local Player = game.Players.LocalPlayer

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)

local UIMunyLabel = Component.new({
    Tag = "UIMunyLabel",
    Ancestors = {Player:WaitForChild("PlayerGui")},
})

function UIMunyLabel:Construct()
    Knit.OnStart():await()
    self.State = BasicState.new {
        Active = true,
    }
end

function UIMunyLabel:UpdateLabel(muny)
    self.Instance.Text = muny .. " muny"
end

function UIMunyLabel:Start()
    local PlayerDataController = Knit.GetController("PlayerDataController")

    self:UpdateLabel(PlayerDataController.State:Get("Muny"))

    PlayerDataController.State:GetChangedSignal("Muny"):Connect(function(muny)
        self:UpdateLabel(muny)
    end)
end

return UIMunyLabel