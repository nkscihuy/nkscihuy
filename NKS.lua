local a = {
    cache = {}::any,
}

do
    do
        local function __modImpl()
            local b = {}

            b.__index = b

            local function palette(c, d, e)
                return {
                    accent = Color3.fromRGB(unpack(c)),
                    accentTop = Color3.fromRGB(unpack(d)),
                    accentDepth = Color3.fromRGB(unpack(e)),
                    accentText = Color3.fromRGB(16, 45, 64),
                    panel = Color3.fromRGB(42, 50, 62),
                    surface = Color3.fromRGB(48, 60, 75),
                    sidebar = Color3.fromRGB(29, 38, 51),
                    inset = Color3.fromRGB(25, 35, 49),
                    outline = Color3.fromRGB(11, 16, 23),
                    text = Color3.fromRGB(237, 244, 252),
                    muted = Color3.fromRGB(165, 182, 202),
                    on = Color3.fromRGB(27, 103, 74),
                    off = Color3.fromRGB(25, 36, 50),
                    knob = Color3.fromRGB(129, 230, 172),
                    danger = Color3.fromRGB(239, 85, 81),
                    white = Color3.fromRGB(255, 255, 255),
                }
            end

            local c = {
                ['Cyan Stud'] = palette({64, 188, 240}, {123, 219, 255}, {24, 113, 155}),
                ['Gold Stud'] = palette({231, 172, 41}, {255, 224, 138}, {150, 103, 24}),
            }

            function b.new(d)
                return setmetatable({
                    name = c[d] and d or 'Cyan Stud',
                    bindings = {},
                    alive = true,
                }, b)
            end
            function b.GetName(d)
                return d.name
            end
            function b.Bind(d, e, f, g)
                if not d.alive then
                    return
                end

                assert(c[d.name][g], 'unknown theme token ' .. g)

                local h = d.bindings[e]

                if not h then
                    h = {}
                    d.bindings[e] = h
                end

                h[f] = g
                e[f] = c[d.name][g]
            end
            function b.Forget(d, e)
                d.bindings[e] = nil

                for f, g in ipairs(e:GetDescendants())do
                    d.bindings[g] = nil
                end
            end
            function b.Set(d, e)
                if not d.alive or not c[e] then
                    return false
                end

                d.name = e

                for f, g in pairs(d.bindings)do
                    for h, i in pairs(g)do
                        f[h] = c[e][i]
                    end
                end

                return true
            end
            function b.Destroy(d)
                d.alive = false

                table.clear(d.bindings)
            end

            return b
        end

        function a.a(): typeof(__modImpl())
            local b = a.cache.a

            if not b then
                b = {
                    c = __modImpl(),
                }
                a.cache.a = b
            end

            return b.c
        end
    end
    do
        local function __modImpl()
            local b = {}

            local function stack(c, d, e)
                c:Make('UIListLayout', d, {
                    Padding = UDim.new(0, e or 0),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
            end
            local function row(c, d, e, f)
                local g = c:Make('Frame', d, {
                    Name = 'Row_' .. e.Title,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, 'surface')
                local h = c:Make('Frame', g, {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 10),
                    Size = UDim2.new(1, -(f or 0) - 24, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                })

                stack(c, h, 3)
                c:Text(h, e.Title, {
                    Size = UDim2.new(1, 0, 0, 20),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextSize = 13,
                })

                local i = c:Text(h, e.Desc or '', {
                    Name = 'Description_' .. e.Title,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextSize = 11,
                }, 'muted')

                c:Make('UIPadding', g, {
                    PaddingBottom = UDim.new(0, 10),
                })

                return g, i
            end

            function b.paragraph(c, d, e)
                local f, g = row(c, d, e)

                return {
                    SetDesc = function(h, i)
                        if c.alive then
                            g.Text = i
                        end
                    end,
                }
            end
            function b.button(c, d, e)
                local f = row(c, d, e, 72)
                local g = c:Make('TextButton', f, {
                    Name = 'Button_' .. e.Title,
                    Text = 'GO',
                    Font = Enum.Font.GothamBlack,
                    TextSize = 12,
                    Size = UDim2.fromOffset(56, 30),
                    Position = UDim2.new(1, -68, 0, 11),
                    AutoButtonColor = false,
                }, 'accent')

                c.theme:Bind(g, 'TextColor3', 'accentText')
                c:Outline(g, 2)
                c:Listen(g.Activated, function()
                    if e.Callback then
                        e.Callback()
                    end
                end)

                return g
            end

            local function toggle(c, d, e)
                local f = row(c, d, e, 75)
                local g = c:Make('TextButton', f, {
                    Name = 'Toggle_' .. e.Title,
                    Text = '',
                    TextSize = 10,
                    Font = Enum.Font.GothamBlack,
                    Size = UDim2.fromOffset(62, 28),
                    Position = UDim2.new(1, -74, 0, 12),
                    AutoButtonColor = false,
                }, 'off')

                c.theme:Bind(g, 'TextColor3', 'text')
                c:Outline(g, 2)

                local h = c:Make('Frame', g, {
                    Name = 'Knob',
                    Size = UDim2.fromOffset(12, 18),
                    Position = UDim2.fromOffset(4, 5),
                }, 'muted')
                local i = c:Text(g, '', {
                    Name = 'ToggleState_' .. e.Title,
                    Position = UDim2.fromOffset(20, 0),
                    Size = UDim2.new(0, 38, 1, 0),
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextWrapped = false,
                })
                local j = e.Value == true
                local k = {}

                local function render()
                    i.Text = j and 'ON' or 'OFF'
                    i.Position = UDim2.fromOffset(j and 4 or 20, 0)

                    c.theme:Bind(g, 'BackgroundColor3', j and 'on' or 'off')
                    c.theme:Bind(h, 'BackgroundColor3', j and 'knob' or 'muted')

                    h.Position = UDim2.fromOffset(j and 46 or 4, 5)
                end

                function k.Get(l)
                    return j
                end
                function k.Set(l, m, n)
                    if not c.alive then
                        return
                    end

                    m = m == true

                    if j == m then
                        return
                    end

                    j = m

                    render()

                    if n and e.Callback then
                        e.Callback(j)
                    end
                end

                c:Listen(g.Activated, function()
                    k:Set(not j, true)
                end)
                render()

                return k
            end
            local function dropdown(c, d, e)
                local f = row(c, d, e, 184)
                local g = c:Make('TextButton', f, {
                    Name = 'Dropdown_' .. e.Title,
                    Text = '',
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Size = UDim2.fromOffset(164, 32),
                    Position = UDim2.new(1, -176, 0, 11),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    AutoButtonColor = false,
                }, 'inset')

                c.theme:Bind(g, 'TextColor3', 'text')
                c:Outline(g, 2)

                local h = e.Value
                local i = {}

                for j, k in ipairs(e.Values)do
                    i[k] = true
                end

                if not i[h] then
                    h = e.Values[1]
                end

                local j = {}

                function j.Get(k)
                    return h
                end
                function j.Set(k, l, m)
                    if not c.alive or not i[l] or h == l then
                        return
                    end

                    h = l
                    g.Text = tostring(h)

                    if m and e.Callback then
                        e.Callback(h)
                    end
                end

                g.Text = tostring(h)

                c:Make('UIPadding', g, {
                    PaddingLeft = UDim.new(0, 9),
                    PaddingRight = UDim.new(0, 26),
                })

                local k = c:Make('Frame', g, {
                    Name = 'DropdownArrow',
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 16, 0.5, 0),
                    Size = UDim2.fromOffset(10, 8),
                })

                for l, m in ipairs{
                    45,
                    -45,
                }do
                    c:Make('Frame', k, {
                        Size = UDim2.fromOffset(6, 2),
                        Position = UDim2.fromOffset((l - 1) * 4, 3),
                        Rotation = m,
                    }, 'muted')
                end

                c:Listen(g.Activated, function()
                    c:CloseOverlay()

                    c.overlay.Visible = true

                    local l = c:Make('TextButton', c.overlay, {
                        Name = 'OverlayDismiss',
                        Text = '',
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                    })
                    local m = c.viewport
                    local n, o = math.min(240, m.X - 16), math.min(260, m.Y - 16)
                    local p = g.AbsolutePosition
                    local q = math.clamp(p.X, 8, math.max(8, m.X - n - 8))
                    local r = math.clamp(p.Y + g.AbsoluteSize.Y + 4, 8, math.max(8, m.Y - o - 8))
                    local s = c:Make('ScrollingFrame', c.overlay, {
                        Name = 'DropdownOptions',
                        Position = UDim2.fromOffset(q, r),
                        Size = UDim2.fromOffset(n, o),
                        CanvasSize = UDim2.fromOffset(0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 5,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                    }, 'inset')

                    c:Outline(s, 2)
                    stack(c, s, 2)

                    local t = {}

                    local function connect(u, v)
                        local w = u:Connect(function(...)
                            if c.alive then
                                v(...)
                            end
                        end)

                        table.insert(t, w)
                    end

                    c.closeOverlay = function()
                        for u, v in ipairs(t)do
                            v:Disconnect()
                        end

                        c.theme:Forget(s)
                        s:Destroy()
                        l:Destroy()
                    end

                    connect(l.Activated, function()
                        c:CloseOverlay()
                    end)

                    for u, v in ipairs(e.Values)do
                        local w = c:Make('TextButton', s, {
                            Name = 'Option_' .. tostring(v),
                            Text = tostring(v),
                            Font = Enum.Font.GothamBold,
                            TextSize = 12,
                            Size = UDim2.new(1, -6, 0, 34),
                            AutoButtonColor = false,
                            TextWrapped = true,
                        }, v == h and 'accent' or 'surface')

                        c.theme:Bind(w, 'TextColor3', v == h and 'accentText' or 'text')
                        connect(w.Activated, function()
                            j:Set(v, true)
                            c:CloseOverlay()
                        end)
                    end
                end)

                return j
            end
            local function keybind(c, d, e)
                local f = row(c, d, e, 184)
                local g = c:Make('TextButton', f, {
                    Name = 'Keybind_' .. e.Title,
                    Text = '',
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Size = UDim2.fromOffset(164, 32),
                    Position = UDim2.new(1, -176, 0, 11),
                    AutoButtonColor = false,
                }, 'inset')

                c:Outline(g, 2)

                local h, i = e.Value, false

                local function render()
                    if not c.alive then
                        return
                    end

                    g.Text = i and 'Press a key...' or h

                    c.theme:Bind(g, 'BackgroundColor3', i and 'accent' or 'inset')
                    c.theme:Bind(g, 'TextColor3', i and 'accentText' or 'text')
                end

                local j = {}

                function j.Get(k)
                    return h
                end
                function j.Set(k, l, m)
                    if not c.alive or h == l then
                        return
                    end

                    h = l

                    render()

                    if m and e.Callback then
                        e.Callback(h)
                    end
                end

                c:Listen(g.Activated, function()
                    local k = c:BeginKeyCapture(function(k)
                        i = false

                        j:Set(k, true)
                        render()
                    end, function()
                        i = false

                        render()
                    end)

                    i = k == true

                    render()
                end)
                render()

                return j
            end
            local function slider(c, d, e)
                local f = c:Make('Frame', d, {
                    Name = 'Row_' .. e.Title,
                    Size = UDim2.new(1, 0, 0, 100),
                }, 'surface')

                c:Text(f, e.Title, {
                    Position = UDim2.fromOffset(12, 7),
                    Size = UDim2.new(1, -100, 0, 22),
                })

                local g = c:Text(f, '', {
                    Name = 'SliderValue',
                    Position = UDim2.new(1, -90, 0, 7),
                    Size = UDim2.fromOffset(76, 22),
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, 'accentTop')

                c:Text(f, e.Desc or '', {
                    Name = 'Description_' .. e.Title,
                    Position = UDim2.fromOffset(12, 32),
                    Size = UDim2.new(1, -24, 0, 30),
                    TextSize = 11,
                }, 'muted')

                local h = c:Make('Frame', f, {
                    Name = 'Slider_' .. e.Title,
                    Active = true,
                    Position = UDim2.fromOffset(12, 71),
                    Size = UDim2.new(1, -24, 0, 15),
                }, 'inset')

                c:Outline(h, 1)

                local i = c:Make('Frame', h, {
                    Name = 'Fill',
                    Size = UDim2.fromScale(0, 1),
                }, 'accent')
                local j = c:Make('Frame', h, {
                    Name = 'Knob',
                    Size = UDim2.fromOffset(12, 23),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                }, 'accentTop')

                c:Outline(j, 2)

                local function normalize(k)
                    return math.clamp(e.Min + math.floor((math.clamp(k, e.Min, e.Max) - e.Min) / e.Step + 0.5) * e.Step, e.Min, e.Max)
                end

                local k = normalize(e.Value)

                local function render()
                    local l = (k - e.Min) / (e.Max - e.Min)

                    i.Size = UDim2.fromScale(l, 1)
                    j.Position = UDim2.fromScale(l, 0.5)

                    local m = 0

                    while m < 6 and math.abs(e.Step * 10 ^ m - math.round(e.Step * 10 ^ m)) > 0.000001 do
                        m += 1
                    end

                    g.Text = string.format('%.' .. m .. 'f', k)
                end

                local l = {}

                function l.Get(m)
                    return k
                end
                function l.Set(m, n, o)
                    if not c.alive or type(n) ~= 'number' or n ~= n then
                        return
                    end

                    local p = normalize(n)

                    if math.abs(p - k) < 0.000001 then
                        return
                    end

                    k = p

                    render()

                    if o and e.Callback then
                        e.Callback(k)
                    end
                end

                c:Listen(h.InputBegan, function(m)
                    if m.UserInputType ~= Enum.UserInputType.MouseButton1 and m.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    local function move(n)
                        local o = math.clamp((n.Position.X - h.AbsolutePosition.X) / math.max(1, h.AbsoluteSize.X), 0, 1)

                        l:Set(e.Min + o * (e.Max - e.Min), true)
                    end

                    move(m)
                    c:Capture(m, move)
                end)
                render()

                return l
            end

            function b.section(c, d, e)
                local f = c:Make('Frame', d, {
                    Name = 'Section_' .. e.Title,
                    Size = UDim2.new(1, -4, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, 'inset')

                c:Outline(f, 2)
                stack(c, f, 1)

                local g = c:Make('Frame', f, {
                    Size = UDim2.new(1, 0, 0, 34),
                }, 'sidebar')

                c:Make('Frame', g, {
                    Position = UDim2.fromOffset(12, 11),
                    Size = UDim2.fromOffset(4, 12),
                }, 'accent')
                c:Text(g, string.upper(e.Title), {
                    Position = UDim2.fromOffset(24, 0),
                    Size = UDim2.new(1, -36, 1, 0),
                    TextSize = 11,
                })

                local h = {}

                function h.Paragraph(i, j)
                    return b.paragraph(c, f, j)
                end
                function h.Button(i, j)
                    return b.button(c, f, j)
                end
                function h.Toggle(i, j)
                    return toggle(c, f, j)
                end
                function h.Dropdown(i, j)
                    return dropdown(c, f, j)
                end
                function h.Keybind(i, j)
                    return keybind(c, f, j)
                end
                function h.Slider(i, j)
                    return slider(c, f, j)
                end

                return h
            end

            return b
        end

        function a.b(): typeof(__modImpl())
            local b = a.cache.b

            if not b then
                b = {
                    c = __modImpl(),
                }
                a.cache.b = b
            end

            return b.c
        end
    end
    do
        local function __modImpl()
            local b = a.a()
            local c = {}

            c.__index = c

            local function pointer(d)
                return d.UserInputType == Enum.UserInputType.MouseButton1 or d.UserInputType == Enum.UserInputType.Touch
            end

            function c.new(d)
                d = d or {}

                local e = setmetatable({
                    alive = true,
                    connections = {},
                    tabs = {},
                    floatingEnabled = true,
                    visible = not d.ShowFreeNotice,
                    consumedKeys = setmetatable({}, {
                        __mode = 'k',
                    }),
                    key = d.ToggleKey or Enum.KeyCode.RightShift,
                    theme = b.new(d.Theme),
                }, c)

                e.input = game:GetService'UserInputService'
                e.world = game:GetService'Workspace'

                local f = d.Parent

                if not f then
                    local g, h = pcall(function()
                        return game:GetService'CoreGui'
                    end)

                    if g then
                        f = h
                    end
                end

                local g = Instance.new'ScreenGui'

                g.Name = 'NKS_StudUI'
                g.ResetOnSpawn = false
                g.IgnoreGuiInset = true
                g.DisplayOrder = 100
                g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

                local h = pcall(function()
                    g.Parent = f
                end)

                if not h or not f then
                    g.Parent = game:GetService'Players'.LocalPlayer:FindFirstChildOfClass'PlayerGui'
                end

                e.gui = g
                e.panel = e:Make('Frame', g, {
                    Name = 'Panel',
                    Size = UDim2.fromOffset(820, 560),
                    Visible = e.visible,
                }, 'panel')

                e:Outline(e.panel, 3)

                e.scale = e:Make('UIScale', e.panel, {
                    Name = 'WindowScale',
                    Scale = 1,
                })
                e.header = e:Make('Frame', e.panel, {
                    Name = 'Header',
                    Size = UDim2.new(1, 0, 0, 72),
                    Active = true,
                }, 'accent')

                e:Studs(e.header, 31)
                e:Make('Frame', e.header, {
                    Name = 'Lip',
                    Position = UDim2.new(0, 0, 1, -7),
                    Size = UDim2.new(1, 0, 0, 7),
                }, 'accentDepth')
                e:Text(e.header, 'NKS', {
                    Name = 'Brand',
                    Position = UDim2.fromOffset(20, 5),
                    Size = UDim2.fromOffset(100, 54),
                    TextSize = 40,
                    Font = Enum.Font.GothamBlack,
                    TextStrokeTransparency = 0.2,
                })
                e:Text(e.header, 'EVADE / UTILITY\nSTUD EDITION', {
                    Position = UDim2.fromOffset(123, 15),
                    Size = UDim2.fromOffset(230, 40),
                    TextSize = 12,
                }, 'accentText')

                local function headerButton(i, j, k, l)
                    local m = e:Make('TextButton', e.header, {
                        Name = i,
                        Text = '',
                        Size = UDim2.new(0, 46, 1, 0),
                        Position = UDim2.new(1, j, 0, 0),
                        AutoButtonColor = false,
                    }, k)

                    e:Make('Frame', m, {
                        Name = 'ButtonLip',
                        Position = UDim2.new(0, 0, 1, -7),
                        Size = UDim2.new(1, 0, 0, 7),
                        BackgroundTransparency = 0.78,
                    }, 'outline')
                    e:Make('Frame', m, {
                        Name = 'ButtonRim',
                        Size = UDim2.new(1, 0, 0, 2),
                        BackgroundTransparency = 0.65,
                    }, 'white')

                    local n = e:Make('Frame', m, {
                        Name = 'Icon',
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, -3),
                        Size = UDim2.fromOffset(16, 16),
                    })

                    if i == 'ThemeCycle' then
                        local o = e:Make('Frame', n, {
                            Size = UDim2.fromOffset(14, 14),
                            Position = UDim2.fromOffset(1, 1),
                        }, 'white')

                        e:Outline(o, 1)
                        e:Make('Frame', o, {
                            Size = UDim2.new(0.5, 0, 1, 0),
                        }, 'accentText')
                    else
                        local o = e:Make('Frame', n, {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(14, 3),
                            Rotation = i == 'Close' and 45 or 0,
                        }, 'white')

                        if i == 'Close' then
                            e:Make('Frame', n, {
                                AnchorPoint = o.AnchorPoint,
                                Position = o.Position,
                                Size = o.Size,
                                Rotation = -45,
                            }, 'white')
                        end
                    end

                    e.theme:Bind(m, 'TextColor3', 'white')
                    e:Outline(m, 2)
                    e:Listen(m.Activated, l)

                    return m
                end

                headerButton('ThemeCycle', -138, 'accentDepth', function()
                    if e.themeCycle then
                        e.themeCycle()
                    end
                end)
                headerButton('Minimize', -92, 'accentDepth', function()
                    e:SetVisible(false)
                end)
                headerButton('Close', -46, 'danger', function()
                    e:SetVisible(false)
                end)

                e.sidebar = e:Make('Frame', e.panel, {
                    Name = 'Sidebar',
                    Position = UDim2.fromOffset(0, 72),
                    Size = UDim2.new(0, 172, 1, -104),
                }, 'sidebar')

                e:Text(e.sidebar, 'YOUR WORKSPACE', {
                    Position = UDim2.fromOffset(17, 14),
                    Size = UDim2.fromOffset(140, 20),
                    TextSize = 10,
                }, 'muted')
                e:Text(e.sidebar, game:GetService'Players'.LocalPlayer.Name, {
                    Position = UDim2.new(0, 17, 1, -65),
                    Size = UDim2.fromOffset(140, 20),
                    TextSize = 12,
                })

                e.keyLabel = e:Text(e.sidebar, '', {
                    Position = UDim2.new(0, 17, 1, -42),
                    Size = UDim2.fromOffset(145, 32),
                    TextSize = 10,
                }, 'muted')
                e.content = e:Make('Frame', e.panel, {
                    Name = 'Content',
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(172, 72),
                    Size = UDim2.new(1, -172, 1, -104),
                })
                e.statusBar = e:Make('Frame', e.panel, {
                    Name = 'StatusBar',
                    Position = UDim2.new(0, 0, 1, -32),
                    Size = UDim2.new(1, 0, 0, 32),
                }, 'inset')
                e.statusLabel = e:Text(e.statusBar, 'Ready \u{b7} all features off', {
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    TextSize = 11,
                }, 'muted')
                e.floating = e:Make('TextButton', g, {
                    Name = 'FloatingN',
                    Text = 'N',
                    Font = Enum.Font.GothamBlack,
                    TextSize = 26,
                    Size = UDim2.fromOffset(48, 48),
                    Position = UDim2.fromOffset(20, 180),
                    Visible = false,
                    AutoButtonColor = false,
                }, 'accent')

                e.theme:Bind(e.floating, 'TextColor3', 'white')
                e:Outline(e.floating, 3)

                e.overlay = e:Make('Frame', g, {
                    Name = 'Overlay',
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    ZIndex = 20,
                    Visible = false,
                })

                e:Listen(e.floating.Activated, function()
                    if not e.suppressFloatingClick then
                        e:SetVisible(true)
                    end
                end)
                e:Listen(e.header.InputBegan, function(i)
                    e:BeginDrag(i, e.panel)
                end)
                e:Listen(e.floating.InputBegan, function(i)
                    e:BeginDrag(i, e.floating)
                end)
                e:Listen(e.input.InputBegan, function(i, j)
                    local k = e:ShouldSuppressShortcut(i)

                    if e.keyCapture then
                        if i.UserInputType ~= Enum.UserInputType.Keyboard then
                            return
                        end
                        if i.KeyCode == Enum.KeyCode.Escape then
                            e:CancelKeyCapture()

                            return
                        end
                        if j or e.input:GetFocusedTextBox() or i.KeyCode == Enum.KeyCode.Unknown then
                            return
                        end

                        local l = e.keyCapture

                        e.keyCapture = nil

                        l.onKey(i.KeyCode.Name)

                        return
                    end
                    if k then
                        return
                    end
                    if j or e.input:GetFocusedTextBox() then
                        return
                    end
                    if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == e.key then
                        e:SetVisible(not e.visible)
                    end
                end)
                e:Listen(e.input.InputChanged, function(i)
                    if e.capture then
                        if i == e.capture.input or (e.capture.input.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement) then
                            e.capture.move(i)
                        end
                    end
                end)
                e:Listen(e.input.InputEnded, function(i)
                    e.consumedKeys[i] = nil

                    if e.capture and (i == e.capture.input or (i.UserInputType == Enum.UserInputType.MouseButton1 and e.capture.input.UserInputType == Enum.UserInputType.MouseButton1)) then
                        local j = e.capture.finish

                        e.capture = nil

                        if j then
                            j()
                        end
                    end
                end)
                e:Listen(e.input.WindowFocusReleased, function()
                    e:CancelKeyCapture()
                end)
                e:Listen(e.world:GetPropertyChangedSignal'CurrentCamera', function(
                )
                    e:BindCamera()
                end)
                if d.ShowFreeNotice then
                    local notice = e:Make('Frame', g, {
                        Name = 'FreeNotice',
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.new(1, -32, 0, 180),
                    }, 'panel')
                    e.notice = notice
                    e:Make('UISizeConstraint', notice, { MaxSize = Vector2.new(400, 180) })
                    e:Outline(notice, 3)

                    local header = e:Make('Frame', notice, {
                        Size = UDim2.new(1, 0, 0, 44),
                    }, 'accent')
                    e:Studs(header, 9)
                    e:Text(header, 'NKS INI GRATIS', {
                        Position = UDim2.fromOffset(14, 0),
                        Size = UDim2.new(1, -28, 1, 0),
                        Font = Enum.Font.GothamBlack,
                        TextSize = 19,
                    }, 'accentText')
                    e:Text(notice, 'Script ini dibagikan gratis. Kalau ada yang minta bayaran buat akses NKS, jangan bayar.', {
                        Position = UDim2.fromOffset(14, 50),
                        Size = UDim2.new(1, -28, 0, 64),
                    })
                    local continueButton = e:Make('TextButton', notice, {
                        Name = 'Continue',
                        Text = 'Lanjut ke menu',
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        Position = UDim2.fromOffset(14, 122),
                        Size = UDim2.new(1, -28, 0, 44),
                    }, 'accent')
                    e.theme:Bind(continueButton, 'TextColor3', 'accentText')
                    e:Outline(continueButton, 2)
                    e:Listen(continueButton.Activated, function()
                        e.notice = nil
                        e.theme:Forget(notice)
                        notice:Destroy()
                        e:SetVisible(true)
                    end)
                end

                e:SetToggleKey(e.key)
                e:BindCamera()

                return e
            end
            function c.Listen(d, e, f)
                local g = e:Connect(function(...)
                    if d.alive then
                        f(...)
                    end
                end)

                table.insert(d.connections, g)

                return g
            end
            function c.Make(d, e, f, g, h)
                local i = Instance.new(e)

                if i:IsA'GuiObject' then
                    i.BorderSizePixel = 0
                end

                for j, k in pairs(g or {})do
                    i[j] = k
                end

                if h then
                    d.theme:Bind(i, 'BackgroundColor3', h)
                end

                i.Parent = f

                return i
            end
            function c.Text(d, e, f, g, h)
                local i = {
                    Text = f,
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextWrapped = true,
                }

                for j, k in pairs(g or {})do
                    i[j] = k
                end

                local j = d:Make('TextLabel', e, i)

                d.theme:Bind(j, 'TextColor3', h or 'text')

                return j
            end
            function c.Outline(d, e, f)
                local g = d:Make('UIStroke', e, {
                    Thickness = f or 2,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                })

                d.theme:Bind(g, 'Color', 'outline')
            end
            function c.Studs(d, e, f)
                for g = 0, f - 1 do
                    local h = d:Make('Frame', e, {
                        Name = 'Stud',
                        Position = UDim2.fromOffset(12 + g * 24, 8),
                        Size = UDim2.fromOffset(9, 9),
                        BackgroundTransparency = 0.82,
                    }, 'white')

                    d:Make('UICorner', h, {
                        CornerRadius = UDim.new(1, 0),
                    })
                end
            end
            function c.BindCamera(d)
                if d.cameraConnection then
                    d.cameraConnection:Disconnect()
                end

                local e = d.world.CurrentCamera

                d.camera = e

                if e then
                    d.cameraConnection = d:Listen(e:GetPropertyChangedSignal'ViewportSize', function(
                    )
                        d:Fit()
                    end)
                end

                d:Fit()
            end
            function c.Fit(d)
                local e = d.camera and d.camera.ViewportSize or Vector2.new(1280, 720)

                d.viewport = e
                d.scale.Scale = math.min(1, math.max(0.1, (e.X - 24) / 820), math.max(0.1, (e.Y - 24) / 560))

                if not d.positioned then
                    d.panel.Position = UDim2.fromOffset(math.max(0, (e.X - 820 * d.scale.Scale) / 2), math.max(0, (e.Y - 560 * d.scale.Scale) / 2))
                    d.positioned = true
                end

                d:Clamp(d.panel)
                d:Clamp(d.floating)

                if d.notification then
                    d.notification.Size = UDim2.fromOffset(math.min(272, math.max(1, e.X - 24)), 0)
                end

                d:CloseOverlay()
            end
            function c.Clamp(d, e)
                local f = d.viewport
                local g = e.Position
                local h = e == d.panel and 820 * d.scale.Scale or 48
                local i = e == d.panel and 560 * d.scale.Scale or 48

                e.Position = UDim2.fromOffset(math.clamp(g.X.Offset, 0, math.max(0, f.X - h)), math.clamp(g.Y.Offset, 0, math.max(0, f.Y - i)))
            end
            function c.Capture(d, e, f, g)
                d.capture = {
                    input = e,
                    move = f,
                    finish = g,
                }
            end
            function c.ShouldSuppressShortcut(d, e)
                if d.keyCapture then
                    d.consumedKeys[e] = true
                end

                return d.notice ~= nil or d.keyCapture ~= nil or d.consumedKeys[e] == true
            end
            function c.BeginKeyCapture(d, e, f)
                if not d.alive or not d.visible then
                    return false
                end

                d:CancelKeyCapture()
                d:CloseOverlay()

                d.keyCapture = {
                    onKey = e,
                    onCancel = f,
                }

                return true
            end
            function c.CancelKeyCapture(d)
                local e = d.keyCapture

                d.keyCapture = nil

                if e then
                    e.onCancel()
                end
            end
            function c.BeginDrag(d, e, f)
                if not pointer(e) then
                    return
                end

                local g, h, i = e.Position, f.Position, false

                d.suppressFloatingClick = false

                d:CloseOverlay()
                d:Capture(e, function(j)
                    local k = j.Position - g

                    if math.abs(k.X) + math.abs(k.Y) > 5 then
                        i = true
                    end

                    f.Position = UDim2.fromOffset(h.X.Offset + k.X, h.Y.Offset + k.Y)

                    d:Clamp(f)
                end, function()
                    if i and f == d.floating then
                        d.suppressFloatingClick = true

                        task.delay(0.15, function()
                            if d.alive then
                                d.suppressFloatingClick = false
                            end
                        end)
                    end
                end)
            end
            function c.CloseOverlay(d)
                if d.closeOverlay then
                    local e = d.closeOverlay

                    d.closeOverlay = nil

                    e()
                end

                d.overlay.Visible = false
            end
            function c.Tab(d, e)
                local f = {
                    window = d,
                    title = e.Title,
                }
                local g = #d.tabs

                f.button = d:Make('TextButton', d.sidebar, {
                    Name = 'Tab_' .. f.title,
                    Text = f.title,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    Position = UDim2.fromOffset(12, 48 + g * 53),
                    Size = UDim2.fromOffset(148, 42),
                    AutoButtonColor = false,
                }, 'surface')

                d.theme:Bind(f.button, 'TextColor3', 'text')
                d:Outline(f.button, 2)

                f.page = d:Make('ScrollingFrame', d.content, {
                    Name = 'Page_' .. f.title,
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Visible = false,
                    CanvasSize = UDim2.fromOffset(0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 5,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                })

                d.theme:Bind(f.page, 'ScrollBarImageColor3', 'accent')
                d:Make('UIPadding', f.page, {
                    PaddingTop = UDim.new(0, 18),
                    PaddingBottom = UDim.new(0, 18),
                    PaddingLeft = UDim.new(0, 20),
                    PaddingRight = UDim.new(0, 20),
                })
                d:Make('UIListLayout', f.page, {
                    Padding = UDim.new(0, 14),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                d:Text(f.page, e.Title, {
                    Size = UDim2.new(1, -8, 0, 32),
                    TextSize = 24,
                    Font = Enum.Font.GothamBlack,
                })

                function f.Select(h)
                    if not h.window.alive then
                        return
                    end

                    h.window:CancelKeyCapture()
                    h.window:CloseOverlay()

                    for i, j in ipairs(h.window.tabs)do
                        local k = h == j

                        j.page.Visible = k

                        h.window.theme:Bind(j.button, 'BackgroundColor3', k and 'accent' or 'surface')
                        h.window.theme:Bind(j.button, 'TextColor3', k and 'accentText' or 'text')
                    end
                end

                d:Listen(f.button.Activated, function()
                    f:Select()
                end)
                table.insert(d.tabs, f)

                function f.Section(h, i)
                    return a.b().section(h.window, h.page, i)
                end
                function f.Paragraph(h, i)
                    return a.b().paragraph(h.window, h.page, i)
                end
                function f.Button(h, i)
                    return a.b().button(h.window, h.page, i)
                end
                function f.Space(h) end

                return f
            end
            function c.SetTheme(d, e)
                if not d.theme:Set(e) then
                    return false
                end
                if d.themeChanged then
                    d.themeChanged(e)
                end

                return true
            end
            function c.GetTheme(d)
                return d.theme:GetName()
            end
            function c.SetThemeChanged(d, e)
                d.themeChanged = e
            end
            function c.SetThemeCycle(d, e)
                d.themeCycle = e
            end
            function c.SetToggleKey(d, e)
                d.key = e
                d.keyLabel.Text = e.Name .. ' \u{b7} Show / hide'
            end
            function c.SetVisible(d, e)
                if not d.alive or d.notice then
                    return
                end

                d:CancelKeyCapture()

                d.visible = e == true
                d.panel.Visible = d.visible
                d.floating.Visible = d.floatingEnabled and not d.visible
                d.capture = nil

                d:CloseOverlay()
            end
            function c.SetFloatingButton(d, e)
                d.floatingEnabled = e == true
                d.floating.Visible = not d.notice and d.floatingEnabled and not d.visible
            end
            function c.SetTransparency(d, e)
                d.panel.BackgroundTransparency = e and 0.22 or 0
            end
            function c.SetStatus(d, e)
                if d.alive then
                    d.statusLabel.Text = e
                end
            end
            function c.Notify(d, e)
                if not d.alive then
                    return
                end
                if d.notification then
                    d.theme:Forget(d.notification)
                    d.notification:Destroy()
                end

                local f = math.min(272, math.max(1, d.viewport.X - 24))
                local g = d:Make('Frame', d.gui, {
                    Name = 'Notification',
                    AnchorPoint = Vector2.new(1, 1),
                    Position = UDim2.new(1, -12, 1, -12),
                    Size = UDim2.fromOffset(f, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 30,
                }, 'surface')
                local h = d:Make('UIStroke', g, {
                    Name = 'NotificationAccent',
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                })

                d.theme:Bind(h, 'Color', 'accent')
                d:Make('UIPadding', g, {
                    PaddingTop = UDim.new(0, 9),
                    PaddingBottom = UDim.new(0, 9),
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                })
                d:Make('UIListLayout', g, {
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                d:Text(g, e.Title or 'NKS', {
                    Name = 'NotificationTitle',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextSize = 12,
                    LayoutOrder = 1,
                })
                d:Text(g, e.Content or '', {
                    Name = 'NotificationBody',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextSize = 11,
                    LayoutOrder = 2,
                }, 'muted')

                d.notification = g

                task.delay(e.Duration or 3, function()
                    if not d.alive or d.notification ~= g then
                        return
                    end

                    d.theme:Forget(g)
                    g:Destroy()

                    d.notification = nil
                end)
            end
            function c.Destroy(d)
                if not d.alive then
                    return
                end

                d:CancelKeyCapture()

                d.alive = false
                d.capture = nil

                d:CloseOverlay()

                for e, f in ipairs(d.connections)do
                    f:Disconnect()
                end

                table.clear(d.connections)
                d.theme:Destroy()
                d.gui:Destroy()

                d.themeChanged = nil
                d.themeCycle = nil
            end

            return c
        end

        function a.c(): typeof(__modImpl())
            local b = a.cache.c

            if not b then
                b = {
                    c = __modImpl(),
                }
                a.cache.c = b
            end

            return b.c
        end
    end
    do
        local function __modImpl()
            local b = {}

            b.__index = b

            local function disconnect(c)
                for d, e in ipairs(c)do
                    e:Disconnect()
                end

                table.clear(c)
            end
            local function watchChildren(c, d, e)
                local f = {}

                local function added(g)
                    if not f[g] then
                        f[g] = g:GetPropertyChangedSignal'Name':Connect(d)
                    end

                    d()
                end

                table.insert(e, c.ChildAdded:Connect(added))
                table.insert(e, c.ChildRemoved:Connect(function(g)
                    if f[g] then
                        f[g]:Disconnect()

                        f[g] = nil
                    end

                    d()
                end))
                table.insert(e, {
                    Disconnect = function()
                        for g, h in pairs(f)do
                            h:Disconnect()
                        end

                        table.clear(f)
                    end,
                })

                for g, h in ipairs(c:GetChildren())do
                    added(h)
                end

                d()
            end

            function b.new(c)
                return setmetatable({
                    world = c,
                    alive = true,
                    enabled = false,
                    color = Color3.fromRGB(64, 188, 240),
                    transparency = 0.5,
                    originals = {},
                    worldConnections = {},
                    mapConnections = {},
                    folderConnections = {},
                }, b)
            end
            function b.IsTarget(c, d)
                return c.alive and c.enabled and c.map ~= nil and c.folder ~= nil and c.world:FindFirstChild'Map' == c.map and c.map.Parent == c.world and c.map.Name == 'Map' and c.map:FindFirstChild'InvisParts' == c.folder and c.folder.Parent == c.map and c.folder.Name == 'InvisParts' and d:IsDescendantOf(c.folder)
            end
            function b.Apply(c, d)
                if not c:IsTarget(d) then
                    c:Release(d)

                    return
                end

                d.Color = c.color
                d.Transparency = c.transparency
                d.LocalTransparencyModifier = 0
            end
            function b.Add(c, d)
                if not d:IsA'BasePart' or not c:IsTarget(d) or c.originals[d] then
                    return
                end

                c.originals[d] = {
                    Color = d.Color,
                    Transparency = d.Transparency,
                    LocalTransparencyModifier = d.LocalTransparencyModifier,
                }

                c:Apply(d)
            end
            function b.Release(c, d)
                local e = c.originals[d]

                if not e then
                    return
                end

                c.originals[d] = nil

                pcall(function()
                    d.Color = e.Color
                    d.Transparency = e.Transparency
                    d.LocalTransparencyModifier = e.LocalTransparencyModifier
                end)
            end
            function b.BindFolder(c, d)
                if c.folder == d then
                    return
                end

                disconnect(c.folderConnections)

                for e in pairs(c.originals)do
                    c:Release(e)
                end

                c.folder = d

                if not d then
                    return
                end

                table.insert(c.folderConnections, d.DescendantAdded:Connect(function(
                    e
                )
                    if c.folder == d then
                        c:Add(e)
                    end
                end))
                table.insert(c.folderConnections, d.DescendantRemoving:Connect(function(
                    e
                )
                    c:Release(e)
                end))

                for e, f in ipairs(d:GetDescendants())do
                    c:Add(f)
                end
            end
            function b.BindMap(c, d)
                if c.map == d then
                    return
                end

                c:BindFolder(nil)
                disconnect(c.mapConnections)

                c.map = d

                if not d then
                    return
                end

                local function refresh()
                    c:BindFolder(d:FindFirstChild'InvisParts')
                end

                watchChildren(d, refresh, c.mapConnections)
            end
            function b.SetEnabled(c, d)
                if not c.alive or c.enabled == (d == true) then
                    return
                end

                c.enabled = d == true

                if c.enabled then
                    local function refresh()
                        c:BindMap(c.world:FindFirstChild'Map')
                    end

                    watchChildren(c.world, refresh, c.worldConnections)
                else
                    disconnect(c.worldConnections)
                    c:BindMap(nil)
                end
            end
            function b.SetAppearance(c, d, e)
                if not c.alive then
                    return
                end

                c.color = d
                c.transparency = math.clamp(e, 0, 1)

                for f in pairs(c.originals)do
                    c:Apply(f)
                end
            end
            function b.Destroy(c)
                if not c.alive then
                    return
                end

                c:SetEnabled(false)

                c.alive = false
            end

            return b
        end

        function a.d(): typeof(__modImpl())
            local b = a.cache.d

            if not b then
                b = {
                    c = __modImpl(),
                }
                a.cache.d = b
            end

            return b.c
        end
    end
end

local b = game:GetService'Players'
local c = game:GetService'RunService'
local d = game:GetService'UserInputService'
local e = game:GetService'Lighting'
local f = game:GetService'VirtualUser'
local g = game:GetService'ReplicatedStorage'
local h = b.LocalPlayer
local i = require(g.Services.Data.ServerStateRegistryService)
local j = g.Remotes.Admin.Command

if _G.NKSCleanup then
    pcall(_G.NKSCleanup)
end

local k = {
    playtimeTwoMinutes = false,
    skipIntermission = false,
    skipVote = false,
    autoEvent = false,
    antiNextbot = false,
    antiAfk = false,
    skyFarm = false,
    fullBright = false,
    noclip = false,
    streakGuard = false,
    showInvisWalls = false,
}
local l = {
    roundCommand = '!time 1',
    specialRound = nil,
    roundCheckInterval = 0.25,
    roundRetryInterval = 2,
    activeRoundTimeTrigger = 60,
    skyHeight = 1000,
    skyRadius = 100,
    windowKey = 'RightShift',
    noclipKey = 'RightAlt',
    showFloatingButton = true,
    skySpeed = 0.8,
    nextbotRange = 100,
    eventInterval = 0.12,
    wallRed = 64,
    wallGreen = 188,
    wallBlue = 240,
    wallTransparency = 0.5,
}
local m = {
    alive = true,
    connections = {},
    savedCFrame = nil,
    orbitCenter = nil,
    orbitAngle = 0,
    orbitStarted = false,
    originalLighting = nil,
    eventClock = 0,
    avoidClock = 0,
    roundClock = 0,
    roundPhase = nil,
    roundCommandSent = false,
    specialRoundSent = false,
    lastRoundAttempt = -math.huge,
    roundCommandCount = 0,
    lastRoundStatus = nil,
    activeRoundCommandSent = false,
    lastCommandPhase = nil,
    noclipParts = {},
    noclipCharacter = nil,
    noclipConnections = {},
    childCaches = {},
    overviewClock = 0,
}

local function connect(n, o)
    local p = n:Connect(o)

    m.connections[#m.connections + 1] = p

    return p
end
local function getRoot()
    local n = h.Character

    return n and n:FindFirstChild'HumanoidRootPart'
end
local function zeroVelocity(n)
    n.AssemblyLinearVelocity = Vector3.zero
    n.AssemblyAngularVelocity = Vector3.zero
end
local function clearChildCaches()
    for n, o in pairs(m.childCaches)do
        for p, q in ipairs(o.connections)do
            q:Disconnect()
        end
    end

    table.clear(m.childCaches)
end
local function releaseChildCache(n)
    local o = m.childCaches[n]

    if not o then
        return
    end

    for p, q in ipairs(o.connections)do
        q:Disconnect()
    end

    m.childCaches[n] = nil
end
local function cachedChildren(n, o)
    local p = m.childCaches[n]

    if p and p.folder == o then
        return p.items
    end
    if p then
        for q, r in ipairs(p.connections)do
            r:Disconnect()
        end
    end

    p = {
        folder = o,
        items = {},
        connections = {},
    }
    m.childCaches[n] = p

    if not o then
        return p.items
    end

    p.connections[1] = o.ChildAdded:Connect(function(q)
        p.items[q] = true
    end)
    p.connections[2] = o.ChildRemoved:Connect(function(q)
        p.items[q] = nil
    end)

    for q, r in ipairs(o:GetChildren())do
        p.items[r] = true
    end

    return p.items
end
local function restoreNoclip()
    for n, o in ipairs(m.noclipConnections)do
        o:Disconnect()
    end

    table.clear(m.noclipConnections)

    for n, o in pairs(m.noclipParts)do
        pcall(function()
            n.CanCollide = o
        end)
    end

    table.clear(m.noclipParts)

    m.noclipCharacter = nil
end
local function applyNoclip()
    local n = h.Character

    if n ~= m.noclipCharacter then
        restoreNoclip()

        m.noclipCharacter = n

        if n then
            local function capture(o)
                if o:IsA'BasePart' and m.noclipParts[o] == nil then
                    m.noclipParts[o] = o.CanCollide
                end
            end

            m.noclipConnections[1] = n.DescendantAdded:Connect(capture)
            m.noclipConnections[2] = n.DescendantRemoving:Connect(function(o)
                local p = m.noclipParts[o]

                if p ~= nil then
                    pcall(function()
                        o.CanCollide = p
                    end)

                    m.noclipParts[o] = nil
                end
            end)

            for o, p in ipairs(n:GetDescendants())do
                capture(p)
            end
        end
    end
    if not n then
        return
    end

    for o in pairs(m.noclipParts)do
        if o.CanCollide then
            o.CanCollide = false
        end
    end
end

local n = a.c()
local o = a.d()
local p = o.new(workspace)
local q = {
    'None',
}
local r = g.Info:FindFirstChild'SpecialRounds'

if r then
    for s, t in ipairs(r:GetChildren())do
        if t:IsA'ModuleScript' then
            q[#q + 1] = t.Name
        end
    end

    table.sort(q, function(s, t)
        if s == 'None' then
            return true
        end
        if t == 'None' then
            return false
        end

        return string.lower(s) < string.lower(t)
    end)
end

local s = n.new{
    Title = 'NKS  /  Evade',
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = 'Cyan Stud',
    ShowFreeNotice = true,
}
local t = {
    Dashboard = s:Tab{
        Title = 'Overview',
        Desc = 'Session at a glance',
        Icon = 'layout-dashboard',
    },
    Farming = s:Tab{
        Title = 'Farming',
        Desc = 'Round control, tokens, orbit and idle protection',
        Icon = 'repeat-2',
    },
    Survival = s:Tab{
        Title = 'Survival',
        Desc = 'Movement and visibility',
        Icon = 'shield',
    },
    Settings = s:Tab{
        Title = 'Settings',
        Desc = 'Appearance and shortcuts',
        Icon = 'settings',
    },
}

local function characterState()
    local u = h.Character
    local v = u and u:FindFirstChild'HumanoidRootPart'
    local w = u and u:FindFirstChildOfClass'Humanoid'

    if not u then
        return 'Not spawned'
    end
    if not v then
        return 'Lobby placeholder'
    end
    if w then
        return string.format('Playable \u{b7} %.0f HP', w.Health)
    end

    return 'Playable'
end
local function nextbotCount()
    local u = workspace:FindFirstChild'Players'
    local v = 0

    for w in pairs(cachedChildren('nextbots', u))do
        if w:GetAttribute'AI' == true then
            v += 1
        end
    end

    return v
end

t.Dashboard:Paragraph{
    Title = h.Name .. '  /  ' .. game.Name,
    Desc = string.format('Connected client\nPlace %s \u{b7} Job %s', tostring(game.PlaceId), tostring(game.JobId):sub(1, 8)),
    Icon = 'user-round-check',
}

local u = t.Dashboard:Paragraph{
    Title = 'System activity',
    Desc = 'Ready \u{b7} All features are off',
    Icon = 'activity',
}
local v = t.Dashboard:Paragraph{
    Title = 'Live session',
    Desc = 'Character: ' .. characterState() .. '\nNextbots detected: ' .. tostring(nextbotCount()),
    Icon = 'radar',
}
local w = t.Dashboard:Paragraph{
    Title = 'Active systems',
    Desc = 'All features are off',
    Icon = 'layers',
}
local x = {
    {
        'playtimeTwoMinutes',
        'Playtime 2 Minutes',
    },
    {
        'skipIntermission',
        'Skip Intermission',
    },
    {
        'skipVote',
        'Skip Vote',
    },
    {
        'autoEvent',
        'Farm Token',
    },
    {
        'antiAfk',
        'Anti AFK',
    },
    {
        'antiNextbot',
        'Anti NextBots',
    },
    {
        'noclip',
        'Noclip',
    },
    {
        'streakGuard',
        'Streak Guard',
    },
    {
        'fullBright',
        'FullBright',
    },
    {
        'skyFarm',
        'Sky Orbit',
    },
    {
        'showInvisWalls',
        'Show Invis Walls',
    },
}

local function refreshOverview()
    local y = i:Get'RoundStatus' or 0
    local z = i:Get'Time' or 0
    local A = i:Get'Voting' == true and 'Map voting' or (i:Get'MapLoading' == true and 'Loading map') or (y == 2 and 'In round') or (y == 1 and 'Intermission') or 'Waiting'
    local B = characterState() .. '\n' .. A .. ' \u{b7} ' .. tostring(math.floor(z)) .. 's remaining\nNextbots \u{b7} ' .. tostring(nextbotCount())

    if B ~= m.lastSnapshot then
        m.lastSnapshot = B

        v:SetDesc(B)
    end

    local C = {}

    for D, E in ipairs(x)do
        if k[E[1] ] then
            C[#C + 1] = E[2]
        end
    end

    if l.specialRound then
        C[#C + 1] = 'Special Round \u{b7} ' .. l.specialRound
    end

    local D = #C > 0 and table.concat(C, '  \u{b7}  ') or 'All features are off'

    if D ~= m.lastFeatureSummary then
        m.lastFeatureSummary = D

        w:SetDesc(D)
    end
end

t.Dashboard:Button{
    Title = 'Refresh Scan',
    Desc = 'Re-scan player vitals and nearby threats.',
    Icon = 'refresh-cw',
    Callback = function()
        refreshOverview()
        s:Notify{
            Title = 'Snapshot updated',
            Content = characterState(),
            Icon = 'check',
            Duration = 2,
        }
    end,
}

local y = t.Dashboard:Paragraph{
    Title = 'Quick controls',
    Desc = '',
    Icon = 'keyboard',
}

local function refreshShortcutHelp()
    y:SetDesc(l.windowKey .. ' \u{b7} Show / hide   |   ' .. l.noclipKey .. ' \u{b7} Noclip\nN button \u{b7} Drag to reposition. Live session updates every second.')
end

refreshShortcutHelp()

local function setStatus(z)
    z = tostring(z)

    if m.lastStatus == z then
        return
    end

    m.lastStatus = z

    u:SetDesc(z)
    s:SetStatus(z)
end
local function isVisibleInGame(z, A)
    if not z or not A or not A.Enabled then
        return false
    end

    local B = z

    while B and B ~= A do
        if B:IsA'GuiObject' and not B.Visible then
            return false
        end

        B = B.Parent
    end

    return B == A
end
local function checkStreakGuard()
    local z = i:Get'RoundStatus'

    if z == 0 or z == 1 then
        m.streakResetAttempted = false
    end
    if not m.alive or not k.streakGuard or z ~= 2 or m.streakResetAttempted then
        return
    end

    m.streakGuardDiagnostic = 'Waiting for visible downed state'

    local A = i:Get'MapLoading'

    if A ~= nil and A ~= false then
        m.streakGuardDiagnostic = 'Blocked: map loading or unsupported loading state'

        return
    end

    local B = h:FindFirstChild'PlayerGui'
    local C = B and B:FindFirstChild'Game'
    local D = C and C:FindFirstChild'Respawn'
    local E = D and D:FindFirstChild'Downed'
    local F = D and D:FindFirstChild'Death'

    if not E or not F then
        m.streakGuardDiagnostic = 'Blocked: downed UI unavailable'

        setStatus'Streak Guard \u{b7} downed UI unavailable; no reset requested'

        return
    end
    if isVisibleInGame(F, C) then
        m.streakGuardDiagnostic = 'Blocked: already died'

        setStatus'Streak Guard \u{b7} already died; streak protection unconfirmed'

        return
    end
    if not isVisibleInGame(E, C) then
        return
    end

    local G = h.Character
    local H = G and G:FindFirstChildOfClass'Humanoid'

    if not H then
        m.streakGuardDiagnostic = 'Blocked: humanoid unavailable'

        setStatus'Streak Guard \u{b7} humanoid unavailable; no reset requested'

        return
    end

    local I = workspace:FindFirstChild'Map'

    if not I or I:GetAttribute'ClientLoaded' ~= true then
        m.streakGuardDiagnostic = 'Blocked: map not confirmed loaded'

        setStatus'Streak Guard \u{b7} map not confirmed loaded; no reset requested'

        return
    end

    local J = I:GetAttribute'MapName'

    if type(J) ~= 'string' or not J:match'^[%w_%-]+$' then
        setStatus'Streak Guard \u{b7} map command name unavailable; no reset requested'

        return
    end

    local K = '!map ' .. string.lower(J)

    m.streakResetAttempted = true
    m.streakGuardDiagnostic = 'Request attempted: ' .. K

    local L, M = pcall(function()
        j:FireServer(K)
    end)

    if L then
        setStatus('Streak Guard \u{b7} requested ' .. K .. '; reset and streak not confirmed')
    else
        setStatus('Streak Guard \u{b7} request failed: ' .. tostring(M))
    end
end

local z = {}

local function setToggle(A, B, C, D)
    B = B == true

    if not D and z[A] then
        z[A]:Set(B)
    end
    if k[A] == B then
        return
    end

    k[A] = B

    if not B then
        if A == 'autoEvent' then
            releaseChildCache'tickets'
        end
        if A == 'antiNextbot' then
            releaseChildCache'spawns'
        end
    end
    if A == 'noclip' then
        if B then
            applyNoclip()
        else
            restoreNoclip()
        end
    end
    if A == 'showInvisWalls' then
        p:SetEnabled(B)
    end

    refreshOverview()

    local E = C or A

    setStatus(E .. (B and ' enabled' or ' disabled'))
    s:Notify{
        Title = E,
        Content = B and 'Enabled' or 'Disabled',
        Icon = B and 'circle-check' or 'circle-minus',
        Duration = 1.8,
    }
end

local A = t.Farming:Section{
    Title = 'Round Control',
    Desc = 'Independent round actions; admin access required',
    Icon = 'repeat-2',
    Opened = true,
    Box = true,
    BoxBorder = true,
}
local B = t.Survival:Section{
    Title = 'Survival controls',
    Desc = 'Threat response, collision and lighting',
    Icon = 'shield',
    Opened = true,
    Box = true,
    BoxBorder = true,
}

z.playtimeTwoMinutes = A:Toggle{
    Title = 'Playtime 2 Minutes',
    Desc = 
[[Skip the final 60 seconds at the two-minute playtime mark. Requires admin access.]],
    Icon = 'timer-reset',
    Value = false,
    Flag = 'playtime_two_minutes',
    Callback = function(C)
        setToggle('playtimeTwoMinutes', C, 'Playtime 2 Minutes', true)
    end,
}
z.skipIntermission = A:Toggle{
    Title = 'Skip Intermission',
    Desc = 
[[Skip only intermission. Does not enable vote or playtime skipping.]],
    Icon = 'fast-forward',
    Value = false,
    Flag = 'skip_intermission',
    Callback = function(C)
        setToggle('skipIntermission', C, 'Skip Intermission', true)
    end,
}
z.skipVote = A:Toggle{
    Title = 'Skip Vote',
    Desc = 'Skip only the map voting phase. Requires admin access.',
    Icon = 'skip-forward',
    Value = false,
    Flag = 'skip_vote',
    Callback = function(C)
        setToggle('skipVote', C, 'Skip Vote', true)
    end,
}
z.specialRound = A:Dropdown{
    Title = 'Special Round',
    Desc = 
[[Request at intermission, even with Skip Intermission off. None disables it; requires admin.]],
    Values = q,
    Value = 'None',
    AllowNone = false,
    Callback = function(C)
        if C == 'None' then
            l.specialRound = nil
        else
            l.specialRound = C
        end

        m.specialRoundSent = false

        refreshOverview()
        setStatus(l.specialRound and ('Special Round selected \u{b7} ' .. l.specialRound) or 'Special Round disabled')
    end,
}

local C = t.Farming:Section{
    Title = 'Token Farming',
    Desc = 'Event token collection',
    Icon = 'ticket',
    Opened = true,
    Box = true,
    BoxBorder = true,
}

z.autoEvent = C:Toggle{
    Title = 'Farm Token',
    Desc = 
[[Moves to the nearest event ticket. Pauses automatically during Sky Orbit.]],
    Icon = 'ticket',
    Value = false,
    Flag = 'auto_event',
    Callback = function(D)
        setToggle('autoEvent', D, 'Farm Token', true)
    end,
}

local D = t.Farming:Section{
    Title = 'Idle Protection',
    Desc = 'Independent idle protection',
    Icon = 'clock-3',
    Opened = true,
    Box = true,
    BoxBorder = true,
}

z.antiAfk = D:Toggle{
    Title = 'Anti AFK',
    Desc = 'Responds only when Roblox reports inactivity.',
    Icon = 'clock-3',
    Value = false,
    Flag = 'anti_afk',
    Callback = function(E)
        setToggle('antiAfk', E, 'Anti AFK', true)
    end,
}
z.streakGuard = B:Toggle{
    Title = 'Streak Guard \u{b7} Reset on downed',
    Desc = 
[[UI-based downed detection requests the current map once per round. Affects everyone; requires admin. Streak preservation is not guaranteed.]],
    Icon = 'shield-alert',
    Value = false,
    Flag = 'streak_guard',
    Callback = function(E)
        setToggle('streakGuard', E, 'Streak Guard', true)
    end,
}
z.antiNextbot = B:Toggle{
    Title = 'Anti NextBots',
    Desc = 'Move to a distant item spawn when a Nextbot gets close.',
    Icon = 'shield-alert',
    Value = false,
    Flag = 'anti_nextbot',
    Callback = function(E)
        setToggle('antiNextbot', E, 'Anti NextBots', true)
    end,
}
z.noclip = B:Toggle{
    Title = 'Noclip',
    Desc = [[Pass through walls. Restores character collision when disabled.]],
    Icon = 'ghost',
    Value = false,
    Flag = 'noclip',
    Callback = function(E)
        setToggle('noclip', E, 'Noclip', true)
    end,
}
z.fullBright = B:Toggle{
    Title = 'FullBright',
    Desc = 
[[Applies readable lighting and restores the captured lighting when disabled.]],
    Icon = 'sun',
    Value = false,
    Flag = 'full_bright',
    Callback = function(E)
        setToggle('fullBright', E, 'FullBright', true)
    end,
}

local E = t.Farming:Section{
    Title = 'Sky Orbit',
    Desc = 
[[A high-altitude route. Your starting position is restored on exit.]],
    Icon = 'orbit',
    Opened = true,
    Box = true,
    BoxBorder = true,
}

z.skyFarm = E:Toggle{
    Title = 'Enable Sky Orbit',
    Desc = 
[[Token collection and Nextbot movement pause while orbiting. Round controls stay independent.]],
    Icon = 'power',
    Value = false,
    Flag = 'sky_farm',
    Callback = function(F)
        setToggle('skyFarm', F, 'Sky Orbit', true)
    end,
}

local F = {}

F.height = E:Slider{
    Title = 'Height',
    Desc = 'Vertical distance above the activation point.',
    Step = 50,
    Min = 50,
    Max = 5000,
    Value = l.skyHeight,
    Flag = 'sky_height',
    Callback = function(G)
        l.skyHeight = G

        setStatus('Orbit height \u{b7} ' .. tostring(G) .. ' studs')
    end,
}
F.radius = E:Slider{
    Title = 'Radius',
    Desc = 'Horizontal orbit radius.',
    Step = 5,
    Min = 5,
    Max = 250,
    Value = l.skyRadius,
    Flag = 'sky_radius',
    Callback = function(G)
        l.skyRadius = G

        setStatus('Orbit radius \u{b7} ' .. tostring(G) .. ' studs')
    end,
}
F.speed = E:Slider{
    Title = 'Speed',
    Desc = 'Angular speed in radians per second.',
    Step = 0.1,
    Min = 0.1,
    Max = 5,
    Value = l.skySpeed,
    Flag = 'sky_speed',
    Callback = function(G)
        l.skySpeed = G

        setStatus(string.format('Orbit speed \u{b7} %.1f rad/s', G))
    end,
}

E:Button{
    Title = 'Restore orbit defaults',
    Desc = 'Height 1000 \u{b7} Radius 100 \u{b7} Speed 0.8',
    Icon = 'rotate-ccw',
    Callback = function()
        F.height:Set(1000, true)
        F.radius:Set(100, true)
        F.speed:Set(0.8, true)
        setStatus'Orbit defaults restored'
    end,
}

local G = t.Settings:Section{
    Title = 'Appearance',
    Desc = 'Theme and window finish',
    Icon = 'palette',
    Opened = true,
    Box = true,
    BoxBorder = true,
}
local H = G:Dropdown{
    Title = 'Theme',
    Desc = 'Changes the interface theme immediately.',
    Values = {
        'Cyan Stud',
        'Gold Stud',
    },
    Value = 'Cyan Stud',
    AllowNone = false,
    Callback = function(H)
        s:SetTheme(H)
        setStatus('Theme \u{b7} ' .. tostring(H))
    end,
}

s:SetThemeChanged(function(I)
    H:Set(I)
end)
G:Toggle{
    Title = 'Transparent window',
    Desc = 'Use panel transparency without changing game lighting.',
    Icon = 'blend',
    Value = false,
    Callback = function(I)
        s:SetTransparency(I)
    end,
}
t.Settings:Space()

local I = t.Settings:Section{
    Title = 'Window controls',
    Desc = 'Visibility shortcut and session cleanup',
    Icon = 'keyboard',
    Opened = true,
    Box = true,
    BoxBorder = true,
}
local J = t.Survival:Section{
    Title = 'Invis Walls',
}

z.showInvisWalls = J:Toggle{
    Title = 'Show Invis Walls',
    Desc = 
[[Reveal Map/InvisParts locally. Collision stays unchanged; waits if no folder is available.]],
    Value = false,
    Callback = function(K)
        setToggle('showInvisWalls', K, 'Show Invis Walls', true)
    end,
}

local function updateWallAppearance()
    p:SetAppearance(Color3.fromRGB(l.wallRed, l.wallGreen, l.wallBlue), l.wallTransparency)
end

for K, L in ipairs{
    {
        'Red',
        'wallRed',
    },
    {
        'Green',
        'wallGreen',
    },
    {
        'Blue',
        'wallBlue',
    },
}do
    local M = L[2]

    J:Slider{
        Title = 'Color ' .. L[1],
        Min = 0,
        Max = 255,
        Step = 1,
        Value = l[M],
        Callback = function(N)
            l[M] = N

            updateWallAppearance()
        end,
    }
end

J:Slider{
    Title = 'Wall Transparency',
    Desc = '0 = solid; 1 = invisible.',
    Min = 0,
    Max = 1,
    Step = 0.05,
    Value = l.wallTransparency,
    Callback = function(K)
        l.wallTransparency = K

        updateWallAppearance()
    end,
}

local K, L

local function handleNoclipInput(M, N)
    if not m.alive or s:ShouldSuppressShortcut(M) or N or d:GetFocusedTextBox() then
        return
    end
    if M.UserInputType == Enum.UserInputType.Keyboard and M.KeyCode == Enum.KeyCode[l.noclipKey] then
        setToggle('noclip', not k.noclip, 'Noclip')
    end
end
local function setNoclipKey(M)
    local N = typeof(M) == 'EnumItem' and M.Name or tostring(M)
    local O, P = pcall(function()
        return Enum.KeyCode[N]
    end)

    if not O or not P or N == 'Unknown' or N == 'Escape' then
        return
    end
    if N == l.windowKey then
        if L then
            L:Set(l.noclipKey)
        end

        setStatus'Noclip key \u{b7} choose a different key from Window key'

        return
    end

    l.noclipKey = N

    refreshShortcutHelp()
    setStatus('Noclip key \u{b7} ' .. N)
end
local function setFloatingButton(M)
    M = M == true
    l.showFloatingButton = M

    s:SetFloatingButton(M)
end
local function setWindowKey(M)
    local N = typeof(M) == 'EnumItem' and M.Name or tostring(M)
    local O, P = pcall(function()
        return Enum.KeyCode[N]
    end)

    if not O or not P or N == 'Unknown' or N == 'Escape' then
        return
    end
    if N == l.noclipKey then
        if K then
            K:Set(l.windowKey)
        end

        setStatus'Window key \u{b7} choose a different key from Noclip key'

        return
    end

    s:SetToggleKey(P)

    l.windowKey = N

    refreshShortcutHelp()
    setStatus('Window key \u{b7} ' .. N)
end

K = I:Keybind{
    Title = 'Window key',
    Desc = 
[[Click, then press a keyboard key. Esc cancels. Applied immediately.]],
    Value = l.windowKey,
    Callback = setWindowKey,
}
L = I:Keybind{
    Title = 'Noclip key',
    Desc = 
[[Click, then press a keyboard key. Esc cancels. Ignored while typing.]],
    Value = l.noclipKey,
    Callback = setNoclipKey,
}

I:Toggle{
    Title = 'Show floating N button',
    Desc = 
[[Hide the minimized logo. Your Window key can still reopen the panel.]],
    Icon = 'eye',
    Value = true,
    Callback = setFloatingButton,
}
connect(d.InputBegan, handleNoclipInput)
I:Button{
    Title = 'Unload NKS',
    Desc = 'Restore managed state and remove the NKS window.',
    Icon = 'power-off',
    Callback = function()
        if _G.NKSCleanup then
            _G.NKSCleanup()
        end
    end,
}
s:SetThemeCycle(function()
    local M = s:GetTheme() == 'Cyan Stud' and 'Gold Stud' or 'Cyan Stud'

    s:SetTheme(M)
    setStatus('Theme \u{b7} ' .. M)
end)
t.Dashboard:Select()

local M = {
    'GlobalShadows',
    'Brightness',
    'Ambient',
    'OutdoorAmbient',
    'ClockTime',
    'ExposureCompensation',
    'FogEnd',
}
local N = {
    GlobalShadows = false,
    Brightness = 3,
    Ambient = Color3.new(1, 1, 1),
    OutdoorAmbient = Color3.new(1, 1, 1),
    ClockTime = 12,
    ExposureCompensation = 0.5,
    FogEnd = 1e10,
}

local function applyFullBright()
    for O, P in pairs(N)do
        if e[O] ~= P then
            e[O] = P
        end
    end
end
local function saveLighting()
    if m.originalLighting then
        return
    end

    m.originalLighting = {}

    for O, P in ipairs(M)do
        m.originalLighting[P] = e[P]
    end
end
local function restoreLighting()
    if not m.originalLighting then
        return
    end

    for O, P in pairs(m.originalLighting)do
        e[O] = P
    end

    m.originalLighting = nil
end
local function nearestEventItem(O)
    local P = workspace:FindFirstChild'Effects'
    local Q = P and P:FindFirstChild'Tickets'
    local R, S = math.huge

    for T in pairs(cachedChildren('tickets', Q))do
        local U = T:FindFirstChild'HumanoidRootPart' or T:FindFirstChildWhichIsA'BasePart'

        if U then
            local V = (O.Position - U.Position).Magnitude

            if V < R then
                S, R = U, V
            end
        end
    end

    return S, R
end
local function nearestNextbot(O)
    local P = workspace:FindFirstChild'Players'
    local Q, R = l.nextbotRange

    for S in pairs(cachedChildren('nextbots', P))do
        local T = S:FindFirstChild'HumanoidRootPart'

        if S:GetAttribute'AI' == true and T then
            local U = (O.Position - T.Position).Magnitude

            if U < Q then
                R, Q = T, U
            end
        end
    end

    return R, Q
end
local function safestItemSpawn(O)
    local P = workspace:FindFirstChild'Map'
    local Q = P and P:FindFirstChild'ItemSpawns'
    local R, S = (-math.huge)

    for T in pairs(cachedChildren('spawns', Q))do
        if T.Name == 'ItemSpawn' and T:IsA'BasePart' then
            local U = (T.Position - O.Position).Magnitude

            if U > R then
                S, R = T, U
            end
        end
    end

    return S
end
local function currentRoundPhase(O, P, Q, R)
    if Q then
        return nil
    end
    if R then
        return 'Map voting'
    end
    if O == 1 and type(P) == 'number' and P <= 30 then
        return 'Intermission'
    end

    return nil
end
local function sendRoundCommand(O)
    m.lastRoundAttempt = os.clock()

    local P, Q = pcall(function()
        j:FireServer(l.roundCommand)
    end)

    if not P then
        setStatus('Time Skip \u{b7} ' .. tostring(Q))

        return false
    end

    m.roundCommandCount += 1

    m.lastCommandPhase = O

    setStatus(O .. ' \u{b7} sent ' .. l.roundCommand)
    s:Notify{
        Title = 'Time Skip',
        Content = O .. ' \u{b7} ' .. l.roundCommand,
        Icon = 'timer',
        Duration = 2,
    }

    return true
end
local function sendSpecialRoundCommand(O)
    if not l.specialRound then
        return true
    end

    m.lastRoundAttempt = os.clock()

    local P = '!specialround ' .. l.specialRound
    local Q, R = pcall(function()
        j:FireServer(P)
    end)

    if not Q then
        setStatus('Special Round \u{b7} ' .. tostring(R))

        return false
    end

    m.roundCommandCount += 1

    m.lastCommandPhase = O

    setStatus(O .. ' \u{b7} sent ' .. P)
    s:Notify{
        Title = 'Special Round',
        Content = O .. ' \u{b7} ' .. P,
        Icon = 'sparkles',
        Duration = 2,
    }

    return true
end
local function checkRoundAutomation()
    local O = i:Get'RoundStatus'
    local P = i:Get'Time'
    local Q = i:Get'MapLoading' == true
    local R = i:Get'Voting' == true

    if Q then
        return
    end

    local S = currentRoundPhase(O, P, Q, R)

    if S ~= m.roundPhase then
        m.roundPhase = S
        m.roundCommandSent = false
        m.specialRoundSent = false
    end
    if O ~= m.lastRoundStatus then
        m.lastRoundStatus = O

        if O == 2 then
            m.activeRoundCommandSent = false
        end
    end
    if os.clock() - m.lastRoundAttempt < l.roundRetryInterval then
        return
    end
    if S == 'Intermission' and l.specialRound and not m.specialRoundSent then
        m.specialRoundSent = sendSpecialRoundCommand(S)

        return
    end

    local T = (S == 'Map voting' and k.skipVote) or (S == 'Intermission' and k.skipIntermission)

    if T and not m.roundCommandSent then
        m.roundCommandSent = sendRoundCommand(S)
    elseif k.playtimeTwoMinutes and O == 2 and not R and type(P) == 'number' and P <= l.activeRoundTimeTrigger and not m.activeRoundCommandSent then
        m.activeRoundCommandSent = sendRoundCommand'Playtime \u{b7} two-minute mark'
    end
end

connect(h.Idled, function()
    if not k.antiAfk then
        return
    end

    f:CaptureController()
    f:ClickButton2(Vector2.new(0, 0))
    setStatus'Anti AFK pulse sent'
end)
connect(h.CharacterAdded, function()
    restoreNoclip()

    m.orbitStarted = false
    m.savedCFrame = nil
    m.orbitCenter = nil
end)
connect(c.Stepped, function()
    if m.alive and k.noclip then
        applyNoclip()
    end
end)
connect(c.Heartbeat, function(O)
    if not m.alive then
        return
    end

    checkStreakGuard()

    local P = getRoot()

    m.overviewClock += O

    if m.overviewClock >= 1 then
        m.overviewClock = 0

        refreshOverview()
    end
    if k.fullBright then
        saveLighting()
        applyFullBright()
    elseif m.originalLighting then
        restoreLighting()
    end

    m.roundClock += O

    if m.roundClock >= l.roundCheckInterval then
        m.roundClock = 0

        checkRoundAutomation()
    end
    if not P then
        return
    end
    if k.skyFarm then
        if not m.orbitStarted then
            m.orbitStarted = true
            m.savedCFrame = P.CFrame
            m.orbitCenter = P.Position + Vector3.new(0, l.skyHeight, 0)
            m.orbitAngle = 0

            setStatus'Sky orbit started'
        end

        m.orbitAngle += O * l.skySpeed

        local Q = m.orbitCenter + Vector3.new(math.cos(m.orbitAngle) * l.skyRadius, 0, math.sin(m.orbitAngle) * l.skyRadius)

        zeroVelocity(P)

        P.CFrame = CFrame.lookAt(Q, m.orbitCenter)

        return
    elseif m.orbitStarted then
        m.orbitStarted = false

        zeroVelocity(P)

        if m.savedCFrame then
            P.CFrame = m.savedCFrame
        end

        m.savedCFrame = nil
        m.orbitCenter = nil

        setStatus'Sky orbit stopped; position restored'
    end

    m.eventClock += O

    if k.autoEvent and m.eventClock >= l.eventInterval then
        m.eventClock = 0

        local Q, R = nearestEventItem(P)

        if Q then
            zeroVelocity(P)

            P.CFrame = CFrame.new(Q.Position)

            setStatus(string.format('Event item: %.0f studs', R))
        end
    end

    m.avoidClock += O

    if k.antiNextbot and m.avoidClock >= 0.2 then
        m.avoidClock = 0

        local Q, R = nearestNextbot(P)

        if Q then
            local S = safestItemSpawn(Q)

            if S then
                zeroVelocity(P)

                P.CFrame = S.CFrame + Vector3.new(0, 3, 0)

                setStatus(string.format('Avoided Nextbot: %.0f studs', R))
            end
        end
    end
end)

local function cleanup()
    if not m.alive then
        return
    end

    m.alive = false

    p:Destroy()
    restoreNoclip()
    clearChildCaches()

    local O = getRoot()

    if O and m.orbitStarted and m.savedCFrame then
        zeroVelocity(O)

        O.CFrame = m.savedCFrame
    end

    restoreLighting()

    for P, Q in ipairs(m.connections)do
        pcall(function()
            Q:Disconnect()
        end)
    end

    table.clear(m.connections)

    if s then
        pcall(function()
            s:Destroy()
        end)
    end

    _G.NKS = nil
    _G.NKSCleanup = nil
end

_G.NKS = {
    state = k,
    config = l,
    runtime = m,
    ui = {
        Window = s,
        Toggles = z,
    },
    set = setToggle,
    cleanup = cleanup,
}
_G.NKSCleanup = cleanup

print('[NKS] loaded with custom Stud UI \u{b7} ' .. s:GetTheme())
