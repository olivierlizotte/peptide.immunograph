<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%>
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
<%@ page import="java.text.*"%>
<%!

%>
<%
String nodeID = request.getParameter("id").toString();
String pipelineName = request.getParameter("pipelineName").toString();
String description = request.getParameter("description").toString();



EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
Node parsingNode;
//String cypherQuery ="start n=node("+nodeID+") match n-->p where has(p.Sequence) return p.Sequence";





try{
	Transaction tx = graphDb.beginTx();
	parsingNode = graphDb.getNodeById(Long.valueOf(nodeID));
	ArrayList<String> queries = new ArrayList<String>();
	// create the node storing the pipeline information
	Index<Node> index = DefaultTemplate.graphDb().index().forNodes("tempNodes");
	Node pipeLineNode = graphDb.createNode(); 
	pipeLineNode.setProperty("type", "Pipeline");
	pipeLineNode.setProperty("Name", pipelineName);
	pipeLineNode.setProperty("Description", description);
	Date date = new Date();
	SimpleDateFormat dateFormat = new SimpleDateFormat ("yyyy.MM.dd 'at' hh:mm:ss");
	pipeLineNode.setProperty("creation date", dateFormat.format(date));
	while (parsingNode.hasRelationship(Direction.INCOMING, DynamicRelationshipType.withName("FilterStep"))){
		Relationship oldRelation = parsingNode.getSingleRelationship(DynamicRelationshipType.withName("FilterStep"), Direction.INCOMING);
		pipeLineNode.createRelationshipTo(parsingNode, 
									DynamicRelationshipType.withName("FilterStep"));
		// remove the node from index so that it is not deleted when tomcat restarts
		index.remove(parsingNode);
		parsingNode = oldRelation.getStartNode();
		oldRelation.delete();
	}
	
	//get the user node
	Node userNode = graphDb.getNodeById(Long.valueOf(session.getAttribute("userNodeID").toString()));
	userNode.createRelationshipTo(pipeLineNode, DynamicRelationshipType.withName("DataAnalysis"));
	long userNodeID = userNode.getId();
	tx.success();
	tx.finish();
	out.print(userNodeID);
}
catch(Exception e)
{
	e.printStackTrace();
}
%>