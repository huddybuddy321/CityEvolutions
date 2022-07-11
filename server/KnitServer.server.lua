local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Server = script:FindFirstAncestor("Server")
local Services = Server.Services
local Components = Server.Components
--local Components = Server.Components

local Knit = require(KnitPackages.Knit)

for _, component in pairs(Components:GetDescendants()) do
    if component:IsA("ModuleScript") then
        require(component)
    end
end

Knit.AddServicesDeep(Services)

Knit.Start():catch(warn)

print("Knit started!")