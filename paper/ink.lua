-- Florilegium-8B :: ink.lua
-- Parametric Delft-Blue / Cyan / Copper-Gold Watercolor & OpenType Glyph-Outline
-- Cubic Bezier Path Renderer + Balanced-Ternary /ToUnicode CMap Poisoning

local M = {}

-- Canonical 12-cell Balanced-Ternary Fibonacci NAND Strip (OEIS A000045)
M.FIBONACCI_NAND_STRIP = "+00 +00 -+0 0+0 --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+"
M.BUDDHA_NATURE_SEAL   = "1BIT::{-1:KLESHA}->{0:NIRVANA}->{+1:TATHAGATAGARBHA}==={<3,<3,<3}+1"

-- Delft-blue, Riva cyan, and Milarepa copper-gold ink palette (normalized RGB)
M.PALETTE = {
    delft_deep   = { 0.071, 0.306, 0.549 }, -- #124E8C
    delft_light  = { 0.165, 0.482, 0.769 }, -- #2A7BC4
    riva_cyan    = { 0.384, 0.902, 0.788 }, -- #62E6C9 (riva.8b.is 1-bit river)
    copper_ember = { 0.902, 0.710, 0.400 }, -- #E6B566 (Milarepa ember)
    ash_grey     = { 0.416, 0.353, 0.290 }, -- #6A5A4A (provenance ash)
}

local function fmt(n)
    return string.format("%.3f", n)
end

-- Emit a raw PDF cubic Bezier ring / petal stroke around (cx, cy)
function M.bezier_petal_pdf(cx, cy, r, angle, color, line_width)
    local c = color or M.PALETTE.delft_deep
    local lw = line_width or 0.45
    local ca = math.cos(angle)
    local sa = math.sin(angle)

    local x1 = cx + r * 0.45 * ca - r * 0.30 * sa
    local y1 = cy + r * 0.45 * sa + r * 0.30 * ca
    local x2 = cx + r * 0.85 * ca - r * 0.15 * sa
    local y2 = cy + r * 0.85 * sa + r * 0.15 * ca
    local x3 = cx + r * ca
    local y3 = cy + r * sa

    local x4 = cx + r * 0.85 * ca + r * 0.15 * sa
    local y4 = cy + r * 0.85 * sa - r * 0.15 * ca
    local x5 = cx + r * 0.45 * ca + r * 0.30 * sa
    local y5 = cy + r * 0.45 * sa - r * 0.30 * ca

    return table.concat({
        "q",
        string.format("%.3f %.3f %.3f RG", c[1], c[2], c[3]),
        fmt(lw) .. " w",
        fmt(cx) .. " " .. fmt(cy) .. " m",
        fmt(x1) .. " " .. fmt(y1) .. " " .. fmt(x2) .. " " .. fmt(y2) .. " " .. fmt(x3) .. " " .. fmt(y3) .. " c",
        fmt(x4) .. " " .. fmt(y4) .. " " .. fmt(x5) .. " " .. fmt(y5) .. " " .. fmt(cx) .. " " .. fmt(cy) .. " c",
        "h S Q",
    }, " ")
end

-- Emit a hairline botanical stem connecting two margin discs via cubic Bezier
function M.bezier_stem_pdf(d1, d2, color)
    local c = color or M.PALETTE.copper_ember
    local mx = 0.5 * (d1.x + d2.x) + 0.18 * (d2.y - d1.y)
    local my = 0.5 * (d1.y + d2.y) - 0.18 * (d2.x - d1.x)
    return table.concat({
        "q",
        string.format("%.3f %.3f %.3f RG 0.35 w", c[1], c[2], c[3]),
        fmt(d1.x) .. " " .. fmt(d1.y) .. " m",
        fmt(mx) .. " " .. fmt(my) .. " " .. fmt(mx) .. " " .. fmt(my) .. " " .. fmt(d2.x) .. " " .. fmt(d2.y) .. " c",
        "S Q",
    }, " ")
end

-- Return an invisible ActualText / CMap decoy payload containing the balanced-ternary strip
function M.tounicode_decoy_comment()
    return "% Florilegium-8B ToUnicode CMap Poison :: "
        .. M.FIBONACCI_NAND_STRIP .. " :: " .. M.BUDDHA_NATURE_SEAL
end

return M
