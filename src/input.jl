struct InputButton
    ended_down::Bool
    num_transitions::Int
end

abstract type AbstractUserInputState end

mutable struct UserInputState <: AbstractUserInputState
    cursor::SD.Point
    key_escape::InputButton
    key_up::InputButton
    key_down::InputButton
    key_left::InputButton
    key_right::InputButton
    mouse_left::InputButton
    mouse_right::InputButton
    mouse_middle::InputButton
    characters::Vector{Char}
end

went_down(ended_down, num_transitions) = (num_transitions >= 2) || ((num_transitions == 1) && ended_down)
went_up(ended_down, num_transitions) = (num_transitions >= 2) || ((num_transitions == 1) && !ended_down)

went_down(input_button) = went_down(input_button.ended_down, input_button.num_transitions)
went_up(input_button) = went_up(input_button.ended_down, input_button.num_transitions)

press(input_button) = InputButton(true, input_button.num_transitions + one(input_button.num_transitions))
release(input_button) = InputButton(false, input_button.num_transitions + one(input_button.num_transitions))
reset(input_button) = InputButton(input_button.ended_down, zero(input_button.num_transitions))

function reset!(user_input_state::UserInputState)
    user_input_state.key_escape = reset(user_input_state.key_escape)
    user_input_state.key_up = reset(user_input_state.key_up)
    user_input_state.key_down = reset(user_input_state.key_down)
    user_input_state.key_left = reset(user_input_state.key_left)
    user_input_state.key_right = reset(user_input_state.key_right)
    user_input_state.mouse_left = reset(user_input_state.mouse_left)
    user_input_state.mouse_right = reset(user_input_state.mouse_right)
    user_input_state.mouse_middle = reset(user_input_state.mouse_middle)
    empty!(user_input_state.characters)

    return nothing
end
