-- Put this LocalScript in StarterPlayer > StarterPlayerScripts.
-- It shows the player's name only on their own personal base.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local world = Workspace:WaitForChild("BrawlWorld")
local personalBases = world:WaitForChild("PersonalBases")

local function refreshBase(base)
	local sign = base:FindFirstChild("OwnerSign")
	if not sign then
		return
	end

	local privateGui = sign:FindFirstChild("OwnerOnlyDisplay")
	if not privateGui then
		return
	end

	local isMyBase = base:GetAttribute("OwnerUserId") == localPlayer.UserId
	privateGui.Enabled = isMyBase
	if isMyBase then
		local label = privateGui:FindFirstChild("OwnerName")
		if label then
			label.Text = localPlayer.DisplayName .. "'S BASE"
		end
	end
end

local function watchBase(base)
	refreshBase(base)
	base:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		refreshBase(base)
	end)
end

for _, base in ipairs(personalBases:GetChildren()) do
	watchBase(base)
end

personalBases.ChildAdded:Connect(watchBase)
