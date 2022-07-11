local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local Knit = require(KnitPackages.Knit)
local Promise = require(Knit.Util.Promise)

local PlayerDataService = Knit.CreateService {
    Name = "PlayerDataService",
    PlayerData = {},
    Client = {
        MyDataLoaded = Knit.CreateSignal()
    }
}

function PlayerDataService.Client:GetPlayerData(player)
    self.Server:WaitForPlayerData(player):await()

    return self.Server:GetPlayerData(player)
end

function PlayerDataService:WaitForPlayerData(player)
    return Promise.new(function(resolve)
        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if self:GetPlayerData(player) then
                heartbeatConnection:Disconnect()
                resolve(self:GetPlayerData(player))
            end
        end)
    end)
end

function PlayerDataService:GetPlayerData(player)
    return self.PlayerData[player]
end

function PlayerDataService:KnitStart()
    game.Players.PlayerAdded:Connect(function(player)
        self.PlayerData[player] = {
            Muny = 0
        }
        --[[
        self.PlayerData[player] = {
            Muny = 0
        }
        ]]--

        --self.Client.MyDataLoaded:Fire(player, self.PlayerData[player])
    end)
end

return PlayerDataService