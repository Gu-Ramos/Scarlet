return function(scarlet)

local lm = love.mouse
local default_flags = {
    children = {},
    visible = true, awake = true,
    focus = nil
}

local UI = scarlet.utils.class("UI Wrapper")
UI:implement(default_flags)



---- SECTION: INIT ----

function UI:init(children, flags)
    if children then self:addChildren(children); end
    if flags then self:setFlags(flags); end
end


function UI:setFlags(flags)
    if flags.focus then
        self:setFocus(flags.focus)
        flags.focus = nil
    end
    for k, v in pairs(flags) do
        self[k] = v
    end
end


function UI:addChild(child)
    if not self:findChild(child.__id, true) then
        self.children[child.__id] = child
        child.has_focus = false
    end
end


function UI:addChildren(children)
    for _, c in pairs(children) do
        self:addChild(c)
    end
end


function UI:findChild(child, by_id, recursive)
    if by_id then
        if self.children[child] then
            return self.children[child]
        elseif recursive then
            for _, c in pairs(self.children) do
                local found = c:findChild(child, by_id, recursive)
                if found then return found; end
            end
        end
    else
        for _, c in pairs(self.children) do
            if c == child then
                return c
            elseif recursive then
                local found = c:findChild(child, by_id, recursive)
                if found then return found; end
            end
        end
    end
    return nil
end


function UI:setFocus(focus)
    if self.focus then self.focus.has_focus = false; end
    if focus then focus.has_focus = true; end
    self.focus = focus
end


---- SECTION: CHECKS ----

function UI:checkPointFocus(px, py)
    -- checks if some of its children want some focus
    for _, c in pairs(self.children) do
        if c.awake and c.visible then
            local focus = c:checkPointFocus(px, py)
            if focus then return focus; end
        end
    end
    return nil
end


---- SECTION: UPDATE

function UI:update(dt)
    if self.focus and not (self.focus.awake and self.focus.visible) then self:setFocus(nil); end

    if self.on_update then self:on_update(dt); end
    for _, c in pairs(self.children) do
        if c.visible and c.awake then c:update(dt); end
    end
end


function UI:keypressed(k, scancode, isrepeat)
    if self.on_keypressed then self:on_keypressed(k, scancode, isrepeat); end
    if self.focus then self.focus:keypressed(k, scancode, isrepeat); end
end


function UI:keyreleased(k, scancode, isrepeat)
    if self.on_keyreleased then self:on_keyreleased(k, scancode, isrepeat); end
    if self.focus then self.focus:keyreleased(k, scancode, isrepeat); end
end


function UI:mousepressed(x, y, button, istouch, presses)
    local focus = self:checkPointFocus(x, y)
    self:setFocus(focus)

    if self.on_mousepressed then self:on_mousepressed(x, y, button, istouch, presses); end
    if self.focus then self.focus:mousepressed(x, y, button, istouch, presses); end
end


function UI:mousereleased(x, y, button, istouch, presses)
    if self.on_mousereleased then self:on_mousereleased(x, y, button, istouch, presses); end
    if self.focus then self.focus:mousereleased(x, y, button, istouch, presses); end
end


function UI:mousemoved(x, y, dx, dy, istouch)
    if self.on_mousemoved then self:on_mousemoved(x, y, dx, dy, istouch); end
    for _, c in pairs(self.children) do
        if c.visible and c.awake then c:mousemoved(x, y, dx, dy, istouch); end
    end
end


function UI:wheelmoved(x, y)
    local mx, my = lm.getPosition()

    if self.on_wheelmoved then self:on_wheelmoved(x, y, mx, my); end
    for _, c in pairs(self.children) do
        if c.visible and c.awake then c:wheelmoved(x, y, mx, my); end
    end
end


function UI:textinput(text)
    if self.on_textinput then self:on_textinput(text); end
    if self.focus then self.focus:textinput(text); end
end


---- SECTION: DRAW ----

function UI:getGlobalOffsetPosition() return 0, 0; end

function UI:draw()
    for _, c in pairs(self.children) do
        if c.visible then c:draw(); end
    end
end

return UI
end