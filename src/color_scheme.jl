struct ContextualColor{C}
    neutral_color::C
    hot_color::C
    active_color::C
end

get_color(user_interaction_state, this_widget, color) = color

function get_color(user_interaction_state, this_widget, color::ContextualColor)
    if this_widget == user_interaction_state.active_widget
        return color.active_color
    elseif this_widget == user_interaction_state.hot_widget
        return color.hot_color
    else
        return color.neutral_color
    end
end
