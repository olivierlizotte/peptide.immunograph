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

void createLinkerNodeFromIds(EmbeddedGraphDatabase graphDb, Node newNode, List<Long> ids){
	RelationshipType tempRelType = DynamicRelationshipType.withName("query_Result");
	for (long id : ids){
		newNode.createRelationshipTo(graphDb.getNodeById(id), tempRelType);
	}
}

String addFilterToQuery(String oldQuery, String andor, String property, String comparator, String value){
	String newQuery = "";
	if (andor != null){
		newQuery += oldQuery + " "+andor;
	}else{
		newQuery += oldQuery;
	}
	if (property.split(" ").length > 1){
		newQuery += " p.`" +property+ "`! " + comparator;
	}else{
		newQuery += " p." +property+ "! " + comparator;
	}
	if (NodeHelper.isNumber(value)){
		newQuery += value;
	}else{
		newQuery += "\""+value+"\"";
	}
	return newQuery;
}
%>
<%
String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();


ArrayList<String> properties = new ArrayList<String>();
ArrayList<String> comparators = new ArrayList<String>();
ArrayList<String> values = new ArrayList<String>();
ArrayList<String> andOrs = new ArrayList<String>();

String nodeType = request.getParameter("nodeType").toString();
properties.add(request.getParameter("nodeProperty1").toString());
comparators.add(request.getParameter("comparator1").toString());
values.add(request.getParameter("value1").toString());
int nbFilters = Integer.valueOf(request.getParameter("NB_FILTERS").toString());
System.out.println(nbFilters);


for (int i=2 ; i<=nbFilters ; i++){
	andOrs.add(request.getParameter("andor"+(i-1)).toString());
	properties.add(request.getParameter(("nodeProperty"+i)).toString());
	comparators.add(request.getParameter(("comparator"+i)).toString());
	values.add(request.getParameter(("value"+i)).toString());
}

String query = "start n=node("+nodeID+") match n-->p where p.type=\""+nodeType+"\" and ";
query=addFilterToQuery(query, null, properties.get(0), comparators.get(0), values.get(0));
for(int i=1 ; i<nbFilters ; i++){
	System.out.println(andOrs.get(i-1)+" "+properties.get(i)+"! "+comparators.get(i) + " " +values.get(i));
	query=addFilterToQuery(query, andOrs.get(i-1), properties.get(i), comparators.get(i), values.get(i));
}

query += " return ID(p)";
System.out.println(query);

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//Node ResultHeadNode = graphDb.createNode();
//ResultHeadNode.setProperty("information", "Result of a database query");
try
{
	Date date = new Date();
	SimpleDateFormat dateFormat = new SimpleDateFormat ("yyyy.MM.dd 'at' hh:mm:ss");
	
	// create a new temp node linked to the resluts
	Transaction tx = graphDb.beginTx();
	Node tempNode = graphDb.createNode();
	tempNode.setProperty("type", "EasyQuery_output");
	tempNode.setProperty("query", query);
	tempNode.setProperty("created from", graphDb.getNodeById(Long.valueOf(nodeID)).getProperty("type"));
	tempNode.setProperty("created from id", graphDb.getNodeById(Long.valueOf(nodeID)).getId());
	tempNode.setProperty("creation date", dateFormat.format(date));
	Long tempNodeID = tempNode.getId();
	createLinkerNodeFromIds(graphDb, tempNode, getQueryResultAsNodeIds(graphDb, query));
	
	// to know which step of the pipeline it is
	if(graphDb.getNodeById(Long.valueOf(nodeID)).hasProperty("step")){
		tempNode.setProperty("step", Integer.valueOf(graphDb.getNodeById(Long.valueOf(nodeID)).getProperty("step").toString())+1);
	}else{
		tempNode.setProperty("step",1);
	}
	DefaultTemplate.calculateFPR(graphDb, tempNode);
	// calculate de percentage of decoy peptides removed

	//Link to node it was created from
	graphDb.getNodeById(Long.valueOf(nodeID)).createRelationshipTo(tempNode,
								  DynamicRelationshipType.withName("FilterStep"));
	// add the new node to the index of temp nodes
	Index<Node> index = DefaultTemplate.graphDb().index().forNodes("tempNodes");
	
	index.add(tempNode, "type", "tempNode");
	tx.success();
	tx.finish();
	out.print(tempNodeID);
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