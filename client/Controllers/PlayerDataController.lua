local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Building = require(Components.Building)

local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local PlayerDataController = Knit.CreateController {
    Name = "PlayerDataController",
    State = BasicState.new {
        Muny = 0
    }
}

function PlayerDataController:KnitStart()
    local PlayerDataService = Knit.GetService("PlayerDataService")

    PlayerDataService:GetPlayerData():andThen(function(playerData)
        self.State:SetState(playerData)
    end)

    PlayerDataService.MyDataChanged:Connect(function(key, value)
        self.State:Set(key, value)
    end)
end

function PlayerDataController:Get(key)
    return self.State:Get(key)
end

return PlayerDataController