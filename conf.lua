function love.conf(t)

  t.title = 'Origin'
  t.author = 'Evan Hahn'

  t.screen.width = 800
  t.screen.height = 800
  t.screen.fullscreen = false

  t.modules.joystick = false
  t.modules.audio = true
  t.modules.keyboard = true
  t.modules.event = true
  t.modules.image = false
  t.modules.graphics = true
  t.modules.timer = true
  t.modules.mouse = true
  t.modules.sound = true
  t.modules.physics = false

end
