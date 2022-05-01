abstract type AbstractWidgetID end

struct WidgetID <: AbstractWidgetID
    line_number::Int
    file_name::String
end

abstract type AbstractUIState end

const NULL_WIDGET_ID = WidgetID(0, "")

function do_widget!(user_interaction_state::AbstractUIState, args...; kwargs...)
    hot_widget, active_widget, null_widget, values = do_widget!!(user_interaction_state.hot_widget, user_interaction_state.active_widget, user_interaction_state.null_widget, args...; kwargs...)

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    return values
end
