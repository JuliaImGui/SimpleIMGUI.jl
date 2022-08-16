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

    image = zeros(MGL.GLuint, image_height, image_width)

    setup_window_hints()
    window = GLFW.CreateWindow(image_width, image_height, window_name)
    GLFW.MakeContextCurrent(window)

    user_input_state = SI.UserInputState(
        SD.Point(1, 1),
        fill(SI.InputButton(false, 0), 512),
        fill(SI.InputButton(false, 0), 8),
        Char[],
    )

    function cursor_position_callback(window, x, y)::Cvoid
        user_input_state.cursor = SD.Point(round(Int, y, RoundDown) + 1, round(Int, x, RoundDown) + 1)

        return nothing
    end

    function key_callback(window, key, scancode, action, mods)::Cvoid
        if key == GLFW.KEY_UNKNOWN
            @error "Unknown key pressed"
        else
            if key == GLFW.KEY_BACKSPACE && (action == GLFW.PRESS || action == GLFW.REPEAT)
                push!(user_input_state.characters, '\b')
            end

            user_input_state.keyboard_buttons[Int(key) + 1] = update_button(user_input_state.keyboard_buttons[Int(key) + 1], action)
        end

        return nothing
    end

    function mouse_button_callback(window, button, action, mods)::Cvoid
        user_input_state.mouse_buttons[Int(button) + 1] = update_button(user_input_state.mouse_buttons[Int(button) + 1], action)

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

    user_interaction_state = SI.UserInteractionState(SI.NULL_WIDGET_ID, SI.NULL_WIDGET_ID, SI.NULL_WIDGET_ID)

    layout = SI.BoxLayout(SD.Rectangle(SD.Point(1, 1), image_height, image_width))
    debug_text = String[]
    show_debug_text = false
    slider_value = 0
    text_box_value = collect("Enter text")
    num_button_clicks = 0
    padding = 8
    font = SD.TERMINUS_32_16
    sliding_window_size = 30
    i = 0
    radio_button_value = 1
    drop_down_selected_item = 1
    drop_down_value = false

    time_stamp_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(time_stamp_buffer, time_ns())

    compute_time_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(compute_time_buffer, zero(UInt))

    while !GLFW.WindowShouldClose(window)
        if SI.went_down(user_input_state.keyboard_buttons[Int(GLFW.KEY_ESCAPE) + 1])
            GLFW.SetWindowShouldClose(window, true)
            break
        end

        layout.reference_bounding_box = SD.Rectangle(SD.Point(1, 1), image_height, image_width)
        empty!(debug_text)

        compute_time_start = time_ns()

        SD.draw!(image, SD.Background(), 0x00cccccc)

        text = "Press the escape key to quit"
        SI.do_widget!(
            SI.TEXT,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.UP_IN_LEFT_IN,
            padding,
            SD.get_height(font),
            SD.get_width(font) * SI.get_num_printable_characters(text),
            image,
            SI.UP_IN_LEFT_IN,
            -1,
            text,
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
        )

        SI.do_widget!(
            SI.TEXT,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.DOWN_OUT_LEFT_IN,
            padding,
            SD.get_height(font),
            SD.get_width(font) * 12,
            image,
            SI.UP_IN_LEFT_IN,
            -1,
            "Button",
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
        )
        reference_bounding_box = layout.reference_bounding_box

        button_value = SI.do_widget!(
            SI.BUTTON,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.RIGHT_OUT,
            padding,
            SD.get_height(font),
            240,
            image,
            SI.CENTER,
            -1,
            "$(num_button_clicks)",
            font,
            SI.ContextualColor(0x00b0b0b0, 0x00b7b7b7, 0x00bfbfbf),
            SI.ContextualColor(0x00000000, 0x00000000, 0x00000000),
            SI.ContextualColor(0x00000000, 0x00000000, 0x00000000),
        )
        if button_value
            num_button_clicks += 1
        end

        layout.reference_bounding_box = reference_bounding_box
        SI.do_widget!(
            SI.TEXT,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.DOWN_OUT_LEFT_IN,
            padding,
            SD.get_height(font),
            SD.get_width(font) * 12,
            image,
            SI.UP_IN_LEFT_IN,
            -1,
            "Slider",
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
        )
        reference_bounding_box = layout.reference_bounding_box

        slider_value = SI.do_widget!(
            SI.SLIDER,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            slider_value,
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.RIGHT_OUT,
            padding,
            SD.get_height(font),
            240,
            image,
            SI.CENTER,
            -1,
            "$(slider_value)",
            font,
            SI.ContextualColor(0x00b0b0b0, 0x00b7b7b7, 0x00bfbfbf),
            0x00000000,
            0x00000000,
            0x00909090,
        )

        layout.reference_bounding_box = reference_bounding_box
        SI.do_widget!(
            SI.TEXT,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.DOWN_OUT_LEFT_IN,
            padding,
            SD.get_height(font),
            SD.get_width(font) * 12,
            image,
            SI.UP_IN_LEFT_IN,
            -1,
            "TextBox",
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
        )
        reference_bounding_box = layout.reference_bounding_box

        text_box_value = SI.do_widget!(
            SI.TEXT_BOX,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            text_box_value,
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            user_input_state.characters,
            layout,
            SI.RIGHT_OUT,
            padding,
            SD.get_height(font),
            240,
            image,
            SI.LEFT_IN,
            -1,
            font,
            SI.ContextualColor(0x00b0b0b0, 0x00b7b7b7, 0x00bfbfbf),
            0x00000000,
            0x00000000,
        )

        push!(debug_text, "previous frame number: $(i)")
        push!(debug_text, "average total time spent per frame (averaged over previous $(length(time_stamp_buffer)) frames): $(round((last(time_stamp_buffer) - first(time_stamp_buffer)) / (1e6 * length(time_stamp_buffer)), digits = 2)) ms")
        push!(debug_text, "average compute time spent per frame (averaged over previous $(length(compute_time_buffer)) frames): $(round(sum(compute_time_buffer) / (1e6 * length(compute_time_buffer)), digits = 2)) ms")
        push!(debug_text, "cursor: $(user_input_state.cursor)")
        push!(debug_text, "mouse_left: $(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1])")
        push!(debug_text, "mouse_right: $(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_RIGHT) + 1])")
        push!(debug_text, "mouse_middle: $(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_MIDDLE) + 1])")
        push!(debug_text, "hot_widget: $(user_interaction_state.hot_widget)")
        push!(debug_text, "active_widget: $(user_interaction_state.active_widget)")

        layout.reference_bounding_box = reference_bounding_box
        SI.do_widget!(
            SI.TEXT,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.DOWN_OUT_LEFT_IN,
            padding,
            SD.get_height(font),
            SD.get_width(font) * 12,
            image,
            SI.UP_IN_LEFT_IN,
            -1,
            "RadioButton",
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
        )
        reference_bounding_box = layout.reference_bounding_box

        radio_button_item_list = ("item a", "item b", "item c")
        max_num_chars = length(first(radio_button_item_list))
        for item in radio_button_item_list
            max_num_chars = max(max_num_chars, length(item))
        end
        for (j, item) in enumerate(radio_button_item_list)
            if SI.do_widget!(
                SI.RADIO_BUTTON,
                user_interaction_state,
                SI.WidgetID(@__FILE__, @__LINE__, j),
                radio_button_value == j,
                user_input_state.cursor,
                user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
                layout,
                SI.RIGHT_OUT,
                padding,
                SD.get_height(font),
                SD.get_width(font) * (max_num_chars + 2),
                image,
                SI.LEFT_IN,
                -1,
                item,
                font,
                0x00cccccc,
                0x00cccccc,
                0x00000000,
                0x00000000,
            )
                radio_button_value = j
            end
            reference_bounding_box = SI.get_enclosing_bounding_box(reference_bounding_box, layout.reference_bounding_box)
        end

        layout.reference_bounding_box = reference_bounding_box
        SI.do_widget!(
            SI.TEXT,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.DOWN_OUT_LEFT_IN,
            padding,
            SD.get_height(font),
            SD.get_width(font) * 12,
            image,
            SI.UP_IN_LEFT_IN,
            -1,
            "DropDown",
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
        )
        reference_bounding_box = layout.reference_bounding_box

        drop_down_item_list = ("item 1", "item 2", "item 3")
        max_num_chars = length(first(drop_down_item_list))
        for item in drop_down_item_list
            max_num_chars = max(max_num_chars, length(item))
        end
        drop_down_value = SI.do_widget!(
            SI.DROP_DOWN,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            drop_down_value,
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.RIGHT_OUT,
            padding,
            SD.get_height(font),
            SD.get_width(font) * (max_num_chars + 2),
            image,
            SI.LEFT_IN,
            -1,
            drop_down_item_list[drop_down_selected_item],
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
            0x00000000,
        )
        reference_bounding_box = SI.get_enclosing_bounding_box(reference_bounding_box, layout.reference_bounding_box)

        if drop_down_value
            for (j, item) in enumerate(drop_down_item_list)
                if SI.do_widget!(
                    SI.RADIO_BUTTON,
                    user_interaction_state,
                    SI.WidgetID(@__FILE__, @__LINE__, j),
                    drop_down_selected_item == j,
                    user_input_state.cursor,
                    user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
                    layout,
                    SI.DOWN_OUT_LEFT_IN,
                    padding,
                    SD.get_height(font),
                    SD.get_width(font) * (max_num_chars + 2),
                    image,
                    SI.LEFT_IN,
                    -1,
                    item,
                    font,
                    0x00cccccc,
                    0x00cccccc,
                    0x00000000,
                    0x00000000,
                )
                    drop_down_selected_item = j
                end
                reference_bounding_box = SI.get_enclosing_bounding_box(reference_bounding_box, layout.reference_bounding_box)
            end
        end

        layout.reference_bounding_box = reference_bounding_box
        SI.do_widget!(
            SI.TEXT,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.DOWN_OUT_LEFT_IN,
            padding,
            SD.get_height(font),
            SD.get_width(font) * 12,
            image,
            SI.UP_IN_LEFT_IN,
            -1,
            "CheckBox",
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
        )
        reference_bounding_box = layout.reference_bounding_box

        text = "Show debug text"
        show_debug_text = SI.do_widget!(
            SI.CHECK_BOX,
            user_interaction_state,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            show_debug_text,
            user_input_state.cursor,
            user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
            layout,
            SI.RIGHT_OUT,
            padding,
            SD.get_height(font),
            SD.get_width(font) * (SI.get_num_printable_characters(text) + 2),
            image,
            SI.LEFT_IN,
            -1,
            text,
            font,
            0x00cccccc,
            0x00cccccc,
            0x00000000,
            0x00000000,
        )

        if show_debug_text
            layout.reference_bounding_box = reference_bounding_box
            for (j, text) in enumerate(debug_text)
                SI.do_widget!(
                    SI.TEXT,
                    user_interaction_state,
                    SI.WidgetID(@__FILE__, @__LINE__, j),
                    user_input_state.cursor,
                    user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1],
                    layout,
                    SI.DOWN_OUT_LEFT_IN,
                    padding,
                    SD.get_height(font),
                    SD.get_width(font) * SI.get_num_printable_characters(text),
                    image,
                    SI.UP_IN_LEFT_IN,
                    -1,
                    text,
                    font,
                    0x00cccccc,
                    0x00cccccc,
                    0x00000000,
                   )
            end
        end

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
