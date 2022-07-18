local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Building = require(Components.Building)

local Knit = require(KnitPackages.Knit)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local BuildingControlController = Knit.CreateController {
    Name = "BuildingControlController",
}

function BuildingControlController:KnitStart()
    self.BuildingControl = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("BuildingControl")

    Knit.GetController("InputController").Clicked:Connect(function(gameProcessed)
        if not gameProcessed then
            if self.currentBuildingInstance and self.canClose then
                self:Close()
            end
        end
    end)
end

function BuildingControlController:Open(buildingComponent)
    if self.currentBuildingInstance then
        if self.currentBuildingInstance ~= buildingComponent.Instance then
            self:Close()
        else
            return
        end
    end

    self.currentBuildingInstance = buildingComponent.Instance

    local function updateCitizenCapacity(citizenCapacity, citizenCount)
        self.BuildingControl:WaitForChild("CitizenCapacity").Text = citizenCount .. "/" .. citizenCapacity .. " spots taken"
    end

    updateCitizenCapacity(buildingComponent.SharedState:Get("Capacity"), #buildingComponent.SharedState:Get("Citizens"))

    self.buildingSharedStateChangedConnection = buildingComponent.SharedState.Changed:Connect(function(key, value)
        if key == "Citizens" then
            updateCitizenCapacity(buildingComponent.SharedState:Get("Capacity"), #value)
        elseif key == "Capacity" then
            updateCitizenCapacity(value, #buildingComponent.SharedState:Get("Citizens"))
        end
    end)

    self.BuildingControl.Visible = true

    task.spawn(function()
        local currentBuildingInstance = self.currentBuildingInstance
        self.canClose = false

        task.wait(0.5)

        if currentBuildingInstance == self.currentBuildingInstance then
            self.canClose = true
        end
    end)
end

function BuildingControlController:Close()
    self.currentBuildingInstance = nil

    if self.buildingSharedStateChangedConnection then
        self.buildingSharedStateChangedConnection:Disconnect()
        self.buildingSharedStateChangedConnection = nil
    end

    self.BuildingControl.Visible = false
end

return BuildingControlController