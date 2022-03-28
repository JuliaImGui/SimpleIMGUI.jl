import ModernGL as MGL
import DataStructures as DS
import GLFW
import SimpleDraw as SD

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

    setup_window_hints()

    window = GLFW.CreateWindow(width_image, height_image, window_name)
    GLFW.MakeContextCurrent(window)
    MGL.glViewport(0, 0, width_image, height_image)

    @info "Renderer: $(unsafe_string(MGL.glGetString(MGL.GL_RENDERER)))"
    @info "OpenGL version: $(unsafe_string(MGL.glGetString(MGL.GL_VERSION)))"

    vertex_shader = setup_vertex_shader()
    fragment_shader = setup_fragment_shader()
    shader_program = setup_shader_program(vertex_shader, fragment_shader)

    VAO_ref, VBO_ref, EBO_ref = setup_vao_vbo_ebo()

    texture_ref = setup_texture(image)

    MGL.glUseProgram(shader_program)
    MGL.glBindVertexArray(VAO_ref[])

    clear_display()

    key_up = Button(false, 0)
    key_down = Button(false, 0)
    key_left = Button(false, 0)
    key_right = Button(false, 0)

    function key_callback(window, key, scancode, action, mods)::Cvoid
        if key == GLFW.KEY_Q && action == GLFW.PRESS
            GLFW.SetWindowShouldClose(window, true)
        elseif key == GLFW.KEY_UP
            update_button!(key_up, action)
        elseif key == GLFW.KEY_DOWN
            update_button!(key_down, action)
        elseif key == GLFW.KEY_LEFT
            update_button!(key_left, action)
        elseif key == GLFW.KEY_RIGHT
            update_button!(key_right, action)
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

    i = 0

    time_stamp_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(time_stamp_buffer, time_ns())

    drawing_time_buffer = DS.CircularBuffer{typeof(time_ns())}(sliding_window_size)
    push!(drawing_time_buffer, zero(UInt))

    while !GLFW.WindowShouldClose(window)
        empty!(lines)
        push!(lines, "previous frame number: $(i)")
        push!(lines, "average time spent per frame (averaged over previous $(length(time_stamp_buffer)) frames): $(round((last(time_stamp_buffer) - first(time_stamp_buffer)) / (1e6 * length(time_stamp_buffer)), digits = 2)) ms")
        push!(lines, "average drawing time spent per frame (averaged over previous $(length(drawing_time_buffer)) frames): $(round(sum(drawing_time_buffer) / (1e6 * length(drawing_time_buffer)), digits = 2)) ms")
        push!(lines, "key_up: $(key_up)")
        push!(lines, "key_down: $(key_down)")
        push!(lines, "key_left: $(key_left)")
        push!(lines, "key_right: $(key_right)")
        push!(lines, "mouse_left: $(mouse_left)")
        push!(lines, "mouse_right: $(mouse_right)")
        push!(lines, "mouse_middle: $(mouse_middle)")

        drawing_time_start = time_ns()
        SD.draw!(image, SD.Background(), background_color)
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
