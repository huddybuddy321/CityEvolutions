local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage.Assets
local Buildings = Assets.Buildings

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local Knit = require(KnitPackages.Knit)

local BuildingService = Knit.CreateService {
    Name = "BuildingService",
    GonsConstructing = {},
    Client = {
        BuildBuilding = Knit.CreateSignal(),
        ReplicateBuilding = Knit.CreateSignal(),
        ConstructOnGon = Knit.CreateSignal(),
        ConstructionComplete = Knit.CreateSignal()
    }
}

function BuildingService.Client:Build(player, gonInstance)
    return self.Server:Build(player, gonInstance)
end

function BuildingService:Build(player, gonInstance)
    local buildingName = Knit.GetService("EvolutionService"):GetRandomBuildingFromEvolution(Knit.GetService("EvolutionService"):GetPlayerEvolution(player))
    print(buildingName)

    local didBuild = false
    if Buildings:FindFirstChild(buildingName) and not self.GonsConstructing[gonInstance] then
        didBuild = true
        --[[
        local buildingInstance = Buildings[buildingName]:Clone()
        CollectionService:AddTag(buildingInstance, "Building")
        buildingInstance:SetPrimaryPartCFrame(CFrame.new(gonInstance.Position + Vector3.new(0, buildingInstance.PrimaryPart.Size.Y / 2, 0)))
        buildingInstance.Parent = workspace

        self.Client.ReplicateBuilding:FireAll(buildingInstance, gonInstance)
        ]]--

        task.spawn(function()
            self.GonsConstructing[gonInstance] = {constructionTime = 5, constructionStartTime = tick(), gonInstance = gonInstance}--gonInstance
            self.Client.ConstructOnGon:FireAll(gonInstance, 5)
            task.wait(5)
            local buildingInstance = Buildings[buildingName]:Clone()
            CollectionService:AddTag(buildingInstance, "Building")
            buildingInstance:SetPrimaryPartCFrame(gonInstance.CFrame + Vector3.new(0, buildingInstance.PrimaryPart.Size.Y / 2, 0))
            buildingInstance.Parent = workspace

            self.GonsConstructing[gonInstance] = nil

            self.Client.ReplicateBuilding:FireAll(buildingInstance, gonInstance)
            self.Client.ConstructionComplete:FireAll(gonInstance)
        end)
    end

    return didBuild
end

function BuildingService:KnitStart()
    self.Client.BuildBuilding:Connect(function(player, gonInstance, buildingName)
        self:Build(player, buildingName, gonInstance)
    end)

    game.Players.PlayerAdded:Connect(function(player)
        --Update players on gons being constructed
        for _, gon in pairs(self.GonsConstructing) do
            self.Client.ConstructOnGon:Fire(player, gon.gonInstance, gon.constructionTime - (tick - gon.constructionStartTime))
        end
    end)
end

return BuildingService