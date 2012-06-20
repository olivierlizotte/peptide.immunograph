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
						+ theProperties.get(key) + "\"";
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

	private static String ComputeChildrenInfo(Node theNode,
			RelationshipType relationType, Direction dir, int index) {
		int i = 0;
		for (@SuppressWarnings("unused")
		Relationship rel : theNode.getRelationships(dir, relationType))
			i++;

		return "{index:'" + index + "',name:'" + relationType.name()
				+ "',size:" + i + ",url:'index.jsp?id=" + theNode.getId()
				+ "&rel=" + relationType.name() + "&dir=" + dir + "'" + "},";
	}

	public String getChildren() {
		String result = "";

		int cpt = 0;
		for (RelationshipType relationType : outRelationsMap.keySet()) {
			result += ComputeChildrenInfo(theNode, relationType,
					Direction.OUTGOING, cpt);
			cpt++;
		}
		for (RelationshipType relationType : inRelationsMap.keySet()) {
			result += ComputeChildrenInfo(theNode, relationType,
					Direction.INCOMING, cpt);
			cpt++;
		}
		if (result.length() > 0)// Remove last comma
			result = result.substring(0, result.length() - 1);

		return "{index:'-1',name: '" + getType() + "', size: " + cpt
				+ ", children: [" + result + "]};";
	}

	private static String ComputeNavigationInfo(Node theNode,
			RelationshipType relationType, Direction dir, int index) {
		String result = "";
		HashMap<String, Long> nodeTypes = NodeHelper.computeNodeTypes(relationType, dir,
				theNode);
		for (String key : nodeTypes.keySet())
			result += "{relationIndex:" + index + ",relation:'"
					+ relationType.name() + "',name:'" + key + "',size:"
					+ nodeTypes.get(key) + ",info:'Node type: <b>" + key
					+ "</b><br><hr>Relation type: " + relationType.name()
					+ "<br>Size of list: " + nodeTypes.get(key)
					+ "',url:'index.jsp?id=" + theNode.getId() + "&rel="
					+ relationType.name() + "&dir=" + dir + "'},";
		return result;
	}

	public String getNavigationChart() {
		String result = "{nodes:";
		try {
			int index = 0;
			for (RelationshipType relationType : outRelationsMap.keySet()) {
				result += ComputeNavigationInfo(theNode, relationType,
						Direction.OUTGOING, index);
				index++;
			}
			for (RelationshipType relationType : inRelationsMap.keySet()) {
				result += ComputeNavigationInfo(theNode, relationType,
						Direction.INCOMING, index);
				index++;
			}
			if (result.length() > 0)
				result = result.substring(0, result.length() - 1);

			return "{relationIndex:-1,relation:'',name: '" + getType()
					+ "', size: 1, children: [" + result + "]};";

		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	private static String getNodeInfo(Node theNode, int size, String toAdd) {
		String result = "{";

		if (theNode.hasProperty("name"))
			result += "name:'" + theNode.getProperty("name") + "'";
		else if (theNode.hasProperty("Name"))
			result += "name:'" + theNode.getProperty("Name") + "'";
		else
			result += "name:'" + theNode.getProperty("type") + "'";
		if (toAdd != null && !toAdd.isEmpty())
			result += "," + toAdd;
		return result + ",size:" + size + ",info:'Node type: <b>"
				+ theNode.getProperty("type") + "</b><br><hr>'"
				+ ",url:'index.jsp?id=" + theNode.getId() + "'}";
	}

	// TODO : fix issue for 1000+ nodes by grouping nodes when more than 3
	// similar nodes are linked with the same relation
	public static void getNavigationInfo(JspWriter out, Node theNode,
			String nomVar) {
		try {
			out.println("var " + nomVar + " = {nodes:["
					+ getNodeInfo(theNode, 1, "IsRoot:'true'"));
			String relations = "links:[";

			int cpt = 1;
			for (Relationship relation : theNode.getRelationships())// (Direction.OUTGOING))
			{
				if (DefaultTemplate.keepRelation(relation.getType().name())) 
				{
					out.println(","
							+ getNodeInfo(relation.getOtherNode(theNode), 1,
									"relation:'" + relation.getType().name()
											+ "'"));
					if (relation.getEndNode().getId() == theNode.getId())
						relations += "{source:" + cpt + ",target:0,name:'"
								+ relation.getType().name() + "'},";
					else
						relations += "{source:0,target:" + cpt + ",name:'"
								+ relation.getType().name() + "'},";					
					cpt++;
//Hide this to get only one depth
					/*
					int newCpt = cpt - 1;
					for (Relationship relation2 : relation.getOtherNode(theNode).getRelationships())// (Direction.OUTGOING))
					{
						if (DefaultTemplate.keepRelation(relation2.getType().name())) 
						{
							out.println(","
									+ getNodeInfo(relation2.getOtherNode(relation.getOtherNode(theNode)), 1,
											"relation:'" + relation2.getType().name()
													+ "'"));
							if (relation2.getEndNode().getId() == relation.getOtherNode(theNode).getId())
								relations += "{source:" + cpt + ",target:" + newCpt + ",name:'"
										+ relation2.getType().name() + "'},";
							else
								relations += "{source:" + newCpt + ",target:" + cpt + ",name:'"
										+ relation2.getType().name() + "'},";
							
							cpt++;
						}
					}//*/
				}
			}
			if (relations.length() > 0)
				relations = relations.substring(0, relations.length() - 1);
			out.println("]," + relations + "]};");
		} catch (IOException e) {
			e.printStackTrace();
		}
	} // */
}
