<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.2.min.js"></script>
	
	<script type="text/javascript">
	
function Launch()
{
	document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
		$.post(	"applets/tools/expertMode/Executable.jsp",
				{"query":document.getElementById("textQuery").value, 
				"id":<%=request.getParameter("id") %>,
				"rel":<%= request.getParameter("rel")%>},
				function(results)
				{		
					MessageTop.msg("Query executed successfuly!", "");
			 		
			 		//document.getElementById("query-result").innerHTML = "</br><b>Result</b></br>"+results+"</br>";
			 		var resultLines = results.split("|");
					
			 		data=Array();
					for (var i=0 ; i < resultLines.length ; i+=1){
			 			data[i] = resultLines[i].split(",");
			 		}
					var store = Ext.create('Ext.data.ArrayStore', {
				        fields: [
				           {name: 'col1'},
				           {name: 'col2'},
				        ],
				        data: data
				    });
					
			 		var grid = Ext.create('Ext.grid.Panel', {
			 	       store: store,
			 	       columns: [
			 	                {
			 	                    text     : 'col1',
			 	                    flex     : 1,
			 	                    sortable : true,
			 	                    dataIndex: 'col1'
			 	                },
			 	                {
			 	                    text     : 'col2',
			 	                    flex    : 1,
			 	                    sortable : true,
			 	                    dataIndex: 'col2'
			 	                }],
			 	        height: 350,
			 	        width: 600,
			 	        title: 'Query results',
			 	        renderTo: 'query-result',
			 	        viewConfig: {
			 	            stripeRows: true
			 	        }
			 	    });
			 		grid.show();
			 		
				});
		document.getElementById("wait").innerHTML="";
}
	</script>
	</head>
	<body>
	<jsp:include page="Description.txt"/>
	<br>
	<input type="text" name="textQuery" id="textQuery" size=200/>
	<button onclick="Launch()">Launch!</button>
	<br>
	<div id="wait"></div>
	<br>
	<div id="query-result" style="background:white"></div>
	</body>
</html>
