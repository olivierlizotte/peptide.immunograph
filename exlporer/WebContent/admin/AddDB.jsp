<%@ page import="graphDB.explore.*" %>

<%
try{
	XmlToDb.RUN("/u/caronlo/MandR.clusterML","dev");
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>