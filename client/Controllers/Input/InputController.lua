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
    Clicked = Signal.new(),
    ClickDown = Signal.new(),
    ClickUp = Signal.new()
}

function InputController:KnitStart()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.ClickDown:Fire(gameProcessed)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Clicked:Fire(gameProcessed)
            self.ClickUp:Fire(gameProcessed)
        end
    end)
    --[[
    ContextActionService:BindAction("Click", function(actionName, inputState)
        if inputState == Enum.UserInputState.Begin then
            self.ClickDown:Fire()
        end
        if inputState == Enum.UserInputState.End then
            self.Clicked:Fire()
            self.ClickUp:Fire()
        end
    end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
    ]]--
end

return InputController