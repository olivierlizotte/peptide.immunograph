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
<%
try{


EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

	Node[] peptideSequences = PeptideSequence.GetAllPeptides();
	int peptidomeID = 394015;
	String protDb = "M";
	ArrayList<Integer> protSizes = new ArrayList<Integer>();
	Node peptidome = graphDb.getNodeById(peptidomeID);
	for (Relationship pep : peptidome.getRelationships()){
		if (NodeHelper.getType(pep.getOtherNode(peptidome)).equals("Peptide")){
			
			Node peptide =  pep.getOtherNode(peptidome);
			
			// get peptide sequence node
			Node pepSeq = peptide.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING).getEndNode();
			System.out.println(pepSeq.getProperty("Sequence").toString());
			for (Relationship seqRel : pepSeq.getRelationships(Direction.OUTGOING, DynamicRelationshipType.withName("Found In"))){
				String id = seqRel.getEndNode().getProperty("Unique ID").toString();
				int protSize = seqRel.getEndNode().getProperty("Sequence").toString().length();
				if (id.startsWith(protDb) || id.startsWith("REVERSE_"+protDb)){
					protSizes.add(protSize);
				}
			}
		}
	}
	BufferedWriter dataFile = new BufferedWriter(new FileWriter("/home/antoine/protSizes.txt"));
	for (Integer l : protSizes){
		dataFile.write(l.toString()+"\n");
	}
	dataFile.close();
}
catch(Exception e)
{
	e.printStackTrace();
}
%>