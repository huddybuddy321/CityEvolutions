local Player = game.Players.LocalPlayer

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)

local CitizenReplicationController

local Citizen = Component.new({
    Tag = "CitizenOLD",
    Ancestors = {workspace},
})

function Citizen:Construct()
    Knit.OnStart():await()
    if not CitizenReplicationController then
        CitizenReplicationController = Knit.GetController("CitizenReplicationController")
    end
end

function Citizen:Start()
    self.citizenWalkAnimation = self.Instance:WaitForChild("Humanoid"):LoadAnimation(Animations.CitizenWalk)
    self.citizenWalkAnimation:Play()

    self.citizenReachedGonConnection = CitizenReplicationController.CitizenReachedGon:Connect(function(citizenInstance)
        if self.Instance == citizenInstance then
            self:ReachedGon()
        end
    end)
end

function Citizen:ReachedGon()
    self.citizenReachedGonConnection:Disconnect()
    self.citizenWalkAnimation:Stop()
end

return Citizen