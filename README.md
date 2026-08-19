# 说明
基于[P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 而来，利用github action在线构建固件。

1. 默认ip地址`192.168.6.1`
2. 包含的插件：
   - passwall
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
   3. opkg源代有问题
- 24版本：修复了ipv6的统计问题，但：
  1. 自带的homeproxy非常难用，更新慢，还经常莫名奇妙跑满CPU导致整个网络卡死
  2. opkg源还是有问题

  本固件基于24.10分支，目的删除掉homeproxy，换成最新的passwall。同时修复wg没有二维码，opkg源的问题。 目前还在摸索中...


