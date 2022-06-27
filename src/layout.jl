abstract type AbstractLayout end

struct BoxLayout <: AbstractLayout
    bounding_box::SD.Rectangle
end

abstract type AbstractDirection end

struct Vertical <: AbstractDirection end
const VERTICAL = Vertical()

struct Horizontal <: AbstractDirection end
const HORIZONTAL = Horizontal()

function get_bounding_box(shapes...)
    shape1 = shapes[1]
    i_min = SD.get_i_min(shape1)
    j_min = SD.get_j_min(shape1)
    i_max = SD.get_i_max(shape1)
    j_max = SD.get_j_max(shape1)

    for shape in shapes
        i_min = min(i_min, SD.get_i_min(shape))
        j_min = min(j_min, SD.get_j_min(shape))
        i_max = max(i_max, SD.get_i_max(shape))
        j_max = max(j_max, SD.get_j_max(shape))
    end

    return SD.Rectangle(SD.Point(i_min, j_min), i_max - i_min + one(i_min), j_max - j_min + one(j_min))
end

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

update_layout(layout::BoxLayout, bounding_box::SD.Rectangle) = BoxLayout(get_bounding_box(layout.bounding_box, bounding_box))

function add_widget(layout::BoxLayout, direction::AbstractDirection, height, width)
    widget_bounding_box = get_widget_bounding_box(layout, direction, height, width)
    new_layout = update_layout(layout, widget_bounding_box)
    return new_layout, widget_bounding_box
end
