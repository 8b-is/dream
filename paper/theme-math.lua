-- Florilegium-8B :: theme-math.lua
-- Vogel Golden-Angle Phyllotaxis Discs, Lissajous Knots, and Apollonian Gaskets

local ink = require("ink")
local M = {}

M.GOLDEN_ANGLE = math.pi * (3.0 - math.sqrt(5.0)) -- ~2.39996322972865332 rad (137.507764 deg)

local function fmt(n)
    return string.format("%.3f", n)
end

-- Vogel's golden-angle spiral seeds inside disc (x, y, r, theta)
function M.render_vogel_pdf(disc, num_seeds)
    local n = num_seeds or 21
    local cx, cy, r, th = disc.x, disc.y, disc.r * 0.88, disc.theta
    local cmds = {
        "q",
        string.format("%.3f %.3f %.3f RG 0.35 w",
            ink.PALETTE.riva_cyan[1],
            ink.PALETTE.riva_cyan[2],
            ink.PALETTE.riva_cyan[3]),
    }

    for k = 1, n do
        local rho = r * math.sqrt(k / n)
        local phi = th + k * M.GOLDEN_ANGLE
        local sx = cx + rho * math.cos(phi)
        local sy = cy + rho * math.sin(phi)
        local sr = math.max(0.55, 1.35 * (1.0 - 0.5 * (k / n)))
        cmds[#cmds + 1] = fmt(sx + sr) .. " " .. fmt(sy) .. " m "
            .. fmt(sx - sr) .. " " .. fmt(sy) .. " l S"
    end

    cmds[#cmds + 1] = "Q"
    return table.concat(cmds, " ")
end

-- Lissajous rose / harmonic knot (p:q frequency ratio) inside disc
function M.render_lissajous_pdf(disc, p, q)
    local freq_p = p or 3
    local freq_q = q or 4
    local cx, cy, r, th = disc.x, disc.y, disc.r * 0.82, disc.theta
    local steps = 48
    local cmds = {
        "q",
        string.format("%.3f %.3f %.3f RG 0.38 w",
            ink.PALETTE.copper_ember[1],
            ink.PALETTE.copper_ember[2],
            ink.PALETTE.copper_ember[3]),
    }

    for s = 0, steps do
        local t = (s / steps) * 2.0 * math.pi
        local px = cx + r * math.sin(freq_p * t + th)
        local py = cy + r * math.sin(freq_q * t)
        if s == 0 then
            cmds[#cmds + 1] = fmt(px) .. " " .. fmt(py) .. " m"
        else
            cmds[#cmds + 1] = fmt(px) .. " " .. fmt(py) .. " l"
        end
    end
    cmds[#cmds + 1] = "h S Q"
    return table.concat(cmds, " ")
end

return M
