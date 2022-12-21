using Test
using HexGrids

using HexGrids: neighbors, isneighbor, hexaxes, cartesian, validindex, root32
using HexGrids: ArrayShape, HexagonShape, HexagonHexArray, reindex


@testset "Indices" include("indices.jl")
@testset "Shapes" include("shapes.jl")
@testset "Arrays" include("arrays.jl")
