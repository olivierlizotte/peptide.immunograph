<%@page import="java.io.File" %>
<%@page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import="org.neo4j.graphdb.Direction" %>
<%@ page import="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.DynamicRelationshipType" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="org.neo4j.graphdb.RelationshipType" %>
<%@ page import="org.neo4j.graphdb.Transaction" %>
<%@ page import="org.neo4j.graphdb.index.Index" %>
<%@ page import="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %>
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
if(session.getAttribute("user") != null)
{	
	//This jsp will add a comment and send back the new list of comments as a result
	String nodeID  = request.getParameter("id");
	String comment = request.getParameter("comment");
	String userID  = session.getAttribute("userNodeID").toString();

	EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
	
	try
	{				
		String text = comment.replaceAll("\\r","<br/>");
		text = text.replaceAll("\\n","<br/>");
		text = text.replaceAll("\\\"", "&#34;");
		text = text.replaceAll("\\\\", "&#92;");
		registerShutdownHook( graphDb );
		Node theNode = graphDb.getNodeById(Long.valueOf(nodeID));
		Node theUser = graphDb.getNodeById(Long.valueOf(userID));
	
		Transaction tx = graphDb.beginTx();
			RelationshipType relType = DynamicRelationshipType.withName( "Comment" );	
			theNode.createRelationshipTo(theUser, relType).setProperty("Text", text);
		tx.success();
		tx.finish();
		
		out.println("{" + DefaultNode.getComments(theNode) + "}");	
	}
	catch(Exception e)
	{
		e.printStackTrace();
		//out.println("-=" + userID + "=-");	
	}
	finally
	{
		graphDb.shutdown();
	}
}
%>