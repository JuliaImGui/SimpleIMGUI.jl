struct InputButton
    ended_down::Bool
    half_transition_count::Int
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

went_down(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && ended_down)
went_up(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && !ended_down)

went_down(input_button) = went_down(input_button.ended_down, input_button.half_transition_count)
went_up(input_button) = went_up(input_button.ended_down, input_button.half_transition_count)

press_button(input_button) = InputButton(true, input_button.half_transition_count + one(input_button.half_transition_count))
release_button(input_button) = InputButton(false, input_button.half_transition_count + one(input_button.half_transition_count))
reset(input_button) = InputButton(input_button.ended_down, zero(input_button.half_transition_count))

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
