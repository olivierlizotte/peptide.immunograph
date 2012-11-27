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
	out.println("Adding protein count for each sequence :: <BR>");
	
	Node[] peptideSequences = PeptideSequence.GetAllPeptides();
	HashMap<Long, HashMap<Long, Double[]>> mapExpProt = new HashMap<Long, HashMap<Long, Double[]>>();	

	//Compute nb link with protein, per db, for each peptide sequence and place results in peptide nodes
	for (Node nodeSequence : peptideSequences)
	{		
		ArrayList<Long> listExp = new ArrayList<Long>();
		//Check experiment
 		for (Relationship pepSeqRel : nodeSequence.getRelationships())
 		{
 			Node nodePeptide = pepSeqRel.getOtherNode(nodeSequence);
 			
 			if (NodeHelper.getType(nodePeptide).equals("Peptide"))
 			{
 		 		for (Relationship relPeptidome : nodePeptide.getRelationships())
 		 		{
 		 			Node nodePeptidome = relPeptidome.getOtherNode(nodePeptide); 		 		
 		 			if (NodeHelper.getType(nodePeptidome).equals("Peptidome"))
 		 			{
 		 				if(!mapExpProt.containsKey(nodePeptidome.getId()))
 		 					mapExpProt.put(nodePeptidome.getId(), new HashMap<Long, Double[]>());
 		 				listExp.add(nodePeptidome.getId());
 		 			}
 		 		}
 			}
 		}
		
		for(long exp : listExp)
		{		
			HashMap<Long, Boolean> mapDone = new HashMap<Long, Boolean>();
		
 			for (Relationship relProtSeq : nodeSequence.getRelationships())
 			{
	 			Node nodeProteinSeq = relProtSeq.getOtherNode(nodeSequence);
 				if (NodeHelper.getType(nodeProteinSeq).equals("Protein Sequence"))
 				{
 					String uniqueId = nodeProteinSeq.getProperty("Unique ID").toString();
 					String proteinId = nodeProteinSeq.getProperty("Protein id").toString();
 					if(!uniqueId.startsWith("REVERSE"))
 					{
 					//!nodeProteinSeq.getProperty("Unique ID").toString().startsWith("REVERSE"))
 				
	 		 		for (Relationship relDB : nodeProteinSeq.getRelationships())
 		 			{
	 		 			Node nodeDB = relDB.getOtherNode(nodeProteinSeq);
 		 				if (NodeHelper.getType(nodeDB).equals("DataBase"))
 		 				{
	 		 				if(!mapExpProt.get(exp).containsKey(nodeDB.getId()))
	 		 				{
	 		 					mapExpProt.get(exp).put(nodeDB.getId(), new Double[2]);
	 		 					mapExpProt.get(exp).get(nodeDB.getId())[0] = 0.0;
	 		 					mapExpProt.get(exp).get(nodeDB.getId())[1] = 0.0;
	 		 				}
	 		 				mapExpProt.get(exp).get(nodeDB.getId())[0] += 1;
	 		 				out.println(exp + "," + nodeDB.getId() + "," + nodeSequence.getProperty("Sequence").toString() + "," + uniqueId + "," + proteinId + ",1<BR>");
	 		 				if(!mapDone.containsKey(nodeDB.getId()))
	 		 				{
	 		 					mapExpProt.get(exp).get(nodeDB.getId())[1] += 1;
	 		 					mapDone.put(nodeDB.getId(), true);
	 		 				}
 		 				}
 		 			}}
 				}
 			}
		}
	}
	
	for(long expKey : mapExpProt.keySet())
	{
		out.println("Peptidome " + expKey + "  ::: <BR>");
		for(long dbKey : mapExpProt.get(expKey).keySet())
		{
			out.println("Database " + dbKey + "  ::: <BR>");
			out.println("Average protein per peptide : " + mapExpProt.get(expKey).get(dbKey)[0] / mapExpProt.get(expKey).get(dbKey)[1] + "<BR>");
			out.println("Number of peptides : " + mapExpProt.get(expKey).get(dbKey)[1] + "<BR>");
		}
	}

	out.println("L'Affaire Est Ketchup!");//
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
