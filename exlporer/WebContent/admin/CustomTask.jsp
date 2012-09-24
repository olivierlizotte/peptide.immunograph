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

<%
try{

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	//"PVTQTTNAFVKSRTRF*QTLGTIPGSSSSCC*ILHNLSLYSKRCSSKCFQKSKPNGSITRKRVRSG*LSLLMSFQE*NP*PEWRKMKTFKLGSERSQNKYCL*IMMILLLRAEKLYN*YKLWKRFKNSTSWNPICKYVSFLPILESFFIK*SEPLTLKRRF*SQCRSLGTFLSLGS*LTVSHPSCKKA*G*IHPWLLNSELPS*SLPLPSICPFFVLIRQIAPTCSACHSTILESWYPM*EKFCRSSQKACLHLF*RS*SFRPTTLLKCLPAWTKTS*GTMLS*AHDTRLPSLLMLFPFLLKAS***KRLWLASSRWIQSSCWKME*GKSL*SALPLPCIGD*YSTLEPSQVN*CPS*KSWERPWMDSIVLLNTYRTMSTFMV*RFGRKKYLVS*ITTWSKSVITF*ERRFKIGKACTSPLIFQYPSLPLWMSL*RLLVDSAEKSCGSQTQK*HVT*TS*TLGMI*KLIRK*PAAASSQKSRPPWEPLV*MA*TGFCAL*L*KSYRISSVCFRKLS*ETELFRTL*KPS*MLSVP*KVLSQIQIKFIFPPLPKHRRFGLRISRL**RLGRCRF*DNRLPMN*IILVGLILNIWQLLWRISIRLS*QTLKPTIRTLHFLTPKKITHFYMKSQPIWRQLAFTTH*IRYT*QQSAYPIFQL*TFYF*SLSCQNFNTTKIWPEDT*NSCRCCGCPSVPGGLCSVHKATQE"
	//"EQTAKHVSCLGGPVSPCGCCRCSN*TDEPWIKTTNFNQCSLS*FYFT*LQFIPYASQQ*TYRI*HTTFALQRWIPQSKMYFHTIKKPTLFHLTRITPKLTQ*SLRISIRWLLQWINLILGVLII*NMPLRND*FRCRGLR**LRSIRLGFRRHKPLPPFIFKIQIQSLVK*PVSLM*SPK*LTRFLETE*SLKRFCVSSIRYSK*L*LACFGT*AM*VLPEWPPRSKQSSAAAP*KRILK*IMGLT*ST*TVH*KQTQSGCSKEASDVLLR*LSMWLPLSPYQFILPSTCAKGIKFRRE*FTIVSKSWTTI*SVLYKKRGFR*VMFTSMTRYTNLLVISDMWPREWSK*SPC*NVQSPELTSY*DGICPLPLAS*LSKG*EMKWCSSQIWRSSALWLRK***SAKLLFPFLMLLSPLRTDHA*SLMTG*STKTWAPLCKLLTTPRFS*SR*FLHLCAKQSSRCFKE*MPYWSELITSHCASCTPAIQRILVFFPCISPLPLS*SPLESNLLWPHI*G*AKKCSPHSVTL*SGLSLFTGLSRCQS*FRRKLTLPES*KIFFSELIPLFSVYKCIPNWSTSNKFRKWLKY*NYLKEARLLLIMMI*LCYKNQSRESGLKFTKMKRWEP*PN*EQFSMLLSL*GSRVRKRTISGNPKSKQFCKSSCRKSYLSLNHLI*CCSSSSGPITGLTQ*FRTRSKVFANTTQTVP"
//	out.println(" Value : " +
//	
//		PeptideSequence.IsSimpleMatch("EQTAKHVSCLGGPVSPCGCCRCSN*TDEPWIKTTNFNQCSLS*FYFT*LQFIPYASQQ*TYRI*HTTFALQRWIPQSKMYFHTIKKPTLFHLTRITPKLTQ*SLRISIRWLLQWINLILGVLII*NMPLRND*FRCRGLR**LRSIRLGFRRHKPLPPFIFKIQIQSLVK*PVSLM*SPK*LTRFLETE*SLKRFCVSSIRYSK*L*LACFGT*AM*VLPEWPPRSKQSSAAAP*KRILK*IMGLT*ST*TVH*KQTQSGCSKEASDVLLR*LSMWLPLSPYQFILPSTCAKGIKFRRE*FTIVSKSWTTI*SVLYKKRGFR*VMFTSMTRYTNLLVISDMWPREWSK*SPC*NVQSPELTSY*DGICPLPLAS*LSKG*EMKWCSSQIWRSSALWLRK***SAKLLFPFLMLLSPLRTDHA*SLMTG*STKTWAPLCKLLTTPRFS*SR*FLHLCAKQSSRCFKE*MPYWSELITSHCASCTPAIQRILVFFPCISPLPLS*SPLESNLLWPHI*G*AKKCSPHSVTL*SGLSLFTGLSRCQS*FRRKLTLPES*KIFFSELIPLFSVYKCIPNWSTSNKFRKWLKY*NYLKEARLLLIMMI*LCYKNQSRESGLKFTKMKRWEP*PN*EQFSMLLSL*GSRVRKRTISGNPKSKQFCKSSCRKSYLSLNHLI*CCSSSSGPITGLTQ*FRTRSKVFANTTQTVP", 
//								  "KSCSIRQKEH")//"KSCGSQTQKPH")//
//								  );//
	//PeptideSequence.MatchAllSequences();

	ArrayList<Node> unmatched = new ArrayList<Node>();

	//PeptideSequence.MatchAllSequences();

	Node currentNode = graphDb.getNodeById(555615);
	
	Iterable<Relationship> allRels = currentNode.getRelationships(Direction.OUTGOING);
	for (Relationship rel : allRels)
	{
		Node otherNode = rel.getOtherNode(currentNode);
		if (NodeHelper.getType(otherNode).equals("Peptide"))
		{
			int numberOfAssociatedProteins = 0;
			// GET PROTEIN SEQUENCES ASSOCIATED TO PEPTIDE SEQUENCES
 			Node peptide = otherNode.getSingleRelationship(DynamicRelationshipType.withName("Sequence"), Direction.OUTGOING).getEndNode();
 			for (Relationship protSeq : peptide.getRelationships())
 			{
 				//out.println(protSeq.getOtherNode(peptide) + "<br>");
 				//System.out.println(NodeHelper.getType(protSeq.getOtherNode(peptide)));
 				if (NodeHelper.getType(protSeq.getOtherNode(peptide)).equals("Protein Sequence")){
 					numberOfAssociatedProteins+=1;
 				}
 			}
 			if(numberOfAssociatedProteins == 0)
 			{
 				out.println(peptide.getProperty("Sequence").toString() + ": " + peptide.getId() + "<br>");
 				unmatched.add(peptide);
 			}
 			else
 				numberOfAssociatedProteins = numberOfAssociatedProteins;
		}
	}
/*
	Node[] peptides = new Node[unmatched.size()];
	
	for(int i = 0; i < unmatched.size(); i++)
		peptides[i] = unmatched.get(i);
	
	PeptideSequence.MatchToProtein(peptides);
//*/

//282108
//Node currentNode = graphDb.getNodeById(282108);
//out.println(PeptideSequence.IsSimpleMatch(currentNode.getProperty("Sequence").toString(), "LEINNIWKR") + "  <BR>");
/*
Node[] proteins = PeptideSequence.GetAllProteins();
for(Node protein : proteins)
	if("REVERSE_M2_5690".equals(protein.getProperty("Unique ID")))
	{
		out.println(protein.getId() + "<BR>");
		out.println(PeptideSequence.IsSimpleMatch(protein.getProperty("Sequence"), "LEINNIWKR" + "  <BR>");
	}
//*/
	out.println("L'Affaire Est Ketchup!");//
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
