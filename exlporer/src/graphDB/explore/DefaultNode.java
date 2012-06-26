package graphDB.explore;

import java.io.IOException;
import java.util.*;

import javax.servlet.jsp.JspWriter;

import org.neo4j.graphdb.*;

public class DefaultNode {
	HashMap<String, String> theProperties;
	Iterable<Relationship> theRelationshipsIn;
	Iterable<Relationship> theRelationshipsOut;

	HashMap<RelationshipType, String> inRelationsMap;
	HashMap<RelationshipType, String> outRelationsMap;

	HashMap<String, HashMap<String, String>> listOfAttributesOUT;
	HashMap<String, HashMap<String, String>> listOfAttributesIN;

	private Node theNode;

	public Node NODE() {
		return theNode;
	}


	public DefaultNode(String nodeID) {
		theNode = DefaultTemplate.graphDb().getNodeById(Long.valueOf(nodeID));
	}

	public void Initialize() {
		// GETTING THE PROPERTIES
		theProperties = NodeHelper.getProperties(theNode);

		// CREATING INCOMING RELATION MAP
		inRelationsMap = computeRelationMaps(
				theNode.getRelationships(Direction.INCOMING), theNode);

		// CREATING OUTGOING RELATION MAP
		outRelationsMap = computeRelationMaps(
				theNode.getRelationships(Direction.OUTGOING), theNode);

		// CREATE LISTS OF ATTRIBUTES
		listOfAttributesOUT = NodeHelper.computeListOfAttributes(outRelationsMap,
				Direction.OUTGOING, theNode);
		listOfAttributesIN = NodeHelper.computeListOfAttributes(inRelationsMap,
				Direction.INCOMING, theNode);
	}

	public String getCommentsVariable(String varName) {
		return "var " + varName + " = " + NodeHelper.getComments(theNode) + ";\n";
	}

	/**
	 * Build a HashMap of relations. To each relationship type corresponds a
	 * list of nodes.
	 * 
	 * @param theRelationships
	 * @param theNode
	 * @return
	 */
	private static HashMap<RelationshipType, String> computeRelationMaps(
			Iterable<Relationship> theRelationships, Node theNode) {
		HashMap<RelationshipType, String> output = new HashMap<RelationshipType, String>();
		for (Relationship rel : theRelationships) {
			if (DefaultTemplate.keepRelation(rel.getType().name())) {
				// if the relationship type is not yet in the HashMap, create a
				// new entry
				// if (!output.containsKey(rel.getType()))
				output.put(rel.getType(), rel.getType().name());

				// output.get(rel.getType()).add(rel.getOtherNode(theNode));
			}
		}
		return output;
	}	

	public String getAttributeJSON(String varName) {
		// EDITING THE STRING
		String output = "var " + varName + " = {";

		String AttributeObjectString = "";
		for (String key : theNode.getPropertyKeys()) {
			if (DefaultTemplate.keepAttribute(key))
				AttributeObjectString += ",\"" + key + "\":\""
						+ DefaultTemplate.Sanitize(theNode.getProperty(key).toString()) + "\"";
		}
		if (AttributeObjectString.isEmpty())
			output += "};\n";
		else
			output += AttributeObjectString.substring(1) + "};\n";
		return output;
	}

	/**
	 * Dynamically write javascript code to declare variables to fill the ExtJS
	 * panels
	 * 
	 * @param out
	 * @param key
	 */
	public void printGridDataJSON(JspWriter out, String key) {
		try {
			String output = "var gridData = new Object();\n";
			output += "var gridColumns = new Object();\n";
			output += "var gridFields = new Object();\n";
			output += "var gridSorters = new Object();\n";
			output += "var gridName = new Object();\n";
			output += "var csvData = new Object();\n";
			out.print(output);
			computeGrid(theNode, out);
			//computeGridDirection(inRelationsMap, listOfAttributesIN,
				//	Direction.INCOMING, theNode, out, key);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Get a default relation to display in the grid
	 * 
	 * @return
	 */
	public String getFirstRelationPlusDir() {
		if (outRelationsMap.size() > 0)
			return outRelationsMap.entrySet().iterator().next().getKey().name();

		if (inRelationsMap.size() > 0)
			return inRelationsMap.entrySet().iterator().next().getKey().name();

		return "";
	}

	/**
	 * Dynamically write javascript code to set variables to fill in the grid
	 * 
	 * @param relationsMap
	 * @param listOfAttributes
	 * @param dir
	 * @param theNode
	 * @param out
	 * @param key
	 */
	private static void computeGrid(Node theNode, JspWriter out) 
	{
		try 
		{	
			HashMap<String, HashMap<String, String>> listOfAttributes = new HashMap<String, HashMap<String, String>>();
						
			//Create a list of all node types and attributes
			for(Relationship relation : theNode.getRelationships())
			{
				String strRelation = relation.getType().name();
				if(DefaultTemplate.keepRelation(strRelation))
				{
					Node theOtherNode = relation.getOtherNode(theNode);
					String theOtherType = NodeHelper.getType(theOtherNode);
					if(!listOfAttributes.containsKey(theOtherType))
					{
						out.println("gridData['" + theOtherType	+ "'] = new Array();");
						listOfAttributes.put(theOtherType, new HashMap<String, String>());
					}
	
					out.println("gridData['" + theOtherType	+ "'].push({" + 
							"'Link':'<a href=\"index.jsp?id="
							+ theOtherNode.getId() + "\">" + NodeHelper.getName(theOtherNode) + "</a>'");
	
					//Add the properties of the relation
					for(String key : relation.getPropertyKeys())
					{
						if(DefaultTemplate.keepAttribute(key))
						{
							out.print(",'" + key + "':'" + relation.getProperty(key) + "'");
							listOfAttributes.get(theOtherType).put(key, key);
						}
					}
					
					//Add the properties of the node
					for(String key : theOtherNode.getPropertyKeys())
					{
						if(DefaultTemplate.keepAttribute(key) && !DefaultTemplate.isNameAttribute(key))
						{
							out.print(",'" + key + "':'" + theOtherNode.getProperty(key) + "'");
							listOfAttributes.get(theOtherType).put(key, key);
						}
					}
					out.print(",Relation:'" + strRelation + "',Type:'" + theOtherType + "'});");
				}
			}
			
			for(String strType : listOfAttributes.keySet())
			{
				HashMap<String, String> attribs = listOfAttributes.get(strType);
				
				out.print("gridColumns['" + strType + "'] = [");
				out.print("{text:'Link', flex:1, dataIndex:'Link'}");
				out.print(",{text:'Relation', flex:1, dataIndex:'Relation', hidden:true}");
				for (String attribute : attribs.keySet())
					out.print(",{text:'" + attribute
							+ "', flex:1, dataIndex:'" + attribute + "'}");
				out.print("];\n");

				out.print("gridFields['" + strType + "'] = [");
				out.print("'Link','Relation'");
				for (String attribute : attribs.keySet())
					out.print(",'" + attribute + "'");
				out.print("];\n");

				out.print("gridSorters['" + strType + "'] = [");
				out.print("'Link'");
				for (String attribute : attribs.keySet())
					out.print(",'" + attribute + "'");
				out.print("];\n");

				out.print("gridName['" + strType + "'] = '" + strType + "';\n");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public String getType() {
		try {
			return theNode.getProperty("type").toString();
		} catch (Exception e) {
			return "";
		}
	}

	/*
	 * public String getCSV(String relationType, String dir) { if(dir == "IN" ||
	 * dir == "TO") { for(RelationshipType rel : inRelationsMap.keySet())
	 * if(rel.name() == relationType) return getCSV(rel, Direction.INCOMING); }
	 * if(dir == "OUT" || dir == "FROM") { for(RelationshipType rel :
	 * outRelationsMap.keySet()) if(rel.name() == relationType) return
	 * getCSV(rel, Direction.OUTGOING); } return ""; }//
	 */

	public String getCSV(RelationshipType relationType, Direction dir) {
		if (dir == Direction.INCOMING)
			return getGridContent(relationType, dir, theNode,
					listOfAttributesIN.get(relationType));
		else if (dir == Direction.OUTGOING)
			return getGridContent(relationType, dir, theNode,
					listOfAttributesOUT.get(relationType));
		else
			return "";
	}

	/**
	 * Get the grid content as a String, represents csv format
	 * 
	 * @param relationType
	 * @param dir
	 * @param theNode
	 * @param listOfAttributes
	 * @return
	 */
	private static String getGridContent(RelationshipType relationType,
			// List<Node> nodes,
			Direction dir, Node theNode,
			HashMap<String, String> listOfAttributes) {
		String output = "";

		if (listOfAttributes != null) {
			for (String attributeKey : listOfAttributes.keySet())
				output += attributeKey + ",";
			output += "\\n";
		}

		for (Relationship rel : theNode.getRelationships(dir, relationType)) {
			for (String k : rel.getPropertyKeys())
				if (DefaultTemplate.keepAttribute(k))
					output += rel.getProperty(k) + ",";

			Node n = rel.getOtherNode(theNode);

			// writing the node properties
			for (String k : n.getPropertyKeys())
				if (DefaultTemplate.keepAttribute(k))
					output += n.getProperty(k) + ",";

			output += "\\n";
		}

		return output;
	}

	public long getId() {
		return theNode.getId();
	}
}
