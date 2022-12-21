"""
Package for working with hexagonal grids.
"""
module HexGrids

export HexIndex, AxialIndex, CubeIndex, neighbors


const root32 = sqrt(3) / 2

include("util.jl")
include("indices.jl")
include("shape.jl")
include("array.jl")


end # module HexGrids
