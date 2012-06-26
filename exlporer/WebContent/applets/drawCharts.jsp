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

/* store the data in a Ext.data.JsonStore:
window.store1 = Ext.create('Ext.data.JsonStore', {
	fields: ['name', 'data1'],
	data: [{name: 1, data1:2},
			{name: 2, data1:14},
				{name: 3, data1:56},
			{name: 4, data1:8},]
});
*/
public void CreateJsonStore(String[] xData, String[] yData, int graphNumber, JspWriter out){
	try{
		out.println("window.store"+graphNumber+"= Ext.create('Ext.data.JsonStore', {"+
		    "fields: ['xax', 'yax'],"+
			"data: [");
		for (int i=0 ; i < xData.length ; i+=1){
			out.println("{xax:'"+xData[i]+"', yax:'"+yData[i]+"'},");
		}
		out.println("]});");
	}catch (IOException e) 	{
		e.printStackTrace();
	}
}
public void CreateExtJsChart(String chartName, String storeName, String title, JspWriter out, String AxeY) {
	try {
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
            "title: '" + AxeY + "',\n"+
            "minimum: 0\n"+
        "}, {\n"+
            "type: 'Category',\n"+
            "position: 'bottom',\n"+
            "fields: ['xax'],\n"+
            "title: '"+title+"'\n"+
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
	}catch	(IOException e) {
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

	int graphNumber=0;
	//only if there are any charts to draw
	//boolean chartsToDraw = graphDb.getNodeById(Long.valueOf(nodeID)).
	//								hasRelationship(DynamicRelationshipType.
	//								withName("Tool_output"));
	for (Relationship chartsRel : theNode.NODE().getRelationships(DynamicRelationshipType.withName("Tool_output"), Direction.OUTGOING))
	{
		Node chartsNode = chartsRel.getOtherNode(theNode.NODE());
		if(chartsNode.hasProperty("data") && chartsNode.hasProperty("Name") )
		{
			graphNumber++;
			String value = chartsNode.getProperty("data").toString();
			String strAxeY = "Number of Peptides";
			if(chartsNode.hasProperty("AxeY"))
				strAxeY = chartsNode.getProperty("AxeY").toString();
			String[] splits = value.split("\\|");
			String[] xaxis = splits[0].split(",");
			String[] yaxis = splits[1].split(",");
					
			CreateJsonStore(xaxis, yaxis, graphNumber, out);
			CreateExtJsChart("chart" + graphNumber, "store"+graphNumber, chartsNode.getProperty("Name").toString(), out,
							 strAxeY);
			out.println("charts["+(graphNumber-1)+"] = " + "chart" + graphNumber);
		}
	}
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
