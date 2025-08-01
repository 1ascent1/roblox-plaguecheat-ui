local UserInputService = game:GetService("UserInputService")

local ui = {}

-- Utility function to create instances
local function create(class, props)
	local instance = Instance.new(class)
	for prop, value in pairs(props) do
		instance[prop] = value
	end
	return instance
end

local function createKeybindHandler(keybindButton, callback)
	local listening = false
	local currentKey = Enum.KeyCode.Unknown
	local bindType = "Toggle" -- Can be "Toggle", "Hold", or "Always"

	-- Left click: change keybind
	keybindButton.MouseButton1Click:Connect(function()
		listening = true
		keybindButton.Text = "[...]"
	end)

	-- Right click: show bind type options
	keybindButton.MouseButton2Click:Connect(function()
		-- Find or create the keybind window
		local keybindWindow = keybindButton:FindFirstChild("KeybindWindow")
		if not keybindWindow then
			keybindWindow = create("Frame", {
				Name = "KeybindWindow",
				Parent = keybindButton,
				Visible = false,
				ZIndex = 5,
				BackgroundColor3 = Color3.fromRGB(19, 19, 19),
				Size = UDim2.new(0, 44, 0, 44),
				Position = UDim2.new(0, -5, 0, 14),
				BorderColor3 = Color3.fromRGB(30, 30, 30)
			})

			local layout = create("UIListLayout", {
				Parent = keybindWindow,
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			local function createOption(text, value)
				local option = create("TextButton", {
					Text = text,
					Size = UDim2.new(1, 0, 0, 15),
					BackgroundTransparency = 1,
					TextColor3 = bindType == value and Color3.fromRGB(255, 255, 255) 
						or Color3.fromRGB(200, 200, 200),
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				option.MouseButton1Click:Connect(function()
					bindType = value
					keybindWindow.Visible = false
					-- Update all option colors
					for _, child in ipairs(keybindWindow:GetChildren()) do
						if child:IsA("TextButton") then
							child.TextColor3 = child.Text == text and Color3.fromRGB(255, 255, 255)
								or Color3.fromRGB(200, 200, 200)
						end
					end
				end)

				return option
			end

			createOption("Toggle", "Toggle").Parent = keybindWindow
			createOption("Hold", "Hold").Parent = keybindWindow
			createOption("Always", "Always").Parent = keybindWindow
		end

		keybindWindow.Visible = not keybindWindow.Visible
	end)

	local function setKey(keyCode)
		if keyCode == Enum.KeyCode.Unknown then return end
		currentKey = keyCode
		local keyName = keyCode.Name
		keybindButton.Text = "["..keyName.."]"
		if callback then callback(keyCode, bindType) end
		listening = false
	end

	local connection
	connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not listening then
			-- Handle keybind activation based on bindType
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
				if bindType == "Toggle" then
					callback(currentKey, bindType)
				elseif bindType == "Hold" then
					-- You'll need to track this in your toggle state
				end
				return
			end
			return
		end

		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			setKey(input.KeyCode)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			setKey(Enum.KeyCode.MouseButton1)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			setKey(Enum.KeyCode.MouseButton2)
		end
	end)

	-- Handle Hold functionality
	if bindType == "Hold" then
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
				-- Handle key release for hold functionality
			end
		end)
	end

	local function destroy()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	return {
		Get = function() return currentKey, bindType end,
		Set = function(keyCode) setKey(keyCode) end,
		SetType = function(type) bindType = type end,
		Destroy = destroy
	}
end

-- Window creation
function ui:Window(options)
	options = options or {}
	local window = {
		title = options.title or "UI Window",
		size = options.size or Vector2.new(555, 475),
		tabs = {}
	}

	-- Create main screen gui
	local screenGui = create("ScreenGui", {
		Name = "Ui",
		Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})


	-- Main frame
	local mainFrame = create("Frame", {
		Name = "Main",
		Parent = screenGui,
		BackgroundColor3 = Color3.fromRGB(21, 21, 21),
		BorderMode = Enum.BorderMode.Inset,
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.new(0, window.size.X, 0, window.size.Y),
		Position = UDim2.new(0.5, -window.size.X/2, 0.5, -window.size.Y/2),
		BorderColor3 = Color3.fromRGB(29, 29, 29)
	})


	-- Main outline stroke
	create("UIStroke", {
		Name = "MainOutline",
		Parent = mainFrame,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Miter
	})

	-- Holder frame
	local holder = create("Frame", {
		Name = "Holder",
		Parent = mainFrame,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(14, 14, 14),
		Size = UDim2.new(1, 0, 1, -48),
		Position = UDim2.new(0, 0, 0, 24),
		BorderColor3 = Color3.fromRGB(0, 0, 0)
	})

	-- Top and bottom accent lines
	create("Frame", {
		Name = "TopAccentLine",
		Parent = holder,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(91, 134, 198),
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, -1)
	})

	create("Frame", {
		Name = "BottomAccentLine",
		Parent = holder,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(91, 134, 198),
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0)
	})

	-- Tabs container
	local tabsContainer = create("Frame", {
		Name = "Tabs",
		Parent = mainFrame,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		BorderColor3 = Color3.fromRGB(0, 0, 0)
	})

	create("UIPadding", {
		Name = "TabsPadding",
		Parent = tabsContainer,
		PaddingLeft = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 3)
	})

	create("UIListLayout", {
		Name = "TabsLayout",
		Parent = tabsContainer,
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal
	})

	-- Title text
	local titleText = create("TextLabel", {
		Name = "TitleText",
		Parent = mainFrame,
		BorderSizePixel = 0,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		Text = window.title,
		FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
		TextColor3 = Color3.fromRGB(255, 255, 255)
	})

	create("UIPadding", {
		Name = "TitleTextPadding",
		Parent = titleText,
		PaddingLeft = UDim.new(0, 5)
	})

	-- Version text
	local versionText = create("TextLabel", {
		Name = "VersionText",
		Parent = mainFrame,
		BorderSizePixel = 0,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		Text = "v1.0",
		FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
		TextColor3 = Color3.fromRGB(255, 255, 255)
	})

	create("UIPadding", {
		Name = "VersionTextPadding",
		Parent = versionText,
		PaddingRight = UDim.new(0, 5)
	})

	-- Welcome text
	local welcomeText = create("TextLabel", {
		Name = "WelcomeText",
		Parent = mainFrame,
		BorderSizePixel = 0,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Text = "Welcome boss, UID -1",
		FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
		TextColor3 = Color3.fromRGB(255, 255, 255)
	})

	create("UIPadding", {
		Name = "WelcomeTextPadding",
		Parent = welcomeText,
		PaddingRight = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 1)
	})


	-- At the start of your drag/resize code:
	local dragData = {
		dragging = false,
		dragStart = Vector2.new(0, 0),
		startPos = UDim2.new(0, 0, 0, 0)
	}

	local resizeData = {
		resizing = false,
		resizeStart = Vector2.new(0, 0),
		startSize = UDim2.new(0, 0, 0, 0)
	}

	local resizeHandle = Instance.new("Frame")
	resizeHandle.Size = UDim2.new(0, 25, 0, 25)
	resizeHandle.Position = UDim2.new(1, -25, 1, -25)
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.Parent = mainFrame
	
	-- Resize functionality
	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizeData.resizing = true
			dragData.dragging = false -- Prevent dragging while resizing
			resizeData.resizeStart = input.Position
			resizeData.startSize = mainFrame.Size

			-- Lock the current position to prevent jumping
			dragData.startPos = mainFrame.Position
		end
	end)

	-- Dragging functionality
	mainFrame.InputBegan:Connect(function(input)
		-- Don't start drag if clicking resize handle or already resizing
		if input.UserInputType == Enum.UserInputType.MouseButton1 
			and not resizeData.resizing
			and input.Position.X < (mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X - 25)
			and input.Position.Y < (mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y - 25) then

			dragData.dragging = true
			dragData.dragStart = input.Position
			dragData.startPos = mainFrame.Position
		end
	end)

	-- Handle input changes
	UserInputService.InputChanged:Connect(function(input)
		if resizeData.resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resizeData.resizeStart

			-- Calculate new size with minimum constraints (400x300)
			local newWidth = math.max(400, resizeData.startSize.X.Offset + delta.X)
			local newHeight = math.max(300, resizeData.startSize.Y.Offset + delta.Y)

			-- Apply new size while maintaining position
			mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
			mainFrame.Position = dragData.startPos -- Maintain original position

		elseif dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragData.dragStart
			mainFrame.Position = UDim2.new(
				dragData.startPos.X.Scale,
				dragData.startPos.X.Offset + delta.X,
				dragData.startPos.Y.Scale, 
				dragData.startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- Clean up on input end
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragData.dragging = false
			resizeData.resizing = false
		end
	end)



	-- Window methods
	function window:Tab(name)
		local tab = {
			name = name,
			sections = {},
			active = false
		}

		-- Create tab button with inactive color by default
		local tabButton = create("TextButton", {
			Name = "TabButton",
			Parent = tabsContainer,
			BorderSizePixel = 0,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(200, 200, 200), -- Inactive color
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			Text = name,
			FontFace = Font.new("rbxasset://fonts/families/Zekton.json")
		})

		-- Create holder for this tab's content
		tab.content = create("Frame", {
			Name = name .. "Content",
			Parent = holder,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false -- Start with all tabs hidden
		})

		-- Tab switching functionality
		tabButton.MouseButton1Click:Connect(function()
			-- Hide all tab contents and set to inactive color
			for _, otherTab in pairs(window.tabs) do
				otherTab.active = false
				otherTab.content.Visible = false
				otherTab.tabButton.TextColor3 = Color3.fromRGB(200, 200, 200) -- Inactive color
			end

			-- Show this tab's content and set to active color
			tab.active = true
			tab.content.Visible = true
			tabButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Active color
		end)

		-- If first tab, make it active
		if #window.tabs == 0 then
			tab.active = true
			tab.content.Visible = true
			tabButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Active color
		end

		tab.tabButton = tabButton
		window.tabs[#window.tabs + 1] = tab

		-- Tab methods
		function tab:Section(name, side)
			local section = {
				name = name,
				elements = {},
				side = side or "left"
			}

			-- Calculate position based on side
			local position
			if side == "right" then
				position = UDim2.new(0.5, 7, 0, 11)
			else
				position = UDim2.new(0, 12, 0, 11)
			end

			-- Create section frame with all visual elements
			local sectionFrame = create("Frame", {
				Name = "Section",
				Parent = tab.content,
				BackgroundColor3 = Color3.fromRGB(21, 21, 21),
				BorderMode = Enum.BorderMode.Inset,
				Size = UDim2.new(0.5, -19, 1, -22),
				Position = position,
				BorderColor3 = Color3.fromRGB(29, 29, 29),
				BackgroundTransparency = 0
			})

			-- Section outline stroke
			create("UIStroke", {
				Name = "SectionOutline",
				Parent = sectionFrame,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				LineJoinMode = Enum.LineJoinMode.Miter,
				Color = Color3.fromRGB(0, 0, 0),
			})

			-- Section accent line
			local accentLine = create("Frame", {
				Name = "SectionAccentLine",
				Parent = sectionFrame,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(91, 134, 198),
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.new(0, 0, 0, 23)
			})

			-- Section title
			local titleLabel = create("TextLabel", {
				Name = "SectionTitle",
				Parent = accentLine,
				BorderSizePixel = 0,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 23),
				Position = UDim2.new(0, 0, 0, -23),
				Text = name,
				FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
				TextColor3 = Color3.fromRGB(255, 255, 255)
			})

			create("UIPadding", {
				Name = "SectionTitlePadding",
				Parent = titleLabel,
				PaddingLeft = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 2)
			})

			-- Section content area with proper layout
			local sectionContent = create("Frame", {
				Name = "SectionContent",
				Parent = sectionFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -24),
				Position = UDim2.new(0, 0, 0, 24),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			})

			create("UIPadding", {
				Name = "SectionContentPadding",
				Parent = sectionContent,
				PaddingTop = UDim.new(0, 5)
			})

			create("UIListLayout", {
				Name = "SectionContentLayout",
				Parent = sectionContent,
				Padding = UDim.new(0, 7),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			-- Section methods
			function section:Toggle(options)
				options = options or {}
				local toggle = {
					title = options.title or "Toggle",
					default = options.default or false,
					callback = options.callback or function() end,
					state = options.default or false
				}

				-- Create toggle button
				local toggleButton = create("TextButton", {
					Name = "ToggleButton",
					Parent = sectionContent,
					BorderSizePixel = 0,
					TextSize = 14,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 10),
					Text = "",
					ZIndex = 15
				})

				-- Toggle indicator
				local toggleIndicator = create("Frame", {
					Name = "Toggle",
					Parent = toggleButton,
					BackgroundColor3 = Color3.fromRGB(18, 18, 18),
					Size = UDim2.new(0, 10, 0, 10),
					Position = UDim2.new(0, 14, 0, 3),
					BorderColor3 = Color3.fromRGB(29, 29, 29)
				})

				local toggleAccent = create("Frame", {
					Name = "ToggleAccent",
					Parent = toggleIndicator,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(91, 134, 198),
					Size = UDim2.new(1, 0, 1, 0),
					Visible = toggle.state
				})

				-- Gradient
				create("UIGradient", {
					Name = "ToggleAccentGradient",
					Parent = toggleAccent,
					Rotation = -90,
					Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 192, 205)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
					}
				})

				-- Toggle title with proper inactive color
				local titleLabel = create("TextLabel", {
					Name = "Title",
					Parent = toggleButton,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 31, 0, 2),
					Text = toggle.title,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = toggle.state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
				})

				-- Toggle functionality
				toggleButton.MouseButton1Click:Connect(function()
					toggle.state = not toggle.state
					toggleAccent.Visible = toggle.state
					titleLabel.TextColor3 = toggle.state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
					toggle.callback(toggle.state)
				end)

				-- Method to create a color picker for this toggle
				function toggle:ColorPicker(options)
					options = options or {}
					local colorpicker = {
						default = options.default or Color3.fromRGB(255, 255, 255),
						callback = options.callback or function() end,
						open = false,
						color = options.default or Color3.fromRGB(255, 255, 255)
					}

					-- Create color preview
					local colorPreview = create("TextButton", {
						Name = "ColorPreview",
						Parent = toggleButton,
						AutoButtonColor = false,
						BackgroundColor3 = colorpicker.color,
						Size = UDim2.new(0, 10, 0, 10),
						Position = UDim2.new(1, -24, 0, 3),
						BorderColor3 = Color3.fromRGB(30, 30, 30),
						Text = "",
						ZIndex = 15
					})

					-- Gradient
					create("UIGradient", {
						Name = "ColorIconGradient",
						Parent = colorPreview,
						Rotation = -90,
						Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 192, 205)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
						}
					})

					-- Create colorpicker window
					local colorpickerWindow = create("Frame", {
						Name = "ColorpickerWindow",
						Parent = toggleButton,
						Visible = false,
						BackgroundColor3 = Color3.fromRGB(19, 19, 19),
						Size = UDim2.new(0, 150, 0, 133),
						Position = UDim2.new(1, -150, 0, 16),
						BorderColor3 = Color3.fromRGB(30, 30, 30),
						ZIndex = 5
					})

					-- Create saturation/brightness picker
					local satPicker = create("ImageButton", {
						Name = "Sat",
						Parent = colorpickerWindow,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromHSV(0, 1, 1),
						Size = UDim2.new(0, 123, 0, 123),
						Position = UDim2.new(0, 5, 0, 5),
						BorderColor3 = Color3.fromRGB(28, 28, 28),
						Image = "rbxassetid://13882904626",
						ZIndex = 5
					})

					-- Create hue picker
					local huePicker = create("ImageButton", {
						Name = "Hue",
						Parent = colorpickerWindow,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Size = UDim2.new(0, 10, 0, 123),
						Position = UDim2.new(1, -15, 0, 5),
						BorderColor3 = Color3.fromRGB(28, 28, 28),
						Image = "rbxassetid://13882976736",
						ZIndex = 5
					})

					-- Convert default color to HSV
					local h, s, v = colorpicker.color:ToHSV()

					-- Update color function
					local function updateColor(newH, newS, newV)
						h = newH or h
						s = newS or s
						v = newV or v

						local newColor = Color3.fromHSV(h, s, v)
						colorpicker.color = newColor
						colorPreview.BackgroundColor3 = newColor
						satPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						colorpicker.callback(newColor)
					end

					-- Initialize with default color
					updateColor(h, s, v)

					-- Saturation/Brightness picker logic
					local satDragging = false
					satPicker.MouseButton1Down:Connect(function(x, y)
						satDragging = true
						local mouse = game:GetService("Players").LocalPlayer:GetMouse()
						local pos = Vector2.new(mouse.X, mouse.Y)
						local absolutePos = satPicker.AbsolutePosition
						local absoluteSize = satPicker.AbsoluteSize

						local relativeX = (pos.X - absolutePos.X) / absoluteSize.X
						local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y

						relativeX = math.clamp(relativeX, 0, 1)
						relativeY = math.clamp(relativeY, 0, 1)

						updateColor(nil, relativeX, 1 - relativeY)
					end)

					satPicker.MouseButton1Up:Connect(function()
						satDragging = false
					end)

					satPicker.MouseLeave:Connect(function()
						satDragging = false
					end)

					satPicker.MouseMoved:Connect(function(x, y)
						if satDragging then
							local mouse = game:GetService("Players").LocalPlayer:GetMouse()
							local pos = Vector2.new(mouse.X, mouse.Y)
							local absolutePos = satPicker.AbsolutePosition
							local absoluteSize = satPicker.AbsoluteSize

							local relativeX = (pos.X - absolutePos.X) / absoluteSize.X
							local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y

							relativeX = math.clamp(relativeX, 0, 1)
							relativeY = math.clamp(relativeY, 0, 1)

							updateColor(nil, relativeX, 1 - relativeY)
						end
					end)

					-- Hue picker logic
					local hueDragging = false
					huePicker.MouseButton1Down:Connect(function(x, y)
						hueDragging = true
						local mouse = game:GetService("Players").LocalPlayer:GetMouse()
						local pos = Vector2.new(mouse.X, mouse.Y)
						local absolutePos = huePicker.AbsolutePosition
						local absoluteSize = huePicker.AbsoluteSize

						local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y
						relativeY = math.clamp(relativeY, 0, 1)

						updateColor(1 - relativeY, nil, nil)
					end)

					huePicker.MouseButton1Up:Connect(function()
						hueDragging = false
					end)

					huePicker.MouseLeave:Connect(function()
						hueDragging = false
					end)

					huePicker.MouseMoved:Connect(function(x, y)
						if hueDragging then
							local mouse = game:GetService("Players").LocalPlayer:GetMouse()
							local pos = Vector2.new(mouse.X, mouse.Y)
							local absolutePos = huePicker.AbsolutePosition
							local absoluteSize = huePicker.AbsoluteSize

							local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y
							relativeY = math.clamp(relativeY, 0, 1)

							updateColor(1 - relativeY, nil, nil)
						end
					end)

					-- Toggle colorpicker window
					colorPreview.MouseButton1Click:Connect(function()
						colorpicker.open = not colorpicker.open
						colorpickerWindow.Visible = colorpicker.open
					end)

					-- Close colorpicker when clicking elsewhere
					local function isMouseOverGui(gui)
						local mouse = game:GetService("Players").LocalPlayer:GetMouse()
						local guiPos = gui.AbsolutePosition
						local guiSize = gui.AbsoluteSize
						local mousePos = Vector2.new(mouse.X, mouse.Y)

						return mousePos.X >= guiPos.X and mousePos.X <= guiPos.X + guiSize.X and
							mousePos.Y >= guiPos.Y and mousePos.Y <= guiPos.Y + guiSize.Y
					end

					game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
						if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 and colorpicker.open then
							if not isMouseOverGui(colorpickerWindow) and not isMouseOverGui(colorPreview) then
								colorpicker.open = false
								colorpickerWindow.Visible = false
							end
						end
					end)

					-- Method to set/get color
					function colorpicker:Set(color)
						local newH, newS, newV = color:ToHSV()
						updateColor(newH, newS, newV)
					end

					function colorpicker:Get()
						return colorpicker.color
					end

					-- Store the colorpicker in the toggle
					toggle.colorpicker = colorpicker

					return colorpicker
				end

				function toggle:Keybind(options)
					options = options or {}
					local keybind = {
						title = options.title or "Keybind",
						default = options.default or Enum.KeyCode.Unknown,
						bindType = options.bindType or "Toggle", -- Can be "Toggle", "Hold", or "Always"
						callback = options.callback or function() end
					}

					-- Create keybind frame
					local keybindFrame = create("Frame", {
						Name = "Keybind",
						Parent = toggleButton,
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 60, 0, 18),
						Position = UDim2.new(1, -52, 0, -3)
					})

					-- Create keybind button
					local keybindButton = create("TextButton", {
						Name = "KeybindButton",
						Parent = keybindFrame,
						TextSize = 12,
						AutoButtonColor = false,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						BackgroundColor3 = Color3.fromRGB(19, 19, 19),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
						Size = UDim2.new(1, 0, 1, 0),
						BorderColor3 = Color3.fromRGB(30, 30, 30),
						Text = keybind.default ~= Enum.KeyCode.Unknown and 
							"["..keybind.default.Name.."]" or "[None]"
					})

					-- Create keybind handler
					local keybindHandler = createKeybindHandler(keybindButton, function(keyCode, bindType)
						keybind.bindType = bindType
						if bindType == "Toggle" then
							-- Only toggle when the key is pressed
							toggle:Set(not toggle.state)
						elseif bindType == "Hold" then
							-- Set state based on key press/release
							toggle:Set(true)
						end

						-- Call the user's callback if provided
						if keybind.callback then
							keybind.callback(keyCode, bindType)
						end
					end)

					-- For Hold type, we need to handle key release
					if keybind.bindType == "Hold" then
						UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybindHandler.Get() then
								toggle:Set(false)
							end
						end)
					end

					-- Method to set/get keybind
					function keybind:Set(keyCode)
						keybindHandler.Set(keyCode)
					end

					function keybind:Get()
						return keybindHandler.Get()
					end

					-- Store the keybind in the toggle
					toggle.keybind = keybind

					return keybind
				end
				
				-- Method to set/get state
				function toggle:Set(state)
					toggle.state = state
					toggleAccent.Visible = state
					titleLabel.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
					toggle.callback(state)
				end

				function toggle:Get()
					return toggle.state
				end

				return toggle
			end

			function section:Button(options)
				options = options or {}
				local button = {
					title = options.title or "Button",
					callback = options.callback or function() end
				}

				-- Create button frame
				local buttonFrame = create("Frame", {
					Name = "Button",
					Parent = sectionContent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22)
				})

				-- Create actual button
				local buttonElement = create("TextButton", {
					Name = "Button",
					Parent = buttonFrame,
					TextSize = 12,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					Size = UDim2.new(1, -28, 0, 18),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					Position = UDim2.new(0, 14, 0, 2),
					Text = button.title
				})

				-- Button functionality
				buttonElement.MouseButton1Click:Connect(function()
					button.callback()
				end)

				-- Button hover effects
				buttonElement.MouseEnter:Connect(function()
					buttonElement.TextColor3 = Color3.fromRGB(255, 255, 255)
				end)

				buttonElement.MouseLeave:Connect(function()
					buttonElement.TextColor3 = Color3.fromRGB(200, 200, 200)
				end)

				return button
			end

			function section:TextBox(options)
				options = options or {}
				local textbox = {
					title = options.title or "Textbox",
					placeholder = options.placeholder or "Enter text...",
					callback = options.callback or function() end,
					default = options.default or ""
				}

				-- Create textbox frame
				local textboxFrame = create("Frame", {
					Name = "TextBox",
					Parent = sectionContent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22)
				})

				-- Create title label
				create("TextLabel", {
					Name = "Title",
					Parent = textboxFrame,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.new(0, 13, 0, 2),
					Text = textbox.title,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(255, 255, 255)
				})

				-- Create actual textbox
				local textboxElement = create("TextBox", {
					Name = "TextBox",
					Parent = textboxFrame,
					TextSize = 12,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					PlaceholderColor3 = Color3.fromRGB(200, 200, 200),
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					Size = UDim2.new(1, -28, 0, 18),
					Position = UDim2.new(0, 14, 0, 2),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					PlaceholderText = textbox.placeholder,
					Text = textbox.default
				})

				-- Textbox functionality
				textboxElement.FocusLost:Connect(function(enterPressed)
					if enterPressed then
						textbox.callback(textboxElement.Text)
					end
				end)

				-- Method to set/get text
				function textbox:Set(text)
					textboxElement.Text = text
				end

				function textbox:Get()
					return textboxElement.Text
				end

				return textbox
			end

			function section:Slider(options)
				options = options or {}
				local slider = {
					title = options.title or "Slider",
					min = options.min or 0,
					max = options.max or 100,
					default = options.default or options.min or 0,
					callback = options.callback or function() end,
					precise = options.precise or false,
					value = options.default or options.min or 0,
					dragging = false
				}

				-- Create slider frame
				local sliderFrame = create("Frame", {
					Name = "Slider",
					Parent = sectionContent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 27)
				})

				-- Create title label
				local titleLabel = create("TextLabel", {
					Name = "Title",
					Parent = sliderFrame,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.new(0, 13, 0, 2),
					Text = slider.title,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(255, 255, 255)
				})

				-- Create value label
				local valueLabel = create("TextLabel", {
					Name = "Value",
					Parent = sliderFrame,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -30, 0, 10),
					Position = UDim2.new(0, 17, 0, 2),
					Text = slider.precise and string.format("%.5f", slider.value) or tostring(slider.value),
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(255, 255, 255)
				})

				-- Create slider track
				local sliderTrack = create("TextButton", {
					Name = "SliderTrack",
					Parent = sliderFrame,
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(1, -28, 0, 8),
					Position = UDim2.new(0, 14, 0, 18),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					Text = "",
					ZIndex = 2
				})

				-- Create slider fill
				local sliderFill = create("TextButton", {
					Name = "SliderFill",
					Parent = sliderTrack,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(91, 134, 198),
					Size = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), 0, 1, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = "",
					ZIndex = 3
				})

				-- Gradient for slider fill
				create("UIGradient", {
					Name = "SliderAccentGradient",
					Parent = sliderFill,
					Rotation = -90,
					Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 192, 205)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
					}
				})

  
				-- Update slider value function
				local function updateSlider(input)
					local percent = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
					percent = math.clamp(percent, 0, 1)

					slider.value = slider.min + (slider.max - slider.min) * percent
					if not slider.precise then
						slider.value = math.floor(slider.value)
					end

					valueLabel.Text = slider.precise and string.format("%.5f", slider.value) or tostring(slider.value)
					sliderFill.Size = UDim2.new(percent, 0, 1, 0)
					slider.callback(slider.value)
				end

				-- Mouse down events for all slider parts
				local function onInputBegan(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						slider.dragging = true
						updateSlider(input)
					end
				end

				sliderTrack.InputBegan:Connect(onInputBegan)
				sliderFill.InputBegan:Connect(onInputBegan)

				-- Mouse movement events
				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if slider.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateSlider(input)
					end
				end)

				-- Mouse up events
				game:GetService("UserInputService").InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						slider.dragging = false
					end
				end)

				-- Method to set/get value
				function slider:Set(value)
					slider.value = math.clamp(value, slider.min, slider.max)
					valueLabel.Text = slider.precise and string.format("%.5f", slider.value) or tostring(slider.value)
					local percent = (slider.value - slider.min) / (slider.max - slider.min)
					sliderFill.Size = UDim2.new(percent, 0, 1, 0)
					slider.callback(slider.value)
				end

				function slider:Get()
					return slider.value
				end

				-- Initialize the slider
				slider:Set(slider.default)

				return slider
			end

			function section:Dropdown(options)
				options = options or {}
				local dropdown = {
					title = options.title or "Dropdown",
					options = options.options or {"Option 1", "Option 2"},
					default = options.default or options.options and options.options[1] or "Option 1",
					callback = options.callback or function() end,
					open = false
				}

				-- Create dropdown frame
				local dropdownFrame = create("Frame", {
					Name = "Dropdown",
					Parent = sectionContent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 35),
					ZIndex = 3
				})

				-- Create title label
				create("TextLabel", {
					Name = "Title",
					Parent = dropdownFrame,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.new(0, 13, 0, 4),
					Text = dropdown.title,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					ZIndex = 3
				})

				-- Create dropdown button
				local dropdownButton = create("TextButton", {
					Name = "Dropdown",
					Parent = dropdownFrame,
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(1, -28, 0, 18),
					Position = UDim2.new(0, 14, 0, 20),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					Text = ""
				})

				-- Create value label
				local valueLabel = create("TextLabel", {
					Name = "Value",
					Parent = dropdownButton,
					BorderSizePixel = 0,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -10, 1, 0),
					Position = UDim2.new(0, 2, 0, 0),
					Text = dropdown.default,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(200, 200, 200)
				})

				create("UIPadding", {
					Name = "ValuePadding",
					Parent = valueLabel,
					PaddingLeft = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 1)
				})

				-- Create icon
				local iconLabel = create("TextLabel", {
					Name = "Icon",
					Parent = dropdownButton,
					BorderSizePixel = 0,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, -4, 0, 0),
					Text = "-",
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(200, 200, 200)
				})

				create("UIPadding", {
					Name = "IconPadding",
					Parent = iconLabel,
					PaddingLeft = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 1)
				})

				-- Create dropdown content
				local dropdownContent = create("Frame", {
					Name = "DropdownContent",
					Parent = dropdownButton,
					Visible = false,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 22),
					BorderColor3 = Color3.fromRGB(30, 30, 30)
				})

				create("UIListLayout", {
					Name = "DropdownContentLayout",
					Parent = dropdownContent,
					SortOrder = Enum.SortOrder.LayoutOrder
				})

				-- Create options
				for i, option in ipairs(dropdown.options) do
					local optionButton = create("TextButton", {
						Name = "Option",
						Parent = dropdownContent,
						BorderSizePixel = 0,
						TextSize = 14,
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 15),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = ""
					})

					local optionName = create("TextLabel", {
						Name = "OptionName",
						Parent = optionButton,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 2, 0, 0),
						Text = option,
						FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
						TextColor3 = option == dropdown.default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
					})

					optionButton.MouseButton1Click:Connect(function()
						valueLabel.Text = option
						dropdown.callback(option)
						dropdownContent.Visible = false
						dropdown.open = false
						iconLabel.Text = "-"

						-- Update all option colors
						for _, child in ipairs(dropdownContent:GetChildren()) do
							if child:IsA("TextButton") and child.Name == "Option" then
								child.OptionName.TextColor3 = child.OptionName.Text == option and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
							end
						end
					end)
				end

				-- Dropdown functionality
				dropdownButton.MouseButton1Click:Connect(function()
					dropdown.open = not dropdown.open
					dropdownContent.Visible = dropdown.open
					iconLabel.Text = dropdown.open and "+" or "-"

					-- Auto-size the dropdown content
					local optionCount = #dropdown.options
					dropdownContent.Size = UDim2.new(1, 0, 0, math.min(optionCount * 15, 150))
				end)

				-- Close dropdown when clicking elsewhere
				game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
					if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
						if dropdown.open and not dropdownButton:IsDescendantOf(input.Target) and not dropdownContent:IsDescendantOf(input.Target) then
							dropdown.open = false
							dropdownContent.Visible = false
							iconLabel.Text = "-"
						end
					end
				end)

				-- Method to set/get value
				function dropdown:Set(value)
					if table.find(dropdown.options, value) then
						valueLabel.Text = value
						dropdown.callback(value)

						-- Update all option colors
						for _, child in ipairs(dropdownContent:GetChildren()) do
							if child:IsA("TextButton") and child.Name == "Option" then
								child.OptionName.TextColor3 = child.OptionName.Text == value and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
							end
						end
					end
				end

				function dropdown:Get()
					return valueLabel.Text
				end

				return dropdown
			end

			function section:MultiDropdown(options)
				options = options or {}
				local multidropdown = {
					title = options.title or "MultiDropdown",
					options = options.options or {"Option 1", "Option 2"},
					default = options.default or {},
					callback = options.callback or function() end,
					open = false,
					selected = {}
				}

				-- Initialize selected options
				for _, option in ipairs(multidropdown.default) do
					if table.find(multidropdown.options, option) then
						table.insert(multidropdown.selected, option)
					end
				end

				-- Create multidropdown frame
				local multidropdownFrame = create("Frame", {
					Name = "MultiDropdown",
					Parent = sectionContent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 35)
				})

				-- Create title label
				create("TextLabel", {
					Name = "Title",
					Parent = multidropdownFrame,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.new(0, 13, 0, 4),
					Text = multidropdown.title,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(255, 255, 255)
				})

				-- Create multidropdown button
				local multidropdownButton = create("TextButton", {
					Name = "MultiDropdown",
					Parent = multidropdownFrame,
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(1, -28, 0, 18),
					Position = UDim2.new(0, 14, 0, 20),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					Text = ""
				})

				-- Create value label
				local valueLabel = create("TextLabel", {
					Name = "Value",
					Parent = multidropdownButton,
					BorderSizePixel = 0,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -10, 1, 0),
					Position = UDim2.new(0, 2, 0, 0),
					Text = #multidropdown.selected > 0 and table.concat(multidropdown.selected, ", ") or "None",
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(200, 200, 200)
				})

				create("UIPadding", {
					Name = "ValuePadding",
					Parent = valueLabel,
					PaddingLeft = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 1)
				})

				-- Create icon
				local iconLabel = create("TextLabel", {
					Name = "Icon",
					Parent = multidropdownButton,
					BorderSizePixel = 0,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, -4, 0, 0),
					Text = "-",
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(200, 200, 200)
				})

				create("UIPadding", {
					Name = "IconPadding",
					Parent = iconLabel,
					PaddingLeft = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 1)
				})

				-- Create multidropdown content
				local multidropdownContent = create("Frame", {
					Name = "MultiDropdownContent",
					Parent = multidropdownButton,
					Visible = false,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 22),
					BorderColor3 = Color3.fromRGB(30, 30, 30)
				})

				create("UIListLayout", {
					Name = "MultiDropdownContentLayout",
					Parent = multidropdownContent,
					SortOrder = Enum.SortOrder.LayoutOrder
				})

				-- Create options
				for i, option in ipairs(multidropdown.options) do
					local optionButton = create("TextButton", {
						Name = "Option",
						Parent = multidropdownContent,
						BorderSizePixel = 0,
						TextSize = 14,
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 15),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = ""
					})

					local isSelected = table.find(multidropdown.selected, option) ~= nil

					local optionName = create("TextLabel", {
						Name = "OptionName",
						Parent = optionButton,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 2, 0, 0),
						Text = option,
						FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
						TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
					})

					optionButton.MouseButton1Click:Connect(function()
						local index = table.find(multidropdown.selected, option)
						if index then
							table.remove(multidropdown.selected, index)
							optionName.TextColor3 = Color3.fromRGB(200, 200, 200)
						else
							table.insert(multidropdown.selected, option)
							optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
						end

						valueLabel.Text = #multidropdown.selected > 0 and table.concat(multidropdown.selected, ", ") or "None"
						multidropdown.callback(multidropdown.selected)
					end)
				end

				-- MultiDropdown functionality
				multidropdownButton.MouseButton1Click:Connect(function()
					multidropdown.open = not multidropdown.open
					multidropdownContent.Visible = multidropdown.open
					iconLabel.Text = multidropdown.open and "+" or "-"

					-- Auto-size the multidropdown content
					local optionCount = #multidropdown.options
					multidropdownContent.Size = UDim2.new(1, 0, 0, math.min(optionCount * 15, 150))
				end)

				-- Close multidropdown when clicking elsewhere
				game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
					if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
						if multidropdown.open and not multidropdownButton:IsDescendantOf(input.Target) and not multidropdownContent:IsDescendantOf(input.Target) then
							multidropdown.open = false
							multidropdownContent.Visible = false
							iconLabel.Text = "-"
						end
					end
				end)

				-- Method to set/get values
				function multidropdown:Set(values)
					multidropdown.selected = {}
					for _, value in ipairs(values) do
						if table.find(multidropdown.options, value) then
							table.insert(multidropdown.selected, value)
						end
					end

					valueLabel.Text = #multidropdown.selected > 0 and table.concat(multidropdown.selected, ", ") or "None"
					multidropdown.callback(multidropdown.selected)

					-- Update all option colors
					for _, child in ipairs(multidropdownContent:GetChildren()) do
						if child:IsA("TextButton") and child.Name == "Option" then
							local isSelected = table.find(multidropdown.selected, child.OptionName.Text) ~= nil
							child.OptionName.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
						end
					end
				end

				function multidropdown:Get()
					return multidropdown.selected
				end

				return multidropdown
			end

			function section:Keybind(options)
				options = options or {}
				local keybind = {
					title = options.title or "Keybind",
					default = options.default or Enum.KeyCode.Unknown,
					callback = options.callback or function() end
				}

				-- Create container frame
				local keybindFrame = create("Frame", {
					Name = "Keybind",
					Parent = sectionContent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22)
				})

				-- Title label
				create("TextLabel", {
					Name = "Title",
					Parent = keybindFrame,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0, 14, 0, 0),
					Text = keybind.title,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(255, 255, 255)
				})

				-- Keybind button
				local keybindButton = create("TextButton", {
					Name = "KeybindButton",
					Parent = keybindFrame,
					TextSize = 12,
					AutoButtonColor = false,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					Size = UDim2.new(0.4, 0, 0, 18),
					Position = UDim2.new(0, 180, 0, 3),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					Text = keybind.default ~= Enum.KeyCode.Unknown and 
						"["..keybind.default.Name.."]" or "[None]"
				})

				-- Create keybind handler
				local keybindHandler = createKeybindHandler(keybindButton, keybind.callback)

				-- Methods
				function keybind:Set(keyCode)
					keybindHandler.Set(keyCode)
				end

				function keybind:Get()
					return keybindHandler.Get()
				end

				return keybind
			end

			function section:ColorPicker(options)
				options = options or {}
				local colorpicker = {
					title = options.title or "ColorPicker",
					default = options.default or Color3.fromRGB(255, 255, 255),
					callback = options.callback or function() end,
					open = false,
					color = options.default or Color3.fromRGB(255, 255, 255)
				}

				-- Create colorpicker frame
				local colorpickerFrame = create("Frame", {
					Name = "ColorPicker",
					Parent = sectionContent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 15)
				})

				-- Create title label
				local titleLabel = create("TextLabel", {
					Name = "Title",
					Parent = colorpickerFrame,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 14, 0, 0),
					Text = colorpicker.title,
					FontFace = Font.new("rbxasset://fonts/families/Zekton.json"),
					TextColor3 = Color3.fromRGB(255, 255, 255)
				})

				local colorPreview = create("TextButton", {
					Name = "ColorPreview",
					Parent = colorpickerFrame,
					AutoButtonColor = false,
					BackgroundColor3 = colorpicker.color,
					BackgroundTransparency = 0, -- Ensure this isn't 1
					Size = UDim2.new(0, 10, 0, 10),
					Position = UDim2.new(1, -24, 0, 4),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					Text = ""
				})

				-- Gradient
				create("UIGradient", {
					Name = "ColorIconGradient",
					Parent = colorPreview, -- Make sure this matches the variable name
					Rotation = -90,
					Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 192, 205)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
					}
				})
				
				-- Create colorpicker window
				local colorpickerWindow = create("Frame", {
					Name = "ColorpickerWindow",
					Parent = colorpickerFrame,
					Visible = false,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(0, 150, 0, 133),
					Position = UDim2.new(1, -150, 0, 16),
					BorderColor3 = Color3.fromRGB(30, 30, 30),
					ZIndex = 2
				})

				-- Create saturation/brightness picker
				local satPicker = create("ImageButton", {
					Name = "Sat",
					Parent = colorpickerWindow,
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromHSV(0, 1, 1),
					Size = UDim2.new(0, 123, 0, 123),
					Position = UDim2.new(0, 5, 0, 5),
					BorderColor3 = Color3.fromRGB(28, 28, 28),
					Image = "rbxassetid://13882904626",
					ZIndex = 2
				})

				-- Create hue picker
				local huePicker = create("ImageButton", {
					Name = "Hue",
					Parent = colorpickerWindow,
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0, 10, 0, 123),
					Position = UDim2.new(1, -15, 0, 5),
					BorderColor3 = Color3.fromRGB(28, 28, 28),
					Image = "rbxassetid://13882976736",
					ZIndex = 2
				})

				-- Convert default color to HSV
				local h, s, v = colorpicker.color:ToHSV()

				-- Update color function
				local function updateColor(newH, newS, newV)
					h = newH or h
					s = newS or s
					v = newV or v

					local newColor = Color3.fromHSV(h, s, v)
					colorpicker.color = newColor
					colorPreview.BackgroundColor3 = newColor
					satPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					colorpicker.callback(newColor)
				end

				-- Initialize with default color
				updateColor(h, s, v)

				-- Saturation/Brightness picker logic
				local satDragging = false
				satPicker.MouseButton1Down:Connect(function(x, y)
					satDragging = true
					local mouse = game:GetService("Players").LocalPlayer:GetMouse()
					local pos = Vector2.new(mouse.X, mouse.Y)
					local absolutePos = satPicker.AbsolutePosition
					local absoluteSize = satPicker.AbsoluteSize

					local relativeX = (pos.X - absolutePos.X) / absoluteSize.X
					local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y

					relativeX = math.clamp(relativeX, 0, 1)
					relativeY = math.clamp(relativeY, 0, 1)

					updateColor(nil, relativeX, 1 - relativeY)
				end)

				satPicker.MouseButton1Up:Connect(function()
					satDragging = false
				end)

				satPicker.MouseLeave:Connect(function()
					satDragging = false
				end)

				satPicker.MouseMoved:Connect(function(x, y)
					if satDragging then
						local mouse = game:GetService("Players").LocalPlayer:GetMouse()
						local pos = Vector2.new(mouse.X, mouse.Y)
						local absolutePos = satPicker.AbsolutePosition
						local absoluteSize = satPicker.AbsoluteSize

						local relativeX = (pos.X - absolutePos.X) / absoluteSize.X
						local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y

						relativeX = math.clamp(relativeX, 0, 1)
						relativeY = math.clamp(relativeY, 0, 1)

						updateColor(nil, relativeX, 1 - relativeY)
					end
				end)

				-- Hue picker logic
				local hueDragging = false
				huePicker.MouseButton1Down:Connect(function(x, y)
					hueDragging = true
					local mouse = game:GetService("Players").LocalPlayer:GetMouse()
					local pos = Vector2.new(mouse.X, mouse.Y)
					local absolutePos = huePicker.AbsolutePosition
					local absoluteSize = huePicker.AbsoluteSize

					local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y
					relativeY = math.clamp(relativeY, 0, 1)

					updateColor(1 - relativeY, nil, nil)
				end)

				huePicker.MouseButton1Up:Connect(function()
					hueDragging = false
				end)

				huePicker.MouseLeave:Connect(function()
					hueDragging = false
				end)

				huePicker.MouseMoved:Connect(function(x, y)
					if hueDragging then
						local mouse = game:GetService("Players").LocalPlayer:GetMouse()
						local pos = Vector2.new(mouse.X, mouse.Y)
						local absolutePos = huePicker.AbsolutePosition
						local absoluteSize = huePicker.AbsoluteSize

						local relativeY = (pos.Y - absolutePos.Y) / absoluteSize.Y
						relativeY = math.clamp(relativeY, 0, 1)

						updateColor(1 - relativeY, nil, nil)
					end
				end)

				-- Toggle colorpicker window
				colorPreview.MouseButton1Click:Connect(function()
					colorpicker.open = not colorpicker.open
					colorpickerWindow.Visible = colorpicker.open
				end)

				-- Close colorpicker when clicking elsewhere
				local function isMouseOverGui(gui)
					local mouse = game:GetService("Players").LocalPlayer:GetMouse()
					local guiPos = gui.AbsolutePosition
					local guiSize = gui.AbsoluteSize
					local mousePos = Vector2.new(mouse.X, mouse.Y)

					return mousePos.X >= guiPos.X and mousePos.X <= guiPos.X + guiSize.X and
						mousePos.Y >= guiPos.Y and mousePos.Y <= guiPos.Y + guiSize.Y
				end

				game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
					if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 and colorpicker.open then
						if not isMouseOverGui(colorpickerWindow) and not isMouseOverGui(colorPreview) then
							colorpicker.open = false
							colorpickerWindow.Visible = false
						end
					end
				end)

				-- Method to set/get color
				function colorpicker:Set(color)
					local newH, newS, newV = color:ToHSV()
					updateColor(newH, newS, newV)
				end

				function colorpicker:Get()
					return colorpicker.color
				end

				return colorpicker
			end


			tab.sections[#tab.sections + 1] = section
			return section
		end

		-- Tab switching functionality
		tabButton.MouseButton1Click:Connect(function()
			-- Hide all tab contents and set to inactive color
			for _, otherTab in pairs(window.tabs) do
				otherTab.active = false
				otherTab.content.Visible = false
				otherTab.tabButton.TextColor3 = Color3.fromRGB(200, 200, 200) -- Inactive color
			end

			-- Show this tab's content and set to active color
			tab.active = true
			tab.content.Visible = true
			tabButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Active color
		end)

		tab.tabButton = tabButton
		window.tabs[#window.tabs + 1] = tab
		return tab
	end

	return window
end

-- Create a window
local window = ui:Window({
	title = "My Cool UI", 
	size = Vector2.new(555, 475)
})

-- Add tabs
local tab1 = window:Tab("Combat")
local tab2 = window:Tab("Visuals")
local tab3 = window:Tab("Misc")

-- Add sections to tabs
local leftSection = tab1:Section("Aimbot", "left")
local rightSection = tab1:Section("Triggerbot", "right")

-- Add elements to sections
leftSection:Toggle({
	title = "Enable Aimbot", 
	default = false, 
	callback = function(state) 
		print("Aimbot:", state) 
	end
}):ColorPicker({
	title = "ESP Color",
	default = Color3.fromRGB(255, 0, 0),
	callback = function(color)
		print("Color changed to:", color)
	end
})


leftSection:Slider({
	title = "Aimbot FOV",
	min = 1,
	max = 360,
	default = 30,
	callback = function(value)
		print("FOV set to:", value)
	end
})

rightSection:Dropdown({
	title = "Aimbot Bone",
	options = {"Head", "Torso", "Random"},
	default = "Head",
	callback = function(option)
		print("Selected bone:", option)
	end
})

rightSection:MultiDropdown({
	title = "Target Selection",
	options = {"Enemies", "Teammates", "NPCs"},
	default = {"Enemies"},
	callback = function(options)
		print("Selected targets:", table.concat(options, ", "))
	end
})

leftSection:Button({
	title = "Test Button",
	callback = function()
		print("Button clicked!")
	end
})

leftSection:TextBox({
	title = "Config Name",
	placeholder = "Enter config name...",
	callback = function(text)
		print("Config name:", text)
	end
})

leftSection:ColorPicker({
	title = "ESP Color",
	default = Color3.fromRGB(255, 0, 0),
	callback = function(color)
		print("Color changed to:", color)
	end
})

local myKeybind = rightSection:Keybind({
	title = "Trigger Key",
	default = Enum.KeyCode.A,
	callback = function(key) print("Trigger key pressed:", key.Name) end
})

local myToggle = leftSection:Toggle({
	title = "Enable Aimbot", 
	default = false, 
	callback = function(state) 
		print("Aimbot:", state) 
	end
})

-- Add keybind to the toggle
myToggle:Keybind({
	title = "Aimbot Key",
	default = Enum.KeyCode.Q,
	bindType = "Toggle", -- or "Hold" or "Always"
	callback = function(key, bindType)
		print("Aimbot key pressed:", key.Name, "Bind type:", bindType)
end})




return ui
