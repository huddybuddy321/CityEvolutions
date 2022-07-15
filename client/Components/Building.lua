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

local Building = Component.new({
    Tag = "Building",
    Ancestors = {workspace},
})

function Building:Construct()
    Knit.OnStart():await()
    self.detailsGui = ReplicatedStorage:WaitForChild("BuildingDetails"):Clone()
    self.detailsGui.Enabled = false
    self.detailsGui.Parent = self.Instance

    self.State = BasicState.new {
        Hovering = false,
        Dragging = true,

        Title = "",
    }

    self.GotSharedState, self.SharedState = RemoteState.WaitForState(self.Instance):await()

    self:SetCapacity(self.SharedState:Get("Capacity"))

    self.State:Set("Owner", self.State.None)
end

function Building:Start()
    self.State:GetChangedSignal("Hovering"):Connect(function(show)
        if show then
            SoundService:PlayLocalSound(SoundService.Interface.BuildingHover)
            self.detailsGui.Enabled = true
        else
            self.detailsGui.Enabled = false
        end
    end)

    self.State:GetChangedSignal("Title"):Connect(function(title)
        self.detailsGui:WaitForChild("Frame"):WaitForChild("Title").Text = title
    end)

    self.SharedState:GetChangedSignal("Citizens"):Connect(function(citizens)
        self.detailsGui:WaitForChild("Frame"):WaitForChild("Details"):WaitForChild("CitizenCapacity").Text = #citizens .. "/" .. self.SharedState:Get("Capacity") .. " spots taken"
    end)

    self.SharedState:GetChangedSignal("Capacity"):Connect(function(capacity)
        self:SetCapacity(capacity)
    end)

    self.State:Set("Title", self.Instance.Name)
end

function Building:SetCapacity(capacity)
    self.detailsGui:WaitForChild("Frame"):WaitForChild("Details"):WaitForChild("CitizenCapacity").Text = #self.SharedState:Get("Citizens") .. "/" .. capacity .. " spots taken"
end

function Building:SetHovered(isHovered)
    self.State:Set("Hovering", isHovered)
end

return Building