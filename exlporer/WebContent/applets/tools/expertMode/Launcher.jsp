<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.1.min.js"></script>
	
	<script type="text/javascript">
	
function Launch()
{
		$.post(	"applets/tools/expertMode/Executable.jsp",
				{"query":document.getElementById("textQuery").value},
				function(results)
				{				 	
			 		MessageTop.msg("Table generated:", results);
			 		document.write(results);
				});
}
	</script>
		
	</head>
	<body>
	<jsp:include page="Description.txt"/>
	<br>
	<input type="text" name="textQuery" id="textQuery" size=200/>
	<button onclick="Launch()">Launch!</button>
	</body>
</html>