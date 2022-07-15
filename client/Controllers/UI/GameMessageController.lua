local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Building = require(Components.Building)

local Knit = require(KnitPackages.Knit)
local Promise = require(Knit.Util.Promise)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local GameMessages = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("GameMessages")
local GameMessage = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("GameMessages"):WaitForChild("GameMessage")

local GameMessageController = Knit.CreateController {
    Name = "GameMessageController",
    PlotsTaken = {}
}

function GameMessageController:KnitStart()
    local GameMessageService = Knit.GetService("GameMessageService")

    GameMessageService.GameMessaged:Connect(function(message)
        self:GameMessage(message)
    end)
end

function GameMessageController:GameMessage(message)
    task.spawn(function()
        local gameMessage = GameMessage:Clone()
        gameMessage:WaitForChild("TextLabel").Text = message
        gameMessage.Visible = true
        gameMessage.Parent = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("GameMessages")
        task.wait(1)
        local fadeTween = TweenService:Create(gameMessage, TweenInfo.new(0.5), {Transparency = 1})
        fadeTween:Play()
        local textFadeTween = TweenService:Create(gameMessage.TextLabel, TweenInfo.new(0.5), {TextTransparency = 1})
        textFadeTween:Play()
        Debris:AddItem(gameMessage, 0.5)
    end)
end

return GameMessageController