--==================================================
-- FRUIT TRACKER
-- Procura frutas no Workspace pelo NOME DO MODELO
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIGURAÇÃO
--==================================================

local UPDATE_TIME = 0.5
local TEXT_SIZE = 14

-- Nomes genéricos que NÃO são considerados
-- nomes reais de frutas.
local GENERIC_NAMES = {
	["fruit"] = true,
	["handle"] = true,
	["model"] = true,
	["mesh"] = true,
	["part"] = true,
	["root"] = true,
}

--==================================================
-- LIMPAR GUI ANTIGA
--==================================================

local old = playerGui:FindFirstChild("FruitTracker")

if old then
	old:Destroy()
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "FruitTracker"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(350,400)
main.Position = UDim2.fromOffset(30,100)
main.BackgroundColor3 = Color3.fromRGB(24,24,24)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,12)
mainCorner.Parent = main

--==================================================
-- CABEÇALHO
--==================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0,52)
header.BackgroundColor3 = Color3.fromRGB(38,38,38)
header.BorderSizePixel = 0
header.Active = true
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0,12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-55,1,0)
title.Position = UDim2.fromOffset(12,0)
title.BackgroundTransparency = 1
title.Text = "🍎  FRUTAS SPAWNADAS"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(40,40)
minimize.Position = UDim2.new(1,-46,0,6)
minimize.BackgroundTransparency = 1
minimize.Text = "−"
minimize.TextColor3 = Color3.new(1,1,1)
minimize.TextSize = 25
minimize.Font = Enum.Font.GothamBold
minimize.Parent = header

--==================================================
-- LISTA
--==================================================

local list = Instance.new("ScrollingFrame")
list.Name = "FruitList"
list.Position = UDim2.fromOffset(10,62)
list.Size = UDim2.new(1,-20,1,-72)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.new(0,0,0,0)
list.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = list

--==================================================
-- PEGAR O NOME DO MODELO DA FRUTA
--==================================================

local function getFruitModelName(object)

	-- Se o próprio objeto for um Model com nome real
	if object:IsA("Model") then

		local name = object.Name

		if not GENERIC_NAMES[name:lower()] then
			return name
		end
	end

	-- Se encontrou uma peça chamada Fruit,
	-- procura o Model pai.
	local parent = object.Parent

	while parent and parent ~= workspace do

		if parent:IsA("Model") then

			local name = parent.Name

			if not GENERIC_NAMES[name:lower()] then
				return name
			end
		end

		parent = parent.Parent
	end

	return nil
end

--==================================================
-- DETECTAR FRUTA
--==================================================

local function isFruitObject(object)

	local name = object.Name:lower()

	-- Detecta o objeto chamado Fruit
	if name == "fruit" then
		return true
	end

	-- Detecta nomes que contenham fruit
	if name:find("fruit",1,true) then
		return true
	end

	return false
end

--==================================================
-- PARTE PRINCIPAL
--==================================================

local function getMainPart(model)

	if model:IsA("BasePart") then
		return model
	end

	if model:IsA("Model") then

		if model.PrimaryPart then
			return model.PrimaryPart
		end

		local handle = model:FindFirstChild(
			"Handle",
			true
		)

		if handle and handle:IsA("BasePart") then
			return handle
		end

		return model:FindFirstChildWhichIsA(
			"BasePart",
			true
		)
	end

	return nil
end

--==================================================
-- NOME ACIMA DA FRUTA
--==================================================

local function createNameTag(model,name)

	local part = getMainPart(model)

	if not part then
		return
	end

	local oldTag = part:FindFirstChild(
		"FruitNameDisplay"
	)

	if oldTag then
		oldTag:Destroy()
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "FruitNameDisplay"
	billboard.Adornee = part
	billboard.Size = UDim2.fromOffset(180,30)
	billboard.StudsOffsetWorldSpace =
		Vector3.new(0,4,0)

	billboard.AlwaysOnTop = true
	billboard.MaxDistance = math.huge
	billboard.Parent = part

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1,1)
	text.BackgroundTransparency = 1

	-- NOME DO MODELO
	text.Text = name

	text.TextColor3 = Color3.new(1,1,1)
	text.TextStrokeColor3 = Color3.new(0,0,0)
	text.TextStrokeTransparency = 0
	text.TextSize = TEXT_SIZE
	text.Font = Enum.Font.GothamBold
	text.Parent = billboard
end

--==================================================
-- ATUALIZAR
--==================================================

local function update()

	-- Limpar painel
	for _, child in ipairs(list:GetChildren()) do

		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local fruits = {}
	local alreadyFound = {}

	for _, object in ipairs(workspace:GetDescendants()) do

		if isFruitObject(object) then

			-- Procura o Model que contém o objeto
			local model = object

			if not model:IsA("Model") then

				model = object:FindFirstAncestorOfClass(
					"Model"
				)
			end

			if model and not alreadyFound[model] then

				local fruitName =
					getFruitModelName(model)

				if fruitName then

					alreadyFound[model] = true

					table.insert(
						fruits,
						{
							Model = model,
							Name = fruitName
						}
					)
				end
			end
		end
	end

	--==================================================
	-- NENHUMA FRUTA
	--==================================================

	if #fruits == 0 then

		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1,-5,0,45)
		empty.BackgroundTransparency = 1
		empty.Text = "Nenhuma fruta encontrada."
		empty.TextColor3 =
			Color3.fromRGB(170,170,170)
		empty.TextSize = 15
		empty.Font = Enum.Font.Gotham
		empty.Parent = list

	else

		--==================================================
		-- MOSTRAR FRUTAS
		--==================================================

		for _, fruit in ipairs(fruits) do

			createNameTag(
				fruit.Model,
				fruit.Name
			)

			local item = Instance.new("TextLabel")

			item.Size =
				UDim2.new(1,-5,0,42)

			item.BackgroundColor3 =
				Color3.fromRGB(45,45,45)

			item.BorderSizePixel = 0

			item.Text =
				"🍎  " .. fruit.Name

			item.TextColor3 =
				Color3.new(1,1,1)

			item.TextSize = 15
			item.Font =
				Enum.Font.GothamBold

			item.TextXAlignment =
				Enum.TextXAlignment.Left

			item.Parent = list

			local padding =
				Instance.new("UIPadding")

			padding.PaddingLeft =
				UDim.new(0,10)

			padding.Parent = item

			local corner =
				Instance.new("UICorner")

			corner.CornerRadius =
				UDim.new(0,8)

			corner.Parent = item
		end
	end

	list.CanvasSize = UDim2.new(
		0,
		0,
		0,
		layout.AbsoluteContentSize.Y + 10
	)
end

--==================================================
-- ARRASTAR PAINEL
--==================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position

	end
end)

UIS.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta =
			input.Position - dragStart

		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,

			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)

--==================================================
-- MINIMIZAR
--==================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then

		list.Visible = false
		main.Size = UDim2.fromOffset(350,52)
		minimize.Text = "+"

	else

		list.Visible = true
		main.Size = UDim2.fromOffset(350,400)
		minimize.Text = "−"

	end
end)

--==================================================
-- ATUALIZAÇÃO
--==================================================

task.spawn(function()

	while gui.Parent do

		update()

		task.wait(UPDATE_TIME)

	end
end)

update()