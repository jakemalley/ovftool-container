#!/usr/bin/env bash
# script to build container with ovftool

# ovftool zip file
readonly OVFTOOL_SRC=$(find . -type f -name "VMware-ovftool*.zip" -print -quit)

ctr_build=$(buildah from fedora)
ctr_build_mnt=$(buildah mount $ctr_build)
buildah copy $ctr_build "${OVFTOOL_SRC}" /tmp/
buildah run $ctr_build -- sh -c "dnf -y install --disablerepo='*' --enablerepo='fedora' unzip && unzip /tmp/${OVFTOOL_SRC} -d /tmp/extract"

ctr=$(buildah from fedora-minimal)
buildah run $ctr -- sh -c "microdnf -y install libxcrypt-compat libnsl && microdnf clean all && mkdir /data"
buildah copy $ctr $ctr_build_mnt/tmp/extract/ovftool /ovftool

buildah config --env LC_CTYPE=C.utf8 $ctr
buildah config --workingdir /data $ctr
buildah config --cmd "--help" $ctr
buildah config --entrypoint '["/ovftool/ovftool"]' $ctr

buildah commit $ctr localhost/ovftool:latest

buildah unmount $ctr_build
buildah rm $ctr_build $ctr
