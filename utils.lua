function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end


function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
  return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
end

function directionTo(x1, y1, x2, y2)
  local dx = x1- x2
  local dy = y1- y2
  speed = math.sqrt(dx^2+dy^2)
  dx,dy = dx/speed, dy/speed
  return dx, dy
end


function clamp(x, min, max)
  if x < min then
    x = min
  elseif x > max then
    x = max
  end
  return x
end