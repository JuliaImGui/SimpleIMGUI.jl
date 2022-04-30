struct InputButton
    ended_down::Bool
    half_transition_count::Int
end

struct Cursor
    i::Int
    j::Int
end

press_button(button) = InputButton(true, button.half_transition_count + one(button.half_transition_count))
release_button(button) = InputButton(false, button.half_transition_count + one(button.half_transition_count))
reset(button) = InputButton(button.ended_down, zero(button.half_transition_count))
