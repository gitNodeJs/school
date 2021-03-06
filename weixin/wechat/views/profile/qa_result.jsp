<%@page import="com.bussiness.oa.ExamenUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lineteam.util.NumberUtil"%>
<%@ page import="net.sf.json.JSONArray"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@ page import="com.app.ajax.weixin.examen.ExamenAjax"%>
<%@ page import="com.lineteam.ajax.DefaultPageAjax"%>
<%@ include file="/weixin/common/checkLogin.jsp" %>
<%
	response.setHeader("Pragma", "No-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setDateHeader("Expires", 0);
	DefaultPageAjax esapi = new DefaultPageAjax(request, response);
	String showExamenId = esapi.getRawParam("qid");
	String examenId = IdEncodingUtil.decode(showExamenId);
	ExamenAjax voteAjax = new ExamenAjax();
	JSONObject info = voteAjax.getExamenJSON(user, examenId, true);
	if(info.isEmpty()){
		response.sendRedirect(ROOTPath+"/weixin/error/notFound.html");
		return;
	}
	String studentId = "";
	if("T_STUDENT".equals(user.getUserType())){
		studentId = user.getUserId();
	}else if("T_PARENT".equals(user.getUserType())){
		studentId = user.getStudentId();
	}
%>
<!DOCTYPE HTML5>
<html>
<head>
	<meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width">
    <title>问卷详情</title>
    <link href="../../public/css/profile/qv.css" rel="stylesheet" />
</head>
<body>
<a class="a-back" href="../profile/qa_list.html">返回问卷列表</a>
<div class="lqt-container" id="vote">
	<div class="homework-container" id="headerBox">
		<ul class="homework-list clearfix header-banner" id="bannerBox">
			<!-- 投票说明 -->
			<li class="it banner-sheet" data-type="checkbox" id="explain">
				<div class="scroll-wrapper">
					<div class="scroll-dom">
						<div class="explain-tips clearfix">
							<div class="tips-content clearfix">
							<%if("1".equals(info.getString("ANONYM_FLAG"))){%>
								<b>匿名问卷</b>
							<%} else {%>
								<b>实名问卷</b>
							<%}%>
							<%if("1".equals(info.getString("HIDE_FLAG"))){%>
								<b>结果不公示</b>
							<%} else {%>
								<b>结果公示</b>
							<%}%>
							</div>
							<span class="deadline"><%=info.getString("OUTDATE") %>截止</span>
						</div>
						<p class="explain-title"><b><%=info.getString("TITLE") %></b></p>
						<p class="explain-content"><%=info.getString("INTRINFO") %></p>
					</div>
				</div>
			</li>
			<!-- 投票说明end -->
<%	JSONArray qArray = info.getJSONArray("QUESTIONS");
	int quesIndex = 0;
	for(int i=0; i<qArray.size(); i++){
		JSONObject qInfo = qArray.getJSONObject(i);
		String qId = qInfo.getString("QID");
		if("1".equals(info.getString("IS_BIG")) && !ExamenUtils.hasThisQuestion(qId, studentId)){
			continue;
		}
		quesIndex++;
		String qType = qInfo.getString("QTYPE");
		String qValue = qInfo.getString("QVALUE");
		JSONArray qOption = qInfo.getJSONArray("QOPTIONS");
		Integer qCount = qInfo.getInt("QCOUNT");
		if("1".equals(qType)){	%>
			<!-- 单选 -->
			<li class="it banner-sheet" data-type="radio" id="<%=qId %>"><!-- id：题目id -->
				<div class="scroll-wrapper">
					<div class="scroll-dom">
						<div class="homework-content">
							<p class="homework-title"><%=quesIndex %>.<b>［单选］</b><%=qInfo.getString("QTITLE") %></p>
							<ul class="homework-answer select-data">
							<%	for(int j=0; j<qOption.size(); j++){
									JSONObject opInfo = qOption.getJSONObject(j);
									String questOptionId =opInfo.getString("OPVALUE"); 
									String otherValue = opInfo.getString("OPOTHERVALUE");
									String active= opInfo.getBoolean("OPSELECT") ? "active" : ""; 
									Integer opCount = opInfo.getInt("OPCOUNT");
									double opCountStr = qCount > 0 ? NumberUtil.double45((double)opCount/(double)qCount*100, 2) : 0D;
							%>
								<li class="answer clearfix" id="<%=questOptionId %>">
									<label class="clearfix">
										<span class="icon-common icon-radio">
											<span class="icon-radio-point <%=active %>"></span>
										</span>
										<span class="answer-content"><%=opInfo.getString("OPTITLE") %></span>
									</label>
								<%if(opInfo.getBoolean("OPOTHERFLAG")){%>
									<div class="answer-qs qs-txt">
									   <textarea class="else-data" name="otherValue"><%=otherValue %></textarea>
									   <div class="qs-content" contenteditable="true"></div>
									</div>
								<%}%>
								<%if("0".equals(info.getString("HIDE_FLAG"))){%>
									<div class="percent-container clearfix">
										<p class="percent"><span style="width:<%=opCountStr %>%"></span></p>
										<span class="tips"><%=opCount %>票</span>
									</div>
								<%}%>
								</li>
							<%	}%>
							</ul>
						</div>
						<input class="answer-data" type="hidden" />
					<%if(i+1 == qArray.size()){%>
						<div class="qa-end">
							<p><%=info.getString("ENDINTRINFO") %></p>
							<p><%=info.getString("DEPTNAME") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=info.getString("PUBLISHDATE") %></p>
						</div>
					<%}%>
					</div>
				</div>
			</li>
			<!-- 单选题 end -->
	<%	}else if("2".equals(qType)){%>
			<!-- 多选 -->
			<li class="it banner-sheet" data-type="checkbox" id="<%=qId %>"><!-- id：题目id -->
				<div class="scroll-wrapper">
					<div class="scroll-dom">
						<div class="homework-content">
							<div class="homework-title"><%=quesIndex %>.<b>［多选］</b><%=qInfo.getString("QTITLE") %></div>
							<ul class="homework-answer select-data">
							<%	for(int j=0; j<qOption.size(); j++){
									JSONObject opInfo = qOption.getJSONObject(j);
									String questOptionId =opInfo.getString("OPVALUE");
									String active= opInfo.getBoolean("OPSELECT") ? "active" : "";
									String otherValue = opInfo.getString("OPOTHERVALUE");
									Integer opCount = opInfo.getInt("OPCOUNT");
									double opCountStr = qCount > 0 ? NumberUtil.double45((double)opCount/(double)qCount*100, 2) : 0D;
							%>
								<li class="answer clearfix" id="<%=questOptionId %>">
									<label class="clearfix">
										<span class="icon-common icon-checkbox">
											<input class="selectBox" type="checkbox" name="checkbox"/>
											<span class="icon-checkbox-point <%=active %>">&#x002c;</span>
										</span>
										<span class="answer-content"><%=opInfo.getString("OPTITLE") %></span>
									</label>
								<%if(opInfo.getBoolean("OPOTHERFLAG")){%>
									<div class="answer-qs qs-txt">
									   <textarea class="else-data" name="otherValue"><%=otherValue %></textarea>
									   <div class="qs-content" contenteditable="true"></div>
									</div>
								<%}%>
								<%if("0".equals(info.getString("HIDE_FLAG"))){%>
									<div class="percent-container clearfix">
										<p class="percent"><span style="width:<%=opCountStr %>%"></span></p>
										<span class="tips"><%=opCount %>票</span>
									</div>
								<%}%>
								</li>
							<%	}%>
							</ul>
						</div>
					<%if(i+1 == qArray.size()){%>
						<div class="qa-end">
							<p><%=info.getString("ENDINTRINFO") %></p>
							<p><%=info.getString("DEPTNAME") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=info.getString("PUBLISHDATE") %></p>
						</div>
					<%}%>
					</div>
				</div>
			</li>
			<!-- 多选end -->
	<%	}else if("3".equals(qType)){%>
			<!-- 问答题 -->
			<li class="it banner-sheet sheet-qs" data-type="checkbox" id="<%=qId %>">
				<div class="scroll-waper">
					<div class="scroll-dom">
						<div class="homework-content">
							<div class="homework-title"><%=quesIndex %>.<b>［问答题］</b><%=qInfo.getString("QTITLE") %></div>
							<ul class="homework-answer">
								<li class="answer-qs qs-txt"><%=qValue %></li>
							</ul>
						</div>
					<%if(i+1 == qArray.size()){%>
						<div class="qa-end">
							<p><%=info.getString("ENDINTRINFO") %></p>
							<p><%=info.getString("DEPTNAME") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=info.getString("PUBLISHDATE") %></p>
						</div>
					<%}%>
		 			</div>
				</div>
			</li>
			<!-- 问答题end -->
	<%	}else if("4".equals(qType)){
		Integer userScore = NumberUtil.toInt(qValue); %>
			<!-- 打分题 -->
			<li class="it banner-sheet" data-type="checkbox" id="<%=qId %>">
				<div class="scroll-waper">
					<div class="scroll-dom">
						<div class="homework-content">
							<div class="homework-title"><%=quesIndex %>.<b>［打分题］</b><%=qInfo.getString("QTITLE") %></div>
					<%
						if("0".equals(info.getString("HIDE_FLAG"))){
							Integer star1 = qInfo.containsKey("STAR1") ? qInfo.getInt("STAR1") : 0;
							Double star1Str = qCount>0&&star1>0 ? NumberUtil.double45((double)star1/(double)qCount*100, 2) : 0D;
							Integer star2 = qInfo.containsKey("STAR2") ? qInfo.getInt("STAR2") : 0;
							Double star2Str = qCount>0&&star2>0 ? NumberUtil.double45((double)star2/(double)qCount*100, 2) : 0D;
							Integer star3 = qInfo.containsKey("STAR3") ? qInfo.getInt("STAR3") : 0;
							Double star3Str = qCount>0&&star3>0 ? NumberUtil.double45((double)star3/(double)qCount*100, 2) : 0D;
							Integer star4 = qInfo.containsKey("STAR4") ? qInfo.getInt("STAR4") : 0;
							Double star4Str = qCount>0&&star4>0 ? NumberUtil.double45((double)star4/(double)qCount*100, 2) : 0D;
							Integer star5 = qInfo.containsKey("STAR5") ? qInfo.getInt("STAR5") : 0;
							Double star5Str = qCount>0&&star5>0 ? NumberUtil.double45((double)star5/(double)qCount*100, 2) : 0D;
							Double scoreCount = (double)(star1+star2*2+star3*3+star4*4+star5*5);
							Double starCount = (double)star1+star2+star3+star4+star5;
							String starCountStr = starCount > 0 ? NumberUtil.removeEndZero(scoreCount/starCount): "0";
					%>
							<ul class="homework-answer select-data">
								<li class="answer clearfix">
									<label class="clearfix">
										<span class="icon-common icon-radio">
											<span class="icon-radio-point <%if(userScore==1){%>active<%}%>"></span>
										</span>
										<div class="clearfix">
						  					<span class="icon-star_e active"></span>
							  			</div>
									</label>
									<div class="percent-container clearfix">
										<p class="percent"><span style="width:<%=star1Str %>%"></span></p>
										<span class="tips"><%=star1 %>票</span>
									</div>
								</li>
								<li class="answer clearfix">
									<label class="clearfix">
										<span class="icon-common icon-radio">
											<span class="icon-radio-point <%if(userScore==2){%>active<%}%>"></span>
										</span>
										<div class="clearfix">
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
							  			</div>
									</label>
									<div class="percent-container clearfix">
										<p class="percent"><span style="width:<%=star2Str %>%"></span></p>
										<span class="tips"><%=star2 %>票</span>
									</div>
								</li>
								<li class="answer clearfix">
									<label class="clearfix">
										<span class="icon-common icon-radio">
											<span class="icon-radio-point <%if(userScore==3){%>active<%}%>"></span>
										</span>
										<div class="clearfix">
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
							  			</div>
									</label>
									<div class="percent-container clearfix">
										<p class="percent"><span style="width:<%=star3Str %>%"></span></p>
										<span class="tips"><%=star3 %>票</span>
									</div>
								</li>
								<li class="answer clearfix">
									<label class="clearfix">
										<span class="icon-common icon-radio">
											<span class="icon-radio-point <%if(userScore==4){%>active<%}%>"></span>
										</span>
										<div class="clearfix">
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
							  			</div>
									</label>
									<div class="percent-container clearfix">
										<p class="percent"><span style="width:<%=star4Str %>%"></span></p>
										<span class="tips"><%=star4 %>票</span>
									</div>
								</li>
								<li class="answer clearfix">
									<label class="clearfix">
										<span class="icon-common icon-radio">
											<span class="icon-radio-point <%if(userScore==5){%>active<%}%>"></span>
										</span>
										<div class="clearfix">
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
						  					<span class="icon-star_e active"></span>
							  			</div>
									</label>
									<div class="percent-container clearfix">
										<p class="percent"><span style="width:<%=star5Str %>%"></span></p>
										<span class="tips"><%=star5 %>票</span>
									</div>
									<div class="percent-container clearfix">本题均分：<%=starCountStr %>分</div>
								</li>
							</ul>
						<%}else {%>
							<div class="score-container clearfix">
			  					<a class="icon-star_e <%if(userScore>0){%>active<%}%>" href="javascript:;"></a>
			  					<a class="icon-star_e <%if(userScore>1){%>active<%}%>" href="javascript:;"></a>
			  					<a class="icon-star_e <%if(userScore>2){%>active<%}%>" href="javascript:;"></a>
			  					<a class="icon-star_e <%if(userScore>3){%>active<%}%>" href="javascript:;"></a>
			  					<a class="icon-star_e <%if(userScore>4){%>active<%}%>" href="javascript:;"></a>
				  			</div>
						<%}%>
						</div>
					<%if(i+1 == qArray.size()){%>
						<div class="qa-end">
							<p><%=info.getString("ENDINTRINFO") %></p>
							<p><%=info.getString("DEPTNAME") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=info.getString("PUBLISHDATE") %></p>
						</div>
					<%}%>
		 			</div>
				</div>
			</li>
			<!-- 打分end -->
	<%	}
	}
%>
		</ul>
	</div>
</div>
<div class="homework-bar clearfix" id="bar">
	<a id="pre" class="homework-btn homework-pre clearfix" href="javascript:void(0)">
		<em class="icon-change icon-pre">&#x0025;</em><span class="txt-change">上一题</span>
	</a>
	<a id="next" class="homework-btn homework-next clearfix" href="javascript:void(0)">
		<span class="txt-change">下一题</span><em class="icon-change icon-next">&#x0025;</em>
	</a>
	<span class="pre-loc"></span>
</div>
<script>
	var g_config = {
		baseUrl: '',
		jsBasePath: '',
		jsVersion: '',
		pageType: 'qa_detail',
		id: '<%=showExamenId %>',//问卷id
		wx: {
			appId: 'wx2e3a10f99ee1c75e',
			timestamp: '', // 必填，生成签名的时间戳
		    nonceStr: '', // 必填，生成签名的随机串
		    signature: '',// 必填，签名
		}
	};
</script>
<script src="../../public/js/lib/seajs/seajs/2.3.0/sea.js"></script>
<script src="../../public/js/config/lqt.js"></script>
<script>seajs.use("../../public/js/profile/qv_detail.js");</script>
</body>
</html>