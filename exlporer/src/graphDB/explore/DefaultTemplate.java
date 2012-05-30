package graphDB.explore;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.graphdb.index.Index;
import org.neo4j.kernel.EmbeddedGraphDatabase;

abstract public class DefaultTemplate {

	//public static String GraphDB = "/home/antoine/neo4j/data/graph.db";
	public static String GraphDB = "C:\\_IRIC\\Neo4J\\data\\graph.db";
	
	public static Boolean keepAttribute( String theAttributeName )
	{
		if(theAttributeName == "type" ||
				theAttributeName == "StringID" ||
				theAttributeName == "passwd")
			return false;
		return true;
	}

	public static Boolean keepRelation( String theRelationName )
	{
		if(theRelationName == "Comment")
			//|| theRelationName == "Hash")
			return false;
		return true;
	}
/*
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
	}//*/
	
	public static String[] getTools( String nodeID, EmbeddedGraphDatabase graphDb)
	{
		DefaultNode theNode = new DefaultNode(nodeID, graphDb );
		String type = theNode.getType();
		if(type == "Experiment")
		{
			String[] testE = {"applets/tools/PeptideLength"};
			return testE;
		}
		if(type == "User")
		{			
			String[] testU = {"applets/tools/AddUser"};
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
