#!vanilla

class $blab.d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()
        
    append: (obj) -> @obj.append obj
    
    initAxes: -> 

        
class $blab.Oscillator extends $blab.d3Object
        
    constructor: (X, @spec) ->
        super X

        # Clear any previous event handlers.
        @obj.on("click", null)  
        d3.behavior.drag().on("drag", null)
       
        @obj.attr("width", @spec.width + @spec.margin.left + @spec.margin.right)
        @obj.attr("height", @spec.height + @spec.margin.top + @spec.margin.bottom)
        @obj.attr("id", "oscillator")

        @obj.append("g") # x axis
            .attr("class", "axis")
            .attr("transform", "translate(#{@spec.margin.left}, #{@spec.margin.top+@spec.height+10})")
            .call(@xAxis) 

        @obj.append("g") # y axis
            .attr("class", "axis")
            .attr("transform","translate(#{@spec.margin.left-10}, #{@spec.margin.top})")
            .call(@yAxis) 

        @plot = @obj.append("g") # Plot area
            .attr("id", "plot")
            .attr("transform", "translate(#{@spec.margin.left},#{@spec.margin.top})")

        @limitCircle = @plot.append("circle")
            .attr("cx", @xScale 0)
            .attr("cy", @yScale 0)
            .attr("r", @xScale(2)-@xScale(0))
            .style("fill", "transparent")
            .style("stroke", "ccc")

        @guide0 = @radialLine(@spec.guide0color)
        @guide1 = @radialLine(@spec.guide1color)

        @marker0 = @marker(@spec.marker0color, @guide0)
        @marker1 = @marker(@spec.marker1color, @guide1)

        @moveMarker(@marker0, -1000, -1000) # initially hide off-screen
        @moveMarker(@marker1, -1000, -1000)

    marker: (color, guide) ->
        m = @plot.append("circle")
            .attr("r",10)
            .style("fill", color)
            .style("stroke", color)
            .style("stroke-width","1")
            .call(
                d3.behavior
                .drag()
                .origin(=>
                    x:m.attr("cx")
                    y:m.attr("cy")
                )
                .on("drag", => @dragMarker(m, d3.event.x, d3.event.y, guide))
            )
        
    radialLine: (color) ->
        @plot.append('line')
            .attr("x1", @xScale 0)
            .attr("y1", @yScale 0)
            .style("stroke", color)
            .style("stroke-width","1")
        
    dragMarker: (marker, u, v, guide) ->
        marker.attr("cx", u)
        marker.attr("cy", v)
        phi = Math.atan2(@yScale.invert(v), @xScale.invert(u))
        guide.attr("x2", @xScale $blab.Figure.xMax*cos(phi))
        guide.attr("y2", @yScale $blab.Figure.xMax*sin(phi))

    moveMarker: (marker, u, v) ->
        marker.attr("cx", u)
        marker.attr("cy", v)

    moveGuide: (guide, phi) ->
        guide.attr("x2", @xScale $blab.Figure.xMax*cos(phi))
        guide.attr("y2", @yScale $blab.Figure.yMax*sin(phi))
         
    initAxes: ->
        @xScale = d3.scale.linear() # sim units -> screen units
            .domain([-@spec.xMax, @spec.xMax])
            .range([0, @spec.width])
        @yScale = d3.scale.linear() # sim units -> screen units
            .domain([-@spec.yMax, @spec.yMax])
            .range([@spec.height, 0])

        @xAxis = d3.svg.axis()
            .scale(@xScale)
            .orient("bottom")

        @yAxis = d3.svg.axis()
            .scale(@yScale)
            .orient("left")

