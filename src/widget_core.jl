abstract type AbstractWidgetType end

struct Button <: AbstractWidgetType end
const BUTTON = Button()

struct TextBox <: AbstractWidgetType end
const TEXT_BOX = TextBox()

struct Text <: AbstractWidgetType end
const TEXT = Text()

struct CheckBox <: AbstractWidgetType end
const CHECK_BOX = CheckBox()

struct RadioButton <: AbstractWidgetType end
const RADIO_BUTTON = RadioButton()

struct DropDown <: AbstractWidgetType end
const DROP_DOWN = DropDown()

struct Slider <: AbstractWidgetType end
const SLIDER = Slider()

struct Image <: AbstractWidgetType end
const IMAGE = Image()

#####
##### utils
#####

"""
    try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next hot widget. It could either be `hot_widget` or `this_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_active_widget`](@ref), [`try_reset_active_widget`](@ref), [`try_reset_hot_widget`](@ref).
"""
function try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == null_widget) && (active_widget == null_widget) && condition
        return this_widget
    else
        return hot_widget
    end
end

"""
    try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next active widget. It could either be `active_widget` or `this_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_hot_widget`](@ref), [`try_reset_active_widget`](@ref), [`try_reset_hot_widget`](@ref).
"""
function try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == null_widget) && condition
        return this_widget
    else
        return active_widget
    end
end

"""
    try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next hot widget. It could either be `hot_widget` or `null_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_hot_widget`](@ref), [`try_set_active_widget`](@ref), [`try_reset_active_widget`](@ref).
"""
function try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == null_widget) && condition
        return null_widget
    else
        return hot_widget
    end
end

"""
    try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next active widget. It could either be `active_widget` or `null_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_hot_widget`](@ref), [`try_set_active_widget`](@ref), [`try_reset_hot_widget`](@ref).
"""
function try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == this_widget) && condition
        return null_widget
    else
        return active_widget
    end
end

#####
##### Button
#####

function get_widget_value(::Union{Button, Text, Image}, hot_widget, active_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == this_widget) && condition
        return true
    else
        return false
    end
end

function do_widget(widget_type::Union{Button, Text, Image}, hot_widget, active_widget, null_widget, this_widget, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget && mouse_went_down)

    widget_value = get_widget_value(widget_type, hot_widget, active_widget, this_widget, mouse_over_widget && mouse_went_up)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, widget_value
end

#####
##### TextBox
#####

get_widget_value(::TextBox, hot_widget, active_widget, this_widget) = (hot_widget == this_widget) && (active_widget == this_widget)

function do_widget(widget_type::TextBox, hot_widget, active_widget, null_widget, this_widget, i_mouse, j_mouse, ended_down, num_transitions, characters, i_min, j_min, i_max, j_max)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget && mouse_went_up)

    widget_value = get_widget_value(widget_type, hot_widget, active_widget, this_widget)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget && mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, widget_value
end

#####
##### CheckBox
#####

function do_widget(widget_type::Union{CheckBox, RadioButton, DropDown}, hot_widget, active_widget, null_widget, this_widget, widget_value, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
    hot_widget, active_widget, null_widget, button_value = do_widget(BUTTON, hot_widget, active_widget, null_widget, this_widget, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)

    if button_value
        widget_value = !widget_value
    end

    return hot_widget, active_widget, null_widget, widget_value
end

#####
##### Slider
#####

function get_widget_value(widget_type::Slider, hot_widget, active_widget, this_widget, i_bar_wrt_slider, j_bar_wrt_slider, height_bar, width_bar, i_bar_wrt_mouse, j_bar_wrt_mouse, i_mouse, j_mouse, i_min_slider, j_min_slider, i_max_slider, j_max_slider)
    if (hot_widget == this_widget) && (active_widget == this_widget)
        i_bar_wrt_slider = i_mouse + i_bar_wrt_mouse - i_min_slider
        j_bar_wrt_slider = j_mouse + j_bar_wrt_mouse - j_min_slider

        i_bar_wrt_slider = clamp(i_bar_wrt_slider, zero(i_bar_wrt_slider), i_max_slider - i_min_slider + one(i_min_slider) - height_bar)
        j_bar_wrt_slider = clamp(j_bar_wrt_slider, zero(j_bar_wrt_slider), j_max_slider - j_min_slider + one(j_min_slider) - width_bar)

        return i_bar_wrt_slider, j_bar_wrt_slider
    else
        return i_bar_wrt_slider, j_bar_wrt_slider
    end
end

get_scroll_value(i_bar_wrt_slider, length_bar, length_slider, length_view, length_full) = i_bar_wrt_slider * (length_full - length_view) ÷ (length_slider - length_bar)

get_bar_length(min_length_bar, length_slider, length_view, length_full) = max(min_length_bar, (length_slider * length_view) ÷ length_full)

function do_widget(widget_type::Slider, hot_widget, active_widget, null_widget, this_widget, i_bar_wrt_slider, j_bar_wrt_slider, height_bar, width_bar, i_bar_wrt_mouse, j_bar_wrt_mouse, height_slider, width_slider, i_mouse, j_mouse, ended_down, num_transitions, i_min_slider, j_min_slider, i_max_slider, j_max_slider)
    height_slider = i_max_slider - i_min_slider + one(i_min_slider)
    width_slider = j_max_slider - j_min_slider + one(j_min_slider)

    i_min_bar = i_min_slider + i_bar_wrt_slider
    j_min_bar = j_min_slider + j_bar_wrt_slider

    i_max_bar = i_min_bar + height_bar - one(height_bar)
    j_max_bar = j_min_bar + width_bar - one(height_bar)

    mouse_over_bar = (i_min_bar <= i_mouse <= i_max_bar) && (j_min_bar <= j_mouse <= j_max_bar)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_bar)

    # i_bar_wrt_mouse becomes freely changeable (controlled by the mouse) when the slider is in hot state
    # this i_bar_wrt_mouse then constrains the i_bar_wrt_slider when the slider becomes active
    if (hot_widget == this_widget) && (active_widget == null_widget)
        i_bar_wrt_mouse = i_min_bar - i_mouse
        j_bar_wrt_mouse = j_min_bar - j_mouse
    end

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_bar && mouse_went_down)

    i_bar_wrt_slider, j_bar_wrt_slider = get_widget_value(widget_type, hot_widget, active_widget, this_widget, i_bar_wrt_slider, j_bar_wrt_slider, height_bar, width_bar, i_bar_wrt_mouse, j_bar_wrt_mouse, i_mouse, j_mouse, i_min_slider, j_min_slider, i_max_slider, j_max_slider)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_bar)

    return hot_widget, active_widget, null_widget, (i_bar_wrt_slider, j_bar_wrt_slider, height_bar, width_bar, i_bar_wrt_mouse, j_bar_wrt_mouse, height_slider, width_slider)
end
