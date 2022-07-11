local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Gon = Assets.Gon

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services

local Knit = require(KnitPackages.Knit)
local Promise = require(Knit.Util.Promise)

local PlotService = Knit.CreateService {
    Name = "PlotService",
    Plots = {},
    Client = {
        PlotClaimed = Knit.CreateSignal()
    }
}

function PlotService.Client:GetPlots()
    return self.Server:GetPlots()
end

function PlotService:GetPlots()
    return self.Plots
end

function PlotService:KnitStart()
    local Plots = workspace:WaitForChild("Plots")

    for index, PlotPoint in pairs(Plots:GetChildren()) do
        local plotPosition = PlotPoint.Position
        plotPosition = Vector3.new(plotPosition.X, -0.05, plotPosition.Z)

        local directions = {
            left = Vector3.new(-5, 0, 0),
            right = Vector3.new(5, 0, 0),
            forward = Vector3.new(0, 0, 5),
            backward = Vector3.new(0, 0, -5)
        }

        local closestDirection
        local closestDirectionDistance

        for _, direction in pairs(directions) do
            local directionDistance = (plotPosition + direction - Vector3.zero).Magnitude

            if not closestDirection then
                closestDirection = direction
                closestDirectionDistance = directionDistance
            else
                if directionDistance < closestDirectionDistance then
                    closestDirection = direction
                    closestDirectionDistance = directionDistance
                end
            end
        end

        local gonPointDirection = closestDirection

        local plotGons = {}

        local plotGonsCount = 5
        local plotGonSize = 8

        local currentRow = 1
        local currentRowCount = 0

        for i = 1, plotGonsCount^2 do
            local gon = Gon:Clone()

            gon.Position = Vector3.new(
                --PlotPoint.Position.X - ((plotGonsCount/2)*plotGonSize) + (currentRowCount*plotGonSize),
                PlotPoint.Position.X - ((currentRowCount - (plotGonsCount/2))*plotGonSize + plotGonSize/2),
                -0.05,
                PlotPoint.Position.Z - ((plotGonsCount/2)*plotGonSize) + (currentRow*plotGonSize - plotGonSize/2)
            )

            gon.CFrame = CFrame.lookAt(gon.Position, gon.Position + gonPointDirection)

            currentRowCount += 1

            if currentRowCount >= plotGonsCount then
                --New row
                currentRow += 1
                currentRowCount = 0
            end

            gon.Parent = PlotPoint

            table.insert(plotGons, gon)
        end

        --[[

        for xIndex = 1, plotGonsCountX do
            local gon = Gon:Clone()
            print("STARTT")
            gon.Position = Vector3.new(PlotPoint.Position.X - (xIndex * plotGonSize) + (((plotGonsCountX + 1)/2)*plotGonSize), -0.05, PlotPoint.Position.Z)
            --gon.Position = Vector3.new(PlotPoint.Position.X - ((xIndex - 1) * plotGonSize), -0.05, PlotPoint.Position.Z)
            gon.Parent = PlotPoint

            table.insert(plotGons, gon)

            local left = {}
            local right = {}

            for yIndex = 1, plotGonsCountY do
                --local yGon = Gon:Clone()
                --print(yIndex - (plotGonsCountY/2) - 1)
                --print((yIndex - (plotGonsCountY/2) - 1) * plotGonSize)
               -- print(yIndex, (yIndex - (plotGonsCountY / 2)) * plotGonSize)
                yGon.Position = gon.Position + Vector3.new(0, 0, ((yIndex) * plotGonSize) - ((plotGonsCountY/2)*plotGonSize))

                if yIndex <= (plotGonsCountY/2) then
                    table.insert(left, yIndex - plotGonsCountY / 2)
                else
                    table.insert(right, yIndex - plotGonsCountY / 2)
                end

                --yGon.Position = gon.Position + Vector3.new(0, 0, ((yIndex) * plotGonSize))
                --yGon.Parent = PlotPoint

                --table.insert(plotGons, yGon)
            end

            for l
        end
        ]]--

        local sign = PlotPoint:WaitForChild("Sign")
        sign.Base.SurfaceGui.EmptyPlot.Visible = true
        sign.Base.SurfaceGui.PlotTaken.Visible = false

        local plotNumber = string.sub(PlotPoint.Name, string.len("PlotPoint") + 1, string.len(PlotPoint.Name))

        self.Plots[plotNumber] = {
            PlotNumber = plotNumber,
            PlotPoint = PlotPoint,
            Gons = plotGons
        }
    end

    game.Players.PlayerAdded:Connect(function(player)
        local foundOpenPlot = false
        for _, plot in pairs(self.Plots) do
            if not foundOpenPlot then
                if not plot.Owner then
                    local sign = plot.PlotPoint:WaitForChild("Sign")
                    sign.Base.SurfaceGui.EmptyPlot.Visible = false
                    sign.Base.SurfaceGui.PlotTaken.Visible = true
                    sign.Base.SurfaceGui.PlotTaken.PlotOwner.Text = player.Name .. "'s plot"
                    sign.Base.SurfaceGui.PlotTaken.OwnerIcon.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)

                    foundOpenPlot = true
                    plot.Owner = player
                    self.Client.PlotClaimed:FireAll(plot)
                end
            end
        end
    end)
end

return PlotService