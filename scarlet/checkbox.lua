return function(scarlet)

local lg = love.graphics
local min = math.min
local default_flags = {
    enabled = false,
    enabled_text = "", disabled_text = "",
}

local Checkbox = scarlet.utils.class("Checkbox", scarlet.button)
Checkbox:implement(default_flags)


function Checkbox:press()
    if self.on_press then self:on_press(); end
    self.enabled = not self.enabled
end


function Checkbox:draw()
    if not self.visible then return; end

    local t = self:getCurrentStateTheme()
    local x,y = self:getGlobalOffsetPosition()
    local w = min(self.width, self.height)
    local h = w

    if self.enabled_text == "" and self.disabled_text == "" then
        x = x + self.width/2 - w/2
    end
    y = y + self.height/2 - h/2

    local previous_color = {lg.getColor()}
    local previous_line_width = lg.getLineWidth()

    -- start drawing
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

    local text = ""
    if self.enabled then
        lg.setColor(t.accent)
        lg.circle("fill", x+w/2,y+h/2, min(w,h)/3)
        if self.enabled_text ~= "" then
            text = self.enabled_text
        end
    else
        text = self.disabled_text
    end

    if text ~= "" then
        local previous_font = lg.getFont()
        x = x + w*1.1 + t.border_size/2
        local _, h_align = scarlet.utils.getTextAlignment(t.text.valign)
        y = y + (h_align * h) - t.text.font:getHeight()/2

        lg.setFont(t.text.font)
        lg.setColor(t.bg_text_color)
        lg.printf(text, x,y, (self.width - w*1.1 - t.border_size/2), t.text.halign)

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


return Checkbox
end