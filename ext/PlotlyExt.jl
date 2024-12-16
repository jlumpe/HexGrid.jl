# The extension only adds methods for functions defined in HexGrids.Plotly

module PlotlyExt

using PlotlyJS

using HexGrids
import HexGrids.Plotly: hex_scatter, hex_plot


function hex_scatter(a::HexArray, extra=(;); kw...)
	xy = HexGrids.cartesian(a.shape)
	trace = scatter(
		mode=:markers,
		x=xy[1, :],
		y=xy[2, :],
		marker_color=collect(a),
		text=[string(CubeIndex(ix).I) for ix in a.shape],
		hovertemplate="%{text}: %{marker.color}",
	)
	merge!(trace, attr(extra))
	merge!(trace, attr(kw...))
end


function hex_plot(a::HexArray, trace_kw=(;), layout_kw=(;); kw...)
	scatter = hex_scatter(a, trace_kw; kw...)
	layout = Layout(yaxis=attr(scaleanchor=:x, scaleratio=1))
	merge!(layout, attr(layout_kw))
	return plot([scatter], layout)
end


end  # Module PlotlyExt
