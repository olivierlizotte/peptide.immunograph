<%@ page import="java.io.File"%>
<%@ page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.DynamicRelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="graphDB.explore.*" %>
<%@ page import="javax.servlet.jsp.JspWriter"%>
<%!
public void CreateExtJsChart(String chartName, String storeName, JspWriter out) {
	try 
	{
	out.println("var "+chartName+"= Ext.create('Ext.chart.Chart', {"+
        "style: 'background:#fff',\n"+
        "animate: true,\n"+
        "shadow: true,\n"+
        "store: "+storeName+",\n"+
        "axes: [{\n"+
            "type: 'Numeric',\n"+
            "position: 'left',\n"+
            "fields: ['yax'],\n"+
            "label: {\n"+
            "    renderer: Ext.util.Format.numberRenderer('0,0')\n"+
            "},\n"+
            "title: 'Number of Peptides',\n"+
            "minimum: 0\n"+
        "}, {\n"+
            "type: 'Category',\n"+
            "position: 'bottom',\n"+
             "fields: ['xax'],\n"+
            "title: '"+chartName+"'\n"+
        "}],\n"+
        "series: [{\n"+
            "type: 'column',\n"+
            "axis: 'left',\n"+
            "gutter:0,\n"+
            "highlight: true,\n"+
            "tips: {\n"+
              "trackMouse: true,\n"+
              "renderer: function(storeItem, item) {\n"+
                   "this.setTitle(storeItem.get('xax') + ': ' + storeItem.get('yax'));\n"+
              "}\n"+
            "},\n"+
            "label: {\n"+
              "display: 'insideEnd',\n"+
              "'text-anchor': 'middle',\n"+
                "field: 'yax',\n"+
                "renderer: Ext.util.Format.numberRenderer('0'),\n"+
                "orientation: 'vertical',\n"+
                "color: '#333'\n"+
            "},\n"+
            "xField: 'xax',\n"+
            "yField: 'yax'\n"+
        "}]\n"+
	"});");
	}catch	(IOException e) 
		{
			e.printStackTrace();
		}
}
%>
<%
//EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
try{
	//registerShutdownHook2(graphDb);
//String nodeID = request.getParameter("id");

DefaultNode theNode = (DefaultNode)session.getAttribute("currentNode");
boolean chartsToDraw = theNode.NODE().hasRelationship(DynamicRelationshipType.withName("Tool_output"));

//only if there are any charts to draw
//boolean chartsToDraw = graphDb.getNodeById(Long.valueOf(nodeID)).
//								hasRelationship(DynamicRelationshipType.
//								withName("Tool_output"));
if(chartsToDraw){
	int graphNumber=0;
	Node chartsNode = theNode.NODE().
			getSingleRelationship(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING).
			getEndNode();
	
	for(String chartName : chartsNode.getPropertyKeys()){
		// the node has an attribute named "type", ignore it!
		if (!chartName.equals("type")){
			graphNumber+=1;
			String value=chartsNode.getProperty(chartName).toString();
			String[] xaxis = value.split("\n")[0].split(",");
			String[] yaxis = value.split("\n")[1].split(",");
			/* store the data in a Ext.data.JsonStore:
				window.store1 = Ext.create('Ext.data.JsonStore', {
    				fields: ['name', 'data1'],
    				data: [{name: 1, data1:2},
    						{name: 2, data1:14},
   							{name: 3, data1:56},
    						{name: 4, data1:8},]
				});
			*/
			out.println("window.store"+graphNumber+"= Ext.create('Ext.data.JsonStore', {"+
				    "fields: ['xax', 'yax'],"+
					"data: [");
			for (int i=0 ; i < xaxis.length ; i+=1){
				out.println("{xax:"+xaxis[i]+", yax:"+yaxis[i]+"},");
			}
			out.println("]});");
			CreateExtJsChart(chartName, "store"+graphNumber, out);
			out.println("charts["+(graphNumber-1)+"] = "+chartName);
		}
	}
%>

window.store2 = Ext.create('Ext.data.JsonStore', {
    fields: ['name', 'data1'],
    data: [{name: 1, data1:30},
    	{name: 2, data1:11},
   		{name: 3, data1:5},
    	{name: 4, data1:8},
    	{name: 5, data1:45},
    	{name: 6, data1:23},
    	{name: 7, data1:4},
    	{name: 8, data1:15},
    	{name: 9, data1:10}]
});


var peptidesLengthChart2 = Ext.create('Ext.chart.Chart', {
    style: 'background:#fff',
    animate: true,
    shadow: true,
    //renderTo: 'idGraphs',
    //height:200,
    //width:500,
    store: store2,
    //layout:'fit',
    axes: [{
        type: 'Numeric',
        position: 'left',
        fields: ['data1'],
        label: {
            renderer: Ext.util.Format.numberRenderer('0,0')
        },
        title: 'Number of Hits',
        grid: true,
        minimum: 0
    }, {
        type: 'Category',
        position: 'bottom',
        fields: ['name'],
        title: 'Month of the Year'
    }],
    series: [{
        type: 'column',
        axis: 'left',
        gutter:0,
        highlight: true,
        tips: {
          trackMouse: true,
          width: 5,
          //height: 28,
          renderer: function(storeItem, item) {
            this.setTitle(storeItem.get('name') + ': ' + storeItem.get('data1'));
          }
        },
        label: {
          display: 'insideEnd',
          'text-anchor': 'middle',
            field: 'data1',
            renderer: Ext.util.Format.numberRenderer('0'),
            orientation: 'vertical',
            color: '#333'
        },
        xField: 'name',
        yField: 'data1'
    }]
});

charts[1] = peptidesLengthChart2;



<%}
}
catch(Exception e)
{
	e.printStackTrace();
}
finally
{
	//graphDb.shutdown();
}
%>
