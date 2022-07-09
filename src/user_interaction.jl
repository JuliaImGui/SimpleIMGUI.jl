abstract type AbstractWidgetID end

struct WidgetID <: AbstractWidgetID
    file::String
    line::Int
    instance::Int
end

abstract type AbstractUserInteractionState end

mutable struct UserInteractionState <: AbstractUserInteractionState
    hot_widget::WidgetID
    active_widget::WidgetID
    null_widget::WidgetID
end

const NULL_WIDGET_ID = WidgetID("", 0, 0)
