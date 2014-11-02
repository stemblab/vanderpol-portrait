#!vanilla

class Figure # Namespace for globals

    @xMax = 4 # horizontal plot limit
    @yMax = 4 # vertical plot limit
    @margin = {top: 65, right: 65, bottom: 65, left: 65}
    @width = 450 - @margin.left - @margin.top
    @height = 450 - @margin.left - @margin.top
    @xScale = d3.scale.linear() # sim units -> screen units
        .domain([-@xMax, @xMax])
        .range([0, @width])
    @yScale = d3.scale.linear() # sim units -> screen units
        .domain([-@yMax, @yMax])
        .range([@height, 0])

class Canvas

    constructor: (@spec) ->

        @canvas = $(@spec.id) 
        @canvas[0].width = @spec.width
        @canvas[0].height = @spec.height
        @ctx = @canvas[0].getContext('2d')
        
    clear: -> @ctx.clearRect(0, 0, @spec.width, @spec.height)

    square: (pos, size, color) ->
        @ctx.fillStyle = color
        @ctx.fillRect(pos.x, pos.y, size, size)


class Checkbox

    constructor: (@id, @change) ->
        @checkbox = $ "##{id}"
        @checkbox.unbind()  # needed to clear event handlers
        @checkbox.on "change", =>
            val = @val()
            @change val
        
    val: -> @checkbox.is(":checked")


class VdPSim

    constructor: ->

        @canvas = new Canvas
            id: "#VdP-vector-field"
            width: Figure.width
            height: Figure.height

        @oscillator = new $blab.Oscillator "VdP-oscillator",
            marker0color: "black"
            marker1color: "transparent"
            guide0color: "transparent"
            guide1color: "transparent"
            margin: Figure.margin
            width: Figure.width
            height: Figure.height
            xMax: 4
            yMax: 4

        @vectorField = new $blab.Emitter @canvas, 1, Figure

        @markerPoint = new $blab.VfPoint

        @persist = new Checkbox "persist" , (v) =>  @.checked = v

        $("#mu-slider").on "change", => @updateMu()
        @updateMu()

        d3.selectAll("#VdP-stop-button").on "click", => @stop()
        d3.selectAll("#VdP-start-button").on "click", => @start()


    updateMu: ->
        k = parseFloat(d3.select("#mu-slider").property("value"))
        @markerPoint.mu = k
        @vectorField.mu = k
        @vectorField.updateMu() 
        d3.select("#mu-value").html(k)
        
    snapshot1: ->
        @canvas.clear() if not @.checked
        @vectorField.directParticles()
        @drawMarker()

    drawMarker: ->
        @markerPoint.move()
        @oscillator.moveMarker(@oscillator.marker0,
            @xScale(@markerPoint.x),
            @yScale(@markerPoint.y)
        )

    animate: ->
        @timer1 = setInterval (=> @snapshot1()), 20

    stop: ->
        clearInterval @timer1
        @timer1 = null

    start: ->
        setTimeout (=> @animate() ), 20

    xScale: Figure.xScale

    yScale: Figure.yScale

new VdPSim

