# isync container image

Packaging of isync (https://sourceforge.net/projects/isync) based on the Red Hat ubi9-micro base image.

* isync version: 1.5.0 
* Image: ghcr.io/ttreuthardt/isync:main

IMPORTANT: Please note that the binary of isync is `mbsync`. 

# Usage

The default config location is /config/isyncrc. You can mount your config file to this location.

```sh
docker run --rm -it -v $PWD/isyncrc:/config/isyncrc --user $(id --user) -v $PWD/data:/data ghcr.io/ttreuthardt/isync:main -a
```
