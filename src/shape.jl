########################################
# Interfaces
########################################

"""
Shape of a hexagonal array - a set of cells.

Acts as a collection of cell indices of type I.
"""
abstract type ArrayShape{I <: HexIndex} end

Base.IteratorSize(::Type{<:ArrayShape}) = Base.HasLength()
Base.eltype(::Type{<:ArrayShape{I}}) where I = I

Base.in(ix::I, s::ArrayShape{I}) where I = validindex(s, ix)


"""
	neighbors(s::ArrayShape, ix::I)::Vector{I} where I <: HexIndex

Neighbors of a cell that are within the shape.
"""
neighbors(s::ArrayShape, ix::I) where I <: HexIndex = filter(n -> validindex(s, n), neighbors(ix))


"""
	validindex(s::ArrayShape, ix::HexIndex)::Bool

Check whether the index is valid for the given shape. Supports index types other than `eltype(s)`.
"""
validindex


"""
	reindex(s::ArrayShape, ::Type{I})::ArrayShape{I}

Create a copy of an `ArrayShape` using an alternate index type.
"""
reindex


########################################
# HexShape
########################################

"""
Array in the shape of a hexagon.

n is the side length. Origin is in the center.
"""
struct HexagonShape{I} <: ArrayShape{I}
	n::Int

	function HexagonShape{I}(n::Int) where I
		n > 0 || throw(ArgumentError("n must be positive"))
		return new{I}(n)
	end
end

HexagonShape(n::Int) = HexagonShape{AxialIndex}(n)

function validindex(s::HexagonShape, ix::HexIndex)
	!validindex(ix) && return false
	all(abs(i) < s.n for i in convert(CubeIndex, ix))
end

reindex(s::HexagonShape, ::Type{I}) where I <: HexIndex = HexagonShape{I}(s.n)

Base.length(s::HexagonShape) = 3 * s.n * (s.n - 1) + 1

function Base.iterate(s::HexagonShape{I}) where I
	nm1 = s.n - 1

	ch = Channel{I}() do ch
		for x in -nm1:nm1
			for y in (-nm1 - min(x, 0)):(nm1 - max(x, 0))
				ix = convert(I, AxialIndex(x, y))
				put!(ch, ix)
			end
		end
	end

	return iterate(s, (ch,))
end

Base.iterate(::HexagonShape, state::Tuple) = iterate_proxy(state)
