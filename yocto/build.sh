#!/usr/bin/env bash
set -euo pipefail
echo "Yocto bootstrap placeholder."
echo "Add poky as submodule: git submodule add https://git.yoctoproject.org/poky yocto/poky"
echo "Then: source poky/oe-init-build-env build && bitbake-layers add-layer ../meta-edgewatch && bitbake core-image-minimal"
