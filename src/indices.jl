########################################
# Interface
########################################

"""
Index for a cell in a hexagonal grid.
"""
abstract type HexIndex end


"""
	neighbors(::T)::NTuple{6, T} where T <: HexIndex

Get the 6 neighbors of a hex cell given its index.
"""
function neighbors end


"""
	isneighbor(::HexIndex, ::HexIndex)::Bool

Check if two cells are neighbors.
"""
function isneighbor end


"""
	validindex(::HexIndex)::Bool

Check if hex index is valid.
"""
validindex(::HexIndex) = true


"""
	cartesian(::HexIndex)::NTuple{2, Float64}

Get cartesian coordinates of cell center.
"""
function cartesian end


########################################
# VectorHexIndex
########################################

"""
Index type which behaves as a vector, more or less (supports addition and scaling by integer values).
"""
abstract type VectorHexIndex <: HexIndex end


"""
	hexaxes(::Type{T})::NTuple{3, T} where T <: VectorHexIndex

Indices representing unit vectors along the three main axes.

Axes are 0, 60, and 120 degrees from Cartesian x axis.
"""
function hexaxes end

function neighbors(ix::T) where T <: VectorHexIndex
	a, b, c = hexaxes(T)
	return (ix + a, ix + b, ix + c, ix - a, ix - b, ix - c)
end


########################################
# CubeIndex
########################################

"""
As 3d cartesian coordinates in the x+y+z=0 plane.
"""
struct CubeIndex <: VectorHexIndex
	I::NTuple{3, Int}
end

CubeIndex(x::Integer, y::Integer, z::Integer=-(x+y)) = CubeIndex((Int(x), Int(y), Int(z)))
CubeIndex() = CubeIndex(0, 0, 0)
CubeIndex(ix::CubeIndex) = ix

Base.show(io::IO, ix::CubeIndex) = show_tuple_wrapper(io, ix)

@tuplewrapper CubeIndex I 3 Int

validindex(ix::CubeIndex) = sum(ix.I) == 0
hexaxes(::Type{CubeIndex}) = (CubeIndex(1, 0, -1), CubeIndex(0, 1, -1), CubeIndex(-1, 1, 0))
cartesian(ix::CubeIndex) = (ix[1] + .5 * ix[2], ix[2] * root32)

Base.zero(::Type{CubeIndex}) = CubeIndex()
Base.:-(idx::CubeIndex) = CubeIndex(.-idx.I)
Base.:+(a::CubeIndex, b::CubeIndex) = CubeIndex(a.I .+ b.I)
Base.:-(a::CubeIndex, b::CubeIndex) = CubeIndex(a.I .- b.I)
Base.:*(a::Integer, ix::CubeIndex) = CubeIndex(ix.I .* a)
Base.:*(ix::CubeIndex, a::Integer) = CubeIndex(ix.I .* a)


########################################
# AxialIndex
########################################

"""
Like CubeIndex, but only stores the first two coordinates.
"""
struct AxialIndex <: VectorHexIndex
	I::NTuple{2, Int}
end

AxialIndex(x::Integer, y::Integer) = AxialIndex((Int(x), Int(y)))
AxialIndex() = AxialIndex(0, 0)
AxialIndex(ix::AxialIndex) = ix

Base.show(io::IO, ix::AxialIndex) = show_tuple_wrapper(io, ix)

@tuplewrapper AxialIndex I 2 Int

hexaxes(::Type{AxialIndex}) = (AxialIndex(1, 0), AxialIndex(0, 1), AxialIndex(-1, 1))
cartesian(ix::AxialIndex) = (ix[1] + .5 * ix[2], ix[2] * root32)

Base.zero(::Type{AxialIndex}) = AxialIndex()
Base.:-(idx::AxialIndex) = AxialIndex(.-idx.I)
Base.:+(a::AxialIndex, b::AxialIndex) = AxialIndex(a.I .+ b.I)
Base.:-(a::AxialIndex, b::AxialIndex) = AxialIndex(a.I .- b.I)
Base.:*(a::Integer, ix::AxialIndex) = AxialIndex(ix.I .* a)
Base.:*(ix::AxialIndex, a::Integer) = AxialIndex(ix.I .* a)


########################################
# Conversions
########################################

Base.convert(::Type{I}, ix::HexIndex) where I <: HexIndex = I(ix)

AxialIndex(ix::CubeIndex) = AxialIndex(ix.I[1], ix.I[2])
CubeIndex(ix::AxialIndex) = CubeIndex(ix.I[1], ix.I[2])

