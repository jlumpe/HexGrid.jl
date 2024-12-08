########################################
# Interface
########################################

"""
Index for a cell in a hexagonal grid.
"""
abstract type HexIndex end


# Treat as a scalar for broadcasting
# (similar behavior to CartesianIndex).
Base.broadcastable(ix::HexIndex) = Ref(ix)


"""
	neighbors(::T) where T <: HexIndex

Get the 6 neighbors of a hex cell given its index.
"""
function neighbors end


"""
	isneighbor(ix1::HexIndex, ix2::HexIndex)::Bool

Check if two cells are neighbors.
"""
isneighbor(ix1::HexIndex, ix2::HexIndex) = hexdist(ix1, ix2) == 1


"""
	validindex(::HexIndex)::Bool

Check if hex index is valid.
"""
validindex(::HexIndex) = true


"""
	hexdist(idx1::HexIndex, [idx2::HexIndex])::Int

Grid distance between two hex indices (or from a single index to the origin).

This is the minimum number of jumps between neighbors to get from one cell to another.
"""
hexdist


"""
	cartesian(::HexIndex)::NTuple{2, Float64}

Get cartesian coordinates of cell center.
"""
function cartesian end


"""
	cartesian_array(indices)::Matrix{Float64}

Get the x/y coordinates of a collection of indices as a 2-row matrix.
"""
function cartesian_array(indices)
	xy = Array{Float64}(undef, 2, length(indices))
	for (i, idx) in enumerate(indices)
		xy[:, i] .= cartesian(idx)
	end
	return xy
end


########################################
# VectorHexIndex
########################################

"""
Index type which behaves as a vector, more or less (supports addition and scaling by integer values).

Vector indices can act as an offset, and added to / subtracted from any index of any type, with
the generic index on the left an the vector index on the right. The result will have the type of the
index on the left.
"""
abstract type VectorHexIndex <: HexIndex end


"""
	hexaxes(::Type{T}) where T <: VectorHexIndex

Get indices representing unit vectors along the three main axes.

Axes are 0, 60, and 120 degrees from Cartesian x axis.
"""
function hexaxes end


function neighbors(ix::T) where T <: VectorHexIndex
	a, b, c = hexaxes(T)
	return @SArray T[ix + a, ix + b, ix + c, ix - a, ix - b, ix - c]
end


hexdist(ix1::VectorHexIndex, ix2::VectorHexIndex) = hexdist(ix1 - ix2)


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

@tuplewrapper CubeIndex I 3 Int

validindex(ix::CubeIndex) = sum(ix.I) == 0
hexdist(ix::CubeIndex) = maximum(abs, ix)
hexdist(ix1::CubeIndex, ix2::CubeIndex) = max(abs(ix1[1] - ix2[1]), abs(ix1[2] - ix2[2]), abs(ix1[3] - ix2[3]))
cartesian(ix::CubeIndex) = (ix[1] + .5 * ix[2], -ix[2] * root32)

Base.zero(::Type{CubeIndex}) = CubeIndex()
Base.:-(idx::CubeIndex) = CubeIndex(.-idx.I)
Base.:+(a::CubeIndex, b::CubeIndex) = CubeIndex(a.I .+ b.I)
Base.:-(a::CubeIndex, b::CubeIndex) = CubeIndex(a.I .- b.I)
Base.:*(a::Integer, ix::CubeIndex) = CubeIndex(ix.I .* a)
Base.:*(ix::CubeIndex, a::Integer) = CubeIndex(ix.I .* a)

const CUBE_NEIGHBORS = @SArray [
	CubeIndex(1, 0, -1), CubeIndex(1, -1, 0), CubeIndex(0, -1, 1),
	CubeIndex(-1, 0, 1), CubeIndex(-1, 1, 0), CubeIndex(0, 1, -1),
]

const CUBE_AXES = CUBE_NEIGHBORS[SA[1, 2, 3]]

hexaxes(::Type{CubeIndex}) = CUBE_AXES
hexaxes(::Type{CubeIndex}, i::Integer) = CUBE_AXES[i]
neighbors(ix::CubeIndex) = ix .+ CUBE_NEIGHBORS


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

@tuplewrapper AxialIndex I 2 Int

hexdist(ix::AxialIndex) = max(abs(ix[1]), abs(ix[2]), abs(ix[1] + ix[2]))
hexdist(ix1::AxialIndex, ix2::AxialIndex) = max(abs(ix1[1] - ix2[1]), abs(ix1[2] - ix2[2]), abs(ix1[1] + ix1[2] - ix2[1] - ix2[2]))
cartesian(ix::AxialIndex) = (ix[1] + .5 * ix[2], ix[2] * -root32)

Base.zero(::Type{AxialIndex}) = AxialIndex()
Base.:-(idx::AxialIndex) = AxialIndex(.-idx.I)
Base.:+(a::AxialIndex, b::AxialIndex) = AxialIndex(a.I .+ b.I)
Base.:-(a::AxialIndex, b::AxialIndex) = AxialIndex(a.I .- b.I)
Base.:*(a::Integer, ix::AxialIndex) = AxialIndex(ix.I .* a)
Base.:*(ix::AxialIndex, a::Integer) = AxialIndex(ix.I .* a)

const AXIAL_NEIGHBORS = @SArray [AxialIndex(ix[1], ix[2]) for ix in CUBE_NEIGHBORS]
const AXIAL_AXES = AXIAL_NEIGHBORS[SA[1, 2, 3]]

hexaxes(::Type{AxialIndex}) = AXIAL_AXES
hexaxes(::Type{AxialIndex}, i::Integer) = AXIAL_AXES[i]
neighbors(ix::AxialIndex) = ix .+ AXIAL_NEIGHBORS


########################################
# Conversion and promotion
########################################

Base.convert(::Type{I}, ix::HexIndex) where I <: HexIndex = I(ix)

AxialIndex(ix::CubeIndex) = AxialIndex(ix.I[1], ix.I[2])
CubeIndex(ix::AxialIndex) = CubeIndex(ix.I[1], ix.I[2])

# Promote to AxialIndex by default if different

# Equality by conversion to AxialIndex
Base.:(==)(ix1::HexIndex, ix2::HexIndex) = AxialIndex(ix1) == AxialIndex(ix2)

# Right-addition/subtraction by vector index, preserving type of left
# Do by conversion to AxialIndex
Base.:+(ix1::L, ix2::VectorHexIndex) where {L <: HexIndex} = convert(L, convert(AxialIndex, ix1) + convert(AxialIndex, ix2))
Base.:-(ix1::L, ix2::VectorHexIndex) where {L <: HexIndex} = convert(L, convert(AxialIndex, ix1) - convert(AxialIndex, ix2))
