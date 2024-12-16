using HexGrids: reindex


"""
Test container-like aspects of a HexShape:

- Iteration gives unique, valid indices of type I.
- Total iterated matches length.
- in()
"""
function test_shape_container(shape::HexShape{I}) where I
	@test eltype(shape) === I

	seen = Set{I}()

	for ix in shape
		@test ix isa I
		@test validindex(ix)
		@test ix ∉ seen
		push!(seen, ix)
	end

	@test length(seen) == length(shape)
end


@testset "HexagonShape" begin

	# Default index type
	@test HexagonShape(3) === HexagonShape{AxialIndex}(3)
	# Size must be positive
	@test_throws ArgumentError HexagonShape(0)

	# Different index types and sizes
	for I in [CubeIndex, AxialIndex]
		for n in [1, 3, 6]
			s = HexagonShape{I}(n)
			test_shape_container(s)

			# One past the "tip" of hexagon on axis 1
			ax1 = hexaxes(I, 1)
			@test (ax1 * n) ∉ s
		end
	end

	# Text neighbors
	s = HexagonShape{AxialIndex}(3)

	# Cell 1 on edge
	ix1 = AxialIndex(2, -1)
	@test ix1 in s
	nbrs1 = collect(neighbors(s, ix1))
	expected1 = AxialIndex.([(2, -2), (1, -1), (1, 0), (2, 0)])
	@test issetequal(nbrs1, expected1)

	# Cell 2 outside edge
	ix2 = AxialIndex(3, -1)
	@test ix2 ∉ s
	nbrs2 = collect(neighbors(s, ix2))
	expected2 = AxialIndex.([(2, -1), (2, 0)])
	@test issetequal(nbrs2, expected2)

	# Cell 3 further outside
	ix3 = AxialIndex(4, -1)
	@test ix3 ∉ s
	@test isempty(neighbors(s, ix3))

	# Reindexing
	@test reindex(AxialIndex, s) === s
	@test reindex(CubeIndex, s) === HexagonShape{CubeIndex}(3)
end
