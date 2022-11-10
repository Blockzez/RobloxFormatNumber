local formatter_settings = require(script.Parent.formatter_settings)
local enums = require(script.Parent.enums)
local skeleton = { }

--
local SIGN_TO_SKELETON = {
	[enums.SignDisplay.AUTO] = nil, --"sign-auto",
	[enums.SignDisplay.ALWAYS] = "sign-always",
	[enums.SignDisplay.NEVER] = "sign-never",
	[enums.SignDisplay.EXCEPT_ZERO] = "sign-except-zero",
	[enums.SignDisplay.NEGATIVE] = "sign-negative",
}

local function notation_to_skeleton(notation)
	local success, result

	if notation.type == enums._Internal.NotationType.SCIENTIFIC then
		success = true
		result = if notation.power10Scale == 3 then "engineering" else "scientific"

		if notation.minExponentDigits ~= 1 then
			result ..= "/*" ..
				string.rep("e", notation.minExponentDigits)
		end

		if notation.exponentSignDisplay ~= enums.SignDisplay.AUTO then
			result ..= "/" .. SIGN_TO_SKELETON[notation.exponentSignDisplay]
		end
	elseif notation.type == enums._Internal.NotationType.SIMPLE then
		success = true
		result = nil -- "notation-simple"
	else
		success = false
		result = "Compact notation skeleton is not supported for being represented as a skeleton string in this module"
	end

	return success, result
end

local function precision_to_skeleton(precision)
	local result
	local frac_s
	local sig_s
	local min_frac, max_frac = nil, nil
	local min_sig, max_sig = nil, nil

	if precision.type == enums._Internal.PrecisionType.FRACTION then
		min_frac, max_frac = precision.min, precision.max
	elseif precision.type == enums._Internal.PrecisionType.SIGNFICANT then
		min_sig, max_sig = precision.min, precision.max
	elseif precision.type == enums._Internal.PrecisionType.FRACTION_SIGNIFICANT then
		min_frac, max_frac = precision.minFractionDigits, precision.maxFractionDigits
		if precision.sourcedWithSignificantDigits then
			min_sig, max_sig = precision.minSignificantDigits, precision.maxSignificantDigits
		elseif precision.roundingPriority == enums.RoundingPriority.RELAXED then
			min_sig, max_sig = precision.maxSignificantDigits, formatter_settings.MAX_PRECISION
		else
			min_sig, max_sig = 1, precision.maxSignificantDigits
		end
	else
		result = "precision-unlimited"
	end

	if min_frac then
		if max_frac == 0 then
			frac_s = "precision-integer"
		else
			frac_s = "." .. string.rep("0", min_frac)
			if max_frac == formatter_settings.MAX_PRECISION then
				frac_s ..= "*"
			else
				frac_s ..= string.rep("#", max_frac - min_frac)
			end
		end
	end

	if min_sig then
		sig_s = string.rep("@", min_sig)
		if max_sig == formatter_settings.MAX_PRECISION then
			sig_s ..= "*"
		else
			sig_s ..= string.rep("#", max_sig - min_sig)
		end
	end

	if frac_s then
		result = frac_s
		if sig_s then
			result ..= "/" .. sig_s
			if precision.type == enums._Internal.PrecisionType.FRACTION_SIGNIFICANT
				and precision.sourcedWithSignificantDigits then
				if precision.roundingPriority == enums.RoundingPriority.RELAXED then
					result ..= "r"
				else
					result ..= "s"
				end
			end
		end
	elseif sig_s then
		result = sig_s
	end

	return result
end

local ROUNDING_MODE_TO_SKELETON = {
	[enums.RoundingMode.CEILING] = "rounding-mode-ceiling",
	[enums.RoundingMode.FLOOR] = "rounding-mode-floor",
	[enums.RoundingMode.DOWN] = "rounding-mode-down",
	[enums.RoundingMode.UP] = "rounding-mode-up",
	[enums.RoundingMode.HALF_EVEN] = "rounding-mode-half-even",
	[enums.RoundingMode.HALF_DOWN] = "rounding-mode-half-down",
	[enums.RoundingMode.HALF_UP] = "rounding-mode-half-up",
}

local GROUPING_TO_SKELETON = {
	[enums.GroupingStrategy.OFF] = "group-off",
	[enums.GroupingStrategy.MIN2] = "group-min2",
	[enums.GroupingStrategy.ON_ALIGNED] = "group-on-aligned",
}

local function int_width_to_skeleton(int_width)
	local result

	if int_width.max == -1 then
		result = "integer-width/*" .. string.rep("0", int_width.min)
	elseif int_width.max == 0 and int_width.min == 0 then
		result = "integer-width-trunc"
	else
		result = "integer-width/" ..
			string.rep("#", int_width.max - int_width.min) ..
			string.rep("0", int_width.min)
	end

	return result
end

local DECIMAL_TO_SKELETON = {
	[enums.DecimalSeparatorDisplay.AUTO] = nil, -- "decimal-auto",
	[enums.DecimalSeparatorDisplay.ALWAYS] = "decimal-always",
}

function skeleton.settings_to_skeleton(settings_)
	local success = true
	local result_tbl = { }
	local result_string

	if settings_.notation then
		local skeleton_part
		success, skeleton_part = notation_to_skeleton(settings_.notation)

		if success then
			table.insert(result_tbl, skeleton_part)
		else
			result_string = skeleton_part
		end
	end

	if success then
		if settings_.precision then
			table.insert(result_tbl, precision_to_skeleton(settings_.precision))
		end
		if settings_.roundingMode then
			table.insert(result_tbl, ROUNDING_MODE_TO_SKELETON[settings_.roundingMode])
		end
		if settings_.grouping then
			table.insert(result_tbl, GROUPING_TO_SKELETON[settings_.grouping])
		end
		if settings_.integerWidth then
			table.insert(result_tbl, int_width_to_skeleton(settings_.integerWidth))
		end
		if settings_.decimal then
			table.insert(result_tbl, DECIMAL_TO_SKELETON[settings_.decimal])
		end

		result_string = table.concat(result_tbl, " ")
	end

	return success, result_string
end
--
local SKELETON_KEY = {
	["notation-simple"] = "notation",

	["precision-unlimited"] = "precision",
	[".+"] = "precision",

	["rounding-mode-ceiling"] = "roundingMode",
	["rounding-mode-floor"] = "roundingMode",
	["rounding-mode-down"] = "roundingMode",
	["rounding-mode-up"] = "roundingMode",
	["rounding-mode-half-even"] = "roundingMode",
	["rounding-mode-half-down"] = "roundingMode",
	["rounding-mode-half-up"] = "roundingMode",

	["group-off"] = "grouping",
	["group-min2"] = "grouping",
	["group-on-aligned"] = "grouping",
	[",_"] = "grouping",
	[",?"] = "grouping",
	[",!"] = "grouping",

	["sign-auto"] = "sign",
	["sign-always"] = "sign",
	["sign-never"] = "sign",
	["sign-except-zero"] = "sign",
	["sign-negative"] = "sign",
	["+!"] = "sign",
	["+_"] = "sign",
	["+?"] = "sign",
	["+-"] = "sign",

	["decimal-auto"] = "decimal",
	["decimal-always"] = "decimal",
}

local SKELETON_VALUE = {
	["notation-simple"] = table.freeze({
		type = enums._Internal.NotationType.SIMPLE,
	}),

	["precision-unlimited"] = table.freeze({
		type = enums._Internal.PrecisionType.UNLIMITED,
	}),
	[".+"] = table.freeze({
		type = enums._Internal.PrecisionType.UNLIMITED,
	}),

	["rounding-mode-ceiling"] = enums.RoundingMode.CEILING,
	["rounding-mode-floor"] = enums.RoundingMode.FLOOR,
	["rounding-mode-down"] = enums.RoundingMode.DOWN,
	["rounding-mode-up"] = enums.RoundingMode.UP,
	["rounding-mode-half-even"] = enums.RoundingMode.HALF_EVEN,
	["rounding-mode-half-down"] = enums.RoundingMode.HALF_DOWN,
	["rounding-mode-half-up"] = enums.RoundingMode.HALF_UP,

	["group-off"] = enums.GroupingStrategy.OFF,
	["group-min2"] = enums.GroupingStrategy.MIN2,
	["group-on-aligned"] = enums.GroupingStrategy.ON_ALIGNED,
	[",_"] = enums.GroupingStrategy.OFF,
	[",?"] = enums.GroupingStrategy.MIN2,
	[",!"] = enums.GroupingStrategy.ON_ALIGNED,

	["sign-auto"] = enums.SignDisplay.AUTO,
	["sign-always"] = enums.SignDisplay.ALWAYS,
	["sign-never"] = enums.SignDisplay.NEVER,
	["sign-except-zero"] = enums.SignDisplay.EXCEPT_ZERO,
	["sign-negative"] = enums.SignDisplay.NEGATIVE,
	["+!"] = enums.SignDisplay.ALWAYS,
	["+_"] = enums.SignDisplay.NEVER,
	["+?"] = enums.SignDisplay.EXCEPT_ZERO,
	["+-"] = enums.SignDisplay.NEGATIVE,

	["decimal-auto"] = enums.DecimalSeparatorDisplay.AUTO,
	["decimal-always"] = enums.DecimalSeparatorDisplay.ALWAYS,
}

local function skeleton_to_scientific_notation(str)
	local p1, p2, p3 = string.match(str, "^(%a+)/?([^/]*)/?([^/]*)$")
	local min_expt = 1
	local sign_expt = enums.SignDisplay.AUTO

	if p1 ~= "scientific" and p1 ~= "engineering" then
		return nil
	end

	if string.match(p2, "^[%*%+]e+$") then
		min_expt = #p2 - 1
		p2 = p3
		p3 = ""
	elseif string.match(p3, "^[%*%+]e+$") then
		min_expt = #p3 - 1
	end

	if p2 ~= "" then
		if string.sub(p2, 1, 5) ~= "sign-" then
			return nil
		end
		sign_expt = SKELETON_VALUE[p2]
	end

	-- sanity check
	if min_expt > 999 then
		return nil
	end

	return table.freeze({
		type = enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = if p1 == "engineering" then 3 else 1,
		minExponentDigits = min_expt,
		exponentSignDisplay = sign_expt,
		displayExponentSignAt = formatter_settings.generate_from_sign_enum(sign_expt),
	})
end

local function skeleton_to_scientific_notation_concise(str)
	local old_c_str
	local c_str = str
	local s_or_e
	local sign_expt

	s_or_e, c_str = string.match(str, "^(EE?)(.+)$")
	if not s_or_e then
		return nil
	end

	old_c_str = c_str
	sign_expt, c_str = string.match(c_str, "^(%+[!%?])(.+)$")
	if sign_expt then
		sign_expt = SKELETON_VALUE[sign_expt]
	else
		c_str = old_c_str
		old_c_str = nil
		sign_expt = enums.SignDisplay.AUTO
	end

	if not string.match(c_str, "^0+$") then
		return nil
	end

	-- sanity check
	if #c_str > 999 then
		return nil
	end

	return table.freeze({
		type = enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = if s_or_e == "EE" then 3 else 1,
		minExponentDigits = #c_str,
		exponentSignDisplay = sign_expt,
		displayExponentSignAt = formatter_settings.generate_from_sign_enum(sign_expt),
	})
end

local function skeleton_to_precision(str)
	local old_c_str
	local c_str = str
	local min_sig_str, max_sig_str
	local min_frac_str, max_frac_str

	max_frac_str, min_frac_str, c_str = string.match(str, "^%.((0*)#*)(.*)$")

	if not max_frac_str then
		max_frac_str, c_str = string.match(str, "^(precision%-integer)(.*)$")
	end

	if max_frac_str then
		local min_frac, max_frac

		if max_frac_str == "precision-integer" then
			min_frac, max_frac = 0, 0
		else
			min_frac = #min_frac_str
			max_frac = #max_frac_str
		end

		if string.match(c_str, "^[%*%+]")
			and min_frac_str == max_frac_str then
			max_frac = -1
			c_str = string.sub(c_str, 2)
		end

		-- sanity check
		if min_frac > 999 or max_frac > 999 then
			return nil
		elseif max_frac == -1 then
			max_frac = formatter_settings.MAX_PRECISION
		end

		if string.sub(c_str, 1, 1) == "/" then
			local rp, min_sig, max_sig
			local rp_incl = false
			max_sig_str, min_sig_str, rp = string.match(
				c_str, "^/((@+)#*)([%*%+rs]?)$"
			)

			if not max_sig_str
				or rp == "" and min_sig_str ~= "@"
				or (rp == "*" or rp == "+") and min_sig_str ~= max_sig_str then
				return nil
			end

			if rp == "" then
				min_sig = 1
				max_sig = #max_sig_str
				rp = "s"
			elseif rp == "*" or rp == "+" then
				min_sig = 1
				max_sig = #min_sig_str
				rp = "r"
			else
				rp_incl = true
				min_sig = #min_sig_str
				max_sig = #max_sig_str
			end

			-- sanity check
			if min_sig > 999 or max_sig > 999 then
				return nil
			end

			return table.freeze({
				type = enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
				minFractionDigits = min_frac,
				maxFractionDigits = max_frac,
				minSignificantDigits = min_sig,
				maxSignificantDigits = max_sig,
				roundingPriority = if rp == "r"
					then enums.RoundingPriority.RELAXED
					else enums.RoundingPriority.STRICT,
				sourcedWithSignificantDigits = rp_incl,
			})
		elseif c_str ~= "" then
			return nil
		end

		return table.freeze({
			type = enums._Internal.PrecisionType.FRACTION,
			min = min_frac,
			max = max_frac,
		})
	end

	max_sig_str, min_sig_str, c_str = string.match(str, "^((@+)#*)([%*%+]?)$")

	if max_sig_str then
		local min_sig = #min_sig_str
		local max_sig = #max_sig_str

		if c_str ~= "" then
			if min_sig ~= max_sig then
				return nil
			end
			max_sig = -1
			c_str = string.sub(c_str, 2)
		end

		-- sanity check
		if min_sig > 999 or max_sig > 999 then
			return nil
		elseif max_sig == -1 then
			max_sig = formatter_settings.MAX_PRECISION
		end

		return table.freeze({
			type = enums._Internal.PrecisionType.SIGNFICANT,
			min = min_sig,
			max = max_sig,
		})
	end

	return nil
end

local function skeleton_to_int_width(str)
	local min_int_str, max_int_str
	if str == "integer-width-trunc" then
		return table.freeze({ min = 0, max = 0 })
	end
	min_int_str = string.match(str, "^integer%-width/[%*%+](0*)$")
	if min_int_str then
		-- sanity check
		if #min_int_str > 999 then
			return nil
		end

		return table.freeze({
			min = #min_int_str,
			max = -1,
		})
	end
	max_int_str, min_int_str =
		string.match(str, "^integer%-width/(#*(0*))$")

	-- sanity check
	if not max_int_str or max_int_str == "" or #max_int_str > 999
		or #min_int_str > 999 then
		return nil
	end

	return table.freeze({
		min = #min_int_str,
		max = #max_int_str,
	})
end

local function skeleton_to_int_width_concise(str)
	return if string.match(str, "^0+$") and #str < 1000 then table.freeze({
		min = #str, max = -1
	}) else nil
end

function skeleton.to_option_linked_list(skeleton_string)
	local result = nil
	local keys = { }

	for pos, token in string.gmatch(skeleton_string, "()(%S+)") do
		local r_key, r_value = nil, nil
		r_key = SKELETON_KEY[token]
		if r_key then
			r_value = SKELETON_VALUE[token]
		end

		if not r_value then
			r_value = skeleton_to_scientific_notation(token)
				or skeleton_to_scientific_notation_concise(token)
			if r_value then
				r_key = "notation"
			end
		end

		if not r_value then
			r_value = skeleton_to_precision(token)
			if r_value then
				r_key = "precision"
			end
		end

		if not r_value then
			r_value = skeleton_to_int_width(token)
				or skeleton_to_int_width_concise(token)
			if r_value then
				r_key = "integerWidth"
			end
		end

		if not r_key or keys[r_key] then
			return false, string.format("number skeleton syntax error near '%*' at position %d", (string.gsub(token, "'", "\\'")), pos)
		end
		keys[r_key] = true
		result = {
			key = r_key,
			value = r_value,
			parent = result,
		}
	end

	return true, result
end

return skeleton
