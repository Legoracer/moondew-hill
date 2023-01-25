local Controller = {
    Mappings = {
        Forward = "w",
        Back = "s",
        Left = "a",
        Right = "d"
    }
}
Controller.__index = Controller

function Controller.new(player)
    local self = setmetatable({
        Player = player,
        Actions = {
            Forward = false,
            Back = false,
            Left = false,
            Right = false
        }
    }, Controller)

    return self
end

function Controller:KeyPressed(key)
    for action, mappedKey in next, self.Mappings do
        if mappedKey == key then
            self.Actions[action] = true
        end
    end
    if key == "r" then
        self.Player:Spawn()
    end
end

function Controller:KeyReleased(key)
    for action, mappedKey in next, self.Mappings do
        if mappedKey == key then
            self.Actions[action] = false
        end
    end
end

function Controller:Update(dt)
    local character = self.Player.Character
    if character then

        local WALKSPEED = 0.2
        local velocity = {x=0, y=0}

        if self.Actions.Forward then
            velocity.y = velocity.y - WALKSPEED
        end

        if self.Actions.Back then
            velocity.y = velocity.y + WALKSPEED
        end

        if self.Actions.Left then
            velocity.x = velocity.x - WALKSPEED
        end

        if self.Actions.Right then
            velocity.x = velocity.x + WALKSPEED
        end

        if velocity.y == 0 and velocity.x == 0 then
            if character.State ~= "Idle" then
                character.State = "Idle"
                character:PauseAnimation()
            end
        else
            character.State = "Moving"
            if velocity.y < 0 then
                character:SetAnimation("WalkBackward")
            elseif velocity.y > 0 then
                character:SetAnimation("WalkForward")
            elseif velocity.x < 0 then
                character:SetAnimation("WalkLeft")
            elseif velocity.x > 0 then
                character:SetAnimation("WalkRight")
            end
        end

        character.Position = {
            x = character.Position.x + velocity.x,
            y = character.Position.y + velocity.y
        }
    end
    
end

return Controller