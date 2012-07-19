<html>
	<head>
	<link rel="stylesheet" type="text/css" href="ExtJS/resources/css/ext-all.css">
	<script type="text/javascript" src="ExtJS/ext-all.js"></script>
	<script type="text/javascript">
	
	var login;
	var win;
	Ext.onReady(function(){
	    Ext.QuickTips.init();
	 
		// Create a variable to hold our EXT Form Panel. 
		// Assign various config options as seen.	 
	    login = new Ext.FormPanel({ 
	        labelWidth:80,
	        bodyPadding:'10 10 10 10',
	        url:'checkLogin.jsp', 
	        //frame:true, 
	        //title:'Please Login', 
	        defaultType:'textfield',
		monitorValid:true,
		// Specific attributes for the text fields for username / password. 
		// The "name" attribute defines the name of variables sent to the server.
	        items:[{ 
	                fieldLabel:'Nickname', 
	                name:'loginUsername', 
	                allowBlank:false,
	                listeners: {
	                    afterrender: function(field) {
	                      field.focus(false, 200);
	                    }
	                }
	            },{ 
	                fieldLabel:'Password', 
	                name:'loginPassword', 
	                inputType:'password', 
	                allowBlank:false,
	                enableKeyEvents: true,
	                listeners: {
	                	keypress: function(field,e)
	                    {	
	                		var theCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	                		if (theCode == 13)//If enter was pressed
	                			testFunction();
	                    }
	                }
	            }],
	 
		// All the magic happens after the user clicks the button     
	        buttons:[{ 
	                text:'Login',
	                formBind: true,	 
	                // Function that fires when user clicks the button 
	                handler:testFunction
	            }] 
	    });
	 
	 
		// This just creates a window to wrap the login form. 
		// The login object is passed to the items collection.       
	    win = new Ext.Window({
	        layout:'fit',
	        //width:300,
	        //height:150,
	        closable: false,
	        resizable: false,
	        plain: true,
	        title:'Please Login',
	        border: false,
	        modal:'true',
	        items: [login]
		});
		win.center();
		win.show();
		win.center();
	});

	function testFunction()
	{ 
		win.hide();
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
            	//win.hide();
            	window.location.reload();
            },

// Failure function, see comment above re: success and failure. 
// You can see here, if login fails, it throws a messagebox
// at the user telling him / her as much.  

            failure:function(form, action){ 
                if(action.failureType == 'server')
                { 
                    obj = Ext.JSON.decode(action.response.responseText); 

                    Ext.MessageBox.show({
                       title:'Login Failed!',
                       msg: obj.errors.reason,
                       buttons: Ext.MessageBox.OK,
                       fn: function(){ win.show(); },
                       icon: Ext.MessageBox.WARNING
                   });
                }else
                {
                    Ext.MessageBox.show({
                       title:'Warning!',
                       msg: 'Authentication server is unreachable : ' + action.response.responseText,
                       buttons: Ext.MessageBox.OK,
                       fn: function(){ win.show(); },
                       icon: Ext.MessageBox.WARNING
                   });
                } 
                login.getForm().reset(); 
            } 
        }); 
    } 
	</script>
		
	</head>
	<body></body>
</html>