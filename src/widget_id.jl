abstract type AbstractWidgetID end

struct WidgetID <: AbstractWidgetID
    line_number::Int
    file_name::String
end

const NULL_WIDGET_ID = WidgetID(0, "")
