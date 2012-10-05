<%@ page import="graphDB.explore.*"%>
<%@ page import="org.neo4j.graphdb.Transaction"%>

<%
try	{				
	Transaction tx = DefaultTemplate.graphDb().beginTx();			
	
	PeptideSequence.MatchAllSequences();
	
	tx.success();
	tx.finish();
}catch(Exception e){
	e.printStackTrace();
}
out.println("Done!");
%>