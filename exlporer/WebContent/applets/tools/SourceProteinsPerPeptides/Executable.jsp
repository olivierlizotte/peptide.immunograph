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

HashMap<String,String> getSourceProteinsDistribution(EmbeddedGraphDatabase graphDb, long nodeID){
	HashMap<String,String> info = new HashMap<String,String>(); 
	int maxValue = 0;
	double ratio;
	String jsonString = "";
	Node currentNode = graphDb.getNodeById(nodeID);
	Map<Integer,Integer> target = new HashMap<Integer,Integer>();
	Map<Integer,Integer> decoy = new HashMap<Integer,Integer>();
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	for (Relationship rel : allRels){
		Node otherNode = rel.getOtherNode(currentNode);
		if (NodeHelper.getType(otherNode).equals("Peptide")){
			int numberOfAssociatedProteins = 0;
			// GET PROTEIN SEQUENCES ASSOCIATED TO PEPTIDE SEQUENCES
 			Node peptideSequence = otherNode.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING).getEndNode();
 			for (Relationship protSeq : peptideSequence.getRelationships()){
 				System.out.println(NodeHelper.getType(protSeq.getOtherNode(peptideSequence)));
 				if (NodeHelper.getType(protSeq.getOtherNode(peptideSequence)).equals("Protein Sequence")){
 					numberOfAssociatedProteins+=1;
 				}
 			}
 			if(numberOfAssociatedProteins == 0)
 				numberOfAssociatedProteins = numberOfAssociatedProteins;
/*
			// GET PROTEINS ASSOCIATED TO PEPTIDES
			for(Relationship prot : otherNode.getRelationships(DynamicRelationshipType.withName("Associated"), Direction.INCOMING)){
				numberOfAssociatedProteins+=1;
			}//*/
			// if target hit
			if(otherNode.getProperty("Decoy").toString().equals("False")){
				if (target.containsKey(numberOfAssociatedProteins)){
					target.put(numberOfAssociatedProteins, target.get(numberOfAssociatedProteins) + 1);
				}else{
					target.put(numberOfAssociatedProteins, 1);
				}
			// if decoy hit
			}else{
				if (decoy.containsKey(numberOfAssociatedProteins)){
					decoy.put(numberOfAssociatedProteins, decoy.get(numberOfAssociatedProteins) + 1);
				}else{
					decoy.put(numberOfAssociatedProteins, 1);
				}
			}
		}
	}
	// some peptides lengths are not represented by any peptide in the DB. 
	// In order to get a proper histogram, the values for these lengths are set to 0
	for(int i=0; i<= Math.max(Collections.max(target.keySet()), Collections.max(decoy.keySet())) ; i+=1 ){
		if (!target.containsKey(i))
			target.put(i,0);
		if (!decoy.containsKey(i))
			decoy.put(i,0);
	}
	maxValue = Collections.max(target.values()) + Collections.max(decoy.values());
	for (int i : target.keySet()){
		System.out.println(i+"->"+target.get(i)+":"+decoy.get(i));
	}
	
	jsonString += "{"+
		    "fields: ['size', 'target', 'decoy', 'ratio'],"+
			"data: [";
		for (int i : target.keySet())
		{
			if(target.get(i) + decoy.get(i) > 0)
				ratio = decoy.get(i) / (double)(target.get(i)+decoy.get(i));
			else
				ratio = 0;
			jsonString += "{size:'"+i+"', target:'"+target.get(i)+"', decoy:'"+decoy.get(i)+"', ratio:'"+ratio+"'},";
		}
		jsonString=jsonString.substring(0, jsonString.length()-1);
		jsonString += "]}";
	
	info.put("data",jsonString);
	info.put("maxYaxis", String.valueOf(maxValue));
	System.out.println(info.get("data"));
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
		HashMap<String,String> nodeInfo = getSourceProteinsDistribution(graphDb, Long.valueOf(request.getParameter("id")));
		Node charts = graphDb.createNode();
		charts.setProperty("type", "Charts");
		charts.setProperty("AxeY", "Number of Peptides");
		charts.setProperty("Name", "Source proteins per peptides distribution[" + nodeType + "]");
		charts.setProperty("data", nodeInfo.get("data"));
		charts.setProperty("maxYaxis", nodeInfo.get("maxYaxis"));
		charts.setProperty("xfield", "'size'");
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