# SimpleIMGUI

Simple Immediate-Mode Graphical User Interface (IMGUI) library in Julia.

# Getting Started

To test an example, first clone the repository and then execute the following command inside the root directory of the cloned repository:

```
julia --project=examples -e 'import Pkg; Pkg.develop(path="."); Pkg.instantiate(); include("examples/example.jl")'
```

This will open a window and you can interact with the widgets present in it. Here is an example (note that the screenshot might not be up to date with `examples/example.jl`):

<img src="https://user-images.githubusercontent.com/32610387/211919302-a3b08e41-4966-4bcb-985d-5d7c82323571.png">
