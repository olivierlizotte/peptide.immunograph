package graphDB.explore;
import java.io.IOException;
import java.util.*;
import java.util.regex.Pattern;

import javax.servlet.jsp.JspWriter;

import org.neo4j.graphdb.*;
import org.neo4j.kernel.EmbeddedGraphDatabase;

public class DefaultNode {

	HashMap<String, String> theProperties = new HashMap<String,String>();
	Iterable<Relationship> theRelationshipsIn;
	Iterable<Relationship> theRelationshipsOut;
	
	HashMap<RelationshipType, String> inRelationsMap;
	HashMap<RelationshipType, String> outRelationsMap;
	
	HashMap<String, HashMap<String, String>> listOfAttributesOUT;
	HashMap<String, HashMap<String, String>> listOfAttributesIN;
	Node theNode;
	
	private static Pattern doublePattern = Pattern.compile("-?\\d+(\\.\\d*)?");
	private static int numberOfDigits = 3;
	
	public static boolean isNumber(String string) {
	    return doublePattern.matcher(string).matches();
	}
	
	public static String doubleFormat(String s){
		String[] tmp=s.split("\\.");
		if (tmp.length > 1 && tmp[1].length() > numberOfDigits){
			return tmp[0]+"."+tmp[1].substring(0, numberOfDigits);
		}else{
			return s;
		}
	}
	
	/**
	 * @param nodeID
	 * @param graphDb
	 */
	public DefaultNode(String nodeID, EmbeddedGraphDatabase graphDb)
	{
		theNode = graphDb.getNodeById(Long.valueOf(nodeID));
	}
	
	public void Initialize()
	{
		// GETTING THE PROPERTIES
		for (String p : theNode.getPropertyKeys()){
			String value = "";
			String s = theNode.getProperty(p).toString();
			//converting to 3 digits number
			if(isNumber(s)){
				value = doubleFormat(s);
			}else{
				value = s;
			}
			theProperties.put(p.toString(), value);
		}
		
		// CREATING INCOMING RELATION MAP
		inRelationsMap = computeRelationMaps(theNode.getRelationships(Direction.INCOMING), theNode);

		// CREATING OUTGOING RELATION MAP
		outRelationsMap = computeRelationMaps(theNode.getRelationships(Direction.OUTGOING), theNode);
		
		//CREATE LISTS OF ATTRIBUTES
		listOfAttributesOUT = computeListOfAttributes(outRelationsMap, Direction.OUTGOING, theNode);
		listOfAttributesIN = computeListOfAttributes(inRelationsMap, Direction.INCOMING, theNode);		
	}

	public String getCommentsVariable(String varName)
	{
		return "var " + varName + " = " + getComments(theNode) + ";\n";
	}	
	
	public static String getComments(Node theNode)
	{
		String output = "";
		//output += "{'comment':\"<a href='test.html'>test</a> comment\"},";
		//output += "{'comment':\"<a href='test.html'>test</a> new comment\"}";
		
	    for(Relationship relation : theNode.getRelationships(Direction.OUTGOING, DynamicRelationshipType.withName("Comment")))
		{
			Node userNode = relation.getOtherNode(theNode);
			if(userNode.hasProperty("NickName") && relation.hasProperty("Text"))
			{
				String user = userNode.getProperty("NickName").toString();			
				String text = relation.getProperty("Text").toString().replaceAll("\\r","<br/>");
				text = text.replaceAll("\\n","<br/>");
				text = text.replaceAll("\\\"", "&#34;");
				text = text.replaceAll("\\\\", "&#92;");
				
				output += ",{'comment':\"<a href='index.jsp?id=" + userNode.getId() + "'>" + user + "</a> " + text + "\"}";
			}
		}//*/
		//output += "{'comment' : {xtype : 'textareafield', grow : true, name : 'message', fieldLabel : 'Message', anchor : '100%' }},";
		//output += "{'comment':\"<textarea id='idAddCommentText' rows='2' placeholder='Add comment...' style='resize: none; width:100%; white-space:pre;' onkeypress='AddComment(this,event);'></textarea>\"}";//Add comment routine
		//output += "{'comment':\"<input type='text' name='addCommentInput' />\"}";//Add comment routine
		if(output.isEmpty())
			return "[]";
		else
			return "[" + output.substring(1) + "]";
	}
	
	private static HashMap<RelationshipType, String> computeRelationMaps(Iterable<Relationship> theRelationships, Node theNode)
	{
		HashMap<RelationshipType, String> output = new HashMap<RelationshipType, String>();
		for (Relationship rel : theRelationships)
		{
			if(DefaultTemplate.keepRelation(rel.getType().name()))
			{
				// 	if the relationship type is not yet in the HashMap, create a new entry
//				if (!output.containsKey(rel.getType()))
					output.put(rel.getType(), rel.getType().name());
			
			//	output.get(rel.getType()).add(rel.getOtherNode(theNode));
			}
		}
		return output;
	}
	
	public String getAttributeJSON(String varName)
	{
		// EDITING THE STRING
		String output = "var " + varName + " = {";

		String AttributeObjectString = "";
		for(String key : theProperties.keySet()){
			if(DefaultTemplate.keepAttribute(key))
				AttributeObjectString += ",\""+ key +"\":\""+theProperties.get(key)+"\"";
		}
		if(AttributeObjectString.isEmpty())
			output += "};\n";
		else
			output += AttributeObjectString.substring(1) + "};\n";
		return output;
	}

	private static HashMap<String, HashMap<String, String>> computeListOfAttributes(HashMap<RelationshipType, String> relationsMap, Direction dir, Node theNode )
	{
		HashMap<String, HashMap<String, String>> listOfAttributes = new HashMap<String, HashMap<String,String>>();		
		for(RelationshipType relationType : relationsMap.keySet())
		{	
			HashMap<String, String> attributes = new HashMap<String, String>();		

			for (Relationship rel : theNode.getRelationships(dir, relationType))
			{
				//	writing the relation properties
				for(String k: rel.getPropertyKeys())
					if(DefaultTemplate.keepAttribute(k))
						attributes.put(k, k);								
				
				Node n = rel.getOtherNode(theNode);
				
				//	writing the node properties
				for(String k: n.getPropertyKeys())
					if(DefaultTemplate.keepAttribute(k))
						attributes.put(k, k);
			}
			listOfAttributes.put(relationType.name(), attributes);
		}
		return listOfAttributes;
	}
	
	public void printGridDataJSON(JspWriter out, String key)
	{
		try 
		{
			String output = "var gridData = new Object();\n";
			output += "var gridColumns = new Object();\n";
			output += "var gridFields = new Object();\n";
			output += "var gridSorters = new Object();\n";
			output += "var gridName = new Object();\n";
			output += "var csvData = new Object();\n";
			out.print(output);
			computeGridDirection(outRelationsMap, listOfAttributesOUT, Direction.OUTGOING, theNode, out, key);
			computeGridDirection(inRelationsMap, listOfAttributesIN, Direction.INCOMING, theNode, out, key);
		} catch (IOException e) 
		{
			e.printStackTrace();
		}
	}
	
	public String getFirstRelationPlusDir()
	{
		if(outRelationsMap.size() > 0)
			return outRelationsMap.entrySet().iterator().next().getKey().name();

		if(inRelationsMap.size() > 0)
			return inRelationsMap.entrySet().iterator().next().getKey().name();
		
		return "";
	}
	
	private void computeGridDirection(HashMap<RelationshipType, String> relationsMap, 
										HashMap<String, HashMap<String, String>> listOfAttributes,
										Direction dir, Node theNode,
										JspWriter out, String key)
	{
		try 
		{
		//String output = "";
		for(RelationshipType relationType : relationsMap.keySet())
		{				
			if(key == null || key == relationType.name())
			{
				out.println("gridData['"+relationType.name()+dir+"'] = [");
				
				boolean isFirstRel = true;
									
				for (Relationship rel : theNode.getRelationships(dir, relationType))
				{
					Node n = rel.getOtherNode(theNode);
					
					//Create link to node
					if(isFirstRel)
						isFirstRel = false;
					else
						out.print(",");
					
					out.print("{'Link':'<a href=\"index.jsp?id=" + n.getId() + "&rel=" + relationType.name() + "&dir=" + dir + "\">" + n.getProperty("type") + "</a>'");
	
					//	writing the relation properties
					for(String k: rel.getPropertyKeys())
					{
						if(DefaultTemplate.keepAttribute(k))
						{
							// converting to 3 digits number
							String s = rel.getProperty(k).toString();
							if(isNumber(s))
								s = doubleFormat(s);
							
							out.print(",'"+k+"':'"+s+"'");
						}
					}
	
					//writing the node properties
					for(String k: n.getPropertyKeys())
					{
						if(DefaultTemplate.keepAttribute(k))
						{
							// converting to 3 digits number
							String s = n.getProperty(k).toString();
							if(isNumber(s))
								s = doubleFormat(s);
	
							out.print(",'"+k+"':'"+s+"'");
						}
					}
					out.println("}");
				}
				
				// remove the last comma
				out.print("];\n");
	
				out.print("gridColumns['"+relationType+dir+"'] = [");
				out.print("{text:'Link', flex:1, dataIndex:'Link'}");
				for(String attribute : listOfAttributes.get(relationType.name()).keySet())
					out.print(",{text:'"+attribute+"', flex:1, dataIndex:'"+attribute+"'}");
				out.print("];\n");
				
				out.print("gridFields['"+relationType+dir+"'] = [");
				out.print("'Link'");
				for(String attribute : listOfAttributes.get(relationType.name()).keySet())
					out.print(",'" + attribute+"'");			
				out.print("];\n");
				
				out.print("gridSorters['"+relationType+dir+"'] = [");
				out.print("'Link'");
				for(String attribute : listOfAttributes.get(relationType.name()).keySet())
					out.print(",'" + attribute+"'");			
				out.print("];\n");				
				
				out.print("gridName['"+relationType+dir+"'] = '" + relationType.name() + "';\n");
				//write csv data
				//out.print("csvData['"+relationType+dir+"'] = '" + getCSV(relationType, dir).trim() + "';\n");
			}
		}		
		} catch (IOException e)
		{		
			e.printStackTrace();
		}			
	}
	
	public String getType(){
		return this.theNode.getProperty("type").toString();
	}
	/*
	public String getCSV(String relationType, String dir)
	{
		if(dir == "IN" || dir == "TO")
		{
			for(RelationshipType rel : inRelationsMap.keySet())
				if(rel.name() == relationType)
					return getCSV(rel, Direction.INCOMING);
		}
		if(dir == "OUT" || dir == "FROM")
		{
			for(RelationshipType rel : outRelationsMap.keySet())
				if(rel.name() == relationType)
					return getCSV(rel, Direction.OUTGOING);
		}
		return "";
	}//*/
	
	public String getCSV(RelationshipType relationType, Direction dir)
	{
		if(dir == Direction.INCOMING)
			return getGridContent(relationType, dir, theNode, listOfAttributesIN.get(relationType));
		else if(dir == Direction.OUTGOING)
			return getGridContent(relationType, dir, theNode, listOfAttributesOUT.get(relationType));
		else
			return "";
	}
	
	private static String getGridContent(RelationshipType relationType, 
										 //List<Node> nodes, 
										 Direction dir, 
										 Node theNode,
										 HashMap<String, String> listOfAttributes)
	{
		String output = "";
		
		if (listOfAttributes != null){
			for(String attributeKey : listOfAttributes.keySet())
				output += attributeKey + ",";
			output += "\\n";
		}
		
		for (Relationship rel : theNode.getRelationships(dir, relationType))
		{
			for(String k: rel.getPropertyKeys())
				if(DefaultTemplate.keepAttribute(k))
					output += rel.getProperty(k) + ",";

			Node n = rel.getOtherNode(theNode);

			//writing the node properties
			for(String k: n.getPropertyKeys())
				if(DefaultTemplate.keepAttribute(k))
					output += n.getProperty(k) + ",";
			
			output += "\\n";				
		}
	
		return output;
	}
	
	public long getId()
	{
		return theNode.getId();
	}	
}
