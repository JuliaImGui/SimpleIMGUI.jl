import ModernGL as MGL
import DataStructures as DS
import GLFW
import SimpleDraw as SD
import SimpleIMGUI as SI
import FileIO
import ImageIO
import ColorTypes

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
    primary_monitor = GLFW.GetPrimaryMonitor()
    video_mode = GLFW.GetVideoMode(primary_monitor)
    image_height = Int(video_mode.height)
    image_width = Int(video_mode.width)
    window_name = "Example"

    image = zeros(MGL.GLuint, image_height, image_width)

    setup_window_hints()
    window = GLFW.CreateWindow(image_width, image_height, window_name, primary_monitor)
    GLFW.MakeContextCurrent(window)

    user_input_state = SI.UserInputState(
        SI.Cursor(SD.Point(1, 1)),
        fill(SI.InputButton(false, 0), 512),
        fill(SI.InputButton(false, 0), 8),
        Char[],
    )

    function cursor_position_callback(window, x, y)::Cvoid
        user_input_state.cursor.position = SD.Point(round(Int, y, RoundDown) + 1, round(Int, x, RoundDown) + 1)

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

    user_interaction_state = SI.UserInteractionState(SI.NULL_WIDGET, SI.NULL_WIDGET, SI.NULL_WIDGET)

    layout = SI.BoxLayout(SD.Rectangle(SD.Point(1, 1), image_height, image_width))

    font = SD.TERMINUS_BOLD_24_12
    font_height = SD.get_height(font)
    font_width = SD.get_width(font)

    widget_gap = font_width ÷ 2

    # widget: button
    button_num_clicks = 0

    # widget: slider
    slider_height = font_height
    slider_width = 20 * font_width
    slider_value = (0, 0, font_height ÷ 2, 4 * font_width, 0, 0, slider_height, slider_width)

    # widget: image
    sample_image = map(x -> convert(ColorTypes.RGB24, x).color, FileIO.load("mandrill.png"))
    sample_image_height, sample_image_width = size(sample_image)
    image_widget_height = 5 * font_height
    image_widget_width = 20 * font_width
    image_widget_horizontal_slider_height = font_height
    image_widget_horizontal_slider_width = image_widget_width
    image_widget_horizontal_slider_bar_width = SI.get_bar_length(8, image_widget_width, image_widget_width, sample_image_width)
    image_widget_horizontal_slider_value = (0, 0, image_widget_horizontal_slider_height, image_widget_horizontal_slider_bar_width, 0, 0, image_widget_horizontal_slider_height, image_widget_horizontal_slider_width)
    image_widget_drawable = SD.Image(SD.move(SD.Point(1, 1), -image_widget_horizontal_slider_value[1], -image_widget_horizontal_slider_value[2]), sample_image)

    # widget: text_box
    text_box_value = collect("Enter text")

    # widget: radio_button
    radio_button_value = 1

    # widget: drop_down
    drop_down_selected_item = 1
    drop_down_value = false

    # widget: check_box
    check_box_value = false
    debug_text_list = String[]

    ui_context = SI.UIContext(user_interaction_state, user_input_state, layout, image)

    i = 0

    sliding_window_size = 30

    frame_time_stamp_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(frame_time_stamp_buffer, time_ns())

    frame_compute_time_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(frame_compute_time_buffer, zero(UInt))

    while !GLFW.WindowShouldClose(window)
        if SI.went_down(user_input_state.keyboard_buttons[Int(GLFW.KEY_ESCAPE) + 1])
            GLFW.SetWindowShouldClose(window, true)
            break
        end

        layout.reference_bounding_box = SD.Rectangle(SD.Point(1, 1), image_height, image_width)
        empty!(debug_text_list)

        compute_time_start = time_ns()

        SD.draw!(image, SD.Background(), 0x00cccccc)

        text = "Press the escape key to quit"
        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            text;
            alignment = SI.UP1_LEFT1,
        )

        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "Button";
            widget_width = 12 * font_width,
        )
        temp_bounding_box = layout.reference_bounding_box

        button_value = SI.do_widget!(
            SI.BUTTON,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "$(button_num_clicks)";
            alignment = SI.UP1_RIGHT2,
            widget_width = 20 * font_width,
        )
        if button_value
            button_num_clicks += 1
        end

        layout.reference_bounding_box = temp_bounding_box
        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "Slider";
            widget_width = 12 * font_width,
        )
        temp_bounding_box = layout.reference_bounding_box

        slider_value = SI.do_widget!(
            SI.SLIDER,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            slider_value;
            alignment = SI.UP1_RIGHT2,
            widget_height = slider_height,
            widget_width = slider_width,
        )

        layout.reference_bounding_box = temp_bounding_box
        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "TextBox";
            widget_width = 12 * font_width,
        )
        temp_bounding_box = layout.reference_bounding_box

        SI.do_widget!(
            SI.TEXT_BOX,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            text_box_value;
            alignment = SI.UP1_RIGHT2,
            widget_width = 20 * font_width,
        )

        layout.reference_bounding_box = temp_bounding_box
        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "Image";
            widget_width = 12 * font_width,
        )
        temp_bounding_box = layout.reference_bounding_box

        SI.do_widget!(
            SI.IMAGE,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            SI.UP1_RIGHT2,
            widget_gap,
            image_widget_height,
            image_widget_width,
            image_widget_drawable,
        )
        temp_bounding_box = SI.get_enclosing_bounding_box(temp_bounding_box, layout.reference_bounding_box)

        image_widget_horizontal_slider_value = SI.do_widget!(
            SI.SLIDER,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            image_widget_horizontal_slider_value;
            widget_width = 20 * font_width,
        )
        image_widget_j_scroll = SI.get_scroll_value(image_widget_horizontal_slider_value[2], image_widget_horizontal_slider_value[4], image_widget_horizontal_slider_value[8], image_widget_width, SD.get_width(image_widget_drawable))
        image_widget_drawable = SD.Image(SD.move(SD.Point(1, 1), 0, -image_widget_j_scroll), image_widget_drawable.image)
        temp_bounding_box = SI.get_enclosing_bounding_box(temp_bounding_box, layout.reference_bounding_box)

        layout.reference_bounding_box = temp_bounding_box
        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "RadioButton";
            widget_width = 12 * font_width,
        )
        temp_bounding_box = layout.reference_bounding_box

        radio_button_item_list = ("item a", "item b", "item c")
        max_num_chars = length(first(radio_button_item_list))
        for item in radio_button_item_list
            max_num_chars = max(max_num_chars, length(item))
        end
        for (j, item) in enumerate(radio_button_item_list)
            if SI.do_widget!(
                SI.RADIO_BUTTON,
                ui_context,
                SI.WidgetID(@__FILE__, @__LINE__, j),
                radio_button_value == j,
                "$(item)";
                alignment = SI.UP1_RIGHT2,
                widget_width = (max_num_chars + 2) * font_width,
            )
                radio_button_value = j
            end
            temp_bounding_box = SI.get_enclosing_bounding_box(temp_bounding_box, layout.reference_bounding_box)
        end

        layout.reference_bounding_box = temp_bounding_box
        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "DropDown";
            widget_width = 12 * font_width,
        )
        temp_bounding_box = layout.reference_bounding_box

        drop_down_item_list = ("item 1", "item 2", "item 3")
        max_num_chars = length(first(drop_down_item_list))
        for item in drop_down_item_list
            max_num_chars = max(max_num_chars, length(item))
        end
        drop_down_value = SI.do_widget!(
            SI.DROP_DOWN,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            drop_down_value,
            drop_down_item_list[drop_down_selected_item];
            alignment = SI.UP1_RIGHT2,
            widget_width = (max_num_chars + 2) * font_width,
        )
        temp_bounding_box = SI.get_enclosing_bounding_box(temp_bounding_box, layout.reference_bounding_box)

        if drop_down_value
            for (j, item) in enumerate(drop_down_item_list)
                if SI.do_widget!(
                    SI.RADIO_BUTTON,
                    ui_context,
                    SI.WidgetID(@__FILE__, @__LINE__, j),
                    drop_down_selected_item == j,
                    "$(item)";
                    padding = 0,
                    widget_width = (max_num_chars + 2) * font_width,
                )
                    drop_down_selected_item = j
                end
                temp_bounding_box = SI.get_enclosing_bounding_box(temp_bounding_box, layout.reference_bounding_box)
            end
        end

        layout.reference_bounding_box = temp_bounding_box
        SI.do_widget!(
            SI.TEXT,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            "CheckBox";
            widget_width = 12 * font_width,
        )
        temp_bounding_box = layout.reference_bounding_box
        push!(debug_text_list, "previous frame number: $(i)")
        push!(debug_text_list, "average total time spent per frame (averaged over previous $(length(frame_time_stamp_buffer)) frames): $(round((last(frame_time_stamp_buffer) - first(frame_time_stamp_buffer)) / (1e6 * length(frame_time_stamp_buffer)), digits = 2)) ms")
        push!(debug_text_list, "average compute time spent per frame (averaged over previous $(length(frame_compute_time_buffer)) frames): $(round(sum(frame_compute_time_buffer) / (1e6 * length(frame_compute_time_buffer)), digits = 2)) ms")
        push!(debug_text_list, "Monitor video mode: $(GLFW.GetVideoMode(GLFW.GetWindowMonitor(window)))")
        push!(debug_text_list, "cursor: $(user_input_state.cursor)")
        push!(debug_text_list, "mouse_left: $(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1])")
        push!(debug_text_list, "count_went_down(mouse_left): $(SI.count_went_down(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1]))")
        push!(debug_text_list, "count_went_up(mouse_left): $(SI.count_went_up(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_LEFT) + 1]))")
        push!(debug_text_list, "mouse_right: $(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_RIGHT) + 1])")
        push!(debug_text_list, "mouse_middle: $(user_input_state.mouse_buttons[Int(GLFW.MOUSE_BUTTON_MIDDLE) + 1])")
        push!(debug_text_list, "hot_widget: $(user_interaction_state.hot_widget)")
        push!(debug_text_list, "active_widget: $(user_interaction_state.active_widget)")

        text = "Show debug text"
        check_box_value = SI.do_widget!(
            SI.CHECK_BOX,
            ui_context,
            SI.WidgetID(@__FILE__, @__LINE__, 1),
            check_box_value,
            text;
            alignment = SI.UP1_RIGHT2,
        )

        if check_box_value
            layout.reference_bounding_box = temp_bounding_box
            for (j, text) in enumerate(debug_text_list)
                SI.do_widget!(
                    SI.TEXT,
                    ui_context,
                    SI.WidgetID(@__FILE__, @__LINE__, j),
                    text;
                )
            end
        end

        compute_time_end = time_ns()
        push!(frame_compute_time_buffer, compute_time_end - compute_time_start)

        update_back_buffer(image)

        GLFW.SwapBuffers(window)

        SI.reset!(user_input_state)

        GLFW.PollEvents()

        i = i + 1

        push!(frame_time_stamp_buffer, time_ns())
    end

    MGL.glDeleteVertexArrays(1, VAO_ref)
    MGL.glDeleteBuffers(1, VBO_ref)
    MGL.glDeleteBuffers(1, EBO_ref)
    MGL.glDeleteProgram(shader_program)

    GLFW.DestroyWindow(window)

    return nothing
end

start()
