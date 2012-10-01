package graphDB.explore;

import java.io.IOException;
import java.util.*;

import javax.servlet.jsp.JspWriter;

import org.neo4j.graphdb.*;

public class DefaultNode 
{
	private Node theNode;

	public Node NODE() {
		return theNode;
	}


	public DefaultNode(String nodeID) {
		theNode = DefaultTemplate.graphDb().getNodeById(Long.valueOf(nodeID));
	}

	public String getCommentsVariable(String varName) {
		return "var " + varName + " = " + NodeHelper.getComments(theNode) + ";\n";
	}

	public String getAttributeJSON(String varName) 
	{
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
	public void printGridDataJSON(JspWriter out) {
		try 
		{
			String output = "var gridColumns = new Object();\n";
			output += "var gridFields = new Object();\n";
			output += "var gridSorters = new Object();\n";
			output += "var gridName = new Object();\n";
			out.print(output);
			computeGrid(NodeHelper.computeListOfAttributes( theNode ), theNode, out);
		} catch (IOException e) {
			e.printStackTrace();
		}
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
	private static void computeGrid(HashMap<String, HashMap<String, String>> listOfAttributes, Node theNode, JspWriter out) 
	{
		try 
		{				
			for(String strType : DefaultTemplate.sortAttributes(listOfAttributes.keySet()))
			{
				HashMap<String, String> attribs = listOfAttributes.get(strType);
				List<String> sortedAttribs = DefaultTemplate.sortAttributes(attribs.keySet());
				
				out.print("gridColumns['" + strType + "'] = [");
				out.print("{text:'Link', flex:1, dataIndex:'Link'}");
				out.print(",{text:'Relation', flex:1, dataIndex:'Relation', hidden:true}");
				for (String attribute : sortedAttribs)
					out.print(",{text:'" + attribute
							+ "', flex:1, filtrable:true, filter:true, dataIndex:'" + attribute + "', editor: { allowBlank: true }}");
				out.print("];\n");

				out.print("gridFields['" + strType + "'] = [");
				out.print("'Link','Relation'");
				for (String attribute : sortedAttribs)
					out.print(",'" + attribute + "'");
				out.print("];\n");

				out.print("gridSorters['" + strType + "'] = [");
				out.print("'Link'");
				for (String attribute : sortedAttribs)
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

	public long getId() {
		return theNode.getId();
	}
}
