local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations
local Particles = Assets.Particles

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

local BerryBush = Component.new({
    Tag = "BuildingBerryBush",
    Ancestors = {workspace},
})

function BerryBush:Construct()
    --self.Building
    self.Timer = Timer.new(2)

    self.Burries = {}
    self.BurriesTaken = {}
    for _, berry in pairs(self.Instance:GetChildren()) do
        if berry.Name == "Berry" then
            table.insert(self.Burries, berry)
        end
    end
end

function BerryBush:Start()
    self.Timer.Tick:Connect(function()
        self:Tick()
    end)

    self.Timer:Start()
end

function BerryBush:Tick()
    if #self.BurriesTaken == #self.Burries then
        table.clear(self.BurriesTaken)

        for _, berry in pairs(self.Burries) do
            berry.Transparency = 0
        end
    else
        local foundBerry = false
        for _, berry in pairs(self.Burries) do
            if not foundBerry and not table.find(self.BurriesTaken, berry) then
                foundBerry = true
                table.insert(self.BurriesTaken, berry)
                task.spawn(function()
                    local berryPickedParticleEmitter = Particles.BerryPicked:Clone()
                    berryPickedParticleEmitter.Rate = 0
                    berryPickedParticleEmitter.Parent = berry

                    Debris:AddItem(berryPickedParticleEmitter, 1)

                    berryPickedParticleEmitter:Emit(1)

                    self.Instance.Base.BerryPicked:Play()

                    task.wait(0.3)
                    TweenService:Create(berry, TweenInfo.new(0.3), {Transparency = 1}):Play()
                    --berry.Transparency = 1
                end)
            end
        end
    end
end

return BerryBush