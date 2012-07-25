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
<%!

String getDecoyDistribution(EmbeddedGraphDatabase graphDb, String cypherQuery)
{
	ExecutionEngine engine = new ExecutionEngine( graphDb );
	// VERY IMPORTANT : use the org.neo4j.cypher.javacompat.* and not the org.neo4j.cypher.*
	// otherwise can't iterate over the ExecutionResult
	ExecutionResult result = engine.execute( cypherQuery );
	
	long decoy = 0;
	long nonDecoy = 0;
	for ( Map<String, Object> row : result )
	{
	    for ( Entry<String, Object> column : row.entrySet() )
	    {
	    	Object val = column.getValue();
	    	if("True".equals(val))
	    		decoy ++;
	    	else
	    		nonDecoy++;
	    }
	}
	
	//First line : the header
	String title = "Sequence, Decoy";
	
	//Number of sequence per length
	String values = nonDecoy + "," + decoy;
	
	return title + "|" + values;
}

%>
<%

String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();

// QUERY : start n=node(1) match n-[:Result]->t-[:Listed]->p where p.type="Peptide" return p.Sequence

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//String cypherQuery = "start n=node(" + request.getAttribute("id") + ") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";

//String cypherQuery = "start n=node(" + nodeID + ") match n-[:" + relationType + "]->p where has(p.Sequence) return p.Sequence";

// String cypherQueryPeptidome ="start n=node("+nodeID+") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";

//String cypherQueryPeptideIdentification ="start n=node("+nodeID+") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide Identification\" return p.Sequence";

String cypherQuery = "start n=node("+nodeID+") match n-->p where has(p.Decoy) return p.Decoy";
String nodeType = NodeHelper.getType(graphDb.getNodeById(Integer.valueOf(nodeID)));
String chartName=nodeType.replaceAll(" ", "")+"_decoyAnalysis";
try
{
	Transaction tx = graphDb.beginTx();
	// get the relashionship to the node storing information about charts. In theory there should only be one node concerned.
	// in theory only one node.
	
	// if the relationship doesn't existe yet, create it
	String dataOutput = getDecoyDistribution(graphDb, cypherQuery);
	//if(!graphDb.getNodeById(Integer.valueOf(nodeID)).hasRelationship(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING))
	{		
		Node charts = graphDb.createNode();
		charts.setProperty("type", "Charts");
		charts.setProperty("AxeY", "Number of Sequences");
		charts.setProperty("Name", "Decoy Analysis [" + nodeType + "]");
		charts.setProperty("data", dataOutput);
		graphDb.getNodeById(Integer.valueOf(nodeID)).
				createRelationshipTo(charts, DynamicRelationshipType.withName("Tool_output"));
		DefaultTemplate.linkToExperimentNode(graphDb, charts, "Tool_output");
		System.out.println("just created "+charts.getId());
	}

	tx.success();
	tx.finish();
	out.println(dataOutput);
}
catch(Exception e)
{
	e.printStackTrace();
}
%>