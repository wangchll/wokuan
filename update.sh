#!/bin/sh

if [ ! -d /koolshare/wokuan ]; then
   mkdir -p /koolshare/wokuan
fi

cp -rf /tmp/wokuan/scripts/* /koolshare/scripts/
cp -rf /tmp/wokuan/webs/* /koolshare/webs/
cp -rf /tmp/wokuan/wokuan.sh /koolshare/wokuan/
rm -rf /tmp/wokuan* >/dev/null 2>&1

chmod a+x /koolshare/scripts/config-wokuan.sh
chmod a+x /koolshare/wokuan/wokuan.sh
