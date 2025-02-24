return function(scarlet)

local lg = love.graphics

local Container = scarlet.utils.class("Container")
Container:implement(scarlet.utils.default_flags)


---- SECTION: INIT ----

function Container:init(id, x,y, w,h, flags, parent, children)
    self.children = {}

    self.__id = id or self.__id
    self.x, self.y = x or 0, y or 0
    self.width, self.height = w or 0, h or 0
    
    self:setParent(parent)
    if flags.theme == nil and self.parent ~= nil then
        self:setTheme(self.parent:getTheme())
    else
        self:setTheme(scarlet.utils.default_theme)
    end
    if flags then self:setFlags(flags); end
    if children then self:addChildren(children); end
end


function Container:setFlags(flags)
    if flags.anchor ~= nil then
        self:setAnchor(flags.anchor)
        flags.anchor = nil
    end
    if flags.align ~= nil then
        self:setAlign(flags.align)
        flags.align = nil
    end
    if flags.theme ~= nil then
        self:setTheme(flags.theme)
        flags.theme = nil
    end

    for k, v in pairs(flags) do
        self[k] = v
    end
end


function Container:setTheme(theme, recursive)
    self.theme = theme
    if recursive then
        for _, c in pairs(self.children) do
            c:setTheme(theme, recursive) 
        end
    end
end


function Container:setThemeOverrides(theme_overrides, recursive)
    for k, v in pairs(theme_overrides) do
        if type(v) == "table" then
            setmetatable(v, {__index = self.theme[k]})
        end
    end
    self.theme = setmetatable(theme_overrides, {__index = self.theme})
    if recursive then
        for _, c in pairs(self.children) do
            c:setThemeOverrides(theme_overrides, recursive) 
        end
    end
end


function Container:getTheme()
    return getmetatable(self.theme).__index
end


function Container:getCurrentStateTheme()
    local t = self.theme
    return {
        corner_radius = t.corner_radius,
        border_size = t.border_size,
        shadow = t.shadow,
        text = t.text,

        bg_color = t.normal.bg_color,
        fg_color = t.normal.fg_color,
        bg_text_color = t.normal.bg_text_color,
        fg_text_color = t.normal.bg_text_color,
        accent = t.normal.accent
    }
end


function Container:setAnchor(anchor)
    self.anchor = anchor
    self._hanchor, self._vanchor = scarlet.utils.getTextAlignment(anchor)
end


function Container:setAlign(align)
    self.align = align
    self._halign, self._valign = scarlet.utils.getTextAlignment(align)
    
    if self.parent and align ~= "parent-controlled" and self.parent.__name ~= "UI Wrapper" then
        self.x = self.parent.width * self._halign + self.parent.hpadding * (self._halign - 0.5) * -2
        self.y = self.parent.height * self._valign + self.parent.vpadding * (self._valign - 0.5) * -2
    end
end


function Container:updatePosition()
    self:setAlign(self.align)
    self:setAnchor(self.anchor)
end


function Container:setPosition(x,y)
    if self.align == "free" or self.parent == nil then
        self.x, self.y = x,y
    end
end


---- SECTION: PARENTS AND CHILDS ----


function Container:setParent(parent)
    if parent ~= self.parent then
        if self.parent ~= nil then self.parent:removeChild(self); end
        self.parent = parent
        
        if parent ~= nil then
            parent:addChild(self)
        end

        self:updatePosition()
    end
end


function Container:addChild(child)
    if not self:findChild(child.__id, true) then
        self.children[child.__id] = child
        if child.parent ~= self then child:setParent(self); end
        child:updatePosition()
    end
end


function Container:addChildren(children)
    for _, c in pairs(children) do
        self:addChild(c)
    end
end


function Container:removeChild(child)
    if type(child) == "string" then child = self[child]; end
    child:setParent(nil)
    self.children[child.__id] = nil
end


function Container:findChild(child, recursive)
    child = child.__id or child
    if self.children[child] then
        return self.children[child]
    elseif recursive then
        for _, c in pairs(self.children) do
            local found = c:findChild(child, recursive)
            if found then return found; end
        end
    end
    return nil
end



---- SECTION: CHECKS ----

function Container:checkPointInBoundaries(px, py)
    local min_x, min_y = self:getGlobalOffsetPosition()
    local max_x, max_y = min_x + self.width, min_y + self.height

    return (px >= min_x and px <= max_x) and (py >= min_y and py <= max_y)
end


function Container:checkPointFocus(px, py)
    if self:checkPointInBoundaries(px, py) then
        -- checks if some of its children want some focus
        for _, c in pairs(self.children) do
            if c.awake and c.visible then
                local focus = c:checkPointFocus(px, py)
                if focus then return focus; end
            end
        end
        return self
    end
    return nil
end



---- SECTION: UPDATING ----

function Container:update(dt)
    if self.on_update then self:on_update(dt); end
    for _, c in pairs(self.children) do
        if c.visible and c.awake then c:update(dt); end
    end
end


function Container:keypressed(k, scancode, isrepeat)
    if self.on_keypressed then self:on_keypressed(k, scancode, isrepeat); end
end


function Container:keyreleased(k, scancode, isrepeat)
    if self.on_keyreleased then self:on_keyreleased(k, scancode, isrepeat); end
end


function Container:mousepressed(x, y, button, istouch, presses)
    if self.on_mousepressed then self:on_mousepressed(x, y, button, istouch, presses); end
    self:down()
end


function Container:mousereleased(x, y, button, istouch, presses)
    if self.on_mousereleased then self:on_mousereleased(x, y, button, istouch, presses); end
    if self:checkPointInBoundaries(x, y) then self:press(); end
    self:up()
end


function Container:mousemoved(x, y, dx, dy, istouch)
    if self.on_mousemoved then self:on_mousemoved(x, y, dx, dy, istouch); end
    if self:checkPointInBoundaries(x, y) and not (self:checkPointFocus(x, y) ~= self) then
        self:hover()
    else
        self:stop_hover()
    end

    for _, c in pairs(self.children) do
        if c.visible and c.awake then c:mousemoved(x, y, dx, dy, istouch); end
    end
end


function Container:wheelmoved(x, y, mx, my)
    if self.on_wheelmoved then self:on_wheelmoved(x, y, mx, my); end

    for _, c in pairs(self.children) do
        if c.visible and c.awake then c:wheelmoved(x, y, mx, my); end
    end
end


function Container:textinput(text)
    if self.on_textinput then self:on_textinput(text); end
end


function Container:hover()
    if self.on_hover then self:on_hover(); end
    self.is_hovered = true
end


function Container:stop_hover()
    if self.on_stop_hover then self:on_stop_hover(); end
    self.is_hovered = false
end


function Container:down()
    if self.on_down then self:on_down(); end
    self.is_down = true
end

function Container:up()
    if self.on_up then self:on_up(); end
    self.is_down = false
end

function Container:press()
    if self.on_press then self:on_press(); end
end


---- SECTION: POSITIONING ----

function Container:getAnchorOffsets()
    return -(self.width * self._hanchor), -(self.height * self._vanchor)
end


function Container:getLocalPosition()
    return self.x, self.y
end


function Container:getLocalOffsetPosition()
    local ox, oy = self:getAnchorOffsets()
    return self.x + ox, self.y + oy
end


function Container:getGlobalPosition()
    if self.parent == nil or self.parent.__name == "UI Wrapper" or self.independent_position then
        return self.x, self.y
    else
        local x, y = self.parent:getGlobalOffsetPosition()
        return x + self.x, y + self.y
    end
end


function Container:getGlobalOffsetPosition()
    local x, y = self:getGlobalPosition()
    local ox, oy = self:getAnchorOffsets()
    return x + ox, y + oy
end


---- SECTION: DRAWING ----

function Container:draw()
    if not self.visible then return; end

    if self.draw_bg then
        local t = self:getCurrentStateTheme()
        local x,y = self:getGlobalOffsetPosition()
        local w,h = self.width, self.height
        local previous_color = {lg.getColor()}
        local previous_line_width = lg.getLineWidth()

        if t.shadow.enabled then
            lg.setColor(t.shadow.color)
            lg.rectangle("fill", x+t.shadow.ox,y+t.shadow.oy, w,h, t.corner_radius)
    
            lg.setColor(previous_color)
            lg.setLineWidth(previous_line_width)
        end

        lg.setColor(t.bg_color)
        lg.rectangle("fill", x,y, w,h, t.corner_radius)

        lg.setColor(t.fg_color)
        lg.setLineWidth(t.border_size)
        lg.rectangle("line", x,y, w,h, t.corner_radius)

        lg.setColor(previous_color)
        lg.setLineWidth(previous_line_width)
    end

    if scarlet.debug.draw_boundaries then
        self:debugDraw()
    end
    for _, c in pairs(self.children) do
        if c.visible then c:draw(); end
    end
end


function Container:debugDraw()
    local x, y = self:getGlobalOffsetPosition()
    local cx, cy = self:getGlobalPosition()


    local info_string = self.__id .. "\n"
    if self.has_focus then info_string = info_string .. "has_focus\n"; end
    if self.is_hovered then info_string = info_string .. "is_hovered\n"; end
    if self.is_down then info_string = info_string .. "is_down\n"; end

    if self.is_down then
        lg.setColor(0,0,1)    
    elseif self.has_focus then
        lg.setColor(1,0,0);
    elseif self.is_hovered then
        lg.setColor(1,1,0);
    end
    lg.rectangle("line", x,y, self.width,self.height)
    lg.print(info_string, x,y )
    
    lg.setColor(0,1,0)
    lg.circle("fill", cx,cy, 4)

    lg.setColor(1,1,1)
end


return Container
end 
