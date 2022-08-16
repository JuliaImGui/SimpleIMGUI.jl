struct InputButton{I}
    ended_down::Bool
    num_transitions::I
end

abstract type AbstractUserInputState end

mutable struct UserInputState{I, T, C} <: AbstractUserInputState
    cursor::SD.Point{I}
    keyboard_buttons::Vector{T}
    mouse_buttons::Vector{T}
    characters::Vector{C}
end

went_down(ended_down, num_transitions) = (num_transitions >= 2) || (isone(num_transitions) && ended_down)
went_up(ended_down, num_transitions) = (num_transitions >= 2) || (isone(num_transitions) && !ended_down)

went_down(input_button) = went_down(input_button.ended_down, input_button.num_transitions)
went_up(input_button) = went_up(input_button.ended_down, input_button.num_transitions)

press(ended_down, num_transitions) = (true, num_transitions + one(num_transitions))
release(ended_down, num_transitions) = (false, num_transitions + one(num_transitions))
reset(ended_down, num_transitions) = (ended_down, zero(num_transitions))

press(input_button) = typeof(input_button)(press(input_button.ended_down, input_button.num_transitions)...)
release(input_button) = typeof(input_button)(release(input_button.ended_down, input_button.num_transitions)...)
reset(input_button) = typeof(input_button)(reset(input_button.ended_down, input_button.num_transitions)...)

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
