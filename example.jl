import ModernGL as MGL
import GLFW

function process_input(window)
    if GLFW.GetKey(window, GLFW.KEY_Q)
        GLFW.SetWindowShouldClose(window, true)
    end

    return nothing
end

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 3)
GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)

height_image = 600
width_image = 800
window_name = "Example"

window = GLFW.CreateWindow(width_image, height_image, window_name)

GLFW.MakeContextCurrent(window)

renderer = unsafe_string(MGL.glGetString(MGL.GL_RENDERER))
version = unsafe_string(MGL.glGetString(MGL.GL_VERSION))
@info "Renderer: $(renderer)"
@info "OpenGL version: $(version)"

MGL.glViewport(0, 0, width_image, height_image)

# vertex shader
vertex_shader_source =
"#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    TexCoord = vec2(aTexCoord.x, aTexCoord.y);
}"
vertex_shader = MGL.glCreateShader(MGL.GL_VERTEX_SHADER)
MGL.glShaderSource(vertex_shader, 1, Ptr{MGL.GLchar}[pointer(vertex_shader_source)], C_NULL)
MGL.glCompileShader(vertex_shader)
vertex_shader_success_ref = Ref{MGL.GLint}(0)
MGL.glGetShaderiv(vertex_shader, MGL.GL_COMPILE_STATUS, vertex_shader_success_ref)
@show vertex_shader_success_ref[]

# fragment shader
fragment_shader_source =
"#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D texture1;

void main()
{
    FragColor = texture(texture1, TexCoord);
}"
fragment_shader = MGL.glCreateShader(MGL.GL_FRAGMENT_SHADER)
MGL.glShaderSource(fragment_shader, 1, Ptr{MGL.GLchar}[pointer(fragment_shader_source)], C_NULL)
MGL.glCompileShader(fragment_shader)
fragment_shader_success_ref = Ref{MGL.GLint}(0)
MGL.glGetShaderiv(fragment_shader, MGL.GL_COMPILE_STATUS, fragment_shader_success_ref)
@show fragment_shader_success_ref[]

# shader program
fragment_shader_source =
shader_program = MGL.glCreateProgram()
MGL.glAttachShader(shader_program, vertex_shader)
MGL.glAttachShader(shader_program, fragment_shader)
MGL.glLinkProgram(shader_program)
shader_program_success_ref = Ref{MGL.GLint}(0)
MGL.glGetProgramiv(shader_program, MGL.GL_LINK_STATUS, shader_program_success_ref)
@show shader_program_success_ref[]
MGL.glDeleteShader(vertex_shader)
MGL.glDeleteShader(fragment_shader)

vertices = MGL.GLfloat[
 1.0f0,  1.0f0, 0.0f0, 1.0f0, 1.0f0,  # top right
 1.0f0, -1.0f0, 0.0f0, 1.0f0, 0.0f0,  # bottom right
-1.0f0, -1.0f0, 0.0f0, 0.0f0, 0.0f0,  # bottom left
-1.0f0,  1.0f0, 0.0f0, 0.0f0, 1.0f0,  # top left
]
indices = MGL.GLuint[
0, 1, 3,  # first Triangle
1, 2, 3   # second Triangle
]

VAO_ref = Ref{MGL.GLuint}(0)
MGL.glGenVertexArrays(1, VAO_ref)
@show VAO_ref[]

VBO_ref = Ref{MGL.GLuint}(0)
MGL.glGenBuffers(1, VBO_ref)
@show VBO_ref[]

EBO_ref = Ref{MGL.GLuint}(0)
MGL.glGenBuffers(1, EBO_ref)
@show EBO_ref[]

MGL.glBindVertexArray(VAO_ref[])

MGL.glBindBuffer(MGL.GL_ARRAY_BUFFER, VBO_ref[])
MGL.glBufferData(MGL.GL_ARRAY_BUFFER, sizeof(vertices), vertices, MGL.GL_STATIC_DRAW)

MGL.glBindBuffer(MGL.GL_ELEMENT_ARRAY_BUFFER, EBO_ref[])
MGL.glBufferData(MGL.GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, MGL.GL_STATIC_DRAW)

MGL.glVertexAttribPointer(0, 3, MGL.GL_FLOAT, MGL.GL_FALSE, 5 * sizeof(MGL.GLfloat), Ptr{Cvoid}(0))
MGL.glEnableVertexAttribArray(0)

MGL.glVertexAttribPointer(1, 2, MGL.GL_FLOAT, MGL.GL_FALSE, 5 * sizeof(MGL.GLfloat), Ptr{Cvoid}(3 * sizeof(MGL.GLfloat)))
MGL.glEnableVertexAttribArray(1)

MGL.glBindBuffer(MGL.GL_ARRAY_BUFFER, 0)

MGL.glBindVertexArray(0)

texture_ref = Ref{MGL.GLuint}(0)
MGL.glGenTextures(1, texture_ref)
@show texture_ref[]
MGL.glActiveTexture(MGL.GL_TEXTURE0)
MGL.glBindTexture(MGL.GL_TEXTURE_2D, texture_ref[])

MGL.glTexParameteri(MGL.GL_TEXTURE_2D, MGL.GL_TEXTURE_WRAP_S, MGL.GL_REPEAT)
MGL.glTexParameteri(MGL.GL_TEXTURE_2D, MGL.GL_TEXTURE_WRAP_T, MGL.GL_REPEAT)

MGL.glTexParameteri(MGL.GL_TEXTURE_2D, MGL.GL_TEXTURE_MIN_FILTER, MGL.GL_NEAREST)
MGL.glTexParameteri(MGL.GL_TEXTURE_2D, MGL.GL_TEXTURE_MAG_FILTER, MGL.GL_NEAREST)

width_texture = 10
height_texture = 10
channels_texture = 3
data = rand(MGL.GLchar, width_texture * height_texture * channels_texture)
MGL.glTexImage2D(MGL.GL_TEXTURE_2D, 0, MGL.GL_RGB, width_texture, height_texture, 0, MGL.GL_RGB, MGL.GL_UNSIGNED_BYTE, data)

while !GLFW.WindowShouldClose(window)
    process_input(window)

    MGL.glClearColor(0.5f0, 0.5f0, 0.5f0, 1.0f0)
    MGL.glClear(MGL.GL_COLOR_BUFFER_BIT)

    MGL.glActiveTexture(MGL.GL_TEXTURE0)
    MGL.glBindTexture(MGL.GL_TEXTURE_2D, texture_ref[])
    data = rand(MGL.GLchar, width_texture * height_texture * channels_texture)
    MGL.glTexSubImage2D(MGL.GL_TEXTURE_2D, 0, MGL.GLint(0), MGL.GLint(0), MGL.GLsizei(width_texture), MGL.GLsizei(height_texture), MGL.GL_RGB, MGL.GL_UNSIGNED_BYTE, data)

    MGL.glUseProgram(shader_program)

    MGL.glBindVertexArray(VAO_ref[])
    MGL.glDrawElements(MGL.GL_TRIANGLES, 6, MGL.GL_UNSIGNED_INT, Ptr{Cvoid}(0))

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
end

MGL.glDeleteVertexArrays(1, VAO_ref)
MGL.glDeleteBuffers(1, VBO_ref)
MGL.glDeleteBuffers(1, EBO_ref)
MGL.glDeleteProgram(shader_program)

GLFW.DestroyWindow(window)
