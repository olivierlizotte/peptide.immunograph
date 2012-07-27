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
		$.post(	"Executable2.jsp",
					{"id":<%=request.getParameter("id") %>,"rel":<%= request.getParameter("rel")%>}, 
					function(results)
					{
				 		document.getElementById("res").innerHTML=results;
				 		window.parent.location.reload();
					});
	}
	
	</script>
	</head>
	<body >
	<jsp:include page="Description.txt"/>
	<br>
	<!-- <div id="form"></div>
	<br>
	 <br>
	Draw Length distribution from: <br>
	<input type="checkbox" id="peptidome"/> Peptidome <br>
	<input type="checkbox" id="sequenceSearch"/> Sequence Search <br> -->
	<button onclick="Launch()">Launch!</button>
	<br>
	<div id="wait"></div>
	<div id="res"></div>
	</body>
	<script type="text/javascript">
	</script>
</html>
