local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Building = require(Components.Building)
local Gon = require(Components.Gon)

local Knit = require(KnitPackages.Knit)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local BuildingReplicationController = Knit.CreateController {
    Name = "BuildingReplicationController",
}

function BuildingReplicationController:KnitStart()
    local BuildingService = Knit.GetService("BuildingService")

    BuildingService.ReplicateBuilding:Connect(function(buildingInstance, gonInstance)
        Building:WaitForInstance(buildingInstance):andThen(function(buildingComponent)
            Gon:WaitForInstance(gonInstance):andThen(function(gonComponent)
                gonComponent:SetBuilding(buildingComponent)
            end)
        end)
    end)
end

return BuildingReplicationController