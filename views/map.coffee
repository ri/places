#set up globe
globe = (attrs) ->
	my = Object.create(attrs)
	height = my.height || 1000
	width = my.width || 1000
	points = my.points || []
	svg = my.svg
	projection = d3.geo.orthographic()
	path = d3.geo.path()
	xRotate = d3.scale.linear()
	yRotate = d3.scale.linear()

	my.init = () ->
		xRotate = d3.scale.linear()
								.domain([0, width])
								.range([-180, 180])
		yRotate = d3.scale.linear()
								.domain([0, height])
								.range([90, -90])

		projection.scale(300).center([100, 9]).translate([width / 2, height / 2]).clipAngle(90)

		#Set up map
		path.projection projection

		#Draw map
		d3.json "world-110m.json", (e, world) ->
			svg.append("path")
				.datum(topojson.feature(world, world.objects.land))
				.attr(class: "land")
				.attr(d: path)

		d3.json points, (e, data) ->
			points = data || []
			
			if points
				my.drawPoints()
				my.drawLines()

	my.drawPoints = () ->
		svg.selectAll("circle")
			 .data(points)
			.enter()
			 .append("circle")
			 .attr(class: "point")
			 .attr(cx: (d) => projection([d.coords[0], d.coords[1]])[0])
			 .attr(cy: (d) => projection([d.coords[0], d.coords[1]])[1])
			 .attr(r: 5 )

	my.drawLines = () ->
		route = 
			type: "LineString"
			coordinates: points.map((point) -> point.coords)

		svg.append("path")
		 .datum(route)
		 .attr("class", "route")
		 .attr("d", path)

	my.rotate = (x, y) ->
		projection.rotate([xRotate(x), yRotate(y)])
		svg.selectAll("path").attr(d: path)
		svg.selectAll("circle")
			.attr(cx: (d) => projection([d.coords[0], d.coords[1]])[0])
			.attr(cy: (d) => projection([d.coords[0], d.coords[1]])[1])

	my.addPoint = (lat, lon) ->
		obj = {coords: [lon, lat]}
		console.log points
		points.push obj

	my


width = 1400
height = 800

svg = d3.select("body").append("svg")
			 .attr(width: width)
			 .attr(height: height)

myGlobe = globe({width: width, height: height, svg: svg})
myGlobe.init()

#Google Maps code
input = document.getElementById('gmaps-search');
autocomplete = new google.maps.places.Autocomplete(input);

#Rotate globe
svg.on "mousemove", () -> 
	p = d3.mouse(this)
	myGlobe.rotate(p[0], p[1])

#Submit Google form
d3.select('#location-submit').on "click", () ->
	place = autocomplete.getPlace();
	lat = place.geometry.location.lat()
	lon = place.geometry.location.lng()

	myGlobe.addPoint(lat, lon)
	myGlobe.drawPoints()
	myGlobe.drawLines()

