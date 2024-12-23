
abstract type InterpMode end


struct InterpNearest <: InterpMode end


struct InterpLinear <: InterpMode end


abstract type BoundaryMode end

struct BoundaryConstant{T} <: BoundaryMode
	value::T
end

struct BoundaryNearest <: BoundaryMode end


"""
Hex array supporting interpolation between cells.
"""
struct InterpArray{A<:HexArray, I<:InterpMode, B<:BoundaryMode}
	array::A
	im::I
	bm::B
end


"""
	interpolate(ia::InterpArray, ::CoordinateSystem, coords)

Perform interpolation on an `InterpArray`.
"""
function interpolate end


function interpolate(ia::InterpArray{A, InterpNearest, BoundaryConstant{T2}}, cs::CoordinateSystem, coords) where {T, A <: HexArray{T}, T2}
	ix = roundhex(cs, coords)
	return get(ia.array, ix, convert(T, ia.bm.value))
end


rasterize!(raster::AbstractMatrix, ia::InterpArray, bb) = _rasterize!(raster, ia, convert(BoundingBox, bb))

function _rasterize!(raster::AbstractMatrix, ia::InterpArray, bb::BoundingBox)
	w = bb.right - bb.left
	h = bb.top - bb.bottom
	nrow, ncol = size(raster)

	pw = w / ncol
	ph = h / nrow

	x = LinRange(bb.left + pw, bb.right - pw, ncol)
	y = LinRange(bb.bottom + ph, bb.top - ph, nrow)

	for i in axes(raster, 1)
		for j in axes(raster, 2)
			pxy = SA[x[i], y[j]]
			raster[i, j] = interpolate(ia, CartesianCoords(), pxy)
		end
	end

	raster
end
