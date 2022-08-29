#####
##### helper methods for bundled arguments for methods in widget_core.jl
#####

function do_widget!(
        widget_type::Union{Button, Text, Image},
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        cursor::SD.Point,
        input_button::InputButton,
        widget_bounding_box::SD.Rectangle,
    )

    hot_widget, active_widget, null_widget, new_widget_value = do_widget!!(
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

    return new_widget_value
end

function do_widget!(
        widget_type::Union{Slider, CheckBox, RadioButton, DropDown},
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        widget_value,
        cursor::SD.Point,
        input_button::InputButton,
        widget_bounding_box::SD.Rectangle,
    )

    hot_widget, active_widget, null_widget, new_widget_value = do_widget!!(
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

    return new_widget_value
end

function do_widget!(
        widget_type::TextBox,
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        widget_value,
        cursor::SD.Point,
        input_button::InputButton,
        characters::Vector,
        widget_bounding_box::SD.Rectangle,
    )

    hot_widget, active_widget, null_widget, new_widget_value = do_widget!!(
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

    return new_widget_value
end

function do_widget!(
        widget_type::ScrollBar,
        user_interaction_state::AbstractUserInteractionState,
        this_widget,
        widget_value,
        cursor::SD.Point,
        input_button::InputButton,
        widget_bounding_box::SD.Rectangle,
    )

    hot_widget, active_widget, null_widget, new_widget_value = do_widget!!(
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

    return new_widget_value
end

function do_widget!(
        widget_type,
        user_interaction_state::AbstractUserInteractionState,
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

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, cursor, input_button, widget_bounding_box)

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, text, font, content_alignment, content_padding, background_color, border_color, text_color)

    return widget_value
end

function do_widget!(
        widget_type,
        user_interaction_state::AbstractUserInteractionState,
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

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, widget_value, cursor, input_button, widget_bounding_box)

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, text, font, background_color, border_color, text_color, indicator_color)

    return widget_value
end

function do_widget!(
        widget_type,
        user_interaction_state::AbstractUserInteractionState,
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

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, widget_value, cursor, input_button, characters, widget_bounding_box)

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, content_alignment, content_padding, font, background_color, border_color, text_color)

    return widget_value
end

function do_widget!(
        widget_type,
        user_interaction_state::AbstractUserInteractionState,
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

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, widget_value, cursor, input_button, widget_bounding_box)

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, widget_value, background_color, border_color, indicator_color)

    return widget_value
end

function do_widget!(
        widget_type::Image,
        user_interaction_state::AbstractUserInteractionState,
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

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, cursor, input_button, widget_bounding_box)

    draw_widget!(image, widget_type, widget_bounding_box, user_interaction_state, this_widget, content, content_alignment, content_padding, border_color)

    return widget_value
end
