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
<%!

String getBindingScoreDistribution(EmbeddedGraphDatabase graphDb, long nodeID){
	String jsonString = "";
	Node currentNode = graphDb.getNodeById(nodeID);
	Map<String,Integer> target = new HashMap<String,Integer>();
	Map<String,Integer> decoy = new HashMap<String,Integer>();
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	target.put("<50", 0);
	target.put("[500,1000]", 0);
	target.put(">1000",	0);
	
	decoy.put("<50", 0);
	decoy.put("[500,1000]", 0);
	decoy.put(">1000",	0);
	for (Relationship rel : allRels){
		Node otherNode = rel.getOtherNode(currentNode);
		if ((otherNode.hasProperty("Sequence")) && (otherNode.hasProperty("Binding Score"))) {
			int currentScore = Integer.valueOf(otherNode.getProperty("Binding Score").toString().trim());
			// if target hit
			System.out.println(currentScore);
			if(otherNode.getProperty("Decoy").toString().equals("False")){
				if (currentScore <= 50){
					target.put("<50", target.get("<50")+1);
				}
				if((currentScore >= 50) &&(currentScore <=1000)){
					target.put("[500,1000]", target.get("[500,1000]")+1);
				}
				if(currentScore > 1000){
					target.put(">1000", target.get(">1000")+1);
				}
			// if decoy hit
			}else{
				if (currentScore <= 50){
					decoy.put("<50", decoy.get("<50")+1);
				}
				if((currentScore >= 50) &&(currentScore <=1000)){
					decoy.put("[500,1000]", decoy.get("[500,1000]")+1);
				}
				if(currentScore > 1000){
					decoy.put(">1000", decoy.get(">1000")+1);
				}
			}
		}
	}
	// some peptides lengths are not represented by any peptide in the DB. 
	// In order to get a proper histogram, the values for these lengths are set to 0
	
	
	
	
	jsonString += "{"+
		    "fields: ['size', 'target', 'decoy'],"+
			"data: [";
	for (String i : target.keySet()){
		jsonString += "{size:'"+i+"', target:'"+target.get(i)+"', decoy:'"+decoy.get(i)+"'},";
	}
	jsonString=jsonString.substring(0, jsonString.length()-1);
	jsonString += "]}";
	
	return jsonString;
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
		Node charts = graphDb.createNode();
		charts.setProperty("type", "Charts");
		charts.setProperty("AxeY", "Number of Peptides");
		charts.setProperty("Name", "Binding Score [" + nodeType + "]");
		charts.setProperty("data", getBindingScoreDistribution(graphDb, Long.valueOf(request.getParameter("id"))));
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