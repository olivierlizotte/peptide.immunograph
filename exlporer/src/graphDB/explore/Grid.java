package graphDB.explore;

import graphDB.explore.tools.AlphanumComparator;

import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.jsp.JspWriter;

import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.helpers.Pair;
import org.neo4j.shell.util.json.*;


public class Grid {

	public static boolean GetList(JspWriter out, int start, int limit, String sort, String nodeID, String nodeType)
	{		
		try 
		{
			JSONArray array = new JSONArray(sort);
			JSONObject obj  = array.getJSONObject(0);
			final String property	= obj.getString("property");
			
			String direction= obj.getString("direction");
			final boolean dir = ("ASC".equals(direction) ? true : false);
					
			Node head = DefaultTemplate.graphDb().getNodeById(Long.parseLong(nodeID)); 

			List<Pair<Node, Relationship>> nodes = new LinkedList<Pair<Node, Relationship>>();
			
			//Cycle through the list of relations to find the 
			for(Relationship relation : head.getRelationships())
			{
				String strRelation = relation.getType().name();
				if(DefaultTemplate.keepRelation(strRelation))
				{
					Node theOtherNode = relation.getOtherNode(head);
					if(nodeType.equals(NodeHelper.getType(theOtherNode)))
					{
						nodes.add(Pair.of(theOtherNode, relation));
					}
				}
			}
			
			final AlphanumComparator alNum = new AlphanumComparator();
	        Collections.sort( nodes, 
	        		new Comparator<Pair<Node, Relationship>>()
	                {
	                    public int compare( Pair<Node, Relationship> n1, Pair<Node, Relationship> n2 )
	                    {
	                    	
	                    	Node a = n1.first();
	                    	Node b = n2.first();
	                    	if(!a.hasProperty(property) || !b.hasProperty(property))
	                    		return 0;
	                    	else
	                    	{	
	                    		Object r1 = n1.first().getProperty(property);
	                    		Object r2 = n2.first().getProperty(property);
	                    		if(r1 instanceof Number && r2 instanceof Number)
		                    		if(dir)
		                    			return alNum.compare((Number)n1.first().getProperty(property), (Number)n2.first().getProperty(property));
		                    		else
		                    			return -alNum.compare((Number)n1.first().getProperty(property), (Number)n2.first().getProperty(property));
	                    		else
	                    			if(dir)
		                    			return alNum.compare((String)n1.first().getProperty(property), (String)n2.first().getProperty(property));
		                    		else
		                    			return -alNum.compare((String)n1.first().getProperty(property), (String)n2.first().getProperty(property));
	                    	}
	                    }
	                } );//*/

	        out.println("{root:[");
			long nbElem = 0;
			long nbPrinted = 0;
			for(Pair<Node, Relationship> aPair : nodes)
			{
				nbElem++;
				if(nbElem >= start)
				{
					Node aNode = aPair.first();
					Relationship relation = aPair.other();
					
					nbPrinted++;
					if(nbPrinted <= limit)
					{
						if(nbPrinted > 1)
							out.print(",");
					
						out.println("{" + 
								"'Link':'<a href=\"index.jsp?id="
								+ aNode.getId() + "\">" + NodeHelper.getName(aNode) + "</a>'");
		
						//Add the properties of the relation
						for(String key : relation.getPropertyKeys())
							if(DefaultTemplate.keepAttribute(key))
								out.print(",'" + key + "':'" + relation.getProperty(key) + "'");
						
						//Add the properties of the node
						for(String key : aNode.getPropertyKeys())
							if(DefaultTemplate.keepAttribute(key) && !DefaultTemplate.isNameAttribute(key))
								out.print(",'" + key + "':'" + aNode.getProperty(key) + "'");
						
						out.print(",Relation:'" + relation.getType().name() + "',Type:'" + NodeHelper.getType(aNode) + "'}");
					}
				}
			}
			
			out.println("],total:" + nbElem + "}");
			return true;
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
		return false;
	}
}
