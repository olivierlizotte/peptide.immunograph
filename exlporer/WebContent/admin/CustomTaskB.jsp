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

	Node[] peptideSequences = PeptideSequence.GetAllPeptides();
	double[] nbForward = new double[4];
	double[] nbReverse = new double[4];
	double[] nbBoth = new double[4];
	double[] nbTotalPeptide = new double[4];
	
	for (Node nodeSequence : peptideSequences)
	{
		String sequence = nodeSequence.getProperty("Sequence").toString();
		int lengthSeq   = sequence.length() - 8;
		
		if(lengthSeq >= 0 && lengthSeq < 4)
		{
			boolean reverse = false;
			boolean forward = false;
			// GET PROTEIN SEQUENCES ASSOCIATED TO PEPTIDE SEQUENCES
	 		for (Relationship protSeq : nodeSequence.getRelationships())
	 		{
	 			if (NodeHelper.getType(protSeq.getOtherNode(nodeSequence)).equals("Protein Sequence"))
	 			{
	 				String id = protSeq.getOtherNode(nodeSequence).getProperty("Unique ID").toString();	 				
	 				if(id.startsWith("REVERSE_M"))
	 				{
	 					nbReverse[lengthSeq] += 1;
	 					reverse = true;
	 				}
	 				else
	 				{
	 					nbForward[lengthSeq] += 1;
	 					forward = true;
	 				}
	 			}	 				
	 		}
			if(forward && reverse)
				nbBoth[lengthSeq] += 1;
			nbTotalPeptide[lengthSeq] += 1;
		}
	}
	for(int i = 0; i < 4; i++)
	{
		out.println("Length " + (i + 8) + "<br/>");
		out.println("Nb Total Peptide = " + nbTotalPeptide[i] + "<br/>");
		out.println("Nb Forward       = " + nbForward[i] + "   [" + nbForward[i]/nbTotalPeptide[i] + "]" + "<br/>");
		out.println("Nb Reverse       = " + nbReverse[i] + "   [" + nbReverse[i]/nbTotalPeptide[i] + "]" + "<br/>");
		out.println("Nb Both          = " + nbBoth[i]    + "   [" + nbBoth[i]   /nbTotalPeptide[i] + "]" + "<br/>");
	}
	out.println("L'Affaire Est Ketchup!");//
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
