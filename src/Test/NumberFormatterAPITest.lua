--[[
As I ported this from ICU to Luau, here's the copyright:
© 2017 and later: Unicode, Inc. and others.
License & terms of use: http://www.unicode.org/copyright.html
https://github.com/unicode-org/icu/blob/main/icu4c/source/test/intltest/numbertest_api.cpp
]]

local FormatNumber = require(script.Parent.Parent.Main)
local NumberFormatterAPITest = { }

local COMPACT_SUFFIXES = table.freeze({ "K", "M", "B", "T" })
local qnan = string.unpack("<d", "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x7F")

local function assert_equals(message: string, expected: string, actual: string)
	if expected ~= actual then
		error("FAIL: " .. message .. "; got \"" .. actual .. "\"; expected \"" .. expected .. "\"")
	end
end

local TEST_INDEX

function NumberFormatterAPITest.RunIndexedTest(index: number, exec: boolean): string
	local name
	-- deliberately put a repeat block just because ICU put a do while block
	-- could've used table for this but it works
	repeat
		-- start
		-- intentionally 0 to be in line with ICU
		local test_case_auto_n = 0
		--
		if index == test_case_auto_n then
			name = "NotationSimple"
			if exec then
				print("NotationSimple ---")
				NumberFormatterAPITest.NotationSimple()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "NotationScientific"
			if exec then
				print("NotationScientific ---")
				NumberFormatterAPITest.NotationScientific()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "NotationCompact"
			if exec then
				print("NotationCompact ---")
				NumberFormatterAPITest.NotationCompact()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "RoundingFraction"
			if exec then
				print("RoundingFraction ---")
				NumberFormatterAPITest.RoundingFraction()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "RoundingFigures"
			if exec then
				print("RoundingFigures ---")
				NumberFormatterAPITest.RoundingFigures()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "RoundingFractionFigures"
			if exec then
				print("RoundingFractionFigures ---")
				NumberFormatterAPITest.RoundingFractionFigures()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "RoundingOther"
			if exec then
				print("RoundingOther ---")
				NumberFormatterAPITest.RoundingOther()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "Grouping"
			if exec then
				print("Grouping ---")
				NumberFormatterAPITest.Grouping()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "IntegerWidth"
			if exec then
				print("IntegerWidth ---")
				NumberFormatterAPITest.IntegerWidth()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "Sign"
			if exec then
				print("Sign ---")
				NumberFormatterAPITest.Sign()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "SignNearZero"
			if exec then
				print("SignNearZero ---")
				NumberFormatterAPITest.SignNearZero()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "SignCoverage"
			if exec then
				print("SignCoverage ---")
				NumberFormatterAPITest.SignCoverage()
			end
			break
		end
		test_case_auto_n += 1
		if index == test_case_auto_n then
			name = "Decimal"
			if exec then
				print("Decimal ---")
				NumberFormatterAPITest.Decimal()
			end
			break
		end
		test_case_auto_n += 1

		-- end
		name = ""
		break
	until false

	return name
end

function NumberFormatterAPITest.NotationSimple()
	NumberFormatterAPITest.assert_format_descending(
		"Basic",
		"",
		"",
		FormatNumber.NumberFormatter.with(),
		"87,650",
		"8,765",
		"876.5",
		"87.65",
		"8.765",
		"0.8765",
		"0.08765",
		"0.008765",
		"0")

	NumberFormatterAPITest.assert_format_descending_big(
		"Big Simple",
		"notation-simple",
		"",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.simple()),
		"87,650,000",
		"8,765,000",
		"876,500",
		"87,650",
		"8,765",
		"876.5",
		"87.65",
		"8.765",
		"0")

	NumberFormatterAPITest.assert_format_single(
		"Basic with Negative Sign",
		"",
		"",
		FormatNumber.NumberFormatter.with(),
		-9876543.21,
		"-9,876,543.21")
end


function NumberFormatterAPITest.NotationScientific()
	-- default rounding mode different to ICU (DOWN rather than HALF_EVEN)
	NumberFormatterAPITest.assert_format_descending(
		"Scientific",
		"scientific",
		"E0",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.scientific()),
		"8.765E4",
		"8.765E3",
		"8.765E2",
		"8.765E1",
		"8.765E0",
		"8.765E-1",
		"8.765E-2",
		"8.765E-3",
		"0E0")

	NumberFormatterAPITest.assert_format_descending(
		"Engineering",
		"engineering",
		"EE0",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.engineering()),
		"87.65E3",
		"8.765E3",
		"876.5E0",
		"87.65E0",
		"8.765E0",
		"876.5E-3",
		"87.65E-3",
		"8.765E-3",
		"0E0")

	NumberFormatterAPITest.assert_format_descending(
		"Scientific sign always shown",
		"scientific/sign-always",
		"E+!0",
		FormatNumber.NumberFormatter.with():Notation(
		FormatNumber.Notation.scientific():WithExponentSignDisplay(FormatNumber.SignDisplay.ALWAYS)),
		"8.765E+4",
		"8.765E+3",
		"8.765E+2",
		"8.765E+1",
		"8.765E+0",
		"8.765E-1",
		"8.765E-2",
		"8.765E-3",
		"0E+0")

	NumberFormatterAPITest.assert_format_descending(
		"Scientific min exponent digits",
		"scientific/*ee",
		"E00",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.scientific():WithMinExponentDigits(2)),
		"8.765E04",
		"8.765E03",
		"8.765E02",
		"8.765E01",
		"8.765E00",
		"8.765E-01",
		"8.765E-02",
		"8.765E-03",
		"0E00")

	NumberFormatterAPITest.assert_format_single(
		"Scientific Negative",
		"scientific",
		"E0",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.scientific()),
		-1000000,
		"-1E6")

	NumberFormatterAPITest.assert_format_single(
		"Scientific Infinity",
		"scientific",
		"E0",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.scientific()),
		-math.huge,
		"-∞")

	NumberFormatterAPITest.assert_format_single(
		"Scientific NaN",
		"scientific",
		"E0",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.scientific()),
		qnan,
		"NaN")
end

function NumberFormatterAPITest.NotationCompact()
	-- default rounding mode different to ICU (DOWN rather than HALF_EVEN)
	NumberFormatterAPITest.assert_format_descending(
		"Compact Short",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		"87K",
		"8.7K",
		"876",
		"87",
		"8.7",
		"0.87",
		"0.087",
		"0.0087",
		"0")

	NumberFormatterAPITest.assert_format_single(
		"Compact with Negative Sign",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		-9876543.21,
		"-9.8M")

	NumberFormatterAPITest.assert_format_single(
		"Compact Rounding",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		990000,
		"990K")

	NumberFormatterAPITest.assert_format_single(
		"Compact Rounding",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		999000,
		"999K")

	NumberFormatterAPITest.assert_format_single(
		"Compact Rounding",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		999900,
		"999K")

	NumberFormatterAPITest.assert_format_single(
		"Compact Rounding",
		nil,
		nil,
		FormatNumber.NumberFormatter.with()
			:Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES))
			:RoundingMode(FormatNumber.RoundingMode.HALF_EVEN),
		999900,
		"1M")

	NumberFormatterAPITest.assert_format_single(
		"Compact Rounding",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		9900000,
		"9.9M")

	NumberFormatterAPITest.assert_format_single(
		"Compact Rounding",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		9990000,
		"9.9M")

	NumberFormatterAPITest.assert_format_single(
		"Compact Infinity",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		-math.huge,
		"-∞")

	NumberFormatterAPITest.assert_format_single(
		"Compact NaN",
		nil,
		nil,
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES)),
		qnan,
		"NaN")
end

function NumberFormatterAPITest.RoundingFraction()
	NumberFormatterAPITest.assert_format_descending(
		"Integer",
		"precision-integer",
		".",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.integer()),
		"87,650",
		"8,765",
		"876",
		"88",
		"9",
		"1",
		"0",
		"0",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"Fixed Fraction",
		".000",
		".000",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedFraction(3)),
		"87,650.000",
		"8,765.000",
		"876.500",
		"87.650",
		"8.765",
		"0.876",
		"0.088",
		"0.009",
		"0.000")

	NumberFormatterAPITest.assert_format_descending(
		"Min Fraction",
		".0*",
		".0+",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.minFraction(1)),
		"87,650.0",
		"8,765.0",
		"876.5",
		"87.65",
		"8.765",
		"0.8765",
		"0.08765",
		"0.008765",
		"0.0")

	NumberFormatterAPITest.assert_format_descending(
		"Max Fraction",
		".#",
		".#",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.maxFraction(1)),
		"87,650",
		"8,765",
		"876.5",
		"87.6",
		"8.8",
		"0.9",
		"0.1",
		"0",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"Min/Max Fraction",
		".0##",
		".0##",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.minMaxFraction(1, 3)),
		"87,650.0",
		"8,765.0",
		"876.5",
		"87.65",
		"8.765",
		"0.876",
		"0.088",
		"0.009",
		"0.0")
end

function NumberFormatterAPITest.RoundingFigures()
	NumberFormatterAPITest.assert_format_single(
		"Fixed Significant",
		"@@@",
		"@@@",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedSignificantDigits(3)),
		-98,
		"-98.0")

	NumberFormatterAPITest.assert_format_single(
		"Fixed Significant Rounding",
		"@@@",
		"@@@",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedSignificantDigits(3)),
		-98.7654321,
		"-98.8")

	NumberFormatterAPITest.assert_format_single(
		"Fixed Significant at rounding boundary",
		"@@@",
		"@@@",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedSignificantDigits(3)),
		9.999,
		"10.0")

	NumberFormatterAPITest.assert_format_single(
		"Fixed Significant Zero",
		"@@@",
		"@@@",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedSignificantDigits(3)),
		0,
		"0.00")

	NumberFormatterAPITest.assert_format_single(
		"Min Significant",
		"@@*",
		"@@+",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.minSignificantDigits(2)),
		-9,
		"-9.0")

	NumberFormatterAPITest.assert_format_single(
		"Max Significant",
		"@###",
		"@###",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.maxSignificantDigits(4)),
		98.7654321,
		"98.77")

	NumberFormatterAPITest.assert_format_single(
		"Min/Max Significant",
		"@@@#",
		"@@@#",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.minMaxSignificantDigits(3, 4)),
		9.99999,
		"10.0")

	NumberFormatterAPITest.assert_format_single(
		"Fixed Significant on zero with lots of integer width",
		"@ integer-width/+000",
		"@ 000",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedSignificantDigits(1))
			:IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(3)),
		0,
		"000")

	NumberFormatterAPITest.assert_format_single(
		"Fixed Significant on zero with zero integer width",
		"@ integer-width/*",
		"@ integer-width/+",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedSignificantDigits(1))
			:IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(0)),
		0,
		"0")
end

function NumberFormatterAPITest.RoundingFractionFigures()
	NumberFormatterAPITest.assert_format_descending(
		"Basic Significant", -- for comparison
		"@#",
		"@#",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.maxSignificantDigits(2)),
		"88,000",
		"8,800",
		"880",
		"88",
		"8.8",
		"0.88",
		"0.088",
		"0.0088",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"FracSig minMaxFrac minSig",
		".0#/@@@*",
		".0#/@@@+",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.minMaxFraction(1, 2):WithMinDigits(3)),
		"87,650.0",
		"8,765.0",
		"876.5",
		"87.65",
		"8.76",
		"0.876", -- minSig beats maxFrac
		"0.0876", -- minSig beats maxFrac
		"0.00876", -- minSig beats maxFrac
		"0.0")

	NumberFormatterAPITest.assert_format_descending(
		"FracSig minMaxFrac maxSig A",
		".0##/@#",
		".0##/@#",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.minMaxFraction(1, 3):WithMaxDigits(2)),
		"88,000.0", -- maxSig beats maxFrac
		"8,800.0", -- maxSig beats maxFrac
		"880.0", -- maxSig beats maxFrac
		"88.0", -- maxSig beats maxFrac
		"8.8", -- maxSig beats maxFrac
		"0.88", -- maxSig beats maxFrac
		"0.088",
		"0.009",
		"0.0")

	NumberFormatterAPITest.assert_format_descending(
		"FracSig minMaxFrac maxSig B",
		".00/@#",
		".00/@#",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedFraction(2):WithMaxDigits(2)),
		"88,000.00", -- maxSig beats maxFrac
		"8,800.00", -- maxSig beats maxFrac
		"880.00", -- maxSig beats maxFrac
		"88.00", -- maxSig beats maxFrac
		"8.80", -- maxSig beats maxFrac
		"0.88",
		"0.09",
		"0.01",
		"0.00")

	NumberFormatterAPITest.assert_format_single(
		"FracSig with trailing zeros A",
		".00/@@@*",
		".00/@@@+",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedFraction(2):WithMinDigits(3)),
		0.1,
		"0.10")

	NumberFormatterAPITest.assert_format_single(
		"FracSig with trailing zeros B",
		".00/@@@*",
		".00/@@@+",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedFraction(2):WithMinDigits(3)),
		0.0999999,
		"0.10")

	NumberFormatterAPITest.assert_format_descending(
		"FracSig withSignificantDigits RELAXED",
		"precision-integer/@#r",
		"./@#r",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.maxFraction(0)
			:WithSignificantDigits(1, 2, FormatNumber.RoundingPriority.RELAXED)),
		"87,650",
		"8,765",
		"876",
		"88",
		"8.8",
		"0.88",
		"0.088",
		"0.0088",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"FracSig withSignificantDigits STRICT",
		"precision-integer/@#s",
		"./@#s",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.maxFraction(0)
			:WithSignificantDigits(1, 2, FormatNumber.RoundingPriority.STRICT)),
		"88,000",
		"8,800",
		"880",
		"88",
		"9",
		"1",
		"0",
		"0",
		"0")

	NumberFormatterAPITest.assert_format_single(
		"FracSig withSignificantDigits Trailing Zeros RELAXED",
		".0/@@@r",
		".0/@@@r",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedFraction(1)
			:WithSignificantDigits(3, 3, FormatNumber.RoundingPriority.RELAXED)),
			1,
		"1.00")

	-- Trailing zeros follow the strategy that was chosen:
	NumberFormatterAPITest.assert_format_single(
		"FracSig withSignificantDigits Trailing Zeros STRICT",
		".0/@@@s",
		".0/@@@s",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedFraction(1)
			:WithSignificantDigits(3, 3, FormatNumber.RoundingPriority.STRICT)),
		1,
		"1.0")

	NumberFormatterAPITest.assert_format_single(
		"FracSig withSignificantDigits at rounding boundary",
		"precision-integer/@@@s",
		"./@@@s",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.fixedFraction(0)
			:WithSignificantDigits(3, 3, FormatNumber.RoundingPriority.STRICT)),
		9.99,
		"10")
end

function NumberFormatterAPITest.RoundingOther()
	NumberFormatterAPITest.assert_format_descending(
		"Rounding None",
		"precision-unlimited",
		".+",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.unlimited()),
		"87,650",
		"8,765",
		"876.5",
		"87.65",
		"8.765",
		"0.8765",
		"0.08765",
		"0.008765",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"Rounding Mode CEILING",
		"precision-integer rounding-mode-ceiling",
		". rounding-mode-ceiling",
		FormatNumber.NumberFormatter.with():Precision(FormatNumber.Precision.integer()):RoundingMode(FormatNumber.RoundingMode.CEILING),
		"87,650",
		"8,765",
		"877",
		"88",
		"9",
		"1",
		"1",
		"1",
		"0")

	NumberFormatterAPITest.assert_format_single(
		"ICU-20974 Double.MIN_NORMAL",
		"scientific",
		"E0",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.scientific()),
		math.ldexp(1, -1022),
		"2.225073E-308")

	-- this behavior is more like icu4c rather than icu4j
	NumberFormatterAPITest.assert_format_single(
		"ICU-20974 Double.MIN_VALUE",
		"scientific",
		"E0",
		FormatNumber.NumberFormatter.with():Notation(FormatNumber.Notation.scientific()),
		4.9E-324,
		"5E-324")
end

function NumberFormatterAPITest.Grouping()
	NumberFormatterAPITest.assert_format_descending_big(
		"Western Grouping",
		"group-on-aligned",
		",!",
		FormatNumber.NumberFormatter.with():Grouping(FormatNumber.GroupingStrategy.ON_ALIGNED),
		"87,650,000",
		"8,765,000",
		"876,500",
		"87,650",
		"8,765",
		"876.5",
		"87.65",
		"8.765",
		"0")

	NumberFormatterAPITest.assert_format_descending_big(
		"Western Grouping, Min 2",
		"group-min2",
		",?",
		FormatNumber.NumberFormatter.with():Grouping(FormatNumber.GroupingStrategy.MIN2),
		"87,650,000",
		"8,765,000",
		"876,500",
		"87,650",
		"8765",
		"876.5",
		"87.65",
		"8.765",
		"0")

	NumberFormatterAPITest.assert_format_descending_big(
		"No Grouping",
		"group-off",
		",_",
		FormatNumber.NumberFormatter.with():Grouping(FormatNumber.GroupingStrategy.OFF),
		"87650000",
		"8765000",
		"876500",
		"87650",
		"8765",
		"876.5",
		"87.65",
		"8.765",
		"0")
end

function NumberFormatterAPITest.IntegerWidth()
	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Default",
		"integer-width/+0",
		"0",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(1)),
		"87,650",
		"8,765",
		"876.5",
		"87.65",
		"8.765",
		"0.8765",
		"0.08765",
		"0.008765",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Zero Fill 0",
		"integer-width/*",
		"integer-width/+",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(0)),
		"87,650",
		"8,765",
		"876.5",
		"87.65",
		"8.765",
		".8765",
		".08765",
		".008765",
		"0")  -- see ICU-20844

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Zero Fill 3",
		"integer-width/+000",
		"000",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(3)),
		"87,650",
		"8,765",
		"876.5",
		"087.65",
		"008.765",
		"000.8765",
		"000.08765",
		"000.008765",
		"000")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Max 3",
		"integer-width/##0",
		"integer-width/##0",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(1):TruncateAt(3)),
		"650",
		"765",
		"876.5",
		"87.65",
		"8.765",
		"0.8765",
		"0.08765",
		"0.008765",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Fixed 2",
		"integer-width/00",
		"integer-width/00",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(2):TruncateAt(2)),
		"50",
		"65",
		"76.5",
		"87.65",
		"08.765",
		"00.8765",
		"00.08765",
		"00.008765",
		"00")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Compact",
		nil,
		nil,
		FormatNumber.NumberFormatter.with()
			:Notation(FormatNumber.Notation.compactWithSuffixThousands(COMPACT_SUFFIXES))
			:IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(3):TruncateAt(3)),
		"087K",
		"008.7K",
		"876",
		"087",
		"008.7",
		"000.87",
		"000.087",
		"000.0087",
		"000")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Scientific",
		"scientific integer-width/000",
		"scientific integer-width/000",
		FormatNumber.NumberFormatter.with()
			:Notation(FormatNumber.Notation.scientific())
			:IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(3):TruncateAt(3)),
		"008.765E4",
		"008.765E3",
		"008.765E2",
		"008.765E1",
		"008.765E0",
		"008.765E-1",
		"008.765E-2",
		"008.765E-3",
		"000E0")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Engineering",
		"engineering integer-width/000",
		"engineering integer-width/000",
		FormatNumber.NumberFormatter.with()
			:Notation(FormatNumber.Notation.engineering())
			:IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(3):TruncateAt(3)),
		"087.65E3",
		"008.765E3",
		"876.5E0",
		"087.65E0",
		"008.765E0",
		"876.5E-3",
		"087.65E-3",
		"008.765E-3",
		"000E0")

	NumberFormatterAPITest.assert_format_single(
		"Integer Width Remove All A",
		"integer-width/00",
		"integer-width/00",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(2):TruncateAt(2)),
		2500,
		"00")

	NumberFormatterAPITest.assert_format_single(
		"Integer Width Remove All B",
		"integer-width/00",
		"integer-width/00",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(2):TruncateAt(2)),
		25000,
		"00")

	NumberFormatterAPITest.assert_format_single(
		"Integer Width Remove All B, Bytes Mode",
		"integer-width/00",
		"integer-width/00",
		FormatNumber.NumberFormatter.with():IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(2):TruncateAt(2)),
		-- Note: this double produces all 17 significant digits
		10000000000000002000.0,
		"00")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Double Zero (ICU-21590)",
		"integer-width-trunc",
		"integer-width-trunc",
		FormatNumber.NumberFormatter.with()
			:IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(0):TruncateAt(0)),
		"0",
		"0",
		".5",
		".65",
		".765",
		".8765",
		".08765",
		".008765",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"Integer Width Double Zero with minFraction (ICU-21590)",
		"integer-width-trunc .0*",
		"integer-width-trunc .0*",
		FormatNumber.NumberFormatter.with()
			:IntegerWidth(FormatNumber.IntegerWidth.zeroFillTo(0):TruncateAt(0))
			:Precision(FormatNumber.Precision.minFraction(1)),
		".0",
		".0",
		".5",
		".65",
		".765",
		".8765",
		".08765",
		".008765",
		".0")
end

function NumberFormatterAPITest.Sign()
	NumberFormatterAPITest.assert_format_single(
		"Sign Auto Positive",
		"sign-auto",
		"",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.AUTO),
		444444,
		"444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Auto Negative",
		"sign-auto",
		"",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.AUTO),
		-444444,
		"-444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Auto Zero",
		"sign-auto",
		"",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.AUTO),
		0,
		"0")

	NumberFormatterAPITest.assert_format_single(
		"Sign Always Positive",
		"sign-always",
		"+!",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.ALWAYS),
		444444,
		"+444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Always Negative",
		"sign-always",
		"+!",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.ALWAYS),
		-444444,
		"-444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Always Zero",
		"sign-always",
		"+!",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.ALWAYS),
		0,
		"+0")

	NumberFormatterAPITest.assert_format_single(
		"Sign Never Positive",
		"sign-never",
		"+_",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.NEVER),
		444444,
		"444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Never Negative",
		"sign-never",
		"+_",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.NEVER),
		-444444,
		"444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Never Zero",
		"sign-never",
		"+_",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.NEVER),
		0,
		"0")

	NumberFormatterAPITest.assert_format_single(
		"Sign Except-Zero Positive",
		"sign-except-zero",
		"+?",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.EXCEPT_ZERO),
		444444,
		"+444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Except-Zero Negative",
		"sign-except-zero",
		"+?",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.EXCEPT_ZERO),
		-444444,
		"-444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Except-Zero Zero",
		"sign-except-zero",
		"+?",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.EXCEPT_ZERO),
		0,
		"0")

	NumberFormatterAPITest.assert_format_single(
		"Sign Negative Positive",
		"sign-negative",
		"+-",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.NEGATIVE),
		444444,
		"444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Negative Negative",
		"sign-negative",
		"+-",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.NEGATIVE),
		-444444,
		"-444,444")

	NumberFormatterAPITest.assert_format_single(
		"Sign Negative Negative Zero",
		"sign-negative",
		"+-",
		FormatNumber.NumberFormatter.with():Sign(FormatNumber.SignDisplay.NEGATIVE),
		-0.0000001,
		"0")
end

function NumberFormatterAPITest.SignNearZero()
	-- https://unicode-org.atlassian.net/browse/ICU-20709
	local cases = {
		{ FormatNumber.SignDisplay.AUTO,  1.1, "1" },
		{ FormatNumber.SignDisplay.AUTO,  0.9, "1" },
		{ FormatNumber.SignDisplay.AUTO,  0.1, "0" },
		{ FormatNumber.SignDisplay.AUTO, -0.1, "-0" }, -- interesting case
		{ FormatNumber.SignDisplay.AUTO, -0.9, "-1" },
		{ FormatNumber.SignDisplay.AUTO, -1.1, "-1" },
		{ FormatNumber.SignDisplay.ALWAYS,  1.1, "+1" },
		{ FormatNumber.SignDisplay.ALWAYS,  0.9, "+1" },
		{ FormatNumber.SignDisplay.ALWAYS,  0.1, "+0" },
		{ FormatNumber.SignDisplay.ALWAYS, -0.1, "-0" },
		{ FormatNumber.SignDisplay.ALWAYS, -0.9, "-1" },
		{ FormatNumber.SignDisplay.ALWAYS, -1.1, "-1" },
		{ FormatNumber.SignDisplay.EXCEPT_ZERO,  1.1, "+1" },
		{ FormatNumber.SignDisplay.EXCEPT_ZERO,  0.9, "+1" },
		{ FormatNumber.SignDisplay.EXCEPT_ZERO,  0.1, "0" }, -- interesting case
		{ FormatNumber.SignDisplay.EXCEPT_ZERO, -0.1, "0" }, -- interesting case
		{ FormatNumber.SignDisplay.EXCEPT_ZERO, -0.9, "-1" },
		{ FormatNumber.SignDisplay.EXCEPT_ZERO, -1.1, "-1" },
		{ FormatNumber.SignDisplay.NEGATIVE,  1.1, "1" },
		{ FormatNumber.SignDisplay.NEGATIVE,  0.9, "1" },
		{ FormatNumber.SignDisplay.NEGATIVE,  0.1, "0" },
		{ FormatNumber.SignDisplay.NEGATIVE, -0.1, "0" }, -- interesting case
		{ FormatNumber.SignDisplay.NEGATIVE, -0.9, "-1" },
		{ FormatNumber.SignDisplay.NEGATIVE, -1.1, "-1" },
	}
	for _, cas in cases do
		local sign, input, expected = table.unpack(cas)
		local actual = FormatNumber.NumberFormatter.with()
			:Sign(sign)
			:Precision(FormatNumber.Precision.integer())
			:Format(input)
		assert(
			expected == actual,
			input .. " @ SignDisplay " .. sign
		)
	end
end

function NumberFormatterAPITest.SignCoverage()
	-- https://unicode-org.atlassian.net/browse/ICU-20708
	local cases = {
		{ FormatNumber.SignDisplay.AUTO, {        "-∞", "-1", "-0",  "0",  "1",  "∞",  "NaN", "-NaN" } },
		{ FormatNumber.SignDisplay.ALWAYS, {      "-∞", "-1", "-0", "+0", "+1", "+∞", "+NaN", "-NaN" } },
		{ FormatNumber.SignDisplay.NEVER, {        "∞",  "1",  "0",  "0",  "1",  "∞",  "NaN",  "NaN" } },
		{ FormatNumber.SignDisplay.EXCEPT_ZERO, { "-∞", "-1",  "0",  "0", "+1", "+∞",  "NaN",  "NaN" } },
	}
	local negNaN = string.unpack("<d", "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF")
	local inputs = {
		-math.huge, -1, -0.0, 0, 1, math.huge, qnan, negNaN
	}
	for _, cas in cases do
		local sign = cas[1]
		for i, input in inputs do
			local input = inputs[i]
			local expected = cas[2][i]
			local actual = FormatNumber.NumberFormatter.with()
			:Sign(sign)
			:Format(input)
			assert(
				expected == actual,
				input .. " " .. sign
			)
		end
	end
end

function NumberFormatterAPITest.Decimal()
	NumberFormatterAPITest.assert_format_descending(
		"Decimal Default",
		"decimal-auto",
		"",
		FormatNumber.NumberFormatter.with():Decimal(FormatNumber.DecimalSeparatorDisplay.AUTO),
		"87,650",
		"8,765",
		"876.5",
		"87.65",
		"8.765",
		"0.8765",
		"0.08765",
		"0.008765",
		"0")

	NumberFormatterAPITest.assert_format_descending(
		"Decimal Always Shown",
		"decimal-always",
		"decimal-always",
		FormatNumber.NumberFormatter.with():Decimal(FormatNumber.DecimalSeparatorDisplay.ALWAYS),
		"87,650.",
		"8,765.",
		"876.5",
		"87.65",
		"8.765",
		"0.8765",
		"0.08765",
		"0.008765",
		"0.")
end

function NumberFormatterAPITest.assert_format_descending(
	message: string,
	skeleton: string?,
	concise_skeleton: string?,
	f: FormatNumber.NumberFormatter,
	...: string)
	local inputs = { 87650, 8765, 876.5, 87.65, 8.765, 0.8765, 0.08765, 0.008765, 0 }
	local expecteds = { ... }
	for i, d in inputs do
		local case_number = string.char(i + 0x2F) -- starts at 0 for consistency with ICU
		local expected = expecteds[i]
		local actual = f:Format(d)
		assert_equals(message .. ": Formatter Path: " .. case_number, expected, actual)
	end
	if skeleton and concise_skeleton then -- if nil, skeleton is declared as undefined.
		-- Only compare normalized skeletons: the tests need not provide the normalized forms.
		-- Use the normalized form to construct the testing formatter to guarantee no loss of info.
		local normalized = select(2,
			(select(
				2,
				FormatNumber.NumberFormatter.forSkeleton(skeleton)
				)
				:: FormatNumber.NumberFormatter)
			:ToSkeleton()
		)
		assert_equals(message .. ": Skeleton:", normalized, select(2, f:ToSkeleton()))

		local f2 = select(2, FormatNumber.NumberFormatter.forSkeleton(skeleton)) :: FormatNumber.NumberFormatter
		for i, d in inputs do
			local actual = f2:Format(d)
			assert(expecteds[i] == actual, message .. ": Skeleton Path: '" .. normalized .. "': " .. d)
		end

		-- Concise skeletons should have same output, and usually round-trip to the normalized skeleton.
		-- If the concise skeleton starts with '~', disable the round-trip check.
		local shouldRoundTrip = true
		if string.byte(concise_skeleton) == 0x7E then
			concise_skeleton = string.sub(concise_skeleton, 2)
			shouldRoundTrip = false
		end
		local f3 = select(2, FormatNumber.NumberFormatter.forSkeleton(concise_skeleton)) :: FormatNumber.NumberFormatter
		if shouldRoundTrip then
			assert_equals(
				message .. ": Concise Skeleton:",
				normalized, select(2, f3:ToSkeleton())
			)
		end
		for i, d in inputs do
			local actual = f3:Format(d)
			assert_equals(message .. ": Concise Skeleton Path: '" .. normalized .. "': " .. d, expecteds[i], actual)
		end
	else
		NumberFormatterAPITest.assert_undefined_skeleton(f)
	end
end

function NumberFormatterAPITest.assert_format_descending_big(
	message: string,
	skeleton: string?,
	concise_skeleton: string?,
	f: FormatNumber.NumberFormatter,
	...: string)
	local inputs = { 87650000, 8765000, 876500, 87650, 8765, 876.5, 87.65, 8.765, 0 }
	local expecteds = { ... }
	for i, d in inputs do
		local case_number = string.char(i + 0x2F) -- starts at 0 for consistency with ICU
		local expected = expecteds[i]
		local actual = f:Format(d)
		assert_equals(message .. ": Formatter Path: " .. case_number, expected, actual)
	end
	if skeleton and concise_skeleton then -- if nil, skeleton is declared as undefined.
		-- Only compare normalized skeletons: the tests need not provide the normalized forms.
		-- Use the normalized form to construct the testing formatter to guarantee no loss of info.
		local normalized = select(2,
			(select(
				2,
				FormatNumber.NumberFormatter.forSkeleton(skeleton)
				)
				:: FormatNumber.NumberFormatter)
			:ToSkeleton()
		)
		assert_equals(message .. ": Skeleton:", normalized, select(2, f:ToSkeleton()))

		local f2 = select(2, FormatNumber.NumberFormatter.forSkeleton(skeleton)) :: FormatNumber.NumberFormatter
		for i, d in inputs do
			local actual = f2:Format(d)
			assert(expecteds[i] == actual, message .. ": Skeleton Path: '" .. normalized .. "': " .. d)
		end

		-- Concise skeletons should have same output, and usually round-trip to the normalized skeleton.
		-- If the concise skeleton starts with '~', disable the round-trip check.
		local shouldRoundTrip = true
		if string.byte(concise_skeleton) == 0x7E then
			concise_skeleton = string.sub(concise_skeleton, 2)
			shouldRoundTrip = false
		end
		local f3 = select(2, FormatNumber.NumberFormatter.forSkeleton(concise_skeleton)) :: FormatNumber.NumberFormatter
		if shouldRoundTrip then
			assert_equals(
				message .. ": Concise Skeleton:",
				normalized, select(2, f3:ToSkeleton())
			)
		end
		for i, d in inputs do
			local actual = f3:Format(d)
			assert_equals(message .. ": Concise Skeleton Path: '" .. normalized .. "': " .. d, expecteds[i], actual)
		end
	else
		NumberFormatterAPITest.assert_undefined_skeleton(f)
	end
end


function NumberFormatterAPITest.assert_format_single(
	message: string,
	skeleton: string?,
	concise_skeleton: string?,
	f: FormatNumber.NumberFormatter,
	input: number,
	expected: string)

	local actual1 = f:Format(input)
	assert_equals(message .. ": Formatter Path", expected, actual1)

	if skeleton and concise_skeleton then -- if nil, skeleton is declared as undefined.
		-- Only compare normalized skeletons: the tests need not provide the normalized forms.
		-- Use the normalized form to construct the testing formatter to guarantee no loss of info.
		local normalized = select(2,
			(select(
				2,
				FormatNumber.NumberFormatter.forSkeleton(skeleton)
				)
				:: FormatNumber.NumberFormatter)
			:ToSkeleton()
		)
		assert_equals( message .. ": Skeleton:", normalized, select(2, f:ToSkeleton()))

		local f2 = select(2, FormatNumber.NumberFormatter.forSkeleton(skeleton)) :: FormatNumber.NumberFormatter
		local actual2 = f2:Format(input)
		assert_equals(message .. ": Skeleton Path: '" .. normalized .. "': " .. input, expected, actual2)

		-- Concise skeletons should have same output, and usually round-trip to the normalized skeleton.
		-- If the concise skeleton starts with '~', disable the round-trip check.
		local shouldRoundTrip = true
		if string.byte(concise_skeleton) == 0x7E then
			concise_skeleton = string.sub(concise_skeleton, 2)
			shouldRoundTrip = false
		end
		local f3 = select(2, FormatNumber.NumberFormatter.forSkeleton(concise_skeleton)) :: FormatNumber.NumberFormatter
		if shouldRoundTrip then
			assert_equals(
				message .. ": Concise Skeleton:",
				normalized, select(2, f3:ToSkeleton())
			)
		end
		local actual3 = f3:Format(input)
		assert_equals(message .. ": Concise Skeleton Path: '" .. normalized .. "': " .. input, expected, actual3)
	else
		NumberFormatterAPITest.assert_undefined_skeleton(f)
	end
end

function NumberFormatterAPITest.assert_undefined_skeleton(f: FormatNumber.NumberFormatter)
	local supported, skeleton = f:ToSkeleton()
	assert(
		not supported,
		"Expect toSkeleton to fail, but passed, producing: " .. skeleton
	)
end

return table.freeze(NumberFormatterAPITest)