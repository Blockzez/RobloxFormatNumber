local _internal = require(script.Parent.Parent._internal)

local DecimalFormatSymbols = { }
local DecimalFormatSymbols_methods = { }
local DecimalFormatSymbols_new = _internal.class.create_init_function(
	"DecimalFormatSymbols", nil,
	DecimalFormatSymbols_methods, nil,
	_internal.class.ImmutabilityType.SYMBOLS
)

function DecimalFormatSymbols_methods.GetSymbol(self: DecimalFormatSymbols, symbol: number): string
	local c_self = _internal.class.try_coerce(1, self, "DecimalFormatSymbols")
	symbol = _internal.class.try_coerce_enum(2, symbol, _internal.enums.ENumberFormatSymbols)

	return c_self[symbol]
end

function DecimalFormatSymbols_methods.SetSymbol(self: DecimalFormatSymbols, symbol: number, value: string)
	local c_self = _internal.class.try_coerce(1, self, "DecimalFormatSymbols")
	symbol = _internal.class.try_coerce_enum(2, symbol, _internal.enums.ENumberFormatSymbols)
	value = _internal.class.try_coerce(3, value, "string")

	c_self[symbol] = value
end


function DecimalFormatSymbols.createWithLastResortData(): DecimalFormatSymbols
	return DecimalFormatSymbols_new({
		[_internal.enums.ENumberFormatSymbols.kDecimalSeparatorSymbol] = ".",
		[_internal.enums.ENumberFormatSymbols.kGroupingSeparatorSymbol] = "",
		[_internal.enums.ENumberFormatSymbols.kMinusSignSymbol] = "-",
		[_internal.enums.ENumberFormatSymbols.kPlusSignSymbol] = "+",
		[_internal.enums.ENumberFormatSymbols.kExponentialSymbol] = "E",
		[_internal.enums.ENumberFormatSymbols.kInfinitySymbol] = "∞",
		[_internal.enums.ENumberFormatSymbols.kNaNSymbol] = "\u{FFFD}",
	})
end

export type DecimalFormatSymbols = {
	GetSymbol: typeof(DecimalFormatSymbols_methods.GetSymbol),
	SetSymbol: typeof(DecimalFormatSymbols_methods.SetSymbol),
}
return table.freeze(DecimalFormatSymbols)