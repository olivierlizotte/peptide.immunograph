<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.2.min.js"></script>

	<link rel="stylesheet" type="text/css" media="all" href="styles.css" />

	</head>
	<body>
	<jsp:include page="Description.txt"/>
		<br>
	<form id="upload" name="upload" action="Executable.jsp" method="POST" enctype="multipart/form-data">
	<fieldset style="background-color:#99BCE8">
	<legend style="background-color:#D3E1F1">Upload the file you created with ProteoProfile</legend>

	<input type="hidden" id="MAX_FILE_SIZE" name="MAX_FILE_SIZE" value="300000" />
	
	<div >
		<label for="fileselect"></label>
		<input type="file" id="fileselect" name="fileselect"  />
		<div id="filedrag">or drop the file here if you dare!</div>
	</div>
	
	<div id="submitbutton" >
		<input title="Create the database" width=100 height=100 type='image' src='./images/logo.png' onmouseover="this.src='./images/logoButton.png'" onmouseout="this.src='./images/logo.png'">
		<!-- <button type="submit">Create the Database!</button> -->
	</div>
	<input type="hidden" name="id" value="<%=request.getParameter("id")%>" />
	<input type="hidden" name="rel"	value="<%= request.getParameter("rel")%>" />
	</fieldset>
	</form>
	
	<div id="messages">
	<p>Status Messages</p>
	</div>
	<script src="filedrag.js"></script>

	
	<button onclick="Launch()">Launch!</button>
	<br>
	<div id="wait"></div>
	<br>
	<div id="query-result" style="background:white"></div>
	</body>
</html>
