function love.load()

  COLORS = {
    background = {42, 39, 50},
    shield = {83, 81, 82},
    particle = {246, 250, 208},
    heart = {124, 56, 65}
  }

  PARTICLE_RADIUS = .01 -- as % of screen size
  PARTICLE_SPEED = .2 -- as % of screen size
  PARTICLE_DAMAGE = .05

  heart = {
    health = 1
  }

  shield = {
    holes = 2,
    hole_percentage = .5, -- % of total holes, not per hole
    radius = .2, -- as % of screen size
    direction = 0
  }

  particles = {}

  screen_size = 400 -- TODO
  center_x = screen_size / 2
  center_y = screen_size / 2

  love.graphics.setBackgroundColor(COLORS.background)

end

function love.update(dt)

  local now = os.clock()

  if love.keyboard.isDown('left') then
    shield.direction = shield.direction - .08
  elseif love.keyboard.isDown('right') then
    shield.direction = shield.direction + .08
  end

  -- TODO: make some kind of function for this
  table.insert(particles, {
    direction = math.random(0, math.pi * 2),
    distance = .75
  })

  for i, particle in ipairs(particles) do
    particle.distance = particle.distance - (PARTICLE_SPEED * dt)
    local destroy_me = false
    if particle.distance < 0 then
      heart.health = heart.health - PARTICLE_DAMAGE
      destroy_me = true
    elseif particle.distance < shield.radius then
      -- TODO: am i even in the shield area?
      -- TODO: destroy me if the shield hits me
    end
    if destroy_me then table.remove(particles, i) end
  end

  if heart.health <= 0 then
    -- TODO: you died
  end

end

function love.draw()

  local now = os.clock()

  local solid_size = (math.pi * 2) * (1 - shield.hole_percentage) / shield.holes
  local hole_size = (math.pi * 2) * shield.hole_percentage / shield.holes
  local shield_radius = shield.radius * screen_size
  love.graphics.setColor(COLORS.shield)
  for i = 0, shield.holes, 1 do
    local start_angle = shield.direction + (i * (solid_size + hole_size))
    local end_angle = start_angle + solid_size
    love.graphics.arc('fill', center_x, center_y, shield_radius, start_angle, end_angle)
  end

  -- "cancel out" the filled shield
  love.graphics.setColor(COLORS.background)
  love.graphics.circle('fill', center_x, center_y, shield_radius * .9)

  local particle_size = PARTICLE_RADIUS * screen_size
  love.graphics.setColor(COLORS.particle)
  for i, particle in ipairs(particles) do
    local particle_x = center_x + (math.cos(particle.direction) * (particle.distance * screen_size))
    local particle_y = center_y - (math.sin(particle.direction) * (particle.distance * screen_size))
    love.graphics.circle('fill', particle_x, particle_y, particle_size)
  end

  local heart_radius = math.abs(math.sin(now * 20)) * (screen_size * .02) + (screen_size * .02)
  love.graphics.setColor(COLORS.heart)
  love.graphics.arc('fill', center_x, center_y, heart_radius, 0, math.pi * 2 * heart.health)

end
