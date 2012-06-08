var node,
    link,
    root,
	divName,
	force,
	currentWidth,
	currentHeight,
	vis,
	nodes,
	links,svgLink,
	fcOnClick;

function CreateGraph(jsonData, divNameParam, OnClick)
{
	fcOnClick = OnClick;
	divName = divNameParam;
	root = jsonData;
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
    .charge(fcCharge)
    .linkDistance(fcDistance)
    .size([currentWidth, currentHeight]);

vis = d3.select("#" + divName).append("svg:svg")
    .attr("width", currentWidth)
    .attr("height", currentHeight)
    .attr("pointer-events", "all");
  //Zoom behavior breaks the node draging functionnality... so we ditch the zoom for the moment
  /*.append('svg:g')
    .call(d3.behavior.zoom().on("zoom", zoomt))
  .append('svg:g');

    .call(d3.behavior.zoom().on("zoom", zoomt))
function zoomt() {
  vis.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
}//*/

jsonData = jsonData;
jsonData.fixed = true;
jsonData.x = currentWidth / 2;
jsonData.y = currentHeight / 2;
updateGraph();
root = jsonData;
}

function fcSize(d) 
{
	if(d.size <= 0)
		return 24;
	var size = (d._children ? Math.sqrt(d.cumulSize) : Math.sqrt(d.size)) + 24;
	if(size > 160)
		return 160;
	else
		return size;  
}

function fcCharge(d) 
{
	var size = -fcSize(d)*14;
	if(size > -100)
		return -100;
	else
		return size;  
}

function fcDistance(d) 
{
	var size = (fcSize(d.source) + fcSize(d.target)) * 4;	
	
	if(size < 40)
		size = 40;
	else if(size > 240)
		size = 240;
	
	return size;
}

function computeAngle(d)
{
	return Math.atan2(d.target.y-d.source.y, d.target.x-d.source.x) * 180/Math.PI;
}

function computeLength(d)
{
	return Math.sqrt((d.target.x - d.source.x) * (d.target.x - d.source.x) + (d.target.y - d.source.y) * (d.target.y - d.source.y)); 
}

function updateGraph() 
{
	nodes = flatten(root);
	links = d3.layout.tree().links(nodes);
	
  // Restart the force layout.
  force
      .nodes(nodes)
      .links(links)
      .start();

  // Update the links
  //link = vis.selectAll("line.link")
  link = vis.selectAll("g.link")
      .data(links, function(d) { return d.target.id; });

  svgLink = link.enter().insert("svg:g", ".node")
      .attr("class", "link");
  
  svgLink.append("svg:line")
      .attr("y1", function(d) { return 8;})
      .attr("y2", function(d) { return 8;});
  
  svgLink.append("svg:line")
  	  .attr("y1", function(d) { return -8;})
  	  .attr("y2", function(d) { return -8;});

  svgLink.append("svg:text")	  
  	  .attr("y", "4")
	  .text(function(d) {      return d.target.name;    });
  
  // Exit any old links
  link.exit().remove();

  // Update the nodes
  node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id; });

  // Enter any new nodes.
  var svgGroup = node.enter().append("svg:g")
      .attr("class", "node")      
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })       
      .on("mousedown", fcOnClick)	  
	  .on("contextmenu", rightclick)
      .call(force.drag);
  
  //Update state of circles
  vis.selectAll("circle")
  		.transition()
  			.delay(100)
  			.attr("r", fcSize)  			
  			.style("fill", color);
    
  svgGroup.append("svg:circle")
      .attr("r", fcSize)
      .style("fill", color);

  svgGroup.append("svg:text")	  
  	  .attr("x", function(d) { return -(d.name.length * 0.5 * 5); })  
  	  .attr("font-size", "10px")
  	  .attr("stroke", "#000")
  	  .attr("stroke-width", ".04em")
	  .text(function(d) {      return d.name;    });
    
 $('svg g').tipsy({ 
        gravity: 'w', 
        html: true, 
        title: function() {
          var d = this.__data__;//, c = colors(d.i);
          return d.name;
        }
      });
  // Exit any old nodes.
  node.exit().remove();
}

function tick() 
{
	link.attr("transform", function(d) { return "translate(" + d.source.x + "," + d.source.y + ") rotate(" + computeAngle(d) + ",0,0)"; });
	link.selectAll("line").attr("x2", function(d) { return computeLength(d); });
	link.selectAll("text").attr("x", function(d) { return computeLength(d) * 0.5 - (d.target.name.length * 0.5 * 5); });

	node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; }); 
}

// Color leaf nodes orange, and packages white or blue.
function color(d) {
  return d._children ? "#3182bd" : d.children ? "#fd8d3c" : "#c6dbef";
}

function rightclick(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
  updateGraph();
  
  //stop showing browser menu
  d3.event.preventDefault();
}

// Returns a list of all nodes under the root.
function flatten(root) {
  var nodes = [], i = 0;

  function recurse(node) 
  {
    if (node.children)
    	node.cumulSize = node.children.reduce(function(p, v) { return p + recurse(v); }, 0);
    if (!node.id) node.id = ++i;
    nodes.push(node);
    if(node.cumulSize)
    	return node.cumulSize;
    else
    	return node.size;
  }
  root.cumulSize = recurse(root);
  return nodes;
}

function ResizeNavPanel()
{
	if(currentWidth != $("#"+divName).width() || currentHeight != $("#"+divName).height())
	{		
		if(root)
		{
			$("#" + divName).empty();
			CreateGraph(root, divName);
		}
	}	  
}

//On Window Resize, recompute the graph
//TODO Call CreateGraph AFTER ExtJS has finished resizing the panel
$(window).resize(ResizeNavPanel);