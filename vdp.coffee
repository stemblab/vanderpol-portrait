#!vanilla

# Global stuff

{rk, ode} = $blab.ode # Import ODE solver

f = (t, v, mu) -> # VdP equation
    [
        v[1]
        mu*(1-v[0]*v[0])*v[1]-v[0]
    ]

# Classes

class Vector

    z = -> new Vector

    constructor: (@x=0, @y=0) ->
        
    add: (v=z()) ->
        @x += v.x
        @y += v.y
        this
    
    mag: () -> Math.sqrt(@x*@x + @y*@y)
        
    ang: () -> Math.atan2(@y, @x)
        
    polar: (m, a) ->
        @x = m*Math.cos(a)
        @y = m*Math.sin(a)
        this

class $blab.VfPoint # vector field point

    #width  = $blab.Figure.width
    #height = $blab.Figure.height
    
    constructor: (@x=1, @y=1, @mu=1, @figure) -> # See state function f
        @vel = new Vector 0, 0 # Velocity
        @d = 0 # Distance

    updateVelocity: ->
        vel = f(0, [@x, @y], @mu) # Global state function
        @vel.x = vel[0]
        @vel.y = vel[1]

    move: ->
        @updateVelocity()
        [@x, @y] = ode(rk[1], f, [0, 0.02], [@x, @y], @mu)[1]
        @d += @vel.mag()

    visible: -> (-@figure.xMax <= @x <= @figure.xMax) and
        (-@figure.yMax <= @y <= @figure.yMax) and
        @d < 200
    
class $blab.Particle extends $blab.VfPoint

    constructor: (@canvas, x, y, mu, @figure) ->
        super x, y, mu, @figure

        @size = 2
        @color = ["red", "green", "blue"][Math.floor(3*Math.random())]

    draw: ->
        pos = {x:@figure.xScale(@x), y:@figure.yScale(@y)}
        @canvas.square pos, @size, @color

class $blab.Emitter
    
    maxParticles: 500
    rate: 3
    
    constructor: (@canvas, @mu=1, @figure)->
        @particles = []

    directParticles: ->
        unless @particles.length > @maxParticles
            @particles.push(@newParticles()) for [1..@rate]
            
        @particles = @particles.filter (p) => p.visible()
        for particle in @particles
            particle.move()
            particle.draw()

    newParticles: ->
        u = @figure.xMax*(2*Math.random()-1)
        v = @figure.yMax*(2*Math.random()-1)
        position = new Vector u, v
        new $blab.Particle @canvas, position.x, position.y, @mu, @figure  

    updateMu: ->
        for particle in @particles
            particle.mu = @mu

    

