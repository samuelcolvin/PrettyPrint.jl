module PrettyPrint
	export @>, @>>
	NAME_LENGTH   =  60
	SHORT_LENGTH  = 65
	LONG_LENGTH   = 400
	INDENT_LENGTH = 5

	function curtail(value::String, len::Int)
		length(value) > len ? string(value[1:(len - 3)], "...") : value
	end

	function short(value::String)
		"($(summary(value))): " * curtail(repr(value), SHORT_LENGTH)
	end

	function short(value::Dict)
		replace(replace(curtail(string(value), SHORT_LENGTH), "\n", " "), "   ", " ")
	end

	function short(value)
		# this avoids having to import DataFrames
		if string(typeof(value)) == "DataFrame"
			return shortdf(value)
		end
		"($(summary(value))): " * replace(curtail(string(value), SHORT_LENGTH), "\n", " ")
	end

	function shortdf(value)
		"$(summary(value))"
	end

	function shortname(io::IO, name, len=NAME_LENGTH)
		name = string(name)
		if length(name) > len
			l1 = int(len/2) - 2
			l2 = l1 - 1
			name = string(name[1:l1], "...", name[end-l2:end])
		end
		print(io, name)
	end

	function indent(s::String, padding::Int = INDENT_LENGTH)
		first = true
		function indentline(s::String)
			start = first ? "" : " " ^ padding
			first = false
			start * s
		end
		if !in('\n', s)
			return s
		else
			return join(map(indentline, split(s, "\n")), "\n")
		end
	end

	function long(value::String)
		indent("($(summary(value))):\n" * curtail(value, LONG_LENGTH) * "\nraw string:\n  " * curtail(repr(value), LONG_LENGTH))
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
		indent(curtail(vstr, LONG_LENGTH))
	end

	function longdf(value)
		sio = IOBuffer()
		show(sio, value)
		vstr = takebuf_string(sio)
		close(sio)
		vstr
	end

	# simple debug print
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
