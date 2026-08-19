# 说明
基于[P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 而来，利用github action在线构建固件。

1. 默认ip地址`192.168.6.1`
2. 包含的插件：
   - passwall（由于内核更新频繁，故不带内核xray、singbox等等，只包含基础的nft proxy支持）
   - openclash
   - ddns-go
   - vlmcsd
   - wireguard（带qrencode）
   - zerotier

# 为何构建此固件
恩山论坛237编译的固件，里面较新的23和24两个版本都有不同的缺陷
- 23版本：
   1. WireGuard不带qrencode，生成的配置无法扫码很不方便
   2. ipv6流量统计不了，导致显示的流量使用信息与实际不符
   3. opkg源有问题（immortalwrt_core用的是`mt7981`，实际没这个包，修改为`filogic`）
- 24版本：修复了ipv6的统计问题，但：
  1. 自带的homeproxy非常难用，更新慢，还经常莫名奇妙跑满CPU导致整个网络卡死
  2. opkg源还是有问题

  本固件基于24.10分支，目的删除掉homeproxy，换成最新的passwall。同时修复wg没有二维码，opkg源的问题。 目前还在摸索中...

# 如何生成config
须在linux环境，推荐Ubuntu20.04。
- 如果你是`linux`用户，且不想污染自己的系统，推荐采用容器化的技术：比如podman（fedora用户可用toolbx，底层就是podman）、docker;也可以虚拟机如`kvm`。
- `win`可尝试`wsl`（似乎得额外配置一些东西，请自己网上找相关教程）、`vmware`等。
  
安装基础环境（若你没有安装，其他系统请自行寻找）：
```
sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib \
  g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev \
  libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev \
  libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano \
  ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip python3-ply python3-docutils \
  python3-pyelftools qemu-utils re2c rsync scons squashfs-tools subversion swig texinfo uglifyjs \
  upx-ucl unzip vim wget xmlto xxd zlib1g-dev zstd
```

1. 克隆仓库：`git clone -b 2410 --single-branch --filter=blob:none https://github.com/padavanonly/immortalwrt-mt798x-24.10 immortalwrt-mt798x-24.10`
2. 转到源代码目录：`cd immortalwrt-mt798x-24.10`
3. 更新feeds：`./scripts/feeds update -a`
4. 安装feeds：`./scripts/feeds install -a`
5. 替换源码为passwall最新：
```sh
# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

# 移除 openwrt feeds 过时的luci版本
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci
```
6. 复制配置文件：`cp -f defconfig/mt7981-ax3000.config .config`
7. 选择你需要的包：`make menuconfig`，保存后其中的`.config`即所需的文件。
