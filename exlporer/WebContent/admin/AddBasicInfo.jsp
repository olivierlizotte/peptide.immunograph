<%@ page import="graphDB.explore.*" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%
try{
	Transaction tx = DefaultTemplate.graphDb().beginTx();
	DefaultTemplate.addBasicInformation(DefaultTemplate.graphDb(), Long.valueOf(2));
	tx.success();
	tx.finish();
	System.out.println("added info");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>