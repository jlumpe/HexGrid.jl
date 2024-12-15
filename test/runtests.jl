using Test
using HexGrids


@testset "Indices" include("indices.jl")
@testset "Coordinates" include("coords.jl")
@testset "Shapes" include("shapes.jl")
@testset "Arrays" include("arrays.jl")
