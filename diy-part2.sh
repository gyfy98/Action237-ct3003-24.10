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

# 添加最新的passwall
# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
# 移除 openwrt feeds 过时的luci版本
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci


# 修复： ERROR: package/feeds/packages/rust [host] failed to build.
# 根据https://github.com/immortalwrt/packages/issues/1607
sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile


# 修复： 包ebtables的hash problem
# Hash of the downloaded file does not match (file: 3039d73b167c41025b1b401b647743b9c6d786613c693eef34de325b30de6d47, requested: 1ee560498e1a047b329eab3dad8425ae51e7f0527e4495efb99481ca11206b37)
if grep -q "PKG_MIRROR_HASH:=1ee560498e1a047b329eab3dad8425ae51e7f0527e4495efb99481ca11206b37" package/network/utils/ebtables/Makefile; then
    sed -i 's/PKG_MIRROR_HASH:=1ee560498e1a047b329eab3dad8425ae51e7f0527e4495efb99481ca11206b37/PKG_MIRROR_HASH:=3039d73b167c41025b1b401b647743b9c6d786613c693eef34de325b30de6d47/' package/network/utils/ebtables/Makefile
fi


# 修复：rust问题
# Fix Rust build: preserve upstream *.orig files,see https://github.com/openwrt/packages/pull/27487
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
