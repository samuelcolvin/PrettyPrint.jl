module PrettyPrint
	export @>, @>>, printbacktrace, pbt
	NAME_LENGTH   =  60
	SHORT_LENGTH  = 65
	LONG_LENGTH   = 5000
	INDENT_LENGTH = 5

	function curtail(value::String, len::Int)
		length(value) > len ? string(value[1:(len - 3)], "...") : value
	end

	function short(value::String)
		" ($(summary(value))): " * curtail(repr(value), SHORT_LENGTH)
	end

	function short(value::Union(Dict, AbstractArray))
		replace(replace(curtail(string(value), SHORT_LENGTH), "\n", " "), "   ", " ")
	end

	function short(value)
		# avoid having to import DataFrames
		isdefined(Main, :DataFrame) && isa(value, Main.DataFrame) ? 
			": $(summary(value))" :
			" ($(summary(value))): " * replace(curtail(string(value), SHORT_LENGTH), "\n", " ")
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
			start = first ? " " : " " ^ padding
			first = false
			start * s
		end
		if !in('\n', s)
			return " " * s
		else
			return join(map(indentline, split(s, "\n")), "\n")
		end
	end

	function long(value::String)
		indent("($(summary(value))):\n" * curtail(value, LONG_LENGTH) * "\nraw string:\n  " * curtail(repr(value), LONG_LENGTH))
	end

	long(value::Union(Dict, AbstractArray)) = longvalue(value)

	function long(value)
		isdefined(Main, :DataFrame) && isa(value, Main.DataFrame) ? 
			":" * longvalue(value) :
			" ($(summary(value))):" * longvalue(value)
		end

	longvalue(value) = indent(curtail(stringmime("text/plain", value), LONG_LENGTH))

	# simple debug print
	macro >(exs...)
	    blk = Expr(:block)
	    for ex in exs
	        push!(blk.args, :(println($(sprint(shortname,ex)), short(begin value=$(esc(ex)) end))))
	    end
		# if !isempty(exs); push!(blk.args, :value); end
	    return blk
	end

	# more verbose debug print
	macro >>(exs...)
	    blk = Expr(:block)
	    for ex in exs
	        push!(blk.args, :(println($(sprint(shortname,ex)), long(begin value=$(esc(ex)) end))))
	    end
		# if !isempty(exs); push!(blk.args, :value); end
	    return blk
	end

	function printbacktrace(name::Union(String, Nothing)=nothing)
		tb = backtrace()
		name == nothing ? println("Backtrace:") : println("$name Backtrace:")
		for ptr in tb
		    lkup = ccall(:jl_lookup_code_address, Any, (Ptr{Void},Cint), ptr, true)
	        lkup === () && continue
	        fname, file, line, fromc = lkup
	        # println(repr(fname))
	        (in(fname, [:printbacktrace, :pbt]) || fromc) && continue
		    println(" " ^ INDENT_LENGTH, "in $fname at $file:$line")
		end
	end

	pbt(args...) = printbacktrace(args...)
end
