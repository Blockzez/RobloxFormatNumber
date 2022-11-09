local class = { }
local type_parents = { }
local proxy_meta = setmetatable({ }, { __mode = "k" })

local function proxy_tostring(self)
	return proxy_meta[self].type_name .. ": " .. proxy_meta[self].as_string
end

local ImmutabilityType = table.freeze({
	DEFAULT = 0,
	NUMBER_FORMATTER = 1,
	SYMBOLS = 2,
})
class.ImmutabilityType = ImmutabilityType

function class.create_init_function(
	type_name: string, parent_type_name: string?,
	methods, parent_methods,
	immutable: number
)
	local result_methods

	if parent_methods then
		result_methods = setmetatable(table.clone(parent_methods), { __index = methods })
	else
		result_methods = methods
	end

	type_parents[type_name] = parent_type_name or "FormatNumberObject"

	return function(data, as_string)
		local result_object = newproxy(true)
		local result_object_meta = getmetatable(result_object)

		if immutable ~= ImmutabilityType.SYMBOLS and type(data) == "table" then
			table.freeze(data)
		end

		result_object_meta.data = data
		result_object_meta.resolved_data = nil
		result_object_meta.type_name = type_name
		result_object_meta.as_string = as_string
			or string.sub(tostring(result_object), 11)
		result_object_meta.__index = result_methods
		result_object_meta.__tostring = proxy_tostring
		result_object_meta.__metatable = "The metatable is locked"

		if immutable ~= ImmutabilityType.NUMBER_FORMATTER then
			table.freeze(result_object_meta)
		end

		proxy_meta[result_object] = result_object_meta

		return result_object
	end
end

function class.is_a(object, type_name)
	local selected_meta = proxy_meta[object]
	local compared_type_name = selected_meta and selected_meta.type_name
	local target_type_name = type_name
	local result = false

	if compared_type_name == target_type_name then
		result = true
	elseif compared_type_name then
		repeat
			compared_type_name = type_parents[compared_type_name]
			result = compared_type_name == target_type_name
		until not compared_type_name or result
	end

	return result
end

function class.get_data(object)
	return proxy_meta[object].data
end

function class.get_resolved_data(object, call_if_not_resolved)
	local proxy_meta_object = proxy_meta[object]
	local resolved_data = proxy_meta_object.resolved_data

	if not resolved_data then
		resolved_data = call_if_not_resolved(proxy_meta_object.data)
		proxy_meta_object.resolved_data = resolved_data
		if resolved_data then
			table.freeze(proxy_meta_object)
		end
	end

	return resolved_data
end

function class.try_coerce(argument_no, value, type_name, default)
	local success = false
	local coerced_value = nil

	if value == nil and default ~= nil then
		coerced_value = default
		success = true
	elseif type_name == "string" then
		if type(value) == "string" then
			coerced_value = value
			success = true
		elseif type(value) == "number" then
			coerced_value = tostring(value)
			success = true
		else
			success = false
		end
	elseif type_name == "number" then
		coerced_value = tonumber(value)
		if coerced_value then
			success = true
		else
			success = false
			type_name ..= " object"
		end
	elseif string.sub(type_name, 1, 1) == "{" then
		local t = string.sub(type_name, 2, -2)
		if type(value) == "table" then
			-- only copy the array part
			-- no metamethods are respected
			coerced_value = table.move(value, 1, rawlen(value), 1, table.create(rawlen(value)))
			for i, v in coerced_value do
				if type(v) ~= t then
					error(string.format("Values inside the table argument must be a %s, index %d got %s", t, i, type(v)), 3)
				end
			end
			success = true
		else
			type_name = "table"
		end
	elseif class.is_a(value, type_name) then
		coerced_value = proxy_meta[value].data
		success = true
	end

	if not success then
		error(string.format("Argument #%d provided must be a %s", argument_no, type_name), 3)
	end

	return coerced_value
end

function class.try_coerce_range(argument_no, value, min, max, default)
	local coerced_value

	if value == nil then
		coerced_value = default
	else
		local converted_integer = tonumber(value)
		if converted_integer then
			converted_integer = class.double_to_int32(converted_integer)

			if converted_integer >= min and converted_integer <= max then
				coerced_value = converted_integer
			end
		end
	end

	return coerced_value or error(string.format(
		"Argument #%d provided must be an integer that is in the range of %d to (and including) %d",
		argument_no, min, max
	), 3)
end

function class.try_coerce_enum(argument_no, value, enum_tbl, default)
	local coerced_value

	if value == nil then
		coerced_value = default
	else
		local enum_value_to_try = tonumber(value)
		if enum_value_to_try then
			enum_value_to_try = class.double_to_int32(value)
			for k, v in enum_tbl do
				if enum_value_to_try == v then
					coerced_value = v
					break
				end
			end
		end
	end

	return coerced_value or error(string.format("Argument #%d provided is out of range", argument_no), 3)
end

function class.double_to_int32(value: number): number
	if not (value > -0x80000001 and value < 0x80000000) then
		-- Double to int32 conversion
		-- cvttsd2si on x86
		-- fcvtzs on aarch64
		return UDim.new(nil, value).Offset
	elseif value <= -1 then
		return math.ceil(value)
	elseif value >= 1 then
		return math.floor(value)
	end
	return 0
end

return table.freeze(class)