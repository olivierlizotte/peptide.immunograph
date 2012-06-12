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
void createLinkerNodeFromIds(EmbeddedGraphDatabase graphDb, Node newNode, List<Long> ids){
	RelationshipType tempRelType = DynamicRelationshipType.withName("tempRelation");
	for (long id : ids){
		newNode.createRelationshipTo(graphDb.getNodeById(id), tempRelType);
	}
}

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

%>
<%
String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();

String aminoAcid = request.getParameter("aa");
int position = Integer.valueOf(request.getParameter("pos"));
String start = request.getParameter("start");

String cypherQuery;
// build regular expression to the start position that has been chosen
if (start.equals("Nterm")){
	cypherQuery ="start n=node("+nodeID+") "+
				 "match n-->p "+
				 "where has(p.Sequence) and p.Sequence=~/.{"+String.valueOf(position-1)+ "}"+aminoAcid+".*/  return ID(p)";
}else{
	cypherQuery ="start n=node("+nodeID+") "+
			 "match n-->p "+
			 "where has(p.Sequence) and p.Sequence=~/.*"+aminoAcid+".{"+String.valueOf(position-1)+ "}/  return ID(p)";
}

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//Node ResultHeadNode = graphDb.createNode();
//ResultHeadNode.setProperty("information", "Result of a database query");
try
{
	System.out.println(cypherQuery);
	//out.println(cypherQuery);
	
	String[] results = getQueryResultForJs(graphDb, cypherQuery).split("<br>");
	
	// create a new temp node linked to the resluts
// 	Transaction tx = graphDb.beginTx();
// 	Node tempNode = graphDb.createNode();
// 	tempNode.setProperty("type", "temporary Node");
// 	tempNode.setProperty("query", "cypherQuery");
// 	createLinkerNodeFromIds(graphDb, tempNode, getQueryResultAsNodeIds(graphDb, cypherQuery));
// 	tx.success();
// 	tx.finish();
	for (String result : results){
		//out.print(tempNode.getId());
		out.print(results);
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