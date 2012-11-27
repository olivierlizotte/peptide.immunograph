<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%>
<%@page import="scala.util.parsing.json.JSONFormat"%>
<%@ page import="graphDB.explore.*" %>
<%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@page import="org.neo4j.cypher.javacompat.*"%>
<%@page import="java.util.*" %>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<html>
	<head>
	
<!-- JavaScript -->
<script type="text/javascript" src="../../../js/jquery-1.7.2.min.js"></script>

	
	
<script type="text/javascript">
var properties=new Array();
var NB_FILTERS = 1;
var MAX_FILTERS = 5;
<%
long currentID = Long.valueOf(request.getParameter("id"));
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
HashMap<String, HashMap<String, Integer>> typesAndPropertiesRelated = NodeHelper.getRelatedNodeTypesAndProperties( graphDb.getNodeById(currentID));
String nodeTypesOptions = "";
String properties;
for (String nodeType : typesAndPropertiesRelated.keySet()){
	properties = "properties['"+nodeType+"']='";
	nodeTypesOptions += "<option value= \""+nodeType+"\">"+nodeType+"</option>\n";
	for (String prop : typesAndPropertiesRelated.get(nodeType).keySet()){
		if (DefaultTemplate.keepAttribute(prop)){
			properties += "<option value=\""+prop+"\"> "+prop+" </option>";
		}
	}
	properties += "';\n";
	out.print(properties+"\n");
}

%>

function changeProperties(){
	nodeType = document.getElementById("nodeType").value;
	for(var i=1 ; i<=NB_FILTERS ; i+=1){
		document.getElementById(('nodeProperty'+i)).innerHTML=properties[nodeType];
	}
	//document.getElementById("nodeProperty1").innerHTML=properties[nodeType];
}

function writeHTMLFilter(){
	
	document.getElementById("additional-filters").innerHTML += ''+
	'<div id="filter'+NB_FILTERS+'" >'+
	'<select id="andor'+(NB_FILTERS-1)+'">'+
	'<option value="and"> and </option>'+
	'<option value="or"> or </option>'+
	'</select><br>'+
	'<fieldset style="border-color:black">'+
	'<legend>filter '+NB_FILTERS+'</legend>'+
	'<select id="nodeProperty'+NB_FILTERS+'" >'+
	'</select>'+
	'<select id="comparator'+NB_FILTERS+'">'+
	'<option value="="> = </option>'+
	'<option value="<"> < </option>'+
	'<option value=">"> > </option>'+
	'</select>	'+
	'<input type="text" id="value'+NB_FILTERS+'" value="a value" size=2/>'+
	'</fieldset>'+
	'</div>';
	changeProperties();
}

function Launch()
{
	var postData = {"id":<%=request.getParameter("id") %>,
			"rel":<%= request.getParameter("rel")%>,
			"NB_FILTERS":NB_FILTERS,
			"nodeType": document.getElementById("nodeType").value,
			"nodeProperty1": document.getElementById("nodeProperty1").value,
			"comparator1": document.getElementById("comparator1").value,
			"value1" : document.getElementById("value1").value
			};
	for(var i=2 ; i<= NB_FILTERS ; i+=1){
		postData[('andor'+(i-1))] = document.getElementById(('andor'+(i-1))).value;
		postData[('nodeProperty'+i)] = document.getElementById(('nodeProperty'+i)).value;
		postData[('comparator'+i)] = document.getElementById(('comparator'+i)).value;
		postData[('value'+i)] = document.getElementById(('value'+i)).value;
	}
	
	document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
		$.post(	"Executable.jsp", 
				postData,
				function(results)
				{		
					//MessageTop.msg("Query executed successfuly!", "");
			 		window.parent.location.href='../../../index.jsp?id='+results;
				});
		document.getElementById("wait").innerHTML="";
}

function addFilter(){
	if (NB_FILTERS < MAX_FILTERS){
		if (document.getElementById('add-filter').disabled){
			document.getElementById('add-filter').disabled = false;
		}
		if(document.getElementById('remove-filter').disabled){
			document.getElementById('remove-filter').disabled = false;
		}
		NB_FILTERS+=1;
		if (document.getElementById('filter'+NB_FILTERS) != null){
			document.getElementById('filter'+NB_FILTERS).style.display="block";
		}else{
			writeHTMLFilter();
		}
		document.getElementById('error-message').innerHTML = NB_FILTERS;
		if(NB_FILTERS == MAX_FILTERS){
			document.getElementById('add-filter').disabled = true;
		}
	}else{
		document.getElementById('add-filter').disabled = true;
	}
}
function removeFilter(){
	if (NB_FILTERS > 1){
		if(document.getElementById('remove-filter').disabled){
			document.getElementById('remove-filter').disabled = false;
		}
		if (document.getElementById('add-filter').disabled){
			document.getElementById('add-filter').disabled = false;
		}
		document.getElementById('filter'+NB_FILTERS).style.display="none";
		NB_FILTERS-=1;
		document.getElementById('error-message').innerHTML = NB_FILTERS;
		if(NB_FILTERS == 1){
			document.getElementById('remove-filter').disabled = true;
		}
	}else{
		document.getElementById('remove-filter').disabled = true;
	}
}

	</script>
	</head>
	<body>
	<jsp:include page="Description.txt"/>
	<br>
	
	Node type you want to query:
	<select id="nodeType" onChange=changeProperties()>
	<%=nodeTypesOptions%>
	</select>
	<br>
	<b>Filters:</b><br>
	<button id="add-filter" onClick=addFilter()>add filter </button> 
	<button id="remove-filter" onClick=removeFilter() disabled="disabled">remove filter</button>
	<div id="filter1">
		<fieldset style="border-color:black">
		<legend>filter 1</legend>
		<select id="nodeProperty1" >
		</select>
		<select id="comparator1">
		<option value="="> = </option>
		<option value="<"> < </option>
		<option value=">"> > </option>
		</select>	
		<input type="text" id="value1" value="a value" size=2/>
		</fieldset>
	</div>
	<br>
	<div id="additional-filters">
	</div>
	<button onclick="Launch()">Launch!</button>
	<br>
	
	<div id="wait"></div>
	<br>
	<script>changeProperties(); </script>
	<div id="error-message" style="color:'red'"></div>
	</body>
</html>
