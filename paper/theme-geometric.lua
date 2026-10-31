-- Florilegium-8B :: theme-geometric.lua
-- Low-poly Platonic crystals & flat-shaded polyhedral projections for margin discs

local ink = require("ink")
local M = {}

local function fmt(n)
    return string.format("%.3f", n)
end

-- Render a projected octahedron / crystal facet inside disc (x, y, r, theta)
function M.render_crystal_pdf(disc)
    local cx, cy, r, th = disc.x, disc.y, disc.r * 0.85, disc.theta
    local vertices = {}
    local sides = 6
    for k = 1, sides do
        local a = th + (k - 1) * (2.0 * math.pi / sides)
        vertices[k] = {
            x = cx + r * math.cos(a),
            y = cy + r * math.sin(a),
        }
    end

    local cmds = {
        "q",
        string.format("%.3f %.3f %.3f RG 0.40 w",
            ink.PALETTE.delft_light[1],
            ink.PALETTE.delft_light[2],
            ink.PALETTE.delft_light[3]),
    }

    -- Outer hexagonal hull
    cmds[#cmds + 1] = fmt(vertices[1].x) .. " " .. fmt(vertices[1].y) .. " m"
    for k = 2, sides do
        cmds[#cmds + 1] = fmt(vertices[k].x) .. " " .. fmt(vertices[k].y) .. " l"
    end
    cmds[#cmds + 1] = "h S"

    -- Internal crystal spokes to apex
    local apex_x = cx + 0.18 * r * math.cos(th + 0.5)
    local apex_y = cy + 0.18 * r * math.sin(th + 0.5)
    for k = 1, sides do
        cmds[#cmds + 1] = fmt(apex_x) .. " " .. fmt(apex_y) .. " m "
            .. fmt(vertices[k].x) .. " " .. fmt(vertices[k].y) .. " l S"
    end

    cmds[#cmds + 1] = "Q"
    return table.concat(cmds, " ")
end

return M
