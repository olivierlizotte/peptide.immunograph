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
					"startNodeID":document.getElementById("startNodeID").value,
					},
					function(results)
					{
				 		window.parent.location.href='../../../index.jsp?id='+results;
					});
	}
	
	</script>
	</head>
	<body >
	<jsp:include page="Description.txt"/>
	<br>
	<br>
	please enter a node ID to start the pipeline from (it is written at the end of the address bar of your browser): <br>
	<input type="text" name="startNodeID" id="startNodeID" value=""/> <br>
	<button onclick="Launch()">Launch!</button>
	<br>
	<div id="wait"></div>
	<div id="error"></div>
	</body>
	<script type="text/javascript">
	</script>
</html>
