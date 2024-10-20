ARG DISTRO_BASE=/distrobase
ARG ADDITIONAL_PACKAGES="openssl cyrus-sasl-lib"

FROM registry.access.redhat.com/ubi9/ubi-micro:latest AS base

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest AS builder

ARG DISTRO_BASE
ARG ADDITIONAL_PACKAGES
ARG DNF_ARGS="-y --installroot ${DISTRO_BASE} --config /etc/dnf/dnf.conf --noplugins --nodocs --releasever 9 --setopt=install_weak_deps=0 --setopt=cachedir=/var/cache/dnf --setopt=reposdir=/etc/yum.repos.d/ --setopt=varsdir=/etc/dnf/vars/"

ARG ISYNC_URL=https://sourceforge.net/projects/isync/files/isync/1.5.0/isync-1.5.0.tar.gz/download
ARG ISYNC_SHA=2f6b1022a0169403148b64077a7d8130f776475c
ARG ISYNC_FILE=isync.tar.gz

# prepare ubi-micro filesystem
RUN mkdir ${DISTRO_BASE}
COPY --from=base / ${DISTRO_BASE}

# upgrade and install additional ubi-micro packages
RUN  microdnf upgrade ${DNF_ARGS} \
  && microdnf install ${DNF_ARGS} ${ADDITIONAL_PACKAGES} \
  && microdnf clean all ${DNF_ARGS} \
  && rm -rf /var/cache/*

# application part
WORKDIR /workdir

# install build dependencies
RUN microdnf install --nodocs -y gc gcc perl make openssl-devel zlib-devel cyrus-sasl-devel tar

# download, verify and extract isync source
RUN curl -s -L -o ${ISYNC_FILE} ${ISYNC_URL} \
  && echo "${ISYNC_SHA} ${ISYNC_FILE}" | sha1sum -c - \
  && tar xzf ${ISYNC_FILE} --strip-components=1

# build and install isync
RUN ./configure \
  && make \
  && install -p -m 555 src/mbsync ${DISTRO_BASE}/usr/local/bin/mbsync

# create new image with updated ubi-micro filesystem
FROM scratch
ARG DISTRO_BASE
ENV XDG_CONFIG_HOME=/config

COPY --from=builder ${DISTRO_BASE}/ . 

USER nobody

ENTRYPOINT ["/usr/local/bin/mbsync"]
CMD ["--help"]