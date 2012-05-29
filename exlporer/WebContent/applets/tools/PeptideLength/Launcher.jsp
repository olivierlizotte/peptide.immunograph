<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.1.min.js"></script>
	
	<script type="text/javascript">
	
function Launch()
{
		$.post(	"Executable.jsp",
				{"id":<%= request.getAttribute("id") %>},//,"rel":relationType}, 
				function(results)
				{				 	
			 		MessageTop.msg("Table generated:", results);
				});
}
	</script>
		
	</head>
	<body>
	<jsp:include page="Description.txt"/>
	<br>
	<button onclick="Launch()">Launch!</button>
	</body>
</html>