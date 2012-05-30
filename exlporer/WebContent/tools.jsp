<%@ page import="java.io.File"%>
<%@ page import="graphDB.explore.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%!
void registerShutdownHook( final GraphDatabaseService graphDb )
{
    // Registers a shutdown hook for the Neo4j instance so that it
    // shuts down nicely when the VM exits (even if you "Ctrl-C" the
    // running example before it's completed)
    Runtime.getRuntime().addShutdownHook( new Thread()
    {
        @Override
        public void run()
		{
            graphDb.shutdown();
		}
	} );
}
%>
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
	String[] tools;

	EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
	try
	{	
		registerShutdownHook( graphDb );				

		tools = DefaultTemplate.getTools(request.getParameter("id"), graphDb);			
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	finally
	{
		graphDb.shutdown();
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
%>
	</div>
 </body>
</html>