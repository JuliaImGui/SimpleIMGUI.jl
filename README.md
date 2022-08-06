# SimpleIMGUI

Simple Immediate-Mode Graphical User Interface (IMGUI) library in Julia.

# Getting Started

To test an example, first clone the repository and then execute the following command inside the root directory of the cloned repository:

```
julia --project=examples -e 'import Pkg; Pkg.develop(path="."); Pkg.instantiate(); include("examples/example.jl")'
```

This will open a window and you can interact with the widgets present in it. Here is an example (note that the screenshot might not be up to date with `examples/example.jl`):

<img src="https://user-images.githubusercontent.com/32610387/181818018-d6a466f6-e52c-4a37-8545-39b64427a6cb.png">
