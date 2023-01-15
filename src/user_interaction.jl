abstract type AbstractWidgetID end

"""
    struct WidgetID{S, I} <: AbstractWidgetID
        file::S
        line::I
        instance::I
    end

Store the file name, line number, and instance number corresponding to a widget. These three together can be used to uniquely identify a widget.
"""
struct WidgetID{S, I} <: AbstractWidgetID
    file::S
    line::I
    instance::I
end

const NULL_WIDGET_ID = WidgetID("", 0, 0)

abstract type AbstractUserInteractionState end

"""
    mutable struct UserInteractionState{T <: AbstractWidgetID} <: AbstractUserInteractionState
        hot_widget::T
        active_widget::T
        null_widget::T
    end

Store the hot widget, active widget, and null widget. Used to keep track of the state of the user interaction. `hot_widget` is the widget that is about to be interacted with and `active_widget` is the widget that is actually being interacted with.
"""
mutable struct UserInteractionState{T <: AbstractWidgetID} <: AbstractUserInteractionState
    hot_widget::T
    active_widget::T
    null_widget::T
end
