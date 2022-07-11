local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local KnitPackages = Packages.KnitPackages

local Client = script:FindFirstAncestor("Client")
local Controllers = Client.Controllers
local Components = Client.Components
--local Components = Server.Components

local Knit = require(KnitPackages.Knit)

for _, component in pairs(Components:GetDescendants()) do
    if component:IsA("ModuleScript") then
        require(component)
    end
end

Knit.AddControllersDeep(Controllers)

Knit.Start():catch(warn)

print("Knit started!")