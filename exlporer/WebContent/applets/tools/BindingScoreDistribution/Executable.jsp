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
/*
50-500-5000-20000->20000
1-2-4-8-16-32-64-128-256-512-1024-2048-4096-8192-16384-32768-65536
*/
boolean isInIntervall(double x, int a, int b){
	if ((x>=a)&&(x<b))
		return true;
	else
		return false;
}

HashMap<String,String> getBindingScoreDistribution(EmbeddedGraphDatabase graphDb, long nodeID)
{
	HashMap<String,String> info = new HashMap<String,String>();
	String jsonString = "";
	double ratio;
	int maxValue = 0;
	Node currentNode = graphDb.getNodeById(nodeID);
	Map<String,Integer> target = new HashMap<String,Integer>();
	Map<String,Integer> decoy = new HashMap<String,Integer>();
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	target.put("<50", 0);
	target.put("[50,500]", 0);
	target.put("[500,5000]", 0);
	target.put("[5000,20000]", 0);
	target.put(">20000", 0);
	
	decoy.put("<50", 0);
	decoy.put("[50,500]", 0);
	decoy.put("[500,5000]", 0);
	decoy.put("[5000,20000]", 0);
	decoy.put(">20000", 0);
	
	List<String> keyOrder = new ArrayList<String>();
	keyOrder.add("<50");
	keyOrder.add("[50,500]");
	keyOrder.add("[500,5000]");
	keyOrder.add("[5000,20000]");
	keyOrder.add(">20000");
	
	String bestHLA;
	for (Relationship rel : allRels){
		Node otherNode = rel.getOtherNode(currentNode);
		
		//if ((otherNode.hasProperty("Sequence")) && (otherNode.hasProperty("Binding Score"))) {
		if (("Peptide".equals(NodeHelper.getType(otherNode)))&&(otherNode.hasProperty("best HLA allele"))){
			bestHLA = otherNode.getProperty("best HLA allele").toString();
			double currentScore = NodeHelper.PropertyToDouble(otherNode.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING).getEndNode().getProperty(bestHLA));
			// if target hit
			if(otherNode.getProperty("Decoy").toString().equals("False")){
				if (currentScore < 50){
					target.put("<50", target.get("<50")+1);
				}
				if(isInIntervall(currentScore, 50, 500)){
					target.put("[50,500]", target.get("[50,500]")+1);
				}
				if(isInIntervall(currentScore, 500, 5000)){
					target.put("[500,5000]", target.get("[500,5000]")+1);
				}
				if(isInIntervall(currentScore, 5000, 20000)){
					target.put("[5000,20000]", target.get("[5000,20000]")+1);
				}
				if(currentScore >= 20000){
					target.put(">20000", target.get(">20000")+1);
				}
			// if decoy hit
			}else{
				if (currentScore < 50){
					decoy.put("<50", decoy.get("<50")+1);
				}
				if(isInIntervall(currentScore, 50, 500)){
					decoy.put("[50,500]", decoy.get("[50,500]")+1);
				}
				if(isInIntervall(currentScore, 500, 5000)){
					decoy.put("[500,5000]", decoy.get("[500,5000]")+1);
				}
				if(isInIntervall(currentScore, 5000, 20000)){
					decoy.put("[5000,20000]", decoy.get("[5000,20000]")+1);
				}
				if(currentScore >= 20000){
					decoy.put(">20000", decoy.get(">20000")+1);
				}
			}
		}
	}
	// some peptides lengths are not represented by any peptide in the DB. 
	// In order to get a proper histogram, the values for these lengths are set to 0
	
	maxValue = Math.max(Collections.max(target.values()), Collections.max(target.values()));
		
	jsonString += "{"+
		    "fields: ['category', 'target', 'decoy', 'ratio'],"+
			"data: [";
	for (String i : keyOrder)
	{
		if(target.get(i)+decoy.get(i) > 0)
			ratio = decoy.get(i) / (double)(target.get(i) + decoy.get(i));
		else
			ratio = 0;
		jsonString += "{category:'"+i+"', target:'"+target.get(i)+"', decoy:'"+decoy.get(i)+"', ratio:'"+ratio+"'},";
	}
	jsonString=jsonString.substring(0, jsonString.length()-1);
	jsonString += "]}";
	
	info.put("data",jsonString);
	info.put("maxYaxis", String.valueOf(maxValue));
	return info;
}
%>
<%
// TODO get a parameter to know which type of peptide to get the distribution from: SequenceSearch, Peptidome etc.
// The data is stored in a node of type "Charts". It will have as attributes key the name of the chart 
// and as value the data to use to draw it. keys will be for example :"Peptidome_peptideLength", "SequenceSearch_peptideLength"...

String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();

// QUERY : start n=node(1) match n-[:Result]->t-[:Listed]->p where p.type="Peptide" return p.Sequence

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//String cypherQuery = "start n=node(" + request.getAttribute("id") + ") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";

//String cypherQuery = "start n=node(" + nodeID + ") match n-[:" + relationType + "]->p where has(p.Sequence) return p.Sequence";

// String cypherQueryPeptidome ="start n=node("+nodeID+") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";

//String cypherQueryPeptideIdentification ="start n=node("+nodeID+") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide Identification\" return p.Sequence";

String cypherQuery ="start n=node("+nodeID+") match n-->p where has(p.Sequence) return p.Sequence";
String nodeType = NodeHelper.getType(graphDb.getNodeById(Integer.valueOf(nodeID)));
String chartName=nodeType.replaceAll(" ", "")+"_peptideLength";
try{
	Transaction tx = graphDb.beginTx();
	// get the relashionship to the node storing information about charts. In theory there should only be one node concerned.
	// in theory only one node.
	
	// if the relationship doesn't existe yet, create it
	//if(!graphDb.getNodeById(Integer.valueOf(nodeID)).hasRelationship(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING))
	{		
		HashMap<String,String> nodeInfo = getBindingScoreDistribution(graphDb, Long.valueOf(request.getParameter("id")));
		Node charts = graphDb.createNode();
		charts.setProperty("type", "Charts");
		charts.setProperty("AxeY", "Number of Peptides");
		charts.setProperty("Name", "Binding Score [" + nodeType + "]");
		charts.setProperty("data", nodeInfo.get("data"));
		charts.setProperty("maxYaxis", nodeInfo.get("maxYaxis"));
		charts.setProperty("xfield", "'category'");
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