return function(scarlet)

local lg = love.graphics
local default_flags = {
    text = "",
    draw_bg = true,
}

local Button = scarlet.utils.class("Button", scarlet.container)
Button:implement(default_flags)


function Button:getCurrentStateTheme()
    local t = self.theme
    return {
        corner_radius = t.corner_radius,
        border_size = t.border_size,
        shadow = t.shadow,
        text = t.text,

        accent = (not self.active and t.disable.accent)
                or (self.is_down and t.pressed.accent)
                or (self.is_hovered and t.hovered.accent)
                or t.normal.accent,
        bg_color = (not self.active and t.disabled.bg_color)
                or (self.is_down and t.pressed.bg_color)
                or (self.is_hovered and t.hovered.bg_color)
                or t.normal.bg_color,
        fg_color = (not self.active and t.disabled.fg_color)
                or (self.is_down and t.pressed.fg_color)
                or (self.is_hovered and t.hovered.fg_color)
                or t.normal.fg_color,
        bg_text_color = (not self.active and t.disabled.bg_text_color)
                or (self.is_down and t.pressed.bg_text_color)
                or (self.is_hovered and t.hovered.bg_text_color)
                or t.normal.bg_text_color,
        fg_text_color = (not self.active and t.disabled.fg_text_color)
                or (self.is_down and t.pressed.fg_text_color)
                or (self.is_hovered and t.hovered.fg_text_color)
                or t.normal.fg_text_color,

    }
end


function Button:draw()
    if not self.visible then return; end

    local t = self:getCurrentStateTheme()
    local x,y = self:getGlobalOffsetPosition()
    local w,h = self.width, self.height
    local previous_color = {lg.getColor()}
    local previous_line_width = lg.getLineWidth()

    -- start drawing
    if self.draw_bg then
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
    end

    if self.text ~= "" then
        local previous_font = lg.getFont()
        
        x = x + t.border_size/2
        local _, h_align = scarlet.utils.getTextAlignment(t.text.valign)
        y = y + (h_align * h) - t.text.font:getHeight()/2
        -- lg.setColor(0,0,1)
        -- lg.circle("fill", x,y, 5)
        lg.setFont(t.text.font)
        lg.setColor(t.fg_text_color)
        lg.printf(self.text, x,y, (w - t.border_size), t.text.halign)

        lg.setFont(previous_font)
    end
    -- end drawing

    lg.setColor(previous_color)
    lg.setLineWidth(previous_line_width)

    if scarlet.debug.draw_boundaries then
        self:debugDraw()
    end
    for _, c in pairs(self.children) do
        if c.visible then c:draw(); end
    end
end

return Button
end
