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

	// set the http content type to "APPLICATION/OCTET-STREAM
	response.setContentType("APPLICATION/OCTET-STREAM");

	// initialize the http content-disposition header to
	// indicate a file attachment with the default filename
	String disHeader = "Attachment;	Filename=\"List.csv\"";
	response.setHeader("Content-Disposition", disHeader);

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

	Node nodeIds = graphDb.getNodeById(394015);
	HashMap<String, String> theSequences = new HashMap<String, String>();		
	
	out.println("Gene,Transcript,Chromosome,Protein,PyGeno,Pos Start,Pos End,Sequence,NodeID,HLA,HLAScore,Precursor Error,  ");
	for (Relationship idRel : nodeIds.getRelationships())
	{
		Node nodeId = idRel.getOtherNode(nodeIds);
		if (NodeHelper.getType(nodeId).equals("Peptide Identification"))
		{			
			String id       = nodeId.getProperty("ID").toString();
			String sequence = nodeId.getProperty("Sequence").toString();
			String decoy    = nodeId.getProperty("Decoy").toString();
			if(decoy.contains("False") && !theSequences.containsKey(sequence))
			{
				theSequences.put(sequence, sequence);
				for (Relationship pepSeqRel : nodeId.getRelationships())
				{
					Node nodeSeq = pepSeqRel.getOtherNode(nodeId);
					if (NodeHelper.getType(nodeSeq).equals("Peptide Sequence"))
					{
						for (Relationship protRel : nodeSeq.getRelationships())
						{
							Node nodeProt = protRel.getOtherNode(nodeSeq);
							if (NodeHelper.getType(nodeProt).equals("Protein Sequence"))
							{
								//Chromosome number: 11 | Gene symbol: MMP3; Gene id: ENSG00000149968 | Transcript id: ENST00000434103 | Protein id: ENSP00000398346; Protein x1: 0							
								String position    = protRel.getProperty("Position").toString();
								String a  	  	   = NodeHelper.decimalFormat(nodeProt.getProperty("Chromosome number").toString());
								String b  	 	   = nodeProt.getProperty("Gene symbol").toString();
								String c  	 	   = nodeProt.getProperty("Gene id").toString();
								String d  	 	   = nodeProt.getProperty("Transcript id").toString();
								String e    	   = nodeProt.getProperty("Protein id").toString();
								String f    	   = NodeHelper.decimalFormat(nodeProt.getProperty("Protein x1").toString());
								
								out.println(sequence + "," + id + "," + position + "," + 
			"Chromosome number: " + a + " | Gene symbol: " + b + "; Gene id: " + c + " | Transcript id: " + d + " | Protein id: " + e + "; Protein x1: " + f);
							}
						}						
					}
				}
			}
		}
	}
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
