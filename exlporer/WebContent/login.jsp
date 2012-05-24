<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="javax.servlet.*" %>
<%@page import="javax.servlet.http.*" %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Peptide Immuno Graph</title>
</head>
<center>
<form method="post" action="checkLogin.jsp"  >
<table style="background-color:#005C9F;color:white">
<tr>
<td><b>Your Name: </b></td><td> <input type="text" name="username"/></td>
</tr>
<tr>
<td><b>Password: </b></td><td><input type="password" name="passwd"/></td>
</tr>
<tr><td><input type="submit" value="Enter Peptide-Immuno-Graph"/></td></tr>
<%
if(request.getParameter("fail") != null){
	out.print("<tr style=\"background-color:white;color:red\"><td> authentification failed... </td></tr>");
}
%>
</table>
</form>
</center>
</body>
</html>