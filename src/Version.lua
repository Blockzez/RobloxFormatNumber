--[[
FormatNumber
Version 31.1
BSD 2-Clause Licence
Copyright 2022 - Blockzez (https://devforum.roblox.com/u/Blockzez and https://github.com/Blockzez)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
local FormatNumberVersion = { }
export type FormatNumberVersion = {
	Major: number,
	Minor: number,
}

local function version_tostring(self)
	return string.format("%d.%d", self.Major, self.Minor)
end

local function version_lt(lhs, rhs)
	return if lhs.Major == rhs.Major
	then lhs.Minor < rhs.Minor
	else lhs.Major < rhs.Major
end

local function version_eq(lhs, rhs)
	return lhs.Major == rhs.Major and lhs.Minor == rhs.Minor
end

local function double_to_int32(value: number): number
	-- relying on UDim.new integer conversion semantic
	-- if you get weird behaviour for values out of the int32 range
	-- or you put the wrong value in, it's on you.
	if math.clamp(tonumber(value) or 0, -0x80000000, 0x7FFFFFFF) ~= value then
		return UDim.new(nil, value).Offset
	elseif value <= -1 then
		return math.ceil(value)
	elseif value >= 1 then
		return math.floor(value)
	end
	return 0
end

function FormatNumberVersion.new(major: number, minor: number): FormatNumberVersion
	local object = newproxy(true)
	local object_meta = getmetatable(object)

	object_meta.__index = {
		Major = double_to_int32(major),
		Minor = double_to_int32(minor),
	}
	object_meta.__metatable = "The metatable is locked"
	object_meta.__tostring = version_tostring
	object_meta.__lt = version_lt
	object_meta.__eq = version_eq
	table.freeze(object_meta)

	return object
end

FormatNumberVersion.current = FormatNumberVersion.new(31, 1)

return table.freeze(FormatNumberVersion)