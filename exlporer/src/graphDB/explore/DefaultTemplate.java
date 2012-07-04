package graphDB.explore;

import java.util.regex.Matcher;
import java.util.regex.Pattern;



import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.graphdb.ReturnableEvaluator;
import org.neo4j.graphdb.StopEvaluator;
import org.neo4j.graphdb.Transaction;
import org.neo4j.graphdb.TraversalPosition;
import org.neo4j.graphdb.Traverser;
import org.neo4j.graphdb.Traverser.Order;
import org.neo4j.graphdb.index.Index;
import org.neo4j.graphdb.index.IndexHits;
import org.neo4j.kernel.EmbeddedGraphDatabase;

/** This class determines the default behavior of the explorer
 *
 */
abstract public class DefaultTemplate 
{
	/** Registers a shutdown hook for the Neo4j instance so that it
	    shuts down nicely when the VM exits (even if you "Ctrl-C" the
	    running example before it's completed)
	 * @param graphDb
	 */
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
	        	removeAllTempElements(graphDb);
	        	if(theGraph != null)
	        		graphDb.shutdown();
			}
		} );
	}	
	
	public static void removeAllTempElements(GraphDatabaseService graphDb )
	{
		if(theGraph != null)
		{
			Transaction tx = graphDb.beginTx();
			Index<Node> index = theGraph.index().forNodes("tempNodes");
			IndexHits<Node> tempNodes = index.get("type", "tempNode");
			while (tempNodes.hasNext())
			{
				Node tempNode = tempNodes.next();
				Iterable<Relationship> tempRels = tempNode.getRelationships();
				for (Relationship rel : tempRels)
					rel.delete();
				tempNode.delete();
			}
			tx.success();
			tx.finish();
		}
	}
	
	
	public static String GraphDBString = "/home/antoine/neo4j/data/graph.db";
	
	//public static String GraphDBString = "C:\\_IRIC\\Neo4J\\data\\graph3.db";
	
	//public static String GraphDBString = "/apps/Neo4J/neo4j-community-1.8.M03/data/graph2.db";
	
	//Singleton pattern to force every user into a single database connexion object
	private static EmbeddedGraphDatabase theGraph = null;
	public static EmbeddedGraphDatabase graphDb()
	{
		if(theGraph == null)
		{
			try
			{
				theGraph = new EmbeddedGraphDatabase( GraphDBString );
				registerShutdownHook(theGraph);
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}			
		}
		return theGraph;
	}
	
		
	/** This function determines whether an attribute should be displayed or not in the explorer
	 * @param theAttributeName attribute to test
	 * @return true if the attribute should be kept, false otherwise
	 */
	public static Boolean keepAttribute( String theAttributeName )
	{
		if("type".equals(theAttributeName) ||
				"StringID".equals(theAttributeName) ||
				"passwd".equals(theAttributeName) ||
				"created from id".equals(theAttributeName) ||
				"Peptidome_peptideLength".equals(theAttributeName))
			return false;
		return true;
	}
	
	/** This function determines whether an attribute is a Name attribute
	 * @param theAttributeName attribute to test
	 * @return true if the attribute is a name
	 */
	public static Boolean isNameAttribute( String theAttributeName )
	{
		if("name".equals(theAttributeName) ||
		   "Name".equals(theAttributeName))
			return true;
		return false;
	}

	/** This function determines whether an attribute should be displayed or not in the explorer
	 * @param theRelationName the relation to test
	 * @return true if the relation should be kept, false otherwise
	 */
	public static Boolean keepRelation( String theRelationName )
	{
		if("Tool_output".equals(theRelationName) //|| "Comment".equals(theRelationName)				
			//|| theRelationName == "Hash"
				)
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
	
	
	/** Get the tools according to the type of node currently diplayed.
	 * @param nodeID
	 * @param graphDb
	 * @return
	 */
	public static String[] getChartsTools( String nodeID )
	{
		DefaultNode theNode = new DefaultNode(nodeID);
		String type = theNode.getType();
		if("Peptidome".equals(type))
		{
			String[] testE = {"applets/tools/PeptideLength", 
							  "applets/tools/DecoyAnalysis", 
							  "applets/tools/BindingScoreDistribution",
							  "applets/tools/MascotScoreDistribution",
							  "applets/tools/IntensityDistribution",
							  "applets/tools/PvalDistribution"};
			return testE;
		}
		if("Sequence Search".equals(type))
		{
			String[] testE = {"applets/tools/PeptideLength"};
			return testE;
		}
		if("User".equals(type))
		{			
			String[] testU = {"applets/tools/AddUser"};
			return testU;
		}			
		return new String[0];
	}
	
	public static String[] getNodeSpecificTools( String nodeID )
	{
		DefaultNode theNode = new DefaultNode(nodeID);
		String type = theNode.getType();
		if("Peptidome".equals(type))
		{
			String[] testE = {"applets/tools/SequenceAnalysis"};
			return testE;
		}
		if("Sequence Search".equals(type))
		{
			String[] testE = {"applets/tools/SequenceAnalysis"};
			return testE;
		}
		if("Temporary Node".equals(type))
		{
			String[] testE = {"applets/tools/DeleteNode"};
			return testE;
		}
		return new String[0];
	}
	
	/** Transform a Text referring to another node into a link to this node
	 * @param text String
	 * @param theNode neo4j Node
	 * @param theUser neo4j Node
	 * @param graphDb EmbeddedGraphDatabase
	 * @return
	 */
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
	
	public static String Sanitize(String input)
	{
		String text = input.replaceAll("\\r","<br/>");
		text = text.replaceAll("\\n","<br/>");
		text = text.replaceAll("\\\"", "&#34;");
		text = text.replaceAll("\\\\", "&#92;");
		return text;
	}	
	
	public static void linkToExperimentNode(EmbeddedGraphDatabase graphDb, Node node, String RelationName){
		long startID = node.getId();
		ReturnableEvaluator returnExperimentNode;
		
		// custom ReturnableEvaluator(). Returns the node if it is an "Experiment" one.
		returnExperimentNode = new ReturnableEvaluator()
		{
		    public boolean isReturnableNode( TraversalPosition position )
		    {
		        // Return nodes that don't have any outgoing relationships,
		        // only incoming relationships, i.e. leaf nodes.
		        return (position.currentNode().getProperty("type").toString().trim().equals("Experiment"));
		    }
		};
		
		// custom stop evaluator. Stops the traversal if the node is an "Experiment" one.
		// to be sure to stop at first Experiment Node found
		StopEvaluator stopAtFirstEsperimentFound= new StopEvaluator()
		 {
		     // Block traversal if the node has a property with key 'key' and value
		     // 'someValue'
		     public boolean isStopNode( TraversalPosition position )
		     {
		         if ( position.isStartNode() )
		         {
		             return false;
		         }
		         Node currentNode = position.currentNode();
		         Object property = currentNode.getProperty( "type", null );
		         return property instanceof String &&
		             ((String) property).equals( "Experiment" );
		     }
		 };
		
		Traverser experimentNode = graphDb.getNodeById(startID).traverse(Order.BREADTH_FIRST, 
				stopAtFirstEsperimentFound, 
				returnExperimentNode,
				DynamicRelationshipType.withName("Result"), Direction.INCOMING, 
				DynamicRelationshipType.withName("Source"), Direction.INCOMING, 
				DynamicRelationshipType.withName("Listed"), Direction.INCOMING, 
				DynamicRelationshipType.withName("Associated"), Direction.INCOMING, 
				DynamicRelationshipType.withName("Sequence"), Direction.INCOMING,
				DynamicRelationshipType.withName("Tool_output"), Direction.INCOMING
				);
		// there should only be one node there
		for (Node n : experimentNode){
			//System.out.println(n.getProperty("type"));
			//System.out.println(n.getId());
			n.createRelationshipTo(node, DynamicRelationshipType.withName(RelationName));
		}
	}
}
