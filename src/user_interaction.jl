abstract type AbstractWidgetID end

struct WidgetID{S} <: AbstractWidgetID
    file::S
    line::Int
    instance::Int
end

abstract type AbstractUserInteractionState end

mutable struct UserInteractionState{S} <: AbstractUserInteractionState
    hot_widget::WidgetID{S}
    active_widget::WidgetID{S}
    null_widget::WidgetID{S}
end

const NULL_WIDGET_ID = WidgetID("", 0, 0)
