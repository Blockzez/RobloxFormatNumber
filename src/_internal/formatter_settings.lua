local enums = require(script.Parent.enums)
local formatter_settings = { }

formatter_settings.MAX_PRECISION = 0x7FFFFFFF -- 2^31 - 1
function formatter_settings.resolve_min_max_sig(precision, decimal_marker)
	local resolved_min, resolved_max = nil, nil

	if precision.type == enums._Internal.PrecisionType.SIGNFICANT then
		resolved_min = precision.min
		resolved_max = precision.max
	elseif precision.type == enums._Internal.PrecisionType.FRACTION then
		resolved_min = decimal_marker + precision.min
		resolved_max = decimal_marker + precision.max
	elseif precision.type == enums._Internal.PrecisionType.FRACTION_SIGNIFICANT then
		local min_frac = decimal_marker + precision.minFractionDigits
		local max_frac = decimal_marker + precision.maxFractionDigits
		local min_sig = precision.minSignificantDigits
		local max_sig = precision.maxSignificantDigits

		if precision.roundingPriority == enums.RoundingPriority.RELAXED then
			resolved_min = math.max(min_frac, min_sig)
			resolved_max = math.max(max_frac, max_sig)
		else
			resolved_min = math.min(min_frac, min_sig)
			resolved_max = math.min(max_frac, max_sig)
		end

		if not precision.sourcedWithSignificantDigits then
			resolved_min = min_frac
		end

	elseif precision.type == enums._Internal.PrecisionType.UNLIMITED then
		resolved_min = 1
		resolved_max = formatter_settings.MAX_PRECISION
	end

	return resolved_min, resolved_max
end

local DEFAULT_SYMBOLS = table.freeze({
	[enums.ENumberFormatSymbols.kDecimalSeparatorSymbol] = ".",
	[enums.ENumberFormatSymbols.kGroupingSeparatorSymbol] = ",",
	[enums.ENumberFormatSymbols.kMinusSignSymbol] = "-",
	[enums.ENumberFormatSymbols.kPlusSignSymbol] = "+",
	[enums.ENumberFormatSymbols.kExponentialSymbol] = "E",
	[enums.ENumberFormatSymbols.kInfinitySymbol] = "∞",
	[enums.ENumberFormatSymbols.kNaNSymbol] = "NaN",
})

function formatter_settings.generate_from_sign_enum(sign)
	local disp_neg, disp_neg_zero, disp_pos_zero, disp_pos

	if sign == enums.SignDisplay.AUTO then
		disp_neg, disp_neg_zero = true, true
		disp_pos, disp_pos_zero = false, false
	elseif sign == enums.SignDisplay.ALWAYS then
		disp_neg, disp_neg_zero = true, true
		disp_pos, disp_pos_zero = true, true
	elseif sign == enums.SignDisplay.NEVER then
		disp_neg, disp_neg_zero = false, false
		disp_pos, disp_pos_zero = false, false
	elseif sign == enums.SignDisplay.NEGATIVE then
		disp_neg, disp_neg_zero = true, false
		disp_pos, disp_pos_zero = false, false
	elseif sign == enums.SignDisplay.EXCEPT_ZERO then
		disp_neg, disp_neg_zero = true, false
		disp_pos, disp_pos_zero = true, false
	end

	return table.freeze({
		negative = disp_neg,
		negativeZero = disp_neg_zero,
		positiveZero = disp_pos_zero,
		positive = disp_pos,
	})
end


function formatter_settings.linked_list_to_dict(linked_list)
	local result = { }
	local selected_ll = linked_list
	while selected_ll do
		if not result[selected_ll.key] then
			result[selected_ll.key] = selected_ll.value
		end
		selected_ll = selected_ll.parent
	end

	return table.freeze(result)
end

function formatter_settings.resolve_settings(settings_)
	local is_compact_notation
	local resolved_settings = { }

	resolved_settings.notation = settings_.notation or table.freeze({
		type = enums._Internal.NotationType.SIMPLE,
	})
	is_compact_notation = resolved_settings.notation.type == enums._Internal.NotationType.COMPACT
	if settings_.precision then
		resolved_settings.precision = settings_.precision
	else
		resolved_settings.precision =
			if is_compact_notation
			then table.freeze({
				type = enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
				minFractionDigits = 0,
				maxFractionDigits = 0,
				minSignificantDigits = 1,
				maxSignificantDigits = 2,
				roundingPriority = enums.RoundingPriority.RELAXED,
			})
			else table.freeze({
				type = enums._Internal.PrecisionType.FRACTION,
				min = 0, max = 6,
			})
	end
	if settings_.roundingMode then
		resolved_settings.roundingMode = settings_.roundingMode
	else
		resolved_settings.roundingMode = if is_compact_notation
			or resolved_settings.notation.type == enums._Internal.NotationType.SCIENTIFIC
			then enums.RoundingMode.DOWN
			else enums.RoundingMode.HALF_EVEN
	end
	if settings_.grouping then
		local grouping = settings_.grouping
		local min_grouping_result

		if grouping == enums.GroupingStrategy.MIN2 then
			min_grouping_result = 5
		elseif grouping == enums.GroupingStrategy.ON_ALIGNED then
			min_grouping_result = 4
		else
			min_grouping_result = nil
		end
		resolved_settings.minGrouping = min_grouping_result
	else
		-- compact notation use min2 grouping by default
		resolved_settings.minGrouping = if is_compact_notation then 5 else 4
	end
	resolved_settings.integerWidth = settings_.integerWidth or table.freeze({
		min = 1,
		max = -1,
	})
	resolved_settings.symbols = settings_.symbols or DEFAULT_SYMBOLS
	if settings_.sign then
		resolved_settings.displaySignAt =
			formatter_settings.generate_from_sign_enum(settings_.sign)
	else
		resolved_settings.displaySignAt =
			formatter_settings.generate_from_sign_enum(enums.SignDisplay.AUTO)
	end
	resolved_settings.alwaysDisplayDecimal =
		settings_.decimal == enums.DecimalSeparatorDisplay.ALWAYS

	return table.freeze(resolved_settings)
end

return table.freeze(formatter_settings)