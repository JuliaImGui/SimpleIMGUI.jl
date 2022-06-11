struct InputButton
    ended_down::Bool
    half_transition_count::Int
end

struct BoundingBox
    i_min::Int
    j_min::Int
    i_max::Int
    j_max::Int
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

BoundingBox(point::SD.Point, height, width) = BoundingBox(point.i, point.j, point.i + height - one(height), point.j + width - one(width))

went_down(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && ended_down)
went_up(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && !ended_down)

went_down(input_button) = went_down(input_button.ended_down, input_button.half_transition_count)
went_up(input_button) = went_up(input_button.ended_down, input_button.half_transition_count)

press_button(button) = InputButton(true, button.half_transition_count + one(button.half_transition_count))
release_button(button) = InputButton(false, button.half_transition_count + one(button.half_transition_count))
reset(button) = InputButton(button.ended_down, zero(button.half_transition_count))

is_inside(bounding_box, cursor) = (bounding_box.i_min <= cursor.i <= bounding_box.i_max) && (bounding_box.j_min <= cursor.j <= bounding_box.j_max)

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
