package graphDB.explore;

import java.util.ArrayList;
import java.util.HashMap;

import javax.servlet.jsp.JspWriter;

import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.kernel.EmbeddedGraphDatabase;

public class ImmunoExtract 
{
	
	public static void Extract(JspWriter out, long nodeID)
	{
		try
		{
			EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
			
			Node nodeIds = graphDb.getNodeById(nodeID);			
	
			for (Relationship relPeptidome : nodeIds.getRelationships())
			{
				Node nodePeptide = relPeptidome.getOtherNode(nodeIds);
				if (NodeHelper.getType(nodePeptide).equals("Peptide"))
				{
					HashMap<Long, ImmunoInfo> theProtsM = new HashMap<Long, ImmunoInfo>();
					HashMap<Long, ImmunoInfo> theProtsR = new HashMap<Long, ImmunoInfo>();
					for (Relationship idRel : nodePeptide.getRelationships())
					{
						Node nodeSeq = idRel.getOtherNode(nodePeptide);
						if (NodeHelper.getType(nodeSeq).equals("Peptide Sequence"))
						{
							for (Relationship protRel : nodeSeq.getRelationships())
							{
								Node nodeProt = protRel.getOtherNode(nodeSeq);
								if (NodeHelper.getType(nodeProt).equals("Protein Sequence"))
								{
									ImmunoInfo holder = new ImmunoInfo(nodePeptide, NodeHelper.PropertyToInt(protRel.getProperty("Position")), nodeProt);									

									if(holder.Proteome.equals("M"))
										theProtsM.put(nodeProt.getId(), holder);
									if(holder.Proteome.equals("R"))
										theProtsR.put(nodeProt.getId(), holder);
								}
							}
						}
					}
					if(theProtsM.size() > 0 && theProtsR.size() == 0)
					{
						//Find in M the corresponding sequences
						for(ImmunoInfo info : theProtsM.values())
						{
							boolean found = false;
							for (Relationship relPeptidome2 : nodeIds.getRelationships())
							{
								Node nodePeptide2 = relPeptidome2.getOtherNode(nodeIds);
								if (NodeHelper.getType(nodePeptide2).equals("Peptide"))
								{
									//For each protein of M, look for matches from R at same position
									for (Relationship idRel : nodePeptide2.getRelationships())
									{
										Node nodeSeq = idRel.getOtherNode(nodePeptide2);
										if (NodeHelper.getType(nodeSeq).equals("Peptide Sequence"))
										{
											for (Relationship protRel : nodeSeq.getRelationships())
											{
												Node nodeProt = protRel.getOtherNode(nodeSeq);
												if (NodeHelper.getType(nodeProt).equals("Protein Sequence"))
												{
													ImmunoInfo holder = new ImmunoInfo(nodePeptide2, NodeHelper.PropertyToInt(protRel.getProperty("Position")), nodeProt);									
		
													if(holder.ProteinID.equals(info.ProteinID) && holder.Proteome.equals("R") &&
													   holder.Start < info.Stop && holder.Stop > info.Start)
													{
														out.println(info.GetString() + "," + 
													                holder.GetString());
														found = true;
													}
												}
											}
										}
									}
								}
							}
							if(!found)
								out.println(info.GetString() + ",");
						}
					}
					if(theProtsR.size() > 0 && theProtsM.size() == 0)
					{
						//Find in M the corresponding sequences
						for(ImmunoInfo info : theProtsR.values())
						{
							boolean found = false;
							for (Relationship relPeptidome2 : nodeIds.getRelationships())
							{
								Node nodePeptide2 = relPeptidome2.getOtherNode(nodeIds);
								if (NodeHelper.getType(nodePeptide2).equals("Peptide"))
								{
									//For each protein of M, look for matches from R at same position
									for (Relationship idRel : nodePeptide2.getRelationships())
									{
										Node nodeSeq = idRel.getOtherNode(nodePeptide2);
										if (NodeHelper.getType(nodeSeq).equals("Peptide Sequence"))
										{
											for (Relationship protRel : nodeSeq.getRelationships())
											{
												Node nodeProt = protRel.getOtherNode(nodeSeq);
												if (NodeHelper.getType(nodeProt).equals("Protein Sequence"))
												{
													ImmunoInfo holder = new ImmunoInfo(nodePeptide2, NodeHelper.PropertyToInt(protRel.getProperty("Position")), nodeProt);									
		
													if(holder.ProteinID.equals(info.ProteinID) && holder.Proteome.equals("M") &&
													   holder.Start < info.Stop && holder.Stop > info.Start)
													{
														out.println(info.GetString() + "," + holder.GetString());
														found = true;
													}
												}
											}
										}
									}
								}
							}
							if(!found)
								out.println(info.GetString() + ",");
						}
					}
				}
			}
		}
		catch(Exception e)		
		{
			e.printStackTrace();
		}	
	}
	
	public static ArrayList<ImmunoInfo> GetSingle(Node nodePeptide, Node nodePeptidome)
	{
		int slider = 11;
		ArrayList<ImmunoInfo> list = new ArrayList<ImmunoInfo>();
		try
		{
			HashMap<Long, ImmunoInfo> theProtsM = new HashMap<Long, ImmunoInfo>();
			HashMap<Long, ImmunoInfo> theProtsR = new HashMap<Long, ImmunoInfo>();
			for (Relationship idRel : nodePeptide.getRelationships())
			{
				Node nodeSeq = idRel.getOtherNode(nodePeptide);
				if (NodeHelper.getType(nodeSeq).equals("Peptide Sequence"))
				{
					for (Relationship protRel : nodeSeq.getRelationships())
					{
						Node nodeProt = protRel.getOtherNode(nodeSeq);
						if (NodeHelper.getType(nodeProt).equals("Protein Sequence"))
						{
							ImmunoInfo holder = new ImmunoInfo(nodePeptide, NodeHelper.PropertyToInt(protRel.getProperty("Position")), nodeProt);									

							if(holder.Proteome.equals("M"))
								theProtsM.put(nodeProt.getId(), holder);
							if(holder.Proteome.equals("R"))
								theProtsR.put(nodeProt.getId(), holder);
						}
					}
				}
			}
			if(theProtsM.size() > 0 && theProtsR.size() == 0)
			{
				//Find in M the corresponding sequences
				for(ImmunoInfo info : theProtsM.values())
				{
					for (Relationship relPeptidome2 : nodePeptidome.getRelationships())
					{
						Node nodePeptide2 = relPeptidome2.getOtherNode(nodePeptidome);
						if (NodeHelper.getType(nodePeptide2).equals("Peptide"))
						{
							//For each protein of M, look for matches from R at same position
							for (Relationship idRel : nodePeptide2.getRelationships())
							{
								Node nodeSeq = idRel.getOtherNode(nodePeptide2);
								if (NodeHelper.getType(nodeSeq).equals("Peptide Sequence"))
								{
									for (Relationship protRel : nodeSeq.getRelationships())
									{
										Node nodeProt = protRel.getOtherNode(nodeSeq);
										if (NodeHelper.getType(nodeProt).equals("Protein Sequence"))
										{
											ImmunoInfo holder = new ImmunoInfo(nodePeptide2, NodeHelper.PropertyToInt(protRel.getProperty("Position")), nodeProt);									

											if(holder.ProteinID.equals(info.ProteinID) && holder.Proteome.equals("R") &&
											   holder.Start < info.Stop + slider && holder.Stop > info.Start-slider)
											{
												list.add(holder);
											}
										}
									}
								}
							}
						}
					}
				 }
			}
			
			if(theProtsR.size() > 0 && theProtsM.size() == 0)
			{
				//Find in M the corresponding sequences
				for(ImmunoInfo info : theProtsR.values())
				{
					for (Relationship relPeptidome2 : nodePeptidome.getRelationships())
					{
						Node nodePeptide2 = relPeptidome2.getOtherNode(nodePeptidome);
						if (NodeHelper.getType(nodePeptide2).equals("Peptide"))
						{
							//For each protein of M, look for matches from R at same position
							for (Relationship idRel : nodePeptide2.getRelationships())
							{
								Node nodeSeq = idRel.getOtherNode(nodePeptide2);
								if (NodeHelper.getType(nodeSeq).equals("Peptide Sequence"))
								{
									for (Relationship protRel : nodeSeq.getRelationships())
									{
										Node nodeProt = protRel.getOtherNode(nodeSeq);
										if (NodeHelper.getType(nodeProt).equals("Protein Sequence"))
										{
											ImmunoInfo holder = new ImmunoInfo(nodePeptide2, NodeHelper.PropertyToInt(protRel.getProperty("Position")), nodeProt);									

											if(holder.ProteinID.equals(info.ProteinID) && holder.Proteome.equals("M") &&
												holder.Start < info.Stop + slider && holder.Stop > info.Start-slider)
											{
												list.add(holder);
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		catch(Exception e)		
		{
			e.printStackTrace();
		}	
		return list;
	}
}
