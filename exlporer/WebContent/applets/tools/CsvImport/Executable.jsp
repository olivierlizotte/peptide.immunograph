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
String csvContent = request.getParameter("fileContent").toString();
csvContent = csvContent.trim();
String[] csvLines = csvContent.split("\n");
System.out.println(csvContent);

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

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


if(attributeNameToIdentify.equals("Node ID"))
{
	try
	{
		int nbNodes = 0;
		Transaction tx = graphDb.beginTx(); 	
		for (int l=1 ; l < csvLines.length ; l++)
		{	
			String[] splits = csvLines[l].split(","); 
			long nodeid = Long.parseLong(splits[0]);
			Node theNode = graphDb.getNodeById(nodeid);
			for (int i = 1 ; i < splits.length ; i++)
			{
				String value = splits[i].trim();
				if (NodeHelper.isNumeric(value))
					theNode.setProperty(attributeNameToUpdate.get(i-1), Double.valueOf(value));
				else
					theNode.setProperty(attributeNameToUpdate.get(i-1), value);
				nbNodes++;
			}
		}	
		tx.success();
		tx.finish();

		System.out.println("Saved " + nbNodes + " Nodes.");
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
}
else
{
	String nodeID = request.getParameter("id").toString();
	String isBindingScore = request.getParameter("isBindingScore").toString();
	Node currentNode = graphDb.getNodeById(Long.valueOf(request.getParameter("id"))); 
	HashMap<String, Node> nodesToUpdate = new HashMap<String, Node>();


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
	
	try
	{	
		Transaction tx = graphDb.beginTx(); 	
		{
			Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING, DynamicRelationshipType.withName("Listed"));
			// if the csv contains information about bindingscore, put it in the "Sequence" Node.
			if ("true".equals(isBindingScore)){
				System.out.println("isBindingScore "+isBindingScore);
				double bestHLAscore, tmpScore;
				String bestAllel;
				for (Relationship rel : allRels){
					Node otherNode = rel.getOtherNode(currentNode);
					bestHLAscore = Double.MAX_VALUE;
					bestAllel="";
					//if the node has the property we are loking for to identify
					if (otherNode.hasProperty(attributeNameToIdentify)){
						// if the other node is part of the nodes to update
						if (csvHash.containsKey(otherNode.getProperty(attributeNameToIdentify).toString())){
							for (String attributeName : csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).keySet()){
								tmpScore = Double.valueOf(csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).get(attributeName));
								otherNode.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING)
										 .getEndNode()
										 .setProperty(attributeName, tmpScore);
								if (tmpScore < bestHLAscore){
									bestHLAscore = tmpScore;
									bestAllel = attributeName;
								}
							}
							otherNode.setProperty("best HLA allele", bestAllel);
							otherNode.setProperty("best HLA score", bestHLAscore);
						}
					}
				}
			}else{
				System.out.println("isBindingScore "+isBindingScore);
				String value;
				for (Relationship rel : allRels)
				{
					Node otherNode = rel.getOtherNode(currentNode);
					// if the node has the property we are loking for to identify
					if (otherNode.hasProperty(attributeNameToIdentify))
					{
						// if the other node is part of the nodes to update
						if (csvHash.containsKey(otherNode.getProperty(attributeNameToIdentify).toString()))
						{
							for (String attributeName : csvHash.get(otherNode.getProperty(attributeNameToIdentify).toString()).keySet())
							{
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
}
%>