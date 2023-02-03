struct BoxedTextLine{I <: Integer, S, F, A, C}
    bounding_box::SD.Rectangle{I}
    text::S
    font::F
    content_alignment::A
    content_padding::I
    background_color::C
    border_color::C
    text_color::C
end

struct TextBoxDrawable{I <: Integer, S, F, A, C}
    bounding_box::SD.Rectangle{I}
    text::S
    font::F
    content_alignment::A
    content_padding::I
    background_color::C
    border_color::C
    text_color::C
    show_cursor::Bool
end

struct CheckBoxIndicator{I <: Integer}
    position::SD.Point{I}
    side_length::I
    value::Bool
end

struct CheckBoxDrawable{I <: Integer, S, F, A, C}
    bounding_box::SD.Rectangle{I}
    text::S
    font::F
    content_alignment::A
    content_padding::I
    background_color::C
    border_color::C
    text_color::C
    indicator_color::C
    value::Bool
end

struct RadioButtonIndicator{I <: Integer}
    position::SD.Point{I}
    diameter::I
    value::Bool
end

struct RadioButtonListDrawable{I <: Integer, S, F, A, C}
    bounding_box::SD.Rectangle{I}
    item_list::S
    font::F
    content_alignment::A
    content_padding::I
    background_color::C
    border_color::C
    text_color::C
    indicator_color::C
    value::I
end

struct DropDownIndicator{I <: Integer}
    position::SD.Point{I}
    side_length::I
    value::Bool
end

struct DropDownDrawable{I <: Integer, S, F, A, C}
    bounding_box::SD.Rectangle{I}
    text::S
    font::F
    content_alignment::A
    content_padding::I
    background_color::C
    border_color::C
    text_color::C
    indicator_color::C
    value::Bool
end

struct SliderDrawable{I <: Integer, S, F, A, C}
    bounding_box::SD.Rectangle{I}
    text::S
    font::F
    content_alignment::A
    content_padding::I
    bar_offset_i::I
    bar_offset_j::I
    bar_height::I
    bar_width::I
    background_color::C
    border_color::C
    text_color::C
    bar_color::C
end

struct ImageDrawable{I <: Integer, A, M, C}
    bounding_box::SD.Rectangle{I}
    content_alignment::A
    content_padding::I
    image::M
    border_color::C
end

function SD.draw!(image, drawable::BoxedTextLine)
    I = typeof(drawable.bounding_box.height)

    bounding_box = drawable.bounding_box
    text = drawable.text
    font = drawable.font
    content_alignment = drawable.content_alignment
    content_padding = drawable.content_padding
    background_color = drawable.background_color
    border_color = drawable.border_color
    text_color = drawable.text_color

    image_bounding_box = SD.Rectangle(SD.Point(one(I), one(I)), size(image)...)
    if is_intersecting(image_bounding_box, bounding_box)
        i_min, j_min, i_max, j_max = get_intersection_extrema(image_bounding_box, bounding_box)
        image_view = @view image[i_min:i_max, j_min:j_max]
    else
        return nothing
    end

    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, SD.get_height(font), SD.get_width(font) * get_num_printable_characters(text))
    SD.draw!(image_view, SD.TextLine(SD.move(SD.Point(one(I), one(I)), i_offset, j_offset), text, font), text_color)

    SD.draw!(image, bounding_box, border_color)

    return nothing
end

function SD.draw!(image, drawable::TextBoxDrawable)
    bounding_box = drawable.bounding_box
    text = drawable.text
    font = drawable.font
    content_alignment = drawable.content_alignment
    content_padding = drawable.content_padding
    background_color = drawable.background_color
    border_color = drawable.border_color
    text_color = drawable.text_color
    show_cursor = drawable.show_cursor

    I = typeof(drawable.bounding_box.height)

    num_printable_characters = get_num_printable_characters(text)

    if num_printable_characters * SD.get_width(font) > bounding_box.width
        content_alignment = RIGHT1
    end

    image_bounding_box = SD.Rectangle(SD.Point(one(I), one(I)), size(image)...)
    if is_intersecting(image_bounding_box, bounding_box)
        i_min, j_min, i_max, j_max = get_intersection_extrema(image_bounding_box, bounding_box)
        image_view = @view image[i_min:i_max, j_min:j_max]
    else
        return nothing
    end

    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, SD.get_height(font), SD.get_width(font) * get_num_printable_characters(text))
    SD.draw!(image_view, SD.TextLine(SD.move(SD.Point(one(I), one(I)), i_offset, j_offset), text, font), text_color)

    if show_cursor
        first_char_position = SD.move(SD.Point(one(I), one(I)), i_offset, j_offset)
        i_offset_first_character, j_offset_first_character = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, SD.get_height(font), SD.get_width(font) * num_printable_characters)
        SD.draw!(image_view, SD.FilledRectangle(SD.move(SD.Point(one(I), one(I)), i_offset_first_character, j_offset_first_character + num_printable_characters * SD.get_width(font)), SD.get_height(font), oftype(SD.get_width(font), 2)), text_color)
    end

    SD.draw!(image, bounding_box, border_color)

    return nothing
end

function SD.draw!(image, shape::CheckBoxIndicator, color)
    position = shape.position
    side_length = shape.side_length
    value = shape.value

    @assert side_length > zero(side_length)

    I = typeof(side_length)

    if value
        SD.draw!(image, SD.FilledRectangle(position, side_length, side_length), color)
    else
        outer_box_thickness = max(convert(I, 1), side_length ÷ convert(I, 4))
        SD.draw!(image, SD.ThickRectangle(position, side_length, side_length, outer_box_thickness), color)
    end

    return nothing
end

function SD.draw!(image, drawable::CheckBoxDrawable)
    I = typeof(drawable.bounding_box.height)

    bounding_box = drawable.bounding_box
    text = drawable.text
    font = drawable.font
    content_alignment = drawable.content_alignment
    content_padding = drawable.content_padding
    background_color = drawable.background_color
    border_color = drawable.border_color
    text_color = drawable.text_color
    indicator_color = drawable.indicator_color
    value = drawable.value

    image_bounding_box = SD.Rectangle(SD.Point(one(I), one(I)), size(image)...)
    if is_intersecting(image_bounding_box, bounding_box)
        i_min, j_min, i_max, j_max = get_intersection_extrema(image_bounding_box, bounding_box)
        image_view = @view image[i_min:i_max, j_min:j_max]
    else
        return nothing
    end

    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    num_printable_characters = get_num_printable_characters(text)
    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, SD.get_height(font), SD.get_width(font) * (num_printable_characters + convert(I, 2)))
    SD.draw!(image_view, SD.TextLine(SD.move(SD.Point(one(I), one(I)), i_offset, j_offset + SD.get_width(font) * convert(I, 2)), text, font), text_color)

    x = min(SD.get_height(font), convert(I, 2) * SD.get_width(font))
    x_div_8 = x ÷ convert(I, 8)
    SD.draw!(image_view, CheckBoxIndicator(SD.move(SD.Point(one(I), one(I)), i_offset + x_div_8, j_offset + x_div_8), (convert(I, 3) * x) ÷ convert(I, 4), value), indicator_color)

    SD.draw!(image, bounding_box, border_color)

    return nothing
end

function SD.draw!(image, shape::RadioButtonIndicator, color)
    position = shape.position
    diameter = shape.diameter
    value = shape.value

    @assert diameter > zero(diameter)

    I = typeof(diameter)

    if value
        SD.draw!(image, SD.FilledCircle(position, diameter), color)
    else
        outer_circle_thickness = max(convert(I, 1), diameter ÷ convert(I, 4))
        SD.draw!(image, SD.ThickCircle(position, diameter, outer_circle_thickness), color)
    end

    return nothing
end

function SD.draw!(image, drawable::RadioButtonListDrawable)
    I = typeof(drawable.bounding_box.height)

    bounding_box = drawable.bounding_box
    item_list = drawable.item_list
    font = drawable.font
    content_alignment = drawable.content_alignment
    content_padding = drawable.content_padding
    background_color = drawable.background_color
    border_color = drawable.border_color
    text_color = drawable.text_color
    indicator_color = drawable.indicator_color
    value = drawable.value

    image_bounding_box = SD.Rectangle(SD.Point(one(I), one(I)), size(image)...)
    if is_intersecting(image_bounding_box, bounding_box)
        i_min, j_min, i_max, j_max = get_intersection_extrema(image_bounding_box, bounding_box)
        image_view = @view image[i_min:i_max, j_min:j_max]
    else
        return nothing
    end

    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    x = min(SD.get_height(font), convert(I, 2) * SD.get_width(font))
    x_div_8 = x ÷ convert(I, 8)

    content_height = length(item_list) * SD.get_height(font)
    content_width = (maximum(get_num_printable_characters, item_list) + 2) * SD.get_width(font)

    i_offset_full, j_offset_full = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, content_height, content_width)

    for (k, text) in enumerate(item_list)
        num_printable_characters = get_num_printable_characters(text)

        i_offset = i_offset_full + (k - one(k)) * SD.get_height(font)
        j_offset = j_offset_full

        SD.draw!(image_view, SD.TextLine(SD.move(SD.Point(one(I), one(I)), i_offset, j_offset + SD.get_width(font) * convert(I, 2)), text, font), text_color)

        SD.draw!(image_view, RadioButtonIndicator(SD.move(SD.Point(one(I), one(I)), i_offset + x_div_8, j_offset + x_div_8), (convert(I, 3) * x) ÷ convert(I, 4), k == value), indicator_color)
    end

    SD.draw!(image, bounding_box, border_color)

    return nothing
end

function SD.draw!(image, shape::DropDownIndicator, color)
    position = shape.position
    side_length = shape.side_length
    value = shape.value

    @assert side_length > zero(side_length)

    I = typeof(side_length)

    if value
        SD.draw!(image, SD.FilledTriangle(position, SD.move_j(position, side_length - one(I)), SD.move(position, side_length - one(I), (side_length + one(I)) ÷ convert(I, 2) - one(I))), color)
    else
        SD.draw!(image, SD.FilledTriangle(position, SD.move_i(position, side_length - one(I)), SD.move(position, (side_length + one(I)) ÷ convert(I, 2) - one(I), side_length - one(I))), color)
    end

    return nothing
end

function SD.draw!(image, drawable::DropDownDrawable)
    I = typeof(drawable.bounding_box.height)

    bounding_box = drawable.bounding_box
    text = drawable.text
    font = drawable.font
    content_alignment = drawable.content_alignment
    content_padding = drawable.content_padding
    background_color = drawable.background_color
    border_color = drawable.border_color
    text_color = drawable.text_color
    indicator_color = drawable.indicator_color
    value = drawable.value

    image_bounding_box = SD.Rectangle(SD.Point(one(I), one(I)), size(image)...)
    if is_intersecting(image_bounding_box, bounding_box)
        i_min, j_min, i_max, j_max = get_intersection_extrema(image_bounding_box, bounding_box)
        image_view = @view image[i_min:i_max, j_min:j_max]
    else
        return nothing
    end

    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    num_printable_characters = get_num_printable_characters(text)
    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, SD.get_height(font), SD.get_width(font) * (num_printable_characters + convert(I, 2)))
    SD.draw!(image_view, SD.TextLine(SD.move(SD.Point(one(I), one(I)), i_offset, j_offset + SD.get_width(font) * convert(I, 2)), text, font), text_color)

    x = min(SD.get_height(font), convert(I, 2) * SD.get_width(font))
    x_div_8 = x ÷ convert(I, 8)
    SD.draw!(image_view, DropDownIndicator(SD.move(SD.Point(one(I), one(I)), i_offset + x_div_8, j_offset + x_div_8), (convert(I, 3) * x) ÷ convert(I, 4), value), indicator_color)

    SD.draw!(image, bounding_box, border_color)

    return nothing
end

function SD.draw!(image, drawable::SliderDrawable)
    I = typeof(drawable.bounding_box.height)

    bounding_box = drawable.bounding_box
    text = drawable.text
    font = drawable.font
    content_alignment = drawable.content_alignment
    content_padding = drawable.content_padding
    bar_offset_i = drawable.bar_offset_i
    bar_offset_j = drawable.bar_offset_j
    bar_height = drawable.bar_height
    bar_width = drawable.bar_width
    background_color = drawable.background_color
    border_color = drawable.border_color
    text_color = drawable.text_color
    bar_color = drawable.bar_color

    image_bounding_box = SD.Rectangle(SD.Point(one(I), one(I)), size(image)...)
    if is_intersecting(image_bounding_box, bounding_box)
        i_min, j_min, i_max, j_max = get_intersection_extrema(image_bounding_box, bounding_box)
        image_view = @view image[i_min:i_max, j_min:j_max]
    else
        return nothing
    end

    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    SD.draw!(image, SD.FilledRectangle(SD.move(bounding_box.position, bar_offset_i, bar_offset_j), bar_height, bar_width), bar_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, SD.get_height(font), SD.get_width(font) * get_num_printable_characters(text))
    SD.draw!(image_view, SD.TextLine(SD.move(SD.Point(one(I), one(I)), i_offset, j_offset), text, font), text_color)

    SD.draw!(image, bounding_box, border_color)

    return nothing
end

function SD.draw!(image, drawable::ImageDrawable)
    I = typeof(drawable.bounding_box.height)

    bounding_box = drawable.bounding_box
    content_alignment = drawable.content_alignment
    content_padding = drawable.content_padding
    image2 = drawable.image
    image2_height, image2_width = size(image2.image)
    border_color = drawable.border_color

    image_bounding_box = SD.Rectangle(SD.Point(one(I), one(I)), size(image)...)
    if is_intersecting(image_bounding_box, bounding_box)
        i_min, j_min, i_max, j_max = get_intersection_extrema(image_bounding_box, bounding_box)
        image_view = @view image[i_min:i_max, j_min:j_max]
    else
        return nothing
    end

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, content_alignment, content_padding, image2_height, image2_width)
    SD.draw!(image_view, SD.Image(SD.move(image2.position, i_offset, j_offset), image2.image))

    SD.draw!(image, bounding_box, border_color)

    return nothing
end

"""
    get_num_printable_characters(text)

Return the number of printable characters in text.

# Examples
```julia-repl
julia> SimpleIMGUI.get_num_printable_characters("hello █\n")
7
```
"""
get_num_printable_characters(text) = count(isprint, text)

function is_intersecting(shape1, shape2)
    i_min_shape1, i_max_shape1 = SD.get_i_extrema(shape1)
    i_min_shape2, i_max_shape2 = SD.get_i_extrema(shape2)

    j_min_shape1, j_max_shape1 = SD.get_j_extrema(shape1)
    j_min_shape2, j_max_shape2 = SD.get_j_extrema(shape2)

    separating_i_axis_exists = (i_max_shape1 < i_min_shape2) || (i_max_shape2 < i_min_shape1)
    separating_j_axis_exists = (j_max_shape1 < j_min_shape2) || (j_max_shape2 < j_min_shape1)
    separating_axis_exists = separating_i_axis_exists || separating_j_axis_exists

    return !separating_axis_exists
end

function get_intersection_extrema(image, shape)
    i_min_shape, i_max_shape = SD.get_i_extrema(shape)
    i_min_image, i_max_image = SD.get_i_extrema(image)

    j_min_shape, j_max_shape = SD.get_j_extrema(shape)
    j_min_image, j_max_image = SD.get_j_extrema(image)

    i_min = max(i_min_image, i_min_shape)
    j_min = max(j_min_image, j_min_shape)

    i_max = min(i_max_image, i_max_shape)
    j_max = min(j_max_image, j_max_shape)

    return i_min, j_min, i_max, j_max
end
