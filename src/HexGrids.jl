"""
Package for working with hexagonal grids.
"""
module HexGrids

using Requires

export HexIndex, AxialIndex, CubeIndex, neighbors
export ArrayShape, HexagonShape, HexArray, HexagonHexArray


const root32 = sqrt(3) / 2


include("util.jl")
include("indices.jl")
include("shape.jl")
include("array.jl")

include("Plotly.jl")


end # module HexGrids
