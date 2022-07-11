local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local Components = Client.Components
local Building = require(Components.Building)

local Knit = require(KnitPackages.Knit)
local Promise = require(Knit.Util.Promise)
local Input = require(Knit.Util.Input)
local Mouse = Input.Mouse.new()

local PlotController = Knit.CreateController {
    Name = "PlotController",
    PlotsTaken = {}
}

function PlotController:KnitStart()
    local PlotService = Knit.GetService("PlotService")
    local plots = PlotService:GetPlots()

    --[[

    PlotService:GetPlots():andThen(function(plots)
        --self.localPlot = plots[1]
        self.localPlot = plots[math.random(1, #plots)]
    end)
    ]]--
    --[[
    local Plots = workspace:WaitForChild("Plots")

    for _, PlotPoint in pairs(Plots:GetChildren()) do
        local plotGons = {}

        local plotGonsCountX = 5
        local plotGonsCountY = plotGonsCountX - 1
        local plotGonSize = 8

        for xIndex = 1, plotGonsCountX do
            local gon = Gon:Clone()
            gon.Position = Vector3.new(PlotPoint.Position.X - ((xIndex - 1) * plotGonSize), -0.05, PlotPoint.Position.Z)
            gon.Parent = PlotPoint

            table.insert(plotGons, gon)

            for yIndex = 1, plotGonsCountY do
                local yGon = Gon:Clone()
                --yGon.Position = Vector3.new(PlotPoint.Position.X - ((xIndex - (plotGonsCountX / 2)) * plotGonSize), -0.05, ((yIndex - (plotGonsCountY / 2)) * plotGonSize))
                yGon.Position = gon.Position + Vector3.new(0, 0, ((yIndex) * plotGonSize))
                yGon.Parent = PlotPoint

                table.insert(plotGons, yGon)
            end
        end

        table.insert(self.PlotsTaken, plotGons)
    end

    self.localPlot = self.PlotsTaken[1]
    ]]--

    PlotService.PlotClaimed:Connect(function(plot)
        if plot.Owner == game.Players.LocalPlayer then
            self.localPlot = plot

            local localPlotHighlight = Assets:WaitForChild("LocalPlotHighlight"):Clone()
            localPlotHighlight:SetPrimaryPartCFrame(self.localPlot.PlotPoint.CFrame)
            localPlotHighlight.Parent = self.localPlot.PlotPoint

            local renderSteppedConnection
            local highlightFading = false

            renderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local character = game.Players.LocalPlayer.Character
                if character then
                    if character:FindFirstChild("HumanoidRootPart") then
                        if (character:FindFirstChild("HumanoidRootPart").Position - self.localPlot.PlotPoint.Position).Magnitude <= 35 then
                            renderSteppedConnection:Disconnect()
                            if not highlightFading then
                                highlightFading = true
                                SoundService:PlayLocalSound(SoundService.Interface.FoundPlot)
                                for _, attachment in pairs(localPlotHighlight:GetDescendants()) do
                                    if attachment:IsA("Attachment") then
                                        local tween = TweenService:Create(attachment, TweenInfo.new(1), {Position = Vector3.new(0, -50, 19.5)})
                                        tween:Play()
                                    end
                                end

                                Debris:AddItem(localPlotHighlight, 2)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

function PlotController:PlotSelected()
    return Promise.new(function(resolve)
        local heartbeatConnection

        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if self.localPlot then
                heartbeatConnection:Disconnect()
                resolve(self.localPlot)
            end
        end)
    end)
end

return PlotController