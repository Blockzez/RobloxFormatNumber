local enums = require(script.Parent.enums)
local formatter_settings = require(script.Parent.formatter_settings)
local format = { }

local function internal_get_digits(fmt: { number }, fmt_n: number, i: number, j: number): string
	local leftz, strd, rightz, rightzn

	if i <= 0 then
		leftz = string.rep("0", -i + 1)
		i = 1
	else
		leftz = ""
	end

	rightzn = j - math.max(fmt_n, i - 1)
	if rightzn <= 0 then
		rightz = ""
	else
		j = fmt_n
		rightz = string.rep("0", rightzn)
	end

	if i > fmt_n then
		strd = ""
	else
		strd = string.char(table.unpack(fmt, i, j))
	end

	return leftz .. strd .. rightz
end

function format.strip_trailing_zero(fmt: { number }, fmt_n: number): (number)
	if fmt_n < 0 then
		fmt_n = 0
	else
		while fmt[fmt_n] == 0 do
			fmt_n -= 1
		end
	end
	return fmt_n
end

function format.round_sig(
	fmt: { number }, fmt_n: number, sig: number,
	sign: boolean, rounding_mode: number
): (number, boolean)
	local incr_e = 0

	if fmt_n > sig then
		local midpoint
		-- 1 = down
		-- 0 = half down
		-- -1 = half up
		-- -2 = up
		local resolved_rounding_midpoint

		if sig < 0 then
			midpoint = -1
		elseif fmt[sig + 1] > 5 then
			midpoint = 1
		elseif fmt[sig + 1] == 5 then
			midpoint = if fmt_n > sig + 1 then 1 else 0
		else
			midpoint = -1
		end


		if rounding_mode == enums.RoundingMode.CEILING then
			resolved_rounding_midpoint = if sign then 1 else -2
		elseif rounding_mode == enums.RoundingMode.FLOOR then
			resolved_rounding_midpoint = if sign then -2 else 1
		elseif rounding_mode == enums.RoundingMode.UP then
			resolved_rounding_midpoint = -2
		elseif rounding_mode == enums.RoundingMode.DOWN then
			resolved_rounding_midpoint = 1
		elseif rounding_mode == enums.RoundingMode.HALF_EVEN then
			resolved_rounding_midpoint = if sig <= 0
				then 0
				else fmt[sig] % -2
		elseif rounding_mode == enums.RoundingMode.HALF_DOWN then
			resolved_rounding_midpoint = 0
		elseif rounding_mode == enums.RoundingMode.HALF_UP then
			resolved_rounding_midpoint = -1
		end

		fmt_n = sig

		if midpoint > resolved_rounding_midpoint then
			while fmt[fmt_n] == 9 and fmt_n > 0 do
				fmt_n -= 1
			end

			if fmt_n <= 0 then
				fmt[1] = 1
				incr_e = 1 - fmt_n
				fmt_n = 1
			else
				fmt[fmt_n] += 1
			end
		end

		fmt_n = format.strip_trailing_zero(fmt, fmt_n)
	end

	return fmt_n, incr_e
end

function format.resolve_int_frac(
	fmt: { number }, fmt_n: number, marker: number,
	i: number, j: number, min_grouping: number?, grouping_symbol: string
): string
	local intg, frac, expt

	for i = 1, fmt_n do
		fmt[i] += 0x30
	end

	-- interesting edge case
	if marker < i and j < marker + 1 then
		intg = "0"
		frac = ""
	else
		intg = internal_get_digits(fmt, fmt_n, i, marker)
		frac = internal_get_digits(fmt, fmt_n, marker + 1, j)
	end

	if min_grouping and marker - i + 1 >= min_grouping then
		local grouping_repl

		if grouping_symbol == "%" then
			grouping_repl = "%0%%"
		elseif #grouping_symbol > 1 then
			grouping_repl = "%0" .. string.reverse(grouping_symbol)
		else
			grouping_repl = "%0" .. grouping_symbol
		end
		intg = string.reverse((string.gsub(string.reverse(intg),
			"...", grouping_repl, (marker - i) / 3
		)))
	end

	return intg, frac
end

function format.format_expt(expt, symbols, min_int_digits, disp_sign_at)
	local disp_sign = ""
	local exp_str
	if expt < 0 then
		exp_str = tostring(-expt)
		if disp_sign_at.negative then
			disp_sign = symbols[enums.ENumberFormatSymbols.kMinusSignSymbol]
		end
	elseif expt == 0 then
		exp_str = "0"
		if disp_sign_at.positiveZero then
			disp_sign = symbols[enums.ENumberFormatSymbols.kPlusSignSymbol]
		end
	else
		exp_str = tostring(expt)
		if disp_sign_at.positive then
			disp_sign = symbols[enums.ENumberFormatSymbols.kPlusSignSymbol]
		end
	end

	exp_str = string.rep("0", min_int_digits - #exp_str) .. exp_str

	return symbols[enums.ENumberFormatSymbols.kExponentialSymbol]
		.. disp_sign .. exp_str
end

function format.resolve_with_notation(fmt, fmt_n, scale, notation, symbols)
	local fmtd_expt = nil
	local next_expt_threshold = nil
	local next_fmtd_expt = nil
	local decimal_marker = scale

	if fmt_n <= 0 then
		if notation.type == enums._Internal.NotationType.SCIENTIFIC then
			fmtd_expt = format.format_expt(
				0, symbols,
				notation.minExponentDigits,
				notation.displayExponentSignAt
			)
		end
	else
		if notation.type == enums._Internal.NotationType.SIMPLE then
			decimal_marker += fmt_n
		else
			local d_pow10 = notation.power10Scale
			local value_pow10 = decimal_marker + fmt_n - 1
			local p_quotient = math.floor(value_pow10 / d_pow10)
			local p_remainder = value_pow10 - p_quotient * d_pow10

			decimal_marker = p_remainder + 1
			if notation.type == enums._Internal.NotationType.COMPACT then
				local suffix_n = notation.suffixesLength
				if p_quotient > suffix_n then
					decimal_marker += (p_quotient - suffix_n) * d_pow10
					fmtd_expt = notation.suffixes[suffix_n]
				elseif p_quotient < 0 then
					decimal_marker += p_quotient * d_pow10
				elseif p_quotient ~= 0 then
					fmtd_expt = notation.suffixes[p_quotient]
				end

				if p_quotient >= 0 and p_quotient < suffix_n then
					next_expt_threshold = d_pow10
					next_fmtd_expt = notation.suffixes[p_quotient + 1]
				end
			else
				fmtd_expt = format.format_expt(
					p_quotient * d_pow10,
					symbols,
					notation.minExponentDigits,
					notation.displayExponentSignAt
				)
				next_fmtd_expt = format.format_expt(
					(p_quotient + 1) * d_pow10,
					symbols,
					notation.minExponentDigits,
					notation.displayExponentSignAt
				)

				next_expt_threshold = d_pow10
			end
		end
	end

	return decimal_marker, fmtd_expt, next_expt_threshold, next_fmtd_expt
end

function format.format_unsigned_finite(
	fmt, fmt_n, scale, is_negt,
	internal_settings
): string
	local result, rounded_to_zero

	local fmtd_frac
	local int_width
	local min_int = internal_settings.integerWidth.min
	local max_int = internal_settings.integerWidth.max
	local re_min_sig, re_max_sig
	local incr_marker

	local notation = internal_settings.notation
	local symbols = internal_settings.symbols

	local decimal_marker, fmtd_expt, next_expt_threshold, next_fmtd_expt =
		format.resolve_with_notation(fmt, fmt_n, scale, notation, symbols)

	re_min_sig, re_max_sig =
		formatter_settings.resolve_min_max_sig(
			internal_settings.precision,
			decimal_marker
		)

	fmt_n, incr_marker = format.round_sig(
		fmt, fmt_n, re_max_sig, is_negt,
		internal_settings.roundingMode
	)

	rounded_to_zero = fmt_n == 0

	if incr_marker > 0 then
		if decimal_marker == next_expt_threshold then
			-- assume incr_maker is 1
			assert(incr_marker == 1)
			fmtd_expt = next_fmtd_expt
			decimal_marker = 1
		else
			decimal_marker += incr_marker
		end

		re_min_sig, re_max_sig =
			formatter_settings.resolve_min_max_sig(
				internal_settings.precision, decimal_marker
			)
	elseif rounded_to_zero then
		-- for convenince
		re_min_sig, re_max_sig =
			formatter_settings.resolve_min_max_sig(
				internal_settings.precision, 1
			)
		decimal_marker = 1
	end

	if decimal_marker < min_int then
		int_width = min_int
	elseif max_int ~= -1 and decimal_marker > max_int then
		int_width = max_int
	else
		int_width = decimal_marker
	end

	result, fmtd_frac = format.resolve_int_frac(
		fmt, fmt_n, decimal_marker,
		math.max(decimal_marker, 0) - int_width + 1,
		math.max(fmt_n, re_min_sig),
		internal_settings.minGrouping,
		symbols[enums.ENumberFormatSymbols.kGroupingSeparatorSymbol]
	)

	if internal_settings.alwaysDisplayDecimal
		or fmtd_frac ~= "" then
		result ..= symbols[enums.ENumberFormatSymbols.kDecimalSeparatorSymbol]
			.. fmtd_frac
	end

	if fmtd_expt then
		result ..= fmtd_expt
	end

	return result, rounded_to_zero
end

function format.display_sign(str, is_negt, is_zero, disp_sign_at, symbols)
	local sign_symbol
	local display

	if is_negt then
		sign_symbol = symbols[enums.ENumberFormatSymbols.kMinusSignSymbol]
		if is_zero then
			display = disp_sign_at.negativeZero
		else
			display = disp_sign_at.negative
		end
	else
		sign_symbol = symbols[enums.ENumberFormatSymbols.kPlusSignSymbol]
		if is_zero then
			display = disp_sign_at.positiveZero
		else
			display = disp_sign_at.positive
		end
	end

	if display then
		return sign_symbol .. str
	end
	return str
end

return table.freeze(format)