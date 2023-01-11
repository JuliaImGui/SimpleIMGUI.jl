# SimpleIMGUI

Simple Immediate-Mode Graphical User Interface (IMGUI) library in Julia.

# Getting Started

To test an example, first clone the repository and then execute the following command inside the root directory of the cloned repository:

```
julia --project=examples -e 'import Pkg; Pkg.develop(path="."); Pkg.instantiate(); include("examples/example.jl")'
```

This will open a window and you can interact with the widgets present in it. Here is an example (note that the screenshot might not be up to date with `examples/example.jl`):

<img src="https://user-images.githubusercontent.com/32610387/211885253-152ae598-f920-4448-bcc6-90bd4002d8ae.png">
