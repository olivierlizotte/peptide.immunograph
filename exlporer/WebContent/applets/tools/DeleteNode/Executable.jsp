<%@ page import="graphDB.explore.*" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@page import="java.util.*" %>


<%
String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();



EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//Node ResultHeadNode = graphDb.createNode();
//ResultHeadNode.setProperty("information", "Result of a database query");
try
{
	Transaction tx = graphDb.beginTx();
	Node tempNode = graphDb.getNodeById(Long.valueOf(nodeID));
	String idToGo = tempNode.getProperty("created from id").toString();
	Iterable<Relationship> tempRels = tempNode.getRelationships();
	for (Relationship rel : tempRels){
		rel.delete();
	}
	tempNode.delete();
	tx.success();
	tx.finish();
	out.print(idToGo);
}
catch(Exception e)
{
	e.printStackTrace();
}
finally
{
	//graphDb.shutdown();
}

%>