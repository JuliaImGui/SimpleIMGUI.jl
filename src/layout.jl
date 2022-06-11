abstract type AbstractLayout end

struct BoxLayout <: AbstractLayout
    bounding_box::SD.Rectangle
end

abstract type AbstractDirection end

struct Vertical <: AbstractDirection end
const VERTICAL = Vertical()

struct Horizontal <: AbstractDirection end
const HORIZONTAL = Horizontal()

update_layout(layout::BoxLayout, ::Vertical, height, width) = BoxLayout(SD.Rectangle(layout.bounding_box.position, layout.bounding_box.height + height, max(layout.bounding_box.width, width)))

update_layout(layout::BoxLayout, ::Horizontal, height, width) = BoxLayout(SD.Rectangle(layout.bounding_box.position, max(layout.bounding_box.height, height), layout.bounding_box.width + width))

function get_widget_position(layout::BoxLayout, ::Vertical)
    i_max = SD.get_i_max(layout.bounding_box)
    return SD.Point(i_max + one(i_max), SD.get_j_min(layout.bounding_box))
end

function get_widget_position(layout::BoxLayout, ::Horizontal)
    j_max = SD.get_j_max(layout.bounding_box)
    return SD.Point(SD.get_i_min(layout.bounding_box), j_max + one(j_max))
end

function get_widget_bounding_box(layout::BoxLayout, direction::AbstractDirection, height, width)
    widget_position = get_widget_position(layout, direction)
    return SD.Rectangle(widget_position, height, width)
end

add_widget(layout::BoxLayout, direction::AbstractDirection, height, width) = update_layout(layout, direction, height, width), get_widget_bounding_box(layout, direction, height, width)
