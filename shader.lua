
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
        return ((sum / (samples * samples)) + source) * colour;
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
textShader:send("imageSize" , {1280, 720})


tt = 0
function updateShader(dt)
    t = love.math.random(0.1,2.0)
    textShader:send("t", t)
    tt = tt + 40 * dt
    textShader:send("phase", tt)
end

function textShaderStart()
    love.graphics.setShader(textShader)
end

function textShaderEnd()
    love.graphics.setShader()
end