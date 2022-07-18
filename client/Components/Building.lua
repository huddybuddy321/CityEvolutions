local Player = game.Players.LocalPlayer

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local BasicState = require(Packages.BasicState)
local RemoteState = require(Packages.RemoteState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)

local BuildingControlController

local Building = Component.new({
    Tag = "Building",
    Ancestors = {workspace},
})

function Building:Construct()
    Knit.OnStart():await()
    if not BuildingControlController then
        BuildingControlController = Knit.GetController("BuildingControlController")
    end
    self.detailsGui = ReplicatedStorage:WaitForChild("BuildingDetails"):Clone()
    self.detailsGui.Enabled = false
    self.detailsGui.Parent = self.Instance

    self.State = BasicState.new {
        Hovering = false,
        Dragging = true,

        Selected = false,

        Title = "",
    }

    self.GotSharedState, self.SharedState = RemoteState.WaitForState(self.Instance):await()

    --self:UpdateCitizenCapacity(self.SharedState:Get("Capacity"), #self.SharedState:Get("Citizens"))
    --self:UpdateDetails(self.SharedState:Get("Details"))

    self.State:Set("Owner", self.State.None)
end

function Building:Start()
    self.State:GetChangedSignal("Hovering"):Connect(function(isHovered)
        if isHovered then
            SoundService:PlayLocalSound(SoundService.Interface.BuildingHover)
            --self.detailsGui.Enabled = true
        else
           -- self.detailsGui.Enabled = false
        end
    end)

    self.State:GetChangedSignal("Selected"):Connect(function(isSelected, wasSelected)
        if isSelected then
            if not wasSelected then
                BuildingControlController:Open(self)
            end
        else
            if wasSelected then
                --BuildingControlController:Close()
            end
        end
    end)

    self.State:Set("Title", self.Instance.Name)
end

function Building:UpdateDetails(details)
    for _, detail in pairs(self.detailsGui:WaitForChild("Frame"):WaitForChild("Details"):GetChildren()) do
        if detail.Name == "Detail" then
            detail:Destroy()
        end
    end

    for _, detail in pairs(details) do
        local detailLabel = Instance.new("TextLabel")
        detailLabel.Name = "Detail"
        detailLabel.Size = UDim2.fromScale(0.8, 0.25)
        detailLabel.BackgroundTransparency = 1
        detailLabel.Font = Enum.Font.GothamBold
        detailLabel.Text = detail
        detailLabel.TextColor3 = Color3.fromRGB(176, 255, 28)
        detailLabel.TextScaled = true
        detailLabel.LayoutOrder = 3

        local UIStroke = Instance.new("UIStroke")
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        UIStroke.Color = Color3.fromRGB(132, 132, 132)
        UIStroke.Parent = detailLabel

        detailLabel.Parent = self.detailsGui:WaitForChild("Frame"):WaitForChild("Details")
    end
end

function Building:UpdateCitizenCapacity(capacity, citizenCount)
    --self.detailsGui:WaitForChild("Frame"):WaitForChild("Details"):WaitForChild("CitizenCapacity").Text = #self.SharedState:Get("Citizens") .. "/" .. capacity .. " spots taken"
    self.BuildingControl:WaitForChild("CitizenCapacity").Text = citizenCount .. "/" .. capacity .. " spots taken"
end

function Building:SetHovered(isHovered)
    self.State:Set("Hovering", isHovered)
end

return Building