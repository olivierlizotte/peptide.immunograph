<%@page import="java.io.FileWriter"%>
<%@page import="java.io.BufferedWriter"%>
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

	Node nodeIds = graphDb.getNodeById(373291); 
	HashMap<String, String> theSequences = new HashMap<String, String>();		
	
	BufferedWriter writer = new BufferedWriter(new FileWriter("C:\\getPages.sh"));
	for (Relationship idRel : nodeIds.getRelationships())
	{
		Node nodeId = idRel.getOtherNode(nodeIds);
		if (NodeHelper.getType(nodeId).equals("Peptide Identification"))
		{			
			String sequence = nodeId.getProperty("Sequence").toString();
			String decoy    = nodeId.getProperty("Decoy").toString();
			String spectrum = nodeId.getProperty("Spectrum").toString();

			writer.write("wget -O folder/" + nodeId.getId() + "_" + sequence + ".html --cookies=on --load-cookies 'cookies.txt' --keep-session-cookies --referer='http://mascot.iric.ca/mascot/cgi/login.pl' '" + spectrum + "'");
		    writer.newLine();   //
		}
	}	

    writer.close();  // Close to unlock and flush to disk.
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
