abstract type AbstractUIContext end

struct UIContext{T, I1, I2, A, C} <: AbstractUIContext
    user_interaction_state::UserInteractionState{T}
    user_input_state::UserInputState{I1}
    layout::BoxLayout{I2}
    image::A
    colors::Dict{Symbol, C}
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
        background_color_neutral = ui_context.colors[:BUTTON_BACKGROUND_NEUTRAL],
        background_color_hot = ui_context.colors[:BUTTON_BACKGROUND_HOT],
        background_color_active = ui_context.colors[:BUTTON_BACKGROUND_ACTIVE],
        border_color_neutral = ui_context.colors[:BUTTON_BORDER_NEUTRAL],
        border_color_hot = ui_context.colors[:BUTTON_BORDER_HOT],
        border_color_active = ui_context.colors[:BUTTON_BORDER_ACTIVE],
        text_color_neutral = ui_context.colors[:BUTTON_TEXT_NEUTRAL],
        text_color_hot = ui_context.colors[:BUTTON_TEXT_HOT],
        text_color_active = ui_context.colors[:BUTTON_TEXT_ACTIVE],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    image = ui_context.image

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, text, font, content_alignment, content_padding, background_color, border_color, text_color)

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
        background_color_neutral = ui_context.colors[:TEXT_BACKGROUND_NEUTRAL],
        background_color_hot = ui_context.colors[:TEXT_BACKGROUND_HOT],
        background_color_active = ui_context.colors[:TEXT_BACKGROUND_ACTIVE],
        border_color_neutral = ui_context.colors[:TEXT_BORDER_NEUTRAL],
        border_color_hot = ui_context.colors[:TEXT_BORDER_HOT],
        border_color_active = ui_context.colors[:TEXT_BORDER_ACTIVE],
        text_color_neutral = ui_context.colors[:TEXT_TEXT_NEUTRAL],
        text_color_hot = ui_context.colors[:TEXT_TEXT_HOT],
        text_color_active = ui_context.colors[:TEXT_TEXT_ACTIVE],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    image = ui_context.image

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, text, font, content_alignment, content_padding, background_color, border_color, text_color)

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
        background_color_neutral = ui_context.colors[:CHECK_BOX_BACKGROUND_NEUTRAL],
        background_color_hot = ui_context.colors[:CHECK_BOX_BACKGROUND_HOT],
        background_color_active = ui_context.colors[:CHECK_BOX_BACKGROUND_ACTIVE],
        border_color_neutral = ui_context.colors[:CHECK_BOX_BORDER_NEUTRAL],
        border_color_hot = ui_context.colors[:CHECK_BOX_BORDER_HOT],
        border_color_active = ui_context.colors[:CHECK_BOX_BORDER_ACTIVE],
        text_color_neutral = ui_context.colors[:CHECK_BOX_TEXT_NEUTRAL],
        text_color_hot = ui_context.colors[:CHECK_BOX_TEXT_HOT],
        text_color_active = ui_context.colors[:CHECK_BOX_TEXT_ACTIVE],
        indicator_color_neutral = ui_context.colors[:CHECK_BOX_INDICATOR_NEUTRAL],
        indicator_color_hot = ui_context.colors[:CHECK_BOX_INDICATOR_HOT],
        indicator_color_active = ui_context.colors[:CHECK_BOX_INDICATOR_ACTIVE],
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    image = ui_context.image

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, text, font, background_color, border_color, text_color, indicator_color)

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
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    image = ui_context.image
    background_color, border_color, text_color, indicator_color = get_colors(widget_type)

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, text, font, background_color, border_color, text_color, indicator_color)

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
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    image = ui_context.image
    background_color, border_color, text_color, indicator_color = get_colors(widget_type)

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, text, font, background_color, border_color, text_color, indicator_color)

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
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    characters = ui_context.user_input_state.characters
    image = ui_context.image
    background_color, border_color, text_color = get_colors(widget_type)

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, content_alignment, content_padding, text, font, background_color, border_color, text_color)

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
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    image = ui_context.image
    background_color, border_color, indicator_color = get_colors(widget_type)

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, widget_value, background_color, border_color, indicator_color)

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
    )

    layout = ui_context.layout
    user_interaction_state = ui_context.user_interaction_state
    cursor_position = ui_context.user_input_state.cursor.position
    input_button = first(ui_context.user_input_state.mouse_buttons)
    image = ui_context.image
    border_color = get_colors(widget_type)[1]

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

    draw_widget!(widget_type, image, widget_bounding_box, user_interaction_state, this_widget, image_content, content_alignment, content_padding, border_color)

    return widget_value
end
