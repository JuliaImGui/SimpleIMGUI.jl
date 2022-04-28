import ModernGL as MGL
import DataStructures as DS
import GLFW
import SimpleDraw as SD
import SimpleWidgets as SW

include("opengl_utils.jl")

mutable struct Button
    ended_down::Bool
    half_transition_count::Int
end

function update_button!(button, action)
    if action == GLFW.PRESS
        button.ended_down = true
        button.half_transition_count += 1
    elseif action == GLFW.RELEASE
        button.ended_down = false
        button.half_transition_count += 1
    end

    return nothing
end

function draw_lines!(image, lines, color)
    font = SD.TERMINUS_32_16
    height_font = 32

    for (i, text) in enumerate(lines)
        position = SD.Point(1 + (i - 1) * height_font, 1)
        SD.draw!(image, SD.TextLine(position, text, font), color)
    end

    return nothing
end

function start()
    height_image = 720
    width_image = 1280
    window_name = "Example"
    background_color = 0x00c0c0c0
    text_color = 0x00000000
    sliding_window_size = 30

    image = zeros(MGL.GLuint, height_image, width_image)
    lines = String[]

    SD.draw!(image, SD.Background(), background_color)
    draw_lines!(image, lines, text_color)

    i = 0

    time_stamp_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(time_stamp_buffer, time_ns())

    drawing_time_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(drawing_time_buffer, zero(UInt))

    hot_widget = SW.NULL_WIDGET_ID
    active_widget = SW.NULL_WIDGET_ID
    slider_value = 1
    text_line = collect("Text box")

    setup_window_hints()
    window = GLFW.CreateWindow(width_image, height_image, window_name)
    GLFW.MakeContextCurrent(window)

    key_up = Button(false, 0)
    key_down = Button(false, 0)
    key_left = Button(false, 0)
    key_right = Button(false, 0)
    characters = Char[]

    function key_callback(window, key, scancode, action, mods)::Cvoid
        if key == GLFW.KEY_ESCAPE && action == GLFW.PRESS
            GLFW.SetWindowShouldClose(window, true)
        elseif key == GLFW.KEY_UP
            update_button!(key_up, action)
        elseif key == GLFW.KEY_DOWN
            update_button!(key_down, action)
        elseif key == GLFW.KEY_LEFT
            update_button!(key_left, action)
        elseif key == GLFW.KEY_RIGHT
            update_button!(key_right, action)
        elseif key == GLFW.KEY_BACKSPACE && (action == GLFW.PRESS || action == GLFW.REPEAT)
            push!(characters, '\b')
        end

        return nothing
    end

    GLFW.SetKeyCallback(window, key_callback)

    mouse_left = Button(false, 0)
    mouse_right = Button(false, 0)
    mouse_middle = Button(false, 0)

    function mouse_button_callback(window, button, action, mods)::Cvoid
        if button == GLFW.MOUSE_BUTTON_LEFT
            update_button!(mouse_left, action)
        elseif button == GLFW.MOUSE_BUTTON_RIGHT
            update_button!(mouse_right, action)
        elseif button == GLFW.MOUSE_BUTTON_MIDDLE
            update_button!(mouse_middle, action)
        end

        return nothing
    end

    GLFW.SetMouseButtonCallback(window, mouse_button_callback)

    i_cursor = 0
    j_cursor = 0

    function cursor_position_callback(window, x, y)::Cvoid
        i_cursor = round(Int, y)
        j_cursor = round(Int, x)

        return nothing
    end

    GLFW.SetCursorPosCallback(window, cursor_position_callback)

    function character_callback(window, unicode_codepoint)
        return push!(characters, Char(unicode_codepoint))
    end

    GLFW.SetCharCallback(window, character_callback)

    MGL.glViewport(0, 0, width_image, height_image)

    vertex_shader = setup_vertex_shader()
    fragment_shader = setup_fragment_shader()
    shader_program = setup_shader_program(vertex_shader, fragment_shader)

    VAO_ref, VBO_ref, EBO_ref = setup_vao_vbo_ebo()

    texture_ref = setup_texture(image)

    MGL.glUseProgram(shader_program)
    MGL.glBindVertexArray(VAO_ref[])

    clear_display()

    while !GLFW.WindowShouldClose(window)
        drawing_time_start = time_ns()
        SD.draw!(image, SD.Background(), background_color)

        button1_shape = SD.Rectangle(SD.Point(577, 1), 32, 200)
        button1_id = SW.WidgetID(@__LINE__, @__FILE__)
        hot_widget, active_widget, button1_value = SW.widget(hot_widget, active_widget, button1_id, SW.UI_BUTTON, SD.get_i_min(button1_shape), SD.get_j_min(button1_shape), SD.get_i_max(button1_shape), SD.get_j_max(button1_shape), i_cursor, j_cursor, mouse_left.ended_down, mouse_left.half_transition_count)
        if button1_value
            text_color = 0x00aa0000
        end
        SD.draw!(image, button1_shape, text_color)
        SD.draw!(image, SD.TextLine(SD.Point(577, 1), "Button 1", SD.TERMINUS_32_16), text_color)

        button2_shape = SD.Rectangle(SD.Point(609, 1), 32, 200)
        button2_id = SW.WidgetID(@__LINE__, @__FILE__)
        hot_widget, active_widget, button2_value = SW.widget(hot_widget, active_widget, button2_id, SW.UI_BUTTON, SD.get_i_min(button2_shape), SD.get_j_min(button2_shape), SD.get_i_max(button2_shape), SD.get_j_max(button2_shape), i_cursor, j_cursor, mouse_left.ended_down, mouse_left.half_transition_count)
        if button2_value
            text_color = 0x00000000
        end
        SD.draw!(image, button2_shape, text_color)
        SD.draw!(image, SD.TextLine(SD.Point(609, 1), "Button 2", SD.TERMINUS_32_16), text_color)

        slider_shape = SD.Rectangle(SD.Point(641, 1), 32, 200)
        slider_id = SW.WidgetID(@__LINE__, @__FILE__)
        hot_widget, active_widget, slider_value = SW.widget(hot_widget, active_widget, slider_id, SW.UI_SLIDER, SD.get_i_min(slider_shape), SD.get_j_min(slider_shape), SD.get_i_max(slider_shape), SD.get_j_max(slider_shape), i_cursor, j_cursor, mouse_left.ended_down, mouse_left.half_transition_count, slider_value)
        SD.draw!(image, slider_shape, text_color)
        slider_value_shape = SD.FilledRectangle(SD.Point(641, 1), 32, slider_value)
        SD.draw!(image, slider_value_shape, text_color)
        SD.draw!(image, SD.TextLine(SD.Point(641, 1), "Slider", SD.TERMINUS_32_16), 0x00ffffff)

        text_input_shape = SD.Rectangle(SD.Point(673, 1), 32, 200)
        text_input_id = SW.WidgetID(@__LINE__, @__FILE__)
        hot_widget, active_widget = SW.widget!(hot_widget, active_widget, text_input_id, SW.UI_TEXT_INPUT, SD.get_i_min(text_input_shape), SD.get_j_min(text_input_shape), SD.get_i_max(text_input_shape), SD.get_j_max(text_input_shape), i_cursor, j_cursor, mouse_left.ended_down, mouse_left.half_transition_count, text_line, characters)
        SD.draw!(image, text_input_shape, text_color)
        text_input_value_shape = SD.TextLine(SD.Point(673, 1), String(text_line), SD.TERMINUS_32_16)
        SD.draw!(image, text_input_value_shape, text_color)

        empty!(lines)
        push!(lines, "Press the escape key to quit")
        push!(lines, "previous frame number: $(i)")
        push!(lines, "average total time spent per frame (averaged over previous $(length(time_stamp_buffer)) frames): $(round((last(time_stamp_buffer) - first(time_stamp_buffer)) / (1e6 * length(time_stamp_buffer)), digits = 2)) ms")
        push!(lines, "average compute time spent per frame (averaged over previous $(length(drawing_time_buffer)) frames): $(round(sum(drawing_time_buffer) / (1e6 * length(drawing_time_buffer)), digits = 2)) ms")
        push!(lines, "key_up: $(key_up)")
        push!(lines, "key_down: $(key_down)")
        push!(lines, "key_left: $(key_left)")
        push!(lines, "key_right: $(key_right)")
        push!(lines, "mouse_left: $(mouse_left)")
        push!(lines, "mouse_right: $(mouse_right)")
        push!(lines, "mouse_middle: $(mouse_middle)")
        push!(lines, "(i_cursor, j_cursor): ($(i_cursor), $(j_cursor))")
        push!(lines, "button1_value: $(button1_value)")
        push!(lines, "button2_value: $(button2_value)")
        push!(lines, "text_color: $(repr(text_color))")
        push!(lines, "slider_value: $(slider_value)")
        push!(lines, "hot_widget: $(hot_widget)")
        push!(lines, "active_widget: $(active_widget)")

        draw_lines!(image, lines, text_color)

        drawing_time_end = time_ns()
        push!(drawing_time_buffer, drawing_time_end - drawing_time_start)

        update_back_buffer(image)

        GLFW.SwapBuffers(window)

        key_up.half_transition_count = 0
        key_down.half_transition_count = 0
        key_left.half_transition_count = 0
        key_right.half_transition_count = 0
        mouse_left.half_transition_count = 0
        mouse_right.half_transition_count = 0
        mouse_middle.half_transition_count = 0
        empty!(characters)

        GLFW.PollEvents()

        i = i + 1

        push!(time_stamp_buffer, time_ns())
    end

    MGL.glDeleteVertexArrays(1, VAO_ref)
    MGL.glDeleteBuffers(1, VBO_ref)
    MGL.glDeleteBuffers(1, EBO_ref)
    MGL.glDeleteProgram(shader_program)

    GLFW.DestroyWindow(window)

    return nothing
end

start()
