# Example Usage

To test an example, first clone the repository and rename it to `SimpleWidgets.jl` (if it is not already named `SimpleWidgets.jl`, which will happen soon).

Then execute the following command inside the `examples` directory of the cloned repository:

```
julia --project=. -e 'import Pkg; Pkg.develop(path="../../SimpleWidgets.jl"); Pkg.instantiate(); include("example.jl")'
```

This will open a window and you can interact with the widgets present in it.

<img src="https://user-images.githubusercontent.com/32610387/165582174-fd98dd3a-d36c-4418-a673-719090b0cd54.png">
