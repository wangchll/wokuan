#!/bin/sh
eval `dbus export wokuan`
source /koolshare/scripts/base.sh
version="0.0.1"
wokuancru=$(cru l | grep "wokuan")
startwokuan=$(ls -l /wokuan/init.d/ | grep "S81Wokuan")

dbus set wokuan_version=$version

#定义请求函数
HTTP_REQ="wget --no-check-certificate -O - "
POST_ARG="--post-data="

#定义更新相关地址
UPDATE_VERSION_URL="https://raw.githubusercontent.com/koolshare/koolshare.github.io/master/wokuan/version"
UPDATE_TAR_URL="https://raw.githubusercontent.com/koolshare/koolshare.github.io/master/wokuan/wokuan.tar.gz"

#获取迅雷用户uid
get_wokuan(){
	ret=`$HTTP_REQ http://bj.wokuan.cn/web/startenrequest.php`
	#判断是否可以加速
	ov=`echo $ret|awk -F 'ov=' '{print $2}'|awk -F '&' '{print $1}'`

	if [ "$ov" == "success" ]
	  then
		  wokuan_can_upgrade=1
		  dbus set wokuan_can_upgrade=$wokuan_can_upgrade
		  oldspeedcode=`echo $ret|awk -F 'old=' '{print $2}'|awk -F '&' '{print $1}'`
		  adslaccount=`echo $ret|awk -F 'cn=' '{print $2}'|awk -F '&' '{print $1}'`
		  upspeed=`echo $ret|awk -F 'up=' '{print $2}'|awk -F '&' '{print $1}'`
		  dbus set wokuan_oldspeedcode=$oldspeedcode
		  dbus set wokuan_adslaccount=$adslaccount
		  dbus set wokuan_upspeed=$upspeed
	  else
		  dbus set wokuan_warning="您的宽带不具备北京联通沃宽加速条件，请确认您是北京联通沃宽用户!"
		  #echo "您的宽带不具备北京联通沃宽加速条件，请确认您是北京联通沃宽用户!"
	fi
}



#快鸟加速注销
wokuan_recover(){
	round=$(date '+%s')
	recover=`$HTTP_REQ "http://bj.wokuan.cn/web/lowerspeed.php?ContractNo=$adslaccount&round=$round"`
	echo $recover
}

#将执行脚本写入crontab定时运行
add_wokuan_cru(){
	if [ "$wokuan_can_upgrade" == "1" ] && [ -f /koolshare/wokuan/wokuan.sh ]; then
		#确保有执行权限
		chmod +x /koolshare/wokuan/wokuan.sh
		cru a wokuan "*/4 * * * * /koolshare/wokuan/wokuan.sh"
	fi
}

#加入开机自动运行
auto_start(){
	if [ "$wokuan_can_upgrade" == "1" ] && [ "$wokuan_start" == "1" ] && [ -f /koolshare/wokuan/wokuan.sh ]; then
		if [ -f /koolshare/init.d/S81Wokuan.sh ]; then
			rm -rf /koolshare/init.d/S81Wokuan.sh
		fi
		cat > /koolshare/init.d/S81Wokuan.sh <<EOF
#!/bin/sh
cru a wokuan "*/4 * * * * /koolshare/wokuan/wokuan.sh"
sh /koolshare/wokuan/wokuan.sh
EOF
		chmod +x /koolshare/init.d/S81Wokuan.sh
	fi
}

#停止快鸟服务
stop_wokuan(){
	#停掉cru里的任务
	if [ ! -z "$wokuancru" ]; then
		cru d wokuan
	fi
	#停止自启动
	if [ -f /koolshare/init.d/S81Wokuan.sh ]; then
		rm -rf /koolshare/init.d/S81Wokuan.sh
	fi
	#清理运行环境临时变量
	dbus ram wokuan_run_warnning=""
	dbus ram wokuan_run_status=0
}

#检查版本
check_version(){
	wokuan_version_web1=$(curl -s $UPDATE_VERSION_URL | sed -n 1p)

	if [ ! -z $wokuan_version_web1 ];then
		dbus set wokuan_version_web=$wokuan_version_web1
	fi
}

##更新插件

if [ "$wokuan_update_check" == "1" ];then

	# wokuan_install_status=	#
	# wokuan_install_status=0	#
	# wokuan_install_status=1	#正在下载更新......
	# wokuan_install_status=2	#正在安装更新...
	# wokuan_install_status=3	#安装更新成功，5秒后刷新本页！
	# wokuan_install_status=4	#下载文件校验不一致！
	# wokuan_install_status=5	#然而并没有更新！
	# wokuan_install_status=6	#正在检查是否有更新~
	# wokuan_install_status=7	#检测更新错误！

	dbus set wokuan_install_status="6"
	wokuan_version_web1=`curl -s $UPDATE_VERSION_URL | sed -n 1p`
	if [ ! -z $wokuan_version_web1 ];then
		dbus set wokuan_version_web=$wokuan_version_web1
		cmp=`versioncmp $wokuan_version_web1 $version`
		if [ "$cmp" = "-1" ];then
			dbus set wokuan_install_status="1"
			cd /tmp
			md5_web1=`curl -s $UPDATE_VERSION_URL | sed -n 2p`
			wget --no-check-certificate --tries=1 --timeout=15 $UPDATE_TAR_URL
			md5sum_gz=`md5sum /tmp/wokuan.tar.gz | sed 's/ /\n/g'| sed -n 1p`
			if [ "$md5sum_gz" != "$md5_web1" ]; then
				dbus set wokuan_install_status="4"
				rm -rf /tmp/wokuan* >/dev/null 2>&1
				sleep 5
				dbus set wokuan_install_status="0"
			else
				stop_wokuan
				tar -zxf wokuan.tar.gz
				dbus set wokuan_enable="0"
				dbus set wokuan_install_status="2"
				chmod a+x /tmp/wokuan/update.sh
				sh /tmp/wokuan/update.sh
				sleep 2
				dbus set wokuan_install_status="3"
				dbus set wokuan_version=$wokuan_version_web1
				sleep 2
				dbus set wokuan_install_status="0"
			fi
		else
			dbus set wokuan_install_status="5"
			sleep 2
			dbus set wokuan_install_status="0"
		fi
	else
		dbus set wokuan_install_status="7"
		sleep 5
		dbus set wokuan_install_status="0"
	fi
	dbus set wokuan_update_check="0"
	exit 0
fi

##主逻辑
#执行初始化
dbus set wokuan_warning=""
dbus set wokuan_can_upgrade=0
stop_wokuan

if [ "$wokuan_enable" == "1" ]; then
	#登陆迅雷获取uid
	get_wokuan
	#判断是否登陆成功
	if [ -n "$adslaccount" ]; then
		#写入crontab
		add_wokuan_cru
		#开机执行
		auto_start
		#检查下插件版本
		check_version
		#判断cru脚本是否正在执行
		wokuan_is_run=$(ps|grep '/koolshare/wokuan/wokuan.sh'|grep -v grep)
		if [ ! -z "$wokuan_is_run" ]; then
			sleep 2
		fi
		sh /koolshare/wokuan/wokuan.sh
	fi
fi
