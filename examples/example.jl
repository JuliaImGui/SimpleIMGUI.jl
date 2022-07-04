import ModernGL as MGL
import DataStructures as DS
import GLFW
import SimpleDraw as SD
import SimpleIMGUI as SI

include("opengl_utils.jl")

function update_button(button, action)
    if action == GLFW.PRESS
        return SI.press(button)
    elseif action == GLFW.RELEASE
        return SI.release(button)
    else
        return button
    end
end

function start()
    image_height = 720
    image_width = 1280
    window_name = "Example"

    sliding_window_size = 30
    font = SD.TERMINUS_32_16

    image = zeros(MGL.GLuint, image_height, image_width)

    SD.draw!(image, SD.Background(), SI.COLORS[Integer(SI.COLOR_BACKGROUND)])

    i = 0

    time_stamp_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(time_stamp_buffer, time_ns())

    compute_time_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(compute_time_buffer, zero(UInt))

    user_interaction_state = SI.UserInteractionState(SI.NULL_WIDGET_ID, SI.NULL_WIDGET_ID, SI.NULL_WIDGET_ID)

    user_input_state = SI.UserInputState(
                                      SD.Point(1, 1),
                                      SI.InputButton(false, 0),
                                      SI.InputButton(false, 0),
                                      SI.InputButton(false, 0),
                                      SI.InputButton(false, 0),
                                      SI.InputButton(false, 0),
                                      SI.InputButton(false, 0),
                                      SI.InputButton(false, 0),
                                      SI.InputButton(false, 0),
                                      Char[],
                                     )

    slider_value = 1
    text_box_value = collect("Text box")

    setup_window_hints()
    window = GLFW.CreateWindow(image_width, image_height, window_name)
    GLFW.MakeContextCurrent(window)

    function cursor_position_callback(window, x, y)::Cvoid
        user_input_state.cursor = SD.Point(round(Int, y, RoundDown) + 1, round(Int, x, RoundDown) + 1)

        return nothing
    end

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

    function character_callback(window, unicode_codepoint)::Cvoid
        push!(user_input_state.characters, Char(unicode_codepoint))

        return nothing
    end

    GLFW.SetCursorPosCallback(window, cursor_position_callback)
    GLFW.SetKeyCallback(window, key_callback)
    GLFW.SetMouseButtonCallback(window, mouse_button_callback)
    GLFW.SetCharCallback(window, character_callback)

    MGL.glViewport(0, 0, image_width, image_height)

    vertex_shader = setup_vertex_shader()
    fragment_shader = setup_fragment_shader()
    shader_program = setup_shader_program(vertex_shader, fragment_shader)

    VAO_ref, VBO_ref, EBO_ref = setup_vao_vbo_ebo()

    texture_ref = setup_texture(image)

    MGL.glUseProgram(shader_program)
    MGL.glBindVertexArray(VAO_ref[])

    clear_display()

    layout = SI.BoxLayout(SD.Rectangle(SD.Point(1, 1), 4, 4), 4)

    while !GLFW.WindowShouldClose(window)
        if SI.went_down(user_input_state.key_escape)
            GLFW.SetWindowShouldClose(window, true)
            break
        end

        layout.bounding_box = SD.Rectangle(SD.Point(1, 1), 4, 4)

        compute_time_start = time_ns()

        SD.draw!(image, SD.Background(), SI.COLORS[Integer(SI.COLOR_BACKGROUND)])

        button1_value = SI.do_widget!(
                                SI.BUTTON,
                                image,
                                user_interaction_state,
                                user_input_state,
                                SI.WidgetID(@__FILE__, @__LINE__, 1),
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                200,
                                SI.CENTER,
                                "Button 1",
                                font,
                                SI.COLORS,
                               )

        button2_value = SI.do_widget!(
                                SI.BUTTON,
                                image,
                                user_interaction_state,
                                user_input_state,
                                SI.WidgetID(@__FILE__, @__LINE__, 1),
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                200,
                                SI.CENTER,
                                "Button 2",
                                font,
                                SI.COLORS,
                               )

        slider_value = SI.do_widget!(
                                SI.SLIDER,
                                image,
                                user_interaction_state,
                                user_input_state,
                                SI.WidgetID(@__FILE__, @__LINE__, 1),
                                slider_value,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                200,
                                SI.CENTER,
                                "Slider",
                                font,
                                SI.COLORS,
                               )

        text_box_value = SI.do_widget!(
                                SI.TEXT_BOX,
                                image,
                                user_interaction_state,
                                user_input_state,
                                SI.WidgetID(@__FILE__, @__LINE__, 1),
                                text_box_value,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                200,
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "Press the escape key to quit"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "previous frame number: $(i)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "average total time spent per frame (averaged over previous $(length(time_stamp_buffer)) frames): $(round((last(time_stamp_buffer) - first(time_stamp_buffer)) / (1e6 * length(time_stamp_buffer)), digits = 2)) ms"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "average compute time spent per frame (averaged over previous $(length(compute_time_buffer)) frames): $(round(sum(compute_time_buffer) / (1e6 * length(compute_time_buffer)), digits = 2)) ms"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "cursor: $(user_input_state.cursor)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "mouse_left: $(user_input_state.mouse_left)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "mouse_right: $(user_input_state.mouse_right)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "mouse_middle: $(user_input_state.mouse_middle)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "hot_widget: $(user_interaction_state.hot_widget)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "active_widget: $(user_interaction_state.active_widget)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "button1_value: $(button1_value)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "button2_value: $(button2_value)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "slider_value: $(slider_value)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        text = "text_box_value: $(text_box_value)"
        _ = SI.do_widget!(
                                SI.TEXT,
                                image,
                                text,
                                layout,
                                SI.VERTICAL,
                                SD.get_height(font),
                                length(text) * SD.get_width(font),
                                SI.MIDDLE_LEFT,
                                font,
                                SI.COLORS,
                               )

        compute_time_end = time_ns()
        push!(compute_time_buffer, compute_time_end - compute_time_start)

        update_back_buffer(image)

        GLFW.SwapBuffers(window)

        SI.reset!(user_input_state)

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
