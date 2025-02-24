-- TODO: BG_IMAGE, FG_IMAGE
-- TODO: text hoffset and voffset
-- TODO: optimize draw calls. right now it's generating a FUCK TON of garbage.
-- TODO: optimize mousemoved and all kinds of shit involving focus.
-- TODO: optimize children making <children> a list and adding a <children>.<by_id> dict
-- TODO: z index
local LIB_DIR = (...)..'.'
local scarlet = {
    utils = require(LIB_DIR.."utils"),
    debug = {draw_boundaries = false}
}


scarlet.ui_wrapper = require(LIB_DIR.."ui_wrapper")(scarlet)
scarlet.container = require(LIB_DIR.."container")(scarlet)
scarlet.button = require(LIB_DIR.."button")(scarlet)
scarlet.checkbox = require(LIB_DIR.."checkbox")(scarlet)
scarlet.label = require(LIB_DIR.."label")(scarlet)
-- scarlet.image = require(LIB_DIR.."image")(scarlet)


return scarlet
