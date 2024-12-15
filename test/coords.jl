using Random
using StaticArrays

using HexGrids: CoordinateSystem, AxialCoords, CubeCoords, CartesianCoords
using HexGrids: convertcoords, convertcoords!, center, centers, centers!

const AxC = AxialCoords()
const CuC = CubeCoords()
const CaC = CartesianCoords()

const COORDTYPES = [AxialCoords(), CubeCoords(), CartesianCoords()]

const ATOL = 1e-6


# Check conversion returns a static vector of correct type
function test_convert(s1::CoordinateSystem, s2::CoordinateSystem, value::AbstractVector)
	converted = @inferred convertcoords(s1, s2, value)
	@test converted isa SVector
	@test eltype(converted) == promote_type(eltype(value), Float32)
	return converted
end


# Test conversion of single coordinate vectors
@testset "vector conversion" begin

	# Quick axial/cube
	@test convertcoords(AxC, CuC, [1.2, -4.9]) ≈ [1.2, -4.9, 3.7]
	@test convertcoords(CuC, AxC, [1.2, -4.9, 3.7]) == [1.2, -4.9]

	# Check axial basis vectors to Cartesian (0 and -60 degrees from x axis)
	basis1 = [1, 0]
	basis2 = [0, 1]
	basis1_cart = convertcoords(AxC, CaC, basis1)
	basis2_cart = convertcoords(AxC, CaC, basis2)

	@test basis1_cart == [1, 0]
	@test basis2_cart ≈ [cosd(-60), sind(-60)]

	# Check linearity
	a = 2.6
	b = -4.1
	expect = a .* basis1_cart .+ b .* basis2_cart
	@test convertcoords(AxC, CaC, [a, b]) ≈ expect atol=ATOL

	# Check random cartesian coords
	Random.seed!(0)
	for _ in 1:10
		cart = randn(2)
		axial = Vector(test_convert(CaC, AxC, cart))
		cube = Vector(test_convert(CaC, CuC, cart))

		@test test_convert(AxC, CaC, axial) ≈ cart atol=ATOL
		@test test_convert(CuC, CaC, cube) ≈ cart atol=ATOL

		@test test_convert(AxC, CuC, axial) ≈ cube atol=ATOL
		@test test_convert(CuC, AxC, cube) ≈ axial atol=ATOL

		@test test_convert(AxC, AxC, axial) == axial
		@test test_convert(CuC, CuC, cube) == cube
		@test test_convert(CaC, CaC, cart) == cart
	end
end


# Test coordinate conversion of matrices
@testset "matrix conversion" begin
	n = 20
	Random.seed!(0)
	cartesian = randn(2, n)

	for c1 in COORDTYPES
		mat1 = convertcoords(CaC, c1, cartesian)
		@test size(mat1, 2) == n

		for c2 in COORDTYPES
			mat2 = convertcoords(c1, c2, mat1)
			@test size(mat2, 2) == n
			expected = mapslices(v -> convertcoords(c1, c2, v), mat1, dims=1)
			@test mat2 ≈ expected

			out = Array{eltype(mat2)}(undef, size(mat2))
			@test convertcoords!(out, c1, c2, mat1) === out
			@test out == mat2
		end
	end
end


# Test hexaxes() for coordinate systems
@testset "hexaxes" begin

	cart_axes = @inferred hexaxes(CaC)
	axial_axes = @inferred hexaxes(AxC)
	cube_axes = @inferred hexaxes(CuC)

	# Check cartesian corresponds to intended geometry
	for i in 1:3
		angle = 60 * (i - 1)
		@test cart_axes[:, i] ≈ [cosd(angle), sind(angle)] atol=ATOL
	end

	# Check others are conversions of cartesian
	@test axial_axes ≈ convertcoords(CaC, AxC, cart_axes) atol=ATOL
	@test cube_axes ≈ convertcoords(CaC, CuC, cart_axes) atol=ATOL
end


# Check center() returns a static vector of correct type
function test_center(s::CoordinateSystem, ix::HexIndex)
	value = @inferred center(s, ix)
	@test value isa SVector
	@test eltype(value) == Float32
	return value
end

@testset "center" begin
	cix = CubeIndex(3, 7)

	for I in [AxialIndex, CubeIndex]
		ix = I(cix)

		axial = test_center(AxC, ix)
		@test axial == [cix[1], cix[2]]

		cube = test_center(CuC, ix)
		@test cube == [cix[1], cix[2], cix[3]]

		cart = test_center(CaC, ix)
		@test cart ≈ convertcoords(AxC, CaC, axial) atol=ATOL

		# Check corresponds to hexaxes()
		for C in COORDTYPES
			ax_coords = hexaxes(C)
			for (i, ax) in enumerate(hexaxes(I))
				@test center(C, ax) ≈ ax_coords[:, i] atol=ATOL
			end
		end
	end
end


@testset "centers" begin
	for I in [AxialIndex, CubeIndex]
		ixs = collect(HexagonShape{I}(3))
		n = length(ixs)

		for C in COORDTYPES
			a = centers(C, ixs)
			@test a isa Matrix{Float32}
			@test size(a, 2) == n
			@test all(a[:, i] == center(C, ixs[i]) for i in 1:n)

			out = similar(a)
			@test centers!(out, C, ixs) === out
			@test out == a
		end
	end
end
