package graphDB.explore;

import java.io.IOException;
import java.util.*;
import java.util.regex.Pattern;

import javax.servlet.jsp.JspWriter;

import org.neo4j.cypher.javacompat.ExecutionEngine;
import org.neo4j.cypher.javacompat.ExecutionResult;
import org.neo4j.graphdb.*;


public class NodeHelper 
{

	private static Pattern doublePattern = Pattern.compile("-?\\d+(\\.\\d*)?");
	private static int numberOfDigits = 3;

	public static boolean isNumber(String string) {
		return doublePattern.matcher(string).matches();
	}

	public static String doubleFormat(String s) {
		String[] tmp = s.split("\\.");
		if (tmp.length > 1 && tmp[1].length() > numberOfDigits) {
			return tmp[0] + "." + tmp[1].substring(0, numberOfDigits);
		} else {
			return s;
		}
	}
	
	public static HashMap<String, String> getProperties(Node theNode)
	{
		HashMap<String, String> theProperties = new HashMap<String, String>();
		for (String p : theNode.getPropertyKeys()) {
			String value = "";
			String s = theNode.getProperty(p).toString();
			// converting to 3 digits number
			if (isNumber(s)) {
				value = doubleFormat(s);
			} else {
				value = s;
			}
			theProperties.put(p.toString(), value);
		}
		return theProperties;
	}

	public static HashMap<String, HashMap<String, String>> computeListOfAttributes(
			HashMap<RelationshipType, String> relationsMap, Direction dir,
			Node theNode) 
    {
		HashMap<String, HashMap<String, String>> listOfAttributes = new HashMap<String, HashMap<String, String>>();
		for (RelationshipType relationType : relationsMap.keySet()) {
			HashMap<String, String> attributes = new HashMap<String, String>();

			for (Relationship rel : theNode.getRelationships(dir, relationType)) {
				// writing the relation properties
				for (String k : rel.getPropertyKeys())
					if (DefaultTemplate.keepAttribute(k))
						attributes.put(k, k);

				Node n = rel.getOtherNode(theNode);

				// writing the node properties
				for (String k : n.getPropertyKeys())
					if (DefaultTemplate.keepAttribute(k))
						attributes.put(k, k);
			}
			listOfAttributes.put(relationType.name(), attributes);
		}
		return listOfAttributes;
	}

	/**
	 * Get the comment written by a user about the current Node. A comment is a
	 * relation of the graph with a "text property"
	 * 
	 * @param theNode
	 *            neo4j Node
	 * @return
	 */
	public static String getComments(Node theNode) {
		String output = "";
		// output += "{'comment':\"<a href='test.html'>test</a> comment\"},";
		// output += "{'comment':\"<a href='test.html'>test</a> new comment\"}";

		for (Relationship relation : theNode
				.getRelationships(Direction.OUTGOING,
						DynamicRelationshipType.withName("Comment"))) {
			Node userNode = relation.getOtherNode(theNode);
			if (userNode.hasProperty("NickName")
					&& relation.hasProperty("Text")) {
				String user = userNode.getProperty("NickName").toString();
				String text = relation.getProperty("Text").toString()
						.replaceAll("\\r", "<br/>");
				text = text.replaceAll("\\n", "<br/>");
				text = text.replaceAll("\\\"", "&#34;");
				text = text.replaceAll("\\\\", "&#92;");

				output += ",{'comment':\"<a href='index.jsp?id="
						+ userNode.getId() + "'>" + user + "</a> " + text
						+ "\"}";
			}
		}// */
			// output +=
			// "{'comment' : {xtype : 'textareafield', grow : true, name : 'message', fieldLabel : 'Message', anchor : '100%' }},";
			// output +=
			// "{'comment':\"<textarea id='idAddCommentText' rows='2' placeholder='Add comment...' style='resize: none; width:100%; white-space:pre;' onkeypress='AddComment(this,event);'></textarea>\"}";//Add
			// comment routine
			// output +=
			// "{'comment':\"<input type='text' name='addCommentInput' />\"}";//Add
			// comment routine
		if (output.isEmpty())
			return "[]";
		else
			return "[" + output.substring(1) + "]";
	}

	public static String getType(Node aNode) {
		try {
			return aNode.getProperty("type").toString();
		} catch (Exception e) {
			return "";
		}
	}
		
	public static HashMap<String, Long> computeNodeTypes(RelationshipType relationType, Direction dir, Node startNode) 
	{
		HashMap<String, Long> listOfNodeTypes = new HashMap<String, Long>();
		for (Relationship rel : startNode.getRelationships(dir, relationType)) {
			Node n = rel.getOtherNode(startNode);
			if (!listOfNodeTypes.containsKey(getType(n)))
				listOfNodeTypes.put(getType(n), 1l);
			else
				listOfNodeTypes.put(getType(n),
						listOfNodeTypes.get(getType(n)) + 1);
		}
		return listOfNodeTypes;
	}

	private static class NavNode
	{
		int   theNodeIndex;
		ArrayList<Integer> theRelationIndexes = new ArrayList<Integer>();
		String theNodeInfo;
		String theRelationInfo = "";
		public NavNode(int index, Node node)
		{
			theNodeIndex = index;
			theNodeInfo = getNodeInfo(node, "IsRoot:true", 1);			
		}
		public NavNode(int index, Node node, Relationship relation, int indexOther, int size)
		{			
			theNodeIndex = index;
			theNodeInfo = getNodeInfo(node, "relation:'" + relation.getType().name() + "'", size);
			if(relation.getEndNode().getId() == node.getId())
				AddRelation(relation, indexOther, index);
			else
				AddRelation(relation, index, indexOther);
		}
		
		public void AddRelation(Relationship relation, int source, int target)
		{
			if(!(theRelationIndexes.contains(source) || theRelationIndexes.contains(target)))
			{
				if(!theRelationInfo.isEmpty())
					theRelationInfo += "},{";
				theRelationInfo += "source:" + source + ",target:" + target + ",name:'" + relation.getType().name() + "'";
				if(source == theNodeIndex)
					theRelationIndexes.add(target);
				else
					theRelationIndexes.add(source);
			}
		}
	}
	
	public static void printNavigationNodes(JspWriter out, Node theNode, int depth, String varName)
	{
		try
		{
			HashMap<String, NavNode> result = new HashMap<String, NodeHelper.NavNode>();
			
			out.println("var " + varName + " = {nodes:[");
			NavNode root = new NavNode(0, theNode);
			out.println("{" + root.theNodeInfo + "}");
			
			result.put(getType(theNode), root);			
			getNavigationNodes(out, theNode, depth, result, 0);
	
			//for (NavNode nav : result.values())
			//	out.println("{" + nav.theNodeInfo + "},");
			out.print("],links:[");
			for (NavNode nav : result.values())
				if(!nav.theRelationInfo.isEmpty())
					out.println("{" + nav.theRelationInfo + "},");
			out.print("]};");		
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private static int CountNodes(Node root, RelationshipType relType)
	{
		String query = "START a=node(" + root.getId() + ") MATCH a-[:" + relType.name() + "]-b RETURN COUNT(*)";
		ExecutionEngine engine = new ExecutionEngine( DefaultTemplate.graphDb() );
		// VERY IMPORTANT : use the org.neo4j.cypher.javacompat.* and not the org.neo4j.cypher.*
		// otherwise can't iterate over the ExecutionResult
		ExecutionResult result = engine.execute( query );
		for ( Map<String, Object> row : result )
		{
		    for ( Object obj : row.values() )
		    {
		    	return Integer.parseInt(obj.toString());
		    }
			//return row..size();
		}
		return 2;
	}
	
	private static HashMap<String, NavNode> getNavigationNodes(JspWriter out, Node theNode, int depth, HashMap<String, NavNode> result, int index) throws IOException
	{	
		if(depth > 0)
		{	
			for (Relationship relation : theNode.getRelationships())
			{
				if (DefaultTemplate.keepRelation(relation.getType().name()))
				{
					NavNode nav = result.get(getType(relation.getOtherNode(theNode)));
					if(nav == null)
					{
						nav = new NavNode(result.size(), relation.getOtherNode(theNode), relation, index, CountNodes(theNode, relation.getType()));
						out.println(",{" + nav.theNodeInfo + "}");
						result.put(getType(relation.getOtherNode(theNode)), nav);
						getNavigationNodes(out, relation.getOtherNode(theNode), depth-1, result, nav.theNodeIndex);
					}
					else
						if(relation.getEndNode().getId() == theNode.getId())
							nav.AddRelation(relation, nav.theNodeIndex, index);
						else
							nav.AddRelation(relation, index, nav.theNodeIndex);					
				}
			}
		}
		return result;
	}
	
	
	private static String getNodeInfo(Node theNode, String toAdd, int size) {
		String result = "";

		if (theNode.hasProperty("name"))
			result += "name:'" + theNode.getProperty("name") + "'";
		else if (theNode.hasProperty("Name"))
			result += "name:'" + theNode.getProperty("Name") + "'";
		else
			result += "name:'" + theNode.getProperty("type") + "'";
		if (toAdd != null && !toAdd.isEmpty())
			result += "," + toAdd;
		return result 
				+ ",size:" + size
				+ ",info:'Node type: <b>"
				+ theNode.getProperty("type") + "</b><br><hr>'"
				+ ",url:'index.jsp?id=" + theNode.getId() + "'";
	}	
}
