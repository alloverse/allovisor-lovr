local ui = require("alloui.ui")
local pretty = require("pl.pretty")
local class = require("pl.class")

class.OverlayPane(ui.Surface)
function OverlayPane:_init(menu)
    self:super(ui.Bounds(0, 1.6, -2,   1.6, 1.2, 0.1))
    self:setColor({1,1,1,1})
    local quitButton = ui.Button(ui.Bounds(0, -0.4, 0.01,     1.4, 0.2, 0.15))
    quitButton.label.text = "Quit!"
    quitButton.onActivated = function() menu:actuate({"quit"}) end
    self:addSubview(quitButton)
  
    local dismissButton = ui.Button(ui.Bounds(0, 0.4, 0.01,   1.4, 0.2, 0.15))
    dismissButton.label.text = "Dismiss"
    dismissButton.onActivated = function() menu:actuate({"dismiss"}) end
    self:addSubview(dismissButton)
  
    local disconnectButton = ui.Button(ui.Bounds(0, 0.1, 0.01,     1.4, 0.2, 0.15))
    disconnectButton.label.text = "Disconnect"
    disconnectButton.onActivated = function() menu:actuate({"disconnect"}) end
    self:addSubview(disconnectButton)
  
    self.messageLabel = ui.Label{
      bounds = ui.Bounds(-0.45, 0.8, 0.01,     1.4, 0.1, 0.1),
      text = "Not connected",
      color = {0,0,0,1},
      halign = "left"
    }
    self:addSubview(self.messageLabel)
  
    local logo = ui.Surface(ui.Bounds(-0.65, 0.8, 0.01, 0.2, 0.2, 0.2))
    logo:setTexture("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB/UlEQVR4nO2av27CMBCHL0AhQqD+GdshUtVnqNStQxk6dUHqVhbExtTn4MX6Bn2CPsZ1wZEJcRLbd7ZD7ifdwJL4++4sRyQAEolEIpFQBY/V1+s7BwEAVwfE1QHVIikXipMR6NdNRsIJuF5As1i8zUcIAPi3fy/rZ/MaXUS5gDp4gwine+jg1YLQE1EURWdwDxGt4LFEOIFbbAtcXGXW8AYR9OC+8C0ivMC5RJCDN4mggqfaFkHAd18fuN+u2SS4iCiPHS5wdZ7vt+uzCiQibtfrwKsS6s5+zmnAmxlv17uAx5wGVvDlYm4Nr+qxuMfrGfs00ArQx8wVPMQ0sAigBucUQSqAG7wqYTr2e2IkE8Ax7qGmwVtALHAqEc4CUgGvk2AjwktAbGCKSRABlyZASRABIkAEiIAu9fJwN2wBg5+A7+enYQvQpkAEWP0dJgJEgAiIDioCDLWcZk7PAaD96LWA23zUCVy9eIGatEpIWUDTBPzu3s663hSjiJQFmCbABrxVRMoC8klGBn4iQX9jnLIANQHQss+dRaiKDdokAIi63jsRIcCNMhIBDw5fSsgnWXARAIDz431jgVcTTAJE7nhb2ERA4uB6cDam2xbAdKyFiPeJAT3qelOsJcCFgFfTKmLzyffNbyopP3EZStdNKSXAwMD1DBZcIpFIksg/LCx2xNxTGTMAAAAASUVORK5CYII=")
    self:addSubview(logo)
end

return OverlayPane