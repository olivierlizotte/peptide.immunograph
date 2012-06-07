<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Peptide Immuno Graph</title>

<!-- CSS Files -->
<link type="text/css" href="css/msg.css" rel="stylesheet" />

<!-- JavaScript -->
<script type="text/javascript" src="js/jquery-1.7.1.min.js"></script>

<!-- Ext JS Library file -->
<script type="text/javascript" src="ExtJS/bootstrap.js"></script>
<link rel="stylesheet" type="text/css" href="ExtJS/resources/css/ext-all.css" />

    <script type="text/javascript" src="js/d3/d3.js"></script>
    <script type="text/javascript" src="js/d3/d3.geom.js"></script>
    <script type="text/javascript" src="js/d3/d3.layout.js"></script>	
	<script type="text/javascript" src="js/jquery.tipsy.js"></script>
    <link href="css/tipsy.css" rel="stylesheet" type="text/css" />
    
	<script type="text/javascript" src="js/graph.js"></script>

</head>


<script type="text/javascript">

Ext.Loader.setConfig({
    enabled: true
});

<%@include file="getInfo.jsp"%>

<%@include file="createGrid.jsp"%>
var charts=[];
<%@include file="drawCharts.jsp"%>

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

function columnDesc(val) {
        return '<div style="overflow: auto !important; white-space: normal !important;">'+val+'</div>';
        return val;
}  

var navigate = function(panel, direction){
    // This routine could contain business logic required to manage the navigation steps.
    // It would call setActiveItem as needed, manage navigation button state, handle any
    // branching logic that might be required, handle alternate actions like cancellation
    // or finalization, etc.  A complete wizard implementation could get pretty
    // sophisticated depending on the complexity required, and should probably be
    // done as a subclass of CardLayout in a real-world implementation.
    var layout = panel.getLayout();
    layout[direction]();
    Ext.getCmp('move-prev').setDisabled(!layout.getPrev());
    Ext.getCmp('move-next').setDisabled(!layout.getNext());
};

var viewport;
var commentGrid;
var nodeStoreComment;

function CreateComments(myComments)
{	
	if(!commentGrid)
	{
		Ext.define('ncModel', {
		    extend: 'Ext.data.Model',
		    fields: [{name : "comment", type :'string'}]
		});
		
	    nodeStoreComment = Ext.create('Ext.data.Store', {
	        storeId: 'nodeCommentStoreID',
	        model: 'ncModel',
	        data: myComments
	    });
	    
	    commentGrid = Ext.create('Ext.container.Container', {
	        title: 'Comments',
	        //height: 240,
	        layout: {
	            type: 'vbox',      
	            align: 'stretch'    
	        },
        	border: false,
            //bodyPadding: 0,
	        items: [{             
	            xtype: 'grid',
	            hideHeaders: true,
	            border: false,
	            columns: [{text:'Comments', flex:1, dataIndex:'comment', renderer: columnDesc}],
	            store: nodeStoreComment, 
	            flex: 1                                      
                //layout: 'fit'
	        	},
	            {
	                xtype     : 'textareafield',
	                name      : 'newCommentField',
	                emptyText : "Add comment...",
	                //height : 80,
	                maxHeight:40,
	                //flex: 1,
	                //bodyPadding: 0,
	                //padding : 0,
	                margins: '5 0 -5 0',
	                enableKeyEvents: true,
	                listeners: {
	                	keypress: function(field,event)
	                    {	
	                		var theCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	                		if (theCode == 13)//If enter was pressed
	                		{
	                    		AddComment(field, event);
	                    		field.reset();
	                    		event.stopEvent();
	                		}
	                    	else
	                    		if(theCode == 32)//space bar, trap it
	                    			return false;
	                    		else
	                    			return true;
	                    }
	                }
	            }
	        ]
	    });
	}
	else
		nodeStoreComment.loadData(myComments);
    
    return commentGrid;
}

function replaceAll(txt, replace, with_this)
{
	return txt.replace(new RegExp(replace, 'g'), with_this);
}

function AddComment(field, event) 
{
	//Send new comment to a jsp file that will add the comment and return the new list of comments		
	var texte = field.getValue();
	if(!(texte === ""))
	{
		texte = replaceAll(texte,"\f", "<br/>");
		texte = replaceAll(texte,"\r", "<br/>");
		texte = replaceAll(texte,"\n", "<br/>");
		texte = replaceAll(texte,"\"", "&#34;");
		texte = replaceAll(texte,"/\\/", "&#92;");
 		
		$.post(	"addComment.jsp",
				{"id":currentNodeID,"user":<%=session.getAttribute("userNodeID")%>, "comment": texte}, 
				function(results)
				{				 	
			 		CreateComments( eval(results) );
			 		MessageTop.msg("Comment added", texte);
				});
	}
	return false; 
}   

function CreateAttributes(attribs)
{
	return Ext.create('Ext.grid.property.Grid', {        
    	border: false,
        hideHeaders : true,
        source: attribs
    });
}

function ShowChartsForm()
{
	 var win = new Ext.create('Ext.window.Window',{//Window({
	        layout:'fit',
	        height: 300,
            width: 300,
	        closable: true,
	        resizable: true,
	        id:'tool-win',
//	        plain: true,
	        title:'Tools',
//	        border: false,	        
	        modal:'true',
	        //items: [login]
	        loader:{url:"tools.jsp?id="+currentNodeID, scripts:true, autoLoad:true, renderer:'html'}
		});
	 	//win.load({url:"http://slashdot.org", scripts:true, autoLoad:true, renderer:'html'});
		win.center();
		win.show();
	/*
	var msgContent = 'Which chart do you want to draw?<br><br>';
	msgContent += '<form name="chartsForm"> <input type="checkbox" name="lengthDistribution"/> Peptides length distribution<br>';
	msgContent += '<input type="checkbox" name="volcanoplot"/> Volcano plot<br>';
	Ext.Msg.show({
		width:300,
		title: 'Charts form',
		msg: msgContent,
		buttons: Ext.Msg.OKCANCEL,
		fn: function(btn){
			if (btn=='ok'){
				if (document.chartsForm.lengthDistribution.value == 'on'){
					//get information from DB and draw peptides length graph
					fetchPeptidesLength(drawPeptidesLength);
				}
			}
		}
	});//*/
}

function CreateViewport()
{
	return Ext.create('Ext.container.Viewport', {
	id: 'MainContainer',
    layout: {
        align: 'stretch',
        type: 'vbox'
    },
	border: false,
    renderTo: Ext.getBody(),
    items: [    {
                    xtype: 'panel',
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    margins: '0 0 0 0',
                    collapseDirection: 'top',
                    collapsible: true,
                    frameHeader: false,
                    hideCollapseTool: false,
                    preventHeader: false,
                	border: false,
                    title: 'Immuno Graph',
                    flex: 1,
                    items: [
                        {
                            xtype: 'panel',
                            minHeight: 100,
                            minWidth: 100,
                            layout: 'fit',
                            collapseDirection: 'left',
                            collapsible: true,
                            title: 'Navigation',
                            floatable: false,
                            margins: '0 0 0 0',
                            flex: 0.4,
                            id: 'idNavigation',
                            loader: {
                                url: 'createNav.jsp?id='+currentNodeID,
                                contentType: 'html',
                                autoLoad: true,
                                scripts: true,
                                loadMask: true
                            },
                        },
                        {
                            xtype: 'splitter'
                        },
                        {
                            xtype: 'container',
                            layout: {
                                align: 'stretch',
                                type: 'vbox'
                            },
                            margins: '0 0 0 0',
                            flex: 1,
                        	border: false,
                            items: [
                                {
                                    xtype: 'container',
                                    //height: 200,
                                    layout: {
                                        align: 'stretch',
                                        type: 'hbox'
                                    },
                                	border: false,
                                    margins: '0 0 0 0',
                                    flex: 1,
                                    items: [
                                        {
                                            xtype: 'panel',
                                            title: 'Attributes [' + currentNodeType + ']',
                                            margins: '0 0 0 0',
                                            flex: 1.5,
                                            layout: 'fit',
                                            id : 'idAttributes',
                                            items: [CreateAttributes(myAttributeObject)]
                                        },
                                        {
                                            xtype: 'splitter'
                                        },
                                        {
                                            xtype: 'panel',//panel',
                                            collapseDirection: 'right',
                                            collapsible: true,
                                            title: 'Comments',
                                        	border: true,
                                            margins: '0 0 0 0',
                                            flex: 1,
                                            id: 'idComments',
                                            layout: 'fit',
                                            items: [CreateComments(myCommentData)]
                                        }//*/
                                    ]
                                },
                                {
                                    xtype: 'splitter'
                                },
                                {
                                    xtype: 'panel',
                                    layout: 'card',
                                    collapseDirection: 'bottom',
                                    collapsible: true,
                                    title: '<button type="button" style="border-radius:40px;font-size:small;font-weight:bold;color:#2B498B;background:#B9D0EE;" onClick="ShowChartsForm()"> <img src="icons/bar_chart.png"/> Charts </button>',
                                    margins: '0 0 0 0',
                                    flex: 1,
                                    id: 'idGraphs',                                                               
                                    border: false,
                                    bbar: [
                                           {
                                               id: 'move-prev',
                                               text: 'Back',
                                               handler: function(btn) {
                                                   navigate(btn.up("panel"), "prev");
                                               },
                                               disabled: true
                                           },
                                           '->', // greedy spacer so that the buttons are aligned to each side
                                           {
                                               id: 'move-next',
                                               text: 'Next',
                                               handler: function(btn) {
                                                   navigate(btn.up("panel"), "next");
                                               }
                                           }
                                       ],
                                    items:charts
                                }
                            ]
                        }
                    ]
                },
                {
                    xtype: 'splitter'
                },
                {
                    xtype: 'container',
                    animCollapse: false,
                    collapsed: false,
                    //collapsible: false,
                    //collapseDirection: 'top',
                    title: 'List',
                	border: false,
                    loadMask: true,
                    margins: '0 0 0 0',
                    flex: 1,
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    id: 'idGrid',
                    items: Grid				    
                }
            ]
        });
}
//dynamicPanel = new Ext.Component({
//    loader: {
//       url: 'url_containing_scripts.htm',
//       renderer: 'html',
//       autoLoad: true,
//       scripts: true
//       }
//    });
//Ext.getCmp('specific_panel_id').add(dynamicPanel);  


Ext.onReady(function() {
	viewport = CreateViewport();
});


</script>


<body>

</body>

</html>
