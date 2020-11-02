namespace("menu", "alloverse")
local SceneClasses = {
    menu = require("app.menu.netmenu_scene"),
    net = require("app.network.network_scene"),
    stats = require("app.debug.stats"),
    controls = require("app.test.controlsOverlay"),
}
local sceneOrder = {"net", "menu", "stats", "controls"}

-- This scene manages the main scenes in the app, to make
-- sure things render in the correct order. 
local SceneManager = classNamed("SceneManager", OrderedEnt)

function SceneManager:_init()
    lovr.scenes = self
    self:super()

    for _, k in ipairs({"menu", "stats", "controls"}) do
        self:_makeScene(k)
    end
end

function SceneManager:showPlace(...)
    if self.net then
        self.net:onDisconnect(0, "Connected elsewhere")
    end
    self.menu.net.engines.graphics.isOverlayScene = true
    self:setMenuVisible(false)
    self.menu:switchToMenu("overlay")
    return self:_makeScene("net", ...)
end

function SceneManager:transitionToMainMenu()
    self.menu.net.engines.graphics.isOverlayScene = false
    self.menu:switchToMenu("main")
    self:setMenuVisible(true)
    return self.menu
end

function SceneManager:setMenuVisible(visible)
    self.menu.visible = visible
    self.menu.net.engines.pose.active = visible
    if self.net then
        self.net.engines.pose.active = not visible
    end
end

function SceneManager:toggleMenuVisible()
    self:setMenuVisible(not self.menu.visible)
end

function SceneManager:onNetConnected(placeName)
    self.menu:setMessage("Connected to", placeName)
end

-- Create a scene of the name wanted, and insert it into the ent graph
function SceneManager:_makeScene(name, ...)
    print("Spawning ", name, "scene with", ...)
    self[name] = SceneClasses[name](...)
    self:_organize()
    return self[name]
end

function SceneManager:_organize()
    local sceneIds = {}
    for i, k in ipairs(sceneOrder) do
        if self[k] then
            if self[k].parent == nil then self[k]:insert(self) end
            table.insert(sceneIds, self[k].id)
        end
    end
    self.kidOrder = sceneIds
end

function SceneManager:unregister(child)
    OrderedEnt.unregister(self, child)
    for i, k in ipairs(sceneOrder) do
        if self[k] == child then self[k] = nil end
    end
    self:_organize()
end

return SceneManager