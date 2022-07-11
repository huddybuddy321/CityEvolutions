local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services
local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)
local Timer = require(Knit.Util.Timer)

local Components = Server.Components
--local Hammer = require(Components.Hammer)

local Hut = Component.new({
    Tag = "BuildingHut",
    Ancestors = {workspace},
})

function Hut:Construct()
    --self.Building
    self.Timer = Timer.new(2)
end

function Hut:Start()
    self.Timer.Tick:Connect(function()
        self:Tick()
    end)

    self.Timer:Start()
end

function Hut:Tick()
end

return Hut