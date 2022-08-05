struct InputButton{I}
    ended_down::Bool
    num_transitions::I
end

abstract type AbstractUserInputState end

mutable struct UserInputState{I1, I2} <: AbstractUserInputState
    cursor::SD.Point{I1}
    keyboard_buttons::Vector{InputButton{I2}}
    mouse_buttons::Vector{InputButton{I2}}
    characters::Vector{Char}
end

went_down(ended_down, num_transitions) = (num_transitions >= 2) || (isone(num_transitions) && ended_down)
went_up(ended_down, num_transitions) = (num_transitions >= 2) || (isone(num_transitions) && !ended_down)

went_down(input_button) = went_down(input_button.ended_down, input_button.num_transitions)
went_up(input_button) = went_up(input_button.ended_down, input_button.num_transitions)

press(input_button) = typeof(input_button)(true, input_button.num_transitions + one(input_button.num_transitions))
release(input_button) = typeof(input_button)(false, input_button.num_transitions + one(input_button.num_transitions))
reset(input_button) = typeof(input_button)(input_button.ended_down, zero(input_button.num_transitions))

function reset!(user_input_state)
    for (i, input_button) in enumerate(user_input_state.keyboard_buttons)
        user_input_state.keyboard_buttons[i] = reset(input_button)
    end

    for (i, input_button) in enumerate(user_input_state.mouse_buttons)
        user_input_state.mouse_buttons[i] = reset(input_button)
    end

    empty!(user_input_state.characters)

    return nothing
end
