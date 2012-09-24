package graphDB.explore;
import java.io.FileReader;
import graphDB.explore.DefaultTemplate;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.HashMap;

import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.graphdb.Transaction;
import org.neo4j.graphdb.index.Index;
import org.neo4j.graphdb.index.IndexHits;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;


public class XmlToDb extends DefaultHandler
{
	Node currentNode 					= null;
	String currentNodeIndex 			= null;
	Relationship currentRelationship 	= null;

	String currentInfoString 			= "";
	
	HashMap<String, Node> nodeMap;	

	String HeadID;
	Transaction tx;	
	GraphDatabaseService graphDb;
	
	String nickName;
	
	static int MaxTx = 10000;
	int doTx = 0;;
	
	public XmlToDb(String userName) 
	{
		super();
		
		graphDb = DefaultTemplate.graphDb();
		
		//indexing the nodes is essential in order to be able to use the following request type :
		// "start n=node:nodes(StringID="RAW1") return n"
		// DRAWBACK : it takes time and memory......
				
		nodeMap = new HashMap<String, Node>();
		nickName = userName;
	}
	
	public String cleanText(String s)
	{
		s = s.trim();

		if (s.startsWith("'") || s.startsWith("\""))
			s = s.substring(1);
		
		if (s.endsWith("'") || s.endsWith("\""))
			s = s.substring(0, s.length()-1);		
		
		return s.trim();
	}		
	
	public Node RetrieveNode(String strType, String strAttribute, String strValue)
	{		
		try
		{
			Index<Node> nodeIndex = graphDb.index().forNodes(strType);
			IndexHits<Node> result = nodeIndex.get(strAttribute, strValue);
			if(	result.size() == 1 )
				return result.getSingle();
			else if(result.size() > 1)
				return result.next();//If more than one... pick first TODO Raise an admin warning if that happens				
		}
		catch(Exception ex)
		{
			ex.printStackTrace();
		}
		return null;			
	}
	
	//Begin transaction
	public void startDocument ()
	{
		this.tx = graphDb.beginTx();
	}
	
	//For each tag, create or retrieve node
	public void startElement (String uri, String name, String qName, Attributes atts)
	{
		doTx++;
		if(doTx > MaxTx)
		{
			doTx = 0;
			this.tx.success();
			this.tx.finish();
			System.gc();
			System.out.println("GC called...");
			this.tx = graphDb.beginTx();
		}
		
		if("Node".equals(qName))
		{
			if(atts.getValue("Get") != null)
				currentNode = RetrieveNode(cleanText(atts.getValue("Type")), cleanText(atts.getValue("Get")), cleanText(atts.getValue("Match")));
						
			if(currentNode == null)
			{
				currentNode = graphDb.createNode();
				currentNode.setProperty("type", atts.getValue("Type"));
			}
			currentNodeIndex = atts.getValue("Index");
			nodeMap.put(atts.getValue("ID"), currentNode);
		}
		else if("Relation".equals(qName))
		{
			RelationshipType relType = DynamicRelationshipType.withName( atts.getValue("Type") );			
			currentRelationship = nodeMap.get(atts.getValue("FROM")).createRelationshipTo(nodeMap.get(atts.getValue("TO")), relType);
		}
		else if("ClusterML".equals(qName))
		{
			HeadID = atts.getValue("HeadID");
		}
		else
		{
			//Unrecognized xml tag //TODO Raise an admin warning on this tag
		}
		currentInfoString = "";//Empty infoString here otherwise it will cumulate start and end tags
	}

	// collecting the characters while reading the content of a xml tag
	public void characters(char ch[], int start, int length)
	{
		currentInfoString += new String(ch, start, length);
	}
	
	//End of tag: take the tag content and add properties to the node
	public void endElement (String uri, String name, String qName)
	{
		if("Node".equals(qName))
		{
			if(currentNode != null)
			{
				for(String line : currentInfoString.split("\n"))
				//for(String line : currentInfoString.trim().split("\n"))
				{
					if(line != null && !line.isEmpty())
					{
						String[] Info = line.split("=(?=([^\"]*\"[^\"]*\")*[^\"]*$)");
						if(Info.length > 2)
							Info[1] = line.substring(Info[0].length() + 1);
							
						if(Info.length > 1)
						{
							String cleaned1 = cleanText(Info[1]);
							
							if(!cleaned1.equals("NaN") &&
							   !cleaned1.equals("Infinity") && 
							   NodeHelper.isNumeric(cleaned1))
							{
								try{  
									currentNode.setProperty(cleanText(Info[0]), Double.valueOf(cleanText(Info[1])));
								}
								catch(Exception ex)
								{
									currentNode.setProperty(cleanText(Info[0]), cleaned1);
								}
							}else{
								currentNode.setProperty(cleanText(Info[0]), cleanText(Info[1]));
							}
						}	
					}
				}

				if(currentNodeIndex != null)
				{
					try
					{
						Index<Node> nodeIndex = graphDb.index().forNodes(currentNode.getProperty("type").toString());
						nodeIndex.add(currentNode, currentNodeIndex, currentNode.getProperty(currentNodeIndex));
					}
					catch(Exception e)
					{
						e.printStackTrace();
					}
				}
			}
		}
		else if("Relation".equals(qName))
		{
			if(currentRelationship != null)
			{
				for(String line : currentInfoString.split("\n"))
				{
					if(line != null && !line.isEmpty())
					{
						String[] Info = line.split("=(?=([^\"]*\"[^\"]*\")*[^\"]*$)");
						if(Info.length > 2)
							Info[1] = line.substring(Info[0].length() + 1);
							
						if(Info.length > 1)
						{
							String cleaned1 = cleanText(Info[1]);
							
							if(!cleaned1.equals("NaN") &&
							   !cleaned1.equals("Infinity") && 
							   NodeHelper.isNumeric(cleaned1))
							{
								try{
									double d = Double.valueOf(cleanText(Info[1]));  
									NumberFormat formatter = new DecimalFormat("#.########");  
									String f = formatter.format(d);
									currentRelationship.setProperty(cleanText(Info[0]), Double.valueOf(f));
								}
								catch(Exception ex)
								{
									currentRelationship.setProperty(cleanText(Info[0]), cleaned1);
								}
							}else{
								currentRelationship.setProperty(cleanText(Info[0]), cleanText(Info[1]));
							}
						}	
					}
				}
			}
		}
		else if("ClusterML".equals(qName))
		{
		}
		else
		{				
		}
		
		currentNode = null;
		currentRelationship = null;
		currentNodeIndex = null;
	}

	public void endDocument ()
	{
		if(HeadID != null)
		{
			Index<Node> index = graphDb.index().forNodes("users");
			Node nodeUser = index.get("NickName", nickName).getSingle();
			RelationshipType relType = DynamicRelationshipType.withName( "Owner" );			
			currentRelationship = nodeUser.createRelationshipTo(nodeMap.get(HeadID), relType);
			
			System.out.println("Head Node ID = " + nodeMap.get(HeadID).getId());
		}
		
		this.tx.success();
		this.tx.finish();
	}
		
	//Read file and feed DB 
	public static void RUN(String file, String nickName) throws Exception 
	{
		XMLReader xr = XMLReaderFactory.createXMLReader();
		XmlToDb handler = new XmlToDb(nickName);
		xr.setContentHandler(handler);
		xr.setErrorHandler(handler);
		
		FileReader f = new FileReader(file);
		xr.parse(new InputSource(f));
		
	}
}
