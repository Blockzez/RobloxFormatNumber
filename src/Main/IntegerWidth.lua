local _internal = require(script.Parent.Parent._internal)

local IntegerWidth = { }
local IntegerWidth_methods = { }
local IntegerWidth_new = _internal.class.create_init_function(
	"IntegerWidth",
	nil,
	IntegerWidth_methods, nil,
	_internal.class.ImmutabilityType.DEFAULT
)

function IntegerWidth_methods.TruncateAt(self: IntegerWidth, maxInt: number): IntegerWidth
	local c_self = _internal.class.try_coerce(1, self, "IntegerWidth")

	if tonumber(maxInt) and math.ceil(maxInt) == -1 then
		-- special case
		maxInt = -1
	else
		maxInt = _internal.class.try_coerce_range(1, maxInt, c_self.min, 999)
	end

	return IntegerWidth_new({
		min = c_self.min,
		max = maxInt,
	})
end


function IntegerWidth.zeroFillTo(minInt: number): IntegerWidth
	minInt = _internal.class.try_coerce_range(1, minInt, 0, 999)

	return IntegerWidth_new({
		min = minInt,
		max = -1,
	})
end

export type IntegerWidth = {
	TruncateAt: typeof(IntegerWidth_methods.TruncateAt),
}
return table.freeze(IntegerWidth)