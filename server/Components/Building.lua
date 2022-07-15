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
local RemoteState = require(Packages.RemoteState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)

local BuildingService

local Building = Component.new({
    Tag = "Building",
    Ancestors = {workspace},
})

function Building:Construct()
    Knit.OnStart():await()

    if not BuildingService then
        BuildingService = Knit.GetService("BuildingService")
    end
    self.State = BasicState.new {
        Citizens = {}
    }

    self.SharedState = RemoteState.new(self.Instance, {
        Citizens = {},
        Capacity = 5,
        Owner = RemoteState.None
    })

    self.CitizenAdded = Signal.new()

    --self.State:Set("Owner", self.State.None)

    for _, basePart in pairs(self.Instance:GetDescendants()) do
        if basePart:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(basePart, "Building")
        end
    end
end


function Building:Start()
    --[[
    self.State.Changed:Connect(function(_, key)
        BuildingService:UpdateBuildingState(self.Instance, key, self.State:Get(key))
    end)
    ]]--
end

function Building:AddCitizen()
    local citizens = self.SharedState:Get("Citizens")
    local citizenIndex = (#citizens)+1

    citizens[citizenIndex] = {index = citizenIndex}

    --self.State:Set("Citizens", citizens)
    self.SharedState:Set("Citizens", citizens)

    self.CitizenAdded:Fire(citizenIndex)
end

return Building