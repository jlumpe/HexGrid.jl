

@testset "HexagonShape" begin

	# Constructor
	@test HexagonShape(3) === HexagonShape{AxialIndex}(3)
	@test_throws ArgumentError HexagonShape(0)

	# Shape with n=2 (7 cells)
	shape = HexagonShape(2)
	@test length(shape) == 7
	@test eltype(shape) === AxialIndex

	expected_idxs = map(AxialIndex, [(0, 0), (-1, 0), (1, 0), (0, -1), (0, 1), (-1, 1), (1, -1)])
	@test issetequal(collect(shape), expected_idxs)

	for ix in expected_idxs
		@test ix in shape
		@test validindex(shape, ix)
		ix2 = CubeIndex(ix)
		@test !(ix2 in shape)
		@test validindex(shape, ix2)
	end

	@test !(AxialIndex(2, 0) in shape)
	@test !validindex(shape, AxialIndex(2, 0))

	expected_neighbors = map(AxialIndex, [(0, 0), (0, 1), (1, -1)])
	@test issetequal(neighbors(shape, AxialIndex(1, 0)), expected_neighbors)

	# Reindexing
	shape2 = reindex(shape, CubeIndex)
	@test shape2 === HexagonShape{CubeIndex}(shape.n)
	@test eltype(shape2) === CubeIndex
	@test issetequal(shape2, map(CubeIndex, expected_idxs))

end