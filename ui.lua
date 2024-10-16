local udim_new = UDim.new
local udim2_new = UDim2.new
local color3_fromrgb = Color3.fromRGB
local instance_new = Instance.new
local nocallback = function() end
local mouse = GS.Players.LocalPlayer:GetMouse()
local GS = setmetatable({}, {
	__index = function(self, index)
		return game:GetService(index)
	end
})

local library = {
	flags = {
		GetState = function(s, flag)
			return library.flags[flag].State
		end
	},
	modules = {},
	currentTab = nil
}

function library:UpdateToggle(flag, value)
	local value = value or library.flags:GetState(flag)
	if value == library.flags:GetState(flag) then
		return
	end
	library.flags[flag]:SetState(value)
end

local utils = {}
function utils:Tween(properties, obj, time, style, direction)
	return GS.TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle[style or "Linear"], Enum.EasingDirection[direction or "InOut"]), properties)
end

function utils:SwitchTab(NewTabData)
	local OldTabData = library.currentTab
	if OldTabData == NewTabData then
		return
	end
	library.currentTab = NewTabData
	utils:Tween({
		Transparency = 1
	}, OldTabData[2].Glow):Play()
	utils:Tween({
		Transparency = 0
	}, NewTabData[2].Glow):Play()
	OldTabData[1].Visible = false
	NewTabData[1].Visible = true
end

function library:CreateWindow(windowName)
	local WoofUI = instance_new("ScreenGui")
	local Main = instance_new("Frame")
	local MainCorner = instance_new("UICorner")
	local TextLabel = instance_new("TextLabel")
	local TextLabelCorner = instance_new("UICorner")
	local Sidebar = instance_new("Frame")
	local SidebarCorner = instance_new("UICorner")
	local TabButtons = instance_new("ScrollingFrame")
	local TabButtonsLayout = instance_new("UIListLayout")
	local TabButtonsPadding = instance_new("UIPadding")
	local TabHolder = instance_new("Frame")
	local TabHolderCorner = instance_new("UICorner")

	local drag = function(objDrag, objHold)
		if not objHold then
			objHold = objDrag
		end
		local dragging
		local dragInput
		local dragStart
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			objDrag.Position = udim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
		objHold.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = objDrag.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		objDrag.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)
		GS.UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end

	drag(Main, TextLabel)

	WoofUI.Name = GS.HttpService:GenerateGUID(true)
	WoofUI.Parent = GS.CoreGui

	Main.Name = "Main"
	Main.Parent = WoofUI
	Main.BackgroundColor3 = color3_fromrgb(52, 62, 72)
	Main.BorderSizePixel = 0
	Main.Position = udim2_new(0.5, 0, 0.5, 0)
	Main.Size = udim2_new(0, 448, 0, 280)
	Main.AnchorPoint = Vector2.new(0.5, 0.5)

	MainCorner.CornerRadius = udim_new(0, 6)
	MainCorner.Name = "MainCorner"
	MainCorner.Parent = Main

	TextLabel.Parent = Main
	TextLabel.BackgroundColor3 = color3_fromrgb(58, 69, 80)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = udim2_new(0, 6, 0, 6)
	TextLabel.Size = udim2_new(0, 436, 0, 24)
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.Text = `  {windowName}`
	TextLabel.TextColor3 = color3_fromrgb(255, 255, 255)
	TextLabel.TextSize = 14.000
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	TextLabelCorner.CornerRadius = udim_new(0, 6)
	TextLabelCorner.Name = "TextLabelCorner"
	TextLabelCorner.Parent = TextLabel

	Sidebar.Name = "Sidebar"
	Sidebar.Parent = Main
	Sidebar.BackgroundColor3 = color3_fromrgb(58, 69, 80)
	Sidebar.BorderSizePixel = 0
	Sidebar.Position = udim2_new(0, 6, 0, 36)
	Sidebar.Size = udim2_new(0, 106, 0, 238)

	SidebarCorner.CornerRadius = udim_new(0, 6)
	SidebarCorner.Name = "SidebarCorner"
	SidebarCorner.Parent = Sidebar

	TabButtons.Name = "TabButtons"
	TabButtons.Parent = Sidebar
	TabButtons.Active = true
	TabButtons.BackgroundColor3 = color3_fromrgb(255, 255, 255)
	TabButtons.BackgroundTransparency = 1.000
	TabButtons.BorderSizePixel = 0
	TabButtons.Size = udim2_new(0, 106, 0, 238)
	TabButtons.ScrollBarThickness = 0

	TabButtonsLayout.Parent = TabButtons
	TabButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabButtonsLayout.Padding = udim_new(0, 5)

	TabButtonsPadding.Parent = TabButtons
	TabButtonsPadding.PaddingTop = udim_new(0, 6)

	TabHolder.Name = "TabHolder"
	TabHolder.Parent = Main
	TabHolder.BackgroundColor3 = color3_fromrgb(58, 69, 80)
	TabHolder.BorderSizePixel = 0
	TabHolder.Position = udim2_new(0, 118, 0, 36)
	TabHolder.Size = udim2_new(0, 324, 0, 238)

	TabHolderCorner.CornerRadius = udim_new(0, 6)
	TabHolderCorner.Name = "TabHolderCorner"
	TabHolderCorner.Parent = TabHolder

	TabButtonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabButtons.CanvasSize = udim2_new(0, 0, 0, TabButtonsLayout.AbsoluteContentSize.Y + 12)
	end)

	local window = {}
	function window:CreateTab(name)
		local TabButton = instance_new("TextButton")
		local TabButtonCorner = instance_new("UICorner")
		local Glow = instance_new("Frame")
		local GlowCorner = instance_new("UICorner")
		local GlowGradient = instance_new("UIGradient")
		local Tab = instance_new("ScrollingFrame")
		local TabPadding = instance_new("UIPadding")
		local TabLayout = instance_new("UIListLayout")
		TabButton.Name = "TabButton"
		TabButton.Parent = TabButtons
		TabButton.BackgroundColor3 = color3_fromrgb(52, 62, 72)
		TabButton.BorderSizePixel = 0
		TabButton.Size = udim2_new(0, 94, 0, 28)
		TabButton.AutoButtonColor = false
		TabButton.Font = Enum.Font.GothamSemibold
		TabButton.Text = name
		TabButton.TextColor3 = color3_fromrgb(255, 255, 255)
		TabButton.TextSize = 14.000
		TabButtonCorner.CornerRadius = udim_new(0, 6)
		TabButtonCorner.Name = "TabButtonCorner"
		TabButtonCorner.Parent = TabButton
		Glow.Name = "Glow"
		Glow.Parent = TabButton
		Glow.BackgroundColor3 = color3_fromrgb(255, 255, 255)
		Glow.BorderSizePixel = 0
		Glow.Position = udim2_new(0, 0, 0.928571463, 0)
		Glow.Size = udim2_new(0, 94, 0, 2)
		Glow.Transparency = 1
		GlowCorner.CornerRadius = udim_new(0, 6)
		GlowCorner.Name = "GlowCorner"
		GlowCorner.Parent = Glow
		GlowGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0.00, color3_fromrgb(52, 62, 72)),
			ColorSequenceKeypoint.new(0.50, color3_fromrgb(255, 255, 255)),
			ColorSequenceKeypoint.new(1.00, color3_fromrgb(52, 62, 72))
		}
		GlowGradient.Name = "GlowGradient"
		GlowGradient.Parent = Glow
		Tab.Name = "Tab"
		Tab.Parent = TabHolder
		Tab.Active = true
		Tab.BackgroundColor3 = color3_fromrgb(255, 255, 255)
		Tab.BackgroundTransparency = 1.000
		Tab.BorderSizePixel = 0
		Tab.Size = udim2_new(0, 324, 0, 238)
		Tab.ScrollBarThickness = 0
		Tab.Visible = false
		if library.currentTab == nil then
			library.currentTab = {
				Tab,
				TabButton
			}
			Glow.Transparency = 0
			Tab.Visible = true
		end
		TabPadding.Name = "TabPadding"
		TabPadding.Parent = Tab
		TabPadding.PaddingTop = udim_new(0, 6)
		TabLayout.Name = "TabLayout"
		TabLayout.Parent = Tab
		TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TabLayout.Padding = udim_new(0, 5)
		TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Tab.CanvasSize = udim2_new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 12)
		end)
		TabButton.MouseButton1Click:Connect(function()
			utils:SwitchTab({
				Tab,
				TabButton
			})
		end)
		local modules = {}
		function modules:NewSeparator()
			local Separator = instance_new("Frame")
			Separator.Transparency = 1
			Separator.Size = udim2_new(0, 0, 0, 0)
			Separator.BorderSizePixel = 0
			Separator.Parent = Tab
		end
		function modules:NewButton(text, callback)
			local callback = callback or nocallback
			local BtnModule = instance_new("TextButton")
			local BtnModuleCorner = instance_new("UICorner")
			BtnModule.Name = "BtnModule"
			BtnModule.Parent = Tab
			BtnModule.BackgroundColor3 = color3_fromrgb(52, 62, 72)
			BtnModule.BorderSizePixel = 0
			BtnModule.Size = udim2_new(0, 312, 0, 28)
			BtnModule.AutoButtonColor = false
			BtnModule.Font = Enum.Font.GothamSemibold
			BtnModule.Text = "  " .. text
			BtnModule.TextColor3 = color3_fromrgb(255, 255, 255)
			BtnModule.TextSize = 14.000
			BtnModule.TextXAlignment = Enum.TextXAlignment.Left
			BtnModuleCorner.CornerRadius = udim_new(0, 6)
			BtnModuleCorner.Name = "BtnModuleCorner"
			BtnModuleCorner.Parent = BtnModule
			BtnModule.MouseButton1Click:Connect(callback)
		end
		function modules:NewToggle(text, flag, enabled, callback)
			local callback = callback or nocallback
			local enabled = enabled or false
			print(enabled)
			local ToggleModule = instance_new("TextButton")
			local ToggleModuleCorner = instance_new("UICorner")
			local OffStatus = instance_new("Frame")
			local OffGrad = instance_new("UIGradient")
			local OffStatusCorner = instance_new("UICorner")
			local OnStatus = instance_new("Frame")
			local OnStatusCorner = instance_new("UICorner")
			local OnGrad = instance_new("UIGradient")
			library.flags[flag or text] = {
				State = false,
				Callback = callback,
				SetState = function(self, value)
					local value = (value ~= nil and value) or (not library.flags:GetState(flag))
					library.flags[flag].State = value
					task.spawn(function()
						library.flags[flag].Callback(value)
					end)
					utils:Tween({
						Transparency = value and 1 or 0
					}, OffStatus):Play()
					utils:Tween({
						Transparency = value and 0 or 1
					}, OnStatus):Play()
				end
			}
			ToggleModule.Name = "ToggleModule"
			ToggleModule.Parent = Tab
			ToggleModule.BackgroundColor3 = color3_fromrgb(52, 62, 72)
			ToggleModule.BorderSizePixel = 0
			ToggleModule.Size = udim2_new(0, 312, 0, 28)
			ToggleModule.AutoButtonColor = false
			ToggleModule.Font = Enum.Font.GothamSemibold
			ToggleModule.Text = "  " .. text
			ToggleModule.TextColor3 = color3_fromrgb(255, 255, 255)
			ToggleModule.TextSize = 14.000
			ToggleModule.TextXAlignment = Enum.TextXAlignment.Left
			ToggleModuleCorner.CornerRadius = udim_new(0, 6)
			ToggleModuleCorner.Name = "ToggleModuleCorner"
			ToggleModuleCorner.Parent = ToggleModule
			OffStatus.Name = "OffStatus"
			OffStatus.Parent = ToggleModule
			OffStatus.BackgroundColor3 = color3_fromrgb(255, 255, 255)
			OffStatus.BorderSizePixel = 0
			OffStatus.Position = udim2_new(0.878205061, 0, 0.178571433, 0)
			OffStatus.Size = udim2_new(0, 34, 0, 18)
			OffGrad.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0.00, color3_fromrgb(255, 83, 83)),
				ColorSequenceKeypoint.new(0.15, color3_fromrgb(255, 83, 83)),
				ColorSequenceKeypoint.new(0.62, color3_fromrgb(52, 62, 72)),
				ColorSequenceKeypoint.new(1.00, color3_fromrgb(52, 62, 72))
			}
			OffGrad.Rotation = 300
			OffGrad.Name = "OffGrad"
			OffGrad.Parent = OffStatus
			OffStatusCorner.CornerRadius = udim_new(0, 4)
			OffStatusCorner.Name = "OffStatusCorner"
			OffStatusCorner.Parent = OffStatus
			OnStatus.Name = "OnStatus"
			OnStatus.Parent = ToggleModule
			OnStatus.BackgroundColor3 = color3_fromrgb(255, 255, 255)
			OnStatus.BackgroundTransparency = 1.000
			OnStatus.BorderSizePixel = 0
			OnStatus.Position = udim2_new(0.878205121, 0, 0.178571433, 0)
			OnStatus.Size = udim2_new(0, 34, 0, 18)
			OnStatus.Transparency = 1
			OnStatusCorner.CornerRadius = udim_new(0, 4)
			OnStatusCorner.Name = "OnStatusCorner"
			OnStatusCorner.Parent = OnStatus
			OnGrad.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0.00, color3_fromrgb(52, 62, 72)),
				ColorSequenceKeypoint.new(0.38, color3_fromrgb(48, 57, 67)),
				ColorSequenceKeypoint.new(1.00, color3_fromrgb(53, 255, 134))
			}
			OnGrad.Rotation = 300
			OnGrad.Name = "OnGrad"
			OnGrad.Parent = OnStatus
			ToggleModule.MouseButton1Click:Connect(function()
				library.flags[flag or text]:SetState()
			end)
			if enabled then
				library.flags[flag or text]:SetState(enabled)
			end
		end
		function modules:NewBind(text, default, callback)
			local default = Enum.KeyCode[default]
			local banned = {
				Return = true;
				Space = true;
				Tab = true;
				Backquote = true;
				CapsLock = true;
				Escape = true;
				Unknown = true;
			}
			local shortNames = {
				RightControl = 'Right Ctrl',
				LeftControl = 'Left Ctrl',
				LeftShift = 'Left Shift',
				RightShift = 'Right Shift',
				Semicolon = ";",
				Quote = '"',
				LeftBracket = '[',
				RightBracket = ']',
				Equals = '=',
				Minus = '-',
				RightAlt = 'Right Alt',
				LeftAlt = 'Left Alt'
			}
			local bindKey = default
			local nm = (default and (shortNames[default.Name] or default.Name) or "None")
			local KeybindModule = instance_new("TextButton")
			local KeybindModuleCorner = instance_new("UICorner")
			local KeybindValue = instance_new("TextButton")
			local KeybindValueCorner = instance_new("UICorner")
			KeybindModule.Name = "KeybindModule"
			KeybindModule.Parent = Tab
			KeybindModule.BackgroundColor3 = color3_fromrgb(52, 62, 72)
			KeybindModule.BorderSizePixel = 0
			KeybindModule.Size = udim2_new(0, 312, 0, 28)
			KeybindModule.AutoButtonColor = false
			KeybindModule.Font = Enum.Font.GothamSemibold
			KeybindModule.Text = "  " .. text
			KeybindModule.TextColor3 = color3_fromrgb(255, 255, 255)
			KeybindModule.TextSize = 14.000
			KeybindModule.TextXAlignment = Enum.TextXAlignment.Left
			KeybindModuleCorner.CornerRadius = udim_new(0, 6)
			KeybindModuleCorner.Name = "KeybindModuleCorner"
			KeybindModuleCorner.Parent = KeybindModule
			KeybindValue.Name = "KeybindValue"
			KeybindValue.Parent = KeybindModule
			KeybindValue.BackgroundColor3 = color3_fromrgb(58, 69, 80)
			KeybindValue.BorderSizePixel = 0
			KeybindValue.Position = udim2_new(0.75, 0, 0.178571433, 0)
			KeybindValue.Size = udim2_new(0, 74, 0, 18)
			KeybindValue.AutoButtonColor = false
			KeybindValue.Font = Enum.Font.Gotham
			KeybindValue.Text = nm
			KeybindValue.TextColor3 = color3_fromrgb(255, 255, 255)
			KeybindValue.TextSize = 12.000
			KeybindValueCorner.CornerRadius = udim_new(0, 4)
			KeybindValueCorner.Name = "KeybindValueCorner"
			KeybindValueCorner.Parent = KeybindValue
			GS.UserInputService.InputBegan:Connect(function(inp, gpe)
				if gpe then
					return
				end
				if inp.UserInputType ~= Enum.UserInputType.Keyboard then
					return
				end
				if inp.KeyCode ~= bindKey then
					return
				end
				callback(bindKey.Name)
			end)
			KeybindValue.MouseButton1Click:Connect(function()
				KeybindValue.Text = "..."
				wait()
				local key, uwu = GS.UserInputService.InputEnded:Wait()
				local keyName = tostring(key.KeyCode.Name)
				if key.UserInputType ~= Enum.UserInputType.Keyboard then
					KeybindValue.Text = nm
					return
				end
				if banned[keyName] then
					KeybindValue.Text = nm
					return
				end
				wait()
				bindKey = Enum.KeyCode[keyName]
				KeybindValue.Text = shortNames[keyName] or keyName
			end)
		end
		function modules:NewSlider(text, flag, default, min, max, precise, callback)
			local default = default or min
			local callback = callback or nocallback
			local SliderModule = instance_new("TextButton")
			local SliderModuleCorner = instance_new("UICorner")
			local SliderBar = instance_new("Frame")
			local SliderBarCorner = instance_new("UICorner")
			local SliderPart = instance_new("Frame")
			local SliderPartCorner = instance_new("UICorner")
			local SliderValue = instance_new("TextBox")
			local SliderValueCorner = instance_new("UICorner")
			local AddSlider = instance_new("TextButton")
			local MinusSlider = instance_new("TextButton")
			library.flags[flag] = {
				State = default,
				SetValue = function(self, value)
					local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
					if value then
						percent = (value - min) / (max - min)
					end
					percent = math.clamp(percent, 0, 1)
					if precise then
						value = value or tonumber(string.format("%.1f", tostring(min + (max - min) * percent)))
					else
						value = value or math.floor(min + (max - min) * percent)
					end
					library.flags[flag].State = tonumber(value)
					SliderValue.Text = tostring(value)
					SliderPart.Size = udim2_new(percent, 0, 1, 0)
					callback(tonumber(value))
				end
			}
			SliderModule.Name = "SliderModule"
			SliderModule.Parent = Tab
			SliderModule.BackgroundColor3 = color3_fromrgb(52, 62, 72)
			SliderModule.BorderSizePixel = 0
			SliderModule.Position = udim2_new(0, 0, -0.140425533, 0)
			SliderModule.Size = udim2_new(0, 312, 0, 28)
			SliderModule.AutoButtonColor = false
			SliderModule.Font = Enum.Font.GothamSemibold
			SliderModule.Text = "  " .. text
			SliderModule.TextColor3 = color3_fromrgb(255, 255, 255)
			SliderModule.TextSize = 14.000
			SliderModule.TextXAlignment = Enum.TextXAlignment.Left
			SliderModuleCorner.CornerRadius = udim_new(0, 6)
			SliderModuleCorner.Name = "SliderModuleCorner"
			SliderModuleCorner.Parent = SliderModule
			SliderBar.Name = "SliderBar"
			SliderBar.Parent = SliderModule
			SliderBar.BackgroundColor3 = color3_fromrgb(58, 69, 80)
			SliderBar.BorderSizePixel = 0
			SliderBar.Position = udim2_new(0.442307681, 0, 0.392857134, 0)
			SliderBar.Size = udim2_new(0, 108, 0, 6)
			SliderBarCorner.CornerRadius = udim_new(0, 2)
			SliderBarCorner.Name = "SliderBarCorner"
			SliderBarCorner.Parent = SliderBar
			SliderPart.Name = "SliderPart"
			SliderPart.Parent = SliderBar
			SliderPart.BackgroundColor3 = color3_fromrgb(255, 255, 255)
			SliderPart.BorderSizePixel = 0
			SliderPart.Size = udim2_new(0, 0, 0, 6)
			SliderPartCorner.CornerRadius = udim_new(0, 2)
			SliderPartCorner.Name = "SliderPartCorner"
			SliderPartCorner.Parent = SliderPart
			SliderValue.Name = "SliderValue"
			SliderValue.Parent = SliderModule
			SliderValue.BackgroundColor3 = color3_fromrgb(58, 69, 80)
			SliderValue.BorderSizePixel = 0
			SliderValue.Position = udim2_new(0.884615362, 0, 0.178571433, 0)
			SliderValue.Size = udim2_new(0, 32, 0, 18)
			SliderValue.Font = Enum.Font.Gotham
			SliderValue.Text = default or min
			SliderValue.TextColor3 = color3_fromrgb(255, 255, 255)
			SliderValue.TextSize = 12.000
			SliderValueCorner.CornerRadius = udim_new(0, 4)
			SliderValueCorner.Name = "SliderValueCorner"
			SliderValueCorner.Parent = SliderValue
			AddSlider.Name = "AddSlider"
			AddSlider.Parent = SliderModule
			AddSlider.BackgroundColor3 = color3_fromrgb(255, 255, 255)
			AddSlider.BackgroundTransparency = 1.000
			AddSlider.BorderSizePixel = 0
			AddSlider.Position = udim2_new(0.807692289, 0, 0.178571433, 0)
			AddSlider.Size = udim2_new(0, 18, 0, 18)
			AddSlider.Font = Enum.Font.Gotham
			AddSlider.Text = "+"
			AddSlider.TextColor3 = color3_fromrgb(255, 255, 255)
			AddSlider.TextSize = 18.000
			MinusSlider.Name = "MinusSlider"
			MinusSlider.Parent = SliderModule
			MinusSlider.BackgroundColor3 = color3_fromrgb(255, 255, 255)
			MinusSlider.BackgroundTransparency = 1.000
			MinusSlider.BorderSizePixel = 0
			MinusSlider.Position = udim2_new(0.365384609, 0, 0.178571433, 0)
			MinusSlider.Size = udim2_new(0, 18, 0, 18)
			MinusSlider.Font = Enum.Font.Gotham
			MinusSlider.Text = "-"
			MinusSlider.TextColor3 = color3_fromrgb(255, 255, 255)
			MinusSlider.TextSize = 18.000
			MinusSlider.MouseButton1Click:Connect(function()
				local currentValue = library.flags:GetState(flag)
				currentValue = math.clamp(currentValue - 1, min, max)
				library.flags[flag]:SetValue(currentValue)
			end)
			AddSlider.MouseButton1Click:Connect(function()
				local currentValue = library.flags:GetState(flag)
				currentValue = math.clamp(currentValue + 1, min, max)
				library.flags[flag]:SetValue(currentValue)
			end)
			library.flags[flag]:SetValue(default)
			local dragging, boxFocused, allowed = false, false, {
				[""] = true,
				["-"] = true
			}
			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					library.flags[flag]:SetValue()
					dragging = true
				end
			end)
			GS.UserInputService.InputEnded:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			GS.UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					library.flags[flag]:SetValue()
				end
			end)
			SliderValue.Focused:Connect(function()
				boxFocused = true
			end)
			SliderValue.FocusLost:Connect(function()
				boxFocused = false
				if SliderValue.Text == "" then
					library.flags[flag]:SetValue(default)
				end
			end)
			SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
				if not boxFocused then
					return
				end
				SliderValue.Text = SliderValue.Text:gsub("%D+", "")
				local text = SliderValue.Text
				if not tonumber(text) then
					SliderValue.Text = SliderValue.Text:gsub('%D+', '')
				elseif not allowed[text] then
					if tonumber(text) > max then
						text = max
						SliderValue.Text = tostring(max)
					end
					library.flags[flag]:SetValue(tonumber(text))
				end
			end)
		end
		function modules:NewDropdown(text, flag, options, callback)
			local callback = callback or nocallback
			library.flags[flag] = {
				State = options[1]
			}
			local DropdownModule = instance_new("TextButton")
			local DropdownModuleCorner = instance_new("UICorner")
			local DropdownText = instance_new("TextBox")
			local OpenDropdown = instance_new("TextButton")
			local DropdownBottom = instance_new("TextButton")
			local DropdownBottomCorner = instance_new("UICorner")
			local DropdownBottomLayout = instance_new("UIListLayout")
			local DropdownBottomPadding = instance_new("UIPadding")
			DropdownModule.Name = "DropdownModule"
			DropdownModule.Parent = Tab
			DropdownModule.BackgroundColor3 = color3_fromrgb(52, 62, 72)
			DropdownModule.BorderSizePixel = 0
			DropdownModule.Size = udim2_new(0, 312, 0, 28)
			DropdownModule.AutoButtonColor = false
			DropdownModule.Font = Enum.Font.GothamSemibold
			DropdownModule.Text = ""
			DropdownModule.TextColor3 = color3_fromrgb(255, 255, 255)
			DropdownModule.TextSize = 14.000
			DropdownModule.TextXAlignment = Enum.TextXAlignment.Left
			DropdownModuleCorner.CornerRadius = udim_new(0, 6)
			DropdownModuleCorner.Name = "DropdownModuleCorner"
			DropdownModuleCorner.Parent = DropdownModule
			DropdownText.Name = "DropdownText"
			DropdownText.Parent = DropdownModule
			DropdownText.BackgroundColor3 = color3_fromrgb(255, 255, 255)
			DropdownText.BackgroundTransparency = 1.000
			DropdownText.Position = udim2_new(0.025641026, 0, 0, 0)
			DropdownText.Size = udim2_new(0, 192, 0, 28)
			DropdownText.Font = Enum.Font.GothamSemibold
			DropdownText.PlaceholderText = text
			DropdownText.PlaceholderColor3 = color3_fromrgb(255, 255, 255)
			DropdownText.TextColor3 = color3_fromrgb(255, 255, 255)
			DropdownText.TextSize = 14.000
			DropdownText.TextXAlignment = Enum.TextXAlignment.Left
			DropdownText.Text = ""
			OpenDropdown.Name = "OpenDropdown"
			OpenDropdown.Parent = DropdownModule
			OpenDropdown.BackgroundColor3 = color3_fromrgb(255, 255, 255)
			OpenDropdown.BackgroundTransparency = 1.000
			OpenDropdown.BorderSizePixel = 0
			OpenDropdown.Position = udim2_new(0.907051265, 0, 0.178571433, 0)
			OpenDropdown.Size = udim2_new(0, 18, 0, 18)
			OpenDropdown.Font = Enum.Font.Gotham
			OpenDropdown.Text = "+"
			OpenDropdown.TextColor3 = color3_fromrgb(255, 255, 255)
			OpenDropdown.TextSize = 22.000
			DropdownBottom.Name = "DropdownBottom"
			DropdownBottom.Parent = Tab
			DropdownBottom.BackgroundColor3 = color3_fromrgb(52, 62, 72)
			DropdownBottom.BorderSizePixel = 0
			DropdownBottom.ClipsDescendants = true
			DropdownBottom.Position = udim2_new(0.0185185187, 0, 0.206896558, 0)
			DropdownBottom.Size = udim2_new(0, 312, 0, 0)
			DropdownBottom.AutoButtonColor = false
			DropdownBottom.Font = Enum.Font.GothamSemibold
			DropdownBottom.Text = ""
			DropdownBottom.TextColor3 = color3_fromrgb(255, 255, 255)
			DropdownBottom.TextSize = 14.000
			DropdownBottom.TextXAlignment = Enum.TextXAlignment.Left
			DropdownBottom.Visible = false
			DropdownBottomCorner.CornerRadius = udim_new(0, 6)
			DropdownBottomCorner.Name = "DropdownBottomCorner"
			DropdownBottomCorner.Parent = DropdownBottom
			DropdownBottomLayout.Name = "DropdownBottomLayout"
			DropdownBottomLayout.Parent = DropdownBottom
			DropdownBottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			DropdownBottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
			DropdownBottomLayout.Padding = udim_new(0, 6)
			DropdownBottomPadding.Name = "DropdownBottomPadding"
			DropdownBottomPadding.Parent = DropdownBottom
			DropdownBottomPadding.PaddingTop = udim_new(0, 6)
			local dropdownOpen = false
			DropdownBottomLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if not dropdownOpen then
					return
				end
				utils:Tween({
					Size = udim2_new(0, 312, 0, DropdownBottomLayout.AbsoluteContentSize.Y + 12)
				}, DropdownBottom, 0.1):Play()
			end)
			local setAllVisible = function()
				local options = DropdownBottom:GetChildren()
				for i = 1, #options do
					local option = options[i]
					if option:IsA("TextButton") then
						option.Visible = true
					end
				end
			end
			local searchDropdown = function(text)
				local options = DropdownBottom:GetChildren()
				for i = 1, #options do
					local option = options[i]
					if text == "" then
						setAllVisible()
					else
						if option:IsA("TextButton") then
							if option.Name:lower():sub(1, string.len(text)) == text:lower() then
								option.Visible = true
							else
								option.Visible = false
							end
						end
					end
				end
			end
			local toggleDropdown = function()
				dropdownOpen = not dropdownOpen
				if dropdownOpen then
					DropdownBottom.Visible = true
					setAllVisible()
				else
					task.spawn(function()
						task.wait(0.35)
						DropdownBottom.Visible = false
					end)
				end
				OpenDropdown.Text = (dropdownOpen and "-" or "+")
				utils:Tween({
					Size = udim2_new(0, 312, 0, (dropdownOpen and DropdownBottomLayout.AbsoluteContentSize.Y + 12 or 0))
				}, DropdownBottom, 0.35):Play()
			end
			OpenDropdown.MouseButton1Click:Connect(toggleDropdown)
			DropdownText.Focused:Connect(function()
				if dropdownOpen then
					return
				end
				toggleDropdown()
			end)
			DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
				searchDropdown(DropdownText.Text)
			end)
			library.flags[flag].SetOptions = function(self, options)
				library.flags[flag]:ClearOptions()
				for i = 1, #options do
					library.flags[flag]:AddOption(options[i])
				end
			end
			library.flags[flag].ClearOptions = function(self)
				local oldOptions = DropdownBottom:GetChildren()
				for i = 1, #oldOptions do
					local obj = oldOptions[i]
					if obj:IsA("TextButton") then
						obj:Destroy()
					end
				end
			end
			library.flags[flag].AddOption = function(self, option)
				local Option = instance_new("TextButton")
				local OptionCorner = instance_new("UICorner")
				Option.Name = option
				Option.Parent = DropdownBottom
				Option.BackgroundColor3 = color3_fromrgb(58, 69, 80)
				Option.BorderSizePixel = 0
				Option.Size = udim2_new(0, 300, 0, 28)
				Option.AutoButtonColor = false
				Option.Font = Enum.Font.GothamSemibold
				Option.Text = option
				Option.TextColor3 = color3_fromrgb(255, 255, 255)
				Option.TextSize = 14.000
				OptionCorner.CornerRadius = udim_new(0, 6)
				OptionCorner.Name = "OptionCorner"
				OptionCorner.Parent = Option
				Option.MouseButton1Click:Connect(function()
					DropdownText.PlaceholderText = option
					DropdownText.Text = ""
					library.flags[flag].State = option
					task.spawn(toggleDropdown)
					callback(option)
				end)
			end
			library.flags[flag].RemoveOption = function(self, option)
				DropdownBottom:WaitForChild(option):Destroy()
			end
			library.flags[flag]:SetOptions(options)
		end
		return modules
	end
	return window
end
