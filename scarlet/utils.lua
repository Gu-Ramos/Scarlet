local LIB_DIR = ((...)..'.'):sub(1, -7)
local utils = {}
local classy = require(LIB_DIR.."classy") 
utils.class = classy.class
local lg = love.graphics


---- SECTION: HELPERS ----

local function copy(t)
    if type(t) ~= "table" then return t; end
    local nt = {}
    for k, v in pairs(t) do nt[k] = copy(v); end
    return nt
end


---- SECTION: THEME ----

utils.default_theme = {
    border_size = 2, corner_radius = 12,
    
    shadow = {
        enabled = true,
        ox = 5, oy = 5,
        color = {0,0,0, 0.5}
    },

    normal = {
        bg_color = {0.9,0.9,0.9}, fg_color = {0.7,0.7,0.7},
        bg_text_color = {1,1,1}, fg_text_color = {0,0,0},
        accent = {0,0,0},
    },

    hovered = {
        bg_color = {1,1,1}, fg_color = {0.8,0.8,0.8},
        bg_text_color = {1,1,1}, fg_text_color = {0,0,0},
        accent = {0,0,0},
    },

    pressed = {
        bg_color = {0.8,0.8,0.8}, fg_color = {0.6,0.6,0.6},
        bg_text_color = {1,1,1}, fg_text_color = {0,0,0},
        accent = {0,0,0},
    },

    disabled = {
        bg_color = {0.7,0.7,0.7}, fg_color = {0.5,0.5,0.5},
        bg_text_color = {0.8,0.8,0.8}, fg_text_color = {0.2,0.2,0.2},
        accent = {0,0,0},
    },
    
    text = {
        font = lg.newFont(24),
        halign = "center", valign = "center"
    }
}

function utils.default_theme:setProperties(properties)
    for k, v in pairs(properties) do self[k] = copy(v); end
end


function utils.new_theme(properties, base)
    local nt = copy(base or utils.default_theme)
    nt:setProperties(properties or {})
    return nt
end


function utils.default_theme:copy() return utils.new_theme(nil, self); end


---- SECTION: DEFAULTS ----

local alignments = {
    free = {0, 0},
    ["parent-controlled"] = {0,0};
    center = {0.5, 0.5},
    ["top-left"] = {0, 0},
    ["top-right"] = {1, 0},
    ["bottom-left"] = {0, 1},
    ["bottom-right"] = {1, 1},
    left = {0, 0.5},
    right = {1, 0.5},
    top = {0.5, 0},
    bottom = {0.5, 1}
}


utils.default_flags = {
    x = 0, y = 0,
    width = 0, height = 0,
    hpadding = 20, vpadding = 20,
    _halign = 0, _valign = 0,
    _hanchor = 0, _vanchor = 0, 
    _ui = nil,
    
    theme = utils.default_theme, -- we override this in the init function
    draw_bg = false,

    anchor = "top-left", align = "free",
    independent_position = false,
    visible = true, awake = true, focusable = true, active = true,
    has_focus = false, is_hovered = false
}


---- FUNCTIONS ----

function utils.getTextAlignment(str)

    local alignment = assert(alignments[str], string.format("Invalid alignment: %q", str))
    return alignment[1], alignment[2]
end

function utils.removeFromTree(child)
    if child.parent then
        child.removeParent()
    end
end

return utils
