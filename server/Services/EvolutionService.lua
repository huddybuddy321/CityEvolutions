local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Common = ReplicatedStorage.Common
local Dictionaries = Common.Dictionaries
local Evolutions = require(Dictionaries.Evolutions)

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local Knit = require(KnitPackages.Knit)

local EvolutionService = Knit.CreateService {
    Name = "EvolutionService",
}

function EvolutionService:GetPlayerEvolution(player)
    return "Tribe Age"
end

function EvolutionService:GetEvolutionBuildings(evolutionName)
    return Evolutions[evolutionName]
end

function EvolutionService:GetRandomBuildingFromEvolution(evolutionName)
    return self:GetEvolutionBuildings(evolutionName).Buildings[math.random(1, #self:GetEvolutionBuildings(evolutionName).Buildings)]
end

return EvolutionService