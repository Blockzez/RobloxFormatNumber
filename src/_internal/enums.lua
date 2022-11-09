return table.freeze({
	RoundingMode = table.freeze({
		CEILING = 0,
		FLOOR = 1,
		DOWN = 2,
		UP = 3,
		HALF_EVEN = 4,
		HALF_DOWN = 5,
		HALF_UP = 6,
	}),
	GroupingStrategy = table.freeze({
		OFF = 0,
		MIN2 = 1,
		ON_ALIGNED = 3,
	}),
	ENumberFormatSymbols = table.freeze({
		kDecimalSeparatorSymbol = 0,
		kGroupingSeparatorSymbol = 1,
		kMinusSignSymbol = 6,
		kPlusSignSymbol = 7,
		kExponentialSymbol = 11,
		kInfinitySymbol = 14,
		kNaNSymbol = 15,
	}),
	SignDisplay = table.freeze({
		AUTO = 0,
		ALWAYS = 1,
		NEVER = 2,
		EXCEPT_ZERO = 5,
		NEGATIVE = 7,
	}),
	DecimalSeparatorDisplay = table.freeze({
		AUTO = 0,
		ALWAYS = 1,
	}),
	RoundingPriority = table.freeze({
		RELAXED = 0,
		STRICT = 1,
	}),

	_Internal = table.freeze({
		NotationType = table.freeze({
			SIMPLE = 0,
			SCIENTIFIC = 1,
			COMPACT = 2,
		}),

		PrecisionType = table.freeze({
			FRACTION = 0,
			SIGNFICANT = 1,
			FRACTION_SIGNIFICANT = 2,
			UNLIMITED = 3,
		}),
	}),
})