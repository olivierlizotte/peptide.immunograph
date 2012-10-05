<%@page import="scala.util.parsing.json.JSONFormat"%>
<%@ page import="graphDB.explore.*" %>
<%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.DynamicRelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@page import="org.neo4j.cypher.javacompat.*"%>
<%@page import="java.util.*" %>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.*"%>
<%!

List<Long> getQueryResultAsNodeIds(EmbeddedGraphDatabase graphDb, String cypherQuery){
	ExecutionEngine engine = new ExecutionEngine( graphDb );
	// VERY IMPORTANT : use the org.neo4j.cypher.javacompat.* and not the org.neo4j.cypher.*
	// otherwise can't iterate over the ExecutionResult
	ExecutionResult result = engine.execute( cypherQuery );
	List<Long> ids = new ArrayList<Long>();
	for ( Map<String, Object> row : result ){
	    for ( Entry<String, Object> column : row.entrySet() ){
	        ids.add(Long.valueOf(column.getValue().toString()));
	    }
	    //rows += ";";
	}
	return ids;
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

void createLinkerNodeFromIds(EmbeddedGraphDatabase graphDb, Node newNode, List<Long> ids){
	RelationshipType tempRelType = DynamicRelationshipType.withName("query_Result");
	for (long id : ids){
		newNode.createRelationshipTo(graphDb.getNodeById(id), tempRelType);
	}
}
%>
<%
String nodeID = request.getParameter("id").toString();
System.out.println(nodeID);
String relationType = request.getParameter("rel").toString();
String returnID = request.getParameter("returnID").toString();
System.out.println(returnID);
String cypherQuery = request.getParameter("query");
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//Node ResultHeadNode = graphDb.createNode();
//ResultHeadNode.setProperty("information", "Result of a database query");
try
{
	// if returning node IDs, create a node to groupe the results
	if ("true".equals(returnID)){
		Transaction tx = graphDb.beginTx();
		Date date = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat ("yyyy.MM.dd 'at' hh:mm:ss");
		Node tempNode = graphDb.createNode();
		tempNode.setProperty("type", "ExpertMode_output");
		tempNode.setProperty("query", cypherQuery);
		//tempNode.setProperty("created from", graphDb.getNodeById(Long.valueOf(nodeID)).getProperty("type"));
		//tempNode.setProperty("created from id", graphDb.getNodeById(Long.valueOf(nodeID)).getId());
		tempNode.setProperty("creation date", dateFormat.format(date));
		Long tempNodeID = tempNode.getId();
		createLinkerNodeFromIds(graphDb, tempNode, getQueryResultAsNodeIds(graphDb, cypherQuery));
		if(graphDb.getNodeById(Long.valueOf(nodeID)).hasProperty("step")){
			tempNode.setProperty("step", Integer.valueOf(graphDb.getNodeById(Long.valueOf(nodeID)).getProperty("step").toString())+1);
		}else{
			tempNode.setProperty("step",1);
		}
		graphDb.getNodeById(Long.valueOf(nodeID)).
				createRelationshipTo(tempNode, DynamicRelationshipType.withName("FilterStep"));
		DefaultTemplate.calculateFPR(graphDb, tempNode);
		tx.success();
		tx.finish();
		out.print(tempNodeID);
	}else{
		String[] results = getQueryResultForJs(graphDb, cypherQuery).split("<br>");
		for (String result : results){
			out.print(result);
		}
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