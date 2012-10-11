package graphDB.explore;

import java.util.Arrays;
import java.util.HashMap;
import graphDB.explore.tools.Parallel;
import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.graphdb.Transaction;
import org.neo4j.graphdb.index.Index;
import org.neo4j.graphdb.index.IndexHits;

public class PeptideSequence 
{	
	public static int IsSimpleMatchV1(String protein, String peptide)
	{
		char[] protArray = protein.toCharArray();
		int iProt = protein.length() - 1;
		
		char[] pepArray  = peptide.toCharArray();
		int iPepMax = peptide.length() - 1;
		int iPep  = iPepMax;
		
		int nbStar = 0;
		while(iProt >= 0 && iPep >= 0)
		{
			if(protArray[iProt] == pepArray[iPep])
			{
				iProt--;
				iPep--;
				nbStar = 0;
			}
			else
			{
				if(protArray[iProt] == '*')
				{
					iProt--;
					iPep--;
					nbStar++;
				}
				else
				{
					if(nbStar > 0)
					{
						iProt += nbStar - 1;
						iPep = iPepMax;
						nbStar = 0;
					}
					else
					{
						iProt--;
						iPep = iPepMax;
						nbStar = 0;
					}
				}
			}
		}
	    return iProt;
	}
	
	public class star
	{
		public int indexProt;
		public int indexPep;
		public star(int protIndex, int pepIndex)
		{
			indexProt = protIndex;
			indexPep  = pepIndex;
		}
	}
	
	public static int IsSimpleMatch(String protein, String peptide)
	{
		//char[] pepArray  = peptide.toCharArray();		
		//char[] protArray = protein.toCharArray();
		int maxProteins = protein.length();
		int maxPeptide  = peptide.length();
		for(int i = 0; i < maxProteins - maxPeptide; i++)
		{
			int j = 0;
			while(j < maxPeptide)
			{
				if(protein.charAt(i+j) == '*' || peptide.charAt(j) == protein.charAt(i+j))
					j++;
				else
					break;
			}
			if(j == maxPeptide)
				return i;
		}
		return -1;
		/*
		Pattern p = Pattern.compile(protein);
		Matcher m = p.matcher(peptide);
		if(m.matches())
			return m.start();
		else return -1;//*/
		/*
		char[] protArray = protein.toCharArray();
		int iProt = protein.length() - 1;
		int currentCheck = -1;
		
		char[] pepArray  = peptide.toCharArray();
		int iPepMax = peptide.length() - 1;
		int iPep  = iPepMax;
		
		while(iProt >= 0 && iPep >= 0)
		{
			if(protArray[iProt] == pepArray[iPep] || protArray[iProt] == '*')
			{
				if(currentCheck < 0)
					currentCheck = iProt;
				iProt--;
				iPep--;
			}
			else
			{
				if(currentCheck < 0)
					iProt--;
				else
				{
					iProt = currentCheck - 1;
					currentCheck = -1;
				}
				iPep = iPepMax;
			}
		}
		if(iPep < 0)
			return iProt + 1;
		else
			return -1;//*/
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
		proteinHits.close();
		System.gc();
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
		peptideHits.close();
		System.gc();
		
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
	
	private static HashMap<Node, String> GetPeptideSequenceMap(Node[] peptides)
	{
		HashMap<Node, String> peptideMap = new HashMap<Node, String>();
		for(Node peptide : peptides)
		{
			peptideMap.put(peptide, peptide.getProperty("Sequence").toString());
		}
		return peptideMap;
	}

	public static void Match(final Node[] proteins, final Node[] peptides)
	{
		try
		{			
			final RelationshipType relType = DynamicRelationshipType.withName( "Found In" );			
	
			Parallel.ForEach(Arrays.asList(peptides), new Parallel.LoopBody <Node>()
		    {
		        public void run(Node peptide)
			//for(Node peptide : peptides)
			{					
				String pepSeq = (String)peptide.getProperty("Sequence");
				long pepID = peptide.getId();
				int nbPeptideMatch = 0;
								
				for(Node protein : proteins)
				{						
					int indexPos = IsSimpleMatch((String)protein.getProperty("Sequence"), pepSeq);
					if(indexPos >= 0)
					{
						boolean isAlreadyThere = false;
						for(Relationship otherRelation : peptide.getRelationships(relType))
							if(otherRelation.getOtherNode(peptide).getId() == pepID)
								isAlreadyThere = true;
						if(!isAlreadyThere)
						{
							Transaction tx = DefaultTemplate.graphDb().beginTx();
							
							Relationship relation = peptide.createRelationshipTo(protein, relType);
							relation.setProperty("Position", indexPos);			

							tx.success();
							tx.finish();
						}

						nbPeptideMatch++;
					}
				}
				if(nbPeptideMatch == 0)
					System.out.println("Unable to match peptide : " + pepSeq);
	        }});
	
		}catch(Exception e){
			e.printStackTrace();
		}
		//System.out.println("Peptide Sequence Matching started");
		System.out.println("Number of Peptide Sequences matched :" + peptides.length);
		System.out.println("Number of Proteins matched          :" + proteins.length);//nbProteins);
	}

	public static void MatchB(Node[] proteins, final Node[] peptides)
	{
		try
		{
			Transaction tx = DefaultTemplate.graphDb().beginTx();
			//Create a hash map of peptide sequences (for faster access)
			final HashMap<Node, String> peptideMap = GetPeptideSequenceMap(peptides);
			final RelationshipType relType = DynamicRelationshipType.withName( "Found In" );
			
	
		    Parallel.ForEach(Arrays.asList(proteins), new Parallel.LoopBody <Node>()
		    {
		        public void run(Node proteinNode)
	            {
	//		for(Node proteinNode : proteins)
	//		{
					HashMap<Long, Relationship> relationMap = new HashMap<Long, Relationship>();
					for(Relationship otherRelation : proteinNode.getRelationships(relType))
						relationMap.put(otherRelation.getOtherNode(proteinNode).getId(), otherRelation);
					
					String protSeq = proteinNode.getProperty("Sequence").toString();
									
					for(Node peptide : peptides)
					{
						//TODO Find why not all peptides are matched to a protein
	//					if("KLFLVNHSQN".equals(pepSeq) && proteinNode.getProperty("Unique ID").equals("Ref9_1412"))
	//					{
	
						int indexPos = IsSimpleMatch(protSeq, peptideMap.get(peptide));
						if(indexPos >= 0)// && !relationMap.containsKey(peptide.getId()))
						{							
							if(!relationMap.containsKey(peptide.getId()))
							{
	//							if(relationMap.containsKey(peptide.getId()))
	//							{										
									Relationship relation = peptide.createRelationshipTo(proteinNode, relType);
									relation.setProperty("Position", indexPos);
									relationMap.put(peptide.getId(), relation);
									//peptide.setProperty("Number of Protein Match", relationMap.size());
	//							}
							}
						}
	//					else
	//						peptide.setProperty("Number of Protein Match", relationMap.size());
					}
					//nbProteins++;        
		        }
		    });
	
			tx.success();
			tx.finish();
		}catch(Exception e){
			e.printStackTrace();
		}
		//System.out.println("Peptide Sequence Matching started");
		System.out.println("Number of Peptide Sequences matched :" + peptides.length);
		System.out.println("Number of Proteins matched          :" + proteins.length);//nbProteins);
	}
}
