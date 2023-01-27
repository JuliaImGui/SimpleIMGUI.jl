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

function draw_text_line_in_a_box!(image, bounding_box, text, font, alignment, padding, background_color, border_color, text_color)
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    SD.draw!(image, bounding_box, border_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, alignment, padding, SD.get_height(font), SD.get_width(font) * get_num_printable_characters(text))
    SD.draw!(image, SD.TextLine(SD.move(bounding_box.position, i_offset, j_offset), text, font), text_color)

    return nothing
end

function draw_widget!(widget_type, image, bounding_box, args...; kwargs...)
    if SD.is_outbounds(image, bounding_box)
        return nothing
    end

    i_min, j_min, i_max, j_max = get_intersection_extrema(image, bounding_box)
    @assert i_max >= i_min
    @assert j_max >= j_min

    view_box_image = @view image[i_min : i_max, j_min : j_max]

    view_box_bounding_box = SD.Rectangle(SD.Point(bounding_box.position.i - i_min + one(i_min), bounding_box.position.j - j_min + one(j_min)), bounding_box.height, bounding_box.width)

    draw_widget_unclipped!(widget_type, view_box_image, view_box_bounding_box, args...; kwargs...)

    return nothing
end

function draw_widget_unclipped!(widget_type::Text, image, bounding_box, user_interaction_state, this_widget, text, font, alignment, padding, background_color, border_color, text_color)
    draw_text_line_in_a_box!(
        image,
        bounding_box,
        text,
        font,
        alignment,
        padding,
        background_color,
        border_color,
        text_color,
    )

    return nothing
end

function draw_widget_unclipped!(widget_type::Button, image, bounding_box, user_interaction_state, this_widget, text, font, alignment, padding, background_color, border_color, text_color)

    draw_text_line_in_a_box!(
        image,
        bounding_box,
        text,
        font,
        alignment,
        padding,
        background_color,
        border_color,
        text_color,
    )

    return nothing
end

function draw_widget_unclipped!(widget_type::TextBox, image, bounding_box, user_interaction_state, this_widget, alignment, padding, text, font, background_contextual_color, border_contextual_color, text_contextual_color)
    if this_widget == user_interaction_state.active_widget
        background_color = background_contextual_color.active_color
        border_color = border_contextual_color.active_color
        text_color = text_contextual_color.active_color
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_contextual_color.hot_color
        border_color = border_contextual_color.hot_color
        text_color = text_contextual_color.hot_color
    else
        background_color = background_contextual_color.neutral_color
        border_color = border_contextual_color.neutral_color
        text_color = text_contextual_color.neutral_color
    end

    num_printable_characters = get_num_printable_characters(text)

    if num_printable_characters * SD.get_width(font) > bounding_box.width
        alignment = RIGHT1
    end

    draw_text_line_in_a_box!(
        image,
        bounding_box,
        text,
        font,
        alignment,
        padding,
        background_color,
        border_color,
        text_color,
    )

    if this_widget == user_interaction_state.active_widget
        _, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, alignment, padding, SD.get_height(font), SD.get_width(font) * num_printable_characters)
        SD.draw!(image, SD.FilledRectangle(SD.move_j(bounding_box.position, j_offset + num_printable_characters * SD.get_width(font) - one(j_offset)), bounding_box.height, oftype(bounding_box.width, 2)), text_color)
    end

    return nothing
end

function draw_widget_unclipped!(widget_type::CheckBox, image, bounding_box, user_interaction_state, this_widget, widget_value, alignment, padding, text, font, background_color, border_color, text_color, indicator_color)
    font_width = SD.get_width(font)
    box_width = oftype(font_width, 2) * font_width
    x = box_width ÷ oftype(box_width, 8)

    SD.draw!(image, SD.ThickRectangle(SD.move(bounding_box.position, x, x), oftype(x, 6) * x, oftype(x, 6) * x, x), indicator_color)
    if widget_value
        SD.draw!(image, SD.FilledRectangle(SD.move(bounding_box.position, oftype(x, 3) * x, oftype(x, 3) * x), oftype(x, 2) * x, oftype(x, 2) * x), indicator_color)
    end

    draw_text_line_in_a_box!(
        image,
        SD.Rectangle(SD.move_j(bounding_box.position, box_width), bounding_box.height, bounding_box.width - box_width),
        text,
        font,
        alignment,
        padding,
        background_color,
        border_color,
        text_color,
    )

    return nothing
end

function draw_widget_unclipped!(widget_type::RadioButton, image, bounding_box, user_interaction_state, this_widget, widget_value, alignment, padding, text, font, background_contextual_color, border_contextual_color, text_contextual_color, indicator_contextual_color)
    if this_widget == user_interaction_state.active_widget
        background_color = background_contextual_color.active_color
        border_color = border_contextual_color.active_color
        text_color = text_contextual_color.active_color
        indicator_color = indicator_contextual_color.active_color
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_contextual_color.hot_color
        border_color = border_contextual_color.hot_color
        text_color = text_contextual_color.hot_color
        indicator_color = indicator_contextual_color.hot_color
    else
        background_color = background_contextual_color.neutral_color
        border_color = border_contextual_color.neutral_color
        text_color = text_contextual_color.neutral_color
        indicator_color = indicator_contextual_color.neutral_color
    end

    font_width = SD.get_width(font)
    indicator_width = oftype(font_width, 2) * font_width
    x = indicator_width ÷ oftype(indicator_width, 8)
    SD.draw!(image, SD.ThickCircle(SD.move(bounding_box.position, x, x), oftype(x, 6) * x, x), indicator_color)
    if widget_value
        SD.draw!(image, SD.FilledCircle(SD.move(bounding_box.position, oftype(x, 3) * x, oftype(x, 3) * x), oftype(x, 2) * x), indicator_color)
    end

    draw_text_line_in_a_box!(
        image,
        SD.Rectangle(SD.move_j(bounding_box.position, indicator_width), bounding_box.height, bounding_box.width - indicator_width),
        text,
        font,
        alignment,
        padding,
        background_color,
        border_color,
        text_color,
    )

    return nothing
end

function draw_widget_unclipped!(widget_type::DropDown, image, bounding_box, user_interaction_state, this_widget, widget_value, alignment, padding, text, font, background_contextual_color, border_contextual_color, text_contextual_color, indicator_contextual_color)
    if this_widget == user_interaction_state.active_widget
        background_color = background_contextual_color.active_color
        border_color = border_contextual_color.active_color
        text_color = text_contextual_color.active_color
        indicator_color = indicator_contextual_color.active_color
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_contextual_color.hot_color
        border_color = border_contextual_color.hot_color
        text_color = text_contextual_color.hot_color
        indicator_color = indicator_contextual_color.hot_color
    else
        background_color = background_contextual_color.neutral_color
        border_color = border_contextual_color.neutral_color
        text_color = text_contextual_color.neutral_color
        indicator_color = indicator_contextual_color.neutral_color
    end

    font_width = SD.get_width(font)
    indicator_width = oftype(font_width, 2) * font_width
    x = indicator_width ÷ oftype(indicator_width, 8)
    if widget_value
        SD.draw!(image, SD.FilledTriangle(SD.move(bounding_box.position, oftype(x, 2) * x, oftype(x, 4) * x), SD.move(bounding_box.position, oftype(x, 6) * x, oftype(x, 2) * x), SD.move(bounding_box.position, oftype(x, 6) * x, oftype(x, 6) * x)), indicator_color)
    else
        SD.draw!(image, SD.FilledTriangle(SD.move(bounding_box.position, oftype(x, 2) * x, oftype(x, 2) * x), SD.move(bounding_box.position, oftype(x, 2) * x, oftype(x, 6) * x), SD.move(bounding_box.position, oftype(x, 6) * x, oftype(x, 4) * x)), indicator_color)
    end

    draw_text_line_in_a_box!(
        image,
        SD.Rectangle(SD.move_j(bounding_box.position, indicator_width), bounding_box.height, bounding_box.width - indicator_width),
        text,
        font,
        alignment,
        padding,
        background_color,
        border_color,
        text_color,
    )

    return nothing
end

function draw_widget_unclipped!(widget_type::Slider, image, bounding_box, user_interaction_state, this_widget, widget_value, background_contextual_color, border_contextual_color, bar_contextual_color)
    if this_widget == user_interaction_state.active_widget
        background_color = background_contextual_color.active_color
        border_color = border_contextual_color.active_color
        bar_color = bar_contextual_color.active_color
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_contextual_color.hot_color
        border_color = border_contextual_color.hot_color
        bar_color = bar_contextual_color.hot_color
    else
        background_color = background_contextual_color.neutral_color
        border_color = border_contextual_color.neutral_color
        bar_color = bar_contextual_color.neutral_color
    end

    i_slider_value = widget_value[1]
    j_slider_value = widget_value[2]
    height_slider = widget_value[3]
    width_slider = widget_value[4]
    i_slider_relative_mouse = widget_value[5]
    j_slider_relative_mouse = widget_value[6]

    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    SD.draw!(image, bounding_box, border_color)

    SD.draw!(image, SD.FilledRectangle(SD.move(bounding_box.position, i_slider_value, j_slider_value), height_slider, width_slider), bar_color)

    return nothing
end

function draw_widget_unclipped!(widget_type::Image, image, bounding_box, user_interaction_state, this_widget, content, alignment, padding, border_contextual_color)
    if this_widget == user_interaction_state.active_widget
        border_color = border_contextual_color.active_color
    elseif this_widget == user_interaction_state.hot_widget
        border_color = border_contextual_color.hot_color
    else
        border_color = border_contextual_color.neutral_color
    end

    SD.draw!(image, content)

    SD.draw!(image, bounding_box, border_color)

    return nothing
end
