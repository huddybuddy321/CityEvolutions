local Player = game.Players.LocalPlayer

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local HammerInstance = Assets.Hammer

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)
local Timer = require(Knit.Util.Timer)

local Components = Client.Components
local Hammer = require(Components.Hammer)

local CitizenSelectorController
local CitizenService
local GonSelectorController

local Gon = Component.new({
    Tag = "Gon",
    Ancestors = {workspace},
})

function Gon:Construct()
    Knit.OnStart():await()
    if not CitizenSelectorController then
        GonSelectorController = Knit.GetController("GonSelectorController")
        CitizenSelectorController = Knit.GetController("CitizenSelectorController")
        CitizenService = Knit.GetService("CitizenService")
    end
    self.State = BasicState.new {
        Hovered = false,
        Constructing = false,
        ConstructionTimeLeft = 0,
        ConstructionTime = 0,
        HasBuildingComponent = false,
    }

    self.BuildingComponent = false

    self.ClickToBuild = ReplicatedStorage.ClickToBuild:Clone()
    self.ClickToBuild.Enabled = false
    self.ClickToBuild.Parent = self.Instance
end

function Gon:Start()
    self.State:GetChangedSignal("Hovered"):Connect(function(isHovered)
        if not self.State:Get("HasBuildingComponent") then
            if isHovered then
                if not self.State:Get("Constructing") then
                    self.ClickToBuild.Enabled = true
                else
                    if self.TimeToBuild then
                        self.TimeToBuild.Enabled = true
                    end
                end
                self.Instance.Decal.Transparency = 0
            else
                if self.TimeToBuild then
                    self.TimeToBuild.Enabled = false
                end
                self.ClickToBuild.Enabled = false
                self.Instance.Decal.Transparency = 0.5
            end
        else
            self.ClickToBuild.Enabled = false
            self.Instance.Decal.Transparency = 0

            self.BuildingComponent.State:Set("Hovering", isHovered)

            if isHovered then
                self.Instance.Decal.Color3 = Color3.fromRGB(69, 151, 163)
            else
                self.Instance.Decal.Color3 = Color3.fromRGB(80, 163, 80)
            end
        end
    end)

    self.State:GetChangedSignal("HasBuildingComponent"):Connect(function(building)
        if building then
            self.Instance.Decal.Transparency = 0
            self.Instance.Decal.Color3 = Color3.fromRGB(80, 163, 80)
        else
            self.Instance.Decal.Transparency = 0.5
            self.Instance.Decal.Color3 = Color3.fromRGB(125, 125, 125)
        end
    end)

    self.State:GetChangedSignal("ConstructionTimeLeft"):Connect(function(constructionTimeLeft)
        if self.TimeToBuild then
            self.TimeToBuild:WaitForChild("TimeLeft").Text = constructionTimeLeft .. " seconds left"
        end
    end)
end

function Gon:Click()
    self.ClickToBuild.Enabled = false
    --[[
    if CitizenSelectorController.selectedCitizenComponent then
        CitizenService:AssignCitizenGon(CitizenSelectorController.selectedCitizenComponent.Instance, self.Instance):andThen(function(citizenWasAssigned)
            if citizenWasAssigned then
                CitizenSelectorController.CitizenAssignedToGon:Fire(CitizenSelectorController.selectedCitizenComponent.Instance)
            end
        end)
    end
    ]]--
end

function Gon:SetBuilding(buildingComponent)
    self.BuildingComponent = buildingComponent
    self.State:Set("HasBuildingComponent", buildingComponent ~= nil)
end

function Gon:StartConstruction(constructionTime)
    self.State:Set("ConstructionTime", constructionTime)
    self.State:Set("ConstructionTimeLeft", constructionTime)

    self.TimeToBuild = ReplicatedStorage.TimeToBuild:Clone()
    self.TimeToBuild.Parent = self.Instance

    if self.State:Get("Hovered") then
        self.TimeToBuild.Enabled = true
    else
        self.TimeToBuild.Enabled = false
    end

    local timer = Timer.new(1)

    timer.Tick:Connect(function()
        local timeLeft = math.clamp(self.State:Get("ConstructionTimeLeft") - 1, 0, self.State:Get("ConstructionTime"))
        self.State:Set("ConstructionTimeLeft", timeLeft)

        if timeLeft <= 0 then
            timer:Destroy()
        end
    end)

    timer:Start()

    self.hammerInstance = HammerInstance:Clone()
    CollectionService:AddTag(self.hammerInstance, "Hammer")
    self.hammerInstance.Parent = self.Instance

    Hammer:WaitForInstance(self.hammerInstance):andThen(function(hammerComponent)
        hammerComponent:SetGon(self.Instance)
        hammerComponent:StartTimer(constructionTime)
    end)
end

function Gon:ConstructionComplete()
    if self.TimeToBuild then
        self.TimeToBuild.Enabled = false
    end
    SoundService:PlayLocalSound(self.Instance:WaitForChild("ConstructionComplete"))

    task.spawn(function()
        self.State:GetChangedSignal("HasBuildingComponent"):wait()

        local constructionCompleteParticles = Assets.Particles.ConstructionComplete:Clone()
        constructionCompleteParticles.Parent = self.BuildingComponent.Instance.PrimaryPart

        constructionCompleteParticles:Emit(5)

        Debris:AddItem(constructionCompleteParticles, 1)
    end)
end

return Gon