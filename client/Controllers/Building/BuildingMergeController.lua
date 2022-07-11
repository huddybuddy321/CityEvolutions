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

local BuildingMergeController = Knit.CreateController {
    Name = "BuildingMergeController",
}

function BuildingMergeController:KnitStart()
    --[[
    local BuildingSelectorController = Knit.GetController("BuildingSelectorController")
    local raycastParams = RaycastParams.new()

    Mouse.LeftDown:Connect(function()
        if BuildingSelectorController.hoveredBuildingComponent then
            self.draggingBuildingComponent = BuildingSelectorController.hoveredBuildingComponent
        end
    end)

    Mouse.LeftUp:Connect(function()
        local targetBuildingComponent = BuildingSelectorController.hoveredBuildingComponent
        if targetBuildingComponent and self.draggingBuildingComponent then
            if targetBuildingComponent ~= self.draggingBuildingComponent then
                print("MERGE")
            end
        end
    end)
    ]]--
end

return BuildingMergeController