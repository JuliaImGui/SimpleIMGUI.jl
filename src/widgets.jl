abstract type AbstractWidgetType end

struct Button <: AbstractWidgetType end
const BUTTON = Button()

struct Slider <: AbstractWidgetType end
const SLIDER = Slider()

struct TextBox <: AbstractWidgetType end
const TEXT_BOX = TextBox()

struct Text <: AbstractWidgetType end
const TEXT = Text()

#####
##### utils
#####

function try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == null_widget) && (active_widget == null_widget) && condition
        return this_widget
    else
        return hot_widget
    end
end

function try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == null_widget) && condition
        return this_widget
    else
        return active_widget
    end
end

function try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == null_widget) && condition
        return null_widget
    else
        return hot_widget
    end
end

function try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == this_widget) && condition
        return null_widget
    else
        return active_widget
    end
end

#####
##### Button
#####

function get_widget_value(::Button, hot_widget, active_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == this_widget) && condition
        return true
    else
        return false
    end
end

function do_widget(widget_type::Button, hot_widget, active_widget, null_widget, this_widget, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget && mouse_went_down)

    widget_value = get_widget_value(widget_type, hot_widget, active_widget, this_widget, mouse_over_widget && mouse_went_up)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, widget_value
end

function do_widget!(widget_type::Button, user_interaction_state, this_widget, cursor, input_button, widget_bounding_box)
    hot_widget, active_widget, null_widget, widget_value = do_widget(
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

    return widget_value
end

function do_widget!(
        widget_type::Button,
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
        text,
        font,
        colors,
    )

    widget_bounding_box = get_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, cursor, input_button, widget_bounding_box)

    SD.draw!(image, widget_bounding_box, widget_type, user_interaction_state, this_widget, text, font, colors)

    return widget_value
end

#####
##### Slider
#####

function get_widget_value(::Slider, hot_widget, active_widget, this_widget, active_value, widget_value)
    if (hot_widget == this_widget) && (active_widget == this_widget)
        return active_value
    else
        return widget_value
    end
end

function do_widget(widget_type::Slider, hot_widget, active_widget, null_widget, this_widget, widget_value, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget && mouse_went_down)

    widget_value = get_widget_value(widget_type, hot_widget, active_widget, this_widget, clamp(j_mouse - j_min + one(j_min), zero(j_min), j_max - j_min + one(j_min)), widget_value)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, widget_value
end

function do_widget!(widget_type::Slider, user_interaction_state, this_widget, widget_value, cursor, input_button, widget_bounding_box)
    hot_widget, active_widget, null_widget, widget_value = do_widget(
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
        text,
        font,
        colors,
    )

    widget_bounding_box = get_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, widget_value, cursor, input_button, widget_bounding_box)

    SD.draw!(image, widget_bounding_box, widget_type, user_interaction_state, this_widget, widget_value, text, font, colors)

    return widget_value
end

#####
##### TextBox
#####

function get_widget_value!(::TextBox, hot_widget, active_widget, this_widget, widget_value, characters)
    if (hot_widget == this_widget) && (active_widget == this_widget)
        for character in characters
            if isascii(character)
                if isprint(character)
                    push!(widget_value, character)
                elseif character == '\b'
                    if length(widget_value) > 0
                        pop!(widget_value)
                    end
                end
            end
        end
    end

    return widget_value
end

function do_widget!(widget_type::TextBox, hot_widget::AbstractWidgetID, active_widget::AbstractWidgetID, null_widget::AbstractWidgetID, this_widget::AbstractWidgetID, widget_value, i_mouse, j_mouse, ended_down, num_transitions, characters, i_min, j_min, i_max, j_max)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget && mouse_went_up)

    widget_value = get_widget_value!(widget_type, hot_widget, active_widget, this_widget, widget_value, characters)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget && mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, widget_value
end

function do_widget!(widget_type::TextBox, user_interaction_state, this_widget, widget_value, cursor, input_button, characters, widget_bounding_box)
    hot_widget, active_widget, null_widget, widget_value = do_widget!(
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

    return widget_value
end

function do_widget!(
        widget_type::TextBox,
        user_interaction_state::AbstractUserInteractionState,
        this_widget::AbstractWidgetID,
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
        text,
        font,
        colors,
    )

    widget_bounding_box = get_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, widget_value, cursor, input_button, characters, widget_bounding_box)

    SD.draw!(image, widget_bounding_box, widget_type, user_interaction_state, this_widget, text, font, colors)

    return widget_value
end

#####
##### Text
#####

function do_widget(widget_type::Text, hot_widget, active_widget, null_widget, this_widget, widget_value, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_widget && mouse_went_down)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, widget_value
end

function do_widget!(widget_type::Text, user_interaction_state, this_widget, widget_value, cursor, input_button, widget_bounding_box)
    hot_widget, active_widget, null_widget, widget_value = do_widget(
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

    return widget_value
end

function do_widget!(
        widget_type::Text,
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
        text,
        font,
        colors,
    )

    widget_bounding_box = get_bounding_box(layout.reference_bounding_box, alignment, padding, widget_height, widget_width)
    layout.reference_bounding_box = widget_bounding_box

    widget_value = do_widget!(widget_type, user_interaction_state, this_widget, text, cursor, input_button, widget_bounding_box)

    SD.draw!(image, widget_bounding_box, widget_type, user_interaction_state, this_widget, text, font, colors)

    return widget_value
end
