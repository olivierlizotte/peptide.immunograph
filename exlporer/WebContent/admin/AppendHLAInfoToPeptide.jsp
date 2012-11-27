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

<%
try{


EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

	ArrayList<Node> unmatched = new ArrayList<Node>();
	
	out.println("Unmatched sequences :: ");
	Node[] peptideSequences = PeptideSequence.GetAllPeptides();

	double bestHLAscore, tmpScore;
	String bestAllel;
	for (Node sequence : peptideSequences)
	{
		bestHLAscore = Double.MAX_VALUE;
		bestAllel="";
		for(String attr: sequence.getPropertyKeys())
		{
			if(attr.startsWith("HLA"))
			{
				tmpScore = Double.valueOf(sequence.getProperty(attr).toString());
				if (tmpScore < bestHLAscore)
				{
					bestHLAscore = tmpScore;
					bestAllel = attr;
				}
			}
		}
		if(!bestAllel.isEmpty())
		{
	 		for (Relationship protSeq : sequence.getRelationships())
	 		{
	 			Node otherNode = protSeq.getOtherNode(sequence);
	 			if(NodeHelper.getType(otherNode).equals("Peptide"))
	 			{
	 				Transaction tx = graphDb.beginTx(); 	
	 				  otherNode.setProperty("best HLA allele", bestAllel);
	 				  otherNode.setProperty("best HLA score", bestHLAscore);
	 				tx.success();
	 				tx.finish();
				}
			}
		}
	}
	out.println("L'Affaire Est Ketchup!");//
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
