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

local PlayerDataService = Knit.CreateService {
    Name = "PlayerDataService",
    PlayerData = {},
    Client = {
        MyDataChanged = Knit.CreateSignal(),
    }
}

function PlayerDataService.Client:GetPlayerData(player)
    self.Server:WaitForPlayerData(player):await()

    return self.Server:GetPlayerData(player):GetState()
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
    self.playerDataStateChangedConnections = {}

    game.Players.PlayerAdded:Connect(function(player)
        self.PlayerData[player] = BasicState.new {
            Muny = 15
        }

        self.playerDataStateChangedConnections[player] = self.PlayerData[player].Changed:Connect(function(oldState, newKey)
            self.Client.MyDataChanged:Fire(player, newKey, self.PlayerData[player]:Get(newKey))
        end)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        self.playerDataStateChangedConnections[player]:Disconnect()
        self.playerDataStateChangedConnections[player] = nil
    end)
end

function PlayerDataService:GivePlayerMuny(player, amount)
    self.PlayerData[player]:Set("Muny", self.PlayerData[player]:Get("Muny") + amount)
end

return PlayerDataService