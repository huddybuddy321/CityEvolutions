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
local Building = require(Components.Building)
--local Hammer = require(Components.Hammer)

local BerryBush = Component.new({
    Tag = "BuildingBerryBush",
    Ancestors = {workspace},
})

function BerryBush:Construct()
    Building:WaitForInstance(self.Instance):andThen(function(buildingComponent)
        self.Building = buildingComponent
    end)

    self.Building.SharedState:Set("Capacity", 2)

    self.tickInterveral = 2

    self.Burries = {}
    self.BurriesTaken = {}
    self.CitizenTimers = {}
    self.citizenTimerTickConnections = {}

    for _, berry in pairs(self.Instance:GetChildren()) do
        if berry.Name == "Berry" then
            table.insert(self.Burries, berry)
        end
    end
end

function BerryBush:Start()
    --Every time a citizen is added to this building, create a new timer
    self.Building.CitizenAdded:Connect(function(citizenIndex)
        local timer = Timer.new(self.tickInterveral)
        self.citizenTimerTickConnections[citizenIndex] = timer.Tick:Connect(function()
            self:Tick()
        end)
        self.CitizenTimers[citizenIndex] = timer

        timer:Start()
    end)
end

function BerryBush:Tick()
    if #self.BurriesTaken == #self.Burries then
        --Reset berries and make all of them visible
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

                    --Give cash
                    Knit.GetService("PlayerDataService"):GivePlayerMuny(self.Building.State:Get("Owner"), 1)

                    task.wait(0.3)
                    TweenService:Create(berry, TweenInfo.new(0.3), {Transparency = 1}):Play()
                    --berry.Transparency = 1
                end)
            end
        end
    end
end

return BerryBush