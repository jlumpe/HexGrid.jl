
"""
	roundhex(q, r[, s])
	roundhex(p::AbstractVector)

Round fractional axial or cube coordinates to nearest cell center.

Accepts coordinates as individual arguments or a single vector. For a non-statically-sized vector,
the `roundhex_axial` or `roundhex_cube` functions should be used instead.
"""
function roundhex(q::Real, r::Real, s::Real=-(q+r))
	qi = round(Int, q)
	ri = round(Int, r)
	si = round(Int, s)

	qdiff = abs(q - qi)
	rdiff = abs(r - ri)
	sdiff = abs(s - si)

	if qdiff > rdiff && qdiff > sdiff
		qi = -(ri + si)
	elseif rdiff > sdiff
		ri = -(qi + si)
	else
		si = -(qi + ri)
	end

	return CubeIndex(qi, ri, si)
end

roundhex(::AxialCoords, v::AbstractVector) = roundhex(v[1], v[2])
roundhex(::CubeCoords, v::AbstractVector) = roundhex(v[1], v[2], v[3])
roundhex(::CartesianCoords, v::AbstractVector) = roundhex(CubeCoords(), convertcoords(CartesianCoords(), CubeCoords(), v))


"""
	BoundingBox

Represents an axis-aligned bounding box in Cartesian coordinates.
"""
struct BoundingBox
	left::Float32
	right::Float32
	bottom::Float32
	top::Float32
end

Base.convert(::Type{BoundingBox}, tup::NTuple{4, Number}) = BoundingBox(tup...)
Base.convert(::Type{BoundingBox}, vec::AbstractVector{<:Number}) = BoundingBox(vec...)

const CELL_BB = BoundingBox(-.5, .5, .5 * ROOT32, -.5 * ROOT32)

"""
	boundingbox(ix::HexIndex)
	boundingbox(shape::HexShape)

Get a bounding box in Cartesian coordinates surrounding the cell or cells.
"""
function boundingbox(ix::HexIndex)
	x, y = cartesian(ix)
	BoundingBox(x + CELL_BB.left, x + CELL_BB.right, y + CELL_BB.bottom, y + CELL_BB.top)
end

function boundingbox(shape::HexagonShape)
	s = 2 * shape.n - 1
	BoundingBox(CELL_BB.left * s, CELL_BB.right * s, CELL_BB.bottom * s, CELL_BB.top * s)
end
