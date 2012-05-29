<%@ page import="java.io.File"%>
<%@ page import="graphDB.explore.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<html>
 <head>
	<script type="text/javascript">
	function gotoUrl(theUrl)
	{		
		document.getElementById('contentToolDiv').innerHTML = '<object id="foo" name="foo" type="text/html" data="' + theUrl + '"></object>';
		//document.body.innerHTML = '<object id="foo" name="foo" type="text/html" data="' + theUrl + '"></object>';
	}
	</script>
 </head>
 <body><div id="contentToolDiv">
	Here are your options:<br><br>
	
<%
	String[] tools = DefaultTemplate.getTools(request.getParameter("id"));
	for(String path : tools)
	{
		String newDesc = path + "/Description.txt";
		String newLaunch = path + "/Launcher.jsp";
		%>
		<button onClick=gotoUrl("<%= newLaunch %>")> 
		<jsp:include page="<%= newDesc %>"/>
		</button>
		<br>
		<%
	}
%>
	</div>
 </body>
</html>