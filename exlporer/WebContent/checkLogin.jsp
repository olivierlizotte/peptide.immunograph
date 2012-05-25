<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="adminTools.*" %>
<%@page import="javax.servlet.*" %>
<%@page import="javax.servlet.http.*" %>
<%
/*
if(session.getAttribute("userName") == null){
	// not already connected
	String userName = request.getParameter("username");
	String passwd = request.getParameter("passwd");
	if (Login.checkPassword(userName, passwd)){
		session.setAttribute("user", userName);
		session.setMaxInactiveInterval(5);

		response.sendRedirect("index.jsp");
	}else{
		response.sendRedirect("login.jsp?fail=T");
	}
}else{
	// session already started
}//*/
%>
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
			session.setMaxInactiveInterval(60);
			session.setAttribute("userNodeID", userID);
		}
		else
			result = "{success:false,errors:{reason:'Login failed.Try again'}}";
 
	} else {
		result = "{success:false,errors:{reason:'Login failed.Try again'}}";
	}
%>
<%=result %>