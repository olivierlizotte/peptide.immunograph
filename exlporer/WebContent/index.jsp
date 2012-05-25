<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%

if(session.getAttribute("user") == null)
{
	%><html>
	<head>
	<link rel="stylesheet" type="text/css" href="ExtJS/resources/css/ext-all.css">
	<script type="text/javascript" src="ExtJS/ext-all.js"></script>
	<script type="text/javascript">
	
	Ext.onReady(function(){
	    Ext.QuickTips.init();
	 
		// Create a variable to hold our EXT Form Panel. 
		// Assign various config options as seen.	 
	    var login = new Ext.FormPanel({ 
	        labelWidth:80,
	        url:'checkLogin.jsp', 
	        frame:true, 
	        title:'Please Login', 
	        defaultType:'textfield',
		monitorValid:true,
		// Specific attributes for the text fields for username / password. 
		// The "name" attribute defines the name of variables sent to the server.
	        items:[{ 
	                fieldLabel:'Username', 
	                name:'loginUsername', 
	                allowBlank:false 
	            },{ 
	                fieldLabel:'Password', 
	                name:'loginPassword', 
	                inputType:'password', 
	                allowBlank:false 
	            }],
	 
		// All the magic happens after the user clicks the button     
	        buttons:[{ 
	                text:'Login',
	                formBind: true,	 
	                // Function that fires when user clicks the button 
	                handler:function(){ 
	                    login.getForm().submit({ 
	                        method:'POST', 
	                        waitTitle:'Connecting', 
	                        waitMsg:'Sending data...',
	 
				// Functions that fire (success or failure) when the server responds. 
				// The one that executes is determined by the 
				// response that comes from login.asp as seen below. The server would 
				// actually respond with valid JSON, 
				// something like: response.write "{ success: true}" or 
				// response.write "{ success: false, errors: { reason: 'Login failed. Try again.' }}" 
				// depending on the logic contained within your server script.
				// If a success occurs, the user is notified with an alert messagebox, 
				// and when they click "OK", they are redirected to whatever page
				// you define as redirect. 
	 
	                        success:function(){ 
	                        	//Ext.Msg.alert('Status', 'Login Successful!', function(btn, text){
					   //if (btn == 'ok'){
						   window.location.reload();
			                        //var redirect = 'test.asp'; 
			                        //window.location = redirect;
	                      //             }
				        //});
	                        },
	 
				// Failure function, see comment above re: success and failure. 
				// You can see here, if login fails, it throws a messagebox
				// at the user telling him / her as much.  
	 
	                        failure:function(form, action){ 
	                            if(action.failureType == 'server'){ 
	                                obj = Ext.JSON.decode(action.response.responseText); 
	                                Ext.Msg.alert('Login Failed!', obj.errors.reason); 
	                            }else{ 
	                                Ext.Msg.alert('Warning!', 'Authentication server is unreachable : ' + action.response.responseText); 
	                            } 
	                            login.getForm().reset(); 
	                        } 
	                    }); 
	                } 
	            }] 
	    });
	 
	 
		// This just creates a window to wrap the login form. 
		// The login object is passed to the items collection.       
	    var win = new Ext.Window({
	        layout:'fit',
	        width:300,
	        height:150,
	        closable: false,
	        resizable: false,
	        plain: true,
	        border: false,
	        items: [login]
		});
		win.show();
	});
	</script>
		
	</head>
	<body></body>
</html>	
	<%
}	
else
{
	%>

<%	
if (request.getParameter("id") != null){
	session.setAttribute( "id", request.getParameter("id") );
}
else
	session.setAttribute( "id", 1);//"noneEntered");
%>



<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Peptide Immuno Graph</title>

<!-- CSS Files -->
<link type="text/css" href="msg.css" rel="stylesheet" />

<!-- JavaScript -->
<script type="text/javascript" src="js/jquery-1.7.1.min.js"></script>
<!-- Ext JS Library file -->
<script type="text/javascript" src="ExtJS/bootstrap.js"></script>
<link rel="stylesheet" type="text/css" href="ExtJS/resources/css/ext-all.css" />
<!-- XmlHttpRequest -->
<script type="text/javascript" src="js/xhtr.js"></script>

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
	                	keypress: function(field,e)
	                    {	
	                		var theCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	                		if (theCode == 13)//If enter was pressed
	                		{
	                    		AddComment(field, e);
	                    		field.reset();
	                    		e.stopEvent();
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
		//height:240,
        //renderTo: 'attribute-container',
        /*propertyNames: {
            tested: 'QA',
            borderWidth: 'Border Width'
        },//*/
    	border: false,
        hideHeaders : true,
        source: attribs
    });
}

function ShowChartsForm(){
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
                                        	border: false,
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
                                    layout: { align: 'stretch',
                                    	      type: 'hbox'
                                    		},
                                    collapseDirection: 'bottom',
                                    collapsible: true,
                                    title: '<button type="button" style="border-radius:40px;font-size:small;font-weight:bold;color:#2B498B;background:#B9D0EE;" onClick="ShowChartsForm()"> <img src="icons/bar_chart.png"/> Charts </button>',
                                    margins: '0 0 0 0',
                                    flex: 1,
                                    layout: 'fit',
                                    id: 'idGraphs',                                                                
                                    border: true
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
                    collapseDirection: 'top',
                    title: 'List',
                	border: false,
                    margins: '0 0 0 0',
                    flex: 1,
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    id: 'idGrid',
				    loader:{url:<%='"'+"createGrid.jsp?id="+session.getAttribute("id").toString()+'"' %>, scripts:true, autoLoad:true}
                }
            ]
        });
}

Ext.onReady(function() {
	init();
});

function init()
{
	viewport = CreateViewport();	
}

</script>
<body>

</body>
</html>
<% } %>