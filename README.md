# PrettyPrint

[![Build Status](https://travis-ci.org/samuelcolvin/PrettyPrint.jl.svg?branch=master)](https://travis-ci.org/samuelcolvin/PrettyPrint.jl)

Extremely simple package to print variables with their names, very similar to `show` but with prettier printing

    @> var  # prints a short description of var
    @>> var # prints a slightly long description of var

Examples:

	using PrettyPrint

	a=[1,2,3,4]
	@> a
	@>> a
	@> Int64[1:100]
	veryveryvery_long_variable_name = 42
	@> veryveryvery_long_variable_name

	b=nothing
	othervar = :symname
	func1(a,b) = a + b
	bigmat = eye(100)
	compl = 4 + 2.12312312im
	@> b othervar func1 bigmat compl
	@>> b othervar func1 bigmat compl
	

Should start using

    tb = backtrace()
    for ptr in tb
        lkup = ccall(:jl_lookup_code_address, Any, (Ptr{Void},Cint), ptr, true)
        println(lkup)
    end
