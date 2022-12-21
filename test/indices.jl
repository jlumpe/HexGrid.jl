

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


@testset "CubeIndex" begin
	# Type traits
	@test Base.IteratorSize(CubeIndex) === Base.HasLength()
	@test eltype(CubeIndex) === Int

	# Constructor
	origin = CubeIndex()
	@test origin === CubeIndex(0, 0, 0)
	@test CubeIndex(origin) === origin
	@test CubeIndex(1, 2) === CubeIndex(1, 2, -3)

	# Tuple-like behavior
	test_tuple_wrapper(CubeIndex(), (0, 0, 0))
	test_tuple_wrapper(CubeIndex(1, 2, -3), (1, 2, -3))

	# Validity
	@test validindex(CubeIndex(0, 0, 0))
	@test validindex(CubeIndex(1, 2, -3))
	@test !validindex(CubeIndex(1, 2, 3))

end


@testset "AxialIndex" begin
	# Type traits
	@test Base.IteratorSize(AxialIndex) === Base.HasLength()
	@test eltype(AxialIndex) === Int

	# Constructor
	origin = AxialIndex()
	@test origin === AxialIndex(0, 0)
	@test AxialIndex(origin) === origin

	# Tuple-like behavior
	test_tuple_wrapper(AxialIndex(), (0, 0))
	test_tuple_wrapper(AxialIndex(1, 2), (1, 2))

end
