function test_basic(array::HexArray, I=nothing; f=identity)

	n = length(array)
	shape = ArrayShape(array)

	@test n == length(shape)

	if !isnothing(I)
		shape = reindex(I, shape)
	end

	# Write values to array
	for (i, ix) in enumerate(shape)
		v = f(i)
		array[ix] = v
	end

	# Read from array
	for (i, ix) in enumerate(shape)
		v = f(i)
		@test array[ix] == v
	end
end


@testset "HexagonArray" begin
	a = HexagonArray{Float32}(5)
	test_basic(a)
end
