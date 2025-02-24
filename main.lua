local lg = love.graphics

function love.load()
    scarlet = require("scarlet")

    main_container_presses = 0
    button_presses = 0
    
    UI = scarlet.ui_wrapper()
    scarlet.utils.default_theme.corner_radius = 10

    main_container = scarlet.container("main", 100, 100, 600, 400, {anchor="top-left"})
    button = scarlet.button("button", 200, 200, 200, 100, {anchor="center", align="center"})
    label = scarlet.label("label", 300, 300, 200, 50, {text="I'm a Label!", anchor="top", align="top"})
    checkbox = scarlet.checkbox("checkbox", 400, 400, 200, 50, {anchor="bottom", align="bottom", enabled_text="checked", disabled_text="unchecked"})

    main_container:setParent(UI)
    button:setParent(main_container)
    label:setParent(main_container)
    checkbox:setParent(main_container)

    button.text = "BOTÃO"
    main_container.draw_bg = true
    main_container:setThemeOverrides( {normal = {bg_color = {0.2,0.2,0.2}}} )

    function main_container:on_press() main_container_presses = main_container_presses + 1; end
    function button:on_press() button_presses = button_presses+ 1; end
end


function love.update(dt)
    UI:update(dt)
end


local lts = love.timer.getFPS
function love.draw()
    lg.print(tostring(lts()), 10, 10)
    lg.print(tostring(collectgarbage("count")), 10, 25)
    -- lg.print("main presses: "..tostring(main_container_presses), 10,10)
    -- lg.print("button_presses: " .. tostring(button_presses), 10,25)
    UI:draw()
end

function love.keypressed(k)
    if k == "space" then
        scarlet.debug.draw_boundaries = not scarlet.debug.draw_boundaries 
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    UI:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    UI:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    UI:mousemoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(x, y)
    UI:wheelmoved(x, y)
end