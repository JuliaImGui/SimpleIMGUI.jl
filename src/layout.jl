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
        UP2_LEFT2
        UP1_LEFT2
        LEFT2
        DOWN1_LEFT2
        DOWN2_LEFT2

        UP2_LEFT1
        UP1_LEFT1
        LEFT1
        DOWN1_LEFT1
        DOWN2_LEFT1

        UP2
        UP1
        CENTER
        DOWN1
        DOWN2

        UP2_RIGHT1
        UP1_RIGHT1
        RIGHT1
        DOWN1_RIGHT1
        DOWN2_RIGHT1

        UP2_RIGHT2
        UP1_RIGHT2
        RIGHT2
        DOWN1_RIGHT2
        DOWN2_RIGHT2
    end

Enumerate 25 different spatial locations with respect to a reference bounding box (rectangle). Used for specifying where further widgets and content are placed with respect to the reference bounding box.

Think of the 25 regions arranged in a 5 x 5 grid (see example). The names of the regions correspond to positions relative to the center region. For example, `DOWN2_LEFT1` corresponds to the region that is 2 hops below and 1 hop to the left of the center region. It corresponds to the rectangle whose top left point is at (30, 5) in the example below.

# Examples
```julia-repl
julia> import SimpleDraw

julia> image_height = 32; image_width = 64;

julia> image = falses(image_height, image_width); color = true;

julia> total_height = 22; total_width = 33; content_height = 3; content_width = 6; padding = 2;

julia> function draw_alignment_combinations!(image, color, total_height, total_width, padding, content_height, content_width)
           reference_bounding_box = SimpleDraw.Rectangle(SimpleDraw.Point(content_height + padding + one(padding), content_width + padding + one(padding)), total_height, total_width)
           SimpleDraw.draw!(image, reference_bounding_box, color)

           for alignment in instances(SimpleIMGUI.Alignment)
               content_bounding_box = SimpleIMGUI.get_alignment_bounding_box(reference_bounding_box, alignment, padding, content_height, content_width)
               SimpleDraw.draw!(image, content_bounding_box, color)
           end

           return nothing
       end
draw_alignment_combinations! (generic function with 1 method)

julia> draw_alignment_combinations!(image, color, total_height, total_width, padding, content_height, content_width)

julia> SimpleDraw.visualize(image)
   1 2 3 4 5 6 7 8 910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364
 1████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 2██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 3████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 4▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 5░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 6████████████▒▒░░██████████████████████████████████████████████████████████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 7██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 8████████████▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 9░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░████████████▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
10▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
11░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░████████████▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
12▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
13░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
14▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
15████████████░░▒▒██▒▒░░████████████▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
16██░░▒▒░░▒▒██▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
17████████████░░▒▒██▒▒░░████████████▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
18▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
19░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
20▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
21░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
22▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒████████████░░▒▒░░▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
23░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
24▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒████████████░░▒▒░░▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
25████████████░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
26██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
27████████████░░▒▒██████████████████████████████████████████████████████████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
28▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
29░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
30████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
31██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
32████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
```
"""
@enum Alignment begin
    UP2_LEFT2 = 1
    UP1_LEFT2
    LEFT2
    DOWN1_LEFT2
    DOWN2_LEFT2

    UP2_LEFT1
    UP1_LEFT1
    LEFT1
    DOWN1_LEFT1
    DOWN2_LEFT1

    UP2
    UP1
    CENTER
    DOWN1
    DOWN2

    UP2_RIGHT1
    UP1_RIGHT1
    RIGHT1
    DOWN1_RIGHT1
    DOWN2_RIGHT1

    UP2_RIGHT2
    UP1_RIGHT2
    RIGHT2
    DOWN1_RIGHT2
    DOWN2_RIGHT2
end

"""
    get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)

Return the offset relative to the top left corner of a reference bounding box such that a content of height `content_height` and width `content_width` is placed with alignment `alignment` and padding `padding` with respect to the reference bounding box of height `total_height` and width `total_width`.

See also [`get_alignment_bounding_box`](@ref).

# Examples
```julia-repl
julia> total_height = 21; total_width = 32; content_height = 3; content_width = 6; padding = 2;

julia> alignment = SimpleIMGUI.UP2_LEFT2
UP2_LEFT2::Alignment = 0

julia> SimpleIMGUI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)
(-5, -8)

julia> alignment = SimpleIMGUI.UP1
UP2_LEFT2::Alignment = 11

julia> SimpleIMGUI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)
(3, 13)
```
"""
function get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width)
    total_height_promoted, total_width_promoted, content_height_promoted, content_width_promoted, padding_promoted = promote(total_height, total_width, content_height, content_width, padding)
    return get_alignment_offset(total_width_promoted, total_width_promoted, alignment, padding_promoted, content_height_promoted, content_width_promoted)
end

function get_alignment_offset(total_height::I, total_width::I, alignment, padding::I, content_height::I, content_width::I) where {I}
    if alignment == UP2_LEFT2
        return (-content_height - padding, -content_width - padding)
    elseif alignment == UP1_LEFT2
        return (zero(I), -content_width - padding)
    elseif alignment == LEFT2
        return ((total_height - content_height) ÷ convert(I, 2), -content_width - padding)
    elseif alignment == DOWN1_LEFT2
        return (total_height - content_height, -content_width - padding)
    elseif alignment == DOWN2_LEFT2
        return (total_height + padding, -content_width - padding)

    elseif alignment == UP2_LEFT1
        return (-content_height - padding, zero(I))
    elseif alignment == UP1_LEFT1
        return (padding + one(I), padding + one(I))
    elseif alignment == LEFT1
        return ((total_height - content_height) ÷ convert(I, 2), padding + one(I))
    elseif alignment == DOWN1_LEFT1
        return (total_height - content_height - padding - one(I), padding + one(I))
    elseif alignment == DOWN2_LEFT1
        return (total_height + padding, zero(I))

    elseif alignment == UP2
        return (-content_height - padding, (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == UP1
        return (padding + one(I), (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == CENTER
        return ((total_height - content_height) ÷ convert(I, 2), (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == DOWN1
        return (total_height - content_height - padding - one(I), (total_width - content_width) ÷ convert(I, 2))
    elseif alignment == DOWN2
        return (total_height + padding, (total_width - content_width) ÷ convert(I, 2))

    elseif alignment == UP2_RIGHT1
        return (-content_height - padding, total_width - content_width)
    elseif alignment == UP1_RIGHT1
        return (padding + one(I), total_width - content_width - padding - one(I))
    elseif alignment == RIGHT1
        return ((total_height - content_height) ÷ convert(I, 2), total_width - content_width - padding - one(I))
    elseif alignment == DOWN1_RIGHT1
        return (total_height - content_height - padding - one(I), total_width - content_width - padding - one(I))
    elseif alignment == DOWN2_RIGHT1
        return (total_height + padding, total_width - content_width)

    elseif alignment == UP2_RIGHT2
        return (-content_height - padding, total_width + padding)
    elseif alignment == UP1_RIGHT2
        return (zero(I), total_width + padding)
    elseif alignment == RIGHT2
        return ((total_height - content_height) ÷ convert(I, 2), total_width + padding)
    elseif alignment == DOWN1_RIGHT2
        return (total_height - content_height, total_width + padding)
    else
        return (total_height + padding, total_width + padding)
    end
end

"""
    get_enclosing_bounding_box(shapes...)

Return a bounding box (preferably the smallest one) that encloses all the shapes in `shapes`.

# Examples
```julia-repl
julia> import SimpleDraw

julia> shape1 = SimpleDraw.Rectangle(SimpleDraw.Point(2, 3), 4, 5)
SimpleDraw.Rectangle{Int64}(SimpleDraw.Point{Int64}(2, 3), 4, 5)

julia> shape2 = SimpleDraw.Rectangle(SimpleDraw.Point(4, 5), 6, 7)
SimpleDraw.Rectangle{Int64}(SimpleDraw.Point{Int64}(4, 5), 6, 7)

julia> SimpleIMGUI.get_enclosing_bounding_box(shape1, shape2)
SimpleDraw.Rectangle{Int64}(SimpleDraw.Point{Int64}(2, 3), 8, 9)
```
"""
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

julia> alignment = SimpleIMGUI.UP2_LEFT2
UP2_LEFT2::Alignment = 0

julia> SimpleIMGUI.get_alignment_bounding_box(bounding_box, alignment, padding, height, width)
SimpleDraw.Rectangle{Int64}(SimpleDraw.Point{Int64}(1, 1), 3, 6)

julia> alignment = SimpleIMGUI.UP1
UP2_LEFT2::Alignment = 11

julia> SimpleIMGUI.get_alignment_bounding_box(bounding_box, alignment, padding, height, width)
SimpleDraw.Rectangle{Int64}(SimpleDraw.Point{Int64}(9, 22), 3, 6)
```
"""
function get_alignment_bounding_box(bounding_box, alignment, padding, height, width)
    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, alignment, padding, height, width)
    return SD.Rectangle(SD.move(bounding_box.position, i_offset, j_offset), height, width)
end
