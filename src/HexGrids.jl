"""
Package for working with hexagonal grids.
"""
module HexGrids

using Requires

export HexIndex, AxialIndex, CubeIndex, neighbors


const root32 = sqrt(3) / 2


include("util.jl")
include("indices.jl")
include("shape.jl")
include("array.jl")

# function __init__()
# 	@require PlotlyJS="f0f68f2c-4968-5e81-91da-67840de0976a" include("Plotly.jl")
# end


end # module HexGrids
