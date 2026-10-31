-- Florilegium-8B :: flora.lua
-- Botanical stems, Delft-blue blossoms, and copper-ember leaf Bezier generators

local ink = require("ink")
local M = {}

function M.render_blossom_pdf(disc, petals)
    local n = petals or 6
    local out = {}
    for k = 1, n do
        local angle = disc.theta + (k - 1) * (2.0 * math.pi / n)
        local color = (k % 2 == 0) and ink.PALETTE.delft_deep or ink.PALETTE.copper_ember
        out[#out + 1] = ink.bezier_petal_pdf(disc.x, disc.y, disc.r * 0.85, angle, color, 0.42)
    end
    return table.concat(out, "\n")
end

return M
