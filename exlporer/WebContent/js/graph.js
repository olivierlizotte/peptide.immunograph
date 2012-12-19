var node,//d3 group object for nodes
    link,//d3 group object for relations
    root,//root of the graph
    jsonObj,//data object storing the graph information
	divName,//identifier for the div containing the graph
	force,//object defining the behavior of a group of nodes
	currentWidth,//width of the canvas (divName div)
	currentHeight,//height of the canvas (divName div)
	vis,//d3 viewport
	nodes,//array of the nodes
	links,//array of relations
	svgLink,//d3 svg for relations
	fcOnClick;//Callback function on node click (Mouse up event)


//Create the graph
function CreateGraph(jsonData, divNameParam, OnClick)
{
	fcOnClick = OnClick;
	divName = divNameParam;

    if(node)
		node.exit().remove();
	if(link)
		link.exit().remove();
	if(force)
		force.stop();
		
	currentWidth = $("#"+divName).width();
    currentHeight = $("#"+divName).height();
		    
	force = d3.layout.force()
	    .on("tick", tick)
	    .gravity(0.1)//.05)
	    .charge(fcCharge)
	    .linkDistance(fcDistance)
	    .size([currentWidth, currentHeight]);
	
	vis = d3.select("#" + divName).append("svg:svg")
	    .attr("width", currentWidth)
	    .attr("height", currentHeight)
	    .attr("pointer-events", "all");

	//Create timer for focus animation
	d3.timer(fcAnimation);
	
	jsonObj = jsonData;
	
	//Update graph content based on json data object
	updateGraph();	

	//Register to changes in window size
	window.onresize = ResizeNavPanel;
}

//Called every few milliseconds, this function changes the stroke-width of the
//clicked circle
function fcAnimation()
{
    node.selectAll("circle").attr("stroke-width", fcStrokeWidth)
    						.attr("stroke", fcStroke);
}

//Retrieves the size, in pixel, for the circle of a node
function fcSize(d) 
{
	if(d.pixelSize)
		return d.pixelSize;
	else
	{
		var size = Math.sqrt(d.size);
		
		if(!d || size <= 36)
			size = 36;
		
		if(size > 160)
			size = 160;
		
		d.pixelSize = size;
		return size;
	}
}

//Retrieves the amount of energy in a node
function fcCharge(d) 
{
	if(d.pixelCharge)
		return d.pixelCharge;
	else
	{
		var charge = -fcSize(d)*50;
		d.pixelCharge = charge;
		return charge;
	}
}

//Retrieves the expected distance between linked nodes
function fcDistance(d) 
{
	if(d.pixelDistance)
		return d.pixelDistance;
	else
	{
		if(!d.source || !d.target)
			return 100;
		
		var distance = (fcSize(d.source) + fcSize(d.target)) * 1.5;	
		
		if(distance < 40)
			distance = 40;
		
		d.pixelDistance = distance;
		return distance;
	}
}

//Focus animation activated on node click
var theFocus;
var cptStroke = 2.5;
var incrStroke = 0.12;
function fcStrokeWidth(d)
{
	if(d.focus)
	{
		cptStroke += incrStroke;
		if(cptStroke > 4 || cptStroke < 1)
			incrStroke = - incrStroke;
		return cptStroke;
	}
	else
		return 2.5;
}

//Retrieves the color of the surrounding line around a circle
function fcStroke(d)
{
	if(d.focus)
		return "#04408c";
	else
		return "#fff";
}

//Retrieves the text to display in a circle, based on node information
function fcText(d)
{
  	return d.name;
}

//Retrieves the angle to rotate text, in order to put tags on relations (links)
function computeAngle(d)
{
	return Math.atan2(d.target.y-d.source.y, d.target.x-d.source.x) * 180/Math.PI;
}

//Retrieves the length of the line linking two nodes
function computeLength(d)
{
	return Math.sqrt((d.target.x - d.source.x) * (d.target.x - d.source.x) + (d.target.y - d.source.y) * (d.target.y - d.source.y)); 
}

//Generates the graph based on the info in the jsonObj.
//This function should get called when the jsonObject content changes.
function updateGraph() 
{
	nodes = jsonObj.nodes;
	links = jsonObj.links;

	root = nodes[0];
	root.fixed = true;
	root.x = currentWidth / 2;
	root.y = currentHeight / 2;
	
  // (Re)Start the force layout.
  force
      .nodes(nodes)
      .links(links)
      .start();

  // Update the links
  link = vis.selectAll("g.link")
      .data(links, function(d) { return d.target.id; });

  svgLink = link.enter().insert("svg:g", ".node")
      .attr("class", "link");
  
  svgLink.append("svg:line")
      .attr("y1", "8")
      .attr("y2", "8");
  
  svgLink.append("svg:line")
  	  .attr("y1", "-8")
  	  .attr("y2", "-8");

  svgLink.append("svg:text")	  
  	  .attr("y", "4")
	  .text(function(d) {      return d.name;    });
  
  // Exit any old links
  link.exit().remove();

  // Update the nodes
  node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id; });

  // Enter any new nodes.
  var svgGroup = node.enter().append("svg:g")
      .attr("class", "node")      
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .on("mouseup", mouseUp)
      .on("mousedown", mouseDown)
	  .on("contextmenu", rightClick)
      .call(force.drag);
  
  //Update state of circles
  vis.selectAll("circle")
  		.transition()
  			.delay(100);
  
  svgGroup.append("svg:circle")
      .attr("r", fcSize)
      .style("fill-opacity", 0.92)
      .style("fill", fcColor);  


  svgGroup.append("svg:text")	  
  	  .attr("x", function(d) { return -(d.name.length * 2.6)+0.5; })
  	  .attr("y", 0.5 )
	  .text(fcText);
 
  if($('svg g.node').tipsy)
  {
	 $('svg g.node').tipsy({ 
	        gravity: 'w', 
	        html: true, 
	        title: function() 
	        {
	        	var d = this.__data__;//, c = colors(d.i);
	        	if(d.info)
	        		return d.info;
	        	else
	        		return d.name;
	        }
	      });
  }
   
  // Exit any old nodes.
  node.exit().remove();
}

//Called periodically, this function updates position of some svg elements to follow the dragged/scattered nodes
function tick() 
{	
	link.attr("transform", function(d) { return "translate(" + d.source.x + "," + d.source.y + ") " + 
			  									"rotate(" + computeAngle(d) + ",0,0) " + 
			  									"translate(" + fcSize(d.source) + ",0)"; });
	
	link.selectAll("line").attr("x2", function(d) { return computeLength(d) - fcSize(d.target) - fcSize(d.source); });
	link.selectAll("text").attr("x", function(d) { return (computeLength(d) - fcSize(d.target) - fcSize(d.source)) * 0.5 - (d.name.length * 3) + 0.5; });

	node.attr("transform", function(d) { return "translate(" + (d.x +0.5)+ "," + (d.y +0.5)+ ")"; });	
}

// Color leaf nodes orange, and packages white or blue.
function fcColor(d) 
{
	if(d.IsRoot)
		return "#dd6d2c";
	if(d.size > 1)
		return "#70a0cf";
	if(d._children)
		return "#3182bd";
	return "#c6dbef";
}

function rightClick(d) 
{	
	d3.event.preventDefault();
}

function mouseUp(d)
{
	d3.event.preventDefault();
}

function mouseDown(d)
{
	for(i = 0; i < nodes.length; i++)	
		nodes[i].fixed = false;
	
	d.fixed = true;	

	if(theFocus)
		theFocus.focus = false;
	
	d.focus = true;
	theFocus = d;
	fcOnClick(d);
	
	d3.event.preventDefault();
}


function ResizeNavPanel()
{
	if(currentWidth != $("#"+divName).width() || currentHeight != $("#"+divName).height())
	{		
		if(root)//If graph is completly loaded
		{
			currentWidth = $("#"+divName).width();
		    currentHeight = $("#"+divName).height();
			    
			force.size([currentWidth, currentHeight]);
	
			vis.attr("width", currentWidth)
			   .attr("height", currentHeight);
			
			updateGraph();
		}
	}	  
}