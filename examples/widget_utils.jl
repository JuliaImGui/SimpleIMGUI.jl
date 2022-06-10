import SimpleDraw as SD
import SimpleWidgets as SW

Base.convert(::Type{SD.Rectangle{I}}, x::SW.BoundingBox) where {I} = SD.Rectangle(SD.Point(convert(I, x.i_min), convert(I, x.j_min)), convert(I, x.i_max - x.i_min + one(x.i_min)), convert(I, x.j_max - x.j_min + one(x.j_min)))

function SW.do_widget!(
        widget_type::SW.Button,
        image,
        user_interaction_state,
        user_input_state,
        widget,
        layout::SW.BoxLayout,
        orientation::SW.Vertical,
        height_widget,
        width_widget,
        text,
        font,
        color
    )

    layout, bounding_box = SW.add_widget(layout, orientation, height_widget, width_widget)
    value = SW.do_widget!(widget_type, user_interaction_state, widget, bounding_box, user_input_state.cursor, user_input_state.mouse_left)
    rectangle = convert(SD.Rectangle{Int}, bounding_box)
    SD.draw!(image, rectangle, color)
    SD.draw!(image, SD.TextLine(rectangle.position, text, font), color)

    return layout, value
end

function SW.do_widget!(
        widget_type::SW.Slider,
        image,
        user_interaction_state,
        user_input_state,
        widget,
        value,
        layout::SW.BoxLayout,
        orientation::SW.Vertical,
        height_widget,
        width_widget,
        text,
        font,
        text_color,
        slider_color
    )

    layout, bounding_box = SW.add_widget(layout, orientation, height_widget, width_widget)
    value = SW.do_widget!(widget_type, user_interaction_state, widget, bounding_box, user_input_state.cursor, user_input_state.mouse_left, value)
    rectangle = convert(SD.Rectangle{Int}, bounding_box)
    SD.draw!(image, SD.FilledRectangle(rectangle.position, rectangle.height, value), slider_color)
    SD.draw!(image, rectangle, text_color)
    SD.draw!(image, SD.TextLine(rectangle.position, text, font), text_color)

    return layout, value
end

function SW.do_widget!(
        widget_type::SW.TextInput,
        image,
        user_interaction_state,
        user_input_state,
        widget,
        value,
        layout::SW.BoxLayout,
        orientation::SW.Vertical,
        height_widget,
        width_widget,
        font,
        color,
    )

    layout, bounding_box = SW.add_widget(layout, orientation, height_widget, width_widget)
    SW.do_widget!(widget_type, user_interaction_state, widget, bounding_box, user_input_state.cursor, user_input_state.mouse_left, value, user_input_state.characters)
    rectangle = convert(SD.Rectangle{Int}, bounding_box)
    SD.draw!(image, rectangle, color)
    SD.draw!(image, SD.TextLine(rectangle.position, value, font), color)

    return layout, value
end
