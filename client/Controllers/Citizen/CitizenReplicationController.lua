local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon
local Beams = Assets.Beams

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Citizen = require(Components.Citizen)

local Knit = require(KnitPackages.Knit)
local Signal = require(Knit.Util.Signal)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local CitizenReplicationController = Knit.CreateController {
    Name = "CitizenReplicationController",
    CitizenAssignedToGon = Signal.new(),
    CitizenReachedGon = Signal.new(),
}

function CitizenReplicationController:KnitStart()
    local CitizenService = Knit.GetService("CitizenService")

    CitizenService.CitizenReachedGon:Connect(function(citizenInstance)
        self.CitizenReachedGon:Fire(citizenInstance)
    end)
end

return CitizenReplicationController