<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%
if (request.getParameter("id") != null){
	session.setAttribute( "id", request.getParameter("id") );
}
else
	session.setAttribute( "id", 1);//"noneEntered");
%>

<script type="text/javascript" src="js/jquery-1.7.1.min.js"></script>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Peptide Immuno Graph</title>

<!-- CSS Files -->
<link type="text/css" href="msg.css" rel="stylesheet" />

<!-- Ext JS Library file -->
<script type="text/javascript" src="ExtJS/bootstrap.js"></script>
<link rel="stylesheet" type="text/css" href="ExtJS/resources/css/ext-all.css" />

</head>
<script type="text/javascript">

Ext.Loader.setConfig({
    enabled: true
});

<%@include file="getInfo.jsp"%>

function columnDesc(val) {
        return '<div style="overflow: auto !important; white-space: normal !important;">'+val+'</div>';
        return val;
}  

var commentGrid;
var nodeStoreComment;
var viewport;

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
	    
	    commentGrid = Ext.create('Ext.panel.Panel', {
	        title: 'Comments',
	        height: 240,
	        layout: {
	            type: 'vbox',       // Arrange child items vertically
	            align: 'stretch',    // Each takes up full width
	        },
	        items: [{               // Results grid specified as a config object with an xtype of 'grid'
	            xtype: 'grid',
	            hideHeaders: true,
	            columns: [{text:'Comments', flex:1, dataIndex:'comment', renderer: columnDesc}],
	            store: nodeStoreComment, // A dummy empty data store
	            flex: 3                                       // Use 1/3 of Container's height (hint to Box layout)
	        	},
	            {
	        		xtype: 'splitter'   // A splitter between the two child items
	        	},
	            {
	                xtype     : 'textareafield',
	                name      : 'newCommentField',
	                emptyText : "Add comment...",
	                flex: 1,
	                bodyPadding: 1,
	                enableKeyEvents: true,
	                listeners: {
	                	keypress: function(field,e)
	                    {	
	                		var theCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	                		if (theCode == 13)//If enter was pressed
	                		{
	                    		AddComment(field, e);
	                    		field.reset();
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

function replaceAll(txt, replace, with_this)
{
	return txt.replace(new RegExp(replace, 'g'), with_this);
}

function AddComment(field, event) {
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
				{"id":currentNodeID,"user":"94156", "comment": texte}, 
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
		height:240,
        //renderTo: 'attribute-container',
        propertyNames: {
            tested: 'QA',
            borderWidth: 'Border Width'
        },
        hideHeaders : true,
        source: attribs
    });
}

function CreateViewport()
{
	return Ext.create('Ext.container.Viewport', {
	id: 'MainContainer',
    layout: {
        align: 'stretch',
        type: 'vbox'
    },
    renderTo: Ext.getBody(),
    items: [    {
                    xtype: 'panel',
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    collapseDirection: 'top',
                    collapsible: true,
                    frameHeader: false,
                    hideCollapseTool: false,
                    preventHeader: false,
                    title: 'Immuno Graph',
                    flex: 1,
                    items: [
                        {
                            xtype: 'panel',
                            minHeight: 100,
                            minWidth: 100,
                            layout: {
                                type: 'absolute'
                            },
                            collapseDirection: 'left',
                            collapsible: true,
                            title: 'Navigation',
                            flex: 0.4,
                            id: 'idNavigation'
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
                            flex: 1,
                            items: [
                                {
                                    xtype: 'container',
                                    height: 200,
                                    layout: {
                                        align: 'stretch',
                                        type: 'hbox'
                                    },
                                    flex: 1,
                                    items: [
                                        {
                                            xtype: 'panel',
                                            title: 'Attributes',
                                            flex: 1.5,
                                            id : 'idAttributes',
                                            items: [CreateAttributes(myAttributeObject)]                                            
                                        },
                                        {
                                            xtype: 'splitter'
                                        },
                                        {
                                            xtype: 'container',//panel',
                                            collapseDirection: 'right',
                                            collapsible: true,
                                            title: 'Comments',
                                            flex: 1,
                                            id: 'idComments',
                                            items: [CreateComments(myCommentData)]
                                        }//*/
                                    ]
                                },
                                {
                                    xtype: 'splitter'
                                },
                                {
                                    xtype: 'panel',
                                    collapseDirection: 'top',
                                    collapsible: true,
                                    title: 'Graphs',
                                    flex: 1,
                                    id: 'idGraphs'                                                                
                                }
                            ]
                        }
                    ]
                },
                {
                    xtype: 'splitter'
                },
                {
                    xtype: 'panel',
                    animCollapse: false,
                    collapsed: false,
                    collapsible: true,
                    title: 'List',
                    flex: 1,
                    id: 'idGrid',
				    loader:{url:<%='"'+"createGrid.jsp?id="+session.getAttribute("id").toString()+'"' %>, scripts:true, autoLoad:true}
                }
            ]
        });
}

function init()
{
	viewport = CreateViewport();	
}

</script>
<body onload="init();">

</body>
</html>