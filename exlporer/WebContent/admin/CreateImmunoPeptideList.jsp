<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%>
<%@page import="scala.util.parsing.json.JSONFormat"%>
<%@ page import="graphDB.explore.*" %>
<%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@page import="org.neo4j.cypher.javacompat.*"%>
<%@page import="java.util.*" %>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<%@ page import="java.text.*"%>
<%@ page import="java.io.*" %>

<%
try{

	// set the http content type to "APPLICATION/OCTET-STREAM
	response.setContentType("APPLICATION/OCTET-STREAM");

	// initialize the http content-disposition header to
	// indicate a file attachment with the default filename
	String disHeader = "Attachment;	Filename=\"List.csv\"";
	response.setHeader("Content-Disposition", disHeader);

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
Node peptidome = graphDb.getNodeById(394015);

	ArrayList<Node> potential = new ArrayList<Node>();	

	HashMap<Node, ArrayList<Node>> proteins = new HashMap<Node, ArrayList<Node>>();
	HashMap<String, Integer> properties = new HashMap<String, Integer>();
	
	//Cycle through peptides
	for (Relationship relPeptidome : peptidome.getRelationships())
	{
		Node peptide = relPeptidome.getOtherNode(peptidome);	
		if (NodeHelper.getType(peptide).toString().equals("Peptide"))
		{
			String strSequence = peptide.getProperty("Sequence").toString();
			
			//Should we keep this peptide?
			if(peptide.hasProperty("best HLA score") &&
			   (Double)peptide.getProperty("best HLA score") <= 1500 &&
			   (Double)peptide.getProperty("Precursor Error") <= 5 &&
			   (Double)peptide.getProperty("Precursor Error") >= -5 &&
			   (Double)peptide.getProperty("Highest Score") >= 19 &&
			   peptide.getProperty("Decoy").equals("False"))
			{
					
				//Keep all properties for reference
				for(String key : peptide.getPropertyKeys())
					if(DefaultTemplate.keepAttribute(key) && !properties.containsKey(key))
						properties.put(key, 1);
				
				//Look for all associated proteins through peptide sequence		
				for (Relationship relPeptide : peptide.getRelationships())
				{
					Node sequence = relPeptide.getOtherNode(peptide);
					if (NodeHelper.getType(sequence).equals("Peptide Sequence") &&
						sequence.getProperty("Sequence").equals(strSequence))
					{		
						int found = 0;
						for (Relationship relSequence : sequence.getRelationships())
						{
							Node protein = relSequence.getOtherNode(sequence);
							if (NodeHelper.getType(relSequence.getOtherNode(sequence)).equals("Protein Sequence"))
							{
								if(!proteins.containsKey(protein))
									proteins.put(protein, new ArrayList<Node>());
								proteins.get(protein).add(peptide);
								found++; 
							}
						}
						if(found == 0)
							System.out.println(sequence.getProperty("Sequence"));
					}
				}
			}
		}
	}
	
	String titleLine = "Protein,Sequence";
	for(String prop : properties.keySet())
		titleLine += "," + prop;
	
	//FileWriter fw = new FileWriter("outputImmunoPep.csv");
	out.println(titleLine);
	//fw.write(titleLine + "\n");
		
	for(Node protein : proteins.keySet())
	{
		//Chromosome number: 1 | Gene symbol: YBX1  Gene id: ENSG00000065978 | Transcript id: ENST00000318612 | Protein id: ENSP00000361621  Protein x1: 0
		String header = "Chromosome number: " + protein.getProperty("Chromosome number").toString() + 
						" | Gene symbol: " + protein.getProperty("Gene symbol").toString() + 
						"  Gene id: " + protein.getProperty("Gene id").toString() + 
						" | Transcript id: " + protein.getProperty("Transcript id").toString() +
						" | Protein id: " + protein.getProperty("Protein id").toString() +
						"  Protein x1: " + protein.getProperty("Protein x1").toString() +
						",";
		
		for(Node peptide : proteins.get(protein))
		{
			String line = peptide.getProperty("Sequence").toString();
			for(String key : properties.keySet())
				if(peptide.hasProperty(key))
					line += "," + peptide.getProperty(key).toString();
				else
					line += ",";
			out.println(header + line);
			//fw.write(header + line + "\n");
		}
	}
	
	//pw.flush();
    //pw.close();    
    //fw.close();

	//out.println("L'Affaire Est Ketchup!");//
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
