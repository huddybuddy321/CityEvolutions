local Player = game.Players.LocalPlayer

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers

local BasicState = require(Packages.BasicState)

local Knit = require(KnitPackages.Knit)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)

local Hammer = Component.new({
    Tag = "Hammer",
    Ancestors = {workspace},
})

function Hammer:Construct()
    self.State = BasicState.new {
        Direction = "Rise",
    }
end

function Hammer:SetGon(gonInstance)
    self.gonInstance = gonInstance
    self.Instance.CFrame = self.gonInstance.CFrame + Vector3.new(0, 3, 2)
    self.Instance.CFrame = CFrame.lookAt(self.Instance.Position, self.gonInstance.Position + Vector3.new(0, 3, 0))
end

function Hammer:SpawnDust()
    local dust = Assets.Dust:Clone()
    --dust.ParticleEmitter.Rate = 0
    dust.Gust.Rate = 0
    dust.Impact.Rate = 0
    dust.Position = self.gonInstance.Position + Vector3.new(0, 2, 0)
    dust.Parent = workspace

    --[[

    task.spawn(function()
        local rateTween1 = TweenService:Create(dust.ParticleEmitter, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {Rate = 30})
        rateTween1:Play()

        SoundService:PlayLocalSound(self.Instance:WaitForChild("Whoosh"))

        task.wait(0.5)

        --local gustFadeTween = TweenService:Create(dust.Gust, TweenInfo.new(0.4), {Rate = 0})
        --gustFadeTween:Play()

        local disapearTween = TweenService:Create(dust.ParticleEmitter, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Rate = 0})
        disapearTween:Play()
        disapearTween.Completed:Wait()
    end)

    ]]--

    task.spawn(function()
        task.wait(0.1)
        dust.Impact:Emit(1)
    end)

    task.spawn(function()
        task.wait(0.15)

        dust.Gust:Emit(2)

        --[[

        local gustStartTween = TweenService:Create(dust.Gust, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {Rate = 8})
        gustStartTween:Play()
        
        gustStartTween.Completed:Wait()
    
        task.wait(0.2)

        local gustFadeTween = TweenService:Create(dust.Gust, TweenInfo.new(0.2), {Rate = 0})
        gustFadeTween:Play()

        gustFadeTween.Completed:Wait()

        task.wait(0.5)

        ]]--
    end)

    Debris:AddItem(dust, 3)
end

function Hammer:StartTimer(constructionTime)
    if self.heartbeatConnection then self.heartbeatConnection:Disconnect() end

    local lastTick = tick()

    self.heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not self.currentTween then
            if self.State:Get("Direction") == "Rise" then
                self.currentTween = TweenService:Create(self.Instance, TweenInfo.new(.2, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(self.Instance.Position, self.gonInstance.Position + Vector3.new(0, 5, 0))})--self.Instance.CFrame * CFrame.Angles(math.rad(30), 0, 0)})
                self.currentTween:Play()
            end
            if self.State:Get("Direction") == "Down" then
                self.currentTween = TweenService:Create(self.Instance, TweenInfo.new(.5, Enum.EasingStyle.Exponential), {CFrame = CFrame.lookAt(self.Instance.Position, self.gonInstance.Position)})--CFrame = self.Instance.CFrame * CFrame.Angles(math.rad(-120), 0, 0)})
                self.currentTween:Play()
                task.spawn(function()
                    SoundService:PlayLocalSound(self.Instance:WaitForChild("Whoosh"))
                    self:SpawnDust()
                    task.wait(0.15)
                    --self:SpawnDust()
                    SoundService:PlayLocalSound(self.Instance:WaitForChild("Hit"))
                end)
            end
            if self.State:Get("Direction") == "Up" then
                self.currentTween = TweenService:Create(self.Instance, TweenInfo.new(.5, Enum.EasingStyle.Exponential), {CFrame = CFrame.lookAt(self.Instance.Position, self.gonInstance.Position + Vector3.new(0, 3, 0))})
                self.currentTween:Play()
            end
        else
            if self.currentTween.PlaybackState == Enum.PlaybackState.Completed then
                if self.State:Get("Direction") == "Rise" then
                    self.State:Set("Direction", "Down")
                elseif self.State:Get("Direction") == "Down" then
                    self.State:Set("Direction", "Up")
                elseif self.State:Get("Direction") == "Up" then
                    self.State:Set("Direction", "Rise")
                end
                self.currentTween = nil
            end
        end

        if tick() - lastTick >= constructionTime then
            if self.currentTween then
                self.currentTween:Cancel()
                self.heartbeatConnection:Disconnect()
                self.State:Set("Direction", "Rise")

                task.spawn(function()
                    for _, basePart in {self.Instance, unpack(self.Instance:GetChildren())} do
                        if basePart:IsA("BasePart") then
                            TweenService:Create(basePart, TweenInfo.new(0.5), {Transparency = 1}):Play()
                        end
                    end
                end)
            end
        end
    end)
end

return Hammer