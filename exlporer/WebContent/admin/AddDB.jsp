<%@ page import="graphDB.explore.*" %>

<%
try{
	//XmlToDb.RUN("/home/caronlio/mandR.clusterML", "dev");
	XmlToDb.RUN("/apps/Files/toInclude.clusterML", "dev");
	//XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\4Reps\\ProteoProfileClustering\\MnR4Reps.clusterML","dev");
	//XmlToDb.RUN("/home/antoine/workspace/clusterML/ipi7.clusterML", "dev");
	//XmlToDb.RUN("/home/antoine/workspace/clusterML/SpikeResults7.clusterML", "dev");
	//XmlToDb.RUN("G:\\Thibault\\Olivier\\ForAntoine\\MandR.clusterML","dev");///u/caronlo/MandR.clusterML","dev");
	//XmlToDb.RUN("/home/antoine/workspace/clusterML/ultraNew/MnR4Reps.clusterML", "dev");
	out.println("Added the new database... Matching Peptide sequences with available proteomes...");
	PeptideSequence.MatchAllSequences();
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
