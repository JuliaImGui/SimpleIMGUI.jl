abstract type AbstractWidgetType end

struct Button <: AbstractWidgetType end
const BUTTON = Button()

struct Slider <: AbstractWidgetType end
const SLIDER = Slider()

struct TextBox <: AbstractWidgetType end
const TEXT_BOX = TextBox()

struct Text <: AbstractWidgetType end
const TEXT = Text()

struct CheckBox <: AbstractWidgetType end
const CHECK_BOX = CheckBox()

struct RadioButton <: AbstractWidgetType end
const RADIO_BUTTON = RadioButton()

struct DropDown <: AbstractWidgetType end
const DROP_DOWN = DropDown()

struct ScrollBar <: AbstractWidgetType end
const SCROLL_BAR = ScrollBar()

struct Image <: AbstractWidgetType end
const IMAGE = Image()

#####
##### utils
#####

"""
    try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next hot widget. It could either be `hot_widget` or `this_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_active_widget`](@ref), [`try_reset_active_widget`](@ref), [`try_reset_hot_widget`](@ref).
"""
function try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == null_widget) && (active_widget == null_widget) && condition
        return this_widget
    else
        return hot_widget
    end
end

"""
    try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next active widget. It could either be `active_widget` or `this_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_hot_widget`](@ref), [`try_reset_active_widget`](@ref), [`try_reset_hot_widget`](@ref).
"""
function try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == null_widget) && condition
        return this_widget
    else
        return active_widget
    end
end

"""
    try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next hot widget. It could either be `hot_widget` or `null_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_hot_widget`](@ref), [`try_set_active_widget`](@ref), [`try_reset_active_widget`](@ref).
"""
function try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == null_widget) && condition
        return null_widget
    else
        return hot_widget
    end
end

"""
    try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, condition)

Return the next active widget. It could either be `active_widget` or `null_widget` depending upon the state of `this_widget` and the `condition`.

See also [`try_set_hot_widget`](@ref), [`try_set_active_widget`](@ref), [`try_reset_hot_widget`](@ref).
"""
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

function get_widget_value(::Union{Button, Text, Image}, hot_widget, active_widget, this_widget, condition)
    if (hot_widget == this_widget) && (active_widget == this_widget) && condition
        return true
    else
        return false
    end
end

function do_widget(widget_type::Union{Button, Text, Image}, hot_widget, active_widget, null_widget, this_widget, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
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

do_widget!!(widget_type::Union{Button, Text, Image}, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

#####
##### Slider
#####

function get_widget_value(::Slider, hot_widget, active_widget, this_widget, widget_value, potential_next_widget_value)
    if (hot_widget == this_widget) && (active_widget == this_widget)
        return potential_next_widget_value
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

    widget_value = get_widget_value(widget_type, hot_widget, active_widget, this_widget, widget_value, clamp(j_mouse - j_min + one(j_min), zero(j_min), j_max - j_min + one(j_min)))

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_widget)

    return hot_widget, active_widget, null_widget, widget_value
end

do_widget!!(widget_type::Slider, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

#####
##### TextBox
#####

function get_widget_value!(::TextBox, hot_widget, active_widget, this_widget, widget_value, characters)
    if (hot_widget == this_widget) && (active_widget == this_widget)
        for character in characters
            if isprint(character)
                push!(widget_value, character)
            elseif character == '\b'
                if get_num_printable_characters(widget_value) > 0
                    pop!(widget_value)
                end
            end
        end
    end

    return widget_value
end

function do_widget!(widget_type::TextBox, hot_widget, active_widget, null_widget, this_widget, widget_value, i_mouse, j_mouse, ended_down, num_transitions, characters, i_min, j_min, i_max, j_max)
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

do_widget!!(widget_type::TextBox, args...; kwargs...) = do_widget!(widget_type, args...; kwargs...)

#####
##### CheckBox
#####

function do_widget(widget_type::Union{CheckBox, RadioButton, DropDown}, hot_widget, active_widget, null_widget, this_widget, widget_value, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
    hot_widget, active_widget, null_widget, button_value = do_widget(BUTTON, hot_widget, active_widget, null_widget, this_widget, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)

    if button_value
        widget_value = !widget_value
    end

    return hot_widget, active_widget, null_widget, widget_value
end

do_widget!!(widget_type::Union{CheckBox, RadioButton, DropDown}, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

#####
##### ScrollBar
#####

function get_widget_value(widget_type, hot_widget, active_widget, this_widget, i_slider_value, j_slider_value, height_slider, width_slider, i_slider_relative_mouse, j_slider_relative_mouse, i_mouse, j_mouse, i_min, j_min, i_max, j_max)
    if (hot_widget == this_widget) && (active_widget == this_widget)
        i_slider_value = i_mouse + i_slider_relative_mouse - i_min
        j_slider_value = j_mouse + j_slider_relative_mouse - j_min

        i_slider_value = clamp(i_slider_value, zero(i_slider_value), i_max - i_min + one(i_min) - height_slider)
        j_slider_value = clamp(j_slider_value, zero(j_slider_value), j_max - j_min + one(j_min) - width_slider)

        return i_slider_value, j_slider_value
    else
        return i_slider_value, j_slider_value
    end
end

function do_widget(widget_type::ScrollBar, hot_widget, active_widget, null_widget, this_widget, i_slider_value, j_slider_value, height_slider, width_slider, i_slider_relative_mouse, j_slider_relative_mouse, i_mouse, j_mouse, ended_down, num_transitions, i_min, j_min, i_max, j_max)
    i_min_slider = i_min + i_slider_value
    j_min_slider = j_min + j_slider_value

    i_max_slider = i_min_slider + height_slider - one(height_slider)
    j_max_slider = j_min_slider + width_slider - one(height_slider)

    mouse_over_slider = (i_min_slider <= i_mouse <= i_max_slider) && (j_min_slider <= j_mouse <= j_max_slider)
    mouse_went_down = went_down(ended_down, num_transitions)
    mouse_went_up = went_up(ended_down, num_transitions)

    hot_widget = try_set_hot_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_slider)

    if (hot_widget == this_widget) && (active_widget == null_widget)
        i_slider_relative_mouse = i_min_slider - i_mouse
        j_slider_relative_mouse = j_min_slider - j_mouse
    end

    active_widget = try_set_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_over_slider && mouse_went_down)

    i_slider_value, j_slider_value = get_widget_value(widget_type, hot_widget, active_widget, this_widget, i_slider_value, j_slider_value, height_slider, width_slider, i_slider_relative_mouse, j_slider_relative_mouse, i_mouse, j_mouse, i_min, j_min, i_max, j_max)

    active_widget = try_reset_active_widget(hot_widget, active_widget, null_widget, this_widget, mouse_went_up)

    hot_widget = try_reset_hot_widget(hot_widget, active_widget, null_widget, this_widget, !mouse_over_slider)

    return hot_widget, active_widget, null_widget, (i_slider_value, j_slider_value, height_slider, width_slider, i_slider_relative_mouse, j_slider_relative_mouse)
end

do_widget!!(widget_type::ScrollBar, args...; kwargs...) = do_widget(widget_type, args...; kwargs...)

#####
##### helper functions
#####

function do_widget!(widget_type, user_interaction_state::AbstractUserInteractionState, this_widget, cursor::SD.Point, input_button::InputButton, widget_bounding_box::SD.Rectangle)
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

    return widget_value
end

function do_widget!(widget_type, user_interaction_state::AbstractUserInteractionState, this_widget, widget_value, cursor::SD.Point, input_button::InputButton, widget_bounding_box::SD.Rectangle)
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

    return widget_value
end

function do_widget!(widget_type, user_interaction_state::AbstractUserInteractionState, this_widget, widget_value, cursor::SD.Point, input_button::InputButton, characters::Vector, widget_bounding_box::SD.Rectangle)
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

    return widget_value
end

function do_widget!(widget_type::ScrollBar, user_interaction_state::AbstractUserInteractionState, this_widget, widget_value, cursor::SD.Point, input_button::InputButton, widget_bounding_box::SD.Rectangle)
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

    return widget_value
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
