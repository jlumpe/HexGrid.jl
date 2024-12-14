using Test
using HexGrids

using HexGrids: cartesian, reindex, VectorHexIndex


@testset "Indices" include("indices.jl")
@testset "Cartesian" include("cartesian.jl")
@testset "Shapes" include("shapes.jl")
@testset "Arrays" include("arrays.jl")
