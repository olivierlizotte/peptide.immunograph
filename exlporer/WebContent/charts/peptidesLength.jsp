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
<%

// QUERY : start n=node(1) match n-[:Result]->t-[:Listed]->p where p.type="Peptide" return p.Sequence

EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );

String cypherQuery = "start n=node(1) match n-[:Result]->t-[:Listed]->p where p.type=\"Peptide\" return p.Sequence";
// Map containing information about the peptides lengths. 
// To each size corresponds the number of peptides in this category
Map<Integer,Integer> lengths = new HashMap<Integer,Integer>();
try
{	
	ExecutionEngine engine = new ExecutionEngine( graphDb );
	// VERY IMPORTANT : use the org.neo4j.cypher.javacompat.* and not the org.neo4j.cypher.*
	// otherwise can't iterate over the ExecutionResult
	ExecutionResult result = engine.execute( cypherQuery );
	String rows="";
	int tmp=0;
	int currentLength=0;
	for ( Map<String, Object> row : result ){
	    for ( Entry<String, Object> column : row.entrySet() ){
	        // get the length of the peptide
	    	currentLength=column.getValue().toString().trim().length();
	        // if the key is already in the map, increment the number
	        if(lengths.containsKey(currentLength)){
	        	tmp=lengths.get(currentLength);
	        	lengths.put(currentLength, tmp+1);        	
	        }else{
	        	// a peptide of the current length has not been found yet
		    	lengths.put(currentLength,1);
	        }
	    }
	}
	
	// some peptides lengths are not represented by any peptide in the DB. 
	// In order to get a proper histogram, the values for these lengths are set to 0
	for(int i=0; i<Collections.max(lengths.keySet()) ; i+=1 ){
		if (!lengths.containsKey(i)){
			lengths.put(i,0);
		}
	}
	
	
	// now use out.print method to transmit the result to xmlhttprequest x,y,z|a,b,c
	// a,b,c are the lengths category, x,y,z the number of peptides in each one
	String s="";
	// first get the number of peptides in each category
	for (int numbers : lengths.values()){
		s+=numbers+",";
	}
	// remove the last comma
	s = s.substring(0, s.length()-1);
	s+="|";
	// get the categories
	for (int peptideLength : lengths.keySet()){
		s+=peptideLength+",";
	}
	// remove the last comma
	s = s.substring(0, s.length()-1);
	out.print(s);
}
catch(Exception e)
{
	e.printStackTrace();
}
finally
{
	graphDb.shutdown();
}
//out.print("1,4,6,9,15,7,4,4,0");
%>