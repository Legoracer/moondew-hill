local Event = require("knife.event")
local Anim8 = require("anim8")

local OverallsSprite = love.graphics.newImage("Assets/Sprites/Hair/Emo.png")

local Character = {
    AnimationDefitions = {
        WalkForward = {"1-8", 1},
        WalkBackward = {"1-8", 2},
        WalkRight = {"1-8", 3},
        WalkLeft = {"1-8", 4}
    }
}
Character.__index = Character

function Character.new(player)
    local self = setmetatable({
        Player = player,
        State = "idle",

        Sprite = nil,
        Position = {x=0, y=0},
        Appearance = { -- Images
            Body = nil,
            Hair = nil,
            Shirt = nil,
            Pants = nil,
            Shoes = nil,
            Accessory = nil,
        },
        Animations = { -- Animations
            Body = nil,
            Hair = nil,
            Shirt = nil,
            Pants = nil,
            Shoes = nil,
            Accessory = nil
        },
        CurrentAnimation = nil,
        
        _Destroyed = false
    }, Character)

    self:SetAnimation("WalkForward")
    self:PauseAnimation()
    self:UpdateAppearance()

    return self
end

function Character:UpdateAppearance()
    local appearance = self.Player:GetAppearance()
    for section, image in next, appearance do
        image:setFilter("nearest", "nearest")
        self.Appearance[section] = image

        self.Animations[section] = Anim8.newAnimation(
            Anim8.newGrid(32, 32, image:getWidth(), image:getHeight()) (
                unpack(self.CurrentAnimationData)
            ), 0.1
        )
    end
end

-- Idle handler
function Character:PauseAnimation()
    for _, animation in next, self.Animations do
        if animation then
            animation:pauseAtStart()
        end
    end
end

function Character:SetAnimation(animName)
    for _, animation in next, self.Animations do
        if animation then
            animation:resume()
        end
    end

    self.CurrentAnimation = animName
    local animData = self.AnimationDefitions[animName] or self.AnimationDefitions["WalkForward"]
    if animData == self.CurrentAnimationData then return end
    self.CurrentAnimationData = animData

    for section, animation in next, self.Animations do
        local image = self.Appearance[section]
        self.Animations[section] = Anim8.newAnimation(
            Anim8.newGrid(32, 32, image:getWidth(), image:getHeight()) (
                unpack(self.CurrentAnimationData)
            ), 0.1
        )
    end
end

function Character:SetBody(image)
    self.Appearance.Body = image
    self.Animations.Body = Anim8.newAnimation(
        Anim8.newGrid(32, 32, image:getWidth(), image:getHeight()) (
            unpack(self.CurrentAnimationData)
        ), 0.1
    )
end

function Character:SetHair()
    
end

function Character:SetShirt()
    
end

function Character:SetPants()
    
end

function Character:_RenderAnimation(animation, image)
    if animation and image then
        animation:draw(image, self.Position.x, self.Position.y)
    end
end
-- returns current "image"
function Character:Render()
    if self.State == "Idle" then
        self:PauseAnimation()
    end

    if self.CurrentAnimationData then
        self:_RenderAnimation(self.Animations.Body, self.Appearance.Body)
        self:_RenderAnimation(self.Animations.Shoes, self.Appearance.Shoes)
        self:_RenderAnimation(self.Animations.Pants, self.Appearance.Pants)
        self:_RenderAnimation(self.Animations.Shirt, self.Appearance.Shirt)
        self:_RenderAnimation(self.Animations.Hair, self.Appearance.Hair)
        self:_RenderAnimation(self.Animations.Accessory, self.Appearance.Accessory)
        -- for section, animation in next, self.Animations do
        --     local image = self.Appearance[section]
        --     animation:draw(image, self.Position.x, self.Position.y)
        -- end
    end

end

function Character:Update(dt)
    for _, animation in next, self.Animations do
        animation:update(dt)
    end
end

function Character:Destroy()
    
end

return Character