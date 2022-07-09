function get_intersection_extrema(image, shape)
    i_min_shape, i_max_shape = SD.get_i_extrema(shape)
    i_min_image, i_max_image = SD.get_i_extrema(image)

    j_min_shape, j_max_shape = SD.get_j_extrema(shape)
    j_min_image, j_max_image = SD.get_j_extrema(image)

    i_min = max(i_min_image, i_min_shape)
    j_min = max(j_min_image, j_min_shape)

    i_max = min(i_max_image, i_max_shape)
    j_max = min(j_max_image, j_max_shape)

    return i_min, j_min, i_max, j_max
end

function draw_text_line_in_a_box!(image, bounding_box, text, font, alignment, padding, background_color, border_color, text_color)
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    SD.draw!(image, bounding_box, border_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, SD.get_height(font), SD.get_width(font) * length(text), alignment, padding)
    SD.draw!(image, SD.TextLine(SD.move(bounding_box.position, i_offset, j_offset), text, font), text_color)

    return nothing
end

function SD.draw!(image::AbstractMatrix, widget_type::AbstractWidgetType, bounding_box::SD.Rectangle, args...; kwargs...)
    if SD.is_outbounds(image, bounding_box)
        return nothing
    end

    i_min, j_min, i_max, j_max = get_intersection_extrema(image, bounding_box)
    @assert i_max >= i_min
    @assert j_max >= j_min

    view_box_image = @view image[i_min : i_max, j_min : j_max]

    view_box_bounding_box = SD.Rectangle(SD.Point(bounding_box.position.i - i_min + one(i_min), bounding_box.position.j - j_min + one(j_min)), bounding_box.height, bounding_box.width)

    draw_widget!(view_box_image, widget_type, view_box_bounding_box, args...; kwargs...)

    return nothing
end

draw_widget!(image::AbstractMatrix, widget_type::Button, args...; kwargs...) = draw_text_line_in_a_box!(image, args...; kwargs...)

function draw_widget!(image::AbstractMatrix, widget_type::Slider, bounding_box, text, font, alignment, padding, slider_value, background_color, border_color, text_color, slider_color)
    SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, bounding_box.width), background_color)

    if slider_value > zero(slider_value)
        SD.draw!(image, SD.FilledRectangle(bounding_box.position, bounding_box.height, slider_value), slider_color)
    end

    SD.draw!(image, bounding_box, border_color)

    i_offset, j_offset = get_alignment_offset(bounding_box.height, bounding_box.width, SD.get_height(font), SD.get_width(font) * length(text), alignment, padding)
    SD.draw!(image, SD.TextLine(SD.move(bounding_box.position, i_offset, j_offset), text, font), text_color)

    return nothing
end

draw_widget!(image::AbstractMatrix, widget_type::TextBox, args...; kwargs...) = draw_text_line_in_a_box!(image, args...; kwargs...)

draw_widget!(image::AbstractMatrix, widget_type::Text, args...; kwargs...) = draw_text_line_in_a_box!(image, args...; kwargs...)
