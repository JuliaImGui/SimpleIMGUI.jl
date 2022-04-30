struct WidgetID
    line_number::Int
    file_name::String
end

const NULL_WIDGET_ID = WidgetID(0, "")

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
