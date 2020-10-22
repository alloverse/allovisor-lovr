local tablex = require("pl.tablex")

local nodeToParentIndex = {
    0,
    0,
    1, --2
    3,
    4,
    5,
    1, -- 6
    7,
    8,
    9,
    10,
    1, -- 12
    12,
    13,
    14,
    15,
    1, -- 17
    17,
    18,
    19,
    20,
    1, -- 22
    22,
    23,
    24,
    25,
}
local nodeNames = {
    "palm",
    "wrist",
    "thumb_metacarpal",
    "thumb_proximal",
    "thumb_distal",
    "thumb_tip",
    "index_metacarpal",
    "index_proximal",
    "index_intermediate",
    "index_distal",
    "index_tip",
    "middle_metacarpal",
    "middle_proximal",
    "middle_intermediate",
    "middle_distal",
    "middle_tip",
    "ring_metacarpal",
    "ring_proximal",
    "ring_intermediate",
    "ring_distal",
    "ring_tip",
    "little_metacarpal",
    "little_proximal",
    "little_intermediate",
    "little_distal",
    "little_tip",
}
local globalNodes = {}

function lovr.load()
    models = {
        ["hand/left"] = lovr.graphics.newModel("assets/models/avatars/female/left-hand.glb"),
    }
    pbr = lovr.graphics.newShader(
        'standard',
        {
            flags = {
                normalMap = true,
                indirectLighting = true,
                occlusion = true,
                emissive = true,
                skipTonemap = false,
                animated = true,
            },
            stereo = lovr.headset == nil or (lovr.headset.getName() ~= "Pico") -- turn off stereo on pico: it's not supported
        }
    )
    pbr:send('lovrLightDirection', { -1, -1, -1 })
    pbr:send('lovrLightColor', { .9, .9, .8, 1.0 })
    pbr:send('lovrExposure', 2)
    lovr.graphics.setBackgroundColor(0.95, 0.98, 0.98)
    lovr.graphics.setColor(0,0,0)
    for i, name in ipairs(nodeNames) do
        table.insert(globalNodes, lovr.math.newMat4())
    end
end

function drawAxes(size)
    lovr.graphics.setColor(1,0,0)
    lovr.graphics.line(0,0,0, size,0,0)
    lovr.graphics.setColor(0,1,0)
    lovr.graphics.line(0,0,0, 0,size,0)
    lovr.graphics.setColor(0,0,1)
    lovr.graphics.line(0,0,0, 0,0,size)
end

function drawHand(hand)
    models[hand] = models[hand] or lovr.headset.newModel(hand)
    local model = models[hand]

    lovr.graphics.setShader()

    if model then
        model:pose()
    end

    lovr.graphics.setColor(0,0,0,1)
    local h = 0.05
    if hand == "hand/left" then
        lovr.graphics.print("Node name", 0, -h, -2, h, lovr.math.quat(), 0, "left")
        lovr.graphics.print("local pos", 0.5, -h, -2, h, lovr.math.quat(), 0, "left")
        lovr.graphics.print("local rot", 0.9, -h, -2, h, lovr.math.quat(), 0, "left")
        lovr.graphics.print("parent node", 1.5, -h, -2, h, lovr.math.quat(), 0, "left")
        lovr.graphics.print("global pos", 2.0, -h, -2, h, lovr.math.quat(), 0, "left")
        lovr.graphics.print("global rot", 2.6, -h, -2, h, lovr.math.quat(), 0, "left")
    end

    for i, joint in ipairs(lovr.headset.getSkeleton(hand) or {}) do
        local x, y, z, a, ax, ay, az = unpack(joint)
        local jointPose = lovr.math.mat4(unpack(joint))
        local nodeName = nodeNames[i]
        local parentIndex = nodeToParentIndex[i]
        local parentNodeName = nodeNames[parentIndex] and nodeNames[parentIndex] or ""

        if parentIndex ~= 0 then
            globalNodes[i]:set(globalNodes[parentIndex]):mul(jointPose)
        else
            globalNodes[i]:set(jointPose)
        end

        local status, ox, oy, oz, oa, oax, oay, oaz = pcall(model.getNodePose, model, nodeName, "local")
        if status and hand == "hand/left" then
            if i > 2 then -- don't pose wrist or palm, model's transform does that for us
                model:pose(nodeName, ox, oy, oz, a, ax, ay, az)
            end
        end

        if hand == "hand/left" then
            lovr.graphics.print(nodeName, 0, i*h, -2, h, lovr.math.quat(), 0, "left")
            lovr.graphics.print(string.format("(%.2f, %.2f, %.2f)", x, y, z), 0.5, i*h, -2, h, lovr.math.quat(), 0, "left")
            lovr.graphics.print(string.format("%.2frad (%.2f, %.2f, %.2f)", a, ax, ay, az), 0.9, i*h, -2, h, lovr.math.quat(), 0, "left")
            lovr.graphics.print(parentNodeName, 1.5, i*h, -2, h, lovr.math.quat(), 0, "left")
            local gx, gy, gz, gsx, gsy, gsz, ga, gax, gay, gaz = globalNodes[i]:unpack()
            lovr.graphics.print(string.format("(%.2f, %.2f, %.2f)", gx, gy, gz), 2.0, i*h, -2, h, lovr.math.quat(), 0, "left")
            lovr.graphics.print(string.format("%.2frad (%.2f, %.2f, %.2f)", ga, gax, gay, gaz), 2.6, i*h, -2, h, lovr.math.quat(), 0, "left")
        end
    end

    for i, joint in ipairs(globalNodes) do
        lovr.graphics.push()
        lovr.graphics.transform(joint)
        lovr.graphics.sphere(0, 0, 0, 0.01)
        drawAxes(0.018)
        lovr.graphics.transform(0, 0.03, 0.0, 1, 1, 1, -3.14/2, 1, 0, 0)
        lovr.graphics.print(nodeNames[i], 0, 0, 0, 0.01)
        lovr.graphics.pop()
    end


    local pose = lovr.math.mat4(lovr.headset.getPose(hand))
    lovr.graphics.push()
    lovr.graphics.transform(pose)
    lovr.graphics.cube("line", 0,0,0, 0.1)
    drawAxes(0.06)
    
    lovr.graphics.setColor(1, 1, 1)
    if model then
        if hand == "hand/right" then
            lovr.headset.animate(hand, model)
        end
        lovr.graphics.setShader(pbr)
        model:draw()
    end
    lovr.graphics.pop()
    
end
function lovr.draw()
    lovr.graphics.clear()
    lovr.graphics.cube('line', 0, 1.2, -3, .5, lovr.timer.getTime())

    for _, hand in ipairs({ 'hand/left', 'hand/right' }) do
        drawHand(hand)
    end
end
  