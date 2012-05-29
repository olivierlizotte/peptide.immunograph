<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="graphDB.users.*" %>
<%@page import="javax.servlet.*" %>
<%@page import="javax.servlet.http.*" %>
<%
	String result;
	String loginUsername = request.getParameter("loginUsername");
	String loginPassword = request.getParameter("loginPassword");
	if (null != loginUsername && loginUsername.length() > 0) 
	{
		long userID = Login.checkPassword(loginUsername, loginPassword); 
		if (userID >= 0)
		{
			result = "{success:true}";
			session.setAttribute("user", loginUsername);
			session.setMaxInactiveInterval(3600);
			session.setAttribute("userNodeID", userID);
		}
		else
		{
			Thread.sleep(1000);
			result = "{success:false,errors:{reason:'Login failed.Try again'}}";
		}
 
	}
	else 
	{
		Thread.sleep(1000);
		result = "{success:false,errors:{reason:'Login failed.Try again'}}";
	}
%>
<%=result %>