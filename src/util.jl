"""
Add Base methods for type which wraps an ntuple.
"""
macro tuplewrapper(typename, field::Symbol, n::Int, eltype)

	if !(typename isa Symbol || Meta.isexpr(typename, :.))
		error("Type name must be a Symbol or dotted expression")
	end

	T = esc(typename)
	E = esc(eltype)
	xtuple = :(x.$field)

	quote
		Tuple(x::$T) = $xtuple

		Base.IteratorSize(::Type{$T}) = Base.HasLength()
		Base.eltype(::Type{$T}) = $E
		Base.length(::$T) = $n
		Base.iterate(x::$T, state...) = iterate($xtuple, state...)

		Base.firstindex(::$T) = 1
		Base.lastindex(::$T) = $n
		Base.getindex(x::$T, i) = $xtuple[i]

	end
end


function show_tuple_wrapper(io::IO, x)
	print(io, typeof(x), "(")
	join(io, x, ", ")
	print(io, ")")
end


"""
Implementation of `Base.Iterate(x, state)` where we just create a proxy object to iterate over
instead. `state` is a tuple of `(proxy[, proxy_state])` where `proxy` is the proxy object.
The intial value should just be `(proxy,)`.
"""
function iterate_proxy(f::Function, state::Tuple)
	proxy, pstate... = state
	result = iterate(proxy, pstate...)
	isnothing(result) && return nothing
	val, next = result
	return f(val), (proxy, next)
end

iterate_proxy(state::Tuple) = iterate_proxy(identity, state)
