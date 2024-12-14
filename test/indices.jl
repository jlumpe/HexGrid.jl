

function test_tuple_wrapper(x, n::Int, E::Type)
	t = Tuple(x)
	@test t isa NTuple{n, E}

	test_tuple_wrapper(x, t)
end


function test_tuple_wrapper(x, t::Tuple)
	n = length(t)

	@test length(x) == n
	@test eltype(x) === eltype(t)
	@test firstindex(x) == 1
	@test lastindex(x) == n

	@test tuple(x...) === t

	for i in 1:n
		@test x[i] === t[i]
	end
end


"""
Test value is a valid index of type I and equal to expected.
"""
function test_valid_and_equal(I::Type{<:HexIndex}, value, expected)
	if expected isa HexIndex
		expected2 = I(expected)
	else
		expected2 = I(AxialIndex(expected))
	end
	@test value isa I
	@test validindex(value)
	@test value === expected2
end


function test_index_general(I::Type{<:VectorHexIndex})
	ix1 = I(AxialIndex(1, 2))
	ix2 = I(AxialIndex(3, -4))

	# Equality + validity
	test_valid_and_equal(I, ix1, (1, 2))
	test_valid_and_equal(I, ix2, (3, -4))
	@test ix1 != ix2

	# Zero
	test_valid_and_equal(I, zero(I), (0, 0))

	# Neighbors
	nbrs = neighbors(ix1)
	@test nbrs isa NTuple{I, 6}
	test_valid_and_equal(I, nbrs[1], (2, 2))
	test_valid_and_equal(I, nbrs[1], (1, 3))
	test_valid_and_equal(I, nbrs[1], (0, 3))
	test_valid_and_equal(I, nbrs[1], (0, 2))
	test_valid_and_equal(I, nbrs[1], (1, 1))
	test_valid_and_equal(I, nbrs[1], (2, 1))

	for nbr in nbrs
		@test isneighbor(ix1, nbr)
	end

	@test !isneighbor(ix1, ix2)
	@test !isneighbor(ix1, ix1)

	# hexdist
	@test hexdist(zero(I) == 0)
	@test hexdist(ix1) == 3
	@test hexdist(ix2) == 4
	@test hexdist(ix1, ix2) == 6
	@test hexdist(ix2, ix1) == 6
end


function test_vector_index(I::Type{<:VectorHexIndex})
	origin = I(AxialIndex())
	ix1 = I(AxialIndex(1, 2))
	ix2 = I(AxialIndex(3, -4))

	# Math
	test_valid_and_equal(I, -ix1, (-1, -2))
	test_valid_and_equal(I, ix1 + ix2, (4, -2))
	test_valid_and_equal(I, ix1 - ix2, (-2, 6))
	test_valid_and_equal(I, ix1 * 2, (2, 4))
	test_valid_and_equal(I, 2 * ix1, (2, 4))

	# Zero
	test_valid_and_equal(I, zero(I), (0, 0))

	# Axes
	ax = hexaxes(I)
	@test length(ax) == 3

	test_valid_and_equal(I, ax[1], (1, 0))
	test_valid_and_equal(I, ax[2], (1, -1))
	test_valid_and_equal(I, ax[3], (0, -1))

	# hexaxes() + -hexaxes() form a ring around the origin
	ax2 = vcat(ax, .-ax)
	@test neighbors(origin) == ax2

	for i in 1:6
		# Adjacent neighbors
		a1 = ax2[i]
		a2 = ax2[1 + (i % 6)]

		@test isneighbor(origin, a1)
		@test isneighbor(origin, a2)
		@test isneighbor(a1, a2)
	end
end


@testset "CubeIndex" begin
	# Type traits
	@test Base.IteratorSize(CubeIndex) === Base.HasLength()
	@test eltype(CubeIndex) === Int

	# Constructor
	tup = (1, 2, -3)
	ix = CubeIndex(tup)
	@test CubeIndex(tup...) === ix
	@test CubeIndex(tup[1], tup[2]) === ix
	@test CubeIndex(ix) === ix
	@test CubeIndex() === CubeIndex(0, 0, 0)

	# Tuple-like behavior
	test_tuple_wrapper(CubeIndex(), (0, 0, 0))
	test_tuple_wrapper(ix, tup)

	# Validity
	@test validindex(CubeIndex(0, 0, 0))
	@test validindex(CubeIndex(1, 2, -3))
	@test !validindex(CubeIndex(1, 2, 3))

	# Vector
	test_vector_index(CubeIndex)
end


@testset "AxialIndex" begin
	# Type traits
	@test Base.IteratorSize(AxialIndex) === Base.HasLength()
	@test eltype(AxialIndex) === Int

	# Constructor
	tup = (1, 2)
	ix = AxialIndex(tup)
	@test AxialIndex(tup...) === ix
	@test AxialIndex(ix) === ix
	@test AxialIndex() === AxialIndex(0, 0)

	# Tuple-like behavior
	test_tuple_wrapper(AxialIndex(), (0, 0))
	test_tuple_wrapper(ix, tup)

	# Validity (always valid)
	@test validindex(ix)

	# Vector
	test_vector_index(AxialIndex)
end


@testset "conversion" begin
	aix = AxialIndex(1, 2)
	cix = CubeIndex(1, 2, -3)
	@test convert(CubeIndex, aix) === cix
	@test convert(AxialIndex, cix) === aix
end


@testset "promotion" begin
	left = AxialIndex(1, 2)
	right = AxialIndex(2, -3)
	expect_sum = AxialIndex(3, -1)
	expect_diff = AxialIndex(-1, 5)

	left_types = [AxialIndex, CubeIndex]
	right_types = [AxialIndex, CubeIndex]

	for L in left_types
		for R in right_types
			@test convert(L, left) == convert(R, left)

			left2 = convert(L, left)
			right2 = convert(R, right)
			test_valid_and_equal(L, left2 + right2, expect_sum)
			test_valid_and_equal(L, left2 - right2, expect_diff)
		end
	end
end
