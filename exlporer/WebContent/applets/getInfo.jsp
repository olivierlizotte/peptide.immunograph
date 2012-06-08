<%@ page import="java.io.File"%>
<%@ page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="graphDB.explore.*" %>
<%
if(session.getAttribute("userNodeID") != null)
{
	try
	{		
		String nodeID = session.getAttribute("userNodeID").toString();
		//if( !session.getAttribute("id").toString().equals("noneEntered"))
		if(request.getParameter("id") != null)
			nodeID = request.getParameter("id");//session.getAttribute("id").toString();
		
		DefaultNode theNode = new DefaultNode(nodeID);
		theNode.Initialize();
		session.setAttribute("currentNode", theNode);
		
		out.println("var currentNodeID=" + theNode.getId() + ";\n");
		out.println("var currentNodeType=\""+theNode.getType()+"\";\n");
		out.println(theNode.getAttributeJSON("myAttributeObject"));
		
		out.println(theNode.getCommentsVariable("myCommentData"));	
		
		out.println("var dataObject = " + theNode.getNavigationChart());
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
}
%>
