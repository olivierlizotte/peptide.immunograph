<%@page import="scala.util.parsing.json.JSONFormat" %><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.*"%><%@ page import="java.io.*"%><%

try 
{
	// set the http content type to "APPLICATION/OCTET-STREAM
	response.setContentType("APPLICATION/OCTET-STREAM");

	// initialize the http content-disposition header to
	// indicate a file attachment with the default filename
	String disHeader = "Attachment;	Filename=\"List.csv\"";
	response.setHeader("Content-Disposition", disHeader);

	String nodeID = request.getParameter("id").toString();
    String nodeType = request.getParameter("nodeType").toString();
    String nodeProperties = request.getParameter("nodeProperties").toString();

    EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
    Node currentNode = graphDb.getNodeById(Long.valueOf(request.getParameter("id"))); 

	Grid.GetListAsCsv(out, nodeProperties, nodeID, nodeType);
}
catch(Exception e) // file IO errors
{
   e.printStackTrace();
}
%>