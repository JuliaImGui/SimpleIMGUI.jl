struct WidgetID
    line_number::Int
    file_name::String
end

const NULL_WIDGET_ID = WidgetID(0, "")

abstract type AbstractWidget end

struct UIButton <: AbstractWidget end
const UI_BUTTON = UIButton()

went_down(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && ended_down)
went_up(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && !ended_down)

function try_set_hot_widget(hot_widget, active_widget, widget, condition)
    if (active_widget == NULL_WIDGET_ID) && condition
        return widget
    else
        return hot_widget
    end
end

function try_set_active_widget(hot_widget, active_widget, widget, condition)
    if (hot_widget == widget) && (active_widget == NULL_WIDGET_ID) && condition
        return widget
    else
        return active_widget
    end
end

function try_reset_hot_widget(hot_widget, active_widget, widget, condition)
    if (hot_widget == widget) && (active_widget != widget) && condition
        return NULL_WIDGET_ID
    else
        return hot_widget
    end
end

function try_reset_active_widget(hot_widget, active_widget, widget, condition)
    if (active_widget == widget) && (hot_widget == widget) && condition
        return NULL_WIDGET_ID
    else
        return active_widget
    end
end

function get_widget_value(hot_widget, active_widget, widget, ::UIButton, condition)
    if (active_widget == widget) && (hot_widget == widget) && condition
        return true
    else
        return false
    end
end

function widget(hot_widget, active_widget, widget, widget_type::UIButton, i_min, j_min, i_max, j_max, i_mouse, j_mouse, ended_down, half_transition_count)
    mouse_over_button = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, half_transition_count)
    mouse_went_up = went_up(ended_down, half_transition_count)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, widget, mouse_over_button)

    active_widget = try_set_active_widget(hot_widget, active_widget, widget, mouse_over_button && mouse_went_down)

    value = get_widget_value(hot_widget, active_widget, widget, widget_type, mouse_over_button && mouse_went_up)

    active_widget = try_reset_active_widget(hot_widget, active_widget, widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, widget, !mouse_over_button)

    return hot_widget, active_widget, value
end
