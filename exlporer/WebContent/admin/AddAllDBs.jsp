<%@ page import="graphDB.explore.*" %>
<%@ page import="graphDB.users.*" %>

<%
try{
	//Add 'dev' user
	Login.addUser("Dev Sriranganadane","dev", "test");
	//Add Ref Database
	XmlToDb.RUN("/u/caronlo/apps/RefBD.clusterML", "dev");
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\UltraNew\\RefBD.clusterML", "dev");
	//Add M database
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\UltraNew\\MBD.clusterML", "dev");
	XmlToDb.RUN("/u/caronlo/apps/MBD.clusterML", "dev");
	//Add R database
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\UltraNew\\RBD.clusterML", "dev");
	XmlToDb.RUN("/u/caronlo/apps/RBD.clusterML", "dev");
	//Add R database
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\UltraNew\\MnR_Result.clusterML", "dev");
	XmlToDb.RUN("/u/caronlo/apps/MnR_Result.clusterML", "dev");
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\SPIKE\\SpikeResults7.clusterML","dev");
	//XmlToDb.RUN("G:\\Thibault\\Olivier\\ForAntoine\\MandR.clusterML","dev");///u/caronlo/MandR.clusterML","dev");
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>