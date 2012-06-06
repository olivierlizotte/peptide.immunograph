<%@ page import="java.io.File"%>
<%@ page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionResult"%>
<%@ page import="org.neo4j.graphdb.Direction"%>
<%@ page import="org.neo4j.graphdb.GraphDatabaseService"%>
<%@ page import="org.neo4j.graphdb.Node"%>
<%@ page import="org.neo4j.graphdb.Relationship"%>
<%@ page import="org.neo4j.graphdb.RelationshipType"%>
<%@ page import="org.neo4j.graphdb.Transaction"%>
<%@ page import="org.neo4j.graphdb.index.Index"%>
<%@ page import="org.neo4j.kernel.AbstractGraphDatabase"%>
<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="graphDB.explore.*"%>
<?xml version="1.0" encoding="utf-8" ?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
	<script type="text/javascript" src="js/jquery-1.7.1.min.js"></script>
    <script type="text/javascript" src="js/d3/d3.js"></script>
    <script type="text/javascript" src="js/d3/d3.geom.js"></script>
    <script type="text/javascript" src="js/d3/d3.layout.js"></script>	
	<script type="text/javascript" src="js/jquery.tipsy.js"></script>
    <link href="css/tipsy.css" rel="stylesheet" type="text/css" />
    
	<script type="text/javascript" src="js/graph.js"></script>
</head>
 <body>     
    <div id="navigationID">	
		<script type="text/javascript">
		<%
		DefaultNode theNode = (DefaultNode) session.getAttribute("currentNode");
		if(session.getAttribute("userNodeID") != null)
		{	
			//theNode = null;//(DefaultNode) session.getAttribute("currentNode");
			
			if(theNode == null)
			{
				String nodeID = session.getAttribute("userNodeID").toString();
				if (request.getParameter("id") != null)
					nodeID = request.getParameter("id");
				
				try 
				{
					theNode = new DefaultNode(nodeID);
					theNode.Initialize();//TODO optimize this call to prevent preloading when key is not empty
				} catch (Exception e) 
				{
					e.printStackTrace();
				}
			}//*/
		}
		%>
		
		var dataObject = <%= theNode.getChildren() %>;
			CreateGraph(dataObject, "navigationID");
		</script>
	</div>
 </body>
</html>