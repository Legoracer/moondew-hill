local Player = require("Player")
local Controller = require("Controller")
local Sti = require("sti")
local Sock = require("sock")
local Console = require("console.console")

local Client = nil
local LocalController = nil
local LocalPlayer = nil
local Players = {}
local NPCs = {}
local Map = nil

local PreparingToClose = false
local ReadyToClose = false

function love.conf(t)
    t.console = true
end

-- for console
function love.textinput(t)
    Console(t)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Map = Sti('Assets/map.lua', { "box2d" })

    Client = Sock.newClient("localhost", 22122)

    Client:on("connect", function(data)
        print("Connected to server.")
    end)

    Client:on("playerAdded", function(data)
        local player = Player.new(data.Id, data.Name, data.Appearance, false)
        table.insert(Players, player)
        print("New player added.")
        player:Spawn()
    end)

    Client:on("playerRemoved", function(data)
        print("Trying to remove", data)
        for n, player in next, Players do
            if player.Id == data then
                table.remove(Players, n)
            end
        end
    end)

    Client:on("updatePosition", function(data)
        local targetPlayer
        for _, player in next, Players do
            if player.Id == data.Id then
                targetPlayer = player
            end
        end

        if targetPlayer then
            local character = targetPlayer.Character
            if character then
                character:SetAnimation(data.Animation)
                character.Position = data.Position
                character.State = data.State
            end
        end
    end)

    Client:on("disconnect", function()
        love.event.quit()
    end)

    Client:on("acknowledge", function(data)
        -- setup yourself
        local playerData = data.Player
        local player = Player.new(playerData.Id, playerData.Name, playerData.Appearance, true)
        table.insert(Players, player)
        player:Spawn()
        LocalController = Controller.new(player)
        LocalPlayer = player

        -- setup others
        for _, otherPlayerData in next, data.Players do
            if playerData.Id ~= otherPlayerData.Id then
                local player = Player.new(otherPlayerData.Id, otherPlayerData.Name, otherPlayerData.Appearance, false)
                table.insert(Players, player)
                player:Spawn()
            end
        end

    end)

    Client:connect()
    print("Connecting...")
end

--- ADD COLLISIONS!
local SCALE = 5

function love.wheelmoved(x, y)
    SCALE = math.max(2, math.min(5, SCALE + y/10))
end

function love.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local tx, ty = 0, 0

    love.graphics.push()

    -- Translate camera
    if LocalPlayer then
        local character = LocalPlayer.Character
        if character then
            tx, ty = (-character.Position.x - 16) * SCALE + w/2 , (-character.Position.y - 24) * SCALE + h/2
            love.graphics.translate(tx, ty)
        end
    end

    -- Draw map
    Map:draw(tx/SCALE, ty/SCALE, SCALE, SCALE)
    
    -- Draw characters
    love.graphics.scale(SCALE, SCALE)
    for _, player in next, Players do
        local character = player.Character
        if character and not character._Destroyed then
            character:Render()
        end
    end

    for _, player in next, Players do
        local character = player.Character
        if character and not character._Destroyed then
            love.graphics.newText(love.graphics.getFont(), player.Name, player.Character.Position.x, player.Character.Position.y)
        end
    end

    love.graphics.pop()

    if not LocalPlayer then
        love.graphics.push()
        love.graphics.scale(2)
        love.graphics.print("Waiting for server....", 20, 20)
        love.graphics.pop()
    end
end

function love.update(dt)
    Map:update()
    Client:update()
    
    for _, player in next, Players do

        if player == LocalPlayer then
            LocalController:Update()
            Client:send("updatePosition", {
                Position = player.Character.Position,
                State = player.Character.State,
                Animation = player.Character.CurrentAnimation
            })
        end

        local character = player.Character
        if character and not character._Destroyed then
            character:Update(dt)
        end
    end

    if PreparingToClose then
        ReadyToClose = true
        love.event.quit()
    end
end

function love.keypressed(key, repeated)
    if LocalController then
        LocalController:KeyPressed(key, repeated)
    end
end

function love.keyreleased(key)
    if LocalController then
        LocalController:KeyReleased(key)
    end
end

function disconnectAfter()
    print(delay)
end

function love.quit()
    Client:disconnect()
    PreparingToClose = true
    return not ReadyToClose
end
