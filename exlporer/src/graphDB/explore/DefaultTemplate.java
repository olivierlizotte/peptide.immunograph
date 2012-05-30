package graphDB.explore;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.graphdb.index.Index;
import org.neo4j.kernel.EmbeddedGraphDatabase;


/**
 * This class determines the default behavior of the database explorer
 *
 */
abstract public class DefaultTemplate {

	public static String GraphDB = "/home/antoine/neo4j/data/graph.db";
	//public static String GraphDB = "C:\\_IRIC\\Neo4J\\data\\graph.db";
	
	
	/**
	 * Decide which attributes of the node to display.
	 * @param theAttributeName
	 * @return true if the relation is to keep, false otherwise
	 */
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
	
	/**
	 * Decide which relations of the node to display.
	 * @param theRelationName
	 * @return true if the relation is to keep, false otherwise 
	 */
	public static Boolean keepRelation( String theRelationName )
	{
		switch(theRelationName)
		{
			case "Comment":		return false;
			//case "Hash":		return false;
		}
		return true;
	}
	/**
	 * Registers a shutdown hook for the Neo4j instance so that it
	 * shuts down nicely when the VM exits (even if you "Ctrl-C" the
	 * running example before it's completed).
	 * @param graphDb a neo4j graph database
	 */
/*
/*
	public static void registerShutdownHook( final GraphDatabaseService graphDb )
	{
	    Runtime.getRuntime().addShutdownHook( new Thread()
	    {
	        @Override
	        public void run()
			{
	            graphDb.shutdown();
			}
		} );
	}//*/
	
	public static String[] getTools( String nodeID, EmbeddedGraphDatabase graphDb)
	{
		DefaultNode theNode = new DefaultNode(nodeID, graphDb );
		switch(theNode.getType())
		{
			case "Experiment":		String[] testE = {"applets/tools/PeptideLength"};
			return testE;
			case "User":			String[] testU = {"applets/tools/AddUser"};
			return testU;
		}
		
		return new String[0];
	}
	
	public static String checkForHashTags(String text, Node theNode, Node theUser, EmbeddedGraphDatabase graphDb)
	{
	    StringBuffer sb = new StringBuffer(text.length());	
		
		Index<Node> index = graphDb.index().forNodes("hashtags");
		
		Pattern patt = Pattern.compile("(#[^<]*?) ");
		Matcher m = patt.matcher(text);
	    while (m.find()) 
	    {
	    	String tag = m.group(1);

			Node tagNode = index.get("name", tag).getSingle();
			if(tagNode == null)
			{
				tagNode = graphDb.createNode();
				tagNode.setProperty("name", tag);		
				tagNode.setProperty("type", "HashTag");
				index.add(tagNode, "name", tag);
			}
			RelationshipType relType = DynamicRelationshipType.withName( "Hash" );	
			theNode.createRelationshipTo(tagNode, relType).setProperty("User", theUser.getProperty("NickName"));				
			m.appendReplacement(sb, Matcher.quoteReplacement("<a href=index.jsp?id=" + tagNode.getId() + ">" + tag + "</a> "));
	    }
	    m.appendTail(sb);	
	
		return sb.toString();
	}
}
