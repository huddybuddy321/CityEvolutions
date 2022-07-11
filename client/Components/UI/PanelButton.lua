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

local PanelButton = Component.new({
    Tag = "UIPanelButton",
    Ancestors = {Player:WaitForChild("PlayerGui")},
})

function PanelButton:Construct()
    self.Panel = self.Instance:FindFirstAncestor("ScreenGui"):WaitForChild("Panels"):WaitForChild(self.Instance:GetAttribute("Panel"))
    self.State = BasicState.new {
        Active = true,
    }
end

function PanelButton:Click()
    if self.State:Get("Active") then
        for _, panelButton in pairs(PanelButton:GetAll()) do
            if panelButton.Instance ~= self.Instance then
                panelButton.Panel.Visible = false
            end
        end
        self.Panel.Visible = not self.Panel.Visible
    end
end

function PanelButton:Start()
    self.Instance.MouseButton1Click:Connect(function()
        SoundService:PlayLocalSound(SoundService.Interface.Click)
        self:Click()
    end)
end

return PanelButton