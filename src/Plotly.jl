"""
Utilities for plotting hex array data with PlotlyJS.
"""
module Plotly

export hex_scatter, hex_plot

# Methods only defined when PlotlyExt extension is loaded

"""
	hex_scatter(a::HexArray, extra=(;); kw...)

Create a scatter trace for a [HexArray](@ref) with each cell colored by value.
"""
function hex_scatter end

"""
	hex_plot(a::HexArray, trace_kw=(;), layout_kw=(;))

Create a full Plotly plot object for a [HexArray](@ref).
"""
function hex_plot end


end  # Module Plotly
