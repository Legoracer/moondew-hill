local Character = require("Character")

local Player = {}
Player.__index = Player

function Player.new(id, name, appearance, isLocalPlayer)
    local self = setmetatable({
        Id = id,
        Name = name or "Player",
        IsLocalPlayer = isLocalPlayer,
        Character = nil,
        Appearance = {
            Body = "Assets/Sprites/Character.png",
            Hair = nil,
            Shirt = nil,
            Pants = nil,
            Shoes = nil,
            Accessory = nil
        }
    }, Player)

    self:SetAppearance(appearance)
    
    return self
end

function Player:SetAppearance(appearance)
    self.Appearance = appearance
end

function Player:GetAppearance()
    return {
        Body = love.graphics.newImage(self.Appearance.Body or "Assets/Sprites/Character.png"),
        Hair = self.Appearance.Hair and love.graphics.newImage(self.Appearance.Hair),
        Shirt = self.Appearance.Shirt and love.graphics.newImage(self.Appearance.Shirt),
        Pants = self.Appearance.Pants and love.graphics.newImage(self.Appearance.Pants),
        Shoes = self.Appearance.Shoes and love.graphics.newImage(self.Appearance.Shoes),
        Accessory = self.Appearance.Accessory and love.graphics.newImage(self.Appearance.Accessory)
    }
end

function Player:Spawn()
    if self.Character and not self.Character._Destroyed then
        self.Character:Destroy()
    end

    self.Character = Character.new(self)
    self.Character.Position = {x=50, y=100}
end

return Player