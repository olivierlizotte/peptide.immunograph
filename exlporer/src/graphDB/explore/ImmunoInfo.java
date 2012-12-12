package graphDB.explore;

import org.neo4j.graphdb.Node;

public class ImmunoInfo
{
	public Node Peptide;
	
	public Node Protein;
	
	public int Start;
	public int Stop;
	public String Sequence;
	
	public String Proteome;
	public String ProteinID;
	
	public ImmunoInfo(Node peptide, int position, Node protein)
	{
		Peptide = peptide;
		Sequence = peptide.getProperty("Sequence").toString();
		Start = position;
		Stop = position + Sequence.length();
		
		Protein = protein;
		String id = protein.getProperty("Unique ID").toString();
		if(id.startsWith("REVERSE"))
			Proteome = "DECOY";
		else if (id.startsWith("Ref"))
			Proteome = "GenomeRef";
		else if (id.startsWith("M"))
			Proteome = "M"; 
		else if (id.startsWith("R"))
			Proteome = "R";
		else
			Proteome = "decoy";
		
		ProteinID = Protein.getProperty("Protein id").toString();
	}
	
	public String GetString()
	{
		String chromo  	   = NodeHelper.decimalFormat(Protein.getProperty("Chromosome number").toString());
		String b  	 	   = Protein.getProperty("Gene symbol").toString();
		String c  	 	   = Protein.getProperty("Gene id").toString();
		String d  	 	   = Protein.getProperty("Transcript id").toString();		
		String f    	   = NodeHelper.decimalFormat(Protein.getProperty("Protein x1").toString());

		String pepLine = "";
		pepLine += "," + Peptide.getProperty("Condition 1").toString();
		pepLine += "," + Peptide.getProperty("Condition 2").toString();
		pepLine += "," + Peptide.getProperty("Precursor Error").toString();
		pepLine += "," + Peptide.getProperty("Highest Score").toString();
		if(Peptide.hasProperty("best HLA allele"))
			pepLine += "," + Peptide.getProperty("best HLA allele").toString();
		else
			pepLine += ",";
		if(Peptide.hasProperty("best HLA score"))
			pepLine += "," + Peptide.getProperty("best HLA score").toString();
		else
			pepLine += ",";		
		
		return Proteome + "," + Sequence + "," + Peptide.getId() + "," + Start + "," + Stop + "," + 
				"Chromosome number: " + chromo + " | Gene symbol: " + b + "; Gene id: " + c + 
				" | Transcript id: " + d + " | Protein id: " + ProteinID + "; Protein x1: " + f + pepLine;
	}
}
