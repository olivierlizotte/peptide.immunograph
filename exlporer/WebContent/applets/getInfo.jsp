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
<%
if(session.getAttribute("userNodeID") != null)
{
	EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
	try
	{	
		registerShutdownHook(graphDb);
	
		String nodeID = session.getAttribute("userNodeID").toString();
		//if( !session.getAttribute("id").toString().equals("noneEntered"))
		if(request.getParameter("id") != null)
			nodeID = request.getParameter("id");//session.getAttribute("id").toString();
		
		DefaultNode theNode = new DefaultNode(nodeID, graphDb );
		theNode.Initialize();
		out.println("var currentNodeID=" + theNode.getId() + ";\n");
		out.println("var currentNodeType=\""+theNode.getType()+"\";\n");
		out.println(theNode.getAttributeJSON("myAttributeObject"));
		
		out.println(theNode.getCommentsVariable("myCommentData"));	
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	finally
	{
		graphDb.shutdown();
	}
}
%>