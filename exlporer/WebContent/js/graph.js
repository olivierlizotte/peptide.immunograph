var node,
    link,
    root,
	divName,
	force,
	currentWidth,
	currentHeight,
	vis,
	nodes,
	links;

function CreateGraph(jsonData, divNameParam)
{
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
jsonData.fixed = false;
jsonData.x = currentWidth / 2;
jsonData.y = currentHeight / 2;
updateGraph();
root = jsonData;
}

function fcSize(d) 
{
	if(d.size <= 0)
		return 24;
	var size = (d._children ? Math.sqrt(d.cumulSize) : Math.sqrt(d.size));
	if(size < 24)
		return 24;
	else if(size > 160)
		return 160;
	else
		return size;  
}

function fcCharge(d) 
{
	var size = -fcSize(d)*10;
	if(size > -100)
		return -100;
	else
		return size;  
}

function fcDistance(d) 
{
	var size = (fcSize(d.source) + fcSize(d.target)) * 2;	
	
	if(size < 40)
		size = 40;
	else if(size > 160)
		size = 160;
	
	return size;
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
  link = vis.selectAll("line.link")
      .data(links, function(d) { return d.target.id; });

  // Enter any new links
  link.enter().insert("svg:line", ".node")
      .attr("class", "link")
      .attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

  // Exit any old links
  link.exit().remove();

  // Update the nodes
  node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id; });

  // Enter any new nodes.
  var svgGroup = node.enter().append("svg:g")
      .attr("class", "node")      
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })       
      .on("click", click)	  
	  .on("contextmenu", rightclick)
      .call(force.drag);
  
  vis.selectAll("circle")
  			.style("fill", color)
  			.attr("r", fcSize);
    
  svgGroup.append("svg:circle")
      .attr("r", fcSize)
      .style("fill", color);

  svgGroup.append("svg:text")	  
  .attr("x", function(d) { return -(d.name.length * 0.5 * 5); })  
  .attr("font-size", "11px") 
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

function tick() {
  link.attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

  node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; }); 
}

// Color leaf nodes orange, and packages white or blue.
function color(d) {
  return d._children ? "#3182bd" : d.children ? "#fd8d3c" : "#c6dbef";
}

// Toggle children on click.
function click(d) {
//TODO Open grid navigation panel on click	
	if(d.url)
		window.location = d.url;
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