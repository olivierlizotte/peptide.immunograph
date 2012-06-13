<%@page import="scala.util.parsing.json.JSONFormat"%>
<%@ page import="graphDB.explore.*" %>
<%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %>
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
<%@page import="org.neo4j.cypher.javacompat.*"%>
<%@page import="java.util.*" %>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<%!

String getQueryResult(EmbeddedGraphDatabase graphDb, String cypherQuery){
	ExecutionEngine engine = new ExecutionEngine( graphDb );
	// VERY IMPORTANT : use the org.neo4j.cypher.javacompat.* and not the org.neo4j.cypher.*
	// otherwise can't iterate over the ExecutionResult
	ExecutionResult result = engine.execute( cypherQuery );
	String rows="";
	for ( Map<String, Object> row : result ){
	    for ( Entry<String, Object> column : row.entrySet() ){
	        rows += column.getKey() + ": " + column.getValue() + ";";
	    }
	    rows += "</br>";
	}
	return rows;
}


String getQueryResultForJs(EmbeddedGraphDatabase graphDb, String cypherQuery){
	ExecutionEngine engine = new ExecutionEngine( graphDb );
	// VERY IMPORTANT : use the org.neo4j.cypher.javacompat.* and not the org.neo4j.cypher.*
	// otherwise can't iterate over the ExecutionResult
	ExecutionResult result = engine.execute( cypherQuery );
	String rows="";
	for ( Map<String, Object> row : result ){
	    for ( Entry<String, Object> column : row.entrySet() ){
	        rows += column.getKey() + "," + column.getValue() + "|";
	    }
	    //rows += ";";
	}
	return rows;
}


%>
<%
String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();



String cypherQuery = request.getParameter("query");
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//Node ResultHeadNode = graphDb.createNode();
//ResultHeadNode.setProperty("information", "Result of a database query");
try
{
	System.out.println(cypherQuery);
	//out.println(cypherQuery);
	
	String[] results = getQueryResultForJs(graphDb, cypherQuery).split("<br>");
	
	for (String result : results){
		//out.print("#"+result.split("\\[")[1].split("]")[0]+"#<br>");
		
		out.print(result);
	}
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