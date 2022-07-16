local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local BasicState = require(Packages.BasicState)
local RemoteState = require(Packages.RemoteState)

local Components = Server.Components
local Gon = require(Components.Gon)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)

local CitizenService

local Citizen = Component.new({
    Tag = "CitizenOLD",
    Ancestors = {workspace},
})

function Citizen:Construct()
    Knit.OnStart():await()

    if not CitizenService then
        CitizenService = Knit.GetService("CitizenService")
    end

    for _, basePart in pairs(self.Instance:GetDescendants()) do
        if basePart:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(basePart, "Citizen")
        end
    end

    self.SharedState = RemoteState.new(self.Instance, {
        TargetState = "Random"
    })
end

function Citizen:SetPlayerTarget(player)
    self.moveToPoint = nil
    self.moveToPlayer = player

    self.SharedState:Set("TargetState", "Player")
end

function Citizen:SetGonTarget(gonInstance)
    self:SetPlayerTarget(nil)
    self.moveToPoint = nil
    self.moveToGon = gonInstance

    local gonComponent = Gon:FromInstance(gonInstance)

    self.citizensChangedConnection = gonComponent.Building.SharedState:GetChangedSignal("Citizens"):Connect(function(citizens)
        if #citizens >= gonComponent.Building.SharedState:Get("Capacity") then
            self.citizensChangedConnection:Disconnect()
            self.moveToPoint = nil
            self.moveToGon = nil
            self.moveToPlayer = nil

            self.SharedState:Set("TargetState", "Random")
        end
    end)

    self.SharedState:Set("TargetState", "Gon")
end

function Citizen:ReachedGon()
    Gon:WaitForInstance(self.moveToGon):andThen(function(gonComponent)
        if gonComponent.Building then
            gonComponent.Building:AddCitizen()
        else
            warn("No building component found")
        end
    end)

    self.heartbeatConnection:Disconnect()

    if self.citizensChangedConnection then
        self.citizensChangedConnection:Disconnect()
    end

    CitizenService.CitizenReachedGon:Fire(self.Instance, self.moveToGon)

    Debris:AddItem(self.Instance, 1)
end

function Citizen:Start()
    local CitizenMoveZone = workspace.CitizenZone.CitizenMoveZone

    self.heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.moveToPoint and not self.moveToPlayer and not self.moveToGon then
            self.moveToPoint = Vector3.new(
                math.random(CitizenMoveZone.Position.X - (CitizenMoveZone.Size.X/2), CitizenMoveZone.Position.X + (CitizenMoveZone.Size.X/2)),
                0.5,
                math.random(CitizenMoveZone.Position.Z - (CitizenMoveZone.Size.Z/2), CitizenMoveZone.Position.Z + (CitizenMoveZone.Size.Z/2))
            )
        end

        if self.moveToPoint then
            self.Instance.Humanoid:MoveTo(self.moveToPoint)
            if (self.Instance.HumanoidRootPart.Position - self.moveToPoint).Magnitude <= 3 then
                self.SharedState:Set("TargetState", "Random")
                self.moveToPoint = nil
            end
        elseif self.moveToPlayer then
            if self.moveToPlayer.Character and self.moveToPlayer.Character:FindFirstChild("HumanoidRootPart") then
                self.Instance.Humanoid:MoveTo(self.moveToPlayer.Character.HumanoidRootPart.Position)
            end
        elseif self.moveToGon then
            self.Instance.Humanoid:MoveTo(self.moveToGon.Position)
            if (self.Instance.HumanoidRootPart.Position - self.moveToGon.Position).Magnitude <= 2 then
                self:ReachedGon()
            end
        end
    end)
end

return Citizen