#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# Fix Rust build: preserve upstream *.orig files
# 这rust害人不浅，本地编译和github编译都出错。
python3 - <<'PY'
from pathlib import Path

f = Path("feeds/packages/lang/rust/Makefile")
s = f.read_text()

if "define Host/Patch" in s:
    print("Rust Host/Patch override already exists.")
    raise SystemExit(0)

marker = "define Host/Compile"

patch = r'''define Host/Patch
	$(if $(HOST_QUILT),rm -rf $(HOST_BUILD_DIR)/patches; mkdir -p $(HOST_BUILD_DIR)/patches)
	$(if $(HOST_QUILT),$(call PatchDir/Quilt,$(HOST_BUILD_DIR),$(HOST_PATCH_DIR),))
	$(if $(HOST_QUILT),touch $(HOST_BUILD_DIR)/.quilt_used)
	$(if $(HOST_QUILT),,$(if $(wildcard $(HOST_PATCH_DIR)/*.patch), \
	$(foreach p,$(sort $(wildcard $(HOST_PATCH_DIR)/*.patch)), \
	echo "Applying patch $(notdir $p)" ; \
	$(PATCH) -f -p1 -d $(HOST_BUILD_DIR) < $p || \
	{ echo "Patch failed! Please fix: $(notdir $p)!" ; exit 1 ; } ; \
	) \
	))
endef

'''

if marker not in s:
    raise SystemExit("ERROR: Host/Compile not found")

f.write_text(s.replace(marker, patch, 1))
PY
