abstract type AbstractLayout end

"""
    mutable struct BoxLayout{I} <: AbstractLayout
        reference_bounding_box::SD.Rectangle{I}
    end

Keep track of a reference bounding box (rectangle) with respect to which further widgets and content are placed spatially.
"""
mutable struct BoxLayout{I} <: AbstractLayout
    reference_bounding_box::SD.Rectangle{I}
end

"""
    @enum Alignment begin
        UP_OUT_LEFT_OUT
        UP_IN_LEFT_OUT
        LEFT_OUT
        DOWN_IN_LEFT_OUT
        DOWN_OUT_LEFT_OUT

        UP_OUT_LEFT_IN
        UP_IN_LEFT_IN
        LEFT_IN
        DOWN_IN_LEFT_IN
        DOWN_OUT_LEFT_IN

        UP_OUT
        UP_IN
        CENTER
        DOWN_IN
        DOWN_OUT

        UP_OUT_RIGHT_IN
        UP_IN_RIGHT_IN
        RIGHT_IN
        DOWN_IN_RIGHT_IN
        DOWN_OUT_RIGHT_IN

        UP_OUT_RIGHT_OUT
        UP_IN_RIGHT_OUT
        RIGHT_OUT
        DOWN_IN_RIGHT_OUT
        DOWN_OUT_RIGHT_OUT
    end

Enumerate 25 different spatial locations with respect to a reference bounding box (rectangle). Used for specifying where further widgets and content are placed with respect to the reference bounding box.
"""
@enum Alignment begin
    UP_OUT_LEFT_OUT
    UP_IN_LEFT_OUT
    LEFT_OUT
    DOWN_IN_LEFT_OUT
    DOWN_OUT_LEFT_OUT

    UP_OUT_LEFT_IN
    UP_IN_LEFT_IN
    LEFT_IN
    DOWN_IN_LEFT_IN
    DOWN_OUT_LEFT_IN

    UP_OUT
    UP_IN
    CENTER
    DOWN_IN
    DOWN_OUT

    UP_OUT_RIGHT_IN
    UP_IN_RIGHT_IN
    RIGHT_IN
    DOWN_IN_RIGHT_IN
    DOWN_OUT_RIGHT_IN

    UP_OUT_RIGHT_OUT
    UP_IN_RIGHT_OUT
    RIGHT_OUT
    DOWN_IN_RIGHT_OUT
    DOWN_OUT_RIGHT_OUT
end

"""
    get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)

Return the offset relative to the top left corner of a reference bounding box such that a content of height `content_height` and width `content_width` is placed with alignment `alignment` and padding `padding` with respect to the reference bounding box of height `total_height` and width `total_width`.

See also [`get_alignment_bounding_box`](@ref).

# Examples
```julia-repl
julia> total_height = 21; total_width = 32; content_height = 3; content_width = 6; padding = 2;

julia> alignment = SimpleIMGUI.UP_OUT_LEFT_OUT
UP_OUT_LEFT_OUT::Alignment = 0

julia> SimpleIMGUI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)
(-5, -8)

julia> alignment = SimpleIMGUI.UP_IN
UP_OUT_LEFT_OUT::Alignment = 11

julia> SimpleIMGUI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)
(3, 13)
```
"""
function get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)
    total_height_promoted, total_width_promoted, content_height_promoted, content_width_promoted, padding_promoted = promote(total_height, total_width, content_height, content_width, padding)
    return get_alignment_offset(total_width_promoted, total_width_promoted, alignment, padding_promoted, content_height_promoted, content_width_promoted)
end

function get_alignment_offset(total_height::I, total_width::I, alignment, padding::I, content_height::I, content_width::I) where {I}
    if alignment == UP_OUT_LEFT_OUT
        return (-content_height - padding, -content_width - padding)
    elseif alignment == UP_IN_LEFT_OUT
        return (zero(I), -content_width - padding)
    elseif alignment == LEFT_OUT
        return ((total_height - content_height) ÷ convert(I, 2), -content_width - padding)
    elseif alignment == DOWN_IN_LEFT_OUT
        return (total_height - content_height, -content_width - padding)
    elseif alignment == DOWN_OUT_LEFT_OUT
        return (total_height + padding, -content_width - padding)

    elseif alignment == UP_OUT_LEFT_IN
        return (-content_height - padding, zero(I))
    elseif alignment == UP_IN_LEFT_IN
        return (padding + one(I), padding + one(I))
    elseif alignment == LEFT_IN
        return ((total_height - content_height) ÷ convert(I, 2), padding + one(I))
    elseif alignment == DOWN_IN_LEFT_IN
        return (total_height - content_height - padding - one(I), padding + one(I))
    elseif alignment == DOWN_OUT_LEFT_IN
        return (total_height + padding, zero(I))

    elseif alignment == UP_OUT
        return (-content_height - padding, (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == UP_IN
        return (padding + one(I), (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == CENTER
        return ((total_height - content_height) ÷ convert(I, 2), (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == DOWN_IN
        return (total_height - content_height - padding - one(I), (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == DOWN_OUT
        return (total_height + padding, (total_width - content_width) ÷ convert(I, 2))

    elseif alignment == UP_OUT_RIGHT_IN
        return (-content_height - padding, total_width - content_width)
    elseif alignment == UP_IN_RIGHT_IN
        return (padding + one(I), total_width - content_width - padding - one(I))
    elseif alignment == RIGHT_IN
        return ((total_height - content_height) ÷ convert(I, 2), total_width - content_width - padding - one(I))
    elseif alignment == DOWN_IN_RIGHT_IN
        return (total_height - content_height - padding - one(I), total_width - content_width - padding - one(I))
    elseif alignment == DOWN_OUT_RIGHT_IN
        return (total_height + padding, total_width - content_width)

    elseif alignment == UP_OUT_RIGHT_OUT
        return (-content_height - padding, total_width + padding)
    elseif alignment == UP_IN_RIGHT_OUT
        return (zero(I), total_width + padding)
    elseif alignment == RIGHT_OUT
        return ((total_height - content_height) ÷ convert(I, 2), total_width + padding)
    elseif alignment == DOWN_IN_RIGHT_OUT
        return (total_height - content_height, total_width + padding)
    else
        return (total_height + padding, total_width + padding)
    end
end

function get_enclosing_bounding_box(shapes...)
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

"""
    get_alignment_bounding_box(bounding_box, alignment, padding, height, width)

Return the bounding box corresponding to the content/widget of height `height` and width `width` placed at alignment `alignment` and padding `padding` with respect to the reference `bounding_box`.

See also [`get_alignment_offset`](@ref).

# Examples
```julia-repl
julia> import SimpleDraw

julia> bounding_box = SimpleDraw.Rectangle(SimpleDraw.Point(6, 9), 21, 32); height = 3; width = 6; padding = 2;

julia> alignment = SimpleIMGUI.UP_OUT_LEFT_OUT
UP_OUT_LEFT_OUT::Alignment = 0

julia> SimpleIMGUI.get_alignment_bounding_box(bounding_box, alignment, padding, height, width)
SimpleDraw.Rectangle{Int64}(SimpleDraw.Point{Int64}(1, 1), 3, 6)

julia> alignment = SimpleIMGUI.UP_IN
UP_OUT_LEFT_OUT::Alignment = 11

julia> SimpleIMGUI.get_alignment_bounding_box(bounding_box, alignment, padding, height, width)
SimpleDraw.Rectangle{Int64}(SimpleDraw.Point{Int64}(9, 22), 3, 6)
```
"""
function get_alignment_bounding_box(bounding_box, alignment, padding, height, width)
    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, alignment, padding, height, width)
    return SD.Rectangle(SD.move(bounding_box.position, i_offset, j_offset), height, width)
end
