module PrettyPrint
	export @>, @>>
	# simple debug print
	CENTER_LINE = 18

	function curtail(value::String, len::Int)
		length(value) > len ? string(value[1:(len - 3)], "...") : value
	end

	function short(value::String)
		"($(summary(value))): " * curtail(repr(value), 65)
	end

	function short(value::Dict)
		" " * replace(curtail(string(value), 65), "\n", " ")
	end

	function short(value)
		# this avoids having to import DataFrames
		if string(typeof(value)) == "DataFrame"
			return shortdf(value)
		end
		"($(summary(value))): " * replace(curtail(string(value), 65), "\n", " ")
	end

	function shortdf(value)
		"$(summary(value))"
	end

	function shortname(io::IO, name, len=CENTER_LINE)
		name = string(name)
		if length(name) > len
			l1 = int(len/2) - 2
			l2 = l1 - 1
			name = string(name[1:l1], "...", name[end-l2:end])
		end
		print(io, lpad(name, len))
	end

	function indent(s::String, padding::Int = CENTER_LINE + 2)
		first = true
		function indentline(s::String)
			line = first ? s : string(" " ^ padding, s)
			first = false
			return line
		end
		if !in('\n', s)
			return s
		else
			return join(map(indentline, split(s, "\n")), "\n")
		end
	end

	function long(value::String)
		indent("($(summary(value))): " * curtail(value, 200) * "\nraw string:\n  " * curtail(repr(value), 200))
	end

	function long(value)
		if string(typeof(value)) == "DataFrame"
			return longdf(value)
		end
		sio = IOBuffer()
		if !isa(value, Dict)
			print(sio, "($(summary(value))):\n")
		end
		writemime(sio, "text/plain", value)
		vstr = takebuf_string(sio)
		close(sio)
		indent(curtail(vstr, 200))
	end

	function longdf(value)
		sio = IOBuffer()
		show(sio, value)
		vstr = takebuf_string(sio)
		close(sio)
		vstr
	end


	macro >(exs...)
	    blk = Expr(:block)
	    for ex in exs
	        push!(blk.args, :(println($(sprint(shortname,ex))*" ", short(begin value=$(esc(ex)) end))))
	    end
		# if !isempty(exs); push!(blk.args, :value); end
	    return blk
	end

	# more verbose debug print
	macro >>(exs...)
	    blk = Expr(:block)
	    for ex in exs
	        push!(blk.args, :(println($(sprint(shortname,ex))*" ", long(begin value=$(esc(ex)) end))))
	    end
		# if !isempty(exs); push!(blk.args, :value); end
	    return blk
	end
end
