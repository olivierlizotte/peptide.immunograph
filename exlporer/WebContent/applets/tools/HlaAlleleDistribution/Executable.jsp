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
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<%@ page import="java.text.*"%>
<%!

boolean isInIntervall(double x, int a, int b){
	if ((x>=a)&&(x<b))
		return true;
	else
		return false;
}

HashMap<String,String> getHlaAlleleDistribution(EmbeddedGraphDatabase graphDb, long nodeID){
	HashMap<String,String> info = new HashMap<String,String>();
	String jsonString = "";
	double ratio;
	int maxValue = 0;
	Node currentNode = graphDb.getNodeById(nodeID);
	Map<String,Integer> target = new HashMap<String,Integer>();
	Map<String,Integer> decoy = new HashMap<String,Integer>();
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	
	String bestHLA;
	for (Relationship rel : allRels){
		Node otherNode = rel.getOtherNode(currentNode);
		if (("Peptide".equals(NodeHelper.getType(otherNode)))&&(otherNode.hasProperty("best HLA allele"))){
			bestHLA = otherNode.getProperty("best HLA allele").toString();
			// if target hit
			if(otherNode.getProperty("Decoy").toString().equals("False")){
				if (target.containsKey(bestHLA)){
					target.put(bestHLA, target.get(bestHLA) + 1);
				}else{
					target.put(bestHLA, 1);
				}
			// if decoy hit
			}else{
				if (decoy.containsKey(bestHLA)){
					decoy.put(bestHLA, decoy.get(bestHLA) + 1);
				}else{
					decoy.put(bestHLA, 1);
				}
			}
		}
	}
	// just in case one allele is not in target or decoy keys
	for(String allele : target.keySet()){
		if (!decoy.containsKey(allele))
			decoy.put(allele,0);
	}
	for(String allele : decoy.keySet()){
		if (!target.containsKey(allele))
			target.put(allele,0);
	}
	
	maxValue = Math.max(Collections.max(target.values()), Collections.max(target.values()));
		
	jsonString += "{"+
		    "fields: ['allele', 'target', 'decoy', 'ratio'],"+
			"data: [";
	for (String i : target.keySet())
	{
		if(target.get(i)+decoy.get(i) > 0)
			ratio = decoy.get(i) / (double)(target.get(i)+decoy.get(i));
		else
			ratio = 0;
		jsonString += "{allele:'"+i+"', target:'"+target.get(i)+"', decoy:'"+decoy.get(i)+"', ratio:'"+ratio+"'},";
	}
	jsonString=jsonString.substring(0, jsonString.length()-1);
	jsonString += "]}";
	
	info.put("data",jsonString);
	info.put("maxYaxis", String.valueOf(maxValue));
	return info;
}
%>
<%

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
String nodeID = request.getParameter("id");
String nodeType = NodeHelper.getType(graphDb.getNodeById(Integer.valueOf(nodeID)));
try{
	Transaction tx = graphDb.beginTx();
	// get the relashionship to the node storing information about charts. In theory there should only be one node concerned.
	// in theory only one node.
	
	// if the relationship doesn't existe yet, create it
	//if(!graphDb.getNodeById(Integer.valueOf(nodeID)).hasRelationship(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING))
	{		
		HashMap<String,String> nodeInfo = getHlaAlleleDistribution(graphDb, Long.valueOf(request.getParameter("id")));
		Node charts = graphDb.createNode();
		charts.setProperty("type", "Charts");
		charts.setProperty("AxeY", "Number of Peptides");
		charts.setProperty("Name", "HLA allele distribution [" + nodeType + "]");
		charts.setProperty("data", nodeInfo.get("data"));
		charts.setProperty("maxYaxis", nodeInfo.get("maxYaxis"));
		charts.setProperty("xfield", "'allele'");
		charts.setProperty("yfield", "['decoy', 'target']");
		Date date = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat ("yyyy.MM.dd 'at' hh:mm:ss");
		charts.setProperty("creation date", dateFormat.format(date));
		graphDb.getNodeById(Integer.valueOf(nodeID)).
				createRelationshipTo(charts, DynamicRelationshipType.withName("Tool_output"));
		DefaultTemplate.linkToExperimentNode(graphDb, charts, "Tool_output");
		System.out.println("just created "+charts.getId());
	
	}/*else{
		Relationship toolOutput = graphDb.getNodeById(Integer.valueOf(nodeID)).
				getSingleRelationship(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING);
		// then check if the data for this chart were already fetched from DB
		
		if(!toolOutput.getEndNode().getProperty(chartName).equals(null)){
			System.out.println("already exists"+toolOutput.getEndNode().getId());
			// this information has already been stored in the DB!
			// TODO: dialog message asking if the user wants to overwrite it
			toolOutput.getEndNode().setProperty(chartName, getPeptidesLengthDistribution(graphDb, cypherQuery));
			System.out.println("RE-calculated "+toolOutput.getEndNode().getId());
		}//otherwise store the data to built chart
		else{
			System.out.println("create only data"+toolOutput.getEndNode().getId());
			toolOutput.getEndNode().setProperty(chartName, getPeptidesLengthDistribution(graphDb, cypherQuery));				
		}
	}//*/

	tx.success();
	tx.finish();
	out.println(Long.valueOf(request.getParameter("id")));
}
catch(Exception e)
{
	e.printStackTrace();
}
%>