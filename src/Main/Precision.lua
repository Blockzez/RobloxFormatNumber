local _internal = require(script.Parent.Parent._internal)

local Precision = { }
local Precision_methods = { }
local Precision_new = _internal.class.create_init_function(
	"Precision", nil,
	Precision_methods, nil,
	_internal.class.ImmutabilityType.DEFAULT
)


local FractionPrecision_methods = { }
local FractionPrecision_new = _internal.class.create_init_function(
	"FractionPrecision", "Precision",
	FractionPrecision_methods, Precision_methods,
	_internal.class.ImmutabilityType.DEFAULT
)

function FractionPrecision_methods.WithMinDigits(self: FractionPrecision, minSignificantDigits: number): Precision
	local c_self = _internal.class.try_coerce(1, self, "FractionPrecision")
	minSignificantDigits = _internal.class.try_coerce_range(2, minSignificantDigits, 1, 999)

	return Precision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
		minFractionDigits = c_self.min,
		maxFractionDigits = c_self.max,
		minSignificantDigits = 1,
		maxSignificantDigits = minSignificantDigits,
		roundingPriority = _internal.enums.RoundingPriority.RELAXED,
		sourcedWithSignificantDigits = false,
	})
end

function FractionPrecision_methods.WithMaxDigits(self: FractionPrecision, maxSignificantDigits: number): Precision
	local c_self = _internal.class.try_coerce(1, self, "FractionPrecision")
	maxSignificantDigits = _internal.class.try_coerce_range(2, maxSignificantDigits, 1, 999)

	return Precision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
		minFractionDigits = c_self.min,
		maxFractionDigits = c_self.max,
		minSignificantDigits = 1,
		maxSignificantDigits = maxSignificantDigits,
		roundingPriority = _internal.enums.RoundingPriority.STRICT,
		sourcedWithSignificantDigits = false,
	})
end

function FractionPrecision_methods.WithSignificantDigits(self: FractionPrecision,
	minSignificantDigits: number, maxSignificantDigits: number, roundingPriority: number): Precision
	local c_self = _internal.class.try_coerce(1, self, "FractionPrecision")
	minSignificantDigits = _internal.class.try_coerce_range(2, minSignificantDigits, 1, 999)
	maxSignificantDigits = _internal.class.try_coerce_range(3, maxSignificantDigits, 1, 999)
	roundingPriority = _internal.class.try_coerce_enum(4, roundingPriority, _internal.enums.RoundingPriority)

	return Precision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
		minFractionDigits = c_self.min,
		maxFractionDigits = c_self.max,
		minSignificantDigits = minSignificantDigits,
		maxSignificantDigits = maxSignificantDigits,
		roundingPriority = roundingPriority,
		sourcedWithSignificantDigits = true,
	})
end

-- reserved
local SignificantDigitsPrecision_methods = { }
local SignificantDigitsPrecision_new = _internal.class.create_init_function(
	"SignificantDigitsPrecision", "Precision",
	SignificantDigitsPrecision_methods, Precision_methods,
	_internal.class.ImmutabilityType.DEFAULT
)


function Precision.unlimited(): Precision
	return Precision_new({
		type = _internal.enums._Internal.PrecisionType.UNLIMITED,
	})
end

function Precision.integer(): FractionPrecision
	return FractionPrecision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = 0,
		max = 0,
	})
end

function Precision.fixedFraction(minMaxFractionPlaces: number): FractionPrecision
	minMaxFractionPlaces = _internal.class.try_coerce_range(1, minMaxFractionPlaces, 0, 999)

	return FractionPrecision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = minMaxFractionPlaces,
		max = minMaxFractionPlaces,
	})
end

function Precision.minFraction(minFractionPlaces: number): FractionPrecision
	minFractionPlaces = _internal.class.try_coerce_range(1, minFractionPlaces, 0, 999)

	return FractionPrecision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = minFractionPlaces,
		max = _internal.formatter_settings.MAX_PRECISION,
	})
end

function Precision.maxFraction(maxFractionPlaces: number): FractionPrecision
	maxFractionPlaces = _internal.class.try_coerce_range(1, maxFractionPlaces, 0, 999)

	return FractionPrecision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = 0,
		max = maxFractionPlaces,
	})
end

function Precision.minMaxFraction(minFractionPlaces: number, maxFractionPlaces: number): FractionPrecision
	minFractionPlaces = _internal.class.try_coerce_range(1, minFractionPlaces, 0, 999)
	maxFractionPlaces = _internal.class.try_coerce_range(2, maxFractionPlaces, minFractionPlaces, 999)

	return FractionPrecision_new({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = minFractionPlaces,
		max = maxFractionPlaces,
	})
end

function Precision.fixedSignificantDigits(minMaxSignificantDigits: number): SignificantDigitsPrecision
	minMaxSignificantDigits = _internal.class.try_coerce_range(1, minMaxSignificantDigits, 1, 999)

	return SignificantDigitsPrecision_new({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = minMaxSignificantDigits,
		max = minMaxSignificantDigits,
	})
end

function Precision.minSignificantDigits(minSignificantDigits: number): SignificantDigitsPrecision
	minSignificantDigits = _internal.class.try_coerce_range(1, minSignificantDigits, 1, 999)

	return SignificantDigitsPrecision_new({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = minSignificantDigits,
		max = _internal.formatter_settings.MAX_PRECISION,
	})
end

function Precision.maxSignificantDigits(maxSignificantDigits: number): SignificantDigitsPrecision
	maxSignificantDigits = _internal.class.try_coerce_range(1, maxSignificantDigits, 1, 999)

	return SignificantDigitsPrecision_new({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = 1,
		max = maxSignificantDigits,
	})
end

function Precision.minMaxSignificantDigits(minSignificantDigits: number, maxSignificantDigits: number): SignificantDigitsPrecision
	minSignificantDigits = _internal.class.try_coerce_range(1, minSignificantDigits, 1, 999)
	maxSignificantDigits = _internal.class.try_coerce_range(2, maxSignificantDigits, minSignificantDigits, 999)

	return SignificantDigitsPrecision_new({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = minSignificantDigits,
		max = maxSignificantDigits,
	})
end

export type Precision = { }
export type FractionPrecision = {
	WithMinDigits: typeof(FractionPrecision_methods.WithMinDigits),
	WithMaxDigits: typeof(FractionPrecision_methods.WithMaxDigits),
	WithSignificantDigits: typeof(FractionPrecision_methods.WithSignificantDigits),
}
export type SignificantDigitsPrecision = { }
return table.freeze(Precision)