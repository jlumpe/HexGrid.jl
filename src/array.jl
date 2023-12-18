########################################
# Interface
########################################

"""
Type which stores values for a set of hex cells.
"""
abstract type HexArray{T, I} end

Base.length(a::HexArray) = length(ArrayShape(a))
Base.IteratorSize(::Type{<:HexArray}) = Base.HasLength()
Base.eltype(::Type{<:HexArray{T}}) where T = T
Base.keytype(::Type{<:HexArray{T, I}}) where {T, I} = I
Base.keytype(a::HexArray) = keytype(typeof(a))
Base.keys(a::HexArray) = ArrayShape(a)


"""
	reindex(a::HexArray, I::Type{<:HexIndex})

Create a copy of `a` using the same data but a different index type `I`.
"""
reindex


"""
	ArrayShape(a::HexArray{T, I}, index_type::Type{<:HexIndex}=I)::ArrayShape{index_type}

Get the shape (set of cells) of a `HexArray`.
"""
ArrayShape(a::HexArray, I::Type{<:HexIndex}) = reindex(ArrayShape(a), I)


########################################
# HexagonHexArray
########################################

struct HexagonHexArray{T, I, A<:AbstractMatrix} <: HexArray{T, I}
	shape::HexagonShape{I}
	array::A

	function HexagonHexArray(shape::HexagonShape, array::AbstractMatrix)
		return new{eltype(array), eltype(shape), typeof(array)}(shape, array)
	end
end

function HexagonHexArray{T}(shape::HexagonShape{I}) where {T, I}
	w = 2 * shape.n - 1
	array = Matrix{T}(undef, w, w)
	return HexagonHexArray(shape, array)
end
HexagonHexArray{T, I}(n::Int) where {T, I} = HexagonHexArray{T}(HexagonShape{I}(n))
HexagonHexArray{T}(n::Int) where T = HexagonHexArray{T, AxialIndex}(n)

ArrayShape(a::HexagonHexArray) = a.shape
reindex(a::HexagonHexArray, I::Type{<:HexIndex}) = HexagonHexArray{eltype(a)}(reindex(a.shape, I), a.array)

Base.similar(a::HexagonHexArray, element_type::Type=eltype(a)) = HexagonHexArray{element_type, keytype(a)}(a.n)
Base.copy(a::HexagonHexArray) = HexagonHexArray(a.shape, copy(a.array))
Base.deepcopy(a::HexagonHexArray) = HexagonHexArray(a.shape, deepcopy(a.array))

function Base.fill!(a::HexagonHexArray, v)
	fill!(a.array, v)
	return a
end

function _arrayindex(a::HexagonHexArray, ix::HexIndex)
	c = convert(CubeIndex, ix)
	validindex(ArrayShape(a), c) || error("Invalid index $ix")
	return CartesianIndex(c[1] + a.shape.n, c[2] + a.shape.n)
end

Base.getindex(a::HexagonHexArray, ix::HexIndex) = a.array[_arrayindex(a, ix)]
function Base.setindex!(a::HexagonHexArray, v, ix::HexIndex)
	a.array[_arrayindex(a, ix)] = v
	return a
end

Base.iterate(a::HexagonHexArray) = iterate(a, (ArrayShape(a, AxialIndex),))
Base.iterate(a::HexagonHexArray, state) = iterate_proxy(i -> a[i], state)
