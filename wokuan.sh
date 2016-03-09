#!/bin/sh
eval `dbus export wokuan`
source /koolshare/scripts/base.sh
version="0.0.2"

#定义请求函数
HTTP_REQ="wget --no-check-certificate -O - "
POST_ARG="--post-data="


#快鸟加速注销
wokuan_run(){
	round=$(date '+%s')
	recover=`$HTTP_REQ "http://bj.wokuan.cn/web/improvespeed.php?ContractNo=$adslaccount&up=09&old=$oldspeedcode&round=$round"`
	echo $recover
}

#从dbus中获取配置
oldspeedcode=$wokuan_oldspeedcode
adslaccount=$wokuan_adslaccount

#初始化运行状态(wokuan_run_status 0表示运行异常，1表示运行正常)
if [ -z "$wokuan_run_status" ]; then
	dbus ram wokuan_run_status=0
	wokuan_run_status=0
fi

#判断是否可以加速
if [[ ! $wokuan_can_upgrade -eq 1 ]]; then
	dbus ram wokuan_run_warnning="您的宽带不能使用沃宽加速！"$(date "+%Y-%m-%d %H:%M:%S")
	dbus ram wokuan_run_status=0
	exit 21
fi

#保持心跳
ret=`wokuan_run`
if [ ! -z "`echo $ret|grep "false"`" ]; then
	dbus ram wokuan_run_warnning="沃宽加速失败！"$(date "+%Y-%m-%d %H:%M:%S")
	dbus ram wokuan_run_status=0
	exit 22
else
	dbus ram wokuan_run_warnning="沃宽加速运行正常！"$(date "+%Y-%m-%d %H:%M:%S")
	dbus ram wokuan_run_status=1
fi
