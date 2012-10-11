package graphDB.explore;

import org.neo4j.graphdb.Node;

public class FakeNode
{
	public String Sequence;
	public long   ID;
	public FakeNode(Node theNode)
	{
		Sequence = (String)theNode.getProperty("Sequence");
		ID = theNode.getId();
	}
}
