local mp = require 'mp'

------------------------------------------------------------
-- GPU DETECTION (dGPU FIRST, then iGPU)
------------------------------------------------------------

local function detect_active_gpu()
    local renderer = mp.get_property("gpu-renderer") or ""
    renderer = renderer:lower()

    --------------------------------------------------------
    -- 1. DISCRETE GPU DETECTION (PRIORITY)
    --------------------------------------------------------

    -- NVIDIA (always discrete)
    if renderer:find("nvidia") or renderer:find("geforce") or renderer:find("rtx") or renderer:find("gtx") then
        return "dgpu-nvidia"
    end

    -- AMD discrete (RX series etc.)
    if renderer:find("radeon") or renderer:find("rx") then
        return "dgpu-amd"
    end

    -- Intel ARC (discrete GPUs)
    if renderer:find("arc") then
        return "dgpu-intel"
    end

    --------------------------------------------------------
    -- 2. INTEGRATED GPU DETECTION
    --------------------------------------------------------

    -- Intel iGPU
    if renderer:find("intel") or renderer:find("uhd") or renderer:find("iris") then
        return "igpu-intel"
    end

    -- AMD APU (Vega, integrated Radeon Graphics)
    if renderer:find("vega") or renderer:find("radeon graphics") then
        return "igpu-amd"
    end

    --------------------------------------------------------
    -- 3. FALLBACK
    --------------------------------------------------------

    return "unknown"
end


------------------------------------------------------------
-- PROFILE APPLICATION LOGIC
------------------------------------------------------------

local function apply_gpu_profile()
    local gpu = detect_active_gpu()

    if gpu:find("dgpu") then
        -- Discrete GPU → full perceptual
        mp.command("apply-profile perceptual")
        mp.msg.info("GPU: " .. gpu .. " → PERCEPTUAL profile")

    elseif gpu:find("igpu") then
        -- Integrated GPU → safe baseline
        mp.command("apply-profile reference")
        mp.msg.info("GPU: " .. gpu .. " → REFERENCE profile")

    else
        -- Unknown → conservative fallback
        mp.command("apply-profile reference")
        mp.msg.warn("GPU: unknown → fallback to REFERENCE")
    end
end


------------------------------------------------------------
-- RUN ON FILE LOAD
------------------------------------------------------------

mp.register_event("file-loaded", apply_gpu_profile)
