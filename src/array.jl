########################################
# Interface
########################################

"""
	HexArray{T}

Type which stores values for a set of hex cells.
"""
abstract type HexArray{T} end


"""
	HexArray{T}(shape::HexShape)

Create a `HexArray` instance with eltype `T` and shape `shape`.
"""

# Type traits
Base.IteratorSize(::Type{<:HexArray}) = Base.HasLength()
Base.eltype(::Type{<:HexArray{T}}) where T = T


# Basic attributes
Base.length(a::HexArray) = length(HexShape(a))
Base.keys(a::HexArray) = HexShape(a)


HexShape{I}(a::HexArray) where I = reindex(I, HexShape(a))
eachindex(::Type{I}, a::HexArray) where {I <: HexIndex} = HexShape{I}(a)


function Base.:(==)(a1::HexArray, a2::HexArray)
	keys(a1) == keys(a2) || return false
	all(a1[ix] == a2[ix] for ix in keys(a1))
end

function Base.isequal(a1::HexArray, a2::HexArray)
	keys(a1) == keys(a2) || return false
	all(isequal(a1[ix] == a2[ix]) for ix in keys(a1))
end


# Default indexing-related stuff
Base.get(a::HexArray, ix::HexIndex, default) = ix in HexShape(a) ? a[ix] : default

Base.checkbounds(::Type{Bool}, a::HexArray, ix::HexIndex) = ix in HexShape(a)

function Base.checkbounds(a::HexArray, ix::HexIndex)
	checkbounds(Bool, a, ix) || throw(BoundsError(a, ix))
	nothing
end


# Default iterate
Base.iterate(a::HexArray) = iterate(a, (keys(a),))
Base.iterate(a::HexArray, state) = iterate_proxy(ix -> a[ix], state)


"""
	similar(array::HexArray, [element_type::Type], [shape::HexShape])

Create a new `HexArray` instance similar to `array`, optionally with a different element type and
shape. Note that the index type of `shape` may not be retained.
"""
Base.similar(array::HexArray, element_type::Type, shape::HexShape) = HexArray{element_type}(shape)
Base.similar(array::HexArray, element_type::Type) = similar(array, element_type, HexShape(array))
Base.similar(array::HexArray, shape::HexShape) = similar(array, eltype(array), shape)
Base.similar(array::HexArray) = similar(array, eltype(array), HexShape(array))


########################################
# HexagonArray
########################################

"""
	HexagonArray{T, A<:AbstractMatrix} <: HexArray{T}

A `HexArray` with shape [`HexagonShape`](@ref).
"""
struct HexagonArray{T, A<:AbstractMatrix} <: HexArray{T}
	shape::HexagonShape{AxialIndex}
	array::A

	function HexagonArray(shape::HexagonShape, array::AbstractMatrix)
		return new{eltype(array), typeof(array)}(reindex(AxialIndex, shape), array)
	end
end

# Constructors
function HexagonArray{T}(shape::HexagonShape) where {T}
	w = 2 * shape.n - 1
	array = Matrix{T}(undef, w, w)
	return HexagonArray(shape, array)
end
HexagonArray{T}(n::Integer) where T = HexagonArray{T}(HexagonShape{AxialIndex}(n))


# Attributes
HexShape(a::HexagonArray) = a.shape
Base.keytype(::HexagonArray) = AxialIndex
Base.keytype(::Type{<:HexagonArray}) = AxialIndex


# Alternate creation methods
HexArray{T}(shape::HexagonShape) where T = HexagonArray{T}(shape)
Base.copy(a::HexagonArray) = HexagonArray(a.shape, copy(a.array))
Base.deepcopy(a::HexagonArray) = HexagonArray(a.shape, deepcopy(a.array))


# Mutability
Base.fill!(a::HexagonArray, v) = (fill!(a.array, v); a)

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
