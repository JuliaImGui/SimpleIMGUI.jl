abstract type AbstractUIContext end

struct UIContext{T, I1, I2, C, D} <: AbstractUIContext
    user_interaction_state::UserInteractionState{T}
    user_input_state::UserInputState{I1}
    layout::BoxLayout{I2}
    colors::Vector{C}
    draw_list::Vector{D}
end

function do_widget!(
        widget_type::Button,
        ui_context::AbstractUIContext,
        this_widget,
        text;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(font),
        widget_width = get_num_printable_characters(text) * SD.get_width(font),
        content_alignment = CENTER,
        content_padding = 0,
        background_color_neutral = ui_context.colors[Integer(COLOR_INDEX_BUTTON_BACKGROUND_NEUTRAL)],
        background_color_hot = ui_context.colors[Integer(COLOR_INDEX_BUTTON_BACKGROUND_HOT)],
        background_color_active = ui_context.colors[Integer(COLOR_INDEX_BUTTON_BACKGROUND_ACTIVE)],
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_BUTTON_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_BUTTON_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_BUTTON_BORDER_ACTIVE)],
        text_color_neutral = ui_context.colors[Integer(COLOR_INDEX_BUTTON_TEXT_NEUTRAL)],
        text_color_hot = ui_context.colors[Integer(COLOR_INDEX_BUTTON_TEXT_HOT)],
        text_color_active = ui_context.colors[Integer(COLOR_INDEX_BUTTON_TEXT_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if this_widget == user_interaction_state.active_widget
        background_color = background_color_active
        border_color = border_color_active
        text_color = text_color_active
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_color_hot
        border_color = border_color_hot
        text_color = text_color_hot
    else
        background_color = background_color_neutral
        border_color = border_color_neutral
        text_color = text_color_neutral
    end

    drawable = BoxedTextLine(widget_bounding_box, text, font, content_alignment, content_padding, background_color, border_color, text_color)
    push!(ui_context.draw_list, drawable)

    return widget_value
end

function do_widget!(
        widget_type::Text,
        ui_context::AbstractUIContext,
        this_widget,
        text;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(font),
        widget_width = get_num_printable_characters(text) * SD.get_width(font),
        content_alignment = UP1_LEFT1,
        content_padding = 0,
        background_color_neutral = ui_context.colors[Integer(COLOR_INDEX_TEXT_BACKGROUND_NEUTRAL)],
        background_color_hot = ui_context.colors[Integer(COLOR_INDEX_TEXT_BACKGROUND_HOT)],
        background_color_active = ui_context.colors[Integer(COLOR_INDEX_TEXT_BACKGROUND_ACTIVE)],
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_TEXT_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_TEXT_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_TEXT_BORDER_ACTIVE)],
        text_color_neutral = ui_context.colors[Integer(COLOR_INDEX_TEXT_TEXT_NEUTRAL)],
        text_color_hot = ui_context.colors[Integer(COLOR_INDEX_TEXT_TEXT_HOT)],
        text_color_active = ui_context.colors[Integer(COLOR_INDEX_TEXT_TEXT_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if this_widget == user_interaction_state.active_widget
        background_color = background_color_active
        border_color = border_color_active
        text_color = text_color_active
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_color_hot
        border_color = border_color_hot
        text_color = text_color_hot
    else
        background_color = background_color_neutral
        border_color = border_color_neutral
        text_color = text_color_neutral
    end

    drawable = BoxedTextLine(widget_bounding_box, text, font, content_alignment, content_padding, background_color, border_color, text_color)
    push!(ui_context.draw_list, drawable)

    return widget_value
end

function do_widget!(
        widget_type::CheckBox,
        ui_context::AbstractUIContext,
        this_widget,
        widget_value,
        text;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(font),
        widget_width = (get_num_printable_characters(text) + 2) * SD.get_width(font),
        content_alignment = UP1_LEFT1,
        content_padding = 0,
        background_color_neutral = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_BACKGROUND_NEUTRAL)],
        background_color_hot = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_BACKGROUND_HOT)],
        background_color_active = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_BACKGROUND_ACTIVE)],
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_BORDER_ACTIVE)],
        text_color_neutral = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_TEXT_NEUTRAL)],
        text_color_hot = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_TEXT_HOT)],
        text_color_active = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_TEXT_ACTIVE)],
        indicator_color_neutral = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_INDICATOR_NEUTRAL)],
        indicator_color_hot = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_INDICATOR_HOT)],
        indicator_color_active = ui_context.colors[Integer(COLOR_INDEX_CHECK_BOX_INDICATOR_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        widget_value,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if this_widget == user_interaction_state.active_widget
        background_color = background_color_active
        border_color = border_color_active
        text_color = text_color_active
        indicator_color = indicator_color_active
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_color_hot
        border_color = border_color_hot
        text_color = text_color_hot
        indicator_color = indicator_color_hot
    else
        background_color = background_color_neutral
        border_color = border_color_neutral
        text_color = text_color_neutral
        indicator_color = indicator_color_neutral
    end

    drawable = CheckBoxDrawable(widget_bounding_box, text, font, content_alignment, content_padding, background_color, border_color, text_color, indicator_color, widget_value)
    push!(ui_context.draw_list, drawable)

    return widget_value
end

function do_widget!(
        widget_type::RadioButton,
        ui_context::AbstractUIContext,
        this_widget,
        widget_value,
        text;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(font),
        widget_width = (get_num_printable_characters(text) + 2) * SD.get_width(font),
        content_alignment = UP1_LEFT1,
        content_padding = 0,
        background_color_neutral = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_BACKGROUND_NEUTRAL)],
        background_color_hot = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_BACKGROUND_HOT)],
        background_color_active = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_BACKGROUND_ACTIVE)],
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_BORDER_ACTIVE)],
        text_color_neutral = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_TEXT_NEUTRAL)],
        text_color_hot = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_TEXT_HOT)],
        text_color_active = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_TEXT_ACTIVE)],
        indicator_color_neutral = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_INDICATOR_NEUTRAL)],
        indicator_color_hot = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_INDICATOR_HOT)],
        indicator_color_active = ui_context.colors[Integer(COLOR_INDEX_RADIO_BUTTON_INDICATOR_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        widget_value,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if this_widget == user_interaction_state.active_widget
        background_color = background_color_active
        border_color = border_color_active
        text_color = text_color_active
        indicator_color = indicator_color_active
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_color_hot
        border_color = border_color_hot
        text_color = text_color_hot
        indicator_color = indicator_color_hot
    else
        background_color = background_color_neutral
        border_color = border_color_neutral
        text_color = text_color_neutral
        indicator_color = indicator_color_neutral
    end

    drawable = RadioButtonDrawable(widget_bounding_box, text, font, content_alignment, content_padding, background_color, border_color, text_color, indicator_color, widget_value)
    push!(ui_context.draw_list, drawable)

    return widget_value
end

function do_widget!(
        widget_type::DropDown,
        ui_context::AbstractUIContext,
        this_widget,
        widget_value,
        text;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(font),
        widget_width = (get_num_printable_characters(text) + 2) * SD.get_width(font),
        content_alignment = UP1_LEFT1,
        content_padding = 0,
        background_color_neutral = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_BACKGROUND_NEUTRAL)],
        background_color_hot = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_BACKGROUND_HOT)],
        background_color_active = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_BACKGROUND_ACTIVE)],
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_BORDER_ACTIVE)],
        text_color_neutral = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_TEXT_NEUTRAL)],
        text_color_hot = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_TEXT_HOT)],
        text_color_active = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_TEXT_ACTIVE)],
        indicator_color_neutral = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_INDICATOR_NEUTRAL)],
        indicator_color_hot = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_INDICATOR_HOT)],
        indicator_color_active = ui_context.colors[Integer(COLOR_INDEX_DROP_DOWN_INDICATOR_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        widget_value,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if this_widget == user_interaction_state.active_widget
        background_color = background_color_active
        border_color = border_color_active
        text_color = text_color_active
        indicator_color = indicator_color_active
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_color_hot
        border_color = border_color_hot
        text_color = text_color_hot
        indicator_color = indicator_color_hot
    else
        background_color = background_color_neutral
        border_color = border_color_neutral
        text_color = text_color_neutral
        indicator_color = indicator_color_neutral
    end

    drawable = DropDownDrawable(widget_bounding_box, text, font, content_alignment, content_padding, background_color, border_color, text_color, indicator_color, widget_value)
    push!(ui_context.draw_list, drawable)

    return widget_value
end

function do_widget!(
        widget_type::TextBox,
        ui_context::AbstractUIContext,
        this_widget,
        text;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(font),
        widget_width = max(1, get_num_printable_characters(text)) * SD.get_width(font),
        content_alignment = UP1_LEFT1,
        content_padding = 0,
        background_color_neutral = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_BACKGROUND_NEUTRAL)],
        background_color_hot = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_BACKGROUND_HOT)],
        background_color_active = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_BACKGROUND_ACTIVE)],
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_BORDER_ACTIVE)],
        text_color_neutral = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_TEXT_NEUTRAL)],
        text_color_hot = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_TEXT_HOT)],
        text_color_active = ui_context.colors[Integer(COLOR_INDEX_TEXT_BOX_TEXT_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    characters = ui_context.user_input_state.characters

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        characters,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if widget_value
        for character in characters
            if isprint(character)
                push!(text, character)
            elseif character == '\b'
                if get_num_printable_characters(text) > 0
                    pop!(text)
                end
            end
        end
    end

    if this_widget == user_interaction_state.active_widget
        background_color = background_color_active
        border_color = border_color_active
        text_color = text_color_active
        show_cursor = true
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_color_hot
        border_color = border_color_hot
        text_color = text_color_hot
        show_cursor = false
    else
        background_color = background_color_neutral
        border_color = border_color_neutral
        text_color = text_color_neutral
        show_cursor = false
    end

    drawable = TextBoxDrawable(widget_bounding_box, text, font, content_alignment, content_padding, background_color, border_color, text_color, show_cursor)
    push!(ui_context.draw_list, drawable)

    return widget_value
end

function do_widget!(
        widget_type::Slider,
        ui_context::AbstractUIContext,
        this_widget,
        widget_value;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(font),
        widget_width = 8 * SD.get_width(font),
        background_color_neutral = ui_context.colors[Integer(COLOR_INDEX_SLIDER_BACKGROUND_NEUTRAL)],
        background_color_hot = ui_context.colors[Integer(COLOR_INDEX_SLIDER_BACKGROUND_HOT)],
        background_color_active = ui_context.colors[Integer(COLOR_INDEX_SLIDER_BACKGROUND_ACTIVE)],
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_SLIDER_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_SLIDER_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_SLIDER_BORDER_ACTIVE)],
        indicator_color_neutral = ui_context.colors[Integer(COLOR_INDEX_SLIDER_INDICATOR_NEUTRAL)],
        indicator_color_hot = ui_context.colors[Integer(COLOR_INDEX_SLIDER_INDICATOR_HOT)],
        indicator_color_active = ui_context.colors[Integer(COLOR_INDEX_SLIDER_INDICATOR_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        widget_value...,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if this_widget == user_interaction_state.active_widget
        background_color = background_color_active
        border_color = border_color_active
        indicator_color = indicator_color_active
    elseif this_widget == user_interaction_state.hot_widget
        background_color = background_color_hot
        border_color = border_color_hot
        indicator_color = indicator_color_hot
    else
        background_color = background_color_neutral
        border_color = border_color_neutral
        indicator_color = indicator_color_neutral
    end

    bar_offset_i = widget_value[1]
    bar_offset_j = widget_value[2]
    bar_height = widget_value[3]
    bar_width = widget_value[4]
    drawable = SliderDrawable(widget_bounding_box, bar_offset_i, bar_offset_j, bar_height, bar_width, background_color, border_color, indicator_color)
    push!(ui_context.draw_list, drawable)

    return widget_value
end

function do_widget!(
        widget_type::Image,
        ui_context::AbstractUIContext,
        this_widget,
        image_content;
        font = SD.TERMINUS_BOLD_24_12,
        alignment = DOWN2_LEFT1,
        padding = SD.get_height(font) ÷ 4,
        widget_height = SD.get_height(image_content),
        widget_width = SD.get_width(image_content),
        content_alignment = UP1_LEFT1,
        content_padding = 0,
        border_color_neutral = ui_context.colors[Integer(COLOR_INDEX_IMAGE_BORDER_NEUTRAL)],
        border_color_hot = ui_context.colors[Integer(COLOR_INDEX_IMAGE_BORDER_HOT)],
        border_color_active = ui_context.colors[Integer(COLOR_INDEX_IMAGE_BORDER_ACTIVE)],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = get_widget_interaction(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        cursor_position.i,
        cursor_position.j,
        input_button.ended_down,
        input_button.num_transitions,
        SD.get_i_min(widget_bounding_box),
        SD.get_j_min(widget_bounding_box),
        SD.get_i_max(widget_bounding_box),
        SD.get_j_max(widget_bounding_box),
    )

    user_interaction_state.hot_widget = hot_widget
    user_interaction_state.active_widget = active_widget
    user_interaction_state.null_widget = null_widget

    if this_widget == user_interaction_state.active_widget
        border_color = border_color_active
    elseif this_widget == user_interaction_state.hot_widget
        border_color = border_color_hot
    else
        border_color = border_color_neutral
    end

    drawable = ImageDrawable(widget_bounding_box, content_alignment, content_padding, image_content, border_color)
    push!(ui_context.draw_list, drawable)

    return widget_value
end
