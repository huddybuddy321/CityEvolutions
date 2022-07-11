local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local Components = Server.Components
local Citizen = require(Components.Citizen)

local Knit = require(KnitPackages.Knit)
local Promise = require(Knit.Util.Promise)

local CitizenService = Knit.CreateService {
    Name = "CitizenService",
    Client = {}
}

function CitizenService.Client:SelectCitizen(player, citizenInstance)
    self.Server:SelectCitizen(player, citizenInstance)
end

function CitizenService.Client:AssignCitizenBuilding(player, citizenInstance, gonInstance)
    self.Server:AssignCitizenBuilding(player, citizenInstance, gonInstance)
end

function CitizenService:AssignCitizenBuilding(player, citizenInstance, gonInstance)
    local citizenComponent = Citizen:FromInstance(citizenInstance)

    if citizenComponent then
        citizenComponent:SetGonTarget(gonInstance)
    end
end

function CitizenService:SelectCitizen(player, citizenInstance)
    local citizenComponent = Citizen:FromInstance(citizenInstance)

    if citizenComponent then
        citizenComponent:SetPlayerTarget(player)
    end
end

function CitizenService:KnitStart()

end

return CitizenService