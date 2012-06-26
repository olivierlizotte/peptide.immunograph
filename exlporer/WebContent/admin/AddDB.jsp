<%@ page import="graphDB.explore.*" %>

<%
try{
	//XmlToDb.RUN("/home/caronlio/mandR.clusterML", "dev");
	XmlToDb.RUN("C:\\_IRIC\\DATA\\SPIKE\\SpikeResults7.clusterML","dev");
	//XmlToDb.RUN("G:\\Thibault\\Olivier\\ForAntoine\\MandR.clusterML","dev");///u/caronlo/MandR.clusterML","dev");
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>