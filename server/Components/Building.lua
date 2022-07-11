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

local Building = Component.new({
    Tag = "Building",
    Ancestors = {workspace},
})

function Building:Construct()
    for _, basePart in pairs(self.Instance:GetDescendants()) do
        if basePart:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(basePart, "Building")
        end
    end
end

return Building