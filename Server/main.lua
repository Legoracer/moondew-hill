local Sock = require("sock")
local Console = require("console.console")
local Server

local NextPlayerId = 1
local Clients = {}

-- for console
function love.textinput(t)
    Console(t)
end

function love.conf(t)
    t.console = true
end

function love.load()
    love.window.setMode(400, 150)

    Server = Sock.newServer("*", 22122)
    print("Started server at localhost:22122")

    Server:on("updatePosition", function(data, client)
        data.Id = client.Id
        sendExcept(client, "updatePosition", data)
    end)

    Server:on("connect", function(data, client)
        print("Client connected.")

        client.Id = NextPlayerId
        client.Name = "Player-"..client.Id
        client.Appearance = {
            Accessory = "Assets/Sprites/Clothes/Accessories/glasses.png",
            Shirt = "Assets/Sprites/Clothes/Shirts/dress.png",
            Hair = math.random(0, 1) == 0 and "Assets/Sprites/Hair/ponytail.png" or "Assets/Sprites/Hair/buzzcut.png"
        }
        NextPlayerId = NextPlayerId + 1

        Clients[client.Id] = client
        local playerData = {
            Id = client.Id,
            Name = client.Name,
            Appearance = client.Appearance
        }

        local players = {}
        for _, client in next, Clients do
            table.insert(players, {
                Id = client.Id,
                Name = client.Name,
                Appearance = client.Appearance
            })
        end

        client:send("acknowledge", {
            Player = playerData,
            Players = players
        })
        sendExcept(client, "playerAdded", playerData)
    end)

    Server:on("disconnect", function(data, client)
        print(client.Id, "Disconnected")
        for n, _client in next, Clients do
            if _client.Id == client.Id then
                table.remove(Clients, n)
            end
        end
        send("playerRemoved", client.Id)
    end)
end

function send(x, y)
    for _, client in next, Clients do
        client:send(x, y)
    end
end

function sendExcept(targetClient, x, y)
    for _, client in next, Clients do
        if client.Id ~= targetClient.Id then
            client:send(x, y)
        end
    end
end

function sendOne(targetClient, x, y)
    for _, client in next, Clients do
        if client.Id == targetClient.Id then
            client:send(x, y)
        end
    end
end

function love.update(dt)
    Server:update(dt)
end