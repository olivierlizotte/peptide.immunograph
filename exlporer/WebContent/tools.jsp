<%@ page import="java.io.File"%>
<%@ page import="graphDB.explore.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<html>
 <head>
 	
	<script type="text/javascript">
	function gotoUrl(theUrl)
	{		
		document.getElementById('contentToolDiv').innerHTML = '<object id="foo" name="foo" type="text/html" data="' + theUrl + '?id=' + <%=request.getParameter("id")%> +'&rel='+<%=request.getParameter("rel")%>+'" style="height:100%; min-height:100%; min-width:100%;"></object>';
		//document.body.innerHTML = '<object id="foo" name="foo" type="text/html" data="' + theUrl + '"></object>';
	}
	
		
	</script>
 </head>
 <body >
 <div id="contentToolDiv" style="height:100%; min-height:100%; min-width:100%;">
	Here are your options:<br><br>
	
<%
	String[] tools = {};

// 	try
// 	{				
	
	if (request.getParameter("name").equals("charts")){
		tools = DefaultTemplate.getChartsTools(request.getParameter("id"));
	}
	if(request.getParameter("name").equals("seq")){
		tools = DefaultTemplate.getNodeSpecificTools(request.getParameter("id"));
	}
		
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
	
	
	
	
// 	}
// 	catch(Exception e)
// 	{
// 		e.printStackTrace();
// 	}
// 	finally
// 	{
// 		graphDb.shutdown();
// 	}
%>
	</div>
 </body>
</html>