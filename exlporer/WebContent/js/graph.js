var node,
    link,
    root,
	divName,
	force,
	currentWidth,
	currentHeight,
	vis;

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
		
	currentWidth = $(document).width();
    currentHeight = $(document).height();
	
force = d3.layout.force()
    .on("tick", tick)
    .charge(function(d) { return d._children ? -d.size / 100 : -30; })
    .linkDistance(function(d) { return d.target._children ? 80 : 30; })
    //.charge(function(d) { return d._children ? -Math.sqrt(d.size)/100 : -Math.sqrt(d.size);})
    //.linkDistance(function(d) { return d.target._children ? 180 : 30; })
    .size([currentWidth, currentHeight - 160]);

vis = d3.select("#" + divName).append("svg:svg")
    .attr("width", currentWidth)
    .attr("height", currentHeight)
    .attr("pointer-events", "all");
  //Zoom behavior breaks the node draging functionnality... so we ditch the zoom for the moment
  /*.append('svg:g')
    .call(d3.behavior.zoom().on("zoom", zoomt))
  .append('svg:g');

function zoomt() {
  vis.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
}//*/
//root = flare;
root.fixed = true;
root.x = currentWidth / 2;
root.y = currentHeight / 2 - 80;
updateGraph();
}
	  
function updateGraph() {

  var nodes = flatten(root),
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
  node = vis.selectAll("circle.node")
      .data(nodes, function(d) { return d.id; })
      .style("fill", color)	  
      .call(force.drag);

  node.transition()
      .attr("r", function(d) { return d.children ? 6.5 : Math.sqrt(d.size) / 10;  }); 
  
  // Enter any new nodes.
  node.enter().append("svg:circle")
      .attr("class", "node")
      .attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; })
      .attr("r", function(d) { return d.children ? 6.5 : Math.sqrt(d.size) / 10; })
      .style("fill", color)
      .on("click", click)
	  .on("contextmenu", rightclick)
      .call(force.drag);
	  //.on('mouseover',  function(d, i) { 
	  
 $('svg circle').tipsy({ 
        gravity: 'w', 
        html: true, 
        title: function() {
          var d = this.__data__;//, c = colors(d.i);
          return d.name;//'Hi there! My color is <span style="color:' + c + '">' + c + '</span>'; 
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

  node.attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; });
}

// Color leaf nodes orange, and packages white or blue.
function color(d) {
  return d._children ? "#3182bd" : d.children ? "#c6dbef" : "#fd8d3c";
}

// Toggle children on click.
function click(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
  updateGraph();
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
//function(data, index) {
     //handle right click
	 
     //stop showing browser menu
     d3.event.preventDefault();
}

// Returns a list of all nodes under the root.
function flatten(root) {
  var nodes = [], i = 0;

  function recurse(node) {
    if (node.children) node.size = node.children.reduce(function(p, v) { return p + recurse(v); }, 0);
    if (!node.id) node.id = ++i;
    nodes.push(node);
    return node.size;
  }

  root.size = recurse(root);
  return nodes;
}
//On Window Resize, recompute the graph
$(window).resize(function() {
	if(currentWidth != $(document).width() || currentHeight != $(document).height())
	{		
		if(root)
		{
			$("#" + divName).empty();
			CreateGraph(root, divName);
		}
	}	  
});