"""
Test basic array attributes.
"""
function test_basic(array::HexArray{T}) where T
	n = length(array)
	shape = ArrayShape(array)

	@test eltype(array) === eltype(typeof(array)) === T
	@test keytype(array) === keytype(typeof(array)) === eltype(shape)
	@test Base.IteratorSize(typeof(array)) === Base.HasLength()

	@test length(shape) == n
	@test keys(array) === shape
end


"""
Test reading from/writing to array.

# Arguments
- `I`: index type to use.
- `f`: function of integer index `i` to generate value to write to array.
"""
function test_readwrite(array::HexArray{T}, I=nothing, f=identity) where T
	for (i, ix) in enumerate(keys(array))
		if !isnothing(I)
			ix = convert(I, ix)
		end

		# Check index
		@test checkbounds(Bool, array, ix)
		checkbounds(array, ix)

		# Write
		v = f(i)
		array[ix] = v

		# Read
		v2 = @inferred array[ix]
		@test v2 isa T
		@test v2 == convert(T, v)

		# get()
		got = @inferred Nothing get(array, ix, nothing)
		@test got == v2
	end
end


function test_iterate(array::HexArray{T}, f=nothing) where T
	indices = collect(keys(array))
	values = collect(array)
	@test length(values) == length(indices) == length(array)

	for i in 1:length(array)
		v = isnothing(f) ? array[indices[i]] : convert(T, f(i))
		@test values[i] isa T
		@test values[i] == v
	end
end


"""
Test invalid index.
"""
function test_invalid_index(array::HexArray{T}, ix::HexIndex) where T
	@test ix ∉ keys(array)

	@test !checkbounds(Bool, array, ix)
	@test_throws BoundsError checkbounds(array, ix)
	@test_throws BoundsError array[ix]

	got = @inferred Nothing get(array, ix, nothing)
	@test isnothing(got)
end


function test_is_hexagonarray(a, eltype=nothing, shape=nothing)
	A = isnothing(eltype) ? HexagonArray : HexagonArray{eltype}
	@test a isa A
	isnothing(shape) || @test ArrayShape(a) === shape
end


@testset "HexagonArray" begin
	n = 3
	T = Float32
	shape = HexagonShape(n)

	# Construct from shape
	a = HexagonArray{T}(shape)
	test_is_hexagonarray(a, T, shape)

	# Construct from n
	test_is_hexagonarray(HexagonArray{T}(n), T, shape)

	# Construct using HexArray{T}(shape)
	test_is_hexagonarray(HexArray{T}(shape), T, shape)

	# similar()
	shape2 = HexagonShape(4)
	test_is_hexagonarray(similar(a), T, shape)
	test_is_hexagonarray(similar(a, shape2), T, shape2)
	test_is_hexagonarray(similar(a, Int), Int, shape)
	test_is_hexagonarray(similar(a, Int, shape2), Int, shape2)

	test_basic(a)

	for I in [AxialIndex, CubeIndex]
		test_readwrite(a, I)
		test_invalid_index(a, I(AxialIndex(n + 1, 0)))
	end

	# Test fill
	fill_val = 42
	@test fill!(a, fill_val) == a
	@test all(==(fill_val), a)
end
