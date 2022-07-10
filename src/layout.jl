abstract type AbstractLayout end

mutable struct BoxLayout <: AbstractLayout
    reference_bounding_box::SD.Rectangle{Int}
    widget_bounding_box::SD.Rectangle{Int}
end

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

function get_alignment_offset(total_height, total_width, content_height, content_width, alignment, padding)
    I = typeof(total_height)

    if alignment == UP2_LEFT2
        return (convert(I, -content_height - padding), convert(I, -content_width - padding))
    elseif alignment == UP1_LEFT2
        return (zero(I), convert(I, -content_width - padding))
    elseif alignment == LEFT2
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, -content_width - padding))
    elseif alignment == DOWN1_LEFT2
        return (convert(I, total_height - content_height), convert(I, -content_width - padding))
    elseif alignment == DOWN2_LEFT2
        return (convert(I, total_height + padding), convert(I, -content_width - padding))

    elseif alignment == UP2_LEFT1
        return (convert(I, -content_height - padding), zero(I))
    elseif alignment == UP1_LEFT1
        return (convert(I, padding), convert(I, padding + 1))
    elseif alignment == LEFT1
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, padding + 1))
    elseif alignment == DOWN1_LEFT1
        return (convert(I, total_height - content_height - padding - 1), convert(I, padding + 1))
    elseif alignment == DOWN2_LEFT1
        return (convert(I, total_height + padding), zero(I))

    elseif alignment == UP2
        return (convert(I, -content_height - padding), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == UP1
        return (convert(I, padding + 1), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == CENTER
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == DOWN1
        return (convert(I, total_height - content_height - padding - 1), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == DOWN2
        return (convert(I, total_height + padding), convert(I, (total_width - content_width) ÷ 2))

    elseif alignment == UP2_RIGHT1
        return (convert(I, -content_height - padding), convert(I, total_width - content_width))
    elseif alignment == UP1_RIGHT1
        return (convert(I, padding + 1), convert(I, total_width - content_width - padding - 1))
    elseif alignment == RIGHT1
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, total_width - content_width - padding - 1))
    elseif alignment == DOWN1_RIGHT1
        return (convert(I, total_height - content_height - padding - 1), convert(I, total_width - content_width - padding - 1))
    elseif alignment == DOWN2_RIGHT1
        return (convert(I, total_height + padding), convert(I, total_width - content_width))

    elseif alignment == UP2_RIGHT2
        return (convert(I, -content_height - padding), convert(I, total_width + padding))
    elseif alignment == UP1_RIGHT2
        return (zero(I), convert(I, total_width + padding))
    elseif alignment == RIGHT2
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, total_width + padding))
    elseif alignment == DOWN1_RIGHT2
        return (convert(I, total_height - content_height), convert(I, total_width + padding))
    else
        return (convert(I, total_height + padding), convert(I, total_width + padding))
    end
end

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

function get_bounding_box(bounding_box::SD.Rectangle, alignment::Alignment, height, width, padding)
    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, height, width, alignment, padding)
    return SD.Rectangle(SD.move(bounding_box.position, i_offset, j_offset), height, width)
end
