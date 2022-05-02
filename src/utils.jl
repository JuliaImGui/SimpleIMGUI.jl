went_down(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && ended_down)
went_down(input_button) = went_down(input_button.ended_down, input_button.half_transition_count)

went_up(ended_down, half_transition_count) = (half_transition_count >= 2) || ((half_transition_count == 1) && !ended_down)
went_up(input_button) = went_up(input_button.ended_down, input_button.half_transition_count)

function try_set_hot_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (active_widget == null_widget) && condition
        return widget
    else
        return hot_widget
    end
end

function try_set_active_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (hot_widget == widget) && (active_widget == null_widget) && condition
        return widget
    else
        return active_widget
    end
end

function try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (hot_widget == widget) && (active_widget != widget) && condition
        return null_widget
    else
        return hot_widget
    end
end

function try_reset_active_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (active_widget == widget) && (hot_widget == widget) && condition
        return null_widget
    else
        return active_widget
    end
end
