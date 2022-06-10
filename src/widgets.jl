abstract type AbstractWidget end

struct Button <: AbstractWidget end
const BUTTON = Button()

struct Slider <: AbstractWidget end
const SLIDER = Slider()

struct TextInput <: AbstractWidget end
const TEXT_INPUT = TextInput()

#####
##### Button
#####

function get_widget_value(::Button, hot_widget, active_widget, widget, condition)
    if (active_widget == widget) && (hot_widget == widget) && condition
        return true
    else
        return false
    end
end

function do_widget(widget_type::Button, hot_widget, active_widget, null_widget, widget, i_min, j_min, i_max, j_max, i_mouse, j_mouse, ended_down, half_transition_count)
    mouse_over_button = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, half_transition_count)
    mouse_went_up = went_up(ended_down, half_transition_count)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, widget, mouse_over_button)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, widget, mouse_over_button && mouse_went_down)

    value = get_widget_value(widget_type, hot_widget, active_widget, widget, mouse_over_button && mouse_went_up)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_button)

    return hot_widget, active_widget, null_widget, value
end

do_widget(widget_type::Button, hot_widget, active_widget, null_widget, widget, bounding_box::BoundingBox, cursor::Point, input_button::InputButton) = do_widget(widget_type, hot_widget, active_widget, null_widget, widget, bounding_box.i_min, bounding_box.j_min, bounding_box.i_max, bounding_box.j_max, cursor.i, cursor.j, input_button.ended_down, input_button.half_transition_count)

do_widget!!(widget_type::Button, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

#####
##### Slider
#####

function get_widget_value(::Slider, hot_widget, active_widget, widget, active_value, last_value)
    if (active_widget == widget) && (hot_widget == widget)
        return active_value
    else
        return last_value
    end
end

function do_widget(widget_type::Slider, hot_widget, active_widget, null_widget, widget, i_min, j_min, i_max, j_max, i_mouse, j_mouse, ended_down, half_transition_count, last_value)
    mouse_over_slider = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, half_transition_count)
    mouse_went_up = went_up(ended_down, half_transition_count)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, widget, mouse_over_slider)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, widget, mouse_over_slider && mouse_went_down)

    value = get_widget_value(widget_type, hot_widget, active_widget, widget, clamp(j_mouse - j_min + one(j_min), one(j_min), j_max - j_min + one(j_min)), last_value)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_slider)

    return hot_widget, active_widget, null_widget, value
end

do_widget(widget_type::Slider, hot_widget, active_widget, null_widget, widget, bounding_box::BoundingBox, cursor::Point, input_button::InputButton, last_value) = do_widget(widget_type, hot_widget, active_widget, null_widget, widget, bounding_box.i_min, bounding_box.j_min, bounding_box.i_max, bounding_box.j_max, cursor.i, cursor.j, input_button.ended_down, input_button.half_transition_count, last_value)

do_widget!!(widget_type::Slider, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

#####
##### TextInput
#####

function update_widget_value!(::TextInput, hot_widget, active_widget, widget, text_line, characters)
    if (active_widget == widget) && (hot_widget == widget)
        for character in characters
            if isascii(character)
                if isprint(character)
                    push!(text_line, character)
                elseif character == '\b'
                    if length(text_line) > 0
                        pop!(text_line)
                    end
                end
            end
        end
    end

    return nothing
end

function do_widget!(widget_type::TextInput, hot_widget, active_widget, null_widget, widget, i_min, j_min, i_max, j_max, i_mouse, j_mouse, ended_down, half_transition_count, text_line, characters)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, half_transition_count)
    mouse_went_up = went_up(ended_down, half_transition_count)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, widget, mouse_over_widget && mouse_went_up)

    update_widget_value!(widget_type, hot_widget, active_widget, widget, text_line, characters)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_widget && mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget
end

do_widget!(widget_type::TextInput, hot_widget, active_widget, null_widget, widget, bounding_box::BoundingBox, cursor::Point, input_button::InputButton, text_line, characters) = do_widget!(widget_type, hot_widget, active_widget, null_widget, widget, bounding_box.i_min, bounding_box.j_min, bounding_box.i_max, bounding_box.j_max, cursor.i, cursor.j, input_button.ended_down, input_button.half_transition_count, text_line, characters)

do_widget!!(widget_type::TextInput, args...; kwargs...) = (do_widget!(widget_type, args...; kwargs...)..., nothing)
