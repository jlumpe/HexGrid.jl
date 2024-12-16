########################################
# Interfaces
########################################

"""
Shape of a hexagonal array - a set of cells.

Acts as a collection of cell indices of type `I``.
"""
abstract type ArrayShape{I <: HexIndex} end

Base.IteratorSize(::Type{<:ArrayShape}) = Base.HasLength()
Base.eltype(::Type{<:ArrayShape{I}}) where I = I


"""
	neighbors(s::ArrayShape, ix::I)::Vector{I} where I <: HexIndex

Neighbors of a cell that are within the shape.
"""
neighbors(s::ArrayShape, ix::I) where I <: HexIndex = filter(∈(s), neighbors(ix))


"""
	reindex(::Type{I}, s::ArrayShape)::ArrayShape{I}

Create a copy of an `ArrayShape` using an alternate index type.
"""
reindex(::Type{I}, shape::ArrayShape{I}) where I = shape


########################################
# HexShape
########################################

"""
Array in the shape of a hexagon.

`n` is the side length/radius. Origin is in the center.
"""
struct HexagonShape{I} <: ArrayShape{I}
	n::Int
	l::Int

	function HexagonShape{I}(n::Int) where I
		n > 0 || throw(ArgumentError("n must be positive"))
		l = 3 * n * (n - 1) + 1
		return new{I}(n, l)
	end
end

HexagonShape(n::Int) = HexagonShape{AxialIndex}(n)

reindex(::Type{I}, s::HexagonShape) where I <: HexIndex = HexagonShape{I}(s.n)


Base.show(io::IO, s::HexagonShape) = print(io, typeof(s), "(", s.n, ")")

function Base.in(ix::HexIndex, s::HexagonShape)
	validindex(ix) && hexdist(ix) < s.n
end

Base.length(s::HexagonShape) = s.l


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
