abstract type AbstractUIContext end

struct UIContext{T, I1, I2, A, F} <: AbstractUIContext
    user_interaction_state::UserInteractionState{T}
    user_input_state::UserInputState{I1}
    layout::BoxLayout{I2}
    image::A
    font::F
end

#####
##### helper methods that bundle some of the arguments for methods in widget_core.jl and also do widget layouting and drawing
#####

function do_widget!(
        widget_type::Union{Button, Text},
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        cursor_position,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, text, font, content_alignment, content_padding, background_color, border_color, text_color)

    return widget_value
end

function do_widget!(
        widget_type::Union{CheckBox, RadioButton, DropDown},
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        widget_value,
        cursor_position,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, text, font, background_color, border_color, text_color, indicator_color)

    return widget_value
end

function do_widget!(
        widget_type::TextBox,
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        widget_value,
        cursor_position,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, font, background_color, border_color, text_color)

    return widget_value
end

function do_widget!(
        widget_type::Slider,
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        widget_value,
        cursor_position,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, background_color, border_color, indicator_color)

    return widget_value
end

function do_widget!(
        widget_type::Image,
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        cursor_position,
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

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, content, content_alignment, content_padding, border_color)

    return widget_value
end

#####
##### helper methods that take default values for some of the arguments and shorten usage of do_widget!
#####

get_colors(widget_type::Button) = (COLOR_BUTTON_BACKGROUND, COLOR_BUTTON_BORDER, COLOR_BUTTON_TEXT)
get_colors(widget_type::TextBox) = (COLOR_TEXT_BOX_BACKGROUND, COLOR_TEXT_BOX_BORDER, COLOR_TEXT_BOX_TEXT)
get_colors(widget_type::Text) = (COLOR_TEXT_BACKGROUND, COLOR_TEXT_BORDER, COLOR_TEXT_TEXT)
get_colors(widget_type::CheckBox) = (COLOR_CHECK_BOX_BACKGROUND, COLOR_CHECK_BOX_BORDER, COLOR_CHECK_BOX_TEXT, COLOR_CHECK_BOX_INDICATOR)
get_colors(widget_type::RadioButton) = (COLOR_RADIO_BUTTON_BACKGROUND, COLOR_RADIO_BUTTON_BORDER, COLOR_RADIO_BUTTON_TEXT, COLOR_RADIO_BUTTON_INDICATOR)
get_colors(widget_type::DropDown) = (COLOR_DROP_DOWN_BACKGROUND, COLOR_DROP_DOWN_BORDER, COLOR_DROP_DOWN_TEXT, COLOR_DROP_DOWN_INDICATOR)
get_colors(widget_type::Slider) = (COLOR_SLIDER_BACKGROUND, COLOR_SLIDER_BORDER, COLOR_SLIDER_INDICATOR)
get_colors(widget_type::Image) = (COLOR_IMAGE_BORDER,)

get_content_alignment(::AbstractWidgetType) = UP1_LEFT1
get_content_alignment(::Button) = CENTER

get_content_padding(::AbstractWidgetType) = 0

function do_widget!(
        widget_type::Union{Button, Text},
        ui_context::AbstractUIContext,
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
        ui_context.user_input_state.cursor.position,
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
        get_colors(widget_type)...,
    )
end

function do_widget!(
        widget_type::Union{CheckBox, RadioButton, DropDown},
        ui_context::AbstractUIContext,
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
        ui_context.user_input_state.cursor.position,
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
        get_colors(widget_type)...,
    )
end

function do_widget!(
        widget_type::TextBox,
        ui_context::AbstractUIContext,
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
        ui_context.user_input_state.cursor.position,
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
        get_colors(widget_type)...,
    )
end

function do_widget!(
        widget_type::Slider,
        ui_context::AbstractUIContext,
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
        ui_context.user_input_state.cursor.position,
        first(ui_context.user_input_state.mouse_buttons), # assuming first one is left mouse button (it will work for GLFW at least)
        ui_context.layout,
        alignment,
        padding,
        widget_height,
        widget_width,
        ui_context.image,
        get_colors(widget_type)...,
    )
end

function do_widget!(
        widget_type::Image,
        ui_context::AbstractUIContext,
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
        ui_context.user_input_state.cursor.position,
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
        get_colors(widget_type)...,
    )
end
