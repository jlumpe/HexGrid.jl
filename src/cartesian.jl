
const ROOT32 = Float32(sqrt(3) / 2)

const AXIAL2CART = @SArray Float32[1 0.5; 0 -ROOT32]
const CART2AXIAL = inv(AXIAL2CART)


"""
	axial2cart(coords::AbstractVector)::Vector
	axial2cart(coords::AbstractMatrix)::Matrix

Convert axial hex coordinates to Cartesian coordinates.

# Arguments
- `coords`: 2-dimensional vector or a 2 x n matrix.
"""
axial2cart(coords::AbstractArray) = AXIAL2CART * coords


"""
	axial2cart!(out, coords)

Convert axial hex coordinates to Cartesian coordinates and store the result in `out`.

# Arguments
- `coords`: 2-dimensional vector or a 2 x n matrix.
- `out`: Array with same shape as `coords`.
"""
axial2cart!(out::AbstractArray, coords::AbstractArray) = mul!(out, AXIAL2CART, coords)


"""
	cart2axial(coords)

Convert Cartesian coordinates to axial hex coordinates.

# Arguments
- `coords`: 2-dimensional vector or a 2 x n matrix.
"""
cart2axial(coords::AbstractArray) = CART2AXIAL * coords


"""
	cart2axial!(out, coords)

Convert Cartesian coordinates to axial hex coordinates and store the result in `out`.

# Arguments
- `coords`: 2-dimensional vector or a 2 x n matrix.
- `out`: Array with same shape as `coords`.
"""
cart2axial!(out::AbstractArray, coords::AbstractArray) = mul!(out, CART2AXIAL, coords)


"""
	cartesian(::HexIndex)

Get cartesian coordinates of cell center.
"""
function cartesian end

cartesian(ix::Union{AxialIndex, CubeIndex}) = SA{Float32}[ix[1] + .5f0 * ix[2], -ix[2] * ROOT32]


function cartesian!(out::AbstractMatrix, indices::AbstractVector)
	for (i, idx) in enumerate(indices)
		out[:, i] .= cartesian(idx)
	end
	return out
end


"""
	cartesian(indices::AbstractVector{HexIndex})::Matrix{Float64}

Get the x/y coordinates of a collection of indices as a 2-row matrix.
"""
function cartesian(indices::AbstractVector)
	xy = Array{Float64}(undef, 2, length(indices))
	cartesian!(xy, indices)
end
