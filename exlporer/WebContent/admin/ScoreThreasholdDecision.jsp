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
<%@ page import="java.io.*"%>


%>


<%

int nodeID=394015;
ArrayList<Node> peptidome811 = new ArrayList<Node>();
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
Node peptidomeNode = graphDb.getNodeById(nodeID);

Node tmpEndNode;
String tmpSequence;
for(Relationship rel : peptidomeNode.getRelationships(Direction.OUTGOING)){
	tmpEndNode = rel.getEndNode();
	if( NodeHelper.getType(tmpEndNode) == "Peptide"){
		tmpSequence = tmpEndNode.getProperty("Sequence").toString();
		if ((tmpSequence.length() >= 8 ) &&
			(tmpSequence.length() <= 11 )){
			
			peptidome811.add(rel.getEndNode());
		}
	}
}

System.out.println(peptidome811.size());

List<Integer> lBS = Arrays.asList(25,50,125,250,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000,3250,3500,3750,4000,4250,4500,4750,5000,100000);
List<Integer> lMS = Arrays.asList(15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50);
 

HashMap<List<Integer>, Integer> nb = new HashMap<List<Integer>, Integer>();
HashMap<List<Integer>, Double> fdr = new HashMap<List<Integer>, Double>();

Double fdrLimit = 0.05;

int nbTarget, nbDecoy;
//for each combination of Mascot and Binding scores
for (Integer bs : lBS){
	for (Integer ms : lMS){
		nbTarget =0;
		nbDecoy  =0;
		// check in all 8-11 peptides, which ones satisfy the condition
		for (Node p : peptidome811){
			if ((Integer.valueOf(p.getProperty("Highest Score").toString()) <= ms) &&
			(Integer.valueOf(p.getProperty("best HLA score").toString()) <= ms)){
				nbTarget = 0;
				nbDecoy = 0;
				if (p.getProperty("Decoy").toString() == "False"){
					nbTarget += 1;
				}else{
					nbDecoy += 1;
				}
			}
		}
		nb.put(Arrays.asList(bs, ms), (nbTarget+nbDecoy));
		fdr.put(Arrays.asList(bs, ms), Double.valueOf(nbDecoy/nbTarget));
	}
}


%>