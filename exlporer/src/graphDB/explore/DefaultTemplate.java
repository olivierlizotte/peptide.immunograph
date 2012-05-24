package graphDB.explore;

abstract public class DefaultTemplate {

	public static String GraphDB = "/home/antoine/neo4j/data/graph.db";
	
	public static Boolean keepAttribute( String theAttributeName )
	{
		switch(theAttributeName)
		{
			case "type":		return false; 
			case "StringID":	return false;
			case "passwd":		return false;
		}
		return true;
	}

	public static Boolean keepRelation( String theRelationName )
	{
		switch(theRelationName)
		{
			case "Comment":		return false;
			case "Hash":		return false;
		}
		return true;
	}
}
