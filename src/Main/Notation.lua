local _internal = require(script.Parent.Parent._internal)

local Notation = { }
local Notation_methods = { }
local Notation_new = _internal.class.create_init_function(
	"Notation",
	nil,
	Notation, nil,
	_internal.class.ImmutabilityType.DEFAULT
)


local ScientificNotation_methods = { }
local ScientificNotation_new = _internal.class.create_init_function(
	"ScientificNotation",
	"Notation",
	ScientificNotation_methods, Notation_methods,
	_internal.class.ImmutabilityType.DEFAULT
)

function ScientificNotation_methods.WithMinExponentDigits(self: ScientificNotation, minExponentDigits: number): ScientificNotation
	local c_self = _internal.class.try_coerce(1, self, "ScientificNotation")
	minExponentDigits = _internal.class.try_coerce_range(2, minExponentDigits, 1, 999)

	c_self = table.clone(c_self)
	c_self.minExponentDigits = minExponentDigits

	return ScientificNotation_new(c_self)
end

function ScientificNotation_methods.WithExponentSignDisplay(self: ScientificNotation, exponentSignDisplay: number): ScientificNotation
	local c_self = _internal.class.try_coerce(1, self, "ScientificNotation")
	exponentSignDisplay = _internal.class.try_coerce_enum(2, exponentSignDisplay, _internal.enums.SignDisplay)

	c_self = table.clone(c_self)
	c_self.exponentSignDisplay = exponentSignDisplay
	c_self.displayExponentSignAt = _internal.formatter_settings.generate_from_sign_enum(exponentSignDisplay)

	return ScientificNotation_new(c_self)
end


-- reserved
local CompactNotation_methods = { }
local CompactNotation_new = _internal.class.create_init_function(
	"CompactNotation", "Notation",
	CompactNotation_methods, Notation_methods,
	_internal.class.ImmutabilityType.DEFAULT
)


-- reserved
local SimpleNotation_methods = { }
local SimpleNotation_new = _internal.class.create_init_function(
	"SimpleNotation", "Notation",
	SimpleNotation_methods, Notation_methods,
	_internal.class.ImmutabilityType.DEFAULT
)


function Notation.scientific(): ScientificNotation
	return ScientificNotation_new({
		type = _internal.enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = 1,
		minExponentDigits = 1,
		exponentSignDisplay = _internal.enums.SignDisplay.AUTO,
		displayExponentSignAt = _internal.formatter_settings.generate_from_sign_enum(
			_internal.enums.SignDisplay.AUTO),
	})
end

function Notation.engineering(): ScientificNotation
	return ScientificNotation_new({
		type = _internal.enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = 3,
		minExponentDigits = 1,
		exponentSignDisplay = _internal.enums.SignDisplay.AUTO,
		displayExponentSignAt = _internal.formatter_settings.generate_from_sign_enum(
			_internal.enums.SignDisplay.AUTO),
	})
end

function Notation.compactWithSuffixThousands(suffixes: { string }): CompactNotation
	local empty_string_p

	suffixes = _internal.class.try_coerce(1, suffixes, "{string}")

	empty_string_p = table.find(suffixes, "")
	if empty_string_p then
		error(string.format("Index %d is an empty string, please double check the suffixes", empty_string_p), 2)
	elseif #suffixes == 0 then
		error("Suffixes is empty", 2)
	end

	return Notation_new({
		type = _internal.enums._Internal.NotationType.COMPACT,
		power10Scale = 3,
		suffixes = suffixes,
		suffixesLength = #suffixes,
	})
end

function Notation.simple(): SimpleNotation
	return Notation_new({
		type = _internal.enums._Internal.NotationType.SIMPLE,
	})
end

export type Notation = { }
export type ScientificNotation = {
	WithMinExponentDigits: typeof(ScientificNotation_methods.WithMinExponentDigits),
	WithExponentSignDisplay: typeof(ScientificNotation_methods.WithExponentSignDisplay)
}
export type CompactNotation = Notation
export type SimpleNotation = Notation
return table.freeze(Notation)