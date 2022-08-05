abstract type AbstractWidgetID end

struct WidgetID{S, I} <: AbstractWidgetID
    file::S
    line::I
    instance::I
end

abstract type AbstractUserInteractionState end

mutable struct UserInteractionState{S, I} <: AbstractUserInteractionState
    hot_widget::WidgetID{S, I}
    active_widget::WidgetID{S, I}
    null_widget::WidgetID{S, I}
end

const NULL_WIDGET_ID = WidgetID("", 0, 0)
