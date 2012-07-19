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
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@page import="org.neo4j.cypher.javacompat.*"%>
<%@page import="java.util.*" %>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>

<%



String nodeID = request.getParameter("id").toString();
String csvContent = request.getParameter("fileContent").toString();
String isBindingScore = request.getParameter("isBindingScore").toString();
csvContent = csvContent.trim();
String[] csvLines = csvContent.split("\n");
System.out.println(csvContent);


EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
Node currentNode = graphDb.getNodeById(Long.valueOf(request.getParameter("id"))); 
HashMap<String, Node> nodesToUpdate = new HashMap<String, Node>();

// first read the header
//attributeName is the attribute to consider to identify one node only and change its value
String attributeNameToIdentify = csvLines[0].split(",")[0].trim();
System.out.println("attributeNameToIdentify:"+attributeNameToIdentify);
ArrayList<String> attributeNameToUpdate = new ArrayList<String>(); 

System.out.println("attributeNameToUpdate:");
for (int i=1 ; i<csvLines[0].split(",").length ; i+=1){
	attributeNameToUpdate.add(csvLines[0].split(",")[i].trim());
	System.out.println(attributeNameToUpdate.get(i-1));
}

Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING, DynamicRelationshipType.withName("Listed"));
for (Relationship rel : allRels){
	Node otherNode = rel.getOtherNode(currentNode);
	if (otherNode.hasProperty(attributeNameToIdentify)){
		if (nodesToUpdate.containsKey(otherNode.getProperty(attributeNameToIdentify))){
				System.out.println("not unique!!");
		}else{
			nodesToUpdate.put(otherNode.getProperty(attributeNameToIdentify).toString(), otherNode);
		}
	}
}

System.out.println("created hashmap");
try
{
	
	String identifier;
	Node tmpNode;
	Transaction tx = graphDb.beginTx();
	for (int l=1 ; l<csvLines.length ; l+=1){
		identifier = csvLines[l].split(",")[0];
		System.out.print(identifier);
		tmpNode = nodesToUpdate.get(identifier);
		if (("true".equals(isBindingScore)) && 
			(NodeHelper.getType(graphDb.getNodeById(Long.valueOf(nodeID))).equals("Peptidome"))){
			tmpNode = tmpNode.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING).
					getEndNode();
		}
		for (int i=1 ; i<csvLines[l].split(",").length ; i+=1){
			tmpNode.setProperty(attributeNameToUpdate.get(i-1) , csvLines[l].split(",")[i].trim());
		}
	}
	tx.success();
	tx.finish();
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