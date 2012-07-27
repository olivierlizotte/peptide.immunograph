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
0-1-2-4-8-16-32-64-128-256-512-1024-2048-4096-8192-16384-32768-65536-131072
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
	Node currentNode = graphDb.getNodeById(nodeID);
	Map<Integer,Integer> target = new HashMap<Integer,Integer>();
	Map<Integer,Integer> decoy = new HashMap<Integer,Integer>();
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	
	for(int i = 1; i <= 131072; i *= 2)
	{
		target.put(i, 0);
		decoy.put(i, 0);
	}
	//Add extra zone to get everything
	target.put(Integer.MAX_VALUE, 0);
	decoy.put(Integer.MAX_VALUE, 0);
	
	String bestHLA;
	for (Relationship rel : allRels)
	{
		Node otherNode = rel.getOtherNode(currentNode);
		
		//if ((otherNode.hasProperty("Sequence")) && (otherNode.hasProperty("Binding Score"))) {
		if (("Peptide".equals(NodeHelper.getType(otherNode)))&&(otherNode.hasProperty("best HLA allele")))
		{
			bestHLA = otherNode.getProperty("best HLA allele").toString();
			double currentScore = NodeHelper.PropertyToDouble(otherNode.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING).getEndNode().getProperty(bestHLA));
			// if target hit
			boolean notFound = true;
			for(int i = 1; i <= 131072 && notFound; i *= 2)
				if(currentScore < i)
				{
					if("False".equals(otherNode.getProperty("Decoy").toString()))
						target.put(i, target.get(i) + 1);
					else
						decoy.put(i, decoy.get(i) + 1);
					notFound = false;
				}				
			if(notFound)
				if("False".equals(otherNode.getProperty("Decoy").toString()))
					target.put(Integer.MAX_VALUE, target.get(Integer.MAX_VALUE) + 1);
				else
					decoy.put(Integer.MAX_VALUE, decoy.get(Integer.MAX_VALUE) + 1);
		}
	}
	
	int maxValue = Math.max(Collections.max(target.values()), Collections.max(target.values()));
		
	jsonString += "{"+
		    "fields: ['category', 'target', 'decoy', 'ratio'],"+
			"data: [";
			
	double ratio;
	int pastI = 0;
	for(int i = 1; i <= 131072; i *= 2)
	{	
		if(target.get(i)+decoy.get(i) > 0)
			ratio = decoy.get(i) / (double)(target.get(i) + decoy.get(i));
		else
			ratio = 0;
		jsonString += "{category:'["+pastI + "," + i + "[', target:'"+target.get(i)+"', decoy:'"+decoy.get(i)+"', ratio:'"+ratio+"'},";
		pastI = i;
	}
	//Add last category
	if(target.get(Integer.MAX_VALUE) + decoy.get(Integer.MAX_VALUE) > 0)
		ratio = decoy.get(Integer.MAX_VALUE) / (double)(target.get(Integer.MAX_VALUE) + decoy.get(Integer.MAX_VALUE));
	else
		ratio = 0;
	jsonString += "{category:'>"+pastI + "', target:'"+target.get(Integer.MAX_VALUE)+"', decoy:'"+decoy.get(Integer.MAX_VALUE)+"', ratio:'"+ratio+"'},";
	
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