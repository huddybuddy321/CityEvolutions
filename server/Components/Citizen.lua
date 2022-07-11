local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services
local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)

local Citizen = Component.new({
    Tag = "Citizen",
    Ancestors = {workspace},
})

function Citizen:Construct()
    for _, basePart in pairs(self.Instance:GetDescendants()) do
        if basePart:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(basePart, "Citizen")
        end
    end
end

function Citizen:SetPlayerTarget(player)
    self.moveToPlayer = player
end

function Citizen:SetGonTarget(gonInstance)
    self:SetPlayerTarget(nil)
    self.moveToGon = gonInstance
end

function Citizen:Start()
    local CitizenMoveZone = workspace.CitizenZone.CitizenMoveZone

    game:GetService("RunService").Heartbeat:Connect(function()
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
                self.moveToPoint = nil
            end
        elseif self.moveToPlayer then
            if self.moveToPlayer.Character then
                self.Instance.Humanoid:MoveTo(self.moveToPlayer.Character.HumanoidRootPart.Position)
            end
        elseif self.moveToGon then
            self.Instance.Humanoid:MoveTo(self.moveToGon.Position)
        end
    end)
end

return Citizen