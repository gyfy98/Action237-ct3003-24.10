# 说明
基于237分支，24.10版本，5.4内核，利用github云编译ct3003的固件。237 24.10固件的缺陷：

1. WireGuard不带qrencode，生成的配置无法扫码很不方便
2. 自带的homeproxy非常难用，更新慢，还经常莫名奇妙跑满CPU导致整个网络卡死
3. opkg源有问题

  本固件目标解决这三个问题。目前还在摸索中...
   
# 插件
- passwall
- openclash
- ddns-go
- vlmcsd
- wireguard（带qrencode）
