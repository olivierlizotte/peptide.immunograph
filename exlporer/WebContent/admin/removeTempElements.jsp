<%@ page import="graphDB.explore.*" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
DefaultTemplate.removeAllTempElements(graphDb);
%>