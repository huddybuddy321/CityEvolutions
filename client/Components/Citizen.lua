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

local Citizen = Component.new({
    Tag = "Citizen",
    Ancestors = {workspace},
})

function Citizen:Construct()
end

function Citizen:Start()
    self.citizenWalk = self.Instance:WaitForChild("Humanoid"):LoadAnimation(Animations.CitizenWalk)
    self.citizenWalk:Play()
end

return Citizen