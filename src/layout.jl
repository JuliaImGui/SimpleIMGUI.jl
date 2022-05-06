abstract type AbstractLayout end

struct BoxLayout <: AbstractLayout
    bounding_box::BoundingBox
end

abstract type AbstractDirection end

struct Vertical <: AbstractDirection end
const VERTICAL = Vertical()

struct Horizontal <: AbstractDirection end
const HORIZONTAL = Horizontal()

update_layout(layout::BoxLayout, ::Vertical, height, width) = BoxLayout(BoundingBox(layout.bounding_box.i_min, layout.bounding_box.j_min, layout.bounding_box.i_max + height, max(layout.bounding_box.j_max, layout.bounding_box.j_min + width - one(width))))

update_layout(layout::BoxLayout, ::Horizontal, height, width) = BoxLayout(BoundingBox(layout.bounding_box.i_min, layout.bounding_box.j_min, max(layout.bounding_box.i_max, layout.bounding_box.i_min + height - one(height)), layout.bounding_box.j_max + width))

get_widget_position(layout::BoxLayout, ::Vertical) = Point(layout.bounding_box.i_max + one(layout.bounding_box.i_max), layout.bounding_box.j_min)

get_widget_position(layout::BoxLayout, ::Horizontal) = Point(layout.bounding_box.i_min, layout.bounding_box.j_max + one(layout.bounding_box.j_max))

function get_widget_bounding_box(layout::BoxLayout, direction::AbstractDirection, height, width)
    widget_position = get_widget_position(layout, direction)
    return BoundingBox(widget_position, height, width)
end

add_widget(layout::BoxLayout, direction::AbstractDirection, height, width) = update_layout(layout, direction, height, width), get_widget_bounding_box(layout, direction, height, width)
