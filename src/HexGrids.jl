"""
Package for working with hexagonal grids.
"""
module HexGrids

using LinearAlgebra
using StaticArrays

export HexIndex, AxialIndex, CubeIndex
export validindex, isneighbor, neighbors, hexdist, hexaxes
export HexShape, HexagonShape, HexArray, HexagonArray


include("util.jl")
include("indices.jl")
include("shape.jl")
include("array.jl")
include("coords.jl")
include("Plotly.jl")


end # module HexGrids
