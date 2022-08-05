abstract type AbstractLayout end

mutable struct BoxLayout{I} <: AbstractLayout
    reference_bounding_box::SD.Rectangle{I}
end

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

function get_alignment_offset(total_height, total_width, content_height, content_width, alignment, padding)
    I = typeof(total_height)

    if alignment == UP_OUT_LEFT_OUT
        return (convert(I, -content_height - padding), convert(I, -content_width - padding))
    elseif alignment == UP_IN_LEFT_OUT
        return (zero(I), convert(I, -content_width - padding))
    elseif alignment == LEFT_OUT
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, -content_width - padding))
    elseif alignment == DOWN_IN_LEFT_OUT
        return (convert(I, total_height - content_height), convert(I, -content_width - padding))
    elseif alignment == DOWN_OUT_LEFT_OUT
        return (convert(I, total_height + padding), convert(I, -content_width - padding))

    elseif alignment == UP_OUT_LEFT_IN
        return (convert(I, -content_height - padding), zero(I))
    elseif alignment == UP_IN_LEFT_IN
        return (convert(I, padding), convert(I, padding + 1))
    elseif alignment == LEFT_IN
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, padding + 1))
    elseif alignment == DOWN_IN_LEFT_IN
        return (convert(I, total_height - content_height - padding - 1), convert(I, padding + 1))
    elseif alignment == DOWN_OUT_LEFT_IN
        return (convert(I, total_height + padding), zero(I))

    elseif alignment == UP_OUT
        return (convert(I, -content_height - padding), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == UP_IN
        return (convert(I, padding + 1), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == CENTER
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == DOWN_IN
        return (convert(I, total_height - content_height - padding - 1), convert(I, (total_width - content_width) ÷ 2))
    elseif alignment == DOWN_OUT
        return (convert(I, total_height + padding), convert(I, (total_width - content_width) ÷ 2))

    elseif alignment == UP_OUT_RIGHT_IN
        return (convert(I, -content_height - padding), convert(I, total_width - content_width))
    elseif alignment == UP_IN_RIGHT_IN
        return (convert(I, padding + 1), convert(I, total_width - content_width - padding - 1))
    elseif alignment == RIGHT_IN
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, total_width - content_width - padding - 1))
    elseif alignment == DOWN_IN_RIGHT_IN
        return (convert(I, total_height - content_height - padding - 1), convert(I, total_width - content_width - padding - 1))
    elseif alignment == DOWN_OUT_RIGHT_IN
        return (convert(I, total_height + padding), convert(I, total_width - content_width))

    elseif alignment == UP_OUT_RIGHT_OUT
        return (convert(I, -content_height - padding), convert(I, total_width + padding))
    elseif alignment == UP_IN_RIGHT_OUT
        return (zero(I), convert(I, total_width + padding))
    elseif alignment == RIGHT_OUT
        return (convert(I, (total_height - content_height) ÷ 2), convert(I, total_width + padding))
    elseif alignment == DOWN_IN_RIGHT_OUT
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

function get_bounding_box(bounding_box::SD.Rectangle, alignment::Alignment, padding, height, width)
    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, height, width, alignment, padding)
    return SD.Rectangle(SD.move(bounding_box.position, i_offset, j_offset), height, width)
end
