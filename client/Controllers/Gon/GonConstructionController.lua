local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon

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

local GonReplicationController = Knit.CreateController {
    Name = "GonReplicationController",
}

function GonReplicationController:KnitStart()
    local BuildingService = Knit.GetService("BuildingService")
    BuildingService.ConstructOnGon:Connect(function(gonInstance, constructionTime)
        local gonComponent = Gon:FromInstance(gonInstance)
        if gonComponent then
            gonComponent:StartConstruction(constructionTime)
        end
    end)
    BuildingService.ConstructionComplete:Connect(function(gonInstance)
        local gonComponent = Gon:FromInstance(gonInstance)
        if gonComponent then
            gonComponent:ConstructionComplete()
        end
    end)
end

return GonReplicationController