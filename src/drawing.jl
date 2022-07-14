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

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, SD.get_height(font), SD.get_width(font) * length(text), alignment, padding)
    SD.draw!(image, SD.TextLine(SD.move(bounding_box.position, i_offset, j_offset), text, font), text_color)

    return nothing
end

function draw_text_line_with_slider_in_a_box!(image, bounding_box, slider_value, text, font, alignment, padding, background_color, border_color, text_color, bar_color)
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    if slider_value > zero(slider_value)
        SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, slider_value), bar_color)
    end

    SD.draw!(image, bounding_box, border_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, SD.get_height(font), SD.get_width(font) * length(text), alignment, padding)
    SD.draw!(image, SD.TextLine(SD.move(bounding_box.position, i_offset, j_offset), text, font), text_color)

    return nothing
end

function SD.draw!(image::AbstractMatrix, bounding_box::SD.Rectangle, widget_type::AbstractWidgetType, args...; kwargs...)
    if SD.is_outbounds(image, bounding_box)
        return nothing
    end

    i_min, j_min, i_max, j_max = get_intersection_extrema(image, bounding_box)
    @assert i_max >= i_min
    @assert j_max >= j_min

    view_box_image = @view image[i_min : i_max, j_min : j_max]

    view_box_bounding_box = SD.Rectangle(SD.Point(bounding_box.position.i - i_min + one(i_min), bounding_box.position.j - j_min + one(j_min)), bounding_box.height, bounding_box.width)

    draw_widget!(view_box_image, view_box_bounding_box, widget_type, args...; kwargs...)

    return nothing
end

function draw_widget!(image, bounding_box, widget_type::Button, user_interaction_state, this_widget, text, font, colors)
    alignment = CENTER
    padding = -1

    if this_widget == user_interaction_state.active_widget
        background_color = colors[Integer(COLOR_ACTIVE_BUTTON_BACKGROUND)]
        border_color = colors[Integer(COLOR_ACTIVE_BUTTON_BORDER)]
        text_color = colors[Integer(COLOR_ACTIVE_BUTTON_TEXT)]
    elseif this_widget == user_interaction_state.hot_widget
        background_color = colors[Integer(COLOR_HOT_BUTTON_BACKGROUND)]
        border_color = colors[Integer(COLOR_HOT_BUTTON_BORDER)]
        text_color = colors[Integer(COLOR_HOT_BUTTON_TEXT)]
    else
        background_color = colors[Integer(COLOR_NEUTRAL_BUTTON_BACKGROUND)]
        border_color = colors[Integer(COLOR_NEUTRAL_BUTTON_BORDER)]
        text_color = colors[Integer(COLOR_NEUTRAL_BUTTON_TEXT)]
    end

    draw_text_line_in_a_box!(image, bounding_box, text, font, alignment, padding, background_color, border_color, text_color)

    return nothing
end

function draw_widget!(image, bounding_box, widget_type::Slider, user_interaction_state, this_widget, slider_value, text, font, colors)
    alignment = CENTER
    padding = -1

    if this_widget == user_interaction_state.active_widget
        background_color = colors[Integer(COLOR_ACTIVE_SLIDER_BACKGROUND)]
        border_color = colors[Integer(COLOR_ACTIVE_SLIDER_BORDER)]
        text_color = colors[Integer(COLOR_ACTIVE_SLIDER_TEXT)]
        bar_color = colors[Integer(COLOR_ACTIVE_SLIDER_BAR)]
    elseif this_widget == user_interaction_state.hot_widget
        background_color = colors[Integer(COLOR_HOT_SLIDER_BACKGROUND)]
        border_color = colors[Integer(COLOR_HOT_SLIDER_BORDER)]
        text_color = colors[Integer(COLOR_HOT_SLIDER_TEXT)]
        bar_color = colors[Integer(COLOR_HOT_SLIDER_BAR)]
    else
        background_color = colors[Integer(COLOR_NEUTRAL_SLIDER_BACKGROUND)]
        border_color = colors[Integer(COLOR_NEUTRAL_SLIDER_BORDER)]
        text_color = colors[Integer(COLOR_NEUTRAL_SLIDER_TEXT)]
        bar_color = colors[Integer(COLOR_NEUTRAL_SLIDER_BAR)]
    end

    draw_text_line_with_slider_in_a_box!(image, bounding_box, slider_value, text, font, alignment, padding, background_color, border_color, text_color, bar_color)

    return nothing
end

function draw_widget!(image, bounding_box, widget_type::TextBox, user_interaction_state, this_widget, text, font, colors)
    alignment = LEFT1
    if length(text) * SD.get_width(font) > bounding_box.width
        alignment = RIGHT1
    end

    padding = -1

    if this_widget == user_interaction_state.active_widget
        background_color = colors[Integer(COLOR_ACTIVE_TEXT_BOX_BACKGROUND)]
        border_color = colors[Integer(COLOR_ACTIVE_TEXT_BOX_BORDER)]
        text_color = colors[Integer(COLOR_ACTIVE_TEXT_BOX_TEXT)]
    elseif this_widget == user_interaction_state.hot_widget
        background_color = colors[Integer(COLOR_HOT_TEXT_BOX_BACKGROUND)]
        border_color = colors[Integer(COLOR_HOT_TEXT_BOX_BORDER)]
        text_color = colors[Integer(COLOR_HOT_TEXT_BOX_TEXT)]
    else
        background_color = colors[Integer(COLOR_NEUTRAL_TEXT_BOX_BACKGROUND)]
        border_color = colors[Integer(COLOR_NEUTRAL_TEXT_BOX_BORDER)]
        text_color = colors[Integer(COLOR_NEUTRAL_TEXT_BOX_TEXT)]
    end

    draw_text_line_in_a_box!(image, bounding_box, text, font, alignment, padding, background_color, border_color, text_color)

    return nothing
end

function draw_widget!(image, bounding_box, widget_type::Text, user_interaction_state, this_widget, text, font, colors)
    alignment = LEFT1
    padding = -1

    if this_widget == user_interaction_state.active_widget
        background_color = colors[Integer(COLOR_ACTIVE_TEXT_BACKGROUND)]
        border_color = colors[Integer(COLOR_ACTIVE_TEXT_BORDER)]
        text_color = colors[Integer(COLOR_ACTIVE_TEXT_TEXT)]
    elseif this_widget == user_interaction_state.hot_widget
        background_color = colors[Integer(COLOR_HOT_TEXT_BACKGROUND)]
        border_color = colors[Integer(COLOR_HOT_TEXT_BORDER)]
        text_color = colors[Integer(COLOR_HOT_TEXT_TEXT)]
    else
        background_color = colors[Integer(COLOR_NEUTRAL_TEXT_BACKGROUND)]
        border_color = colors[Integer(COLOR_NEUTRAL_TEXT_BORDER)]
        text_color = colors[Integer(COLOR_NEUTRAL_TEXT_TEXT)]
    end

    draw_text_line_in_a_box!(image, bounding_box, text, font, alignment, padding, background_color, border_color, text_color)

    return nothing
end

function draw_widget!(image, bounding_box, widget_type::CheckBox, user_interaction_state, this_widget, widget_value, text, font, colors)
    alignment = LEFT1
    padding = -1

    if this_widget == user_interaction_state.active_widget
        background_color = colors[Integer(COLOR_ACTIVE_CHECK_BOX_BACKGROUND)]
        border_color = colors[Integer(COLOR_ACTIVE_CHECK_BOX_BORDER)]
        text_color = colors[Integer(COLOR_ACTIVE_CHECK_BOX_TEXT)]
        box_color = colors[Integer(COLOR_ACTIVE_CHECK_BOX_BOX)]
    elseif this_widget == user_interaction_state.hot_widget
        background_color = colors[Integer(COLOR_HOT_CHECK_BOX_BACKGROUND)]
        border_color = colors[Integer(COLOR_HOT_CHECK_BOX_BORDER)]
        text_color = colors[Integer(COLOR_HOT_CHECK_BOX_TEXT)]
        box_color = colors[Integer(COLOR_HOT_CHECK_BOX_BOX)]
    else
        background_color = colors[Integer(COLOR_NEUTRAL_CHECK_BOX_BACKGROUND)]
        border_color = colors[Integer(COLOR_NEUTRAL_CHECK_BOX_BORDER)]
        text_color = colors[Integer(COLOR_NEUTRAL_CHECK_BOX_TEXT)]
        box_color = colors[Integer(COLOR_NEUTRAL_CHECK_BOX_BOX)]
    end

    font_width = SD.get_width(font)
    box_width = oftype(font_width, 2) * font_width
    x = box_width ÷ oftype(box_width, 8)
    SD.draw!(image, SD.ThickRectangle(SD.move(bounding_box.position, x, x), oftype(x, 6) * x, oftype(x, 6) * x, x), box_color)
    if widget_value
        SD.draw!(image, SD.FilledRectangle(SD.move(bounding_box.position, oftype(x, 3) * x, oftype(x, 3) * x), oftype(x, 2) * x, oftype(x, 2) * x), box_color)
    end
    draw_text_line_in_a_box!(image, SD.Rectangle(SD.move_j(bounding_box.position, box_width), bounding_box.height, bounding_box.width - box_width), text, font, alignment, padding, background_color, border_color, text_color)

    return nothing
end
