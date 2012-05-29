package graphDB.explore;

import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.kernel.EmbeddedGraphDatabase;

abstract public class DefaultTemplate {

	//public static String GraphDB = "/home/antoine/neo4j/data/graph.db";
	public static String GraphDB = "C:\\_IRIC\\Neo4J\\data\\graph.db";
	
	public static Boolean keepAttribute( String theAttributeName )
	{
		switch(theAttributeName)
		{
			case "type":		return false; 
			case "StringID":	return false;
			case "passwd":		return false;
		}
		return true;
	}

	public static Boolean keepRelation( String theRelationName )
	{
		switch(theRelationName)
		{
			case "Comment":		return false;
			case "Hash":		return false;
		}
		return true;
	}

	public static void registerShutdownHook( final GraphDatabaseService graphDb )
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
	
	public static String[] getTools( String nodeID )
	{
		EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
		try
		{	
			registerShutdownHook( graphDb );				
			
			DefaultNode theNode = new DefaultNode(nodeID, graphDb );
			switch(theNode.getType())
			{
				case "Experiment":		String[] testE = {"applets/tools/PeptideLength"};
				return testE;
				case "User":			String[] testU = {"applets/tools/AddUser"};
				return testU;
			}	
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			graphDb.shutdown();
		}
		return new String[0];
	} 
}
