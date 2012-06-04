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
void registerShutdownHook( final GraphDatabaseService graphDb )
{
    // Registers a shutdown hook for the Neo4j instance so that it
    // shuts down nicely when the VM exits (even if you "Ctrl-C" the
    // running example before it's completed)
    Runtime.getRuntime().addShutdownHook( new Thread()
    {
        @Override
        public void run()
		{
            graphDb.shutdown();
		}
	} );
}
%>
<%
String nodeID = request.getParameter("id").toString();
String relationType = request.getParameter("rel").toString();

// QUERY : start n=node(1) match n-[:Result]->t-[:Listed]->p where p.type="Peptide" return p.Sequence

EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );

//String cypherQuery = "start n=node(" + request.getAttribute("id") + ") match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";

//good?:  String cypherQuery = "start n=node(" + nodeID + ") match n-[:" + relationType + "]->p where has(p.Sequence) return p.Sequence";
String cypherQuery ="start n=node(1) match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";

// Map containing information about the peptides lengths. 
// To each size corresponds the number of peptides in this category
Map<Integer,Integer> lengths = new HashMap<Integer,Integer>();
try
{	
	ExecutionEngine engine = new ExecutionEngine( graphDb );
	// VERY IMPORTANT : use the org.neo4j.cypher.javacompat.* and not the org.neo4j.cypher.*
	// otherwise can't iterate over the ExecutionResult
	ExecutionResult result = engine.execute( cypherQuery );
	
	int currentLength=0;
	for ( Map<String, Object> row : result )
	{
	    for ( Entry<String, Object> column : row.entrySet() )
	    {
	        // get the length of the peptide
	    	currentLength = column.getValue().toString().trim().length();
	        
	        // if the key is already in the map, increment the number
	        if(lengths.containsKey(currentLength))
	        	lengths.put(currentLength, lengths.get(currentLength) + 1);
	        else  	// a peptide of the current length has not been found yet
		    	lengths.put(currentLength,1);	        
	    }
	}
	
	// some peptides lengths are not represented by any peptide in the DB. 
	// In order to get a proper histogram, the values for these lengths are set to 0
	for(int i=0; i<Collections.max(lengths.keySet()) ; i+=1 )
		if (!lengths.containsKey(i))
			lengths.put(i,0);	
	
	
	// now use out.print method to transmit the result
	// 1,2,3,4,5,6,7,8,9,10 <- sizes
	// 0,0,2,2,2,2,3,4,2,1  <- number of nodes with this value
	
	//First line (sequence length header)
	String sizes = "";
	for (int length : lengths.keySet())
		sizes += length + ",";
	sizes = sizes.substring(0, sizes.length()-1);
	
	//Number of sequence per length
	String numberOfSeq = "";
	for (int nb : lengths.values())
		numberOfSeq += nb + ",";
	numberOfSeq = numberOfSeq.substring(0, numberOfSeq.length() - 1);
	
	
	
	
	
	System.out.println(sizes);
	System.out.println();
	System.out.println(numberOfSeq);
	out.println(sizes);
	out.println();
	out.println(numberOfSeq);
}
catch(Exception e)
{
	e.printStackTrace();
}
finally
{
	graphDb.shutdown();
}
%>