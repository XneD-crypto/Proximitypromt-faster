-- СУЩЕСТВОВАТЬ: Instant Prompt + Anti-Delay (все кнопки без задержки)
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local Credits = Instance.new("TextLabel")
local UICorner_Frame = Instance.new("UICorner")
local UICorner_Button = Instance.new("UICorner")
local UICorner_Min = Instance.new("UICorner")

ScreenGui.Name = "InstantPromptHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 160)
MainFrame.Active = true
MainFrame.ClipsDescendants = true

UICorner_Frame.CornerRadius = UDim.new(0, 10)
UICorner_Frame.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Size = UDim2.new(0, 140, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Instant + Anti-Delay"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeButton.Position = UDim2.new(1, -35, 0, 12)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16

UICorner_Min.CornerRadius = UDim.new(0, 5)
UICorner_Min.Parent = MinimizeButton

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleButton.Position = UDim2.new(0.5, 0, 0.52, 0)
ToggleButton.Size = UDim2.new(0, 160, 0, 40)
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

UICorner_Button.CornerRadius = UDim.new(0, 8)
UICorner_Button.Parent = ToggleButton

Credits.Name = "Credits"
Credits.Parent = MainFrame
Credits.BackgroundTransparency = 1
Credits.Position = UDim2.new(0, 0, 1, -25)
Credits.Size = UDim2.new(1, 0, 0, 20)
Credits.Font = Enum.Font.GothamSemibold
Credits.Text = "Exist | Anti-Delay"
Credits.TextColor3 = Color3.fromRGB(255, 255, 255)
Credits.TextSize = 10

-- Перетаскивание
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Основной функционал: убираем задержку ВСЕХ ProximityPrompt
local promptHackEnabled = false
local originalDurations = {}

-- Перехват ВСЕХ новых ProximityPrompt
ProximityPromptService.PromptShown:Connect(function(prompt)
    if promptHackEnabled then
        if not originalDurations[prompt] then
            originalDurations[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    end
end)

-- Убираем задержку у уже существующих ProximityPrompt
local function clearAllDelays()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if not originalDurations[obj] then
                originalDurations[obj] = obj.HoldDuration
            end
            if promptHackEnabled then
                obj.HoldDuration = 0
            else
                if originalDurations[obj] then
                    obj.HoldDuration = originalDurations[obj]
                end
            end
        end
    end
end

-- Сканируем новые объекты
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and promptHackEnabled then
        if not originalDurations[obj] then
            originalDurations[obj] = obj.HoldDuration
        end
        obj.HoldDuration = 0
    end
end)

local function toggleHack()
    promptHackEnabled = not promptHackEnabled
    if promptHackEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        ToggleButton.Text = "ON"
        clearAllDelays()
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton.Text = "OFF"
        -- Восстанавливаем оригинальные задержки
        for prompt, originalTime in pairs(originalDurations) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = originalTime
            end
        end
        table.clear(originalDurations)
    end
end

ToggleButton.MouseButton1Click:Connect(toggleHack)

local minimized = false
local function toggleMinimize()
    minimized = not minimized
    if minimized then
        ToggleButton.Visible = false
        Credits.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 200, 0, 48), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 200, 0, 160), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeButton.Text = "-"
        task.wait(0.1)
        ToggleButton.Visible = true
        Credits.Visible = true
    end
end

MinimizeButton.MouseButton1Click:Connect(toggleMinimize)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.V then
        toggleHack()
    elseif input.KeyCode == Enum.KeyCode.P then
        toggleMinimize()
    end
end)
