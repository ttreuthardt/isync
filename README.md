# isync container image

Packaging of isync (https://sourceforge.net/projects/isync) based on the Red Hat ubi9-micro base image.

* isync version: 1.5.0 
* Image: ghcr.io/ttreuthardt/isync:main

# Usage

```sh
docker run --rm -it -v /path/to/isyncrc:/config/isyncrc --user $(id --user) -v $PWD/data:/data ghcr.io/ttreuthardt/isync:main mbsync --config /config/isyncrc -a
```
