<%@ page import="java.io.File"%>
<%@ page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionEngine" %>
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
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="graphDB.explore.*" %>
<%
if(session.getAttribute("userNodeID") != null)
{
	try
	{		
		String nodeID = session.getAttribute("userNodeID").toString();
		//if( !session.getAttribute("id").toString().equals("noneEntered"))
		if(request.getParameter("id") != null)
			nodeID = request.getParameter("id");//session.getAttribute("id").toString();
		
		DefaultNode theNode = new DefaultNode(nodeID);
		
		//Get browsing history (assume single page opening) TODO: make that work for multiple browser window (past params)		 
		if(session.getAttribute("historyIDs") == null)
			session.setAttribute("historyIDs", new ArrayList());
		List historyIDs = (List)session.getAttribute("historyIDs");
		if(session.getAttribute("historyTypes") == null)
			session.setAttribute("historyTypes", new ArrayList());
		List historyTypes = (List)session.getAttribute("historyTypes");
		/*
		if(session.getAttribute("currentNode") != null)
		{
			DefaultNode pastNode = (DefaultNode)session.getAttribute("currentNode");
			historyIDs.add(pastNode.getId());
			historyTypes.add(pastNode.getType());
		}//*/
		
		//if(session.getAttribute("currentNode") != null)
		//{			
			historyIDs.add(theNode.getId());
			historyTypes.add(NodeHelper.getName(theNode.NODE()));
		//}
		
		String strHistory = "";
		for(int i = 0; i < historyIDs.size(); i++)
		{
			if(!strHistory.isEmpty())
				strHistory += " / ";
	
			strHistory += "<a href='index.jsp?id=" + historyIDs.get(i) + "'>" + historyTypes.get(i) + "</a>";
			
			if(nodeID.equals(historyIDs.get(i).toString()) && i+1 < historyIDs.size())
			{
				
				session.setAttribute("historyIDs", historyIDs.subList(0, i+1));
				session.setAttribute("historyTypes", historyTypes.subList(0, i+1));
				break;
			}
		}
				
		//Save current node object as a session attribute
		session.setAttribute("currentNode", theNode);

		//Create javascript variables
		out.println("var currentNodeID=" + theNode.getId() + ";\n");
		out.println("var currentNodeType=\""+theNode.getType()+"\";\n");
		out.println("var browserHistory=\"" + strHistory + "\";\n");
		out.println(theNode.getAttributeJSON("myAttributeObject"));
		theNode.printGridDataJSON(out);
		
		out.println(theNode.getCommentsVariable("myCommentData"));	
		
		NodeHelper.printNavigationNodes(out, theNode.NODE(), 1, "dataObject");
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
}
%>
