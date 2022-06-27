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

function try_set_hot_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (hot_widget == null_widget) && (active_widget == null_widget) && condition
        return widget
    else
        return hot_widget
    end
end

function try_set_active_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (hot_widget == widget) && (active_widget == null_widget) && condition
        return widget
    else
        return active_widget
    end
end

function try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (hot_widget == widget) && (active_widget == null_widget) && condition
        return null_widget
    else
        return hot_widget
    end
end

function try_reset_active_widget(hot_widget, active_widget, null_widget, widget, condition)
    if (hot_widget == widget) && (active_widget == widget) && condition
        return null_widget
    else
        return active_widget
    end
end

#####
##### Button
#####

function get_widget_value(::Button, hot_widget, active_widget, widget, condition)
    if (hot_widget == widget) && (active_widget == widget) && condition
        return true
    else
        return false
    end
end

function do_widget(widget_type::Button, hot_widget, active_widget, null_widget, widget, i_min, j_min, i_max, j_max, i_mouse, j_mouse, ended_down, num_transitions)
    mouse_over_button = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, widget, mouse_over_button)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, widget, mouse_over_button && mouse_went_down)

    value = get_widget_value(widget_type, hot_widget, active_widget, widget, mouse_over_button && mouse_went_up)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_button)

    return hot_widget, active_widget, null_widget, value
end

function do_widget(
        widget_type::Button,
        hot_widget,
        active_widget,
        null_widget,
        widget,
        bounding_box::SD.Rectangle,
        cursor::SD.Point,
        input_button::InputButton
    )

    return do_widget(
                     widget_type,
                     hot_widget,
                     active_widget,
                     null_widget,
                     widget,
                     SD.get_i_min(bounding_box),
                     SD.get_j_min(bounding_box),
                     SD.get_i_max(bounding_box),
                     SD.get_j_max(bounding_box),
                     cursor.i,
                     cursor.j,
                     input_button.ended_down,
                     input_button.num_transitions,
                    )
end

do_widget!!(widget_type::Button, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

function do_widget!(
        widget_type::Button,
        image,
        user_interaction_state,
        user_input_state,
        widget,
        layout::BoxLayout,
        orientation::Vertical,
        widget_height,
        widget_width,
        text,
        font,
        color
    )

    bounding_box = add_widget!(layout, orientation, widget_height, widget_width)
    value = do_widget!(widget_type, user_interaction_state, widget, bounding_box, user_input_state.cursor, user_input_state.mouse_left)
    SD.draw!(image, bounding_box, color)
    SD.draw!(image, SD.TextLine(bounding_box.position, text, font), color)

    return value
end

#####
##### Slider
#####

function get_widget_value(::Slider, hot_widget, active_widget, widget, active_value, last_value)
    if (hot_widget == widget) && (active_widget == widget)
        return active_value
    else
        return last_value
    end
end

function do_widget(widget_type::Slider, hot_widget, active_widget, null_widget, widget, i_min, j_min, i_max, j_max, i_mouse, j_mouse, ended_down, num_transitions, last_value)
    mouse_over_slider = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, widget, mouse_over_slider)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, widget, mouse_over_slider && mouse_went_down)

    value = get_widget_value(widget_type, hot_widget, active_widget, widget, clamp(j_mouse - j_min + one(j_min), one(j_min), j_max - j_min + one(j_min)), last_value)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_slider)

    return hot_widget, active_widget, null_widget, value
end

function do_widget(
        widget_type::Slider,
        hot_widget,
        active_widget,
        null_widget,
        widget,
        bounding_box::SD.Rectangle,
        cursor::SD.Point,
        input_button::InputButton,
        last_value
    )

    return do_widget(
                     widget_type,
                     hot_widget,
                     active_widget,
                     null_widget,
                     widget,
                     SD.get_i_min(bounding_box),
                     SD.get_j_min(bounding_box),
                     SD.get_i_max(bounding_box),
                     SD.get_j_max(bounding_box),
                     cursor.i,
                     cursor.j,
                     input_button.ended_down,
                     input_button.num_transitions,
                     last_value,
                    )
end

do_widget!!(widget_type::Slider, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

function do_widget!(
        widget_type::Slider,
        image,
        user_interaction_state,
        user_input_state,
        widget,
        value,
        layout::BoxLayout,
        orientation::Vertical,
        widget_height,
        widget_width,
        text,
        font,
        text_color,
        slider_color
    )

    bounding_box = add_widget!(layout, orientation, widget_height, widget_width)
    value = do_widget!(widget_type, user_interaction_state, widget, bounding_box, user_input_state.cursor, user_input_state.mouse_left, value)
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, value), slider_color)
    SD.draw!(image, bounding_box, text_color)
    SD.draw!(image, SD.TextLine(bounding_box.position, text, font), text_color)

    return value
end

#####
##### TextBox
#####

function get_widget_value!(::TextBox, hot_widget, active_widget, widget, text, characters)
    if (hot_widget == widget) && (active_widget == widget)
        for character in characters
            if isascii(character)
                if isprint(character)
                    push!(text, character)
                elseif character == '\b'
                    if length(text) > 0
                        pop!(text)
                    end
                end
            end
        end
    end

    return text
end

function do_widget!(widget_type::TextBox, hot_widget, active_widget, null_widget, widget, i_min, j_min, i_max, j_max, i_mouse, j_mouse, ended_down, num_transitions, text, characters)
    mouse_over_widget = (i_min <= i_mouse <= i_max) && (j_min <= j_mouse <= j_max)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, widget, mouse_over_widget)

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, widget, mouse_over_widget && mouse_went_up)

    value = get_widget_value!(widget_type, hot_widget, active_widget, widget, text, characters)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_widget && mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, value
end

function do_widget!(
        widget_type::TextBox,
        hot_widget,
        active_widget,
        null_widget,
        widget,
        bounding_box::SD.Rectangle,
        cursor::SD.Point,
        input_button::InputButton,
        text,
        characters
    )

    return do_widget!(
                     widget_type,
                     hot_widget,
                     active_widget,
                     null_widget,
                     widget,
                     SD.get_i_min(bounding_box),
                     SD.get_j_min(bounding_box),
                     SD.get_i_max(bounding_box),
                     SD.get_j_max(bounding_box),
                     cursor.i,
                     cursor.j,
                     input_button.ended_down,
                     input_button.num_transitions,
                     text,
                     characters,
                    )
end

do_widget!!(widget_type::TextBox, args...; kwargs...) = do_widget!(widget_type, args...; kwargs...)

function do_widget!(
        widget_type::TextBox,
        image,
        user_interaction_state,
        user_input_state,
        widget,
        value,
        layout::BoxLayout,
        orientation::Vertical,
        widget_height,
        widget_width,
        font,
        color,
    )

    bounding_box = add_widget!(layout, orientation, widget_height, widget_width)
    value = do_widget!(widget_type, user_interaction_state, widget, bounding_box, user_input_state.cursor, user_input_state.mouse_left, value, user_input_state.characters)
    SD.draw!(image, bounding_box, color)
    SD.draw!(image, SD.TextLine(bounding_box.position, value, font), color)

    return value
end

#####
##### Text
#####

function do_widget!(
        widget_type::Text,
        image,
        text,
        layout::BoxLayout,
        orientation::Vertical,
        widget_height,
        widget_width,
        font,
        color,
    )

    bounding_box = add_widget!(layout, orientation, widget_height, widget_width)
    SD.draw!(image, bounding_box, color)
    SD.draw!(image, SD.TextLine(bounding_box.position, text, font), color)

    return text
end
