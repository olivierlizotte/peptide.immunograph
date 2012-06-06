<%@ page import="graphDB.explore.*" %>

<%
try{
	//XmlToDb.RUN("/u/caronlo/MandR.clusterML","dev");
	XmlToDb.RUN("G:\\Thibault\\Olivier\\ForAntoine\\MandR.clusterML","dev");///u/caronlo/MandR.clusterML","dev");
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>