#data
route = {
	type: "LineString",
	coordinates: [[126.534967, 45.80377499999999],
							  [115.8574693, -31.9530044],
								[153.0234489, -27.4710107],
								[ -87.6297982, 41.8781136],
								[-122.4194155, 37.7749295],
								[144.96328, -37.814107]
								]
}

#DOM elements
width = 1400
height = 800
xRotate = d3.scale.linear()
    				.domain([0, width])
    				.range([-180, 180])
yRotate = d3.scale.linear()
				    .domain([0, height])
				    .range([90, -90])

svg = d3.select("body").append("svg")
	   	 .attr(width: width)
	   	 .attr(height: height)

#Set up map
projection = d3.geo.orthographic()
							.scale(300)
							.center([100, 9])
							.translate([width / 2, height / 2])

path = d3.geo.path()
				.projection projection

#Draw map
d3.json "world-110m.json", (e, world) ->
	svg.append("path")
    .datum(topojson.feature(world, world.objects.land))
    .attr(class: "land")
    .attr(d: path)

#Add points
d3.json "places.json", (e, places) ->
	svg.selectAll("circle")
		 .data(places)
		.enter()
		 .append("circle")
		 .attr(class: "point")
		 .attr(cx: (d) => return projection([d.coords[0], d.coords[1]])[0])
		 .attr(cy: (d) => return projection([d.coords[0], d.coords[1]])[1])
		 .attr(r: 5 )

#Rotate globe
svg.on "mousemove", () -> 
  p = d3.mouse(this)
  projection.rotate([xRotate(p[0]), yRotate(p[1])])
  svg.selectAll("path").attr(d: path)
  svg.selectAll("circle")
  	 .attr(cx: (d) => return projection([d.coords[0], d.coords[1]])[0])
		 .attr(cy: (d) => return projection([d.coords[0], d.coords[1]])[1])

#Draw lines
svg.append("path")
    .datum(route)
    .attr("class", "route")
    .attr("d", path);