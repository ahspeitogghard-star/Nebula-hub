-- language: Lua, file: UI.lua
-- OrionLib — fork Nebula (fundo preto, borda branca, botões à esquerda, título à direita, toggle cinza+check)

while not game:IsLoaded() do
	task.wait()
end
for _, UI in ipairs(game.CoreGui:GetChildren()) do
	if UI.Name == "BetterOrion" or UI.Name == "NebulaUI" then
		UI:Destroy()
	end
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local OrionLib = {
	Elements = {},
	UIElements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Tabs = {},
	Themes = {
		Default = {
			Main = { Color = Color3.fromRGB(0, 0, 0), Transparency = 0 },
			Stroke = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0 },
			Divider = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.7 },
			Text = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0 },
			TextDark = { Color = Color3.fromRGB(180, 180, 180), Transparency = 0 },
			Elements = { Color = Color3.fromRGB(15, 15, 15), Transparency = 0 },
			ToggleOn = { Color = Color3.fromRGB(200, 200, 200), Transparency = 0 },
			Dark = { Color = Color3.fromRGB(0, 0, 0), Transparency = 0 },
		},
		MyCustomTheme = {
			Main = {},
			Stroke = {},
			Divider = {},
			Text = {},
			TextDark = {},
			Elements = {},
		},
	},
	NotificationSettings = { Enabled = true, Printing = true },
	WindowConfig = { AutoSizedTabHolderX = false, AutoSizedTabHolderY = "Window" },
	BackgroundConfig = { EnabledBackground = false, BackgroundName = "", BackgroundTransparency = 0.2 },
	SelectedTheme = "Default",
	ScriptFolder = "NebulaUI",
	GameName = tostring(game.PlaceId),
	Window = nil,
}

local Icons = {}
local LucideIcons = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Utkaky/Main/refs/heads/main/SoundHub/icons.lua")
)().assets

-- Icons do Nebula
local NebulaIcons = {
	Close = "rbxassetid://10747384394", -- lucide-x
	Minimize = "rbxassetid://10734896206", -- lucide-minus
	Plus = "rbxassetid://10734924532", -- lucide-plus
	Check = "rbxassetid://10709790644", -- lucide-check
}

local Orion = Instance.new("ScreenGui")
Orion.Name = "NebulaUI"
if syn then
	pcall(function()
		syn.protect_gui(Orion)
	end)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = game.CoreGui
end

function OrionLib:IsRunning()
	return Orion.Parent == game.CoreGui
end

local function GetOrionIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end
local function GetLucideIcon(IconName)
	if IconName ~= nil then
		return LucideIcons["lucide-" .. IconName]
	else
		return nil
	end
end

local function AddConnection(Signal, Function)
	if not OrionLib:IsRunning() then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while OrionLib:IsRunning() do
		wait()
	end
	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in Properties or {} do
		Object[i] = v
	end
	for i, v in Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	return OrionLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	Number = tonumber(Number)
	local sign = Number >= 0 and 1 or -1
	local result = math.floor(Number / Factor + 0.5 * sign) * Factor
	if result < 0 then
		result = result + Factor
	end
	if Factor < 1 then
		local str = tostring(Factor)
		local dot = str:find("%.")
		local precision = dot and #str - dot or 0
		result = tonumber(string.format("%." .. precision .. "f", result))
	end
	return result
end

local function ReturnProperty(Object, PropType)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return (PropType == "Color" and "BackgroundColor3") or "BackgroundTransparency"
	end
	if Object:IsA("ScrollingFrame") then
		return (PropType == "Color" and "ScrollBarImageColor3") or "ScrollBarImageTransparency"
	end
	if Object:IsA("UIStroke") then
		return (PropType == "Color" and "Color") or "Transparency"
	end
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return (PropType == "Color" and "TextColor3") or "TextTransparency"
	end
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return (PropType == "Color" and "ImageColor3") or "ImageTransparency"
	end
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end
	table.insert(OrionLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object, "Color")] = OrionLib.Themes[OrionLib.SelectedTheme][Type]["Color"]
	Object[ReturnProperty(Object, "Transparency")] = OrionLib.Themes[OrionLib.SelectedTheme][Type]["Transparency"]
	return Object
end

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object, "Color")] = OrionLib.Themes[OrionLib.SelectedTheme][Name]["Color"]
			Object[ReturnProperty(Object, "Transparency")] =
				OrionLib.Themes[OrionLib.SelectedTheme][Name]["Transparency"]
		end
	end
end

local function PackColor(Color)
	return { R = Color.R * 255, G = Color.G * 255, B = Color.B * 255 }
end
local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local WhitelistedMouse = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseButton2,
	Enum.UserInputType.MouseButton3,
}
local BlacklistedKeys = {
	Enum.KeyCode.Unknown,
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Up,
	Enum.KeyCode.Left,
	Enum.KeyCode.Down,
	Enum.KeyCode.Right,
	Enum.KeyCode.Slash,
	Enum.KeyCode.Backspace,
	Enum.KeyCode.Escape,
}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

-- Elements
CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", { CornerRadius = UDim.new(Scale or 0, Offset or 10) })
end)

CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1,
		Name = "Stroke",
	})
end)

CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0),
	})
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	return Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4),
	})
end)

CreateElement("TFrame", function()
	return Create("Frame", { BackgroundTransparency = 1 })
end)

CreateElement("Frame", function(Color)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	})
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(Scale, Offset) }),
	})
end)

CreateElement("Button", function()
	return Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
end)

CreateElement("ScrollFrame", function(Color)
	return Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
end)

CreateElement("Image", function(ImageID)
	local Img = Create("ImageLabel", { Image = ImageID, BackgroundTransparency = 1 })
	if GetOrionIcon(ImageID) ~= nil then
		Img.Image = GetOrionIcon(ImageID)
	end
	return Img
end)

CreateElement("ImageButton", function(ImageID)
	return Create("ImageButton", { Image = ImageID, BackgroundTransparency = 1 })
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	return Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end)

local NotificationHolder = SetProps(
	SetChildren(MakeElement("TFrame"), {
		SetProps(MakeElement("List"), {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.Name,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 5),
		}),
	}),
	{
		Position = UDim2.new(1, -25, 1, -25),
		Size = UDim2.new(0, 300, 1, -25),
		AnchorPoint = Vector2.new(1, 1),
		Parent = Orion,
		Name = "NotificationList",
	}
)

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig = NotificationConfig or {}
		NotificationConfig.Name = NotificationConfig.Name or "Notification Title"
		NotificationConfig.Content = NotificationConfig.Content or "Notification Content"
		NotificationConfig.Image = NotificationConfig.Image or "server"
		NotificationConfig.Time = NotificationConfig.Time or 5
		NotificationConfig.Color = NotificationConfig.Color or Color3.fromRGB(0, 0, 0)
		NotificationConfig.TextColor = NotificationConfig.TextColor or Color3.fromRGB(255, 255, 255)
		NotificationConfig.Sound = NotificationConfig.Sound or ""
		NotificationConfig.SoundVolume = NotificationConfig.SoundVolume or 1

		if NotificationConfig.Sound ~= "" then
			local sound = Instance.new("Sound")
			sound.SoundId = NotificationConfig.Sound
			sound.Parent = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
			sound.Volume = NotificationConfig.SoundVolume
			sound:Play()
		end

		if OrionLib.NotificationSettings.Printing then
			local Contents = {}
			local SendContent = ""
			if string.find(NotificationConfig.Content, "\n") then
				for _, line in NotificationConfig.Content:split("\n") do
					table.insert(Contents, "\n  " .. line)
				end
				SendContent = table.concat(Contents)
				print(
					string.format(
						"\n%s\n%s:%s\n%s\n",
						string.rep("-", 49),
						NotificationConfig.Name,
						SendContent,
						string.rep("-", 49)
					)
				)
			else
				SendContent = NotificationConfig.Content
				print(
					string.format(
						"\n%s\n%s:\n  %s\n%s\n",
						string.rep("-", 49),
						NotificationConfig.Name,
						SendContent,
						string.rep("-", 49)
					)
				)
			end
		end

		if OrionLib.NotificationSettings.Enabled == false then
			return
		end

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(0.9, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder,
		})

		local NotificationFrame = SetChildren(
			SetProps(MakeElement("RoundFrame", NotificationConfig.Color, 0, 8), {
				Parent = NotificationParent,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(1, -55, 0, 0),
				BackgroundTransparency = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
			}),
			{
				MakeElement("Padding", 12, 12, 12, 12),
				SetProps(MakeElement("Image", GetLucideIcon(NotificationConfig.Image)), {
					Size = UDim2.new(0, 20, 0, 20),
					Position = UDim2.new(0, 0, 0.5, -9),
					ImageColor3 = NotificationConfig.TextColor,
					Name = "Icon",
					BackgroundTransparency = 1,
				}),
				SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
					Size = UDim2.new(1, -30, 0, 20),
					Position = UDim2.new(0, 30, 0, -4),
					Font = Enum.Font.GothamBold,
					TextSize = 15,
					Name = "Title",
					BackgroundTransparency = 1,
					TextColor3 = NotificationConfig.TextColor,
				}),
				SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
					Size = NotificationConfig.Content == "" and UDim2.new(0, 0, 0, 0) or UDim2.new(1, -30, 0, 6),
					Position = UDim2.new(0, 30, 0, 20),
					Font = Enum.Font.GothamSemibold,
					TextSize = 13,
					Name = "Content",
					AutomaticSize = Enum.AutomaticSize.Y,
					TextColor3 = NotificationConfig.TextColor,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Visible = NotificationConfig.Content ~= "" and true or false,
				}),
			}
		)
		SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
			Size = UDim2.new(1, -35, 0, 2),
			Position = UDim2.new(0, 30, 0, NotificationFrame.AbsoluteSize.Y - 15),
			Name = "TimerBar",
			Parent = NotificationFrame,
		})

		spawn(function()
			local TimerBar = NotificationFrame.TimerBar
			TweenService:Create(
				TimerBar,
				TweenInfo.new(NotificationConfig.Time - 1, Enum.EasingStyle.Linear),
				{ Size = UDim2.new(0, 0, 0, 2) }
			):Play()
			wait(NotificationConfig.Time - 1)
			TweenService:Create(TimerBar, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 0) })
				:Play()
			TweenService
				:Create(TimerBar, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { Position = UDim2.new(0, 30, 0, 0) })
				:Play()
			wait(0.3)
			TimerBar.Visible = false
		end)
		TweenService
			:Create(
				NotificationFrame,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint),
				{ Position = UDim2.new(0, 30, 0, 0) }
			)
			:Play()

		wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame, TweenInfo.new(3, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 })
			:Play()
		if NotificationFrame.Icon then
			TweenService
				:Create(NotificationFrame.Icon, TweenInfo.new(3, Enum.EasingStyle.Quint), { ImageTransparency = 1 })
				:Play()
		end
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(3, Enum.EasingStyle.Quint), { TextTransparency = 1 })
			:Play()
		TweenService
			:Create(NotificationFrame.Content, TweenInfo.new(3, Enum.EasingStyle.Quint), { TextTransparency = 1 })
			:Play()
		wait(0.05)
		NotificationFrame:TweenPosition(UDim2.new(1, 60, 0, 0), "In", "Quint", 0.8, true)
		wait(0.85)
		NotificationParent:Destroy()
	end)
end

function OrionLib:SetNotifyingState(Config)
	OrionLib.NotificationSettings.Enabled = Config.Enabled
	OrionLib.NotificationSettings.Printing = Config.Printing
end

function OrionLib:MakeWindow(WindowConfig)
	local Val = {
		FirstTab = true,
		Minimized = false,
		UIHidden = false,
		Tab = "",
		TabholderSize = UDim2.new(0, 120, 0, 200),
	}

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Nebula"
	WindowConfig.SubName = WindowConfig.SubName or ""
	WindowConfig.Size = WindowConfig.Size or UDim2.fromOffset(600, 400)
	WindowConfig.MinSize = WindowConfig.MinSize or UDim2.fromOffset(400, 200)
	WindowConfig.MaxSize = WindowConfig.MaxSize or UDim2.fromOffset(4000, 2000)
	WindowConfig.IntroEnabled = WindowConfig.IntroEnabled or false
	WindowConfig.IntroText = WindowConfig.IntroText or "Nebula"
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = GetLucideIcon(WindowConfig.Icon) or ""
	WindowConfig.IntroIcon = GetLucideIcon(WindowConfig.IntroIcon) or ""
	WindowConfig.Transparency = WindowConfig.Transparency or 0
	WindowConfig.ToggleUIKey = WindowConfig.ToggleUIKey or Enum.KeyCode.RightControl
	WindowConfig.SearchBar = WindowConfig.SearchBar or false
	WindowConfig.NewUI = WindowConfig.NewUI or false
	WindowConfig.BackgroundURL = WindowConfig.BackgroundURL or ""
	WindowConfig.BackgroundTransparency = tonumber(WindowConfig.BackgroundTransparency or 0.2)
	WindowConfig.WatermarkConfig = WindowConfig.WatermarkConfig or {}
	WindowConfig.WatermarkConfig.Enabled = WindowConfig.WatermarkConfig.Enabled or false
	WindowConfig.WatermarkConfig.Visible = WindowConfig.WatermarkConfig.Visible or false
	WindowConfig.WatermarkConfig.ShowFPS = WindowConfig.WatermarkConfig.ShowFPS or false
	WindowConfig.WatermarkConfig.ShowPing = WindowConfig.WatermarkConfig.ShowPing or false
	WindowConfig.WatermarkConfig.ShowName = WindowConfig.WatermarkConfig.ShowName or false
	WindowConfig.WatermarkConfig.ShowClockTime = WindowConfig.WatermarkConfig.ShowClockTime or false
	WindowConfig.WatermarkConfig.Icon = GetLucideIcon(WindowConfig.WatermarkConfig.Icon) or ""
	WindowConfig.FreeMouse = WindowConfig.FreeMouse or false

	OrionLib.BackgroundURL = WindowConfig.BackgroundURL
	OrionLib.BackgroundTransparency = WindowConfig.BackgroundTransparency

	local TabHolder = AddThemeObject(
		SetChildren(
			SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255)), {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Name = "TabHolder",
			}),
			{
				MakeElement("List"),
				MakeElement("Padding", 8, 0, 0, 8),
			}
		),
		"Divider"
	)

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	-- ===============================================================
	-- BOTÕES: [×] primeiro, [–] segundo — canto ESQUERDO
	-- ===============================================================
	local CloseBtn = SetChildren(
		SetProps(MakeElement("Button"), {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(0, 8, 0, 10),
			BackgroundTransparency = 1,
		}),
		{
			AddThemeObject(
				SetProps(MakeElement("Image", NebulaIcons.Close), {
					Position = UDim2.new(0, 7, 0, 7),
					Size = UDim2.new(0, 16, 0, 16),
				}),
				"Text"
			),
		}
	)

	local MinimizeBtn = SetChildren(
		SetProps(MakeElement("Button"), {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(0, 40, 0, 10),
			BackgroundTransparency = 1,
		}),
		{
			AddThemeObject(
				SetProps(MakeElement("Image", NebulaIcons.Minimize), {
					Position = UDim2.new(0, 7, 0, 7),
					Size = UDim2.new(0, 16, 0, 16),
					Name = "Ico",
				}),
				"Text"
			),
		}
	)

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
	})

	local ResizePoint = SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 10), {
		Size = UDim2.new(0, 20, 1, 10),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Name = "DragMainWindowResize",
	})

	local ResizePoint2 = SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 10), {
		Size = UDim2.new(1, 10, 0, 20),
		Position = UDim2.new(1, 0, 1, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Name = "DragMainWindowResize2",
	})

	local WindowStuff = AddThemeObject(
		SetChildren(
			SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 16), {
				Size = UDim2.new(0, 120, 0, 0),
				Position = UDim2.new(0, 0, 0, 55),
				BackgroundTransparency = 0,
				Name = "WindowStuff",
				Active = true,
			}),
			{
				SetProps(MakeElement("Frame"), {
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
				}),
				SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 10, 1, 0),
					Position = UDim2.new(1, -10, 0, 0),
					BackgroundTransparency = 1,
				}),
				SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(1, -1, 0, 0),
					BackgroundTransparency = 1,
				}),
				SetChildren(
					SetProps(MakeElement("Image", ""), {
						Size = UDim2.new(1, 0, 1, 0),
						ScaleType = Enum.ScaleType.Crop,
						Name = "BackgroundImage",
						Image = WindowConfig.BackgroundURL,
						ZIndex = -10,
						Visible = false,
					}),
					{ MakeElement("Corner", 0, 16) }
				),
				TabHolder,
			}
		),
		"Main"
	)

	local ResizeTabHolderPoint = SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 10), {
		Size = UDim2.new(0, 15, 1, 0),
		Position = UDim2.new(1, -5, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Parent = WindowStuff,
		Name = "DragTabHolderResize",
		Active = true,
	})

	local ResizeTabHolderPoint2 = SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 10), {
		Size = UDim2.new(1, 0, 0, 15),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Parent = WindowStuff,
		Name = "DragTabHolderResize2",
		Active = true,
	})

	-- ===============================================================
	-- TÍTULO: canto DIREITO
	-- ===============================================================
	local WindowName = AddThemeObject(
		SetProps(MakeElement("Label", WindowConfig.Name, 14), {
			Size = UDim2.new(1, -100, 2, 0),
			Position = UDim2.new(0, 80, 0, -45),
			TextXAlignment = Enum.TextXAlignment.Right,
			Font = Enum.Font.GothamBlack,
			TextSize = 20,
			Name = "WindowName",
			Text = WindowConfig.Name,
		}),
		"Text"
	)

	local WindowSubName = AddThemeObject(
		SetProps(MakeElement("Label", WindowConfig.SubName, 14), {
			Size = UDim2.new(1, -WindowName.TextBounds.X - 200, 1, 0),
			Position = UDim2.new(
				0,
				WindowConfig.ShowIcon and WindowName.TextBounds.X + 60 or WindowName.TextBounds.X + 35,
				0,
				-19
			),
			TextXAlignment = Enum.TextXAlignment.Right,
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			TextWrapped = true,
			Name = "WindowSubName",
			Text = WindowConfig.SubName,
		}),
		"TextDark"
	)

	local WindowTopBarLine = AddThemeObject(
		SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BackgroundTransparency = 0.7,
		}),
		"Divider"
	)

	local MainWindow = AddThemeObject(
		SetChildren(
			SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 16), {
				Parent = Orion,
				Position = UDim2.new(0.5, -WindowConfig.Size.X.Offset / 2, 0.5, -WindowConfig.Size.Y.Offset / 2),
				Size = WindowConfig.Size,
				BackgroundTransparency = 0,
				Name = "MainWindow",
				Visible = false,
			}),
			{
				SetChildren(
					AddThemeObject(
						SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 16), {
							Size = UDim2.new(1, 0, 1, -55),
							Position = UDim2.new(0, 0, 0, 55),
							Name = "FakeMainWindowNew",
							BackgroundTransparency = 0,
							ClipsDescendants = true,
							Active = true,
						}),
						"Main"
					),
					{
						SetChildren(
							SetProps(MakeElement("Image", ""), {
								Size = UDim2.new(1, 0, 1, 0),
								ScaleType = Enum.ScaleType.Crop,
								Name = "BackgroundImage",
								Image = WindowConfig.BackgroundURL,
								ZIndex = -10,
								Visible = false,
							}),
							{ MakeElement("Corner", 0, 16) }
						),
						ResizePoint,
						ResizePoint2,
					}
				),
				AddThemeObject(
					SetChildren(
						SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 16), {
							Size = UDim2.new(1, 0, 0, 50),
							Name = "TopBar",
							BackgroundTransparency = 0,
							ClipsDescendants = true,
							Active = true,
						}),
						{
							WindowTopBarLine,
							AddThemeObject(
								SetChildren(
									SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 0, 10), {
										Size = UDim2.new(0, 70, 0, 30),
										Position = UDim2.new(0, 10, 0, 10), -- canto ESQUERDO agora
										BackgroundTransparency = 1,
										Name = "ButtonsFrame",
									}),
									{
										SetProps(MakeElement("Stroke"), {
											Color = Color3.fromRGB(255, 255, 255),
											Name = "Stroke",
											Transparency = 0,
										}),
										AddThemeObject(
											SetProps(MakeElement("Frame"), {
												Size = UDim2.new(0, 1, 1, 0),
												Position = UDim2.new(0.5, 0, 0, 0),
												BackgroundTransparency = 0.5,
											}),
											"Divider"
										),
										CloseBtn,
										MinimizeBtn,
									}
								),
								"Elements"
							),
							AddThemeObject(
								SetChildren(
									SetProps(MakeElement("TFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
										Size = UDim2.new(1, 0, 1, 0),
										Position = UDim2.new(0, 0, 0, 20),
										Name = "WindowNames",
									}),
									{
										WindowName,
										WindowSubName,
									}
								),
								"Main"
							),
							SetChildren(
								SetProps(MakeElement("Image", ""), {
									Size = UDim2.new(1, 0, 0, 50),
									ScaleType = Enum.ScaleType.Crop,
									Position = UDim2.new(0, 0, 0, 0),
									Name = "BackgroundImage",
									Image = WindowConfig.BackgroundURL,
									ZIndex = -10,
								}),
								{ MakeElement("Corner", 0, 16) }
							),
						}
					),
					"Main"
				),
				DragPoint,
				WindowStuff,
			}
		),
		"Main"
	)

	-- [continuação — parte 2]
	local FreeMouseButton = Create("TextButton", {
		Name = "FreeMouseBtn",
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		Modal = true,
		Parent = Orion,
		Visible = false,
	})

	local mouseUnlocked = false

	local function SetMouseUnlocked(state)
		mouseUnlocked = state
		UserInputService.MouseIconEnabled = state
		FreeMouseButton.Visible = state

		if state then
			task.spawn(function()
				while mouseUnlocked and OrionLib:IsRunning() do
					UserInputService.MouseIconEnabled = true
					FreeMouseButton.Visible = true
					task.wait(0.1)
				end
			end)
		end
	end

	if WindowConfig.FreeMouse then
		SetMouseUnlocked(true)
	end

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 80, 0, -45)
		WindowName.TextXAlignment = Enum.TextXAlignment.Right
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 17.5),
			Name = "WindowIcon",
		})
		WindowIcon.Parent = MainWindow.TopBar
	end

	if WindowConfig.SearchBar then
		local SearchBox = Create("TextBox", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			PlaceholderColor3 = Color3.fromRGB(210, 210, 210),
			PlaceholderText = (type(WindowConfig.SearchBar) == "table" and WindowConfig.SearchBar.Default) or "Search",
			Font = Enum.Font.GothamBold,
			TextWrapped = true,
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 14,
			ClearTextOnFocus = (
				type(WindowConfig.SearchBar) == "table"
				and WindowConfig.SearchBar.ClearTextOnFocus ~= nil
				and WindowConfig.SearchBar.ClearTextOnFocus
			) or true,
		})

		local TextboxActual = AddThemeObject(SearchBox, "Text")
		local SearchBar = AddThemeObject(
			SetChildren(
				SetProps(MakeElement("RoundFrame", Color3.fromRGB(0, 0, 0), 1, 6), {
					Parent = MainWindow.TopBar,
					Size = UDim2.new(0, 100, 0, 30),
					Position = UDim2.new(1, -100, 0, 25),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 0,
					Name = "SearchBar",
				}),
				{
					SetProps(MakeElement("Stroke"), {
						Color = Color3.fromRGB(255, 255, 255),
						Name = "Stroke",
						Transparency = 0,
					}),
					TextboxActual,
				}
			),
			"Main"
		)

		SearchBar.UICorner.CornerRadius = UDim.new(0, 6)

		local function GetCurrentTab()
			local Containers = {}
			for _, Container in next, MainWindow:GetChildren() do
				if Container.Name == "ItemContainerLeft" or Container.Name == "ItemContainerRight" then
					table.insert(Containers, Container)
				end
			end
			for _, Container in next, Containers do
				if Container.Visible then
					return Container:GetAttribute("tab")
				end
			end
			return ""
		end

		local function ChangeTab(Name)
			pcall(function()
				local Tab = TabHolder:FindFirstChild(Name)
				local Containers = {}
				for _, Container in next, MainWindow:GetChildren() do
					if Container.Name == "ItemContainerLeft" or Container.Name == "ItemContainerRight" then
						table.insert(Containers, Container)
					end
				end
				for _, Container in next, Containers do
					if Container:GetAttribute("tab") == Name then
						Container.Visible = true
						task.spawn(function()
							local Tab = TabHolder:FindFirstChild(Container:GetAttribute("tab"))
							TweenService:Create(
								Tab.Ico,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ ImageTransparency = 0 }
							):Play()
							TweenService:Create(
								Tab.Title,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ TextTransparency = 0 }
							):Play()
							Tab.Title.Font = Enum.Font.GothamBlack
						end)
					else
						Container.Visible = false
						task.spawn(function()
							local Tab = TabHolder:FindFirstChild(Container:GetAttribute("tab"))
							TweenService:Create(
								Tab.Ico,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ ImageTransparency = 0.4 }
							):Play()
							TweenService:Create(
								Tab.Title,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ TextTransparency = 0.4 }
							):Play()
							Tab.Title.Font = Enum.Font.GothamSemibold
						end)
					end
				end
			end)
		end

		local function SearchHandle()
			pcall(function()
				local CurrentTab = GetCurrentTab()
				local Text = string.lower(SearchBox.Text)
				if not TabHolder or not TabHolder:IsA("GuiObject") then
					return
				end

				for _, container in MainWindow:GetChildren() do
					if container.Name == "ItemContainerLeft" or container.Name == "ItemContainerRight" then
						for _2, frame in container:GetChildren() do
							if not frame:IsA("Frame") then
								continue
							end
							for _3, btn in frame.Holder:GetChildren() do
								if not btn:IsA("Frame") then
									continue
								end
								local content = btn:FindFirstChild("Content")
									or btn:FindFirstChild("F"):FindFirstChild("Content")
								if Text == "" or string.find(string.lower(content.Text), Text) then
									local tab = container:GetAttribute("tab")
									if Text ~= "" then
										ChangeTab(tab)
									end
									if content.Parent.Name ~= "F" then
										content.Parent.Visible = true
									else
										content.Parent.Parent.Visible = true
									end
								else
									if Text ~= "" then
										if content.Parent.Name ~= "F" then
											content.Parent.Visible = false
										else
											content.Parent.Parent.Visible = false
										end
									end
								end
							end
						end
					end
				end
			end)
		end

		AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), SearchHandle)
	end

	local WatermarkFrame, WatermarkText, WatermarkIcon, WatermarkStroke, WatermarkConnection
	if WindowConfig.WatermarkConfig.Enabled then
		local FrameTimer = tick()
		local FrameCounter = 0
		local FPS = 60

		WatermarkFrame = AddThemeObject(
			Create("Frame", {
				Parent = Orion,
				Position = UDim2.new(0, 15, 0, 15),
				Size = UDim2.new(0, 200, 0, 28),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Name = "Watermark",
				ZIndex = 100,
				Active = true,
				Visible = WindowConfig.WatermarkConfig.Visible,
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
				Create("ImageLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					ScaleType = Enum.ScaleType.Crop,
					Name = "BackgroundImage",
					Image = WindowConfig.BackgroundURL,
					ZIndex = -10,
					Visible = false,
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) }),
			}),
			"Main"
		)

		WatermarkStroke = AddThemeObject(
			Create("UIStroke", {
				Parent = WatermarkFrame,
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1,
				Transparency = 0,
			}),
			"Stroke"
		)

		local IconOffset = 0
		if WindowConfig.WatermarkConfig.Icon then
			IconOffset = 22
			WatermarkIcon = AddThemeObject(
				Create("ImageLabel", {
					Parent = WatermarkFrame,
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0, 8, 0.5, -8),
					BackgroundTransparency = 1,
					Image = WindowConfig.WatermarkConfig.Icon or "",
					Name = "WatermarkIcon",
					ZIndex = 101,
				}),
				"Text"
			)
		end

		WatermarkText = AddThemeObject(
			Create("TextLabel", {
				Parent = WatermarkFrame,
				Size = UDim2.new(1, -IconOffset - 16, 1, 0),
				Position = UDim2.new(0, IconOffset + 8, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Name = "WatermarkText",
				ZIndex = 101,
				Text = "",
			}),
			"Text"
		)

		local parts = {}
		local function UpdateWatermark()
			parts = {}
			if WindowConfig.WatermarkConfig.ShowName then
				parts[#parts + 1] = WindowConfig.Name
			end
			if WindowConfig.WatermarkConfig.ShowFPS then
				parts[#parts + 1] = tostring(math.floor(FPS)) .. " fps"
			end
			if WindowConfig.WatermarkConfig.ShowPing then
				local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
				parts[#parts + 1] = ping .. " ms"
			end
			if WindowConfig.WatermarkConfig.ShowClockTime then
				parts[#parts + 1] = os.date("%H:%M:%S")
			end
			WatermarkText.Text = table.concat(parts, " | ")
			WatermarkFrame.Size = UDim2.new(0, WatermarkText.TextBounds.X + IconOffset + 16, 0, 28)
		end
		UpdateWatermark()

		WatermarkConnection = RunService.RenderStepped:Connect(function()
			FrameCounter = FrameCounter + 1
			if (tick() - FrameTimer) >= 1 then
				FPS = FrameCounter
				FrameTimer = tick()
				FrameCounter = 0
				UpdateWatermark()
			end
		end)
		OrionLib.Connections[#OrionLib.Connections + 1] = WatermarkConnection
	end

	local function AddDraggingFunctionality(DragPoint, Main)
		pcall(function()
			local Dragging, DragInput, MousePos, FramePos = false
			DragPoint.InputBegan:Connect(function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					Dragging = true
					MousePos = Input.Position
					FramePos = Main.Position
					Input.Changed:Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							Dragging = false
						end
					end)
				end
			end)
			DragPoint.InputChanged:Connect(function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseMovement
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					DragInput = Input
				end
			end)
			UserInputService.InputChanged:Connect(function(Input)
				if Input == DragInput and Dragging then
					local Delta = Input.Position - MousePos
					TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = UDim2.new(
							FramePos.X.Scale,
							FramePos.X.Offset + Delta.X,
							FramePos.Y.Scale,
							FramePos.Y.Offset + Delta.Y
						),
					}):Play()
				end
			end)
		end)
	end

	local function AddResizingFunctionality(ResizePoint, Main, IsTabholder)
		pcall(function()
			local Dragging, DragInput, MousePos, FrameSize = false
			local Clamp, Sizing = false, false

			ResizePoint.InputBegan:Connect(function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					Dragging = true
					MousePos = Input.Position
					FrameSize = Main.Size
					Input.Changed:Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							Dragging = false
							Sizing = false
							Clamp = false
						end
					end)
				end
			end)
			ResizePoint.InputChanged:Connect(function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseMovement
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					DragInput = Input
				end
			end)
			UserInputService.InputChanged:Connect(function(Input)
				if Input == DragInput and Dragging then
					local Delta = Input.Position - MousePos
					local size
					if IsTabholder then
						size = UDim2.new(
							0,
							math.clamp(FrameSize.X.Offset + Delta.X, 10, (MainWindow.Size.X.Offset / 2) + 50),
							0,
							math.clamp(FrameSize.Y.Offset + Delta.Y, 45, 9999)
						)
						Val.TabholderSize = size
					else
						size = UDim2.new(
							FrameSize.X.Scale,
							math.clamp(
								FrameSize.X.Offset + Delta.X,
								WindowConfig.MinSize.X.Offset,
								WindowConfig.MaxSize.X.Offset
							),
							FrameSize.Y.Scale,
							math.clamp(
								FrameSize.Y.Offset + Delta.Y,
								WindowConfig.MinSize.Y.Offset,
								WindowConfig.MaxSize.Y.Offset
							)
						)
					end
					TweenService
						:Create(
							Main,
							TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Size = size }
						)
						:Play()
					WindowConfig.Size = size
				end
			end)
		end)
	end

	AddDraggingFunctionality(DragPoint, MainWindow)
	AddDraggingFunctionality(WatermarkFrame, WatermarkFrame)
	AddResizingFunctionality(ResizePoint, MainWindow, false)
	AddResizingFunctionality(ResizePoint2, MainWindow, false)
	AddResizingFunctionality(ResizeTabHolderPoint, WindowStuff, true)
	AddResizingFunctionality(ResizeTabHolderPoint2, WindowStuff, true)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		Val.UIHidden = true
		if WindowConfig.FreeMouse then
			SetMouseUnlocked(false)
		end
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == WindowConfig.ToggleUIKey then
			Val.UIHidden = not Val.UIHidden
			MainWindow.Visible = not Val.UIHidden
			if WindowConfig.FreeMouse then
				SetMouseUnlocked(not Val.UIHidden)
			end
		end
	end)

	AddConnection(WindowName:GetPropertyChangedSignal("TextBounds"), function()
		WindowSubName.Size = UDim2.new(1, -WindowName.TextBounds.X - 240, 1, 0)
		WindowSubName.Position =
			UDim2.new(0, WindowConfig.ShowIcon and WindowName.TextBounds.X + 60 or WindowName.TextBounds.X + 35, 0, -19)
	end)

	AddConnection(MainWindow:GetPropertyChangedSignal("Size"), function()
		MainWindow.TopBar.BackgroundImage.Size = MainWindow.Size
		WindowStuff.Size = UDim2.new(0, Val.TabholderSize.X.Offset, 0, MainWindow.Size.Y.Offset - 50)
	end)

	AddConnection(MainWindow.UICorner:GetPropertyChangedSignal("CornerRadius"), function()
		MainWindow.TopBar.BackgroundImage.UICorner.CornerRadius = MainWindow.UICorner.CornerRadius
		MainWindow.FakeMainWindowNew.BackgroundImage.UICorner.CornerRadius = MainWindow.UICorner.CornerRadius
		WindowStuff.BackgroundImage.UICorner.CornerRadius = MainWindow.UICorner.CornerRadius
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkFrame.BackgroundImage.UICorner.CornerRadius = MainWindow.UICorner.CornerRadius
			WatermarkFrame.UICorner.CornerRadius = MainWindow.UICorner.CornerRadius
		end
	end)

	local VisibleContainers = {}
	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Val.Minimized then
			TweenService:Create(
				MainWindow,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = WindowConfig.Size }
			):Play()
			spawn(function()
				WindowSubName.Visible = true
				TweenService:Create(WindowSubName, TweenInfo.new(0.1), { TextTransparency = 0 }):Play()
			end)
			ResizePoint.Visible = true
			ResizeTabHolderPoint.Visible = true
			MinimizeBtn.Ico.Image = NebulaIcons.Minimize
			WindowSubName.Visible = true
			wait(0.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
			for i, v in pairs(VisibleContainers) do
				v.Visible = true
			end
			VisibleContainers = {}
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = NebulaIcons.Plus

			if not WindowConfig.ShowIcon then
				TweenService:Create(
					MainWindow,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50) }
				):Play()
			else
				TweenService:Create(
					MainWindow,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, WindowName.TextBounds.X + 160, 0, 50) }
				):Play()
			end
			spawn(function()
				TweenService:Create(WindowSubName, TweenInfo.new(0.1), { TextTransparency = 1 }):Play()
				wait(0.1)
				WindowSubName.Visible = false
			end)
			ResizePoint.Visible = false
			ResizeTabHolderPoint.Visible = false
			wait(0.1)
			WindowStuff.Visible = false
			for i, Container in pairs(MainWindow:GetChildren()) do
				if Container.Name == "ItemContainerLeft" or Container.Name == "ItemContainerRight" then
					if Container.Visible then
						Container.Visible = false
						table.insert(VisibleContainers, Container)
					end
				end
			end
		end
		Val.Minimized = not Val.Minimized
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1,
		})
		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1,
		})
		TweenService:Create(
			LoadSequenceLogo,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }
		):Play()
		wait(0.8)
		TweenService:Create(
			LoadSequenceLogo,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X / 2), 0.5, 0) }
		):Play()
		wait(0.3)
		TweenService:Create(
			LoadSequenceText,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 0 }
		):Play()
		wait(2)
		TweenService:Create(
			LoadSequenceText,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 1 }
		):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end

	-- ===============================================================
	-- Set functions
	-- ===============================================================
	local TabFunction = {}

	function TabFunction:SetSize(Size)
		MainWindow.Size = Size
	end

	function TabFunction:SetIconColor(Color)
		if MainWindow.TopBar:FindFirstChild("WindowIcon") then
			MainWindow.TopBar.WindowIcon.ImageColor3 = Color
		end
		for i, Tab in next, TabHolder:GetChildren() do
			if Tab:IsA("TextButton") and Tab:FindFirstChild("Ico") then
				Tab.Ico.ImageColor3 = Color
			end
		end
	end

	function TabFunction:SetColor(Color)
		MainWindow.FakeMainWindowNew.BackgroundColor3 = Color
		MainWindow.TopBar.BackgroundColor3 = Color
		MainWindow.BackgroundColor3 = Color
		WindowStuff.BackgroundColor3 = Color
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkFrame.BackgroundColor3 = Color
		end
	end

	function TabFunction:SetStrokeColor(Color)
		MainWindow.TopBar.ButtonsFrame.Stroke.Color = Color
		MainWindow.TopBar.ButtonsFrame.Frame.BackgroundColor3 = Color
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkStroke.Color = Color
		end
	end

	function TabFunction:SetStrokeTransparency(Transparency)
		MainWindow.TopBar.ButtonsFrame.Stroke.Transparency = Transparency
		MainWindow.TopBar.ButtonsFrame.Frame.BackgroundTransparency = Transparency
	end

	function TabFunction:SetTextColor(Color)
		local SubNameColor = Color3.fromRGB(Color.R * 180, Color.G * 180, Color.B * 180)
		MainWindow.TopBar.WindowNames.WindowName.TextColor3 = Color
		MainWindow.TopBar.WindowNames.WindowSubName.TextColor3 = SubNameColor
		for i, Tab in next, TabHolder:GetChildren() do
			if Tab:IsA("TextButton") then
				Tab.Title.TextColor3 = Color
			end
		end
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkText.TextColor3 = Color
		end
	end

	function TabFunction:SetTextTransparency(Transparency)
		MainWindow.TopBar.WindowNames.WindowName.TextTransparency = Transparency
		MainWindow.TopBar.WindowNames.WindowSubName.TextTransparency = Transparency
		for i, Tab in next, TabHolder:GetChildren() do
			if Tab:IsA("TextButton") then
				Tab.Title.TextTransparency = Transparency
			end
		end
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkText.TextTransparency = Transparency
		end
	end

	function TabFunction:SetTransparency(Transparency)
		MainWindow.BackgroundTransparency = Transparency
		WindowConfig.Transparency = Transparency
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkFrame.BackgroundTransparency = Transparency
		end
	end

	function TabFunction:SetToggleKey(Key)
		local KeyCode = Key or Enum.KeyCode.RightShift
		WindowConfig.ToggleUIKey = Enum.KeyCode[KeyCode]
	end

	function TabFunction:DestroyElement(Flag)
		if OrionLib.Flags[Flag] ~= nil then
			OrionLib.Flags[Flag]:Destroy()
		end
	end

	function TabFunction:SetThemeColor(Theme, Element, ThemeColor)
		OrionLib.Themes[Theme][Element] = ThemeColor
	end

	function TabFunction:SetThemeTransparency(Theme, Element, Transparency)
		OrionLib.Themes[Theme][Element].Transparency = Transparency
	end

	function TabFunction:SetMainCorners(Offset)
		MainWindow.FakeMainWindowNew.UICorner.CornerRadius = UDim.new(0, Offset)
		MainWindow.TopBar.UICorner.CornerRadius = UDim.new(0, Offset)
		WindowStuff.UICorner.CornerRadius = UDim.new(0, Offset)
		MainWindow.UICorner.CornerRadius = UDim.new(0, Offset)
	end

	function TabFunction:SetBackground(URL)
		WindowConfig.BackgroundURL = URL
		MainWindow.FakeMainWindowNew.BackgroundImage.Image = URL
		MainWindow.TopBar.BackgroundImage.Image = URL
		WindowStuff.BackgroundImage.Image = URL
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkFrame.BackgroundImage.Image = URL
		end
	end

	function TabFunction:SetBackgroundTransparency(Transparency)
		WindowConfig.BackgroundTransparency = tonumber(Transparency)
		MainWindow.FakeMainWindowNew.BackgroundImage.ImageTransparency = Transparency
		MainWindow.TopBar.BackgroundImage.ImageTransparency = Transparency
		WindowStuff.BackgroundImage.ImageTransparency = Transparency
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkFrame.BackgroundImage.ImageTransparency = Transparency
		end
	end

	function TabFunction:SetBackgroundVisibility(Bool)
		MainWindow.FakeMainWindowNew.BackgroundImage.Visible = Bool
		WindowStuff.BackgroundImage.Visible = Bool
		MainWindow.TopBar.BackgroundImage.Visible = Bool
		if WindowConfig.WatermarkConfig.Enabled then
			WatermarkFrame.BackgroundImage.Visible = Bool
		end
	end

	function TabFunction:SetWatermarkVisibility(Bool)
		if WatermarkFrame then
			WatermarkFrame.Visible = Bool
			WindowConfig.WatermarkConfig.Enabled = Bool
		end
	end

	function TabFunction:SetWatermarkText(Text)
		if WatermarkText then
			WatermarkText.Text = tostring(Text)
			WatermarkFrame.Size = UDim2.new(0, WatermarkText.TextBounds.X + (WatermarkIcon and 38 or 20), 0, 28)
		end
	end

	function TabFunction:SetWatermarkColor(Color)
		if WatermarkFrame then
			WatermarkFrame.BackgroundColor3 = Color
		end
	end
	function TabFunction:SetWatermarkTextColor(Color)
		if WatermarkText then
			WatermarkText.TextColor3 = Color
		end
	end
	function TabFunction:SetWatermarkIconColor(Color)
		if WatermarkIcon then
			WatermarkIcon.ImageColor3 = Color
		end
	end
	function TabFunction:SetWatermarkTransparency(Transparency)
		if WatermarkFrame then
			WatermarkFrame.BackgroundTransparency = Transparency
		end
		if WatermarkStroke then
			WatermarkStroke.Transparency = Transparency
		end
	end
	function TabFunction:SetWatermarkPosition(Position)
		if WatermarkFrame then
			WatermarkFrame.Position = Position
		end
	end
	function TabFunction:DestroyWatermark()
		if WatermarkConnection then
			WatermarkConnection:Disconnect()
			WatermarkConnection = nil
		end
		if WatermarkFrame then
			WatermarkFrame:Destroy()
			WatermarkFrame = nil
		end
	end

	-- ===============================================================
	-- MakeTab
	-- ===============================================================
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
		Val.Tab = TabConfig.Name

		local TabFrame = SetChildren(
			SetProps(MakeElement("Button"), {
				Size = UDim2.new(1, 0, 0, 30),
				Parent = TabHolder,
				TextWrapped = false,
				Name = Val.Tab,
			}),
			{
				AddThemeObject(
					SetProps(MakeElement("Image", GetLucideIcon(TabConfig.Icon)), {
						AnchorPoint = Vector2.new(0, 0.5),
						Size = UDim2.new(0, 18, 0, 18),
						Position = UDim2.new(0, 10, 0.5, 0),
						ImageTransparency = 0.4,
						Name = "Ico",
					}),
					"Text"
				),
				AddThemeObject(
					SetProps(MakeElement("Label", TabConfig.Name, 14), {
						Size = UDim2.new(1, -35, 1, 0),
						Position = UDim2.new(0, 35, 0, 0),
						Font = Enum.Font.GothamSemibold,
						TextTransparency = 0.4,
						TextWrapped = false,
						Name = "Title",
					}),
					"Text"
				),
			}
		)

		local ContainerLeft = AddThemeObject(
			SetChildren(
				SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255)), {
					Size = UDim2.new(0.5, -40, 1, 0),
					Position = UDim2.new(0, 95, 0, 50),
					Parent = MainWindow,
					Visible = false,
					Name = "ItemContainerLeft",
				}),
				{
					MakeElement("List", 0, 6),
					MakeElement("Padding", 15, 10, 10, 15),
				}
			),
			"Divider"
		)
		ContainerLeft:SetAttribute("tab", Val.Tab)

		local ContainerRight = AddThemeObject(
			SetChildren(
				SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255)), {
					Size = UDim2.new(0.5, -40, 1, 0),
					Position = UDim2.new(0.5, 40, 0, 50),
					Parent = MainWindow,
					Visible = false,
					Name = "ItemContainerRight",
				}),
				{
					MakeElement("List", 0, 6),
					MakeElement("Padding", 15, 10, 10, 15),
				}
			),
			"Divider"
		)
		ContainerRight:SetAttribute("tab", Val.Tab)

		AddConnection(ContainerLeft.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			ContainerLeft.CanvasSize = UDim2.new(0, 0, 0, ContainerLeft.UIListLayout.AbsoluteContentSize.Y - 5)
		end)
		AddConnection(ContainerRight.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			ContainerRight.CanvasSize = UDim2.new(0, 0, 0, ContainerRight.UIListLayout.AbsoluteContentSize.Y - 5)
		end)

		if GetOrionIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetOrionIcon(TabConfig.Icon)
		end

		if Val.FirstTab then
			Val.FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			ContainerLeft.Visible = true
			ContainerRight.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(
						Tab.Ico,
						TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ ImageTransparency = 0.4 }
					):Play()
					TweenService:Create(
						Tab.Title,
						TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ TextTransparency = 0.4 }
					):Play()
				end
			end
			for _, Container in next, MainWindow:GetChildren() do
				if Container.Name == "ItemContainerLeft" or Container.Name == "ItemContainerRight" then
					Container.Visible = false
				end
			end
			TweenService:Create(
				TabFrame.Ico,
				TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ ImageTransparency = 0 }
			):Play()
			TweenService:Create(
				TabFrame.Title,
				TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ TextTransparency = 0 }
			):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			ContainerLeft.Visible = true
			ContainerRight.Visible = true
		end)

		do
			local width
			local function SetSizes()
				width = (MainWindow.AbsoluteSize.X - TabHolder.Parent.AbsoluteSize.X + 5) / 2
				ContainerLeft.Size = UDim2.new(0, width + 5, 1, -60)
				ContainerRight.Size = UDim2.new(0, width + 5, 1, -60)
				ContainerLeft.Position = UDim2.new(0, TabHolder.Parent.AbsoluteSize.X - 5, 0, 50)
				ContainerRight.Position = UDim2.new(0, TabHolder.Parent.AbsoluteSize.X + width - 10, 0, 50)
				MainWindow.FakeMainWindowNew.Position = UDim2.new(0, TabHolder.Parent.AbsoluteSize.X + 5, 0, 55)
				MainWindow.FakeMainWindowNew.Size = UDim2.new(1, -TabHolder.Parent.AbsoluteSize.X - 5, 1, -55)
			end
			SetSizes()
			AddConnection(TabHolder.Parent:GetPropertyChangedSignal("AbsoluteSize"), SetSizes)
			AddConnection(MainWindow:GetPropertyChangedSignal("AbsoluteSize"), SetSizes)
		end

		local function GetElements(ItemParent)
			local ElementFunction = { Type = "ElementFunction" }

			local function AddElements(ItemParent2)
				function ItemParent2:AddLabel(Text)
					Text = Text or "Label"
					local LabelFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 30),
								BackgroundTransparency = 0,
								Parent = ItemParent,
								Name = "Label",
							}),
							{
								AddThemeObject(
									SetProps(MakeElement("Label", Text, 14), {
										Size = UDim2.new(1, -12, 1, 0),
										Position = UDim2.new(0, 12, 0, 0),
										Font = Enum.Font.GothamBold,
										Name = "Content",
										TextWrapped = true,
									}),
									"Text"
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
							}
						),
						"Elements"
					)
					AddConnection(LabelFrame.Content:GetPropertyChangedSignal("Text"), function()
						LabelFrame.Content.Size = UDim2.new(1, -24, 0, LabelFrame.Content.TextBounds.Y)
						LabelFrame.Content.Position = UDim2.new(0, 12, 0, 6)
						LabelFrame.Size = UDim2.new(1, 0, 0, LabelFrame.Content.TextBounds.Y + 12)
					end)
					return {
						Set = function(_, t)
							LabelFrame.Content.Text = t
						end,
					}
				end

				function ItemParent2:AddParagraph(Text, Content)
					Text = Text or "Text"
					Content = Content or "Content"
					local ParagraphFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 30),
								BackgroundTransparency = 0,
								Parent = ItemParent,
								Name = "Paragraph",
							}),
							{
								AddThemeObject(
									SetProps(MakeElement("Label", Text, 14), {
										Size = UDim2.new(1, -12, 0, 14),
										Position = UDim2.new(0, 12, 0, 10),
										Font = Enum.Font.GothamBold,
										Name = "Title",
									}),
									"Text"
								),
								AddThemeObject(
									SetProps(MakeElement("Label", "", 13), {
										Size = UDim2.new(1, -24, 0, 0),
										Position = UDim2.new(0, 12, 0, 26),
										Font = Enum.Font.GothamSemibold,
										Name = "Content",
										TextWrapped = true,
									}),
									"TextDark"
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
							}
						),
						"Elements"
					)
					AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
						ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
						ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
					end)
					task.wait(0.01)
					ParagraphFrame.Content.Text = Content
					return {
						Set = function(_, t)
							ParagraphFrame.Content.Text = t
						end,
					}
				end

				function ItemParent2:AddButton(ButtonConfig)
					ButtonConfig = ButtonConfig or {}
					ButtonConfig.Name = ButtonConfig.Name or "Button"
					ButtonConfig.Callback = ButtonConfig.Callback or function() end
					ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"
					ButtonConfig.DoubleTap = ButtonConfig.DoubleTap or false
					ButtonConfig.TapDelay = ButtonConfig.TapDelay or 0.5

					local Button, Tap, OldButtonName = {}, 0, ButtonConfig.Name
					local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

					local ButtonFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 33),
								Parent = ItemParent,
								BackgroundTransparency = 0,
								Name = "Button",
							}),
							{
								AddThemeObject(
									SetProps(MakeElement("Label", ButtonConfig.Name, 14), {
										Size = UDim2.new(1, -40, 1, 0),
										Position = UDim2.new(0, 12, 0, 0),
										Font = Enum.Font.GothamBold,
										Name = "Content",
										TextWrapped = true,
									}),
									"Text"
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
								Click,
							}
						),
						"Elements"
					)

					function Button:Set(ButtonText)
						ButtonFrame.Content.Text = ButtonText
					end
					function Button:SetColor(Color)
						ButtonFrame.BackgroundColor3 = Color
					end

					AddConnection(Click.MouseEnter, function()
						TweenService
							:Create(ButtonFrame, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) })
							:Play()
					end)
					AddConnection(Click.MouseLeave, function()
						TweenService
							:Create(ButtonFrame, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(15, 15, 15) })
							:Play()
					end)
					AddConnection(Click.MouseButton1Up, function()
						Tap += 1
						if Tap == 2 and ButtonConfig.DoubleTap then
							ButtonConfig.Callback()
						elseif Tap == 1 and ButtonConfig.DoubleTap then
							ButtonFrame.Content.Text = "Are you sure?"
							task.wait(ButtonConfig.TapDelay)
							if Tap == 1 then
								Tap = 0
								ButtonFrame.Content.Text = OldButtonName
							end
						elseif not ButtonConfig.DoubleTap then
							ButtonConfig.Callback()
						end
						Tap = 0
						ButtonFrame.Content.Text = OldButtonName
					end)
					table.insert(OrionLib.UIElements, Button)
					return Button
				end

				function ItemParent2:AddToggle(ToggleConfig)
					ToggleConfig = ToggleConfig or {}
					ToggleConfig.Name = ToggleConfig.Name or "Toggle"
					ToggleConfig.Default = ToggleConfig.Default or false
					ToggleConfig.Callback = ToggleConfig.Callback or function() end
					ToggleConfig.Flag = ToggleConfig.Flag or nil

					local Toggle = { Value = ToggleConfig.Default, Name = ToggleConfig.Name, Type = "Toggle" }
					ElementFunction.Type = "Toggle"
					local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 0, 38) })

					local ToggleBox = SetChildren(
						SetProps(MakeElement("RoundFrame", Color3.fromRGB(30, 30, 30), 0, 5), {
							Size = UDim2.new(0, 20, 0, 20),
							Position = UDim2.new(1, -24, 0, 19),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 0,
						}),
						{
							SetProps(
								MakeElement("Stroke"),
								{ Color = Color3.fromRGB(255, 255, 255), Name = "Stroke", Transparency = 0 }
							),
							SetProps(MakeElement("Image", NebulaIcons.Check), {
								Size = UDim2.new(0, 14, 0, 14),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0.5, 0),
								ImageColor3 = Color3.fromRGB(0, 0, 0),
								ImageTransparency = 1,
								Name = "Ico",
							}),
						}
					)

					local ToggleFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 38),
								Parent = ItemParent,
								BackgroundTransparency = 0,
								Name = "Toggle",
							}),
							{
								AddThemeObject(
									SetProps(MakeElement("Label", ToggleConfig.Name, 14), {
										Size = UDim2.new(1, -50, 0, 0),
										Position = UDim2.new(0, 12, 0, 19),
										Font = Enum.Font.GothamBold,
										Name = "Content",
										TextWrapped = true,
									}),
									"Text"
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
								ToggleBox,
								Click,
							}
						),
						"Elements"
					)

					function Toggle:Set(Value)
						Toggle.Value = Value
						if Value then
							TweenService:Create(
								ToggleFrame,
								TweenInfo.new(0.2),
								{ BackgroundColor3 = Color3.fromRGB(200, 200, 200) }
							):Play()
							TweenService
								:Create(
									ToggleFrame.Content,
									TweenInfo.new(0.2),
									{ TextColor3 = Color3.fromRGB(0, 0, 0) }
								)
								:Play()
							TweenService
								:Create(ToggleBox, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
								:Play()
							TweenService
								:Create(ToggleBox.Stroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(0, 0, 0) })
								:Play()
							TweenService:Create(
								ToggleBox.Ico,
								TweenInfo.new(0.2),
								{ ImageTransparency = 0, ImageColor3 = Color3.fromRGB(200, 200, 200) }
							):Play()
						else
							TweenService
								:Create(
									ToggleFrame,
									TweenInfo.new(0.2),
									{ BackgroundColor3 = Color3.fromRGB(15, 15, 15) }
								)
								:Play()
							TweenService:Create(
								ToggleFrame.Content,
								TweenInfo.new(0.2),
								{ TextColor3 = Color3.fromRGB(255, 255, 255) }
							):Play()
							TweenService
								:Create(
									ToggleBox,
									TweenInfo.new(0.2),
									{ BackgroundColor3 = Color3.fromRGB(30, 30, 30) }
								)
								:Play()
							TweenService
								:Create(ToggleBox.Stroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255) })
								:Play()
							TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
						end
						ToggleConfig.Callback(Toggle.Value)
					end

					AddConnection(Click.MouseButton1Up, function()
						Toggle:Set(not Toggle.Value)
					end)

					Toggle:Set(Toggle.Value)
					if ToggleConfig.Flag then
						OrionLib.Flags[ToggleConfig.Flag] = Toggle
					end
					table.insert(OrionLib.UIElements, Toggle)
					return Toggle
				end

				function ItemParent2:AddSlider(SliderConfig)
					SliderConfig = SliderConfig or {}
					SliderConfig.Name = SliderConfig.Name or "Slider"
					SliderConfig.Min = SliderConfig.Min or 0
					SliderConfig.Max = SliderConfig.Max or 100
					SliderConfig.Increment = SliderConfig.Increment or 1
					SliderConfig.Default = SliderConfig.Default or 50
					SliderConfig.Callback = SliderConfig.Callback or function() end
					SliderConfig.InputEndedCallback = SliderConfig.InputEndedCallback or function() end
					SliderConfig.ValueName = SliderConfig.ValueName or ""
					SliderConfig.Flag = SliderConfig.Flag or nil

					local Slider = { Value = SliderConfig.Default, Name = SliderConfig.Name, Type = "Slider" }
					local Dragging = false

					local SliderDrag = SetChildren(
						SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 0.2,
							ClipsDescendants = true,
						}),
						{
							AddThemeObject(
								SetProps(MakeElement("Label", "value", 13), {
									Size = UDim2.new(1, -12, 0, 14),
									Position = UDim2.new(0, 12, 0, 6),
									Font = Enum.Font.GothamBold,
									Name = "Value",
									TextTransparency = 0,
								}),
								"Text"
							),
						}
					)

					local SliderBar = SetChildren(
						SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, -24, 0, 26),
							Position = UDim2.new(0, 12, 0, 30),
							BackgroundTransparency = 0.9,
						}),
						{
							SetProps(MakeElement("Stroke"), { Color = Color3.fromRGB(255, 255, 255), Name = "Stroke" }),
							AddThemeObject(
								SetProps(MakeElement("Label", "value", 13), {
									Size = UDim2.new(1, -12, 0, 14),
									Position = UDim2.new(0, 12, 0, 6),
									Font = Enum.Font.GothamBold,
									Name = "Value",
									TextTransparency = 0.8,
								}),
								"Text"
							),
							SliderDrag,
						}
					)

					local SliderFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 65),
								Parent = ItemParent,
								BackgroundTransparency = 0,
								Name = "Slider",
							}),
							{
								AddThemeObject(
									SetProps(MakeElement("Label", SliderConfig.Name, 14), {
										Size = UDim2.new(1, -12, 0, 14),
										Position = UDim2.new(0, 12, 0, 10),
										Font = Enum.Font.GothamBold,
										Name = "Content",
										TextWrapped = true,
									}),
									"Text"
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
								SliderBar,
							}
						),
						"Elements"
					)

					SliderBar.InputBegan:Connect(function(Input)
						if
							Input.UserInputType == Enum.UserInputType.MouseButton1
							or Input.UserInputType == Enum.UserInputType.Touch
						then
							Dragging = true
						end
					end)

					SliderBar.InputEnded:Connect(function(Input)
						if
							Input.UserInputType == Enum.UserInputType.MouseButton1
							or Input.UserInputType == Enum.UserInputType.Touch
						then
							Dragging = false
							local SizeScale = math.clamp(
								(Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X,
								0,
								1
							)
							SliderConfig.InputEndedCallback(
								Round(
									SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale),
									SliderConfig.Increment
								)
							)
						end
					end)

					UserInputService.InputChanged:Connect(function(Input)
						if
							Dragging
							and (
								Input.UserInputType == Enum.UserInputType.MouseMovement
								or Input.UserInputType == Enum.UserInputType.Touch
							)
						then
							local SizeScale = math.clamp(
								(Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X,
								0,
								1
							)
							Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
						end
					end)

					function Slider:Set(Value)
						self.Value =
							math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
						TweenService
							:Create(SliderDrag, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Size = UDim2.fromScale(
									(self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min),
									1
								),
							})
							:Play()
						SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
						SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
						SliderConfig.Callback(self.Value)
					end

					Slider:Set(Slider.Value)
					if SliderConfig.Flag then
						OrionLib.Flags[SliderConfig.Flag] = Slider
					end
					table.insert(OrionLib.UIElements, Slider)
					return Slider
				end

				function ItemParent2:AddDropdown(DropdownConfig)
					DropdownConfig = DropdownConfig or {}
					DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
					DropdownConfig.Options = DropdownConfig.Options or {}
					DropdownConfig.Default = DropdownConfig.Default or ""
					DropdownConfig.Callback = DropdownConfig.Callback or function() end
					DropdownConfig.Flag = DropdownConfig.Flag or nil

					local Dropdown = {
						Buttons = {},
						Value = DropdownConfig.Default,
						Options = DropdownConfig.Options,
						Toggled = false,
						Type = "Dropdown",
						Name = DropdownConfig.Name,
					}
					if not table.find(Dropdown.Options, Dropdown.Value) then
						Dropdown.Value = {}
					end

					local DropdownList =
						SetProps(MakeElement("List"), { HorizontalAlignment = Enum.HorizontalAlignment.Center })

					local DropdownContainer = AddThemeObject(
						SetProps(
							SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(0, 0, 0)), {
								DropdownList,
							}),
							{
								Parent = ItemParent,
								Position = UDim2.new(0, 0, 0, 38),
								Size = UDim2.new(1, 0, 1, -38),
								ClipsDescendants = true,
							}
						),
						"Divider"
					)

					local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

					local DropdownFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 38),
								Parent = ItemParent,
								ClipsDescendants = true,
								BackgroundTransparency = 0,
								Name = "Dropdown",
							}),
							{
								DropdownContainer,
								SetProps(
									SetChildren(MakeElement("TFrame"), {
										AddThemeObject(
											SetProps(MakeElement("Label", DropdownConfig.Name, 14), {
												Size = UDim2.new(1, -12, 1, 0),
												Position = UDim2.new(0, 12, 0, 0),
												Font = Enum.Font.GothamBold,
												Name = "Content",
											}),
											"Text"
										),
										AddThemeObject(
											SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
												Size = UDim2.new(0, 20, 0, 20),
												AnchorPoint = Vector2.new(0, 0.5),
												Position = UDim2.new(1, -30, 0.5, 0),
												ImageColor3 = Color3.fromRGB(255, 255, 255),
												Name = "Ico",
											}),
											"TextDark"
										),
										AddThemeObject(
											SetProps(MakeElement("Frame"), {
												Size = UDim2.new(1, 0, 0, 1),
												Position = UDim2.new(0, 0, 1, -1),
												Name = "Line",
												Visible = false,
											}),
											"Stroke"
										),
										Click,
									}),
									{
										Size = UDim2.new(1, 0, 0, 38),
										ClipsDescendants = true,
										Name = "F",
									}
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
								MakeElement("Corner"),
							}
						),
						"Elements"
					)

					AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
						DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
					end)

					local function AddOptions(Options)
						for _, Option in pairs(Options) do
							local OptionBtn = AddThemeObject(
								SetProps(
									SetChildren(MakeElement("Button", Color3.fromRGB(0, 0, 0)), {
										MakeElement("Corner", 0, 6),
										AddThemeObject(
											SetProps(MakeElement("Label", Option, 13, 0.4), {
												Position = UDim2.new(0, 4, 0, 0),
												Size = UDim2.new(1, -8, 1, 0),
												Name = "Title",
											}),
											"Text"
										),
									}),
									{
										Parent = DropdownContainer,
										Size = UDim2.new(1, 0, 0, 28),
										BackgroundTransparency = 1,
										ClipsDescendants = true,
									}
								),
								"Divider"
							)

							AddConnection(OptionBtn.MouseButton1Click, function()
								Dropdown:Set(Option)
							end)
							Dropdown.Buttons[Option] = OptionBtn
						end
					end

					function Dropdown:Refresh(Options, Delete)
						if Delete then
							for _, Button in pairs(Dropdown.Buttons) do
								if Button then
									Button:Destroy()
								end
							end
							Dropdown.Buttons = {}
							Dropdown.Options = {}
						end
						Dropdown.Options = Options or {}
						AddOptions(Dropdown.Options)
						task.wait()
						DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
					end

					function Dropdown:Set(Value)
						if not table.find(Dropdown.Options, Value) then
							return
						end
						Dropdown.Value = Value
						for _, v in pairs(Dropdown.Buttons) do
							v.BackgroundTransparency = 1
							v.Title.TextTransparency = 0.4
						end
						Dropdown.Buttons[Value].BackgroundTransparency = 0
						Dropdown.Buttons[Value].Title.TextTransparency = 0
						DropdownConfig.Callback(Dropdown.Value)
					end

					local OldSize = 0
					AddConnection(Click.MouseButton1Click, function()
						Dropdown.Toggled = not Dropdown.Toggled
						DropdownFrame.F.Line.Visible = Dropdown.Toggled
						TweenService
							:Create(
								DropdownFrame.F.Ico,
								TweenInfo.new(0.15),
								{ Rotation = Dropdown.Toggled and 180 or 0 }
							)
							:Play()
						local NextSize = Dropdown.Toggled
								and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38)
							or UDim2.new(1, 0, 0, 38)
						TweenService:Create(DropdownFrame, TweenInfo.new(0.15), { Size = NextSize }):Play()
					end)

					Dropdown:Refresh(Dropdown.Options, false)
					Dropdown:Set(Dropdown.Value)
					if DropdownConfig.Flag then
						OrionLib.Flags[DropdownConfig.Flag] = Dropdown
					end
					table.insert(OrionLib.UIElements, Dropdown)
					return Dropdown
				end

				function ItemParent2:AddBind(BindConfig)
					BindConfig = BindConfig or {}
					BindConfig.Name = BindConfig.Name or "Bind"
					BindConfig.Default = BindConfig.Default or ""
					BindConfig.Hold = BindConfig.Hold or false
					BindConfig.Callback = BindConfig.Callback or function() end

					local function GetBind(Key)
						if typeof(Key) == "string" then
							if Key == "" then
								return ""
							end
							if table.find({ "MouseButton1", "MouseButton2", "MouseButton3" }, Key) then
								return Enum.UserInputType[Key]
							else
								return Enum.KeyCode[Key]
							end
						end
						return Key
					end

					local Bind = { Name = BindConfig.Name, Key = GetBind(BindConfig.Default), Binding = false }
					local Holding = false
					local ClickBind = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0), ZIndex = 2 })

					local BindBox = SetChildren(
						SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),
							BackgroundTransparency = 0,
						}),
						{
							SetProps(
								MakeElement("Stroke"),
								{ Color = Color3.fromRGB(255, 255, 255), Transparency = 0, Name = "Stroke" }
							),
							AddThemeObject(
								SetProps(MakeElement("Label", "None", 14), {
									Size = UDim2.new(1, 0, 1, 0),
									Font = Enum.Font.GothamBold,
									TextXAlignment = Enum.TextXAlignment.Center,
									Name = "Value",
								}),
								"Text"
							),
							ClickBind,
						}
					)

					local BindFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 38),
								Parent = ItemParent,
								BackgroundTransparency = 0,
								Name = "Bind",
							}),
							{
								AddThemeObject(
									SetProps(MakeElement("Label", BindConfig.Name, 14), {
										Size = UDim2.new(1, -45, 1, 0),
										Position = UDim2.new(0, 12, 0, 0),
										Font = Enum.Font.GothamBold,
										Name = "Content",
										TextWrapped = true,
									}),
									"Text"
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
								BindBox,
							}
						),
						"Elements"
					)

					function Bind:Set(Key)
						Bind.Binding = false
						Bind.Value = Key or Bind.Value
						Bind.Value = Bind.Value.Name or Bind.Value
						BindBox.Value.Text = Bind.Value
					end

					AddConnection(ClickBind.InputEnded, function(Input)
						if
							Input.UserInputType == Enum.UserInputType.MouseButton1
							or Input.UserInputType == Enum.UserInputType.Touch
						then
							Bind.Binding = true
							BindBox.Value.Text = ""
						end
					end)

					AddConnection(UserInputService.InputBegan, function(Input)
						if UserInputService:GetFocusedTextBox() then
							return
						end
						if Bind.Binding then
							local Key
							pcall(function()
								if not CheckKey(BlacklistedKeys, Input.KeyCode) then
									Key = Input.KeyCode
								end
							end)
							pcall(function()
								if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
									Key = Input.UserInputType
								end
							end)
							if Input.KeyCode == Enum.KeyCode.Backspace then
								Bind:Set("")
								return
							end
							Key = Key or Bind.Value
							Bind:Set(Key)
						elseif Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
							if BindConfig.Hold then
								Holding = true
								BindConfig.Callback(Holding)
							else
								BindConfig.Callback()
							end
						end
					end)

					AddConnection(UserInputService.InputEnded, function(Input)
						if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
							if BindConfig.Hold and Holding then
								Holding = false
								BindConfig.Callback(Holding)
							end
						end
					end)

					Bind:Set(BindConfig.Default)
					table.insert(OrionLib.UIElements, Bind)
					return Bind
				end

				function ItemParent2:AddTextbox(TextboxConfig)
					TextboxConfig = TextboxConfig or {}
					TextboxConfig.Name = TextboxConfig.Name or "Textbox"
					TextboxConfig.Default = TextboxConfig.Default or ""
					TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
					TextboxConfig.Callback = TextboxConfig.Callback or function() end

					local Textbox = { Value = "", Type = "Textbox", Name = TextboxConfig.Name }
					local Click =
						SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })

					local TextboxActual = AddThemeObject(
						Create("TextBox", {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							PlaceholderColor3 = Color3.fromRGB(210, 210, 210),
							PlaceholderText = "Input",
							Font = Enum.Font.GothamSemibold,
							TextXAlignment = Enum.TextXAlignment.Center,
							TextSize = 14,
							ClearTextOnFocus = false,
						}),
						"Text"
					)

					local TextContainer = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 4), {
								Size = UDim2.new(0, 24, 0, 24),
								Position = UDim2.new(1, -12, 0.5, 0),
								AnchorPoint = Vector2.new(1, 0.5),
								BackgroundTransparency = 0,
							}),
							{
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
								TextboxActual,
							}
						),
						"Main"
					)

					local TextboxFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 38),
								Parent = ItemParent,
								BackgroundTransparency = 0,
								Name = "Textbox",
							}),
							{
								AddThemeObject(
									SetProps(MakeElement("Label", TextboxConfig.Name, 14), {
										Size = UDim2.new(1, -12, 1, 0),
										Position = UDim2.new(0, 12, 0, 0),
										Font = Enum.Font.GothamBold,
										Name = "Content",
									}),
									"Text"
								),
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
								TextContainer,
								Click,
							}
						),
						"Elements"
					)

					AddConnection(TextboxActual.FocusLost, function()
						TextboxConfig.Callback(TextboxActual.Text)
						if TextboxConfig.TextDisappear then
							TextboxActual.Text = ""
						end
					end)

					function Textbox:Set(Text)
						TextboxActual.Text = Text
					end
					TextboxActual.Text = TextboxConfig.Default
					table.insert(OrionLib.UIElements, Textbox)
					return Textbox
				end

				function ItemParent2:AddColorpicker(ColorpickerConfig)
					ColorpickerConfig = ColorpickerConfig or {}
					ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
					ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
					ColorpickerConfig.DefaultTransparency = ColorpickerConfig.DefaultTransparency or 0
					ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end

					local ColorH, ColorS, ColorV = Color3.toHSV(ColorpickerConfig.Default)
					local TransparencyColor = ColorpickerConfig.DefaultTransparency
					local Colorpicker = {
						Value = ColorpickerConfig.Default,
						TransparencyValue = ColorpickerConfig.DefaultTransparency,
						Toggled = false,
						Type = "Colorpicker",
						Name = ColorpickerConfig.Name,
					}

					local ColorSelection = Create("ImageLabel", {
						Size = UDim2.new(0, 18, 0, 18),
						ScaleType = Enum.ScaleType.Fit,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = "http://www.roblox.com/asset/?id=4805639000",
					})
					local HueSelection = Create("ImageLabel", {
						Size = UDim2.new(0, 18, 0, 18),
						ScaleType = Enum.ScaleType.Fit,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = "http://www.roblox.com/asset/?id=4805639000",
					})
					local TransparencySelection = Create("ImageLabel", {
						Size = UDim2.new(0, 18, 0, 18),
						ScaleType = Enum.ScaleType.Fit,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = "http://www.roblox.com/asset/?id=4805639000",
					})

					local Color = Create("ImageLabel", {
						Size = UDim2.new(1, -60, 1, -45),
						Visible = false,
						Image = "rbxassetid://4155801252",
					}, {
						Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
						ColorSelection,
					})

					local Hue = Create("Frame", {
						Size = UDim2.new(0, 20, 1, -45),
						Position = UDim2.new(1, -50, 0, 0),
						Visible = false,
						Name = "Hue",
					}, {
						Create("UIGradient", {
							Rotation = 270,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
								ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)),
								ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)),
								ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)),
								ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)),
								ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4)),
							}),
						}),
						Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
						HueSelection,
					})

					local Transparency = Create("ImageLabel", {
						Size = UDim2.new(0, 20, 1, -45),
						Position = UDim2.new(1, -20, 0, 0),
						Visible = false,
						Image = "rbxassetid://139785960036434",
						ScaleType = Enum.ScaleType.Tile,
						TileSize = UDim2.new(0, 5, 0, 5),
					}, {
						Create("UIGradient", {
							Rotation = 270,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
							}),
						}),
						Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
						TransparencySelection,
					})

					local ColorpickerContainer = Create("Frame", {
						Position = UDim2.new(0, -21, 0, 32),
						Size = UDim2.new(1, 45, 1, -32),
						BackgroundTransparency = 1,
						ClipsDescendants = true,
					}, {
						Hue,
						Color,
						Transparency,
						Create("UIPadding", {
							PaddingLeft = UDim.new(0, 35),
							PaddingRight = UDim.new(0, 35),
							PaddingBottom = UDim.new(0, 10),
							PaddingTop = UDim.new(0, 17),
						}),
					})

					local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

					local ColorpickerBox = SetChildren(
						SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),
						}),
						{ AddThemeObject(MakeElement("Stroke"), "Stroke") }
					)

					local ColorpickerFrame = AddThemeObject(
						SetChildren(
							SetProps(MakeElement("RoundFrame", Color3.fromRGB(15, 15, 15), 0, 6), {
								Size = UDim2.new(1, 0, 0, 38),
								Parent = ItemParent,
								BackgroundTransparency = 0,
								Name = "Colorpicker",
							}),
							{
								SetProps(
									SetChildren(MakeElement("TFrame"), {
										AddThemeObject(
											SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
												Size = UDim2.new(1, 0, 0, 38),
												Position = UDim2.new(0, 12, 0, 0),
												Font = Enum.Font.GothamBold,
												Name = "Content",
												TextWrapped = true,
											}),
											"Text"
										),
										ColorpickerBox,
										Click,
										AddThemeObject(
											SetProps(MakeElement("Frame"), {
												Size = UDim2.new(1, 0, 0, 1),
												Position = UDim2.new(0, 0, 1, -1),
												Name = "Line",
												Visible = false,
											}),
											"Stroke"
										),
									}),
									{
										Size = UDim2.new(1, 0, 0, 38),
										ClipsDescendants = true,
										Name = "F",
									}
								),
								ColorpickerContainer,
								AddThemeObject(MakeElement("Stroke"), "Stroke"),
							}
						),
						"Elements"
					)

					AddConnection(Click.MouseButton1Click, function()
						Colorpicker.Toggled = not Colorpicker.Toggled
						TweenService:Create(ColorpickerFrame, TweenInfo.new(0.15), {
							Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 200) or UDim2.new(1, 0, 0, 38),
						}):Play()
						Color.Visible = Colorpicker.Toggled
						Hue.Visible = Colorpicker.Toggled
						Transparency.Visible = Colorpicker.Toggled
						ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
					end)

					local function UpdateColorPicker(NotCallbacking)
						ColorH = ColorH >= 0 and ColorH or 0
						ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
						ColorpickerBox.BackgroundTransparency = TransparencyColor
						Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
						if NotCallbacking == nil or NotCallbacking == false then
							ColorpickerConfig.Callback(
								ColorpickerBox.BackgroundColor3,
								ColorpickerBox.BackgroundTransparency
							)
						else
							Colorpicker.Value = ColorpickerBox.BackgroundColor3
							Colorpicker.TransparencyValue = ColorpickerBox.BackgroundTransparency
						end
					end

					HueSelection.Position = UDim2.new(0.5, 0, 1 - ColorH, 0)
					ColorSelection.Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)

					AddConnection(Color.InputBegan, function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							local conn
							conn = AddConnection(RunService.RenderStepped, function()
								local ColorX = math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X)
									/ Color.AbsoluteSize.X
								local ColorY = math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y)
									/ Color.AbsoluteSize.Y
								ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
								ColorS = ColorX
								ColorV = 1 - ColorY
								UpdateColorPicker()
							end)
							Color.InputEnded:Once(function()
								if conn then
									conn:Disconnect()
								end
							end)
						end
					end)

					AddConnection(Hue.InputBegan, function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							local conn
							conn = AddConnection(RunService.RenderStepped, function()
								local HueY = math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y)
									/ Hue.AbsoluteSize.Y
								HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
								ColorH = 1 - HueY
								UpdateColorPicker()
							end)
							Hue.InputEnded:Once(function()
								if conn then
									conn:Disconnect()
								end
							end)
						end
					end)

					AddConnection(Transparency.InputBegan, function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							local conn
							conn = AddConnection(RunService.RenderStepped, function()
								local TY = math.clamp(
									Mouse.Y - Transparency.AbsolutePosition.Y,
									0,
									Transparency.AbsoluteSize.Y
								) / Transparency.AbsoluteSize.Y
								TransparencySelection.Position = UDim2.new(0.5, 0, TY, 0)
								TransparencyColor = 1 - TY
								UpdateColorPicker()
							end)
							Transparency.InputEnded:Once(function()
								if conn then
									conn:Disconnect()
								end
							end)
						end
					end)

					function Colorpicker:Set(Value, Transp, NotCallbacking)
						Colorpicker.Value = Value
						Colorpicker.TransparencyValue = Transp
						ColorpickerBox.BackgroundColor3 = Value
						ColorpickerBox.BackgroundTransparency = Transp
						if NotCallbacking == nil or NotCallbacking == false then
							ColorpickerConfig.Callback(Value, Transp)
						end
					end

					UpdateColorPicker(true)
					Colorpicker:Set(Colorpicker.Value, TransparencyColor, true)
					table.insert(OrionLib.UIElements, Colorpicker)
					return Colorpicker
				end

				return ItemParent2
			end

			AddElements(ElementFunction)
			return ElementFunction
		end

		local ElementFunction = { Type = "ElementFunction", Name = TabConfig.Name }

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig = SectionConfig or {}
			SectionConfig.Name = SectionConfig.Name or "Section"
			SectionConfig.Side = SectionConfig.Side or "Left"

			local ContainerSection = (SectionConfig.Side == "Left") and ContainerLeft or ContainerRight

			local SectionFrame = SetChildren(
				SetProps(MakeElement("TFrame"), {
					Size = UDim2.new(1, 0, 0, 10),
					Parent = ContainerSection,
				}),
				{
					AddThemeObject(
						SetProps(MakeElement("Label", SectionConfig.Name, 14), {
							Size = UDim2.new(1, -12, 0, 20),
							Position = UDim2.new(0, 0, 0, -20),
							Font = Enum.Font.GothamSemibold,
						}),
						"Text"
					),
					SetChildren(
						SetProps(MakeElement("TFrame"), {
							AnchorPoint = Vector2.new(0, 0),
							Size = UDim2.new(0.5, 0, 1, 0),
							Position = UDim2.new(0, 0, 0, 5),
							Name = "Holder",
						}),
						{
							MakeElement("List", 0, 6),
						}
					),
				}
			)

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do
				SectionFunction[i] = v
			end
			return SectionFunction
		end

		OrionLib.Tabs[TabConfig.Name] = ElementFunction
		return ElementFunction
	end

	OrionLib.Window = TabFunction
	return TabFunction
end

function OrionLib:Init()
	local Window = game.CoreGui:WaitForChild("NebulaUI", 1):WaitForChild("MainWindow", 1)
	Window.Visible = true
end

function OrionLib:Destroy()
	Orion:Destroy()
end

return OrionLib
