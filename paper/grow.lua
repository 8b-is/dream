-- Florilegium-8B :: grow.lua
-- Greedy space-filling disc packer seeded deterministically from the
-- Phoenix Waking Seal S^{(n+1)} and Milarepa Provenance Root:
-- SHA-256: 25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e

local M = {}

M.PROVENANCE_ROOT_HEX = "25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e"
M.PROVENANCE_SEED_32  = 0x25b3cfad
M.MODULUS             = 2147483647 -- 2^31 - 1 (Mersenne prime M_31)
M.MULTIPLIER          = 16807      -- 7^5 (Park-Miller minimal standard)

-- Derive deterministic page seed s_p = (0x25b3cfad ~ page * 0x9e3779b9) mod (2^31 - 1)
function M.page_seed(page_num, waking_seal_low32)
    local w = waking_seal_low32 or 0x7c242080
    local raw = bit32 and bit32.bxor(M.PROVENANCE_SEED_32, (page_num * 2654435761) % M.MODULUS, w)
        or ((M.PROVENANCE_SEED_32 + page_num * 1103515245 + w) % M.MODULUS)
    if raw <= 0 then raw = raw + M.MODULUS - 1 end
    return raw
end

-- Park-Miller PRNG closure
function M.make_prng(seed)
    local state = seed % M.MODULUS
    if state <= 0 then state = 1 end
    return function()
        state = (state * M.MULTIPLIER) % M.MODULUS
        return state / M.MODULUS
    end
end

-- Distance from point (x, y) to the textblock rectangle [x0, y0, x1, y1]
local function dist_to_box(x, y, box)
    local dx = math.max(box.x0 - x, 0, x - box.x1)
    local dy = math.max(box.y0 - y, 0, y - box.y1)
    return math.sqrt(dx * dx + dy * dy)
end

-- Greedy space-filling disc packing in the page margins around textblock `box`
-- Returns a deterministic array of { x, y, r, theta, index } discs.
function M.pack_margin_discs(page_w, page_h, box, page_num, max_discs)
    local rand = M.make_prng(M.page_seed(page_num or 1))
    local discs = {}
    local n_target = max_discs or 36
    local min_r = 4.0
    local max_r = 28.0

    for k = 1, n_target do
        local best = nil
        -- Sample candidate centers in the margin region and keep the largest valid disc
        for _ = 1, 48 do
            local cx = rand() * page_w
            local cy = rand() * page_h
            local d_text = dist_to_box(cx, cy, box)
            local d_edge = math.min(cx, page_w - cx, cy, page_h - cy)
            local r = math.min(d_text - 2.0, d_edge - 1.5, max_r)

            if r >= min_r then
                for i = 1, #discs do
                    local other = discs[i]
                    local dist = math.hypot and math.hypot(cx - other.x, cy - other.y)
                        or math.sqrt((cx - other.x)^2 + (cy - other.y)^2)
                    r = math.min(r, dist - other.r - 1.0)
                    if r < min_r then break end
                end
            end

            if r >= min_r and (not best or r > best.r) then
                best = {
                    x = cx,
                    y = cy,
                    r = r,
                    theta = rand() * 2.0 * math.pi,
                    index = k,
                }
            end
        end
        if best then
            discs[#discs + 1] = best
        end
    end

    return discs
end

return M
