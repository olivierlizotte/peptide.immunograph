<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.2.min.js"></script>
	
	<script type="text/javascript">
	
function Launch()
{
	document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
	$.post(	"applets/tools/CsvImport/Executable.jsp",
			{"id":<%=request.getParameter("id") %>,
			"rel":<%= request.getParameter("rel")%>},
			function(results)
			{		
				MessageTop.msg("Query executed successfuly!", "");
		 		
		 		document.getElementById("wait").innerHTML="";
		 		window.parent.location.reload();
			});
}
	</script>
	</head>
	<body>
	<jsp:include page="Description.txt"/>
	<br>
	<button onclick="Launch()">Launch!</button>
	<br>
	<div id="wait"></div>
	<br>
	<div id="query-result" style="background:white"></div>
	</body>
</html>
