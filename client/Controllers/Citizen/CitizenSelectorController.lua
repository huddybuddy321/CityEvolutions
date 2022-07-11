local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Citizen = require(Components.Citizen)

local Knit = require(KnitPackages.Knit)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local CitizenSelectorController = Knit.CreateController {
    Name = "CitizenSelectorController",
}

function CitizenSelectorController:KnitStart()
    local CitizenService = Knit.GetService("CitizenService")

    Mouse.LeftDown:Connect(function()
        local raycastParams = RaycastParams.new()

        raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
        raycastParams.FilterDescendantsInstances = {workspace:WaitForChild("CitizenZone"):WaitForChild("Citizens")}

        local raycastResult = Mouse:Raycast(raycastParams, 70)

        if raycastResult then
            local citizenComponent = Citizen:FromInstance(raycastResult.Instance.Parent)
            if citizenComponent then
                self.selectedCitizenComponent = citizenComponent
                CitizenService:SelectCitizen(raycastResult.Instance.Parent)
            end
        end
    end)
end

return CitizenSelectorController