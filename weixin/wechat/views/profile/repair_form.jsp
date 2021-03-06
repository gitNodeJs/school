<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@ page import="net.sf.json.JSONArray"%>
<%@ page import="com.app.ajax.weixin.repair.RepairAjax"%>
<%@ include file="/weixin/common/checkLogin.jsp" %>
<%
	JSONObject weixinConfig = esapiPage.getWeixinConfig(request, user.getSchoolId());
	RepairAjax repairAjax = new RepairAjax();
	JSONArray deptArray = repairAjax.getRepairDepts(user.getSchoolId());
%>
<!DOCTYPE HTML5>
<html>
  <head>
  	<meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width">
    <title>提交报修</title>
    <link href="../../public/css/profile/repair_form.css" rel="stylesheet" />
  </head>
  <body>
  	<a class="a-back" href="../profile/repair_list.jsp?listType=1">返回报修列表</a>
  	<div class="lqt-wrapper">
  		<section>
  			<p class="form-title">报修内容</p>
  			<p class="form-content">
  				<textarea class="data" name="content" type="textarea" maxlength="1000"></textarea>
  			</p>
  		</section>
  		<section>
  			<p class="form-title">报修地点</p>
  			<p class="form-content">
  				<input class="data" type="text" name="place" maxlength="20"/>
  			</p>
  		</section>
  		<section>
  			<p class="form-title">报修对象</p>
  			<ul class="dept_list clearfix">
	<% 
		for(int i=0; i<deptArray.size(); i++){
			JSONObject deptInfo = deptArray.getJSONObject(i);
			String deptCode = deptInfo.getString("CODE");
			String deptName = deptInfo.getString("NAME");
			%>
				<li>
  					<label>
  						<input class="data" id="<%=deptCode %>" type="radio" name="dept" <%if(i==0){%>checked="checked"<%}%>/>
  						<span><%=deptName %></span>
  					</label>
  				</li>
			<%
		}
	%>
  			</ul>
  		</section>
  		<section>
  			<p class="form-title">联系电话</p>
  			<p class="form-content">
  				<input class="data" type="text" name="phone" maxlength="15"/>
  			</p>
  		</section>
  		<section>
  			<p class="form-title">上传图片</p>
  			<ul class="clearfix" id="preview-list">
  				<li class="it add"><p><a id="addpic" href="javascript:void(0)"></a></p></li>
  			</ul>
  		</section>
  		<a id="submit" href="javascript:void(0)">提交报修</a>
  	</div>
  	<script>
  		var g_config = {
  			pageType: 'repair_form',
  			REPAIR_ID: 1,//埋一下id,
  			wx: {
  				appId: "<%=weixinConfig.getString("appId") %>", 
	  			timestamp: "<%=weixinConfig.getString("timestamp") %>", 
	  			nonceStr: "<%=weixinConfig.getString("nonceStr") %>", 
	  			signature: "<%=weixinConfig.getString("signature") %>"
  			}
  		};
  	</script>
	<script src="../../public/js/lib/seajs/seajs/2.3.0/sea.js"></script>
	<script src="../../public/js/config/lqt.js"></script>
	<script>seajs.use("../../public/js/profile/repair_publish.js?v=1");</script>
  </body>
</html>