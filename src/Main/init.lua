local _internal = require(script.Parent._internal)
local Notation = require(script.Notation)
local Precision = require(script.Precision)
local IntegerWidth = require(script.IntegerWidth)
local DecimalFormatSymbols = require(script.DecimalFormatSymbols)

local enums = _internal.enums

export type Notation = Notation.Notation
export type ScientificNotation = Notation.ScientificNotation
export type Precision = Precision.Precision
export type FractionPrecision = Precision.FractionPrecision
export type IntegerWidth = IntegerWidth.IntegerWidth
export type DecimalFormatSymbols = DecimalFormatSymbols.DecimalFormatSymbols

local NumberFormatter = { }
local NumberFormatter_methods = { }
local NumberFormatter_new = _internal.class.create_init_function(
	"NumberFormatter", nil,
	NumberFormatter_methods, nil,
	_internal.class.ImmutabilityType.NUMBER_FORMATTER
)

function NumberFormatter_methods.Notation(self: NumberFormatter, notation: Notation): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	notation = _internal.class.try_coerce(2, notation, "Notation")

	return NumberFormatter_new({
		key = "notation",
		value = notation,
		parent = _internal.class.get_data(self),
	})
end
function NumberFormatter_methods.Precision(self: NumberFormatter, precision: Precision): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	precision = _internal.class.try_coerce(2, precision, "Precision")

	return NumberFormatter_new({
		key = "precision",
		value = precision,
		parent = _internal.class.get_data(self),
	})
end
function NumberFormatter_methods.RoundingMode(self: NumberFormatter, roundingMode: number): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	roundingMode = _internal.class.try_coerce_enum(2, roundingMode, enums.RoundingMode)

	return NumberFormatter_new({
		key = "roundingMode",
		value = roundingMode,
		parent = _internal.class.get_data(self),
	})
end
function NumberFormatter_methods.Grouping(self: NumberFormatter, strategy: number): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	strategy = _internal.class.try_coerce_enum(2, strategy, enums.GroupingStrategy)

	return NumberFormatter_new({
		key = "grouping",
		value = strategy,
		parent = _internal.class.get_data(self),
	})
end
function NumberFormatter_methods.IntegerWidth(self: NumberFormatter, style: IntegerWidth): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	style = _internal.class.try_coerce(2, style, "IntegerWidth")

	return NumberFormatter_new({
		key = "integerWidth",
		value = style,
		parent = _internal.class.get_data(self),
	})
end
function NumberFormatter_methods.Symbols(self: NumberFormatter, symbols: DecimalFormatSymbols): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	symbols = _internal.class.try_coerce(2, symbols, "DecimalFormatSymbols")

	return NumberFormatter_new({
		key = "symbols",
		value = symbols,
		parent = _internal.class.get_data(self),
	})
end
function NumberFormatter_methods.Sign(self: NumberFormatter, style: number): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	style = _internal.class.try_coerce_enum(2, style, enums.SignDisplay)

	return NumberFormatter_new({
		key = "sign",
		value = style,
		parent = _internal.class.get_data(self),
	})
end
function NumberFormatter_methods.Decimal(self: NumberFormatter, style: number): NumberFormatter
	_internal.class.try_coerce(1, self, "NumberFormatter")
	style = _internal.class.try_coerce_enum(2, style, enums.DecimalSeparatorDisplay)

	return NumberFormatter_new({
		key = "decimal",
		value = style,
		parent = _internal.class.get_data(self),
	})
end

local function resolve_nf_data(data)
	return _internal.formatter_settings.resolve_settings(
		_internal.formatter_settings.linked_list_to_dict(data)
	)
end

function NumberFormatter_methods.Format(self: NumberFormatter, value: number): string
	local result
	local internal_settings
	local symbols
	local is_negt, is_zero
	local display_sign

	_internal.class.try_coerce(1, self, "NumberFormatter")
	if type(value) == "string" then
		error("Argument #2 as a string interpreted as decimal is not currently supported, please cast the argument to a double if you want the string to be interpreted as a double", 2)
	end
	value = _internal.class.try_coerce(2, value, "number")

	internal_settings = _internal.class.get_resolved_data(self, resolve_nf_data)
	symbols = internal_settings.symbols

	-- special values
	if value ~= value then
		-- Sign bit detection for NaN
		-- NaN payload ignored
		is_negt = string.byte(string.pack(">d", value)) >= 0x80
		-- intentionally set to true
		is_zero = true
		result = symbols[enums.ENumberFormatSymbols.kNaNSymbol]
	elseif value == math.huge or value == -math.huge then
		is_negt = value < 0
		is_zero = false
		result = symbols[enums.ENumberFormatSymbols.kInfinitySymbol]
	else
		local fmt, fmt_n, decimal_marker

		if value == 0 then
			is_negt = math.atan2(value, -1) < 0
			fmt, fmt_n, decimal_marker = nil, 0, 1
		else
			is_negt = value < 0
			fmt, fmt_n, decimal_marker =
				_internal.decimal_conversion.from_double(math.abs(value))
		end

		result, is_zero = _internal.format.format_unsigned_finite(
			fmt, fmt_n, decimal_marker, is_negt, internal_settings
		)
	end

	result = _internal.format.display_sign(
		result, is_negt, is_zero,
		internal_settings.displaySignAt, internal_settings.symbols
	)

	return result
end

function NumberFormatter_methods.ToSkeleton(self: NumberFormatter): (boolean, string)
	local c_self = _internal.class.try_coerce(1, self, "NumberFormatter")

	return _internal.skeleton.settings_to_skeleton(
		_internal.formatter_settings.linked_list_to_dict(c_self)
	)
end

function NumberFormatter.with(): NumberFormatter
	return NumberFormatter_new(nil)
end

function NumberFormatter.forSkeleton(skeleton: string): (boolean, string | NumberFormatter)
	local success, result

	skeleton = _internal.class.try_coerce(1, skeleton, "string")

	success, result = _internal.skeleton.to_option_linked_list(skeleton)

	return success, if success then NumberFormatter_new(result) else result
end

export type NumberFormatter = typeof(NumberFormatter_methods)
return table.freeze({
	NumberFormatter = table.freeze(NumberFormatter),
	Notation = Notation,
	Precision = Precision,
	RoundingPriority = enums.RoundingPriority,
	RoundingMode = enums.RoundingMode,
	GroupingStrategy = enums.GroupingStrategy,
	IntegerWidth = IntegerWidth,
	DecimalFormatSymbols = DecimalFormatSymbols,
	ENumberFormatSymbols = enums.ENumberFormatSymbols,
	SignDisplay = enums.SignDisplay,
	DecimalSeparatorDisplay = enums.DecimalSeparatorDisplay,
})