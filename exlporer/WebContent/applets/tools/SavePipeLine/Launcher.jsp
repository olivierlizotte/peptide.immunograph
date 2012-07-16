<html>
	<head>
	
	<!-- JavaScript -->
	<script type="text/javascript" src="../../../js/jquery-1.7.2.min.js"></script>
	<script type="text/javascript" src="../../../ExtJS/bootstrap.js"></script>
	<link rel="stylesheet" type="text/css" href="../../../css/msg.css" />
	<script type="text/javascript">
	MessageTop = function(){
	    var msgCt;

	    function createBox(t, s)
	    {
	       return '<div class="msg" style="position:absolute;"><h3>' + t + '</h3><p>' + s + '</p></div>';
	    };
	    
	    return {
	        msg : function(title, format){
	            if(!msgCt){
	                msgCt = Ext.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
	            }
	            var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
	            var m = Ext.DomHelper.append(msgCt, createBox(title, s), true);
	            m.hide();
	            m.slideIn('t').ghost("t", { delay: 1000, remove: true});
	        },

	        init : function(){
	        }
	    };
	}();

	function Launch()
	{	
		
		document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" /><br><img src=../../../icons/waitingGrandMa.png width=\"150\" height=\"150\" />";
		$.post(	"Executable.jsp",
					{"id":<%=request.getParameter("id") %>,
					"pipelineName":document.getElementById("pipelineName").value,
					"description":document.getElementById("description").value
					},
					function(results)
					{
				 		window.parent.location.href='http://localhost:8080/exlporer/index.jsp?id='+results;
					});
	}
	
	</script>
	</head>
	<body >
	<jsp:include page="Description.txt"/>
	<br>
	<br>
	name of the pipeline: <br>
	<input type="text" name="pipelineName" id="pipelineName" value=""/> <br>
	<textarea rows="6" cols="40" id="description">enter a little description here</textarea>
	<button onclick="Launch()">Launch!</button>
	<br>
	<div id="wait"></div>
	<div id="error"></div>
	</body>
	<script type="text/javascript">
	</script>
</html>
