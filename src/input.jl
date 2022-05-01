struct InputButton
    ended_down::Bool
    half_transition_count::Int
end

struct Cursor
    i::Int
    j::Int
end

struct BoundingBox
    i_min::Int
    j_min::Int
    i_max::Int
    j_max::Int
end

press_button(button) = InputButton(true, button.half_transition_count + one(button.half_transition_count))
release_button(button) = InputButton(false, button.half_transition_count + one(button.half_transition_count))
reset(button) = InputButton(button.ended_down, zero(button.half_transition_count))

is_inside(bounding_box, cursor) = (bounding_box.i_min <= cursor.i <= bounding_box.i_max) && (bounding_box.j_min <= cursor.j <= bounding_box.j_max)
