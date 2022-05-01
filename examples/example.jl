import ModernGL as MGL
import DataStructures as DS
import GLFW
import SimpleDraw as SD
import SimpleWidgets as SW

include("opengl_utils.jl")

mutable struct UserInteractionState <: SW.AbstractUIState
    hot_widget::SW.WidgetID
    active_widget::SW.WidgetID
    null_widget::SW.WidgetID
end

mutable struct UserInputState
    cursor::SW.Cursor
    key_escape::SW.InputButton
    key_up::SW.InputButton
    key_down::SW.InputButton
    key_left::SW.InputButton
    key_right::SW.InputButton
    mouse_left::SW.InputButton
    mouse_right::SW.InputButton
    mouse_middle::SW.InputButton
    characters::Vector{Char}
end

function reset!(user_input_state::UserInputState)
    user_input_state.key_escape = SW.reset(user_input_state.key_escape)
    user_input_state.key_up = SW.reset(user_input_state.key_up)
    user_input_state.key_down = SW.reset(user_input_state.key_down)
    user_input_state.key_left = SW.reset(user_input_state.key_left)
    user_input_state.key_right = SW.reset(user_input_state.key_right)
    user_input_state.mouse_left = SW.reset(user_input_state.mouse_left)
    user_input_state.mouse_right = SW.reset(user_input_state.mouse_right)
    user_input_state.mouse_middle = SW.reset(user_input_state.mouse_middle)
    empty!(user_input_state.characters)

    return nothing
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

Base.convert(::Type{SD.Rectangle{I}}, x::SW.BoundingBox) where {I} = SD.Rectangle(SD.Point(convert(I, x.i_min), convert(I, x.j_min)), convert(I, x.i_max - x.i_min + one(x.i_min)), convert(I, x.j_max - x.j_min + one(x.j_min)))

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

    compute_time_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(compute_time_buffer, zero(UInt))

    user_interaction_state = UserInteractionState(SW.NULL_WIDGET_ID, SW.NULL_WIDGET_ID, SW.NULL_WIDGET_ID)

    user_input_state = UserInputState(
                                      SW.Cursor(1, 1),
                                      SW.InputButton(false, 0),
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
        if key == GLFW.KEY_ESCAPE
            user_input_state.key_escape = update_button(user_input_state.key_escape, action)
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
        if SW.went_down(user_input_state.key_escape.ended_down, user_input_state.key_escape.half_transition_count)
            GLFW.SetWindowShouldClose(window, true)
            break
        end

        compute_time_start = time_ns()

        SD.draw!(image, SD.Background(), background_color)

        button1 = SW.WidgetID(@__LINE__, @__FILE__)
        button1_bounding_box = SW.BoundingBox(577, 1, 608, 200)
        button1_value = SW.do_widget!(user_interaction_state, button1, SW.BUTTON, button1_bounding_box, user_input_state.cursor, user_input_state.mouse_left)
        if button1_value
            text_color = 0x00aa0000
        end
        button1_rectangle = convert(SD.Rectangle{Int}, button1_bounding_box)
        SD.draw!(image, button1_rectangle, text_color)
        SD.draw!(image, SD.TextLine(button1_rectangle.position, "Button 1", SD.TERMINUS_32_16), text_color)

        button2 = SW.WidgetID(@__LINE__, @__FILE__)
        button2_bounding_box = SW.BoundingBox(609, 1, 640, 200)
        button2_value = SW.do_widget!(user_interaction_state, button2, SW.BUTTON, button2_bounding_box, user_input_state.cursor, user_input_state.mouse_left)
        if button2_value
            text_color = 0x00000000
        end
        button2_rectangle = convert(SD.Rectangle{Int}, button2_bounding_box)
        SD.draw!(image, button2_rectangle, text_color)
        SD.draw!(image, SD.TextLine(button2_rectangle.position, "Button 2", SD.TERMINUS_32_16), text_color)

        slider = SW.WidgetID(@__LINE__, @__FILE__)
        slider_bounding_box = SW.BoundingBox(641, 1, 672, 200)
        slider_value = SW.do_widget!(user_interaction_state, slider, SW.SLIDER, slider_bounding_box, user_input_state.cursor, user_input_state.mouse_left, slider_value)
        slider_rectangle = convert(SD.Rectangle{Int}, slider_bounding_box)
        SD.draw!(image, slider_rectangle, text_color)
        SD.draw!(image, SD.FilledRectangle(slider_rectangle.position, slider_rectangle.height, slider_value), text_color)
        SD.draw!(image, SD.TextLine(slider_rectangle.position, "Slider", SD.TERMINUS_32_16), 0x00ffffff)

        text_input = SW.WidgetID(@__LINE__, @__FILE__)
        text_input_bounding_box = SW.BoundingBox(673, 1, 704, 200)
        SW.do_widget!(user_interaction_state, text_input, SW.TEXT_INPUT, text_input_bounding_box, user_input_state.cursor, user_input_state.mouse_left, text_line, user_input_state.characters)
        text_input_rectangle = convert(SD.Rectangle{Int}, text_input_bounding_box)
        SD.draw!(image, text_input_rectangle, text_color)
        SD.draw!(image, SD.TextLine(text_input_rectangle.position, text_line, SD.TERMINUS_32_16), text_color)

        empty!(lines)
        push!(lines, "Press the escape key to quit")
        push!(lines, "previous frame number: $(i)")
        push!(lines, "average total time spent per frame (averaged over previous $(length(time_stamp_buffer)) frames): $(round((last(time_stamp_buffer) - first(time_stamp_buffer)) / (1e6 * length(time_stamp_buffer)), digits = 2)) ms")
        push!(lines, "average compute time spent per frame (averaged over previous $(length(compute_time_buffer)) frames): $(round(sum(compute_time_buffer) / (1e6 * length(compute_time_buffer)), digits = 2)) ms")
        push!(lines, "cursor: $(user_input_state.cursor)")
        push!(lines, "key_up: $(user_input_state.key_up)")
        push!(lines, "key_down: $(user_input_state.key_down)")
        push!(lines, "key_left: $(user_input_state.key_left)")
        push!(lines, "key_right: $(user_input_state.key_right)")
        push!(lines, "mouse_left: $(user_input_state.mouse_left)")
        push!(lines, "mouse_right: $(user_input_state.mouse_right)")
        push!(lines, "mouse_middle: $(user_input_state.mouse_middle)")
        push!(lines, "hot_widget: $(user_interaction_state.hot_widget)")
        push!(lines, "active_widget: $(user_interaction_state.active_widget)")
        push!(lines, "button1_value: $(button1_value)")
        push!(lines, "button2_value: $(button2_value)")
        push!(lines, "slider_value: $(slider_value)")
        push!(lines, "text_input_value: $(String(text_line))")
        draw_lines!(image, lines, text_color)

        compute_time_end = time_ns()
        push!(compute_time_buffer, compute_time_end - compute_time_start)

        update_back_buffer(image)

        GLFW.SwapBuffers(window)

        reset!(user_input_state)

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
