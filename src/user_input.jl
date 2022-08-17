"""
    struct InputButton{I}
        ended_down::Bool
        num_transitions::I
    end

Store the last state and number of transitions per frame for a switch-like input device. This can be used to keep track of input events corresponding to keyboard keys and mouse buttons.
"""
struct InputButton{I}
    ended_down::Bool
    num_transitions::I
end

abstract type AbstractUserInputState end

"""
    mutable struct UserInputState{I1, I2} <: AbstractUserInputState
        cursor::SD.Point{I1}
        keyboard_buttons::Vector{InputButton{I2}}
        mouse_buttons::Vector{InputButton{I2}}
        characters::Vector{Char}
    end

Keep track of input events in a frame.
"""
mutable struct UserInputState{I, T, C} <: AbstractUserInputState
    cursor::SD.Point{I}
    keyboard_buttons::Vector{T}
    mouse_buttons::Vector{T}
    characters::Vector{C}
end

"""
    went_down(ended_down, num_transitions)

Works similar to went_down(input_button), just that the arguments are not bundled together.

See also [`went_up`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.went_down(true, 1)
true
```
"""
went_down(ended_down, num_transitions) = (num_transitions >= 2) || (isone(num_transitions) && ended_down)

"""
    went_up(ended_down, num_transitions)

Works similar to went_up(input_button), just that the arguments are not bundled together.

See also [`went_down`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.went_up(false, 1)
true
```
"""
went_up(ended_down, num_transitions) = (num_transitions >= 2) || (isone(num_transitions) && !ended_down)

"""
    went_down(input_button)

Return whether a switch like input device (like a keyboard/mouse button) went down (was pressed at least once) within a frame.

See also [`went_up`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.went_down(SimpleIMGUI.InputButton(true, 0))
false

julia> SimpleIMGUI.went_down(SimpleIMGUI.InputButton(true, 1))
true

julia> SimpleIMGUI.went_down(SimpleIMGUI.InputButton(true, 2))
true

julia> SimpleIMGUI.went_down(SimpleIMGUI.InputButton(false, 0))
false

julia> SimpleIMGUI.went_down(SimpleIMGUI.InputButton(false, 1))
false

julia> SimpleIMGUI.went_down(SimpleIMGUI.InputButton(false, 2))
true
```
"""
went_down(input_button) = went_down(input_button.ended_down, input_button.num_transitions)

"""
    went_up(input_button)

Return whether a switch like input device (like a keyboard/mouse button) went up (was released at least once) within a frame.

See also [`went_down`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.went_up(SimpleIMGUI.InputButton(true, 0))
false

julia> SimpleIMGUI.went_up(SimpleIMGUI.InputButton(true, 1))
false

julia> SimpleIMGUI.went_up(SimpleIMGUI.InputButton(true, 2))
true

julia> SimpleIMGUI.went_up(SimpleIMGUI.InputButton(false, 0))
false

julia> SimpleIMGUI.went_up(SimpleIMGUI.InputButton(false, 1))
true

julia> SimpleIMGUI.went_up(SimpleIMGUI.InputButton(false, 2))
true
```
"""
went_up(input_button) = went_up(input_button.ended_down, input_button.num_transitions)

"""
    press(ended_down, num_transitions)

Works similar to press(input_button), just that the arguments are not bundled together.

See also [`release`](@ref), [`reset`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.press(false, 0)
(true, 1)
```
"""
press(ended_down, num_transitions) = (true, num_transitions + one(num_transitions))

"""
    release(ended_down, num_transitions)

Works similar to release(input_button), just that the arguments are not bundled together.

See also [`press`](@ref), [`reset`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.release(true, 0)
(false, 1)
```
"""
release(ended_down, num_transitions) = (false, num_transitions + one(num_transitions))

"""
    reset(ended_down, num_transitions)

Works similar to reset(input_button), just that the arguments are not bundled together.

See also [`press`](@ref), [`release`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.reset(true, 1)
(true, 0)

julia> SimpleIMGUI.reset(false, 2)
(true, 0)
```
"""
reset(ended_down, num_transitions) = (ended_down, zero(num_transitions))

"""
    press(input_button)

Return updated value of `input_button` when the switch like input device is pressed once.

See also [`release`](@ref), [`reset`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.press(SimpleIMGUI.InputButton(false, 0))
SimpleIMGUI.InputButton{Int64}(true, 1)

julia> SimpleIMGUI.press(SimpleIMGUI.InputButton(false, 1))
SimpleIMGUI.InputButton{Int64}(true, 2)

julia> SimpleIMGUI.press(SimpleIMGUI.InputButton(false, 2))
SimpleIMGUI.InputButton{Int64}(true, 3)
```
"""
press(input_button) = typeof(input_button)(press(input_button.ended_down, input_button.num_transitions)...)

"""
    release(input_button)

Return updated value of `input_button` when the switch like input device is released once.

See also [`press`](@ref), [`reset`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.release(SimpleIMGUI.InputButton(true, 0))
SimpleIMGUI.InputButton{Int64}(false, 1)

julia> SimpleIMGUI.release(SimpleIMGUI.InputButton(true, 1))
SimpleIMGUI.InputButton{Int64}(false, 2)

julia> SimpleIMGUI.release(SimpleIMGUI.InputButton(true, 2))
SimpleIMGUI.InputButton{Int64}(false, 3)
```
"""
release(input_button) = typeof(input_button)(release(input_button.ended_down, input_button.num_transitions)...)

"""
    reset(input_button)

Return updated value of `input_button` when the switch like input device is reset at the beginning of a frame.

See also [`press`](@ref), [`release`](@ref).

# Examples
```julia-repl
julia> SimpleIMGUI.reset(SimpleIMGUI.InputButton(true, 0))
SimpleIMGUI.InputButton{Int64}(true, 0)

julia> SimpleIMGUI.reset(SimpleIMGUI.InputButton(true, 1))
SimpleIMGUI.InputButton{Int64}(true, 0)

julia> SimpleIMGUI.reset(SimpleIMGUI.InputButton(true, 2))
SimpleIMGUI.InputButton{Int64}(true, 0)

julia> SimpleIMGUI.reset(SimpleIMGUI.InputButton(false, 0))
SimpleIMGUI.InputButton{Int64}(true, 0)

julia> SimpleIMGUI.reset(SimpleIMGUI.InputButton(false, 1))
SimpleIMGUI.InputButton{Int64}(true, 0)

julia> SimpleIMGUI.reset(SimpleIMGUI.InputButton(false, 2))
SimpleIMGUI.InputButton{Int64}(true, 0)
```
"""
reset(input_button) = typeof(input_button)(reset(input_button.ended_down, input_button.num_transitions)...)

"""
    reset!(user_input_state)

Reset the input events tracked by `user_input_state` at the beginning of a frame.
```
"""
function reset!(user_input_state)
    for (i, input_button) in enumerate(user_input_state.keyboard_buttons)
        user_input_state.keyboard_buttons[i] = reset(input_button)
    end

    for (i, input_button) in enumerate(user_input_state.mouse_buttons)
        user_input_state.mouse_buttons[i] = reset(input_button)
    end

    empty!(user_input_state.characters)

    return nothing
end
