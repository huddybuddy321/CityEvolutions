local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Promise = require(Knit.Util.Promise)

local GameMessageService = Knit.CreateService {
    Name = "GameMessageService",
    Client = {
        GameMessaged = Knit.CreateSignal(),
    }
}
function GameMessageService:MessagePlayer(player, message)
    self.Client.GameMessaged:Fire(player, message)
end

return GameMessageService