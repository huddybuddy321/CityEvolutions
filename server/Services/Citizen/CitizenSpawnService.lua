local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local Components = Server.Components
local Citizen = require(Components.Citizen)
local Gon = require(Components.Gon)

local Knit = require(KnitPackages.Knit)
local Promise = require(Knit.Util.Promise)
local Timer = require(Knit.Util.Timer)

local CitizenMoveZone = workspace.CitizenZone.CitizenMoveZone

local CitizenSpawnService = Knit.CreateService {
    Name = "CitizenSpawnService",
    SpawnInterveral = 30,
    CitizenWaveCount = 10,
    MaxCitizenCount = 30,
}

function CitizenSpawnService:SpawnCitizenWave(citizenWaveCount)
    print("Spawning " .. citizenWaveCount .. " citizens.")

    for _ = 1, citizenWaveCount do
        local citizenCount = #(workspace.CitizenZone.Citizens:GetChildren())
        if citizenCount + 1 <= self.MaxCitizenCount then
            local citizenInstance = ReplicatedStorage.Assets.Citizen:Clone()

            citizenInstance:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(
                Vector3.new(
                    math.random(CitizenMoveZone.Position.X - (CitizenMoveZone.Size.X/2), CitizenMoveZone.Position.X + (CitizenMoveZone.Size.X/2)),
                    1.5,
                    math.random(CitizenMoveZone.Position.Z - (CitizenMoveZone.Size.Z/2), CitizenMoveZone.Position.Z + (CitizenMoveZone.Size.Z/2))
                )
            )
            citizenInstance.Parent = workspace.CitizenZone.Citizens
        end
    end
end

function CitizenSpawnService:KnitStart()
    self.citizenSpawnTimer = Timer.new(self.SpawnInterveral)

    self.citizenSpawnTimer.Tick:Connect(function()
        local citizenCount = #(workspace.CitizenZone.Citizens:GetChildren())

        if citizenCount <= 30 then
            self:SpawnCitizenWave(self.CitizenWaveCount)
        end
    end)

    self.citizenSpawnTimer:Start()
end

return CitizenSpawnService