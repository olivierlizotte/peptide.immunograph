<html>
	<head>
	
	<script type="text/javascript">
	var csvFile;
function Launch()
{
	if (csvFile == null)
		csvFile = document.getElementById('fileselect').files[0];
    if (csvFile) {
      var reader = new FileReader();
      reader.onload = function(e) { 
	    contents = e.target.result;
	    //alert(contents);
	    $.post("applets/tools/CsvImport/Executable.jsp",
			{"id":<%=request.getParameter("id") %>,
			"rel":<%= request.getParameter("rel")%>,
			"fileContent": contents,
			},
			function(results)
			{		
				alert(results);
				//window.parent.location.href='http://localhost:8080/exlporer/index.jsp?id='+results;
			});
      }
      reader.readAsText(csvFile);
    } else { 
      alert("Failed to load file");
    }
}
// 	document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
// 		$.post(	"Executable.jsp",
<%-- 				{"id":<%=request.getParameter("id") %>, --%>
<%-- 				"rel":<%= request.getParameter("rel")%>, --%>
// 				"file": document.getElementById("fileselect").files[0]},
// 				function(results)
// 				{		
// 			 		alert(results);
// 					//window.parent.location.href='http://localhost:8080/exlporer/index.jsp?id='+results;
// 				});




	</script>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>

	<link rel="stylesheet" type="text/css" media="all" href="applets/tools/CsvImport/styles.css" />

	</head>
	<body>
	<jsp:include page="Description.txt"/>
		<br>
	<fieldset style="background-color:#99BCE8">
	<legend style="background-color:#D3E1F1">Upload the file you created with ProteoProfile</legend>
	
	
	<input type="hidden" id="MAX_FILE_SIZE" name="MAX_FILE_SIZE" value="300000" />
	<form id="form1">
	<div >
		<label for="fileselect"></label>
		<input type="file" id="fileselect" name="fileselect"  />
		<div id="filedrag">or drop the file here if you dare!</div>
	</div>
	</form>
	<div id="submitbutton" >
		<button onclick="Launch()">Launch!</button>
		<!-- <button type="submit">Create the Database!</button> -->
	</div>
	<input type="hidden" name="id" value="<%=request.getParameter("id")%>" />
	<input type="hidden" name="rel"	value="<%= request.getParameter("rel")%>" />
	</fieldset>
	
	<div id="messages">
	<p>Status Messages</p>
	</div>
	<script src="applets/tools/CsvImport/filedrag.js"></script>
	</body>
</html>
