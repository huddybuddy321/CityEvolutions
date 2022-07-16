local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon
local Beams = Assets.Beams

local Packages = ReplicatedStorage.Packages
local BasicState = require(Packages.BasicState)
local RemoteState = require(Packages.RemoteState)

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Citizen = require(Components.Citizen)

local KnitPackages = Packages.KnitPackages
local Knit = require(KnitPackages.Knit)
local Signal = require(Knit.Util.Signal)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local CitizenService
local GonSelectorController

local CitizenSelectorController = Knit.CreateController {
    Name = "CitizenSelectorController",
    CitizenAssignedToGon = Signal.new(),
}

function CitizenSelectorController:KnitStart()
    CitizenService = Knit.GetService("CitizenService")

    GonSelectorController = Knit.GetController("GonSelectorController")

    local raycastParams = RaycastParams.new()

    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    raycastParams.FilterDescendantsInstances = {workspace:WaitForChild("CitizenZone"):WaitForChild("Citizens")}

    Knit.GetController("InputController").ClickDown:Connect(function()
        local raycastResult = Mouse:Raycast(raycastParams, 70)

        if raycastResult then
            local citizenComponent = Citizen:FromInstance(raycastResult.Instance.Parent)
            if citizenComponent then
                self.selectedCitizenComponent = citizenComponent

                self:StartDrag(citizenComponent)

                --[[

                local citizenState = RemoteState.GetState(citizenComponent.Instance)

                if citizenState:Get("TargetState") ~= "Player" then
                    CitizenService:SelectCitizen(raycastResult.Instance.Parent):andThen(function(result)
                        if result then
                            local beam = Beams.Follow:Clone()
                            beam.Parent = citizenComponent.Instance.HumanoidRootPart

                            local attachment0 = Instance.new("Attachment", citizenComponent.Instance.HumanoidRootPart)
                            local attachment1 = Instance.new("Attachment", game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"))

                            beam.Attachment0 = attachment0
                            beam.Attachment1 = attachment1
            
                            local stateChangedSignal
                            stateChangedSignal = citizenState:GetChangedSignal("TargetState"):Connect(function(value)
                                if value ~= "Player" then
                                    stateChangedSignal:Disconnect()
                                    beam:Destroy()
                                    attachment0:Destroy()
                                    attachment1:Destroy()
                                end
                            end)

                            --[[

                            local citizenAssignedToGonConnection
                            citizenAssignedToGonConnection = self.CitizenAssignedToGon:Connect(function(citizenInstance)
                                if citizenInstance == citizenComponent.Instance then
                                    citizenAssignedToGonConnection:Disconnect()
                                    beam:Destroy()
                                    attachment0:Destroy()
                                    attachment1:Destroy()
                                end
                            end)
                        end
                    end)
                end
                ]]--
            end
        end
    end)

    Knit.GetController("InputController").ClickUp:Connect(function()
        if self.selectedCitizenComponent then
            self:EndDrag(self.selectedCitizenComponent)
        end
    end)
end

function CitizenSelectorController:StartDrag(citizenComponent)
    SoundService:PlayLocalSound(SoundService.Interface.Click)

    citizenComponent:StartDrag()

    CitizenService:StartDrag(citizenComponent)

    self.renderSteppedConnection = RunService.RenderStepped:Connect(function()
        local citizenDragRaycastParams = RaycastParams.new()

        citizenDragRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        citizenDragRaycastParams.FilterDescendantsInstances = {workspace:WaitForChild("CitizenZone"):WaitForChild("Citizens")}

        local citizenDragRaycastResult = Mouse:Raycast(citizenDragRaycastParams, 70)

        if citizenDragRaycastResult and citizenComponent.Instance:FindFirstChild("HumanoidRootPart") then
            citizenComponent.Instance:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(citizenDragRaycastResult.Position)
        end
    end)
end

function CitizenSelectorController:EndDrag(citizenComponent)
    if self.renderSteppedConnection then
        self.renderSteppedConnection:Disconnect()

        if GonSelectorController.selectedGonInstance then
            CitizenService:AssignCitizenGon(citizenComponent.Instance, GonSelectorController.selectedGonInstance):andThen(function(citizenAssignedToGon)
                if citizenAssignedToGon then
                    SoundService:PlayLocalSound(SoundService.Interface.Click)
                else
                    citizenComponent:EndDrag()
                end
            end)
        else
            citizenComponent:EndDrag()
        end
    end
end

return CitizenSelectorController