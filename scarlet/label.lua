return function(scarlet)

local lg = love.graphics
local default_flags = {
    text = "",
}

local Label = scarlet.utils.class("Label", scarlet.container)
Label:implement(default_flags)


function Label:draw()
    local t = self:getCurrentStateTheme()
    local x,y = self:getGlobalOffsetPosition()
    local w,h = self.width, self.height
    local previous_color = {lg.getColor()}
    
    if self.draw_bg then
        if t.shadow.enabled then
            lg.setColor(t.shadow.color)
            lg.rectangle("fill", x+t.shadow.ox,y+t.shadow.oy, w,h, t.corner_radius)
    
            lg.setColor(previous_color)
            lg.setLineWidth(previous_line_width)
        end
        local previous_line_width = lg.getLineWidth()
        lg.setColor(t.bg_color)
        lg.rectangle("fill", x,y, w,h, t.corner_radius)

        lg.setColor(t.fg_color)
        lg.setLineWidth(t.border_size)
        lg.rectangle("line", x,y, w,h, t.corner_radius)
        lg.setLineWidth(previous_line_width)
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

    lg.setColor(previous_color)
    if scarlet.debug.draw_boundaries then
        self:debugDraw()
    end
    for _, c in pairs(self.children) do
        if c.visible then c:draw(); end
    end
end


return Label
end