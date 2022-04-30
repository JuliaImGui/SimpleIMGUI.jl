import ModernGL as MGL
import DataStructures as DS
import GLFW
import SimpleDraw as SD
import SimpleWidgets as SW

include("opengl_utils.jl")

mutable struct UIState <: SW.AbstractUIState
    hot_widget::SW.WidgetID
    active_widget::SW.WidgetID
    null_widget::SW.WidgetID
end

mutable struct UserInputState
    cursor::SW.Cursor
    key_up::SW.InputButton
    key_down::SW.InputButton
    key_left::SW.InputButton
    key_right::SW.InputButton
    mouse_left::SW.InputButton
    mouse_right::SW.InputButton
    mouse_middle::SW.InputButton
    characters::Vector{Char}
end

function update_button(button, action)
    if action == GLFW.PRESS
        return SW.press_button(button)
    elseif action == GLFW.RELEASE
        return SW.release_button(button)
    else
        return button
    end
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

    ui_state = UIState(SW.NULL_WIDGET_ID, SW.NULL_WIDGET_ID, SW.NULL_WIDGET_ID)

    user_input_state = UserInputState(
                                      SW.Cursor(1, 1),
                                      SW.InputButton(false, 0),
                                      SW.InputButton(false, 0),
                                      SW.InputButton(false, 0),
                                      SW.InputButton(false, 0),
                                      SW.InputButton(false, 0),
                                      SW.InputButton(false, 0),
                                      SW.InputButton(false, 0),
                                      Char[],
                                     )

    slider_value = 1
    text_line = collect("Text box")

    setup_window_hints()
    window = GLFW.CreateWindow(width_image, height_image, window_name)
    GLFW.MakeContextCurrent(window)

    function key_callback(window, key, scancode, action, mods)::Cvoid
        if key == GLFW.KEY_ESCAPE && action == GLFW.PRESS
            GLFW.SetWindowShouldClose(window, true)
        elseif key == GLFW.KEY_UP
            user_input_state.key_up = update_button(user_input_state.key_up, action)
        elseif key == GLFW.KEY_DOWN
            user_input_state.key_down = update_button(user_input_state.key_down, action)
        elseif key == GLFW.KEY_LEFT
            user_input_state.key_left = update_button(user_input_state.key_left, action)
        elseif key == GLFW.KEY_RIGHT
            user_input_state.key_right = update_button(user_input_state.key_right, action)
        elseif key == GLFW.KEY_BACKSPACE && (action == GLFW.PRESS || action == GLFW.REPEAT)
            push!(user_input_state.characters, '\b')
        end

        return nothing
    end

    GLFW.SetKeyCallback(window, key_callback)

    function mouse_button_callback(window, button, action, mods)::Cvoid
        if button == GLFW.MOUSE_BUTTON_LEFT
            user_input_state.mouse_left = update_button(user_input_state.mouse_left, action)
        elseif button == GLFW.MOUSE_BUTTON_RIGHT
            user_input_state.mouse_right = update_button(user_input_state.mouse_right, action)
        elseif button == GLFW.MOUSE_BUTTON_MIDDLE
            user_input_state.mouse_middle = update_button(user_input_state.mouse_middle, action)
        end

        return nothing
    end

    GLFW.SetMouseButtonCallback(window, mouse_button_callback)

    function cursor_position_callback(window, x, y)::Cvoid
        user_input_state.cursor = SW.Cursor(round(Int, y, RoundDown) + 1, round(Int, x, RoundDown) + 1)

        return nothing
    end

    GLFW.SetCursorPosCallback(window, cursor_position_callback)

    function character_callback(window, unicode_codepoint)
        return push!(user_input_state.characters, Char(unicode_codepoint))
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
        button1_value = SW.widget!(ui_state, button1_id, SW.BUTTON, SD.get_i_min(button1_shape), SD.get_j_min(button1_shape), SD.get_i_max(button1_shape), SD.get_j_max(button1_shape), user_input_state.cursor.i, user_input_state.cursor.j, user_input_state.mouse_left.ended_down, user_input_state.mouse_left.half_transition_count)
        if button1_value
            text_color = 0x00aa0000
        end
        SD.draw!(image, button1_shape, text_color)
        SD.draw!(image, SD.TextLine(SD.Point(577, 1), "Button 1", SD.TERMINUS_32_16), text_color)

        button2_shape = SD.Rectangle(SD.Point(609, 1), 32, 200)
        button2_id = SW.WidgetID(@__LINE__, @__FILE__)
        button2_value = SW.widget!(ui_state, button2_id, SW.BUTTON, SD.get_i_min(button2_shape), SD.get_j_min(button2_shape), SD.get_i_max(button2_shape), SD.get_j_max(button2_shape), user_input_state.cursor.i, user_input_state.cursor.j, user_input_state.mouse_left.ended_down, user_input_state.mouse_left.half_transition_count)
        if button2_value
            text_color = 0x00000000
        end
        SD.draw!(image, button2_shape, text_color)
        SD.draw!(image, SD.TextLine(SD.Point(609, 1), "Button 2", SD.TERMINUS_32_16), text_color)

        slider_shape = SD.Rectangle(SD.Point(641, 1), 32, 200)
        slider_id = SW.WidgetID(@__LINE__, @__FILE__)
        slider_value = SW.widget!(ui_state, slider_id, SW.SLIDER, SD.get_i_min(slider_shape), SD.get_j_min(slider_shape), SD.get_i_max(slider_shape), SD.get_j_max(slider_shape), user_input_state.cursor.i, user_input_state.cursor.j, user_input_state.mouse_left.ended_down, user_input_state.mouse_left.half_transition_count, slider_value)
        SD.draw!(image, slider_shape, text_color)
        slider_value_shape = SD.FilledRectangle(SD.Point(641, 1), 32, slider_value)
        SD.draw!(image, slider_value_shape, text_color)
        SD.draw!(image, SD.TextLine(SD.Point(641, 1), "Slider", SD.TERMINUS_32_16), 0x00ffffff)

        text_input_shape = SD.Rectangle(SD.Point(673, 1), 32, 200)
        text_input_id = SW.WidgetID(@__LINE__, @__FILE__)
        SW.widget!(ui_state, text_input_id, SW.TEXT_INPUT, SD.get_i_min(text_input_shape), SD.get_j_min(text_input_shape), SD.get_i_max(text_input_shape), SD.get_j_max(text_input_shape), user_input_state.cursor.i, user_input_state.cursor.j, user_input_state.mouse_left.ended_down, user_input_state.mouse_left.half_transition_count, text_line, user_input_state.characters)
        SD.draw!(image, text_input_shape, text_color)
        text_input_value_shape = SD.TextLine(SD.Point(673, 1), String(text_line), SD.TERMINUS_32_16)
        SD.draw!(image, text_input_value_shape, text_color)

        empty!(lines)
        push!(lines, "Press the escape key to quit")
        push!(lines, "previous frame number: $(i)")
        push!(lines, "average total time spent per frame (averaged over previous $(length(time_stamp_buffer)) frames): $(round((last(time_stamp_buffer) - first(time_stamp_buffer)) / (1e6 * length(time_stamp_buffer)), digits = 2)) ms")
        push!(lines, "average compute time spent per frame (averaged over previous $(length(drawing_time_buffer)) frames): $(round(sum(drawing_time_buffer) / (1e6 * length(drawing_time_buffer)), digits = 2)) ms")
        push!(lines, "user_input_state.key_up: $(user_input_state.key_up)")
        push!(lines, "user_input_state.key_down: $(user_input_state.key_down)")
        push!(lines, "user_input_state.key_left: $(user_input_state.key_left)")
        push!(lines, "user_input_state.key_right: $(user_input_state.key_right)")
        push!(lines, "user_input_state.mouse_left: $(user_input_state.mouse_left)")
        push!(lines, "user_input_state.mouse_right: $(user_input_state.mouse_right)")
        push!(lines, "user_input_state.mouse_middle: $(user_input_state.mouse_middle)")
        push!(lines, "user_input_state.cursor: $(user_input_state.cursor)")
        push!(lines, "button1_value: $(button1_value)")
        push!(lines, "button2_value: $(button2_value)")
        push!(lines, "text_color: $(repr(text_color))")
        push!(lines, "slider_value: $(slider_value)")
        push!(lines, "ui_state.hot_widget: $(ui_state.hot_widget)")
        push!(lines, "ui_state.active_widget: $(ui_state.active_widget)")

        draw_lines!(image, lines, text_color)

        drawing_time_end = time_ns()
        push!(drawing_time_buffer, drawing_time_end - drawing_time_start)

        update_back_buffer(image)

        GLFW.SwapBuffers(window)

        user_input_state.key_up = SW.reset(user_input_state.key_up)
        user_input_state.key_down = SW.reset(user_input_state.key_down)
        user_input_state.key_left = SW.reset(user_input_state.key_left)
        user_input_state.key_right = SW.reset(user_input_state.key_right)
        user_input_state.mouse_left = SW.reset(user_input_state.mouse_left)
        user_input_state.mouse_right = SW.reset(user_input_state.mouse_right)
        user_input_state.mouse_middle = SW.reset(user_input_state.mouse_middle)
        empty!(user_input_state.characters)


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
