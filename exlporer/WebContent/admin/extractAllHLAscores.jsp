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
	
	BufferedWriter dataFile = new BufferedWriter(new FileWriter("/home/antoine/all_HLA_scores.csv"));
	for (Node nodeSequence : peptideSequences)
	{
		String sequence = nodeSequence.getProperty("Sequence").toString();
		int lengthSeq   = sequence.length();
		
		if((lengthSeq >= 8 && lengthSeq < 12) && (nodeSequence.hasProperty("HLA-A03:01")))
		{
			String a03 = nodeSequence.getProperty("HLA-A03:01").toString();
			String a29 = nodeSequence.getProperty("HLA-A29:02").toString();
			String b08 = nodeSequence.getProperty("HLA-B08:01").toString();
			String b44 = nodeSequence.getProperty("HLA-B44:03").toString();
			String c07 = nodeSequence.getProperty("HLA-C07:01").toString();
			String c16 = nodeSequence.getProperty("HLA-C16:01").toString();
			dataFile.write(sequence + "," + a03 + "," + a29 + "," + b08 + "," +b44 + "," + c07 + "," + c16 +"\n");
		}
	}
	
	dataFile.close();
	out.println("L'Affaire Est Ketchup!");//	
}
catch(Exception e)
{
	e.printStackTrace();
}
%>