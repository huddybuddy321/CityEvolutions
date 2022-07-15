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
local Signal = require(Knit.Util.Signal)

local CitizenService = Knit.CreateService {
    Name = "CitizenService",
    CitizenReachedGon = Signal.new(),
    Client = {
        CitizenReachedGon = Knit.CreateSignal(),
        CitizenUnselected = Knit.CreateSignal(),
    }
}

function CitizenService.Client:SelectCitizen(player, citizenInstance)
    return self.Server:SelectCitizen(player, citizenInstance)
end

function CitizenService.Client:AssignCitizenGon(player, citizenInstance, gonInstance)
    return self.Server:AssignCitizenGon(player, citizenInstance, gonInstance)
end

function CitizenService:AssignCitizenGon(player, citizenInstance, gonInstance)
    local assignedCitizenToGon = false

    local citizenComponent = Citizen:FromInstance(citizenInstance)

    if citizenComponent then
        local gonComponent = Gon:FromInstance(gonInstance)

        if gonComponent.Building then
            if #gonComponent.Building.SharedState:Get("Citizens") < gonComponent.Building.SharedState:Get("Capacity") then
                assignedCitizenToGon = true
                citizenComponent:SetGonTarget(gonInstance)
            end
        end
    end

    return assignedCitizenToGon
end

function CitizenService:SelectCitizen(player, citizenInstance)
    local didSelectCitizen = false
    local citizenComponent = Citizen:FromInstance(citizenInstance)

    if citizenComponent and citizenComponent.SharedState:Get("TargetState") ~= "Player" then
        didSelectCitizen = true
        citizenComponent:SetPlayerTarget(player)
    end

    return didSelectCitizen
end

function CitizenService:KnitStart()
    self.CitizenReachedGon:Connect(function(citizenInstance, gonInstance)
        self.Client.CitizenReachedGon:FireAll(citizenInstance, gonInstance)
    end)
end

return CitizenService