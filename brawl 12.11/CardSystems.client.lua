-- LocalScript in StarterPlayer > StarterPlayerScripts.
-- Collection/trading UI and the 3D case-opening scene. Cases are opened at the base conveyor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("CardGameRemotes")
local tradeRequest = remotes:WaitForChild("TradeRequest")
local tradeReply = remotes:WaitForChild("TradeReply")
local tradeOffer = remotes:WaitForChild("TradeOffer")
local tradeResult = remotes:WaitForChild("TradeResult")
local inventoryUpdate = remotes:WaitForChild("InventoryUpdate")
local caseReveal = remotes:WaitForChild("CaseReveal")
local setHotbar = remotes:WaitForChild("SetHotbar")
local placeFighter = remotes:WaitForChild("PlaceFighter")

local gui = Instance.new("ScreenGui")
gui.Name = "CardGameGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function make(className, properties, parent)
	local object = Instance.new(className)
	for key, value in pairs(properties) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local panel = make("Frame", {
	Name = "InventoryPanel",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.new(0.34, 0, 0, 310),
	BackgroundColor3 = Color3.fromRGB(34, 27, 62),
	BackgroundTransparency = 0.08,
}, gui)
panel.Visible = false
make("UISizeConstraint", { MinSize = Vector2.new(250, 260), MaxSize = Vector2.new(350, 330) }, panel)
make("UICorner", { CornerRadius = UDim.new(0, 14) }, panel)
make("UIStroke", { Color = Color3.fromRGB(255, 205, 45), Thickness = 2 }, panel)

make("TextLabel", {
	Size = UDim2.new(1, -20, 0, 42), Position = UDim2.fromOffset(10, 8),
	BackgroundTransparency = 1, Text = "ИНВЕНТАРЬ БОЙЦОВ",
	TextColor3 = Color3.fromRGB(255, 220, 70), TextScaled = true,
	Font = Enum.Font.GothamBlack,
}, panel)

local inventoryList = make("ScrollingFrame", {
	Name = "InventoryList", Size = UDim2.new(1, -24, 0, 150),
	Position = UDim2.fromOffset(12, 56), BackgroundColor3 = Color3.fromRGB(21, 20, 38),
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 6, ScrollingDirection = Enum.ScrollingDirection.Y,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, inventoryList)
make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, inventoryList)
make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, inventoryList)

local status = make("TextLabel", {
	Name = "Status", Size = UDim2.new(1, -24, 0, 42), Position = UDim2.fromOffset(12, 212),
	BackgroundTransparency = 1, Text = "Кейсы покупаются у конвейера на твоей базе.",
	TextColor3 = Color3.fromRGB(225, 225, 235), TextSize = 14,
	Font = Enum.Font.Gotham, TextWrapped = true,
}, panel)

local tradeButton = make("TextButton", {
	Size = UDim2.new(1, -24, 0, 42), Position = UDim2.fromOffset(12, 260),
	BackgroundColor3 = Color3.fromRGB(130, 45, 220),
	Text = "ОБМЕН С ИГРОКОМ РЯДОМ", TextColor3 = Color3.new(1, 1, 1),
	TextSize = 16, TextWrapped = true, Font = Enum.Font.GothamBold,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, tradeButton)

local inventoryToggle = make("TextButton", {
	Name = "InventoryButton", Size = UDim2.fromOffset(150, 42), Position = UDim2.fromOffset(16, 72),
	BackgroundColor3 = Color3.fromRGB(34, 27, 62), Text = "ИНВЕНТАРЬ",
	TextColor3 = Color3.fromRGB(255, 220, 70), TextSize = 17, Font = Enum.Font.GothamBlack,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, inventoryToggle)
make("UIStroke", { Color = Color3.fromRGB(255, 205, 45), Thickness = 2 }, inventoryToggle)

local quickbar = {}
local selectedFighter
local renderHotbar
local quickbarFrame = make("Frame", {
	Name = "Quickbar", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12),
	Size = UDim2.new(0.76, 0, 0, 66), BackgroundTransparency = 1,
}, gui)
local quickStatus = make("TextLabel", {
	Name = "QuickStatus", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -4),
	Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = "",
	TextColor3 = Color3.new(1, 1, 1), TextSize = 16, Font = Enum.Font.GothamBold,
}, quickbarFrame)
local quickbarButtons = {}
for slotIndex = 1, 5 do
	local slotButton = make("TextButton", {
		Name = "Slot" .. slotIndex, Size = UDim2.new(0.19, 0, 1, 0),
		Position = UDim2.new((slotIndex - 1) * 0.202, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(34, 27, 62), Text = tostring(slotIndex) .. "\n—",
		TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextWrapped = true, Font = Enum.Font.GothamBold,
	}, quickbarFrame)
	make("UICorner", { CornerRadius = UDim.new(0, 9) }, slotButton)
	make("UIStroke", { Color = Color3.fromRGB(95, 85, 130), Thickness = 1 }, slotButton)
	quickbarButtons[slotIndex] = slotButton
end

local inventory = {}
local activeTrade
local tradeForm

local function renderInventory()
	for _, child in ipairs(inventoryList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	local cardNames = {}
	for cardName, amount in pairs(inventory) do
		if amount > 0 then table.insert(cardNames, cardName) end
	end
	table.sort(cardNames)
	if #cardNames == 0 then
		make("TextLabel", {
			Size = UDim2.new(1, -8, 0, 54), BackgroundTransparency = 1,
			Text = "Пока нет бойцов.\nОткрой кейс у конвейера!", TextColor3 = Color3.new(1, 1, 1),
			TextSize = 16, TextWrapped = true, Font = Enum.Font.GothamMedium,
		}, inventoryList)
		return
	end
	for order, cardName in ipairs(cardNames) do
		local row = make("TextButton", {
			Name = "Card_" .. cardName, Size = UDim2.new(1, -8, 0, 38),
			LayoutOrder = order, BackgroundColor3 = Color3.fromRGB(60, 48, 98),
			Text = cardName .. " × " .. inventory[cardName] .. "     + В быстрый доступ",
			TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextWrapped = true,
			Font = Enum.Font.GothamBold,
		}, inventoryList)
		make("UICorner", { CornerRadius = UDim.new(0, 7) }, row)
		row.Activated:Connect(function()
			local exists = false
			for _, equipped in pairs(quickbar) do
				if equipped == cardName then exists = true; break end
			end
			if exists then
				quickStatus.Text = cardName .. " уже в быстром доступе."
				return
			end
			local slotIndex
			for index = 1, 5 do
				if not quickbar[index] then slotIndex = index; break end
			end
			if not slotIndex then slotIndex = 1 end
			quickbar[slotIndex] = cardName
			setHotbar:FireServer(quickbar)
			quickStatus.Text = cardName .. " добавлен в слот " .. slotIndex .. ". Нажми его снизу, затем кликни свою базу."
			renderHotbar()
		end)
	end
end

renderHotbar = function()
	for index, slotButton in ipairs(quickbarButtons) do
		local cardName = quickbar[index]
		if cardName then
			slotButton.Text = tostring(index) .. "\n" .. cardName
		else
			slotButton.Text = tostring(index) .. "\n—"
		end
		if selectedFighter and selectedFighter == cardName then
			slotButton.BackgroundColor3 = Color3.fromRGB(80, 58, 145)
		else
			slotButton.BackgroundColor3 = Color3.fromRGB(34, 27, 62)
		end
	end
end

for index, slotButton in ipairs(quickbarButtons) do
	slotButton.Activated:Connect(function()
		local cardName = quickbar[index]
		if not cardName then
			quickStatus.Text = "Открой кейс и добавь бойца в быстрый доступ через инвентарь."
			return
		end
		if selectedFighter == cardName then
			selectedFighter = nil
			quickStatus.Text = "Размещение отменено."
		else
			selectedFighter = cardName
			quickStatus.Text = "Выбран " .. cardName .. ": кликни по свободному месту своей базы."
		end
		renderHotbar()
	end)
end

inventoryToggle.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then renderInventory() end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not selectedFighter then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local mouse = player:GetMouse()
	local target = mouse.Target
	local world = workspace:FindFirstChild("BrawlWorld")
	local bases = world and world:FindFirstChild("PersonalBases")
	local ownBase
	if bases then
		for _, base in ipairs(bases:GetChildren()) do
			if base:GetAttribute("OwnerUserId") == player.UserId then ownBase = base; break end
		end
	end
	if target and ownBase and target.Name == "BaseColorInset" and target:IsDescendantOf(ownBase) then
		placeFighter:FireServer(selectedFighter, mouse.Hit.Position)
		quickStatus.Text = "Ставлю " .. selectedFighter .. " на базу..."
		selectedFighter = nil
		renderHotbar()
	else
		quickStatus.Text = "Кликни по полу внутри своей базы, чтобы поставить бойца."
	end
end)

local function scenePart(parent, name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Material = material or Enum.Material.SmoothPlastic
	part.Color = color
	part.Parent = parent
	return part
end

local function createFighter(worldModel, fighterName, accent, rarity)
	-- Use the detailed imported mesh for Edgar when it is available.
	if fighterName == "Эдгар" then
		local template = ReplicatedStorage:FindFirstChild("EdgarModel")
		if template and template:IsA("Model") then
			local imported = template:Clone()
			imported.Name = fighterName
			for _, item in ipairs(imported:GetDescendants()) do
				if item:IsA("BasePart") then
					item.Anchored = true
					item.CanCollide = false
					item.CastShadow = true
					local partName = string.lower(item.Name)
					if string.find(partName, "scarf") then
						item.Color = Color3.fromRGB(142, 62, 220)
					elseif string.find(partName, "jacket_red") or string.find(partName, "trouser_stripe") then
						item.Color = Color3.fromRGB(205, 45, 60)
					elseif string.find(partName, "hair") then
						item.Color = Color3.fromRGB(28, 33, 58)
					elseif string.find(partName, "head") or string.find(partName, "neck") or string.find(partName, "forearm") then
						item.Color = Color3.fromRGB(242, 204, 184)
					elseif string.find(partName, "visible_eye_white") or string.find(partName, "shoe") or string.find(partName, "tongue") then
						item.Color = Color3.fromRGB(235, 235, 250)
					elseif string.find(partName, "eye") then
						item.Color = Color3.fromRGB(18, 16, 28)
					elseif string.find(partName, "gold") or string.find(partName, "buckle") then
						item.Color = Color3.fromRGB(255, 194, 55)
					elseif string.find(partName, "sole") then
						item.Color = Color3.fromRGB(60, 42, 100)
					elseif string.find(partName, "glove") or string.find(partName, "belt") then
						item.Color = Color3.fromRGB(112, 54, 180)
					elseif string.find(partName, "jacket") or string.find(partName, "trouser") or string.find(partName, "torso") or string.find(partName, "shirt") or string.find(partName, "sleeve") or string.find(partName, "arm") then
						item.Color = Color3.fromRGB(31, 29, 55)
					end
				end
			end
			imported.Parent = worldModel
			local _, originalSize = imported:GetBoundingBox()
			if originalSize.Y > 0 then
				imported:ScaleTo(math.clamp(6.4 / originalSize.Y, 0.2, 3))
			end
			local boundsCFrame, boundsSize = imported:GetBoundingBox()
			local pivotToBounds = imported:GetPivot():ToObjectSpace(boundsCFrame)
			local targetBounds = CFrame.new(0, -2.3 + boundsSize.Y / 2, 0) * CFrame.Angles(0, math.rad(180), 0)
			imported:PivotTo(targetBounds * pivotToBounds:Inverse())

			local effectPart = imported:FindFirstChild("Torso_base", true)
			if not (effectPart and effectPart:IsA("BasePart")) then
				effectPart = imported:FindFirstChildWhichIsA("BasePart", true)
			end
			if effectPart then
				local light = Instance.new("PointLight")
				light.Color = accent
				light.Brightness = rarity == "Легендарная" and 5 or 3
				light.Range = rarity == "Легендарная" and 22 or 16
				light.Parent = effectPart
				local attachment = Instance.new("Attachment")
				attachment.Parent = effectPart
				local sparks = Instance.new("ParticleEmitter")
				sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				sparks.Color = ColorSequence.new(accent)
				sparks.Lifetime = NumberRange.new(0.7, 1.4)
				sparks.Speed = NumberRange.new(2, 5)
				sparks.SpreadAngle = Vector2.new(180, 180)
				sparks.Rate = rarity == "Легендарная" and 40 or 18
				sparks.Parent = attachment
			end
			local aura = scenePart(imported, "EdgarAura", Vector3.new(math.max(boundsSize.X, 3.5), 0.14, math.max(boundsSize.Z, 3.5)), Vector3.new(0, -2.22, 0), accent, Enum.Material.Neon)
			aura.Shape = Enum.PartType.Cylinder
			aura.Orientation = Vector3.new(0, 0, 90)
			aura.Transparency = 0.28
			return imported
		end
	end

	local model = Instance.new("Model")
	model.Name = fighterName
	model.Parent = worldModel
	local bodyColor = Color3.fromRGB(45, 43, 70)
	scenePart(model, "Body", Vector3.new(2.1, 2.5, 1.1), Vector3.new(0, 0.2, 0), bodyColor)
	scenePart(model, "Head", Vector3.new(1.65, 1.65, 1.4), Vector3.new(0, 2.25, 0), Color3.fromRGB(255, 190, 125))
	scenePart(model, "Hair", Vector3.new(1.8, 0.6, 1.55), Vector3.new(0, 3.1, 0), accent)
	scenePart(model, "LeftLeg", Vector3.new(0.75, 1.25, 0.9), Vector3.new(-0.55, -1.65, 0), accent)
	scenePart(model, "RightLeg", Vector3.new(0.75, 1.25, 0.9), Vector3.new(0.55, -1.65, 0), accent)
	scenePart(model, "LeftArm", Vector3.new(0.7, 1.8, 0.8), Vector3.new(-1.35, 0.35, 0), bodyColor)
	scenePart(model, "RightArm", Vector3.new(0.7, 1.8, 0.8), Vector3.new(1.35, 0.35, 0), bodyColor)
	local badge = scenePart(model, "ChestBadge", Vector3.new(0.7, 0.7, 0.16), Vector3.new(0, 0.45, 0.62), accent, Enum.Material.Neon)
	if fighterName == "Эдгар" then
		scenePart(model, "Scarf", Vector3.new(2.2, 0.35, 0.45), Vector3.new(0, 0.95, 0.8), Color3.fromRGB(185, 55, 235))
		scenePart(model, "ScarfTail", Vector3.new(0.5, 1.8, 0.35), Vector3.new(0.75, -0.15, 1), Color3.fromRGB(185, 55, 235))
	end
	local light = Instance.new("PointLight")
	light.Color = accent
	light.Brightness = 2
	light.Range = 16
	light.Parent = badge
	local sparkAttachment = Instance.new("Attachment")
	sparkAttachment.Parent = badge
	local sparks = Instance.new("ParticleEmitter")
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(accent)
	sparks.Lifetime = NumberRange.new(0.7, 1.4)
	sparks.Speed = NumberRange.new(2, 5)
	sparks.SpreadAngle = Vector2.new(180, 180)
	if rarity == "Легендарная" then
		sparks.Rate = 45
	elseif rarity == "Эпическая" then
		sparks.Rate = 25
	elseif rarity == "Редкая" then
		sparks.Rate = 14
	else
		sparks.Rate = 7
	end
	sparks.Parent = sparkAttachment
	local aura = scenePart(model, "Aura", Vector3.new(3.8, 0.18, 3.8), Vector3.new(0, -2.3, 0), accent, Enum.Material.Neon)
	aura.Shape = Enum.PartType.Cylinder
	aura.Orientation = Vector3.new(0, 0, 90)
	aura.Transparency = 0.25
	return model
end

local openingFrame
local animationId = 0

local function playOpening(caseType, caseName, fighterName, rarity, accent)
	animationId += 1
	local thisAnimation = animationId
	if openingFrame then openingFrame:Destroy() end
	openingFrame = make("Frame", {
		Name = "CaseOpening", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 7, 18), BackgroundTransparency = 0.08,
		ZIndex = 20,
	}, gui)
	make("TextLabel", {
		Size = UDim2.new(1, -24, 0, 55), Position = UDim2.new(0, 12, 0.08, 0),
		BackgroundTransparency = 1, Text = caseName, TextColor3 = accent,
		TextScaled = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)
	local viewport = make("ViewportFrame", {
		Size = UDim2.new(0.78, 0, 0.56, 0), Position = UDim2.new(0.11, 0, 0.22, 0),
		BackgroundColor3 = Color3.fromRGB(24, 19, 48), Ambient = Color3.fromRGB(180, 180, 205),
		LightColor = Color3.new(1, 1, 1), ZIndex = 21,
	}, openingFrame)
	make("UICorner", { CornerRadius = UDim.new(0, 18) }, viewport)
	make("UIStroke", { Color = accent, Thickness = 3 }, viewport)
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 2, 13), Vector3.new(0, 0.5, 0))
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	scenePart(worldModel, "Pedestal", Vector3.new(8, 0.5, 5), Vector3.new(0, -3, 0), Color3.fromRGB(38, 31, 70), Enum.Material.Metal)
	local caseColor
	if caseType == "Starter" then
		caseColor = Color3.fromRGB(45, 130, 255)
	elseif caseType == "Brawl" then
		caseColor = Color3.fromRGB(170, 60, 255)
	else
		caseColor = Color3.fromRGB(255, 185, 35)
	end
	local crate = Instance.new("Model")
	crate.Name = "SpinningCase"
	crate.Parent = worldModel
	scenePart(crate, "Box", Vector3.new(4.5, 3.5, 3.5), Vector3.new(0, 0.3, 0), caseColor, Enum.Material.Metal)
	scenePart(crate, "Lid", Vector3.new(4.9, 0.55, 3.9), Vector3.new(0, 2.3, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
	local frontCore = scenePart(crate, "FrontCore", Vector3.new(1.8, 1.4, 0.18), Vector3.new(0, 0.35, 1.85), Color3.fromRGB(255, 245, 175), Enum.Material.Neon)
	local caseLight = Instance.new("PointLight")
	caseLight.Color = caseColor
	caseLight.Brightness = 3
	caseLight.Range = 18
	caseLight.Parent = frontCore
	if caseType == "Starter" then
		local orb = scenePart(crate, "SignalOrb", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 3.25, 0), caseColor, Enum.Material.Neon)
		orb.Shape = Enum.PartType.Ball
	elseif caseType == "Brawl" then
		scenePart(crate, "LeftWing", Vector3.new(0.6, 4, 3.5), Vector3.new(-2.5, 0.3, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
		scenePart(crate, "RightWing", Vector3.new(0.6, 4, 3.5), Vector3.new(2.5, 0.3, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
	else
		local orb = scenePart(crate, "MegaCore", Vector3.new(2.1, 2.1, 2.1), Vector3.new(0, 3.2, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
		orb.Shape = Enum.PartType.Ball
		scenePart(crate, "LeftReactor", Vector3.new(0.35, 3.8, 3.2), Vector3.new(-2.4, 0.3, 0), caseColor, Enum.Material.Neon)
		scenePart(crate, "RightReactor", Vector3.new(0.35, 3.8, 3.2), Vector3.new(2.4, 0.3, 0), caseColor, Enum.Material.Neon)
	end
	local caption = make("TextLabel", {
		Size = UDim2.new(1, -24, 0, 66), Position = UDim2.new(0, 12, 0.82, 0),
		BackgroundTransparency = 1, Text = "КЕЙС ОТКРЫВАЕТСЯ...", TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)
	local startTime = os.clock()
	while os.clock() - startTime < 2.2 and thisAnimation == animationId do
		local angle = (os.clock() - startTime) * 5
		crate:PivotTo(CFrame.new(0, 0.4 + math.sin(angle * 1.5) * 0.25, 0) * CFrame.Angles(0, angle, 0))
		RunService.RenderStepped:Wait()
	end
	if thisAnimation ~= animationId then return end
	crate:Destroy()
	local fighter = createFighter(worldModel, fighterName, accent, rarity)
	local flash = make("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent,
		BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 24,
	}, openingFrame)
	TweenService:Create(flash, TweenInfo.new(0.65), { BackgroundTransparency = 1 }):Play()
	task.delay(0.7, function()
		if flash.Parent then flash:Destroy() end
	end)
	for ringIndex = 1, 3 do
		local ring = scenePart(worldModel, "RevealPulse" .. ringIndex, Vector3.new(0.6, 0.12, 0.6), Vector3.new(0, -2.35 + ringIndex * 0.18, 0), accent, Enum.Material.Neon)
		ring.Shape = Enum.PartType.Cylinder
		ring.Orientation = Vector3.new(0, 0, 90)
		local delayTime = (ringIndex - 1) * 0.18
		task.delay(delayTime, function()
			if ring.Parent then
				TweenService:Create(ring, TweenInfo.new(0.85), { Size = Vector3.new(7 + ringIndex, 0.12, 7 + ringIndex), Transparency = 1 }):Play()
			end
		end)
	end
	local revealStart = os.clock()
	while os.clock() - revealStart < 1.8 and thisAnimation == animationId do
		local angle = (os.clock() - revealStart) * 1.4
		fighter:PivotTo(CFrame.new(0, math.sin(angle * 2) * 0.15, 0) * CFrame.Angles(0, angle, 0))
		RunService.RenderStepped:Wait()
	end
	if thisAnimation ~= animationId then return end
	caption.Text = fighterName .. " • " .. rarity
	caption.TextColor3 = accent
	task.wait(1.4)
	if thisAnimation == animationId and openingFrame then
		openingFrame:Destroy()
		openingFrame = nil
	end
end

local function playOpeningCinematic(caseType, caseName, fighterName, rarity, accent)
	animationId += 1
	local thisAnimation = animationId
	if openingFrame then openingFrame:Destroy() end
	openingFrame = make("Frame", {
		Name = "CaseOpeningCinematic", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(10, 7, 24), BackgroundTransparency = 0.02, ZIndex = 20,
	}, gui)
	make("TextLabel", {
		Size = UDim2.new(0.92, 0, 0, 58), Position = UDim2.new(0.04, 0, 0.035, 0),
		BackgroundColor3 = Color3.fromRGB(31, 22, 62), BackgroundTransparency = 0.05,
		Text = caseName .. "  •  КЕЙС НА КОНВЕЙЕРЕ", TextColor3 = Color3.fromRGB(255, 221, 85),
		TextSize = 24, TextWrapped = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)
	local viewport = make("ViewportFrame", {
		Size = UDim2.new(0.94, 0, 0.68, 0), Position = UDim2.new(0.03, 0, 0.16, 0),
		BackgroundColor3 = Color3.fromRGB(18, 14, 40), Ambient = Color3.fromRGB(155, 145, 195),
		LightColor = Color3.fromRGB(255, 235, 195), ZIndex = 21,
	}, openingFrame)
	make("UICorner", { CornerRadius = UDim.new(0, 20) }, viewport)
	make("UIStroke", { Color = accent, Thickness = 3 }, viewport)
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 2.1, 18), Vector3.new(0, -0.4, 0))
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local caption = make("TextLabel", {
		Size = UDim2.new(0.92, 0, 0, 64), Position = UDim2.new(0.04, 0, 0.86, 0),
		BackgroundColor3 = Color3.fromRGB(31, 22, 62), BackgroundTransparency = 0.05,
		Text = "КОНВЕЙЕР ЗАПУСКАЕТСЯ...", TextColor3 = Color3.new(1, 1, 1),
		TextSize = 26, TextWrapped = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)

	local caseColor
	if caseType == "Starter" then
		caseColor = Color3.fromRGB(40, 125, 255)
	elseif caseType == "Brawl" then
		caseColor = Color3.fromRGB(165, 55, 245)
	else
		caseColor = Color3.fromRGB(255, 185, 30)
	end
	scenePart(worldModel, "ConveyorFrame", Vector3.new(17, 0.8, 8), Vector3.new(0, -3.1, 0), Color3.fromRGB(28, 25, 55), Enum.Material.Metal)
	scenePart(worldModel, "MovingBelt", Vector3.new(15.8, 0.18, 6.4), Vector3.new(0, -2.58, 0), Color3.fromRGB(48, 52, 78), Enum.Material.Metal)
	scenePart(worldModel, "RailLeft", Vector3.new(17, 0.75, 0.45), Vector3.new(0, -2.05, -3.7), caseColor, Enum.Material.Neon)
	scenePart(worldModel, "RailRight", Vector3.new(17, 0.75, 0.45), Vector3.new(0, -2.05, 3.7), caseColor, Enum.Material.Neon)
	local rollers = {}
	for index = 1, 11 do
		local x = -7.2 + (index - 1) * 1.44
		local roller = scenePart(worldModel, "Roller" .. index, Vector3.new(0.55, 6.3, 0.55), Vector3.new(x, -2.77, 0), Color3.fromRGB(118, 130, 165), Enum.Material.Metal)
		roller.Shape = Enum.PartType.Cylinder
		table.insert(rollers, { part = roller, position = roller.Position })
	end
	local beltAngle = 0
	local function animate(duration, speed, update)
		local start = os.clock()
		local previous = start
		while os.clock() - start < duration and thisAnimation == animationId do
			local now = os.clock()
			local dt = now - previous
			previous = now
			beltAngle += dt * speed
			for _, rollerData in ipairs(rollers) do
				rollerData.part.CFrame = CFrame.new(rollerData.position) * CFrame.Angles(0, 0, beltAngle) * CFrame.Angles(math.rad(90), 0, 0)
			end
			if update then update(math.clamp((now - start) / duration, 0, 1), now) end
			RunService.RenderStepped:Wait()
		end
	end

	local crate = Instance.new("Model")
	crate.Name = "RidingCase"
	crate.Parent = worldModel
	local body = scenePart(crate, "CaseBody", Vector3.new(3.8, 3.1, 3.4), Vector3.zero, caseColor, Enum.Material.Metal)
	crate.PrimaryPart = body
	local lid = scenePart(crate, "CaseLid", Vector3.new(4.05, 0.48, 3.65), Vector3.new(0, 1.78, 0), Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
	scenePart(crate, "FrontPanel", Vector3.new(2, 1.35, 0.18), Vector3.new(0, 0.15, 1.78), Color3.fromRGB(245, 250, 255), Enum.Material.Neon)
	scenePart(crate, "SideTrimL", Vector3.new(0.35, 2.6, 0.25), Vector3.new(-1.95, 0, 1.75), Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
	scenePart(crate, "SideTrimR", Vector3.new(0.35, 2.6, 0.25), Vector3.new(1.95, 0, 1.75), Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
	local core = Instance.new("Attachment")
	core.Position = Vector3.new(0, 0, 1)
	core.Parent = body
	local crateSparks = Instance.new("ParticleEmitter")
	crateSparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	crateSparks.Color = ColorSequence.new(caseColor, Color3.fromRGB(255, 235, 150))
	crateSparks.Lifetime = NumberRange.new(0.45, 0.9)
	crateSparks.Speed = NumberRange.new(3, 7)
	crateSparks.SpreadAngle = Vector2.new(180, 180)
	crateSparks.Rate = 0
	crateSparks.Parent = core
	local crateLight = Instance.new("PointLight")
	crateLight.Color = caseColor
	crateLight.Brightness = 3
	crateLight.Range = 18
	crateLight.Parent = body
	crate:PivotTo(CFrame.new(-8, -0.9, 0) * CFrame.Angles(0, 0, math.rad(-12)))
	caption.Text = "КОНВЕЙЕР НАБИРАЕТ СКОРОСТЬ"
	animate(1.35, 18, function(alpha, now)
		local eased = 1 - (1 - alpha) * (1 - alpha)
		local x = -8 + eased * 8
		crate:PivotTo(CFrame.new(x, -0.9 + math.sin(now * 15) * 0.12, 0) * CFrame.Angles(0, now * 1.2, math.rad(-12 + math.sin(now * 19) * 3)))
	end)
	if thisAnimation ~= animationId then return end
	crate:PivotTo(CFrame.new(0, -0.9, 0))
	caption.Text = "КЕЙС ОСТАНАВЛИВАЕТСЯ..."
	animate(0.55, 25, function(alpha, now)
		crate:PivotTo(CFrame.new(math.sin(now * 38) * (1 - alpha) * 0.17, -0.9, 0) * CFrame.Angles(0, 0, math.sin(now * 35) * (1 - alpha) * 0.04))
		crateLight.Brightness = 2.5 + math.abs(math.sin(now * 24)) * 4
	end)
	local lidStart = lid.CFrame
	caption.Text = "ЗАРЯДКА КЕЙСА..."
	crateSparks:Emit(42)
	animate(0.65, 8, function(alpha)
		local eased = alpha * alpha
		lid.CFrame = lidStart * CFrame.new(0, eased * 2.6, 0) * CFrame.Angles(math.rad(-105 * eased), 0, 0)
		crateLight.Brightness = 4 + eased * 10
	end)
	if thisAnimation ~= animationId then return end
	crate:Destroy()

	local previews = {
		{ "Шелли", "Обычная", Color3.fromRGB(70, 145, 255) },
		{ "Кольт", "Редкая", Color3.fromRGB(155, 80, 255) },
		{ "Нита", "Обычная", Color3.fromRGB(70, 145, 255) },
		{ "Ворон", "Легендарная", Color3.fromRGB(255, 215, 55) },
		{ "Спайк", "Эпическая", Color3.fromRGB(255, 150, 45) },
	}
	caption.Text = "РУЛЕТКА БОЙЦОВ"
	for index, entry in ipairs(previews) do
		local preview = createFighter(worldModel, entry[1], entry[3], entry[2])
		local duration = 0.16 + index * 0.085
		caption.Text = entry[1] .. "  •  " .. entry[2]
		caption.TextColor3 = entry[3]
		animate(duration, 22 - index * 2, function(alpha, now)
			preview:PivotTo(CFrame.new(0, math.sin(now * 9) * 0.22, 0) * CFrame.Angles(0, now * (8 - index * 0.45), 0))
		end)
		preview:Destroy()
	end
	if thisAnimation ~= animationId then return end
	caption.Text = "ПОСЛЕДНИЙ БРОСОК..."
	caption.TextColor3 = accent
	local winner = createFighter(worldModel, fighterName, accent, rarity)
	local winnerLight = Instance.new("PointLight")
	winnerLight.Color = accent
	winnerLight.Brightness = 0
	winnerLight.Range = 24
	winnerLight.Parent = winner:FindFirstChild("ChestBadge")
	local revealFlash = make("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent,
		BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 24,
	}, openingFrame)
	TweenService:Create(revealFlash, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
	task.delay(0.85, function()
		if revealFlash.Parent then revealFlash:Destroy() end
	end)
	local winnerBadge = winner:FindFirstChild("ChestBadge")
	local winnerSparks = winnerBadge and winnerBadge:FindFirstChildOfClass("Attachment")
	if winnerSparks then
		local emitter = winnerSparks:FindFirstChildOfClass("ParticleEmitter")
		if emitter then
			local burst = 55
			if rarity == "Эпическая" then burst = 80 end
			if rarity == "Легендарная" then burst = 120 end
			emitter:Emit(burst)
		end
	end
	caption.Text = "ВЫПАЛ " .. string.upper(fighterName) .. "  •  " .. string.upper(rarity)
	caption.TextColor3 = accent
	animate(1.7, 7, function(alpha, now)
		local rise = -2.8 + alpha * 2.8
		winner:PivotTo(CFrame.new(0, rise + math.sin(now * 4) * 0.1, 0) * CFrame.Angles(0, now * 1.25, 0))
		winnerLight.Brightness = 2 + alpha * 5
	end)
	if thisAnimation ~= animationId then return end
	task.wait(1.4)
	if thisAnimation == animationId and openingFrame then
		openingFrame:Destroy()
		openingFrame = nil
	end
end

local function showTradeForm()
	if tradeForm then tradeForm:Destroy() end
	tradeForm = make("Frame", {
		Size = UDim2.new(0.86, 0, 0, 230), Position = UDim2.new(0.07, 0, 0.5, -115),
		BackgroundColor3 = Color3.fromRGB(34, 27, 62), ZIndex = 30,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 12) }, tradeForm)
	make("UIStroke", { Color = Color3.fromRGB(255, 205, 45), Thickness = 2 }, tradeForm)
	make("TextLabel", {
		Size = UDim2.new(1, -16, 0, 42), Position = UDim2.fromOffset(8, 6),
		BackgroundTransparency = 1, Text = "ОБМЕН КАРТОЧКАМИ",
		TextColor3 = Color3.fromRGB(255, 220, 70), TextSize = 21, Font = Enum.Font.GothamBlack, ZIndex = 31,
	}, tradeForm)
	local cardNames = {}
	for name, amount in pairs(inventory) do
		if amount > 0 then table.insert(cardNames, name) end
	end
	table.sort(cardNames)
	if #cardNames == 0 then table.insert(cardNames, "НЕТ КАРТОЧЕК") end
	local cardIndex = 1
	local selectedCard = cardNames[1]
	local selectedAmount = 1
	local cardLabel = make("TextLabel", {
		Size = UDim2.new(1, -20, 0, 38), Position = UDim2.fromOffset(10, 52),
		BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1), TextSize = 17,
		Font = Enum.Font.GothamBold, ZIndex = 31,
	}, tradeForm)
	local amountLabel = make("TextLabel", {
		Size = UDim2.new(1, -20, 0, 30), Position = UDim2.fromOffset(10, 91),
		BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(225, 225, 235),
		TextSize = 15, Font = Enum.Font.Gotham, ZIndex = 31,
	}, tradeForm)
	local function refreshTradeForm()
		selectedCard = cardNames[cardIndex]
		local owned = inventory[selectedCard] or 0
		selectedAmount = math.clamp(selectedAmount, 1, math.max(owned, 1))
		cardLabel.Text = "Карточка: " .. selectedCard
		amountLabel.Text = "Количество: " .. (owned > 0 and tostring(selectedAmount) or "0") .. " из " .. owned
	end
	local previous = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.fromOffset(12, 130), Text = "◀", ZIndex = 31 }, tradeForm)
	local nextCard = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.new(1, -54, 0, 130), Text = "▶", ZIndex = 31 }, tradeForm)
	local less = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.new(0.5, -48, 0, 130), Text = "−", ZIndex = 31 }, tradeForm)
	local more = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.new(0.5, 6, 0, 130), Text = "+", ZIndex = 31 }, tradeForm)
	local submit = make("TextButton", {
		Size = UDim2.new(1, -20, 0, 42), Position = UDim2.fromOffset(10, 178),
		BackgroundColor3 = Color3.fromRGB(55, 170, 85), Text = "ПРЕДЛОЖИТЬ",
		TextColor3 = Color3.new(1, 1, 1), TextSize = 17, Font = Enum.Font.GothamBold, ZIndex = 31,
	}, tradeForm)
	previous.Activated:Connect(function()
		cardIndex = (cardIndex - 2) % #cardNames + 1
		refreshTradeForm()
	end)
	nextCard.Activated:Connect(function()
		cardIndex = cardIndex % #cardNames + 1
		refreshTradeForm()
	end)
	less.Activated:Connect(function()
		selectedAmount = math.max(1, selectedAmount - 1)
		refreshTradeForm()
	end)
	more.Activated:Connect(function()
		selectedAmount += 1
		refreshTradeForm()
	end)
	submit.Activated:Connect(function()
		if not activeTrade then
			status.Text = "Обмен уже закончился."
			tradeForm:Destroy()
			return
		end
		local amount = inventory[selectedCard] and inventory[selectedCard] > 0 and selectedAmount or 0
		tradeOffer:FireServer(activeTrade.id, selectedCard, amount)
		activeTrade = nil
		tradeForm:Destroy()
	end)
	refreshTradeForm()
end

tradeButton.Activated:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then status.Text = "Персонаж ещё загружается."; return end
	local nearestPlayer
	local nearestDistance = 25
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
			if otherRoot then
				local distance = (otherRoot.Position - root.Position).Magnitude
				if distance < nearestDistance then
					nearestDistance = distance
					nearestPlayer = other
				end
			end
		end
	end
	if not nearestPlayer then status.Text = "Подойди ближе к игроку для обмена."; return end
	tradeRequest:FireServer(nearestPlayer.UserId)
	status.Text = "Запрос отправлен: " .. nearestPlayer.DisplayName
end)

inventoryUpdate.OnClientEvent:Connect(function(newInventory, newHotbar)
	inventory = newInventory or {}
	local oldHotbar = quickbar
	quickbar = newHotbar or quickbar
	for index = 1, 5 do
		if quickbar[index] and quickbar[index] ~= oldHotbar[index] then
			quickStatus.Text = quickbar[index] .. " сразу добавлен в быстрый доступ — нажми слот " .. index .. "."
			break
		end
	end
	renderInventory()
	renderHotbar()
end)

caseReveal.OnClientEvent:Connect(function(stage, caseType, caseName, fighterName, rarity, color)
	if stage == "Start" then
		task.spawn(playOpeningCinematic, caseType, caseName, fighterName, rarity, color)
	end
end)

tradeRequest.OnClientEvent:Connect(function(fromUserId, fromName)
	local dialog = make("Frame", {
		Size = UDim2.new(0.86, 0, 0, 150), Position = UDim2.new(0.07, 0, 0.5, -75),
		BackgroundColor3 = Color3.fromRGB(34, 27, 62), ZIndex = 40,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 12) }, dialog)
	make("TextLabel", {
		Size = UDim2.new(1, -20, 0, 65), Position = UDim2.fromOffset(10, 8),
		BackgroundTransparency = 1, Text = fromName .. " предлагает обмен.",
		TextColor3 = Color3.new(1, 1, 1), TextWrapped = true, TextSize = 19,
		Font = Enum.Font.GothamBold, ZIndex = 41,
	}, dialog)
	local accept = make("TextButton", {
		Size = UDim2.new(0.48, -8, 0, 48), Position = UDim2.new(0, 8, 1, -56),
		BackgroundColor3 = Color3.fromRGB(50, 165, 80), Text = "ПРИНЯТЬ", TextColor3 = Color3.new(1, 1, 1), ZIndex = 41,
	}, dialog)
	local decline = make("TextButton", {
		Size = UDim2.new(0.48, -8, 0, 48), Position = UDim2.new(0.52, 0, 1, -56),
		BackgroundColor3 = Color3.fromRGB(180, 60, 65), Text = "ОТКЛОНИТЬ", TextColor3 = Color3.new(1, 1, 1), ZIndex = 41,
	}, dialog)
	accept.Activated:Connect(function()
		tradeReply:FireServer(true)
		dialog:Destroy()
	end)
	decline.Activated:Connect(function()
		tradeReply:FireServer(false)
		dialog:Destroy()
	end)
end)

tradeOffer.OnClientEvent:Connect(function(tradeId, partnerId, partnerName)
	activeTrade = { id = tradeId, partnerId = partnerId, partnerName = partnerName }
	status.Text = "Обмен с " .. partnerName .. ". Выбери свою карточку."
	showTradeForm()
end)

tradeResult.OnClientEvent:Connect(function(message, kind)
	status.Text = tostring(message)
	if kind == "error" then
		status.TextColor3 = Color3.fromRGB(255, 125, 125)
	elseif kind == "success" then
		status.TextColor3 = Color3.fromRGB(140, 255, 155)
	else
		status.TextColor3 = Color3.fromRGB(225, 225, 235)
	end
end)

renderInventory()
