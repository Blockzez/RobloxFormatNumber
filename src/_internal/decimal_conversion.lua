local decimal_conversion = { }
local NUMBER_BYTE_CONVERSION = table.freeze({
	["0"] = "\x00", ["1"] = "\x01", ["2"] = "\x02", ["3"] = "\x03",
	["4"] = "\x04", ["5"] = "\x05", ["6"] = "\x06", ["7"] = "\x07",
	["8"] = "\x08", ["9"] = "\x09",
})

function decimal_conversion.from_double(double: number): ({ number }, number, number)
	local result_fmt
	local result_n
	local result_scale

	local sigt_int, sigt_frac, expt = string.match(
		tostring(double), "^(%d+)%.?(%d*)e?([+-]?%d*)$"
	)
	local sigt, sigt_incr = string.match(
		sigt_int .. sigt_frac, "^0*(%d-)(0*)$"
	)

	result_fmt = {string.byte(
		string.gsub(sigt, ".", NUMBER_BYTE_CONVERSION),
		1, -1
	)}
	result_n = #result_fmt
	result_scale = (tonumber(expt) or 0) - #sigt_frac + #sigt_incr

	return result_fmt, result_n, result_scale
end

return table.freeze(decimal_conversion)