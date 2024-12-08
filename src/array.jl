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
	ArrayShape(a::HexArray{T, I})::ArrayShape{I}
	ArrayShape(a::HexArray, index_type::Type{I})::ArrayShape{I}

Get the shape (set of cells) of a `HexArray`.
"""
ArrayShape(a::HexArray, I::Type{<:HexIndex}) = reindex(ArrayShape(a), I)


Base.checkbounds(::Type{Bool}, a::HexArray, i::HexIndex) = i in ArrayShape(a)

function Base.checkbounds(a::HexArray, i::HexIndex)
	checkbounds(Bool, a, i) || throw(BoundsError(a, i))
	nothing
end


########################################
# HexagonArray
########################################

struct HexagonArray{T, I, A<:AbstractMatrix} <: HexArray{T, I}
	shape::HexagonShape{I}
	array::A

	function HexagonArray(shape::HexagonShape, array::AbstractMatrix)
		return new{eltype(array), eltype(shape), typeof(array)}(shape, array)
	end
end

function HexagonArray{T}(shape::HexagonShape{I}) where {T, I}
	w = 2 * shape.n - 1
	array = Matrix{T}(undef, w, w)
	return HexagonArray(shape, array)
end
HexagonArray{T, I}(n::Int) where {T, I} = HexagonArray{T}(HexagonShape{I}(n))
HexagonArray{T}(n::Int) where T = HexagonArray{T, AxialIndex}(n)

ArrayShape(a::HexagonArray) = a.shape
reindex(a::HexagonArray, I::Type{<:HexIndex}) = HexagonArray{eltype(a)}(reindex(a.shape, I), a.array)

Base.similar(a::HexagonArray, element_type::Type=eltype(a)) = HexagonArray{element_type, keytype(a)}(a.n)
Base.copy(a::HexagonArray) = HexagonArray(a.shape, copy(a.array))
Base.deepcopy(a::HexagonArray) = HexagonArray(a.shape, deepcopy(a.array))

function Base.fill!(a::HexagonArray, v)
	fill!(a.array, v)
	return a
end

function _arrayindex(a::HexagonArray, ix::HexIndex)
	@boundscheck checkbounds(a, ix)
	aix = convert(AxialIndex, ix)
	return CartesianIndex(aix[1] + a.shape.n, aix[2] + a.shape.n)
end

Base.@propagate_inbounds function Base.getindex(a::HexagonArray, ix::HexIndex)
	cix = _arrayindex(a, ix)
	return a.array[cix]
end

Base.@propagate_inbounds function Base.setindex!(a::HexagonArray, v, ix::HexIndex)
	cix = _arrayindex(a, ix)
	a.array[cix] = v
	return a
end

Base.iterate(a::HexagonArray) = iterate(a, (ArrayShape(a, AxialIndex),))
Base.iterate(a::HexagonArray, state) = iterate_proxy(i -> a[i], state)
