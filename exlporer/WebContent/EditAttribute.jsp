<%@page import="org.neo4j.shell.util.json.JSONArray"%>
<%@page import="org.neo4j.shell.util.json.JSONObject"%>
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

<%
if(session.getAttribute("user") != null)
{	
	
	//This jsp will add a comment and send back the new list of comments as a result
	String nodeID  = request.getParameter("id");
	//Object obj = request.getParameter("json");
	//out.print(obj);
	//String postParamsJSON = request.getReader().readLine();
	//out.println(postParamsJSON);
	//JSONArray names= obj.names();
    //JSONArray values = obj.toJSONArray(names);
    JSONObject json = new JSONObject(request.getParameter("json"));
    
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	
	try
	{				
		/*String text = json.replaceAll("\\r","<br/>");
		text = text.replaceAll("\\n","<br/>");
		text = text.replaceAll("\\\"", "&#34;");
		text = text.replaceAll("\\\\", "&#92;");//*/
		
		Node theNode = graphDb.getNodeById(Long.valueOf(nodeID));				
		Transaction tx = graphDb.beginTx();

        JSONArray nameArray = json.names();
        JSONArray valArray = json.toJSONArray(nameArray);
        for(int i=0;i<valArray.length();i++)
        {
        	theNode.setProperty(nameArray.getString(i), valArray.get(i));
        }       
//		foreach(kay value pairs)
//			theNode.setAttribute(key, value);
		tx.success();
		tx.finish();		
		out.println(request.getParameter("json"));	
	}
	catch(Exception e)
	{
		e.printStackTrace();
		//out.println("-=" + userID + "=-");	
	}
}
%>