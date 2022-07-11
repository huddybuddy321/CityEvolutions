local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Building = require(Components.Building)
local Gon = require(Components.Gon)

local Knit = require(KnitPackages.Knit)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local GonSelectorController = Knit.CreateController {
    Name = "GonSelectorController",
}

function GonSelectorController:KnitStart()
    local BuildingService = Knit.GetService("BuildingService")

    local PlotController = Knit.GetController("PlotController")
    PlotController:PlotSelected():andThen(function(localPlot)
        local raycastParams = RaycastParams.new()

        raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
        raycastParams.FilterDescendantsInstances = {workspace:WaitForChild("Plots")}

        RunService.RenderStepped:Connect(function()
            local foundGon = false

            local raycastResult = Mouse:Raycast(raycastParams, 60)

            if raycastResult then
                --if raycastResult.Instance:FindFirstAncestor("Plots") then
                    for gonIndex, gon in pairs(localPlot.Gons) do
                        if gon == raycastResult.Instance then
                            foundGon = true
                            if not self.selectedGonInstance then
                                self.selectedGonInstance = gon
                                
                                local gonComponent = Gon:FromInstance(gon)
                                gonComponent.State:Set("Hovered", true)
                            end
                        end
                    end
                --end
            end

            if not foundGon then
                for _, gonComponent in pairs(Gon:GetAll()) do
                    gonComponent.State:Set("Hovered", false)
                end

                --[[
                 for gonIndex, gon in pairs(localPlot) do
                    gon.Decal.Transparency = 0.5
                end

                ]]--

                self.selectedGonInstance = nil
            end
        end)

        ContextActionService:BindAction("BuildOnGon", function(actionName, inputState)
            if inputState == Enum.UserInputState.End then
                local raycastResult = Mouse:Raycast(raycastParams, 60)

                if raycastResult then
                    --if raycastResult.Instance:FindFirstAncestor("Plots") then
                        for gonIndex, gon in pairs(localPlot.Gons) do
                            if gon == raycastResult.Instance then
                                local gonComponent = Gon:FromInstance(gon)

                                if gonComponent then
                                    gonComponent:Click()
                                end
            
                                if gonComponent and not gonComponent.State:Get("HasBuildingComponent") then
                                    gonComponent.State:Set("Constructing", BuildingService:Build(gonComponent.Instance))
                                end
                            end
                        end
                    --end
                end
                --[[
                print("Clicked")
                if self.selectedGonInstance then
                    local gonComponent = Gon:FromInstance(self.selectedGonInstance)

                    if gonComponent then
                        gonComponent:Click()
                    end

                    if gonComponent and not gonComponent.State:Get("HasBuildingComponent") then
                        BuildingService.BuildBuilding:Fire(gonComponent.Instance, "Housing1")
                    end
                end
                ]]--
            end
        end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
    end)
end

return GonSelectorController