"""
Package for working with hexagonal grids.
"""
module HexGrids

using StaticArrays

export HexIndex, AxialIndex, CubeIndex
export validindex, isneighbor, neighbors, hexdist, hexaxes
export ArrayShape, HexagonShape, HexArray, HexagonHexArray


const root32 = sqrt(3) / 2


include("util.jl")
include("indices.jl")
include("shape.jl")
include("array.jl")

include("Plotly.jl")


end # module HexGrids
