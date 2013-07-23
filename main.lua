timer = require('vendor/timer')

function love.load()

  COLORS = {
    background = {20, 20, 80},
    shield = {255, 108, 255},
    heart = {255, 0, 40},
    outline = {0, 0, 0},
    white = {255, 255, 255}
  }

  SOUNDS = {
    music = love.audio.newSource('assets/DST-Blam.mp3'),
    explosion = love.audio.newSource('assets/explosion.ogg', 'static'),
    shoot = love.audio.newSource('assets/laser-3.wav', 'static'),
    pop = love.audio.newSource('assets/laserd.wav', 'static'),
    powerup = love.audio.newSource('assets/alarm.wav', 'static')
  }

  PARTICLE_RADIUS = .03 -- as % of screen size
  PARTICLE_SPEED = .2 -- as % of screen size
  PARTICLE_DAMAGE = .05

  SHIELD_SPEED = 5

  pi = math.pi
  twopi = math.pi * 2

  heart = {
    health = 1
  }

  shield = {
    holes = 1,
    hole_percentage = .5, -- % of total holes, not per hole
    radius = .25, -- as % of screen size
    direction = 0
  }

  particles = {}

  points = 0

  screen_size = 800 -- TODO pull from the conf
  center_x = screen_size / 2
  center_y = screen_size / 2

  set_background(COLORS.background)

  SOUNDS.music:setLooping(true)
  love.audio.play(SOUNDS.music)

end

function set_background(c)
  background_color = c
  love.graphics.setBackgroundColor(c)
end

function particle_update(particle, i, dt)

  assert(particle.direction >= 0)
  assert(particle.direction < twopi)

  particle.distance = particle.distance - (PARTICLE_SPEED * dt)
  if particle.orbit then
    particle.direction = (particle.direction - (1 * dt)) % twopi
  end

  local destroy_me = false

  if particle.distance < 0 then
    heart.health = heart.health - PARTICLE_DAMAGE
    destroy_me = true
    love.audio.stop(SOUNDS.explosion)
    love.audio.play(SOUNDS.explosion)
    shield.hole_percentage = shield.hole_percentage - .005
    set_background(COLORS.white)
    timer.add(.1, function()
      set_background(COLORS.background)
    end)

  elseif (math.abs(particle.distance - shield.radius) < .001) and (heart.health > 0) then

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

  if destroy_me then

    table.remove(particles, i)

    if heart.health > 0 then
      points = points + 1
      if points == 5 then
        love.audio.stop(SOUNDS.powerup)
        love.audio.play(SOUNDS.powerup)
        shield.holes = 2
      end
      if points == 20 then
        love.audio.stop(SOUNDS.powerup)
        love.audio.play(SOUNDS.powerup)
        shield.holes = 3
      end
    end

  end

end

function love.update(dt)

  local now = os.clock()

  timer.update(dt)

  if love.keyboard.isDown('left') then
    shield.direction = shield.direction - (SHIELD_SPEED * dt)
  elseif love.keyboard.isDown('right') then
    shield.direction = shield.direction + (SHIELD_SPEED * dt)
  end

  while shield.direction < 0 do
    shield.direction = twopi + shield.direction
  end
  shield.direction = shield.direction % twopi

  assert(shield.direction >= 0)
  assert(shield.direction < twopi)

  if (#particles < now) and (math.random(0, 20) == 0) then
    table.insert(particles, {
      direction = math.random() * twopi,
      distance = .75,
      orbit = (math.random(0, 5) == 0)
    })
    SOUNDS.shoot:setPitch(math.random() + .5)
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

  if heart.health > 0 then

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
    love.graphics.setColor(background_color)
    love.graphics.circle('fill', center_x, center_y, shield_radius * .8)

    local heart_radius = math.abs(math.sin(now * 20)) * (screen_size * .02) + (screen_size * .02)
    love.graphics.setColor(COLORS.outline)
    love.graphics.arc('fill', center_x, center_y, heart_radius * 1.3, 0, twopi * heart.health, heart.health * 5 + 5)
    love.graphics.setColor(COLORS.heart)
    love.graphics.arc('fill', center_x, center_y, heart_radius, 0, twopi * heart.health, heart.health * 5 + 5)

  end

  local particle_size = PARTICLE_RADIUS * screen_size
  for i, particle in ipairs(particles) do
    local particle_x = center_x + (math.cos(particle.direction) * (particle.distance * screen_size))
    local particle_y = center_y - (math.sin(particle.direction) * (particle.distance * screen_size))
    love.graphics.setColor(COLORS.outline)
    love.graphics.circle('fill', particle_x, particle_y, particle_size * 1.3, 50)
    love.graphics.setColor(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    love.graphics.circle('fill', particle_x, particle_y, particle_size, 50)
  end

  if heart.health <= 0 then
    love.graphics.setColor(COLORS.heart)
    love.graphics.print('Score: ' .. points, 10, 10)
  end

end
