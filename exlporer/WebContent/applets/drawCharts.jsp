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
<%!

void registerShutdownHook2( final GraphDatabaseService graphDb )
	{
	    // Registers a shutdown hook for the Neo4j instance so that it
	    // shuts down nicely when the VM exits (even if you "Ctrl-C" the
	    // running example before it's completed)
	    Runtime.getRuntime().addShutdownHook( new Thread()
	    {
	        @Override
	        public void run()
			{
	            graphDb.shutdown();
			}
		} );
	}
%>
<%
EmbeddedGraphDatabase graphDb = new EmbeddedGraphDatabase( DefaultTemplate.GraphDB );
try{
registerShutdownHook2(graphDb);
String nodeID = session.getAttribute("userNodeID").toString();
if(request.getParameter("id") != null)
	nodeID = request.getParameter("id");
//only if there are any charts to draw
boolean chartsToDraw = graphDb.getNodeById(Integer.valueOf(nodeID)).hasRelationship(DynamicRelationshipType.withName("Tool_output"));
if(chartsToDraw){
%>


window.store1 = Ext.create('Ext.data.JsonStore', {
    fields: ['name', 'data1'],
    data: [{name: 1, data1:2},
    	{name: 2, data1:14},
   		{name: 3, data1:56},
    	{name: 4, data1:8}]
});



window.store2 = Ext.create('Ext.data.JsonStore', {
    fields: ['name', 'data1'],
    data: [{name: 1, data1:30},
    	{name: 2, data1:11},
   		{name: 3, data1:5},
    	{name: 4, data1:8}]
});


var peptidesLengthChart = Ext.create('Ext.chart.Chart', {
           style: 'background:#fff',
           animate: true,
           shadow: true,
           //renderTo: 'idGraphs',
           height:200,
           width:500,
           store: store1,
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
               highlight: true,
               tips: {
                 trackMouse: true,
                 width: 140,
                 height: 28,
                 renderer: function(storeItem, item) {
                   this.setTitle(storeItem.get('name') + ': ' + storeItem.get('data1') + ' $');
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

var peptidesLengthChart2 = Ext.create('Ext.chart.Chart', {
    style: 'background:#fff',
    animate: true,
    shadow: true,
    //renderTo: 'idGraphs',
    height:200,
    width:500,
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
        highlight: true,
        tips: {
          trackMouse: true,
          //width: 140,
          //height: 28,
          renderer: function(storeItem, item) {
            this.setTitle(storeItem.get('name') + ': ' + storeItem.get('data1') + ' $');
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

var charts=[peptidesLengthChart, peptidesLengthChart2];
//Ext.get('idGraphs').doLayout();


<%}
}
catch(Exception e)
{
	e.printStackTrace();
}
finally
{
	graphDb.shutdown();
}
%>
