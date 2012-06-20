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
<%@ page import="scala.util.parsing.json.JSON" %>

<%
if(session.getAttribute("user") != null)
{	
	//This jsp will add a comment and send back the new list of comments as a result
	String nodeID  = request.getParameter("id");
	object json = JSON.parse(request.getParameter("json"));

	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	
	try
	{				
		String text = json.replaceAll("\\r","<br/>");
		text = text.replaceAll("\\n","<br/>");
		text = text.replaceAll("\\\"", "&#34;");
		text = text.replaceAll("\\\\", "&#92;");
		
		Node theNode = graphDb.getNodeById(Long.valueOf(nodeID));				
		Transaction tx = graphDb.beginTx();
		foreach(kay value pairs)
			theNode.setAttribute(key, value);
		tx.success();
		tx.finish();		
		out.println(theNode.tojson);	
	}
	catch(Exception e)
	{
		e.printStackTrace();
		//out.println("-=" + userID + "=-");	
	}
}
%>