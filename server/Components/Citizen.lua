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
    Tag = "Citizen",
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
       GonAssignedTo = RemoteState.None,
       Dragging = false
    })
end

function Citizen:Start()
    local CitizenMoveZone = workspace.CitizenZone.CitizenMoveZone

    self.heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.SharedState:Get("Dragging") then
            if not self.moveToPoint then
                self.moveToPoint = Vector3.new(
                    math.random(CitizenMoveZone.Position.X - (CitizenMoveZone.Size.X/2), CitizenMoveZone.Position.X + (CitizenMoveZone.Size.X/2)),
                    0.5,
                    math.random(CitizenMoveZone.Position.Z - (CitizenMoveZone.Size.Z/2), CitizenMoveZone.Position.Z + (CitizenMoveZone.Size.Z/2))
                )
            end

            if self.moveToPoint then
                self.Instance.Humanoid:MoveTo(self.moveToPoint)
                if self.Instance:FindFirstChild("HumanoidRootPart") then
                    if (self.Instance.HumanoidRootPart.Position - self.moveToPoint).Magnitude <= 3 then
                        --Reached point
                        self.moveToPoint = nil
                    end
                end
            end
        end
    end)
end

function Citizen:AssignToGon(gonInstance)
    Gon:WaitForInstance(gonInstance):andThen(function(gonComponent)
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

    self.Instance:Destroy()
end

function Citizen:StartDrag()
    self.SharedState:Set("Dragging", true)
end

return Citizen