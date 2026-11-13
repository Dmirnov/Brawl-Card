-- Brawl Card: server-authoritative case opening and player trading prototype.
-- Put this normal Script in ServerScriptService alongside WorldSetup.server.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("CardGameRemotes") or Instance.new("Folder")
remotes.Name = "CardGameRemotes"
remotes.Parent = ReplicatedStorage

local function getRemote(name)
	local remote = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	return remote
end

local tradeRequest = getRemote("TradeRequest")
local tradeReply = getRemote("TradeReply")
local tradeOffer = getRemote("TradeOffer")
local tradeResult = getRemote("TradeResult")
local inventoryUpdate = getRemote("InventoryUpdate")
local caseReveal = getRemote("CaseReveal")
local setHotbar = getRemote("SetHotbar")
local placeFighter = getRemote("PlaceFighter")

local CASE_COOLDOWN = 2
local TRADE_TIMEOUT = 30
local cards = {
	{ name = "Шелли", rarity = "Обычная", color = Color3.fromRGB(65, 145, 255) },
	{ name = "Нита", rarity = "Обычная", color = Color3.fromRGB(65, 145, 255) },
	{ name = "Кольт", rarity = "Редкая", color = Color3.fromRGB(155, 80, 255) },
	{ name = "Спайк", rarity = "Эпическая", color = Color3.fromRGB(255, 150, 45) },
	{ name = "Ворон", rarity = "Легендарная", color = Color3.fromRGB(255, 215, 55) },
	{ name = "Эдгар", rarity = "Эпическая", color = Color3.fromRGB(205, 75, 245) },
}
local caseTypes = {
	Starter = { name = "СТАРТОВЫЙ КЕЙС", cost = 100, color = Color3.fromRGB(45, 130, 255), weights = { 47, 30, 16, 5, 1, 1 }, chances = "Обычн. 77% • Редк. 16% • Эпич. 6% • Лег. 1%" },
	Brawl = { name = "БРАВЛ КЕЙС", cost = 350, color = Color3.fromRGB(170, 60, 255), weights = { 29, 24, 20, 15, 6, 6 }, chances = "Обычн. 53% • Редк. 20% • Эпич. 21% • Лег. 6%" },
	Mega = { name = "МЕГА КЕЙС", cost = 900, color = Color3.fromRGB(255, 185, 35), weights = { 14, 18, 22, 24, 15, 7 }, chances = "Обычн. 32% • Редк. 22% • Эпич. 31% • Лег. 15%" },
}

local inventories = {}
local pendingRequests = {}
local activeTrades = {}
local lastCaseAt = {}
local openingCase = {}
local hotbars = {}
local firstCaseAwarded = {}
local MAX_PLACED_FIGHTERS = 12

local function send(player, message, kind)
	if player and player.Parent == Players then
		tradeResult:FireClient(player, message, kind or "info")
	end
end

local function getCoins(player)
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	if coins and coins:IsA("IntValue") then return coins end
	return nil
end

local function inventoryFor(player)
	inventories[player.UserId] = inventories[player.UserId] or {}
	return inventories[player.UserId]
end

local function sendInventory(player)
	inventoryUpdate:FireClient(player, inventoryFor(player), hotbars[player.UserId] or {})
end

	local function pickCard(caseType)
	local config = caseTypes[caseType]
	local total = 0
	for index in ipairs(cards) do total += config.weights[index] end
	local roll = math.random(1, total)
	for index, card in ipairs(cards) do
		roll -= config.weights[index]
		if roll <= 0 then return card end
	end
	return cards[1]
end

local findCard

local function handleOpenCase(player, caseType, base)
	local config = caseTypes[caseType]
	if not config or not base or base:GetAttribute("OwnerUserId") ~= player.UserId then return end
	if openingCase[player.UserId] then return end
	local now = os.clock()
	if now - (lastCaseAt[player.UserId] or 0) < CASE_COOLDOWN then return end
	lastCaseAt[player.UserId] = now
	local coins = getCoins(player)
	if not coins then send(player, "Монеты пока не загрузились.", "error"); return end
	if coins.Value < config.cost then send(player, "Для этого кейса нужно " .. config.cost .. " монет.", "error"); return end
	coins.Value -= config.cost
	openingCase[player.UserId] = true
	local card
	if not firstCaseAwarded[player.UserId] then
		card = findCard("Эдгар")
		firstCaseAwarded[player.UserId] = true
	else
		card = pickCard(caseType)
	end
	caseReveal:FireClient(player, "Start", caseType, config.name, card.name, card.rarity, card.color)
	-- Reveal lasts about 8 seconds; award only after the client-side animation finishes.
	task.delay(8.5, function()
		openingCase[player.UserId] = nil
		if player.Parent ~= Players then return end
		local inventory = inventoryFor(player)
		inventory[card.name] = (inventory[card.name] or 0) + 1
		local hotbar = hotbars[player.UserId] or {}
		local equipped = false
		for _, name in pairs(hotbar) do
			if name == card.name then equipped = true; break end
		end
		if not equipped then
			local freeSlot
			for slotIndex = 1, 5 do
				if not hotbar[slotIndex] then freeSlot = slotIndex; break end
			end
			if not freeSlot then freeSlot = 5 end
			hotbar[freeSlot] = card.name
			hotbars[player.UserId] = hotbar
		end
		sendInventory(player)
		caseReveal:FireClient(player, "Result", caseType, config.name, card.name, card.rarity, card.color)
		send(player, "Выпала карточка «" .. card.name .. "» — " .. card.rarity .. "!", "success")
	end)
end

findCard = function(cardName)
	for _, card in ipairs(cards) do
		if card.name == cardName then return card end
	end
	return nil
end

setHotbar.OnServerEvent:Connect(function(player, requestedHotbar)
	if typeof(requestedHotbar) ~= "table" then return end
	local inventory = inventoryFor(player)
	local safeHotbar = {}
	local used = {}
	for index = 1, 5 do
		local cardName = requestedHotbar[index]
		if typeof(cardName) == "string" and findCard(cardName) and (inventory[cardName] or 0) > 0 and not used[cardName] then
			safeHotbar[index] = cardName
			used[cardName] = true
		end
	end
	hotbars[player.UserId] = safeHotbar
	sendInventory(player)
end)

placeFighter.OnServerEvent:Connect(function(player, cardName, requestedPosition)
	local card = findCard(cardName)
	if not card or typeof(requestedPosition) ~= "Vector3" then return end
	local inventory = inventoryFor(player)
	if (inventory[cardName] or 0) < 1 then
		send(player, "Этого бойца больше нет в инвентаре.", "error")
		return
	end
	local selectedInHotbar = false
	for _, equippedName in pairs(hotbars[player.UserId] or {}) do
		if equippedName == cardName then selectedInHotbar = true; break end
	end
	if not selectedInHotbar then
		send(player, "Сначала добавь бойца в быстрый доступ.", "error")
		return
	end
	local world = workspace:FindFirstChild("BrawlWorld")
	local bases = world and world:FindFirstChild("PersonalBases")
	local ownedBase
	if bases then
		for _, base in ipairs(bases:GetChildren()) do
			if base:GetAttribute("OwnerUserId") == player.UserId then ownedBase = base; break end
		end
	end
	local platform = ownedBase and ownedBase:FindFirstChild("BasePlatform")
	if not platform or not platform:IsA("BasePart") then return end
	local localPosition = platform.CFrame:PointToObjectSpace(requestedPosition)
	if math.abs(localPosition.X) > platform.Size.X / 2 - 6 or math.abs(localPosition.Z) > platform.Size.Z / 2 - 6 then
		send(player, "Поставить бойца можно только внутри своей базы.", "error")
		return
	end
	local floorY = platform.Position.Y + platform.Size.Y / 2
	if requestedPosition.Y < floorY - 0.2 or requestedPosition.Y > floorY + 1 then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - requestedPosition).Magnitude > 120 then return end
	local placedFolder = ownedBase:FindFirstChild("PlacedFighters")
	if not placedFolder then
		placedFolder = Instance.new("Folder")
		placedFolder.Name = "PlacedFighters"
		placedFolder.Parent = ownedBase
	end
	if #placedFolder:GetChildren() >= MAX_PLACED_FIGHTERS then
		send(player, "На базе уже размещено максимальное число бойцов.", "error")
		return
	end
	local figure = Instance.new("Model")
	figure.Name = "Fighter_" .. cardName
	figure:SetAttribute("FighterName", cardName)
	figure.Parent = placedFolder
	local center = Vector3.new(requestedPosition.X, floorY + 2.4, requestedPosition.Z)
	local bodyColor = Color3.fromRGB(48, 42, 72)
	local function figurePart(partName, size, offset, color, material)
		local part = Instance.new("Part")
		part.Name = partName
		part.Size = size
		part.CFrame = CFrame.new(center + offset)
		part.Anchored = true
		part.CanCollide = false
		part.Material = material or Enum.Material.SmoothPlastic
		part.Color = color
		part.Parent = figure
		return part
	end
	figurePart("Body", Vector3.new(2, 2.4, 1.1), Vector3.new(0, 0, 0), bodyColor)
	figurePart("Head", Vector3.new(1.6, 1.6, 1.4), Vector3.new(0, 2, 0), Color3.fromRGB(255, 190, 125))
	figurePart("Hair", Vector3.new(1.8, 0.6, 1.5), Vector3.new(0, 2.9, 0), card.color)
	figurePart("LeftLeg", Vector3.new(0.7, 1.2, 0.9), Vector3.new(-0.5, -1.8, 0), card.color)
	figurePart("RightLeg", Vector3.new(0.7, 1.2, 0.9), Vector3.new(0.5, -1.8, 0), card.color)
	figurePart("LeftArm", Vector3.new(0.65, 1.7, 0.8), Vector3.new(-1.3, 0, 0), bodyColor)
	figurePart("RightArm", Vector3.new(0.65, 1.7, 0.8), Vector3.new(1.3, 0, 0), bodyColor)
	local emblem = figurePart("Emblem", Vector3.new(0.7, 0.7, 0.16), Vector3.new(0, 0.3, 0.62), card.color, Enum.Material.Neon)
	if cardName == "Эдгар" then
		figurePart("Scarf", Vector3.new(2.2, 0.35, 0.45), Vector3.new(0, 0.95, 0.8), Color3.fromRGB(185, 55, 235))
		figurePart("ScarfTail", Vector3.new(0.5, 1.8, 0.35), Vector3.new(0.75, -0.15, 1), Color3.fromRGB(185, 55, 235))
	end
	local glow = Instance.new("PointLight")
	glow.Color = card.color
	glow.Brightness = 1.5
	glow.Range = 12
	glow.Parent = emblem
	inventory[cardName] -= 1
	if inventory[cardName] <= 0 then
		inventory[cardName] = nil
		for slotIndex, equippedName in pairs(hotbars[player.UserId] or {}) do
			if equippedName == cardName then hotbars[player.UserId][slotIndex] = nil end
		end
	end
	sendInventory(player)
	send(player, cardName .. " теперь стоит на твоей базе.", "success")
end)

tradeRequest.OnServerEvent:Connect(function(player, targetUserId)
	if typeof(targetUserId) ~= "number" or targetUserId == player.UserId then return end
	local target = Players:GetPlayerByUserId(targetUserId)
	if not target then send(player, "Игрок уже вышел.", "error"); return end
	if activeTrades[player.UserId] or activeTrades[target.UserId] then
		send(player, "Один из игроков уже участвует в обмене.", "error"); return
	end
	pendingRequests[target.UserId] = { from = player, expires = os.clock() + TRADE_TIMEOUT }
	tradeRequest:FireClient(target, player.UserId, player.DisplayName)
	send(player, "Запрос на обмен отправлен игроку " .. target.DisplayName .. ".")
	task.delay(TRADE_TIMEOUT, function()
		local request = pendingRequests[target.UserId]
		if request and request.from == player then
			pendingRequests[target.UserId] = nil
			send(player, "Запрос на обмен истёк.", "error")
			send(target, "Запрос на обмен истёк.", "error")
		end
	end)
end)

tradeReply.OnServerEvent:Connect(function(target, accepted)
	local request = pendingRequests[target.UserId]
	if not request then return end
	pendingRequests[target.UserId] = nil
	local from = request.from
	if os.clock() > request.expires or not from or from.Parent ~= Players then
		send(target, "Запрос уже недействителен.", "error"); return
	end
	if accepted ~= true then send(from, target.DisplayName .. " отклонил обмен.", "error"); return end
	if activeTrades[target.UserId] or activeTrades[from.UserId] then return end
	local tradeId = tostring(target.UserId) .. ":" .. tostring(from.UserId) .. ":" .. tostring(os.clock())
	local trade = { id = tradeId, a = from, b = target, offers = {}, submitted = {} }
	activeTrades[from.UserId] = trade
	activeTrades[target.UserId] = trade
	tradeOffer:FireClient(from, tradeId, target.UserId, target.DisplayName)
	tradeOffer:FireClient(target, tradeId, from.UserId, from.DisplayName)
	send(from, "Обмен начался. Выбери карточку и количество в окне обмена.")
	send(target, "Обмен начался. Выбери карточку и количество в окне обмена.")
	task.delay(120, function()
		if activeTrades[from.UserId] == trade then
			activeTrades[from.UserId], activeTrades[target.UserId] = nil, nil
			send(from, "Обмен отменён: время вышло.", "error")
			send(target, "Обмен отменён: время вышло.", "error")
		end
	end)
end)

tradeOffer.OnServerEvent:Connect(function(player, tradeId, cardName, amount)
	local trade = activeTrades[player.UserId]
	if not trade or trade.id ~= tradeId or trade.submitted[player.UserId] then
		return
	end
	if typeof(cardName) ~= "string" or #cardName > 40 or typeof(amount) ~= "number" or amount % 1 ~= 0 or amount < 0 or amount > 99 then
		return
	end
	local inventory = inventoryFor(player)
	if amount > 0 and (inventory[cardName] or 0) < amount then
		send(player, "У тебя нет столько таких карточек.", "error")
		return
	end
	local offeredCardName = cardName
	if amount == 0 then
		offeredCardName = ""
	end
	trade.offers[player.UserId] = { cardName = offeredCardName, amount = amount }
	trade.submitted[player.UserId] = true
	local partner
	if trade.a == player then
		partner = trade.b
	else
		partner = trade.a
	end
	tradeResult:FireClient(partner, player.DisplayName .. " подготовил предложение. Ждём твоё предложение.")
	send(player, "Предложение записано. Ждём второго игрока.")
	if trade.submitted[trade.a.UserId] and trade.submitted[trade.b.UserId] then
		local offerA, offerB = trade.offers[trade.a.UserId], trade.offers[trade.b.UserId]
		local invA, invB = inventoryFor(trade.a), inventoryFor(trade.b)
		local invalidOfferA = offerA.amount > 0 and (invA[offerA.cardName] or 0) < offerA.amount
		local invalidOfferB = offerB.amount > 0 and (invB[offerB.cardName] or 0) < offerB.amount
		if invalidOfferA or invalidOfferB then
			send(trade.a, "Обмен отменён: количество карточек изменилось.", "error")
			send(trade.b, "Обмен отменён: количество карточек изменилось.", "error")
		else
			if offerA.amount > 0 then
				invA[offerA.cardName] = invA[offerA.cardName] - offerA.amount
				if invA[offerA.cardName] == 0 then invA[offerA.cardName] = nil end
			end
			if offerB.amount > 0 then
				invB[offerB.cardName] = invB[offerB.cardName] - offerB.amount
				if invB[offerB.cardName] == 0 then invB[offerB.cardName] = nil end
			end
			if offerA.amount > 0 then
				invB[offerA.cardName] = (invB[offerA.cardName] or 0) + offerA.amount
			end
			if offerB.amount > 0 then
				invA[offerB.cardName] = (invA[offerB.cardName] or 0) + offerB.amount
			end
			send(trade.a, "Обмен завершён.", "success")
			send(trade.b, "Обмен завершён.", "success")
			sendInventory(trade.a)
			sendInventory(trade.b)
		end
		activeTrades[trade.a.UserId], activeTrades[trade.b.UserId] = nil, nil
	end
end)

local function addCasePrompt()
	local world = workspace:WaitForChild("BrawlWorld", 30)
	if not world then warn("CardSystems: BrawlWorld wasn't found"); return end
	local bases = world:WaitForChild("PersonalBases", 30)
	if not bases then warn("CardSystems: PersonalBases wasn't found"); return end
	for _, base in ipairs(bases:GetChildren()) do
		local conveyor = base:FindFirstChild("CaseConveyor")
		if conveyor then
			for index, caseType in ipairs({ "Starter", "Brawl", "Mega" }) do
				local config = caseTypes[caseType]
				local casePart = base:FindFirstChild("ConveyorCase_" .. index)
				if casePart and casePart:IsA("BasePart") then
					casePart.Color = config.color
					casePart.Material = Enum.Material.Metal
					casePart:SetAttribute("CaseType", caseType)
					casePart:SetAttribute("BaseSlotNumber", base:GetAttribute("SlotNumber"))
					local details = Instance.new("Folder")
					details.Name = caseType .. "CaseDetails"
					details.Parent = base
					local function detail(name, size, offset, color, shape, material)
						local part = Instance.new("Part")
						part.Name, part.Size = name, size
						part.Position = casePart.Position + offset
						part.Anchored, part.CanCollide = true, false
						part.Material, part.Color = material or Enum.Material.Metal, color
						if shape then part.Shape = shape end
						part.Parent = details
						return part
					end
					detail("TopPlate", Vector3.new(5.8, 0.35, 5.8), Vector3.new(0, 2.75, 0), Color3.fromRGB(255, 220, 70), nil, Enum.Material.Neon)
					if caseType == "Starter" then
						detail("SignalAntenna", Vector3.new(0.35, 1.8, 0.35), Vector3.new(0, 3.7, 0), Color3.fromRGB(225, 235, 255))
						detail("SignalOrb", Vector3.new(1.1, 1.1, 1.1), Vector3.new(0, 4.8, 0), config.color, Enum.PartType.Ball, Enum.Material.Neon)
					elseif caseType == "Brawl" then
						detail("LeftWing", Vector3.new(0.6, 4, 2.8), Vector3.new(-3.1, 0.5, 0), Color3.fromRGB(255, 220, 70))
						detail("RightWing", Vector3.new(0.6, 4, 2.8), Vector3.new(3.1, 0.5, 0), Color3.fromRGB(255, 220, 70))
					else
						detail("TopOrb", Vector3.new(1.8, 1.8, 1.8), Vector3.new(0, 4.1, 0), Color3.fromRGB(255, 225, 80), Enum.PartType.Ball, Enum.Material.Neon)
						detail("SideCoreLeft", Vector3.new(0.35, 3.4, 3.4), Vector3.new(-2.9, 0.1, 0), config.color, nil, Enum.Material.Neon)
						detail("SideCoreRight", Vector3.new(0.35, 3.4, 3.4), Vector3.new(2.9, 0.1, 0), config.color, nil, Enum.Material.Neon)
					end
					local stripe = base:FindFirstChild("ConveyorCaseStripe_" .. index)
					if stripe and stripe:IsA("BasePart") then
						stripe.Color = Color3.fromRGB(255, 225, 80)
						stripe.Material = Enum.Material.Neon
					end
					local light = Instance.new("PointLight")
					light.Name = "CaseGlow"
					light.Color = config.color
					light.Brightness = 1.2
					light.Range = 14
					light.Parent = casePart
					local prompt = Instance.new("ProximityPrompt")
					prompt.Name = "Open" .. caseType .. "Case"
					prompt.ActionText = "Купить • " .. config.cost .. " монет"
					prompt.ObjectText = config.name
					prompt.HoldDuration = 0.35
					prompt.MaxActivationDistance = 12
					prompt.RequiresLineOfSight = false
					prompt.Parent = casePart
					prompt.Triggered:Connect(function(player)
						handleOpenCase(player, caseType, base)
					end)
					local labelGui = Instance.new("BillboardGui")
					labelGui.Name = "CaseNameLabel"
					labelGui.Size = UDim2.fromOffset(210, 56)
					local labelHeight = if caseIndex == 2 then 6.3 else 4.8
					labelGui.StudsOffset = Vector3.new(0, labelHeight, 0)
					labelGui.MaxDistance = 120
					labelGui.AlwaysOnTop = true
					labelGui.Adornee = casePart
					labelGui.Parent = casePart
					local label = Instance.new("TextLabel")
					label.Size = UDim2.fromScale(1, 1)
					label.BackgroundColor3 = Color3.fromRGB(34, 27, 62)
					label.BackgroundTransparency = 0.15
					label.Text = config.name .. "\n" .. config.cost .. " монет"
					label.TextColor3 = config.color
					label.TextStrokeColor3 = Color3.new(0, 0, 0)
					label.TextStrokeTransparency = 0.25
					label.TextScaled = false
					label.TextWrapped = true
					label.TextSize = 16
					label.Font = Enum.Font.GothamBlack
					label.Parent = labelGui
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(sendInventory)
Players.PlayerRemoving:Connect(function(player)
	local trade = activeTrades[player.UserId]
	if trade then
		local partner = if trade.a == player then trade.b else trade.a
		activeTrades[trade.a.UserId], activeTrades[trade.b.UserId] = nil, nil
		send(partner, "Обмен отменён: игрок вышел.", "error")
	end
	local request = pendingRequests[player.UserId]
	if request then send(request.from, "Запрос отменён: игрок вышел.", "error"); pendingRequests[player.UserId] = nil end
	for targetId, pending in pairs(pendingRequests) do
		if pending.from == player then pendingRequests[targetId] = nil end
	end
	inventories[player.UserId], lastCaseAt[player.UserId], openingCase[player.UserId], hotbars[player.UserId], firstCaseAwarded[player.UserId] = nil, nil, nil, nil, nil
end)

task.spawn(addCasePrompt)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(sendInventory, player) end
print("Brawl Card case and trading prototype ready")
