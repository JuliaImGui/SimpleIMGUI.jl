import SimpleDraw as SD
import SimpleWidgets as SW

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
    SD.draw!(image, bounding_box, color)
    SD.draw!(image, SD.TextLine(bounding_box.position, text, font), color)

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
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, value), slider_color)
    SD.draw!(image, bounding_box, text_color)
    SD.draw!(image, SD.TextLine(bounding_box.position, text, font), text_color)

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
    value = SW.do_widget!(widget_type, user_interaction_state, widget, bounding_box, user_input_state.cursor, user_input_state.mouse_left, value, user_input_state.characters)
    SD.draw!(image, bounding_box, color)
    SD.draw!(image, SD.TextLine(bounding_box.position, value, font), color)

    return layout, value
end

function SW.do_widget!(
        widget_type::SW.TextDisplay,
        image,
        text,
        layout::SW.BoxLayout,
        orientation::SW.Vertical,
        height_widget,
        width_widget,
        font,
        color,
    )

    layout, bounding_box = SW.add_widget(layout, orientation, height_widget, width_widget)
    SD.draw!(image, bounding_box, color)
    SD.draw!(image, SD.TextLine(bounding_box.position, text, font), color)

    return layout, text
end
