
local textShader = love.graphics.newShader[[
    // blur shader
    uniform float t;
    extern vec2 size;
    extern int samples; // 
    extern float quality; // lower = smaller glow, better quality
		extern float intensity;
    extern float scale;
    extern vec2 imageSize;
    extern float phase;


    vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
    {
        vec4 source = Texel(tex, tc);
        vec4 sum = vec4(0.0);
        int diff = (samples - 1) / 2;
        vec2 sizeFactor = vec2(1.0) / size * quality * t;
        
        for (int x = -diff; x <= diff; x++)
        {
            for (int y = -diff; y <= diff; y++)
            {
                vec2 offset = vec2(x, y) * sizeFactor;
                sum += Texel(tex, tc + offset);
            }
        }
        vec4 result = ((sum / (samples * samples)) + source) * colour;
        result.a = floor(result.a);
        return result;
    }
        
    
    vec4 position(mat4 transform_projection, vec4 vertex_position) {
        vertex_position.x = vertex_position.x + sin(vertex_position.y * imageSize.y * (scale / imageSize.x) + phase) * intensity;
        vertex_position.y = vertex_position.y + sin(vertex_position.x * imageSize.x * (scale / imageSize.y) + phase) * intensity;
        return transform_projection * vertex_position;
    }
]]

textShader:send("phase", 0.0)
textShader:send("size", {100.0,100.0})
textShader:send("samples", 5)
textShader:send("quality", 10.0)
textShader:send("intensity", 1.0)
textShader:send("scale", 0.1)


local backgroundShader = love.graphics.newShader[[
    #ifdef GL_ES
    precision mediump float;
    #endif

    extern int stage;
    uniform vec2 u_resolution;

    extern float intensity;
    extern float scale;
    extern float phase;

    float rand(vec2 co) {
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) 
    {
        vec2 st = (2. * screen_coords-  u_resolution.xy) / u_resolution.y;
        float radius = length(st * 50.);
        //float rings = smoothstep(.1, .25, sin(phase + radius)) * .45;
        float rings = smoothstep(.1, .25, sin(phase + radius)) * .3;
       
        if (stage==1)
            return vec4(0, 0, rings, 1.);
        else if (stage==2)
            return vec4(rings, 0, 0, 1.);
        else
            return vec4(rings, 0, 0.2, 1.);
    }
        
    vec4 position(mat4 transform_projection, vec4 vertex_position) {
        vertex_position.x = vertex_position.x + sin(vertex_position.y * u_resolution.y * (scale / u_resolution.x) + phase) * intensity;
        vertex_position.y = vertex_position.y + sin(vertex_position.x * u_resolution.x * (scale / u_resolution.y) + phase) * intensity;
        return transform_projection * vertex_position;
    }

]]

backgroundShader:send("stage", 1)
backgroundShader:send("phase", 0.0)
backgroundShader:send("intensity", 5.0)
backgroundShader:send("scale", 2)


local vignetteShader = love.graphics.newShader[[

    uniform vec2 res;
    uniform vec2 ship;
	uniform float radius;

    vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
    {
        return vec4(0,0,0,1-(
        max(
            max(
                max(
                    max(
                        (1-distance(sc, ship)/res*radius),
                        (1-distance(sc, vec2(ship.x+res.x,ship.y))/res*radius)
                    ),
                    max(
                        (1-distance(sc, vec2(ship.x-res.x,ship.y))/res*radius),
                        (1-distance(sc, vec2(ship.x,ship.y+res.y))/res*radius)
                    )
                ),
                max(
                    max(
                        (1-distance(sc, vec2(ship.x,ship.y-res.y))/res*radius),
                        (1-distance(sc, ship+res)/res*radius)
                    ),
                    max(
                        (1-distance(sc, ship-res)/res*radius),
                        (1-distance(sc, vec2(ship.x+res.x,ship.y-res.y))/res*radius)
                    )
                )
            ),
            (1-distance(sc, vec2(ship.x-res.x,ship.y+res.y))/res*radius)
        )
        ));
    }

]]

tt = 0
ttt = 0
function updateShader(dt)
    if gameTimer < 100 then
        backgroundShader:send("stage", 1)
    else
        backgroundShader:send("stage", 2)
    end
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    backgroundShader:send("u_resolution", {w, h})
    vignetteShader:send("res", {w, h})
	vignetteShader:send("ship", {shipX, shipY})
    t = love.math.random(0.1,2.0)
    textShader:send("t", t)
    tt = tt + 40 * dt
    ttt = ttt + 5 * dt
    textShader:send("phase", tt)
    backgroundShader:send("phase", ttt)
    textShader:send("imageSize" , {w, h})
end

function textShaderStart()
    love.graphics.setShader(textShader)
end

function textShaderEnd()
    love.graphics.setShader()
end

function backgroundShaderStart()
    love.graphics.setShader(backgroundShader)
end

function backgroundShaderEnd()
    love.graphics.setShader()
end

function vignetteShaderStart()
    love.graphics.setShader(vignetteShader)
end
