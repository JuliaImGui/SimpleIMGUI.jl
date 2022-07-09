function SD.draw!(image, bounding_box, text, font, alignment, padding, background_color, border_color, text_color)
    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, SD.get_height(font), SD.get_width(font) * length(text), alignment, padding)
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)
    SD.draw!(image, bounding_box, border_color)
    SD.draw!(image, SD.TextLine(SD.move(bounding_box.position, i_offset, j_offset), text, font), text_color)

    return nothing
end

SD.draw!(image, widget_type::Button, args...; kwargs...) = SD.draw!(image, args..., kwargs...)

function SD.draw!(image, widget_type::Slider, bounding_box, text, font, alignment, padding, slider_value, background_color, border_color, text_color, slider_color)
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    if slider_value > zero(slider_value)
        SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, slider_value), slider_color)
    end

    SD.draw!(image, bounding_box, border_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, SD.get_height(font), SD.get_width(font) * length(text), alignment, padding)
    SD.draw!(image, SD.TextLine(SD.move(bounding_box.position, i_offset, j_offset), text, font), text_color)

    return nothing
end

SD.draw!(image, widget_type::TextBox, args...; kwargs...) = SD.draw!(image, args..., kwargs...)

SD.draw!(image, widget_type::Text, args...; kwargs...) = SD.draw!(image, args..., kwargs...)
