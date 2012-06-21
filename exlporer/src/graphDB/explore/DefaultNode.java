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
		for (String key : theProperties.keySet()) {
			if (DefaultTemplate.keepAttribute(key))
				AttributeObjectString += ",\"" + key + "\":\""
						+ DefaultTemplate.Sanitize(theProperties.get(key)) + "\"";
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
			computeGridDirection(outRelationsMap, listOfAttributesOUT,
					Direction.OUTGOING, theNode, out, key);
			computeGridDirection(inRelationsMap, listOfAttributesIN,
					Direction.INCOMING, theNode, out, key);
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
	private void computeGridDirection(
			HashMap<RelationshipType, String> relationsMap,
			HashMap<String, HashMap<String, String>> listOfAttributes,
			Direction dir, Node theNode, JspWriter out, String key) {
		try {
			// String output = "";
			for (RelationshipType relationType : relationsMap.keySet()) {
				if (key == null || key == relationType.name()) {
					out.println("gridData['" + relationType.name() + dir
							+ "'] = [");

					boolean isFirstRel = true;

					for (Relationship rel : theNode.getRelationships(dir,
							relationType)) {
						Node n = rel.getOtherNode(theNode);

						// Create link to node
						if (isFirstRel)
							isFirstRel = false;
						else
							out.print(",");

						out.print("{'Link':'<a href=\"index.jsp?id="
								+ n.getId() + "&rel=" + relationType.name()
								+ "&dir=" + dir + "\">" + NodeHelper.getType(n) + "</a>'");

						// writing the relation properties
						for (String k : rel.getPropertyKeys()) {
							if (DefaultTemplate.keepAttribute(k)) {
								// converting to 3 digits number
								String s = rel.getProperty(k).toString();
								if (NodeHelper.isNumber(s))
									s = NodeHelper.doubleFormat(s);

								out.print(",'" + k + "':'" + s + "'");
							}
						}

						// writing the node properties
						for (String k : n.getPropertyKeys()) {
							if (DefaultTemplate.keepAttribute(k)) {
								// converting to 3 digits number
								String s = n.getProperty(k).toString();
								if (NodeHelper.isNumber(s))
									s = NodeHelper.doubleFormat(s);

								out.print(",'" + k + "':'" + s + "'");
							}
						}
						out.println("}");
					}

					// remove the last comma
					out.print("];\n");

					out.print("gridColumns['" + relationType + dir + "'] = [");
					out.print("{text:'Link', flex:1, dataIndex:'Link'}");
					for (String attribute : listOfAttributes.get(
							relationType.name()).keySet())
						out.print(",{text:'" + attribute
								+ "', flex:1, dataIndex:'" + attribute + "'}");
					out.print("];\n");

					out.print("gridFields['" + relationType + dir + "'] = [");
					out.print("'Link'");
					for (String attribute : listOfAttributes.get(
							relationType.name()).keySet())
						out.print(",'" + attribute + "'");
					out.print("];\n");

					out.print("gridSorters['" + relationType + dir + "'] = [");
					out.print("'Link'");
					for (String attribute : listOfAttributes.get(
							relationType.name()).keySet())
						out.print(",'" + attribute + "'");
					out.print("];\n");

					out.print("gridName['" + relationType + dir + "'] = '"
							+ relationType.name() + "';\n");
					// write csv data
					// out.print("csvData['"+relationType+dir+"'] = '" +
					// getCSV(relationType, dir).trim() + "';\n");
				}
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
