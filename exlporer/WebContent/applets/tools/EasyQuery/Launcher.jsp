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
var nbFilters = 1;
var maxFilters = 3;
<%
long currentID = Long.valueOf(request.getParameter("id"));
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
HashMap<String, Iterable<String>> typesAndPropertiesRelated = NodeHelper.getRelatedNodeTypesAndProperties( graphDb.getNodeById(currentID));
String nodeTypesOptions = "";
String properties;
for (String nodeType : typesAndPropertiesRelated.keySet()){
	properties = "properties['"+nodeType+"']='";
	nodeTypesOptions += "<option value= \""+nodeType+"\">"+nodeType+"</option>\n";
	for (String prop : typesAndPropertiesRelated.get(nodeType)){
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
	for(var i=1 ; i<=maxFilters ; i+=1){
		document.getElementById(('nodeProperty'+i)).innerHTML=properties[nodeType];
	}
	//document.getElementById("nodeProperty1").innerHTML=properties[nodeType];
}



function Launch()
{
	document.getElementById("wait").innerHTML="<img src=../../../icons/waiting.gif width=\"150\" height=\"20\" />";
		$.post(	"Executable.jsp",
				{"query":document.getElementById("textQuery").value, 
				"id":<%=request.getParameter("id") %>,
				"rel":<%= request.getParameter("rel")%>
				},
				function(results)
				{		
					MessageTop.msg("Query executed successfuly!", "");
			 		
			 		//document.getElementById("query-result").innerHTML = "</br><b>Result</b></br>"+results+"</br>";
				});
		document.getElementById("wait").innerHTML="";
}

function addFilter(){
	if (nbFilters < maxFilters){
		if (document.getElementById('add-filter').disabled){
			document.getElementById('add-filter').disabled = false;
		}
		if(document.getElementById('remove-filter').disabled){
			document.getElementById('remove-filter').disabled = false;
		}
		nbFilters+=1;
		document.getElementById('filter'+nbFilters).style.display="block";
		document.getElementById('error-message').innerHTML = nbFilters;
		if(nbFilters == maxFilters){
			document.getElementById('add-filter').disabled = true;
		}
	}else{
		document.getElementById('add-filter').disabled = true;
	}
}
function removeFilter(){
	if (nbFilters > 1){
		if(document.getElementById('remove-filter').disabled){
			document.getElementById('remove-filter').disabled = false;
		}
		if (document.getElementById('add-filter').disabled){
			document.getElementById('add-filter').disabled = false;
		}
		document.getElementById('filter'+nbFilters).style.display="none";
		nbFilters-=1;
		document.getElementById('error-message').innerHTML = nbFilters;
		if(nbFilters == 1){
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
		<input type="text" id="value1" size=2/>
		</fieldset>
	</div>
	<br>
	<div id="filter2" style="display:none">
		<select id="andor1">
		<option value="and"> and </option>
		<option value="or"> or </option>
		</select><br>
		<fieldset style="border-color:black">
		<legend>filter 2</legend>
		<select id="nodeProperty2" >
		</select>
		<select id="comparator2">
		<option value="="> = </option>
		<option value="<"> < </option>
		<option value=">"> > </option>
		</select>	
		<input type="text" id="value2" size=2/>
		</fieldset>
	</div>
	<div id="filter3" style="display:none">
		<select id="andor2">
		<option value="and"> and </option>
		<option value="or"> or </option>
		</select><br>
		<fieldset style="border-color:black">
		<legend>filter 3</legend>
		<select id="nodeProperty3" >
		</select>
		<select id="comparator3">
		<option value="="> = </option>
		<option value="<"> < </option>
		<option value=">"> > </option>
		</select>	
		<input type="text" id="value3" size=2/>
		</fieldset>
	</div>
	<button onclick="Launch()">Launch!</button>
	<br>
	
	<div id="wait"></div>
	<br>
	<script>changeProperties(); </script>
	<div id="error-message" style="color:'red'"></div>
	</body>
</html>
