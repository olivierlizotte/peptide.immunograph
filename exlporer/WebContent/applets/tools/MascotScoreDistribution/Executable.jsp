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

// This function puts a value in the right interval represented by keys in target or decoy hashmap
HashMap<String,Integer> putInApropriateKey(HashMap<String,Integer> targetOrDecoy, double value, int max){
	int start, end;
	HashMap<String,Integer> res = targetOrDecoy;
	for (String interval : res.keySet()){
		start=Integer.valueOf(interval.split(":")[0]);
		end=interval.split(":")[1].equals("+") ? Integer.MAX_VALUE : Integer.valueOf(interval.split(":")[1]);
		if ((value>=start)&&(value<end)){
			res.put(interval, res.get(interval)+1);
			return res;
		}
	}
	return res;
}

Map<String,String> getMascotScoreDistribution(EmbeddedGraphDatabase graphDb, 
													long nodeID,
													int intervalSize,
													int max){
	Map<String,String> info = new HashMap<String,String>();
	List<String> keyOrder = new ArrayList<String>();
	String jsonString = "";
	
	int maxValue = 0;
	HashMap<String,Integer> target = new HashMap<String,Integer>();
	HashMap<String,Integer> decoy = new HashMap<String,Integer>();
	int start, end;
	// initialize target and decoy hashmaps
	for (int i=0 ; i<max ; i+=intervalSize){
		start=i;
		end=i+intervalSize;
		target.put(start+":"+end, 0);
		decoy.put(start+":"+end, 0);
		keyOrder.add(start+":"+end);
	}
	target.put(max+":+",0);
	decoy.put(max+":+",0);
	keyOrder.add(max+":+");
	
	Node currentNode = graphDb.getNodeById(nodeID);
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	
	for (Relationship rel : allRels)
	{
		Node peptideIdentification = rel.getOtherNode(currentNode);
		double mascotScore = -1;
		if (peptideIdentification.hasProperty("Score")) 
			mascotScore = NodeHelper.PropertyToDouble(peptideIdentification.getProperty("Score"));
		else if(peptideIdentification.hasProperty("Highest Score"))
			mascotScore = NodeHelper.PropertyToDouble(peptideIdentification.getProperty("Highest Score"));
		if(mascotScore >= 0)
		{
			boolean isDecoy = false;
			if(peptideIdentification.hasProperty("Decoy"))
				isDecoy = "True".equals(peptideIdentification.getProperty("Decoy").toString()) ? true : false;
			
			if (isDecoy)
				decoy = putInApropriateKey(decoy, mascotScore, max);
			else
				target = putInApropriateKey(target, mascotScore, max);			
		}
		else
		{
			System.out.println("not if");
		}
	}
	// some peptides lengths are not represented by any peptide in the DB. 
	// In order to get a proper histogram, the values for these lengths are set to 0
	
	maxValue = Math.max(Collections.max(target.values()), Collections.max(target.values()));
		
	jsonString += "{"+
		    "fields: ['score', 'target', 'decoy', 'ratio'],"+
			"data: [";
	for (String i : keyOrder)
	{
		double ratio = 0;
		if(target.get(i)+decoy.get(i) > 0)
			ratio = decoy.get(i) / (double)(target.get(i) + decoy.get(i));
		jsonString += "{score:'"+i+"', target:'"+target.get(i)+"', decoy:'"+decoy.get(i)+"', ratio:'"+ratio+"'},";
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
// QUERY : start n=node(1) match n-[:Result]->t-[:Listed]->p where p.type="Peptide" return p.Sequence
//String cypherQuery = "start n=node(" + request.getAttribute("id") + ") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";
//String cypherQuery = "start n=node(" + nodeID + ") match n-[:" + relationType + "]->p where has(p.Sequence) return p.Sequence";
// String cypherQueryPeptidome ="start n=node("+nodeID+") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";
//String cypherQueryPeptideIdentification ="start n=node("+nodeID+") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide Identification\" return p.Sequence";

String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();
int intervalSize = Integer.valueOf(request.getParameter("intervalSize"));
int max = Integer.valueOf(request.getParameter("max"));



EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//String cypherQuery ="start n=node("+nodeID+") match n-->p where has(p.Sequence) return p.Sequence";
String nodeType = NodeHelper.getType(graphDb.getNodeById(Integer.valueOf(nodeID)));
String chartName=nodeType.replaceAll(" ", "")+"_peptideLength";
try{
	Transaction tx = graphDb.beginTx();
	// get the relashionship to the node storing information about charts. In theory there should only be one node concerned.
	// in theory only one node.
	
	// if the relationship doesn't existe yet, create it
	//if(!graphDb.getNodeById(Integer.valueOf(nodeID)).hasRelationship(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING))
	{		
		Map<String,String> nodeInfo = getMascotScoreDistribution(graphDb, Long.valueOf(request.getParameter("id")), intervalSize, max);
		System.out.print(nodeInfo.get("data"));
		Node charts = graphDb.createNode();
		charts.setProperty("type", "Charts");
		charts.setProperty("AxeY", "Number of Peptides");
		charts.setProperty("Name", "MASCOT score [" + nodeType + "]");
		charts.setProperty("data", nodeInfo.get("data"));
		charts.setProperty("maxYaxis", nodeInfo.get("maxYaxis"));
		charts.setProperty("xfield", "'score'");
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
