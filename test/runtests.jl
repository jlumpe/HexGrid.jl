using Test
using HexGrids

using HexGrids: cartesian, reindex, VectorHexIndex


@testset "Indices" include("indices.jl")
@testset "Shapes" include("shapes.jl")
@testset "Arrays" include("arrays.jl")
