# Convert between real coordinate systems and get coordinates of cell centers based on index.

const ROOT32 = Float32(sqrt(3) / 2)

const AXIAL2CART = @SArray Float32[1 0.5; 0 -ROOT32]
const CART2AXIAL = inv(AXIAL2CART)

const AXIAL2CUBE = SA{Float32}[1 0; 0 1; -1 -1]
const CUBE2AXIAL = SA{Float32}[1 0 0; 0 1 0]

const CUBE2CART = AXIAL2CART * CUBE2AXIAL
const CART2CUBE = AXIAL2CUBE * CART2AXIAL

const CUBE_NEIGHBORS_FRAC = SA{Float32}[
	 1  1  0 -1 -1  0;
	 0 -1 -1  0  1  1;
	-1  0  1  1  0 -1;
]
const CUBE_AXES_FRAC = CUBE_NEIGHBORS_FRAC[:, SA[1, 2, 3]]

const AXIAL_NEIGHBORS_FRAC = CUBE_NEIGHBORS_FRAC[SA[1, 2], :]
const AXIAL_AXES_FRAC = AXIAL_NEIGHBORS_FRAC[:, SA[1, 2, 3]]

const CARTESIAN_NEIGHBORS = AXIAL2CART * AXIAL_NEIGHBORS_FRAC
const CARTESIAN_AXES = CARTESIAN_NEIGHBORS[:, SA[1, 2, 3]]


"""
	CoordinateSystem

Abstract type representing a real coordinate system in the plane.
"""
abstract type CoordinateSystem end

"""
	AxialCoords

Axial coordinate system, with two real components. The first basis vector is identical
to the Cartesian X basis vector. The second is the first rotated by -60 degrees.

This is the real-valued version of [`AxialIndex`](@ref).
"""
struct AxialCoords <: CoordinateSystem end

"""
	CubeCoords

Cube coordinate system, with three real components. The first two are identical to
[`AxialCoords`](@ref), and all three sum to zero.

This is the real-valued version of [`CubeIndex`](@ref).
"""
struct CubeCoords <: CoordinateSystem end

"""
	CartesianCoords

Standard Cartesian coordinate system.
"""
struct CartesianCoords <: CoordinateSystem end


"""
	coorddims(::CoordinateSystem)
	coorddims(::Type{<:CoordinateSystem})

Get the number of dimensions of the coordinate system.
"""
coorddims(::S) where {S <: CoordinateSystem} = coorddims(S)
coorddims(::Type{AxialCoords}) = 2
coorddims(::Type{CubeCoords}) = 3
coorddims(::Type{CartesianCoords}) = 2


"""
	hexaxes(::CoordinateSystem)::StaticMatrix


Get unit vectors along the three main hexagonal axes in the given coordinate system.

Axes are 0, 60, and 120 degrees from Cartesian x axis.

Return value is a matrix with the vectors in columns.
"""
hexaxes

hexaxes(::AxialCoords) = AXIAL_AXES_FRAC
hexaxes(::CubeCoords) = CUBE_AXES_FRAC
hexaxes(::CartesianCoords) = CARTESIAN_AXES


"""
	convertcoords(from::CoordinateSystem, to::CoordinateSystem, coords::AbstractVector)::AbstractVector
	convertcoords(from::CoordinateSystem, to::CoordinateSystem, coords::AbstractMatrix)::AbstractMatrix

Convert coordinate vectors between coordinate systems. Also accepts a matrix, with individual
coordinate vectors in columns.
"""
function convertcoords end


"""
	convertcoords!(out, from::CoordinateSystem, to::CoordinateSystem, coords)

Convert coordinate vectors between coordinate systems, writing the output to an existing array.
"""
function convertcoords! end


# Identity conversion
function convertcoords(::C, ::C, coords::AbstractVector{T}) where {C <: CoordinateSystem, T}
	# Return same type as if multiplied by NxN static identity matrix
	T2 = promote_type(T, Float32)
	N = coorddims(C)
	return SVector{N, T2}(coords)
end
convertcoords(::C, ::C, coords) where {C <: CoordinateSystem} = copy(coords)
convertcoords!(out, ::C, ::C, coords) where {C <: CoordinateSystem} = copyto!(out, coords)


"""
Define linear conversion by left-multiplying by a matrix.
"""
macro _linear_conversion(sys1::Symbol, sys2::Symbol, mat::Symbol)
	sys1 = esc(sys1)
	sys2 = esc(sys2)
	mat = esc(mat)
	quote
		$(esc(:convertcoords))(::$sys1, ::$sys2, coords) = $mat * coords
		$(esc(:convertcoords!))(out, ::$sys1, ::$sys2, coords) = mul!(out, $mat, coords)
	end
end


@_linear_conversion AxialCoords CartesianCoords AXIAL2CART
@_linear_conversion CartesianCoords AxialCoords CART2AXIAL
@_linear_conversion CubeCoords CartesianCoords CUBE2CART
@_linear_conversion CartesianCoords CubeCoords CART2CUBE
@_linear_conversion CubeCoords AxialCoords CUBE2AXIAL
@_linear_conversion AxialCoords CubeCoords AXIAL2CUBE

# convertcoords(::CubeCoords, ::AxialCoords, coords::AbstractVector) = coords[SA[1, 2]]
# convertcoords(::CubeCoords, ::AxialCoords, coords::AbstractMatrix) = coords[SA[1, 2], :]
# convertcoords(::AxialCoords, ::CubeCoords, coords::AbstractVector) = SA[coords[1], coords[2], -(coords[1] + coords[2])]


"""
	center(::CoordinateSystem, index::HexIndex)::StaticVector{N, Float32}

Get the coordinates of the center of the hex cell in the given coordinate system.
"""
function center end


center(::AxialCoords, ix::AxialIndex) = SVector{2, Float32}(ix.I)
center(::AxialCoords, ix::CubeIndex) = SA{Float32}[ix[1], ix[2]]
center(::CubeCoords, ix::AxialIndex) = SA{Float32}[ix[1], ix[2], -(ix[1] + ix[2])]
center(::CubeCoords, ix::CubeIndex) = SVector{3, Float32}(ix.I)

center(::CartesianCoords, ix::Union{AxialIndex, CubeIndex}) = SA{Float32}[ix[1] + .5f0 * ix[2], -ix[2] * ROOT32]


function centers(c::CoordinateSystem, indices)
	out = Array{Float32}(undef, coorddims(c), length(indices))
	centers!(out, c, indices)
end


function centers!(out::AbstractMatrix, c::CoordinateSystem, indices)
	for (i, ix) in enumerate(indices)
		out[:, i] = center(c, ix)
	end
	return out
end


# Aliases
cartesian(ix::HexIndex) = center(CartesianCoords(), ix)
cartesian(ixs) = centers(CartesianCoords(), ixs)
cartesian!(out, ixs) = centers!(out, CartesianCoords(), ixs)
