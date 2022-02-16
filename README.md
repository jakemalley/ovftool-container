# ovftool-container

## building

```
cd ovftool-container
cp /path/to/VMware-ovftool-<version>-lin.x86_64.zip .
buildah unshare ./build.sh
```

## run

e.g. to extract an OVA file:

```
podman run --rm -it -v "$(pwd):/data" localhost/ovftool:latest fedora-coreos-35.20220131.3.0-vmware.x86_64.ova .
```