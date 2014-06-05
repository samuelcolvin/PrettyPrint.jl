using PrettyPrint
# using Base.Test

a=[1,2,3,4]
@> a
@>> a
@> Int64[1:100]
b=1
@> b
@> b += 1
@> b
# actually this does happen, not with long variable names but with long expressions
veryveryveryveryveryveryveryveryveryveryveryveryvery_long_variable_name = 42
@> veryveryveryveryveryveryveryveryveryveryveryveryvery_long_variable_name

b=nothing
othervar = :symname
func1(a,b) = a + b
bigmat = eye(100)
compl = 4 + 2.12312312im
@> b othervar func1 bigmat compl
@>> b othervar func1 bigmat compl

longstr = "this is a longish string \nwith new lines in it \n and unicode characters π \r\netc.\tetc."
dict_example = ["key"=>"value", 8=>2.3, (1,2)=>(3,4)]
regexexpr = r"[a-z]*.*?hello"
@> longstr dict_example regexexpr
@>> longstr dict_example regexexpr

@> 2^2
x=1
y=2
@> x+y

type TestType
	onething::String
	antherthing::Int
	thirdthing::Union(Nothing, String)
end

tt = TestType("hello", 42, "world")
@show tt
@> tt
@>> tt

# using DataFrames
# using RDatasets
# iris = dataset("datasets", "iris")
# @> iris
# @>> iris