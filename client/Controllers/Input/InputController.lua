local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
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
local Signal = require(Knit.Util.Signal)

local InputController = Knit.CreateController {
    Name = "InputController",
    Clicked = Signal.new()
}

function InputController:KnitStart()
    ContextActionService:BindAction("Click", function(actionName, inputState)
        if inputState == Enum.UserInputState.End then
            self.Clicked:Fire()
        end
    end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
end

return InputController