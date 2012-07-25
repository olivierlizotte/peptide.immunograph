<%@page import="org.neo4j.cypher.internal.commands.IsNull"%>
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


//Hashmap containing the csv data. <Sequence, < new attribute name, value>>
HashMap<String, HashMap<String, String>> csvHash = new HashMap<String, HashMap<String, String>>();
//HashMap<String, String> tempAttributesHashMap = new HashMap<String, String>();
for (int l=1 ; l<csvLines.length ; l+=1){
	HashMap<String, String> tempAttributesHashMap = new HashMap<String, String>();
	for (int i=1 ; i<csvLines[l].split(",").length ; i+=1){
		//System.out.println(attributeNameToUpdate.get(i-1) +" "+ csvLines[l].split(",")[i].trim());
		tempAttributesHashMap.put(attributeNameToUpdate.get(i-1) , csvLines[l].split(",")[i].trim());
	}
	csvHash.put(csvLines[l].split(",")[0].trim(),tempAttributesHashMap);
}

System.out.println("created csv hashmap");
for (String seq : csvHash.keySet()){
 	System.out.println(seq+" "+csvHash.get(seq).get("HLA-A03:01"));
}

try
{
	
	
	Transaction tx = graphDb.beginTx(); 
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING, DynamicRelationshipType.withName("Listed"));
	// if the csv contains information about bindingscore, put it in the "Sequence" Node.
	if ("true".equals(isBindingScore)){
		System.out.println("isBindingScore "+isBindingScore);
		double bestHLAscore, tmpScore;
		for (Relationship rel : allRels){
			Node otherNode = rel.getOtherNode(currentNode);
			bestHLAscore = Double.MAX_VALUE;
			// if the node has the property we are loking for to identify
			if (otherNode.hasProperty(attributeNameToIdentify)){
				// if the other node is part of the nodes to update
				if (csvHash.containsKey(otherNode.getProperty(attributeNameToIdentify).toString())){
					for (String attributeName : csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).keySet()){
						tmpScore = Double.valueOf(csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).get(attributeName));
						otherNode.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING)
								 .getEndNode()
								 .setProperty(attributeName, tmpScore);
						if (tmpScore < bestHLAscore)
							bestHLAscore = tmpScore;
					}
					otherNode.setProperty("best HLA", bestHLAscore);
				}
			}
		}
	}else{
		System.out.println("isBindingScore "+isBindingScore);
		String value;
		for (Relationship rel : allRels){
			Node otherNode = rel.getOtherNode(currentNode);
			// if the node has the property we are loking for to identify
			if (otherNode.hasProperty(attributeNameToIdentify)){
				// if the other node is part of the nodes to update
				if (csvHash.containsKey(otherNode.getProperty(attributeNameToIdentify).toString())){
					for (String attributeName : csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).keySet()){
						value = csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).get(attributeName);
						if (NodeHelper.isNumeric(value))
							otherNode.setProperty(attributeName, Double.valueOf(csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).get(attributeName)));
						else
							otherNode.setProperty(attributeName, csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).get(attributeName));
					}
				}
			}
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