<%@ page import="adminTools.*" %>
<%@page import="javax.servlet.*" %>
<%@page import="javax.servlet.http.*" %>
<%

if(session.getAttribute("userName") == null){
	// not already connected
	String userName = request.getParameter("username");
	String passwd = request.getParameter("passwd");
	if (Login.checkPassword(userName, passwd)){
		session.setAttribute("user", userName);
		response.sendRedirect("index.jsp");
	}else{
		response.sendRedirect("login.jsp?fail=T");
	}
}else{
	// session already started
}
%>