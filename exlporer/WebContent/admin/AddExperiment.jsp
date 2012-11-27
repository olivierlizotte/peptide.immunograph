<%@ page import="graphDB.users.*" %>
<%@ page import="graphDB.explore.*" %>

<%
try{
	XmlToDb.RUN("G:\\Thibault\\-=Proteomics_Raw_Data=-\\ELITE\\JUN27_2012\\MR 4Rep DS\\Proteoprofile HGR DB all Mascot score\\PigInfo.clusterML", "dev");
	//out.println("Added the new database... Matching Peptide sequences with available proteomes...");
	PeptideSequence.MatchAllSequences();
%>	
	<jsp:include page="AddPrecursorError.jsp"/>
	<jsp:include page="AddFragmentError.jsp"/>
<%
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
