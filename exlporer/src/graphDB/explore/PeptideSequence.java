package graphDB.explore;

import java.util.Arrays;
import graphDB.explore.tools.Parallel;
import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.graphdb.index.Index;
import org.neo4j.graphdb.index.IndexHits;

public class PeptideSequence 
{	
	public static int IsSimpleMatch(String protein, String peptide)
	{
		char[] protArray = protein.toCharArray();
		int iProt = protein.length() - 1;
		
		char[] pepArray  = peptide.toCharArray();
		int iPepMax = peptide.length() - 1;
		int iPep  = iPepMax;
		
		while(iProt >= 0 && iPep >= 0)
		{
			if(protArray[iProt] == '*' || protArray[iProt] == pepArray[iPep])
				iPep--;
			else
				iPep = iPepMax;
			iProt--;
		}
	    return iProt;
	}
	
	public static Node[] GetAllProteins()
	{

		Index<Node> proteinIndex = DefaultTemplate.graphDb().index().forNodes("Protein Sequence");						
		IndexHits<Node> proteinHits = proteinIndex.query("Unique ID", "*");
		
		Node[] proteins = new Node[proteinHits.size()];
		int index = 0;
		for(Node protein : proteinHits)
		{
			proteins[index] = protein;
			index++;			
		}
		return proteins;
	}
	
	public static Node[] GetAllPeptides()
	{

		Index<Node> peptideIndex = DefaultTemplate.graphDb().index().forNodes("Peptide Sequence");
		IndexHits<Node> peptideHits = peptideIndex.query("Sequence", "*");

		Node[] peptides = new Node[peptideHits.size()];
		int index = 0;
		for(Node peptide : peptideHits)
		{
			peptides[index] = peptide;
			index++;			
		}
		return peptides;
	}
	
	public static void MatchAllSequences()
	{
		Match(GetAllProteins(), GetAllPeptides());
	}
	
	public static void MatchToPeptide(Node[] proteins)
	{		
		Match(proteins, GetAllPeptides());
	}
	
	public static void MatchToProtein(Node[] peptides)
	{	
		Match(GetAllProteins(), peptides);
	}
	
	public static void Match(Node[] proteins, final Node[] peptides)
	{
		final RelationshipType relType = DynamicRelationshipType.withName( "Found In" );
		//final int nbProteins = 0;

	    Parallel.ForEach(Arrays.asList(proteins), new Parallel.LoopBody <Node>()
	    {
	        public void run(Node proteinNode)
	        {
				String protSeq = proteinNode.getProperty("Sequence").toString();
				
				for(Node peptide : peptides)
				{
					int nbMatch = 0;
					String pepSeq = peptide.getProperty("Sequence").toString();

					//TODO Find why not all peptides are matched to a protein
					if("KLFLVNHSQN".equals(pepSeq) && proteinNode.getProperty("Unique ID").equals("Ref9_1412"))
						nbMatch = 0;
						
					int indexPos = IsSimpleMatch(protSeq, pepSeq);
					if(indexPos >= 0)
					{
						boolean add = true;
						if(proteinNode.hasRelationship(relType))
						{
							for(Relationship otherRelation : proteinNode.getRelationships(relType))
							{
								if(otherRelation.getOtherNode(proteinNode).getId() == peptide.getId())
									add = false;
								nbMatch++;
							}
						}
						if(add)
						{										
							Relationship relation = peptide.createRelationshipTo(proteinNode, relType);
							relation.setProperty("Position", indexPos);
							nbMatch++;
							peptide.setProperty("Number of Protein Match", nbMatch);
						}
					}
				}
				//nbProteins++;        
	        }
	    });
	    
		System.out.println("Peptide Sequence Matching started");
		System.out.println("Number of Peptide Sequences matched :" + peptides.length);
		System.out.println("Number of Proteins matched          :" + proteins.length);//nbProteins);
	}
}
