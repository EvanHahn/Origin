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

  pi = math.pi
  twopi = math.pi * 2

  heart = {
    health = 1
  }

  shield = {
    holes = 3,
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

function particle_update(particle, i, dt)

  assert(particle.direction >= 0)
  assert(particle.direction < twopi)

  particle.distance = particle.distance - (PARTICLE_SPEED * dt)

  local destroy_me = false

  if particle.distance < 0 then
    heart.health = heart.health - PARTICLE_DAMAGE
    destroy_me = true
  elseif math.abs(particle.distance - shield.radius) < PARTICLE_RADIUS then

    local normalized = particle.direction + shield.direction
    while normalized < 0 do
      normalized = twopi + normalized
    end
    normalized = normalized % twopi
    assert(normalized >= 0)
    assert(normalized < twopi)

    normalized = normalized % (twopi / shield.holes)

    destroy_me = normalized > (twopi * shield.hole_percentage / shield.holes)

  end

  if destroy_me then table.remove(particles, i) end

end

function love.update(dt)

  local now = os.clock()

  if love.keyboard.isDown('left') then
    shield.direction = shield.direction - .08
  elseif love.keyboard.isDown('right') then
    shield.direction = shield.direction + .08
  end

  while shield.direction < 0 do
    shield.direction = twopi + shield.direction
  end
  shield.direction = shield.direction % twopi

  assert(shield.direction >= 0)
  assert(shield.direction < twopi)

  if #particles < now then
    table.insert(particles, {
      direction = math.random(0, twopi),
      distance = .75
    })
  end

  for i, particle in ipairs(particles) do
    particle_update(particle, i, dt)
  end

  if heart.health <= 0 then
    heart.health = 0
  end

end

function love.draw()

  local now = os.clock()

  local solid_size = twopi * (1 - shield.hole_percentage) / shield.holes
  local hole_size = twopi * shield.hole_percentage / shield.holes
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
  love.graphics.arc('fill', center_x, center_y, heart_radius, 0, twopi * heart.health)

end
