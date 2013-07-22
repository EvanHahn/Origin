function love.load()

  COLORS = {
    background = {20, 20, 80},
    shield = {255, 108, 255},
    heart = {255, 0, 40},
    outline = {0, 0, 0},
  }

  SOUNDS = {
    music = love.audio.newSource('assets/DST-Blam.mp3'),
    explosion = love.audio.newSource('assets/explosion.ogg', 'static'),
    shoot = love.audio.newSource('assets/laser-3.wav', 'static'),
    pop = love.audio.newSource('assets/laserd.wav', 'static')
  }

  PARTICLE_RADIUS = .03 -- as % of screen size
  PARTICLE_SPEED = .2 -- as % of screen size
  PARTICLE_DAMAGE = .05

  pi = math.pi
  twopi = math.pi * 2

  heart = {
    health = 1
  }

  shield = {
    holes = 2,
    hole_percentage = .5, -- % of total holes, not per hole
    radius = .25, -- as % of screen size
    direction = 0
  }

  particles = {}

  screen_size = 800 -- TODO
  center_x = screen_size / 2
  center_y = screen_size / 2

  love.graphics.setBackgroundColor(COLORS.background)

  SOUNDS.music:setLooping(true)
  love.audio.play(SOUNDS.music)

end

function particle_update(particle, i, dt)

  assert(particle.direction >= 0)
  assert(particle.direction < twopi)

  particle.distance = particle.distance - (PARTICLE_SPEED * dt)
  particle.direction = (particle.direction - (1 * dt)) % twopi

  local destroy_me = false

  if particle.distance < 0 then
    heart.health = heart.health - PARTICLE_DAMAGE
    destroy_me = true
    love.audio.stop(SOUNDS.explosion)
    love.audio.play(SOUNDS.explosion)

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
    love.audio.stop(SOUNDS.pop)
    love.audio.play(SOUNDS.pop)

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
      direction = math.random() * twopi,
      distance = .75
    })
    love.audio.stop(SOUNDS.shoot)
    love.audio.play(SOUNDS.shoot)
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
  for i = 0, shield.holes, 1 do
    local start_angle = shield.direction + (i * (solid_size + hole_size))
    local end_angle = start_angle + solid_size
    love.graphics.setColor(COLORS.outline)
    love.graphics.arc('fill', center_x, center_y, shield_radius * 1.1, start_angle - .1, end_angle + .1)
    love.graphics.setColor(COLORS.shield)
    love.graphics.arc('fill', center_x, center_y, shield_radius, start_angle, end_angle)
  end

  -- "cancel out" the filled shield
  love.graphics.setColor(COLORS.background)
  love.graphics.circle('fill', center_x, center_y, shield_radius * .8)

  local heart_radius = math.abs(math.sin(now * 20)) * (screen_size * .02) + (screen_size * .02)
  love.graphics.setColor(COLORS.outline)
  love.graphics.arc('fill', center_x, center_y, heart_radius * 1.3, 0, twopi * heart.health, heart.health * 5 + 5)
  love.graphics.setColor(COLORS.heart)
  love.graphics.arc('fill', center_x, center_y, heart_radius, 0, twopi * heart.health, heart.health * 5 + 5)

  local particle_size = PARTICLE_RADIUS * screen_size
  for i, particle in ipairs(particles) do
    local particle_x = center_x + (math.cos(particle.direction) * (particle.distance * screen_size))
    local particle_y = center_y - (math.sin(particle.direction) * (particle.distance * screen_size))
    love.graphics.setColor(COLORS.outline)
    love.graphics.circle('fill', particle_x, particle_y, particle_size * 1.3, 50)
    love.graphics.setColor(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    love.graphics.circle('fill', particle_x, particle_y, particle_size, 50)
  end

end
