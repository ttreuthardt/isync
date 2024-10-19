ARG DISTRO_BASE=/distrobase
ARG ADDITIONAL_PACKAGES="coreutils-single glibc-minimal-langpack openssl"

FROM registry.access.redhat.com/ubi9/ubi-micro:latest AS base

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest AS builder

ARG DISTRO_BASE
ARG ADDITIONAL_PACKAGES
ARG DNF_ARGS="--installroot ${DISTRO_BASE} --config /etc/dnf/dnf.conf --noplugins --nodocs --releasever 9 --setopt=install_weak_deps=0 --setopt=cachedir=/var/cache/dnf --setopt=reposdir=/etc/yum.repos.d/ --setopt=varsdir=/etc/dnf/vars/"

ARG ISYNC_URL=https://sourceforge.net/projects/isync/files/isync/1.5.0/isync-1.5.0.tar.gz/download
ARG ISYNC_SHA=2f6b1022a0169403148b64077a7d8130f776475c
ARG ISYNC_FILE=isync.tar.gz

# prepare ubi-micro filesystem
RUN mkdir ${DISTRO_BASE}
COPY --from=base / ${DISTRO_BASE}

# install additional ubi-micro packages 
RUN microdnf install -y ${DNF_ARGS} ${ADDITIONAL_PACKAGES} \
  && microdnf clean all ${DNF_ARGS} \
  && rm -rf /var/cache/*

# application part
WORKDIR /workdir

RUN microdnf install --nodocs -y gc gcc perl make openssl-devel zlib-devel tar
RUN curl -L -o ${ISYNC_FILE} ${ISYNC_URL} \
  && echo "${ISYNC_SHA} ${ISYNC_FILE}" | sha1sum -c - \
  && tar xzf ${ISYNC_FILE} --strip-components=1 \
  && ./configure --prefix=${DISTRO_BASE}/usr/local \
  && make \
  && make install

# create new image with updated ubi-micro filesystem
FROM scratch
ARG DISTRO_BASE

COPY --from=builder ${DISTRO_BASE}/ . 

CMD ["bash"]