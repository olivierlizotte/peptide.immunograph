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
	
	out.println("Adding fragment error info (in dalton) ");
	Node[] peptideSequences = PeptideSequence.GetAllPeptides();
	int nbPeptide = 0;
	//Start with all peptide sequence to get to Peptide nodes.
	//-Sequence->(Peptide)-Source->(Cluster)-Associated->(Peptide Identification)
	for (Node nodeSequence : peptideSequences)
	{
		String sequence = (String)nodeSequence.getProperty("Sequence");
		
 		for (Relationship pepSeqRel : nodeSequence.getRelationships())
 		{
 			Node nodePeptide = pepSeqRel.getOtherNode(nodeSequence);
 			
 			if (NodeHelper.getType(nodePeptide).equals("Peptide"))
 			{
 				double bestDelta = 200000000;
 			
 				//Found a peptide, need to go up to clusters
 				for (Relationship pepRel : nodePeptide.getRelationships())
 				{
 					Node nodeCluster = pepRel.getOtherNode(nodePeptide);
 					if (NodeHelper.getType(nodeCluster).equals("Cluster"))
 					{
 						//Found a Cluster, lets find some Peptide Identifications
 						for (Relationship clusterRel : nodeCluster.getRelationships())
 						{
 							Node nodeIdentification = clusterRel.getOtherNode(nodeCluster);
 							if (NodeHelper.getType(nodeIdentification).equals("Peptide Identification") &&
 								sequence.equals(nodeIdentification.getProperty("Sequence")))
 							{
 								if(nodeIdentification.hasProperty("Error on Fragments"))// && 
 									//NodeHelper.IsNumber(nodeIdentification.getProperty("Error on Fragments")))
 								{
 									double deltaFrag = Double.parseDouble(nodeIdentification.getProperty("Error on Fragments").toString());
 									if(deltaFrag < bestDelta)
 										bestDelta = deltaFrag;
 								}
 								else
 									bestDelta = bestDelta;
 							}
 						}
 					}
 				}
 				if(bestDelta < 200)
 				{
					Transaction tx = graphDb.beginTx();
					
					nodePeptide.setProperty("Fragment Error", bestDelta);

					nbPeptide++;
					
					tx.success();
					tx.finish();
 				}
 				else
 					bestDelta = bestDelta;
 			}
 		}
	}
 					 								
 		

//*/


	out.println("L'Affaire Est Ketchup! : " + nbPeptide);//
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
