<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
		<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
		<link rel="shortcut icon" href="images/favicon.png"/>
		<link rel="icon" href="images/favicon.png"/>
		<title>软件中心 - 北京联通沃宽加速设置</title>
		<link rel="stylesheet" type="text/css" href="index_style.css"/>
		<link rel="stylesheet" type="text/css" href="form_style.css"/>
		<link rel="stylesheet" type="text/css" href="usp_style.css"/>
		<link rel="stylesheet" type="text/css" href="ParentalControl.css">
		<link rel="stylesheet" type="text/css" href="css/icon.css">
		<link rel="stylesheet" type="text/css" href="css/element.css">
		<script type="text/javascript" src="/state.js"></script>
		<script type="text/javascript" src="/popup.js"></script>
		<script type="text/javascript" src="/help.js"></script>
		<script type="text/javascript" src="/validator.js"></script>
		<script type="text/javascript" src="/js/jquery.js"></script>
		<script type="text/javascript" src="/general.js"></script>
		<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
		<script type="text/javascript" src="/dbconf?p=wokuan_&v=<% uptime(); %>"></script>
        <script type="text/javascript">
		function init() {
			show_menu();
			buildswitch();
			var rrt = document.getElementById("switch");
		    if (document.form.wokuan_enable.value != "1") {
		        rrt.checked = false;
		        document.getElementById('wokuan_detail_table').style.display = "none";
		    } else {
		        rrt.checked = true;
		        document.getElementById('wokuan_detail_table').style.display = "";
		    }
			//conf2obj();
			//var conf_ajax = setInterval("conf2obj();", 60000);
			version_show();
			write_wokuan_install_status();
			check_selected("wokuan_start", db_wokuan_.wokuan_start);
		}

		function onSubmitCtrl(o, s) {
			document.form.action_mode.value = s;
			//防止变为更新操作
			$("#wokuan_update_check").val(0);
			showLoading(5);
			document.form.submit();
			setTimeout("conf2obj()", 8000);
		}

		function pass_checked(obj){
			switchType(obj, document.form.show_pass.checked, true);
		}

		function conf2obj() {
			$.ajax({
				type: "get",
				url: "dbconf?p=wokuan_",
				dataType: "script",
				success: function(xhr) {
			    	var p = "wokuan_";
			        var params = ["warning","can_upgrade", "run_status", "run_warnning"];
			        for (var i = 0; i < params.length; i++) {
						if (typeof db_wokuan_[p + params[i]] !== "undefined") {
							$("#wokuan_"+params[i]).val(db_wokuan_[p + params[i]]);
						}
			        }
					update_visibility();
					check_selected("wokuan_start", db_wokuan_.wokuan_start);
					check_downstream(db_wokuan_.wokuan_run_status);
				}
			});
		}

		function buildswitch(){
			$("#switch").click(
			function(){
				if(document.getElementById('switch').checked){
					document.form.wokuan_enable.value = 1;
					document.getElementById('wokuan_detail_table').style.display = "";
				}else{
					document.form.wokuan_enable.value = 0;
					document.getElementById('wokuan_detail_table').style.display = "none";
				}
			});
		}

		function update_visibility() {
			//不满足快鸟条件的显示异常信息
			//if ($("#wokuan_can_upgrade").val() == "0") {
			//	$("#warn").html($("#wokuan_warning").val());
			//	showhide("warn", ($("#wokuan_can_upgrade").val() == "0"));
			//}
			$("#warn").html($("#wokuan_warning").val());
			showhide("warn", ($("#wokuan_can_upgrade").val() == "0"));
			//给出快鸟运行状态
			$("#kn_state2").html($("#wokuan_run_warnning").val());
		}

		function check_selected(obj, m) {
		    var o = document.getElementById(obj);
		    for (var c = 0; c < o.length; c++) {
		        if (o.options[c].value == m) {
		            o.options[c].selected = true;
		            break;
		        }
		    }
		}

		function check_downstream(state) {
			if (state == "1") {
				$("#kn_upgreade_state").html("沃宽加速运行中~");
			} else {
				$("#kn_upgreade_state").html("沃宽加速未运行！");
			}
		}

		function write_wokuan_install_status(){
			$.ajax({
				type: "get",
				url: "dbconf?p=wokuan_",
				dataType: "script",
				success: function() {
					if (db_wokuan_['wokuan_install_status'] == "1"){
						$("#wokuan_install_show").html("<i>正在下载更新...</i>");
					} else if (db_wokuan_['wokuan_install_status'] == "2"){
						$("#wokuan_install_show").html("<i>正在安装更新...</i>");
					} else if (db_wokuan_['wokuan_install_status'] == "3"){
						$("#wokuan_install_show").html("<i>安装更新成功，5秒后刷新本页!</i>");
						version_show();
						refreshpage(3);
					} else if (db_wokuan_['wokuan_install_status'] == "4"){
					   document.getElementById('updateBtn').style.display = "";
						$("#wokuan_install_show").html("<i>下载文件校验不一致！</i>");
					} else if (db_wokuan_['wokuan_install_status'] == "5"){
						document.getElementById('updateBtn').style.display = "";
						$("#wokuan_install_show").html("<i>然而并没有更新！</i>");
					} else if (db_wokuan_['wokuan_install_status'] == "6"){
			      		$("#wokuan_install_show").html("<i>正在检查是否有更新~</i>");
					} else if (db_wokuan_['wokuan_install_status'] == "7"){
					   document.getElementById('updateBtn').style.display = "";
						$("#wokuan_install_show").html("<i>检测更新错误！</i>");
					} else {
						$("#wokuan_install_show").html("");
					}
					//尝试合并函数
					var p = "wokuan_";
					var params = ["warning","can_upgrade", "run_status", "run_warnning"];
					for (var i = 0; i < params.length; i++) {
						if (typeof db_wokuan_[p + params[i]] !== "undefined") {
							$("#wokuan_"+params[i]).val(db_wokuan_[p + params[i]]);
						}
					}
					update_visibility();
					//check_selected("wokuan_start", db_wokuan_.wokuan_start);
					//check_selected("wokuan_time", db_wokuan_.wokuan_time);
					check_downstream(db_wokuan_.wokuan_run_status);

					setTimeout("write_wokuan_install_status()", 2000);
				}
			});
		}

		function version_show(){
			if (db_wokuan_['wokuan_version'] != db_wokuan_['wokuan_version_web'] && db_wokuan_['wokuan_version_web'] !== undefined){
				$("#wokuan_version_status").html("<i>有新版本：" + db_wokuan_['wokuan_version_web']);
			} else {
				if (db_wokuan_['wokuan_version'] == undefined) {
					$("#wokuan_version_status").html("<i>当前版本：");
				} else {
					$("#wokuan_version_status").html("<i>当前版本：" + db_wokuan_['wokuan_version']);
				}
			}
		}
		function update_wokuan(o, s){
			document.form.wokuan_update_check.value = 1;
			document.getElementById('updateBtn').style.display = "none";
			document.form.action_mode.value = s;
			document.form.submit();
		}

		function reload_Soft_Center() {
			location.href = "/Main_Soft_center.asp";
		}

		function done_validating(action) {
			return true;
		}
        </script>
    </head>
    <body onload="init();">
		<div id="TopBanner"></div>
		<div id="Loading" class="popup_bg"></div>
		<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
		<form method="post" name="form" action="/applydb.cgi?p=wokuan_" target="hidden_frame">
			<input type="hidden" name="current_page" value="Module_wokuan.asp"/>
			<input type="hidden" name="next_page" value="Module_wokuan.asp"/>
			<input type="hidden" name="group_id" value=""/>
			<input type="hidden" name="modified" value="0"/>
			<input type="hidden" name="action_mode" value=""/>
			<input type="hidden" name="action_script" value=""/>
			<input type="hidden" name="action_wait" value="5"/>
			<input type="hidden" name="first_time" value=""/>
			<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
			<input type="hidden" name="SystemCmd" onkeydown="onSubmitCtrl(this, ' Refresh ')" value="config-wokuan.sh"/>
			<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
			<input type="hidden" id="wokuan_warning" name="wokuan_warning" value='<% dbus_get_def("wokuan_warning", ""); %>'/>
			<input type="hidden" id="wokuan_enable" name="wokuan_enable" value='<% dbus_get_def("wokuan_enable", "0"); %>'/>
			<input type="hidden" id="wokuan_can_upgrade" name="wokuan_can_upgrade" value='<% dbus_get_def("wokuan_can_upgrade", "0"); %>'/>
			<input type="hidden" id="wokuan_run_status" name="wokuan_run_status" value='<% dbus_get_def("wokuan_run_status", "0"); %>'/>
			<input type="hidden" id="wokuan_run_warnning" name="wokuan_run_warnning" value='<% dbus_get_def("wokuan_run_warnning", ""); %>'/>
			<input type="hidden" id="wokuan_install_status" name="wokuan_install_status" value="0" />
			<input type="hidden" id="wokuan_update_check" name="wokuan_update_check" value="0" />

			<table class="content" align="center" cellpadding="0" cellspacing="0">
				<tr>
					<td width="17">&nbsp;</td>
					<td valign="top" width="202">
						<div id="mainMenu"></div>
						<div id="subMenu"></div>
					</td>
					<td valign="top">
						<div id="tabMenu" class="submenuBlock"></div>
						<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
							<tr>
								<td align="left" valign="top">
									<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
										<tr>
											<td bgcolor="#4D595D" colspan="3" valign="top">
												<div>&nbsp;</div>
												<div style="float:left;" class="formfonttitle">北京联通沃宽</div>
												<div style="float:right; width:15px; height:25px;margin-top:10px"><img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img></div>
												<div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
												<div class="formfontdesc" style="padding-top:5px;margin-top:0px;float: left;" id="cmdDesc">北京联通沃宽加速，最高可达100M</div>
												<div id="wokuan_version_status" style="padding-top:5px;margin-left:30px;margin-top:0px;float: left;"><i>当前版本：<% dbus_get_def("wokuan_version", "0"); %></i></div>
												<div class="formfontdesc" id="cmdDesc"></div>
												<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="routing_table">
													<thead>
													<tr>
														<td colspan="2">开关设置</td>
													</tr>
													</thead>
													<tr>
													<th>开启沃宽加速</th>
														<td colspan="2">
															<div class="switch_field" style="display:table-cell">
																<label for="switch">
																	<input id="switch" class="switch" type="checkbox" style="display: none;">
																	<div class="switch_container" >
																		<div class="switch_bar"></div>
																		<div class="switch_circle transition_style">
																			<div></div>
																		</div>
																	</div>
																</label>
															</div>
															<div id="update_button" style="padding-top:5px;margin-left:100px;margin-top:-35px;float: left;">
																<button id="updateBtn" class="button_gen" onclick="update_wokuan(this, ' Refresh ');">检查更新</button>
															</div>
															<div id="wokuan_install_show" style="padding-top:5px;margin-left:80px;margin-top:-30px;float: left;"></div>
													</td>
													</tr>
		                                    	</table>
												<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="wokuan_detail_table">

													<thead>
													<tr>
														<td colspan="3">运行状态</td>
													</tr>
													</thead>
													<tr>
													    <th width="35%">沃宽状态</th>
														<td>
															<a>
																<span style="display: none" id="kn_state1">尚未启用! </span>
																<span id="kn_state2"></span>
															</a>
														</td>
													</tr>

													<tr>
													    <th width="35%">提速状态</th>
														<td>
															<a>
																<span id="kn_upgreade_state"></span>
															</a>
														</td>
													</tr>

													<thead>
													<tr>
														<td colspan="4">启动设置</td>
													</tr>
													</thead>
													<tr>
													    <th width="35%">开机自启</th>
														<td>
															<select id="wokuan_start" name="wokuan_start" class="input_option"  >
																<option value="1">是</option>
																<option value="0">否</option>
															</select>
														</td>
													</tr>

		 										</table>
		 										<div id="warn" style="display: none;margin-top: 20px;text-align: center;font-size: 20px;margin-bottom: 20px;"class="formfontdesc" ></div>
												<div class="apply_gen">
													<button id="cmdBtn" class="button_gen" onclick="onSubmitCtrl(this, ' Refresh ')">提交</button>
												</div>
												<div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
												<div class="KoolshareBottom">
													<br/>论坛技术支持： <a href="http://www.koolshare.cn" target="_blank"> <i><u>www.koolshare.cn</u></i> </a> <br/>
													后台技术支持： <i>Xiaobao</i> <br/>
													Shell, Web by： <i>wangchll</i><br/>
												</div>
											</td>
										</tr>
									</table>
								</td>
								<td width="10" align="center" valign="top"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</form>
		<div id="footer"></div>
    </body>
</html>
