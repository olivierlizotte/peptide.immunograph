<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.2.min.js"></script>
	
	<script type="text/javascript">
	
function Launch()
{
	document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
		$.post(	"Executable.jsp",
				{"id":<%=request.getParameter("id") %>,
				"rel":<%= request.getParameter("rel")%>},
				function(results)
				{		
					window.parent.location.href = '../../../index.jsp?id='+results; 		
				});
}
	</script>
	</head>
	<body>
	<jsp:include page="Description.txt"/>
	<br>
	<b>Please be sure, there is no way to get it back!</b><br>
	<button onclick="Launch()">Delete!</button>
	<br>
	<div id="wait"></div>
	</body>
</html>
