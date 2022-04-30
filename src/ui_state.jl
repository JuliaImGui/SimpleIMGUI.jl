abstract type AbstractWidgetID end

struct WidgetID <: AbstractWidgetID
    line_number::Int
    file_name::String
end

abstract type AbstractUIState end

const NULL_WIDGET_ID = WidgetID(0, "")

function widget!(ui_state::AbstractUIState, args...; kwargs...)
    hot_widget, active_widget, null_widget, values = widget!!(ui_state.hot_widget, ui_state.active_widget, ui_state.null_widget, args...; kwargs...)

    ui_state.hot_widget = hot_widget
    ui_state.active_widget = active_widget
    ui_state.null_widget = null_widget

    return values
end
