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
<%!


%>
<%
String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();

String cypherQuery = request.getParameter("query");
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

String csvFilePath = "/home/antoine/workspace/test.csv";
File f = new File(csvFilePath);
Scanner csvScanner = new Scanner(f);

Node currentNode = graphDb.getNodeById(Long.valueOf(request.getParameter("id"))); 
HashMap<String, Node> nodesToUpdate = new HashMap<String, Node>();

String line = csvScanner.nextLine();
String[] elmts = line.split(",");// contains the two elements of the current csv row
// attributeName is the attribute to consider to identify one node only and change its value
String attributeNameToUpdate = elmts[1].trim();
String attributeNameToIdentify = elmts[0].trim();

if (NodeHelper.getType(currentNode).equals("Peptidome")){
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	for (Relationship rel : allRels){
		Node otherNode = rel.getOtherNode(currentNode);
		if (otherNode.hasProperty("Sequence")){
			if (nodesToUpdate.containsKey(otherNode.getProperty("Sequence"))){
				System.out.println("not unique!!");
			}else{
				nodesToUpdate.put(otherNode.getProperty("Sequence").toString(), otherNode);
			}
		}
	}
	
	try
	{
		Transaction tx = graphDb.beginTx();
		while (csvScanner.hasNextLine()) {
			line = csvScanner.nextLine();
			elmts = line.split(",");
			//System.out.println(nodesToUpdate.get(elmts[0].trim()).getProperty("type"));
			
			nodesToUpdate.get(elmts[0].trim()).setProperty(attributeNameToUpdate, elmts[1].trim());
			
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
	
	
	
	
}else{
	out.print("operation not available for this node!");
}




%>