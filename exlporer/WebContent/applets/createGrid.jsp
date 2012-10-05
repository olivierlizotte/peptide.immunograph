<%@ page import="java.io.File"%>
<%@ page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionResult"%>
<%@ page import="org.neo4j.graphdb.Direction"%>
<%@ page import="org.neo4j.graphdb.GraphDatabaseService"%>
<%@ page import="org.neo4j.graphdb.Node"%>
<%@ page import="org.neo4j.graphdb.Relationship"%>
<%@ page import="org.neo4j.graphdb.RelationshipType"%>
<%@ page import="org.neo4j.graphdb.Transaction"%>
<%@ page import="org.neo4j.graphdb.index.Index"%>
<%@ page import="org.neo4j.kernel.AbstractGraphDatabase"%>
<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="graphDB.explore.*"%>

<%

//String nodeID = request.getParameter("id");
//String key = request.getParameter("key");
//if(session.getAttribute("userNodeID") != null)
//{	
	/*
	if(session.getAttribute("currentNode") != null)
	{
		DefaultNode aNode = ((DefaultNode)session.getAttribute("currentNode"));
		nodeID = Long.toString(aNode.getId());
		aNode.printGridDataJSON(out, key);
	}
	else
	{
		nodeID = session.getAttribute("userNodeID").toString();
		if (request.getParameter("id") != null)
			nodeID = request.getParameter("id");
	//	else
	//		nodeID = session.getAttribute("id").toString();	
	
		try 
		{
			DefaultNode theNode = new DefaultNode(nodeID);
			theNode.Initialize();//TODO optimize this call to prevent preloading when key is not empty 
			theNode.printGridDataJSON(out, key);
		} catch (Exception e) 
		{
			e.printStackTrace();
		} finally 
		{
			//graphDb.shutdown();
		}
	}//*/
//}
%>
				
	function CreateGrid(keyName)//myListFields, myListColumns, myListSorters, myListData)
	{
		// wrapped in closure to prevent global vars.
		Ext.define('nodeModel' + keyName, {
			extend : 'Ext.data.Model',
			fields : gridFields[keyName]
		});

		var nodeStore = Ext.create('Ext.data.Store', {
			storeId : 'nodeStoreID' + keyName,
			model : 'nodeModel' + keyName,
			sorters : gridSorters[keyName],
			//New
			pageSize : 100,//50000,
			remoteSort: true,
			proxy: {
				type: 'rest',
				url : 'GetList.jsp',
				extraParams : { 
					id : currentNodeID,
					type : keyName
					},
				reader: {
					type: 'json',
					root: 'root',
					totalProperty: 'total'
				}
			},
			//Old
			//pageSize : gridData[keyName].length,//50000,
			buffered : true,
			//purgePageCount : 0,
			//proxy : {
			//	type : 'memory'
			//},
			////     autoLoad: true,			
			//groupField: 'Relation',
			//EndNew
			//data : gridData[keyName]
		});
		/*
		var groupingFeature = Ext.create('Ext.grid.feature.Grouping',{
		    groupHeaderTpl: 'Relation: {name} ({rows.length} Item{[(values.rows.length > 1 ? "s" : "")]})'
		});//*/


		function Json2Csv(jsonObject){
		alert(jsonObject);
        var array = typeof jsonObject != 'object' ? JSON.parse(jsonObject) : jsonObject;
        var csv = '';
        var header = '';
        for (var i = 0; i < array.length; i++) {
            var line = '';
            for (var index in array[i]) {
                line += array[i][index] + ',';
                // when creating the first line, get the headers
                if (i==0){
                	header += index + ','; 
                }
            }
            line.slice(0,line.Length-1); 
            csv += line + '\r\n';
        }
        csv = header + '\n' + csv
        window.open( "data:text/csv;charset=utf-8," + escape(csv))
    	}
		
    var cellEditing = Ext.create('Ext.grid.plugin.CellEditing', {
        clicksToEdit: 1
    });
    
    var filters = {
        ftype: 'filters',
        // encode and local configuration options defined previously for easier reuse
        encode: true, // json encode the filter query
        local: false,
        //local: local,   // defaults to false (remote filtering)

        // Filters are most naturally placed in the column definition, but can also be
        // added here.
        filters: [{
            type: 'boolean',
            dataIndex: 'visible'
        }]
    };
    
		var theGrid = Ext.create('Ext.grid.Panel',
						{
							id : 'grid' + currentNodeType + keyName,
							//stateful: true,//TODO make sure there is no state corruption bug before using states
							loadMask : true,
		                    animCollapse: false,
		                    collapsible: false,
		                    flex: 1,
		                    layout: 'fit',
							iconCls : 'icon-grid',
							store : nodeStore,
							title : gridName[keyName],
							plugins: [cellEditing],
							//features: [groupingFeature],
				        features: [filters],
							columns : gridColumns[keyName],

							loadMask : true,
							disableSelection : true,
							invalidateScrollerOnRefresh : false,
							viewConfig : {
								trackOver : false
							},
							//End New

							tbar : {
								height : '25px',
								items : [
<!-- 										{ -->
<!-- 											xtype : 'button', -->
<!-- 											text : keyName + ' tools', -->
<!-- 											handler : function() { -->
<!-- 												var toolWin = new Ext.create( -->
<!-- 														'Ext.Window', -->
<!-- 														{ -->
<!-- 															id : 'autoload-win', -->
<!-- 															title : keyName -->
<!-- 																	+ ' Tools', -->
<!-- 															closable : true, -->
<!-- 															width : 400, -->
<!-- 															height : 200, -->
<!-- 															x : 10, -->
<!-- 															y : 200, -->
<!-- 															plain : true, -->
<!-- 															loader : { -->
<!-- 																url : "tools.jsp?name=seq&id="+currentNodeID, -->
<!-- 																scripts : true, -->
<!-- 																autoLoad : true, -->
<!-- 																renderer : 'html' -->
<!-- 															}, -->
<!-- 															layout : 'fit', -->
<!-- 														//items: attributeForm, -->
<!-- 														}); -->
<!-- 												toolWin.show(); -->
<!-- 											} -->
<!-- 										}, -->
										{
											xtype : 'button',
											text : 'csv export',
											iconCls: 'icon-csvExport',
											handler : function() {
												var csvExpWin = new Ext.create(
														'Ext.Window',
														{
															id : 'autoload-win',
															title : 'CSV file export',
															closable : true,
															width : 400,
															autoScroll:true,
															width : 400,
															height : 200,
//															x : 10,
//															y : 200,
															plain : true,
															//autoLoad: {url:'tool.jsp?name='+keyName+'&url='+document.URL, scripts:true},
															loader : {
																url : 'applets/tools/CsvExport/Launcher.jsp?url='
																		+ document.URL+'&id='+currentNodeID,
																scripts : true,
																autoLoad : true,
																renderer : 'html'
															},
															layout : 'fit',
														//items: attributeForm,?url='+document.URL
														});
												csvExpWin.show();
												
												//octet-stream
												//Json2Csv(dataObject)
												//var formatedData = "";
												//var theGrid = Ext.ComponentMgr
												//		.get('grid'
												//				+ currentNodeType
												//				+ keyName);
												//var theStore = theGrid.store;//Ext.ComponentMgr.get('nodeStoreID'+keyName);
												//var columns = theGrid.columns;
												//Title line
												//for (i = 0; i < columns.length; i++)
												//	formatedData += columns[i].dataIndex
												//			+ ',';
												//Items currently displayed
												//for (i = 0; i < theStore.data.items.length; i++) {
												//	formatedData += '\n';
												//	for (j = 0; j < columns.length; j++)
												//		formatedData += theStore.data.items[i].data[columns[j].dataIndex]
												//				+ ',';
												//}/*
																        //TODO
																        //Set a default file name with the csv file type//*/
												//uriContent = 'data:text/csv,'
												//		+ encodeURIComponent(formatedData);
												//newWindow = window
												//		.open(uriContent,
												//				'gridToCSV');
												MessageTop
														.msg('CSV EXPORT',
																'Your file has been created successfully');
												//alert(csvData[keyName]);				 		
											}
										},
										{
											xtype : 'button',
											text : 'csv import',
											iconCls: 'icon-csvImport',
											handler : function() {
												//var attributeForm=createForm();
												var csvWin = new Ext.create(
														'Ext.Window',
														{
															id : 'autoload-win',
															title : 'CSV file import',
															closable : true,
															width : 400,
															autoScroll:true,
															width : 400,
															height : 200,
//															x : 10,
//															y : 200,
															plain : true,
															//autoLoad: {url:'tool.jsp?name='+keyName+'&url='+document.URL, scripts:true},
															loader : {
																url : 'applets/tools/CsvImport/Launcher.jsp?url='
																		+ document.URL+'&id='+currentNodeID,
																scripts : true,
																autoLoad : true,
																renderer : 'html'
															},
															layout : 'fit',
														//items: attributeForm,?url='+document.URL
														});
												csvWin.show();
											}
										},
										{
											xtype : 'button',
											text : 'Expert mode',
											iconCls: 'icon-expert',
											handler : function() {
												//var attributeForm=createForm();
												var queryWin = new Ext.create(
														'Ext.Window',
														{
															id : 'autoload-win',
															title : 'Cypher Query',
															closable : true,
															width : 400,
															height : 180,
//															x : 10,
//															y : 200,
															plain : true,
															//autoLoad: {url:'tool.jsp?name='+keyName+'&url='+document.URL, scripts:true},
															loader : {
																url : 'applets/tools/expertMode/Launcher.jsp?url='
																		+ document.URL+'&id='+currentNodeID,
																scripts : true,
																autoLoad : true
															},
															layout : 'fit',
														//items: attributeForm,?url='+document.URL
														});
												queryWin.show();
											}
										} ]
							}
						});
		nodeStore.guaranteeRange(0, 99);
		return theGrid;

	}

	//STATE PROVIDER VIA COOKIES 
	//Ext.state.Manager.setProvider(new Ext.state.CookieProvider({
	//	expires: new Date(new Date().getTime()+(1000*60*60*24*7)), //7 days from now
	//}));

	/**
* Grid focus issue ----------------------------------------------------------------------------------------------
	 * 
	 * http://www.sencha.com/forum/archive/index.php/t-142291.html?
	 * http://www.sencha.com/forum/showthread.php?136674-Howto-disable-grid-focus-on-click/page2
	 */	 
	Ext.override(Ext.selection.RowModel, {
		onRowMouseDown : function(view, record, item, index, e) {
			//view.el.focus();
			if (!this.allowRightMouseSelection(e))
				return;
			this.selectWithEvent(record, e);
		}
	});

	Ext.override(Ext.grid.plugin.CellEditing,
			{
				onEditComplete : function(ed, value, startValue) {
					var me = this, grid = me.grid, sm = grid
							.getSelectionModel(), activeColumn = me
							.getActiveColumn(), dataIndex;

					if (activeColumn) {
						dataIndex = activeColumn.dataIndex;

						me.setActiveEditor(null);
						me.setActiveColumn(null);
						me.setActiveRecord(null);
						delete sm.wasEditing;

						if (!me.validateEdit())
							return;

						//Only update the record if the new value is different than the
						//startValue, when the view refreshes its el will gain focus
						if (value !== startValue) {
							me.context.record.set(dataIndex, value);
							//Restore focus back to the view's element.
						} else {
							// Line commented out!	
							//grid.getView().getEl(activeColumn).focus();//Faulty line for focus bug
						}
						me.context.value = value;
						me.fireEvent('edit', me, me.context);
					}
				}
			});//*/
//----------------END OF GRID FOCUS FIX-----------------------------------------------------------------------------------
    
    Ext.Loader.setPath('Ext.ux', 'ExtJS/examples/ux');
	Ext.require(['Ext.tab.*',
				 'Ext.ux.grid.FiltersFeature']);

    var Grid;
	Ext.onReady(function() 
	{
		var keys = [];
		var itemsTab = [];

		for ( var keyA in gridFields)
			itemsTab.push(CreateGrid(keyA));

		Grid = Ext.createWidget('tabpanel', {
		    id : 'tabPanelGrid',
			activeTab : 0,
               flex: 1,
               height : 400,
               defaults: {
                   layout: 'fit'
               },
			items : itemsTab
		});
	});



