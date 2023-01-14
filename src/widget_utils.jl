mutable struct UIContext{S, I1, I2, I3, A, F, C}
    user_interaction_state::UserInteractionState{S, I1}
    user_input_state::UserInputState{I2}
    layout::BoxLayout{I3}
    image::A
    font::F
    colors::Vector{C}
end

#####
##### helper methods that bundle some of the arguments for methods in widget_core.jl and also do widget layouting and drawing
#####

function do_widget!(
        widget_type::Union{Button, Text},
        user_interaction_state,
        this_widget,
        cursor,
        input_button,
        layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        image,
        content_alignment,
        content_padding,
        text,
        font,
        background_color,
        border_color,
        text_color,
    )

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = do_widget!!(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        cursor.i,
        cursor.j,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, text, font, content_alignment, content_padding, background_color, border_color, text_color)

    return widget_value
end

function do_widget!(
        widget_type::Union{CheckBox, RadioButton, DropDown},
        user_interaction_state,
        this_widget,
        widget_value,
        cursor,
        input_button,
        layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        image,
        content_alignment,
        content_padding,
        text,
        font,
        background_color,
        border_color,
        text_color,
        indicator_color,
    )

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = do_widget!!(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        widget_value,
        cursor.i,
        cursor.j,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, text, font, background_color, border_color, text_color, indicator_color)

    return widget_value
end

function do_widget!(
        widget_type::TextBox,
        user_interaction_state,
        this_widget,
        widget_value,
        cursor,
        input_button,
        characters,
        layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        image,
        content_alignment,
        content_padding,
        font,
        background_color,
        border_color,
        text_color,
    )

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = do_widget!!(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        widget_value,
        cursor.i,
        cursor.j,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, font, background_color, border_color, text_color)

    return widget_value
end

function do_widget!(
        widget_type::Slider,
        user_interaction_state,
        this_widget,
        widget_value,
        cursor,
        input_button,
        layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        image,
        background_color,
        border_color,
        indicator_color,
    )

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = do_widget!!(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        widget_value...,
        cursor.i,
        cursor.j,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, background_color, border_color, indicator_color)

    return widget_value
end

function do_widget!(
        widget_type::Image,
        user_interaction_state,
        this_widget,
        cursor,
        input_button,
        layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        image,
        content_alignment,
        content_padding,
        content,
        border_color,
    )

    widget_bounding_box = get_alignment_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    hot_widget, active_widget, null_widget, widget_value = do_widget!!(
        widget_type,
        user_interaction_state.hot_widget,
        user_interaction_state.active_widget,
        user_interaction_state.null_widget,
        this_widget,
        cursor.i,
        cursor.j,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, content, content_alignment, content_padding, border_color)

    return widget_value
end

#####
##### helper methods that take default values for some of the arguments and shorten usage of do_widget!
#####

function get_colors(widget_type::Button, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_BUTTON_BACKGROUND)], colors[Integer(COLOR_ACTIVE_BUTTON_BORDER)], colors[Integer(COLOR_ACTIVE_BUTTON_TEXT)])
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_BUTTON_BACKGROUND)], colors[Integer(COLOR_HOT_BUTTON_BORDER)], colors[Integer(COLOR_HOT_BUTTON_TEXT)])
    else
        return (colors[Integer(COLOR_NEUTRAL_BUTTON_BACKGROUND)], colors[Integer(COLOR_NEUTRAL_BUTTON_BORDER)], colors[Integer(COLOR_NEUTRAL_BUTTON_TEXT)])
    end
end

function get_colors(widget_type::TextBox, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_TEXT_BOX_BACKGROUND)], colors[Integer(COLOR_ACTIVE_TEXT_BOX_BORDER)], colors[Integer(COLOR_ACTIVE_TEXT_BOX_TEXT)])
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_TEXT_BOX_BACKGROUND)], colors[Integer(COLOR_HOT_TEXT_BOX_BORDER)], colors[Integer(COLOR_HOT_TEXT_BOX_TEXT)])
    else
        return (colors[Integer(COLOR_NEUTRAL_TEXT_BOX_BACKGROUND)], colors[Integer(COLOR_NEUTRAL_TEXT_BOX_BORDER)], colors[Integer(COLOR_NEUTRAL_TEXT_BOX_TEXT)])
    end
end

function get_colors(widget_type::Text, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_TEXT_BACKGROUND)], colors[Integer(COLOR_ACTIVE_TEXT_BORDER)], colors[Integer(COLOR_ACTIVE_TEXT_TEXT)])
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_TEXT_BACKGROUND)], colors[Integer(COLOR_HOT_TEXT_BORDER)], colors[Integer(COLOR_HOT_TEXT_TEXT)])
    else
        return (colors[Integer(COLOR_NEUTRAL_TEXT_BACKGROUND)], colors[Integer(COLOR_NEUTRAL_TEXT_BORDER)], colors[Integer(COLOR_NEUTRAL_TEXT_TEXT)])
    end
end

function get_colors(widget_type::CheckBox, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_CHECK_BOX_BACKGROUND)], colors[Integer(COLOR_ACTIVE_CHECK_BOX_BORDER)], colors[Integer(COLOR_ACTIVE_CHECK_BOX_TEXT)], colors[Integer(COLOR_ACTIVE_CHECK_BOX_INDICATOR)])
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_CHECK_BOX_BACKGROUND)], colors[Integer(COLOR_HOT_CHECK_BOX_BORDER)], colors[Integer(COLOR_HOT_CHECK_BOX_TEXT)], colors[Integer(COLOR_HOT_CHECK_BOX_INDICATOR)])
    else
        return (colors[Integer(COLOR_NEUTRAL_CHECK_BOX_BACKGROUND)], colors[Integer(COLOR_NEUTRAL_CHECK_BOX_BORDER)], colors[Integer(COLOR_NEUTRAL_CHECK_BOX_TEXT)], colors[Integer(COLOR_NEUTRAL_CHECK_BOX_INDICATOR)])
    end
end

function get_colors(widget_type::RadioButton, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_RADIO_BUTTON_BACKGROUND)], colors[Integer(COLOR_ACTIVE_RADIO_BUTTON_BORDER)], colors[Integer(COLOR_ACTIVE_RADIO_BUTTON_TEXT)], colors[Integer(COLOR_ACTIVE_RADIO_BUTTON_INDICATOR)])
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_RADIO_BUTTON_BACKGROUND)], colors[Integer(COLOR_HOT_RADIO_BUTTON_BORDER)], colors[Integer(COLOR_HOT_RADIO_BUTTON_TEXT)], colors[Integer(COLOR_HOT_RADIO_BUTTON_INDICATOR)])
    else
        return (colors[Integer(COLOR_NEUTRAL_RADIO_BUTTON_BACKGROUND)], colors[Integer(COLOR_NEUTRAL_RADIO_BUTTON_BORDER)], colors[Integer(COLOR_NEUTRAL_RADIO_BUTTON_TEXT)], colors[Integer(COLOR_NEUTRAL_RADIO_BUTTON_INDICATOR)])
    end
end

function get_colors(widget_type::DropDown, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_DROP_DOWN_BACKGROUND)], colors[Integer(COLOR_ACTIVE_DROP_DOWN_BORDER)], colors[Integer(COLOR_ACTIVE_DROP_DOWN_TEXT)], colors[Integer(COLOR_ACTIVE_DROP_DOWN_INDICATOR)])
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_DROP_DOWN_BACKGROUND)], colors[Integer(COLOR_HOT_DROP_DOWN_BORDER)], colors[Integer(COLOR_HOT_DROP_DOWN_TEXT)], colors[Integer(COLOR_HOT_DROP_DOWN_INDICATOR)])
    else
        return (colors[Integer(COLOR_NEUTRAL_DROP_DOWN_BACKGROUND)], colors[Integer(COLOR_NEUTRAL_DROP_DOWN_BORDER)], colors[Integer(COLOR_NEUTRAL_DROP_DOWN_TEXT)], colors[Integer(COLOR_NEUTRAL_DROP_DOWN_INDICATOR)])
    end
end

function get_colors(widget_type::Slider, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_SLIDER_BACKGROUND)], colors[Integer(COLOR_ACTIVE_SLIDER_BORDER)], colors[Integer(COLOR_ACTIVE_SLIDER_INDICATOR)])
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_SLIDER_BACKGROUND)], colors[Integer(COLOR_HOT_SLIDER_BORDER)], colors[Integer(COLOR_HOT_SLIDER_INDICATOR)])
    else
        return (colors[Integer(COLOR_NEUTRAL_SLIDER_BACKGROUND)], colors[Integer(COLOR_NEUTRAL_SLIDER_BORDER)], colors[Integer(COLOR_NEUTRAL_SLIDER_INDICATOR)])
    end
end

function get_colors(widget_type::Image, user_interaction_state, this_widget, colors)
    if this_widget == user_interaction_state.active_widget
        return (colors[Integer(COLOR_ACTIVE_IMAGE_BORDER)],)
    elseif this_widget == user_interaction_state.hot_widget
        return (colors[Integer(COLOR_HOT_IMAGE_BORDER)],)
    else
        return (colors[Integer(COLOR_NEUTRAL_IMAGE_BORDER)],)
    end
end

get_content_alignment(::AbstractWidgetType) = UP1_LEFT1
get_content_alignment(::Button) = CENTER

get_content_padding(::AbstractWidgetType) = 0

function do_widget!(
        widget_type::Union{Button, Text},
        ui_context::UIContext,
        this_widget,
        alignment,
        padding,
        widget_height,
        widget_width,
        text,
    )

    do_widget!(
        widget_type,
        ui_context.user_interaction_state,
        this_widget,
        ui_context.user_input_state.cursor,
        first(ui_context.user_input_state.mouse_buttons), # assuming first one is left mouse button (it will work for GLFW at least)
        ui_context.layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        ui_context.image,
        get_content_alignment(widget_type),
        get_content_padding(widget_type),
        text,
        ui_context.font,
        get_colors(widget_type, ui_context.user_interaction_state, this_widget, ui_context.colors)...,
    )
end

function do_widget!(
        widget_type::Union{CheckBox, RadioButton, DropDown},
        ui_context::UIContext,
        this_widget,
        widget_value,
        alignment,
        padding,
        widget_height,
        widget_width,
        text,
    )

    do_widget!(
        widget_type,
        ui_context.user_interaction_state,
        this_widget,
        widget_value,
        ui_context.user_input_state.cursor,
        first(ui_context.user_input_state.mouse_buttons), # assuming first one is left mouse button (it will work for GLFW at least)
        ui_context.layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        ui_context.image,
        get_content_alignment(widget_type),
        get_content_padding(widget_type),
        text,
        ui_context.font,
        get_colors(widget_type, ui_context.user_interaction_state, this_widget, ui_context.colors)...,
    )
end

function do_widget!(
        widget_type::TextBox,
        ui_context::UIContext,
        this_widget,
        widget_value,
        alignment,
        padding,
        widget_height,
        widget_width,
    )

    do_widget!(
        widget_type,
        ui_context.user_interaction_state,
        this_widget,
        widget_value,
        ui_context.user_input_state.cursor,
        first(ui_context.user_input_state.mouse_buttons), # assuming first one is left mouse button (it will work for GLFW at least)
        ui_context.user_input_state.characters,
        ui_context.layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        ui_context.image,
        get_content_alignment(widget_type),
        get_content_padding(widget_type),
        ui_context.font,
        get_colors(widget_type, ui_context.user_interaction_state, this_widget, ui_context.colors)...,
    )
end

function do_widget!(
        widget_type::Slider,
        ui_context::UIContext,
        this_widget,
        widget_value,
        alignment,
        padding,
        widget_height,
        widget_width,
    )

    do_widget!(
        widget_type,
        ui_context.user_interaction_state,
        this_widget,
        widget_value,
        ui_context.user_input_state.cursor,
        first(ui_context.user_input_state.mouse_buttons), # assuming first one is left mouse button (it will work for GLFW at least)
        ui_context.layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        ui_context.image,
        get_colors(widget_type, ui_context.user_interaction_state, this_widget, ui_context.colors)...,
    )
end

function do_widget!(
        widget_type::Image,
        ui_context::UIContext,
        this_widget,
        alignment,
        padding,
        widget_height,
        widget_width,
        image,
    )

    do_widget!(
        widget_type,
        ui_context.user_interaction_state,
        this_widget,
        ui_context.user_input_state.cursor,
        first(ui_context.user_input_state.mouse_buttons), # assuming first one is left mouse button (it will work for GLFW at least)
        ui_context.layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        ui_context.image,
        get_content_alignment(widget_type),
        get_content_padding(widget_type),
        image,
        get_colors(widget_type, ui_context.user_interaction_state, this_widget, ui_context.colors)...,
    )
end
