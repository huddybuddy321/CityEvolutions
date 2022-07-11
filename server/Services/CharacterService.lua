local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local Knit = require(KnitPackages.Knit)

local CharacterService = Knit.CreateService {
    Name = "CharacterService",
    Characters = {}
}

function CharacterService:GetAllCharacters()
    return self.Characters
end

function CharacterService:KnitStart()
    local characterAddedConnections = {}

    game.Players.PlayerAdded:Connect(function(player)
        characterAddedConnections[player.Name] = player.CharacterAdded:Connect(function(character)
            for _, basePart in pairs(character:GetDescendants()) do
                if basePart:IsA("BasePart") then
                    PhysicsService:SetPartCollisionGroup(basePart, "Player")
                end
            end

            self.Characters[player.Name] = character
        end)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        if characterAddedConnections[player.Name] then
            characterAddedConnections[player.Name]:Disconnect()
            characterAddedConnections[player.Name] = nil
            self.Characters[player.Name] = nil
        end
    end)
end

return CharacterService