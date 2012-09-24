<%@ page import="graphDB.explore.*" %>
<%@ page import="graphDB.users.*" %>

<%
try{
	//Add 'dev' user
//	Login.addUser("Dev Sriranganadane","dev", "test");
	//Add Ref Database
	XmlToDb.RUN("/home/antoine/workspace/clusterML/ultraNew/RefBD.clusterML", "dev");
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\Newestest\\BDRef_WithReverse5b.clusterML", "dev");
	//Add M database
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\Newestest\\translatedM_WithReverse5b.clusterML", "dev");
	XmlToDb.RUN("/home/antoine/workspace/clusterML/ultraNew/MBD.clusterML", "dev");
	//Add R database
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\Newestest\\translatedR_WithReverse5b.clusterML", "dev");
	XmlToDb.RUN("/home/antoine/workspace/clusterML/ultraNew/RBD.clusterML", "dev");
	//Add R database
//	XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\UltraNew\\MnR_Result.clusterML", "dev");
	//XmlToDb.RUN("/u/caronlo/apps/MnR_Result.clusterML", "dev");
	//XmlToDb.RUN("G:\\Thibault\\-=Proteomics_Raw_Data=-\\VELOS\\OCT06_2010\\_NEW\\01July2012\\MandR_RefOnly.clusterML","dev");
	//XmlToDb.RUN("G:\\Thibault\\Olivier\\ForAntoine\\MandR.clusterML","dev");///u/caronlo/MandR.clusterML","dev");
	PeptideSequence.MatchAllSequences();
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
