#!/usr/bin/env bash
# script to build container with ovftool

set -e

# ovftool download
readonly OVFTOOL_SRC="https://vdc-download.vmware.com/vmwb-repository/dcr-public/f87355ff-f7a9-4532-b312-0be218a92eac/b2916af6-9f4f-4112-adac-49d1d6c81f63/VMware-ovftool-4.5.0-20459872-lin.x86_64.zip"
readonly OVFTOOL_SRC_MD5="7f385e0840f4bb87c544ba57469750d1"

# build container for downloading, and extracting the zip
ctr_build=$(buildah from --pull fedora)
ctr_build_mnt=$(buildah mount $ctr_build)

buildah add $ctr_build "${OVFTOOL_SRC}" /tmp/
buildah run $ctr_build -- sh -c "cd /tmp; md5sum --check <(echo '${OVFTOOL_SRC_MD5} $(basename ${OVFTOOL_SRC})')"
buildah run $ctr_build -- sh -c "dnf -y install --disablerepo='*' --enablerepo='fedora' unzip && unzip /tmp/$(basename ${OVFTOOL_SRC}) -d /tmp/extract"

# build final image
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
