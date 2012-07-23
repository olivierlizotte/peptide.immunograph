<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.2.min.js"></script>
	
	<script type="text/javascript">
	
function Launch()
{
	document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
		$.post(	"Executable.jsp",
				{"aa":document.getElementById("aa").value,
				"pos":document.getElementById("pos").value,
				"start":document.getElementById("start").value,
				"length":document.getElementById("length").value,
				"id":<%=request.getParameter("id") %>,
				"rel":<%= request.getParameter("rel")%>},
				function(results)
				{		
			 		window.parent.location.href='../../../index.jsp?id='+results;
				});
}
	</script>
	</head>
	<body>
	<jsp:include page="Description.txt"/>
	<br>
	<br>
	<fieldset style="border-color:#000000;">
	<legend> AminoAcid search:</legend>
	<br>
	Find Sequences with 
	<select name="aa" id="aa">
		<option VALUE="any">Any</option>
		<option VALUE="A">A</option>
		<option VALUE="R">R</option>
		<option VALUE="N">N</option>
		<option VALUE="D">D</option>
		<option VALUE="C">C</option>
		<option VALUE="E">E</option>
		<option VALUE="Q">Q</option>
		<option VALUE="G">G</option>
		<option VALUE="H">H</option>
		<option VALUE="I">I</option>
		<option VALUE="L">L</option>
		<option VALUE="K">K</option>
		<option VALUE="M">M</option>
		<option VALUE="F">F</option>
		<option VALUE="P">P</option>
		<option VALUE="S">S</option>
		<option VALUE="T">T</option>
		<option VALUE="W">W</option>
		<option VALUE="Y">Y</option>
		<option VALUE="V">V </option>
	</select>
	at position <input type="text" id="pos" name="pos" maxlength="3" size="2"/>.<br>
	Start counting from <select name="start" id="start">
							<option VALUE="Nterm">N terminus</option>
							<option VALUE="Cterm">C terminus</option>
						</select> aminoacid residue.
	<br>
	</fieldset>
	<fieldset style="border-color:#000000;">
	<legend>Sequence length</legend>
	Only sequences of <input type="text" id="length" name="length" maxlength="3" size="2"/>
	aminoacids.
	</fieldset>
	<button onclick="Launch()">Launch!</button>
	<br>
	<div id="wait"></div>
	<br>
	<div id="query-result" style="background:white"></div>
	</body>
</html>
