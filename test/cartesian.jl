using HexGrids: axial2cart, axial2cart!, cart2axial, cart2axial!


"""
Test HexIndex to cartesian conversion.
"""
function test_index_cartesian(I::Type{<:HexIndex})
	center = AxialIndex(4, -7)
	cx, cy = cartesian(center)

	for (i, ax) in enumerate(hexaxes(AxialIndex))
		ix = I(ax)

		angle = (i - 1) * 60
		ey, ex = sincosd(angle)

		# Test basic axis directions
		x, y = cartesian(ix)
		@test isapprox(x, ex)
		@test isapprox(y, ey)

		# Test summed indices have summed coordinates
		ix2 = I(center + ax)
		x2, y2 = cartesian(ix2)
		@test isapprox(x2, cx + ex)
		@test isapprox(y2, cy + ey)
	end

	# Test array version
	ax_array = hexaxes(I) .+ I(center)
	xy_array = cartesian(ax_array)
	@test size(xy_array) == (2, length(ax_array))

	for (i, ix) in enumerate(ax_array)
		@test xy_array[:, i] == cartesian(ix)
	end
end


@testset "CubeIndex" begin
	test_index_cartesian(CubeIndex)
end


@testset "AxialIndex" begin
	test_index_cartesian(AxialIndex)
end


@testset "array" begin
	# TODO
end
