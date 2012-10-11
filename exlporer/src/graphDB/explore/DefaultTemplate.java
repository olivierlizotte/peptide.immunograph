package graphDB.explore;

import graphDB.explore.tools.AlphanumComparator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
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
	
	
	//public static String GraphDBString = "/home/antoine/neo4j/data/graph.db";
	//public static String GraphDBString = "C:\\_IRIC\\Neo4J\\data\\graph6.db";
	//public static String GraphDBString = "C:\\_IRIC\\DATA\\M&R\\graphProject981.db";
	
	public static String GraphDBString = "/apps/Neo4J/neo4j-community-1.8.M03/data/graph3.db";
	
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
				"Peptidome_peptideLength".equals(theAttributeName)||
				"data".equals(theAttributeName)||
				"xfield".equals(theAttributeName)||
				"yfield".equals(theAttributeName)||
				"maxYaxis".equals(theAttributeName)||
				"queries".equals(theAttributeName))
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
		//if("Tool_output".equals(theRelationName) //|| "Comment".equals(theRelationName)				
			//|| theRelationName == "Hash"
		//		)
		//	return false;
		return true;
	}

	/** This function returns an ordered list of String based on a given key set
	 * @param keySet the key set of a hashmap, used to create the ordered attribute list
	 * @return the list of attributes, ordered
	 */
	public static List<String> sortAttributes(Set<String> keySet)
	{
		final AlphanumComparator alNum = new AlphanumComparator();
		List<String> results = new ArrayList<String>();
		results.addAll(keySet);
		Collections.sort(results, 
        		new Comparator<String>()
                {
                    public int compare( String n1, String n2 )
                    {
                    	return alNum.compare((String)n1, (String)n2);
                    }
                } );//*/
		return results;
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
							  "applets/tools/PvalDistribution",
							  "applets/tools/SequenceRedundancy",
							  "applets/tools/HlaAlleleDistribution",
							  "applets/tools/SourceProteinsPerPeptides"};
			return testE;
		}
		if("ExpertMode_output".equals(type))
		{
			String[] testE = {"applets/tools/PeptideLength", 
							  "applets/tools/DecoyAnalysis", 
							  "applets/tools/BindingScoreDistribution",
							  "applets/tools/MascotScoreDistribution",
							  "applets/tools/IntensityDistribution",
							  "applets/tools/PvalDistribution",
							  "applets/tools/SequenceRedundancy", 
							  "applets/tools/HlaAlleleDistribution"};
			return testE;
		}
		if("EasyQuery_output".equals(type))
		{
			String[] testE = {"applets/tools/PeptideLength", 
							  "applets/tools/DecoyAnalysis", 
							  "applets/tools/BindingScoreDistribution",
							  "applets/tools/MascotScoreDistribution",
							  "applets/tools/IntensityDistribution",
							  "applets/tools/PvalDistribution",
							  "applets/tools/SequenceRedundancy",
							  "applets/tools/HlaAlleleDistribution"};
			return testE;
		}
		if("Sequence Search".equals(type))
		{
			String[] testE = {"applets/tools/PeptideLength",
					  		  "applets/tools/MascotScoreDistribution"};
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
		List<String> tools = new ArrayList<String>();
		if("Peptidome".equals(type))
		{
			tools.add("applets/tools/SequenceAnalysis");
			tools.add("applets/tools/EasyQuery");
		}
		if("Sequence Search".equals(type))
		{
			tools.add("applets/tools/SequenceAnalysis");
			tools.add("applets/tools/EasyQuery");
			tools.add("applets/tools/CsvExport");
		}
		if("Temporary Node".equals(type))
		{
			tools.add("applets/tools/DeleteNode");
		}
		
		if("EasyQuery_output".equals(type))
		{
			tools.add("applets/tools/SavePipeLine");
			tools.add("applets/tools/EasyQuery");
		}
		if("ExpertMode_output".equals(type))
		{
			tools.add("applets/tools/SavePipeLine");
			tools.add("applets/tools/EasyQuery");
		}
		if("Pipeline".equals(type))
		{
			
		}
		tools.add("applets/tools/DeleteNode");
		return tools.toArray(new String[tools.size()]);
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
	
	/** Calculate number of elements for a grouping node such as 
	 * peptides for peptidome, proteins for proteome etc. 
	 */
	public static int numberOfElements(EmbeddedGraphDatabase graphDb, Node groupingNode, String nodeTypeToCount){
		int nb=0;
		for (Relationship rel : groupingNode.getRelationships(Direction.OUTGOING)){
			if (nodeTypeToCount.equals(NodeHelper.getType(rel.getEndNode()))){
				nb+=1;
			}
		}
		return nb;
	}
	
	/** Calculate FPR for a grouping node such as Peptidome, proteome. 
	 * The nodes OUTGING must have decoy properties. 
	 */
	public static double calculateFPR(EmbeddedGraphDatabase graphDb, Node groupingNode){
		Node tmpNode;
		double total = 0;
		double decoyHits = 0;
		boolean hasDecoy=false;
		for (Relationship rel : groupingNode.getRelationships(Direction.OUTGOING)){
			tmpNode = rel.getEndNode();
			total+=1;
			if (tmpNode.hasProperty("Decoy")){
				hasDecoy=true;
				total += 1;
				if ("True".equals(tmpNode.getProperty("Decoy")))
					decoyHits += 1;
			}
		}
		if (hasDecoy){
			groupingNode.setProperty("FPR (decoy hits/ total)", Double.valueOf(decoyHits/total));
			groupingNode.setProperty("Total hits", total);
		}
		return total;
	}
	
	
	/** Add basic information to the database just after creating it: 
	 *  - Flase positive rate to Peptidome, Sequence Search and Quantification
	 *  - Number of nodes for each node grouped to many other.
	 *  - General Experiment's information: number of peptides, proteins etc.
	 */
	public static void addBasicInformation(EmbeddedGraphDatabase graphDb, Long experimentNodeId){
		Node experimentNode = graphDb.getNodeById(experimentNodeId);
		Node tmpNode;
		double total;
		
		for (Relationship rel : experimentNode.getRelationships(Direction.OUTGOING)){
			tmpNode = rel.getEndNode();
			if ("Peptidome".equals(NodeHelper.getType(tmpNode))){
				total = calculateFPR(graphDb, tmpNode);
				//if (!experimentNode.hasProperty("number of peptides")){
					experimentNode.setProperty("number of peptides", total);
				//}
			}
			if ("Sequence Search".equals(NodeHelper.getType(tmpNode))){
				total = calculateFPR(graphDb, tmpNode);
				//if (!experimentNode.hasProperty("number of peptide identifications")){
					experimentNode.setProperty("number of peptide identifications", total);
				//}
			}
			if ("Quantification".equals(NodeHelper.getType(tmpNode))){
				total = calculateFPR(graphDb, tmpNode);
				//if (!experimentNode.hasProperty("number of clusters")){
					experimentNode.setProperty("number of clusters", total);
				//}
			}
		}
	}
}
