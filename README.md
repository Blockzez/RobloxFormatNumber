# FormatNumber
This is a number formatting module for Roblox.

# Main API (FormatNumber.Main)
## NumberFormatter
The class to format the numbers, located in `FormatNumber.NumberFormatter`.

### Static methods
`function NumberFormatter.with(): NumberFormatter`
Creates a new number formatter with the default setting.

`function NumberFormatter.forSkeleton(skeleton: string): (boolean, NumberFormatter | string)`
Tries to create a new number formatter with the skeleton string provided. If unsuccessful (e.g. the skeleton syntax is invalid) then it returns `false` and a message string, otherwise it returns `true` and the NumberFormatter.
See the Number Skeletons section of this API documentation for the skeleton syntax.

### Methods
`function NumberFormatter:Format(value: string): string`
The number to format, it could be any Luau number. It accounts for negative numbers, infinities, and NaNs. It returns `string` instead of `FormattedNumber` to simplify the implementation of module.
`function NumberFormatter:ToSkeleton(): (boolean, string)`
Tries to convert it to skeleton. If it is unable to (like the settings having compact notation or symbols) then the first value will return `false` and a message stating that it is unsupported.
If it's successful then the first value will return `true` and the second value will return the skeleton.

#### Settings chain methods
These are methods that returns NumberFormatter with the specific settings changed. Calling the methods doesn’t change the NumberFormatter object itself as it is immutable so you have to use the NumberFormatter that it returned.

`function NumberFormatter:Notation(notation: FormatNumber.Notation): NumberFormatter`
See Notation.
`function NumberFormatter:Precision(precision: FormatNumber.Precision): NumberFormatter`
See Precision.
`function NumberFormatter:RoundingMode(roundingMode: FormatNumber.RoundingMode): NumberFormatter`
See FormatNumber.RoundingMode enum.
`function NumberFormatter:Grouping(strategy: FormatNumber.GroupingStrategy): NumberFormatter`
See FormatNumber.GroupingStrategy enum.
`function NumberFormatter:IntegerWidth(style: FormatNumber.IntegerWidth): NumberFormatter`
See IntegerWidth.
`function NumberFormatter:Sign(style: FormatNumber.SignDisplay): NumberFormatter`
See FormatNumber.SignDisplay enum.
`function NumberFormatter:Decimal(style: FormatNumber.DecimalSeparatorDisplay): NumberFormatter`
See FormatNumber.DecimalSeparatorDisplay enum.

## Notation
These specify how the number is rendered, located in `FormatNumber.Notation`.

### Static methods
`function Notation.scientific(): ScientificNotation`
`function Notation.engineering(): ScientificNotation`
Scientific notation and the engineering version of it respectively. Uses `E` as the exponent separator but you can change this through the `Symbols` settings.

`function Notation.compactWithSuffixThousands(suffixTable: {string}): CompactNotation`
Basically abbreviations with suffix appended, scaling by every thousands as the suffix changes.
The `suffixTable` argument does not respect the `__index` metamethod nor the `__len` metamethod.

`function Notation.simple(): SimpleNotation`
The standard formatting without any scaling. The default.

### ScientificNotation (methods)
ScientificNotation is a subclass of `Notation`.

`function ScientificNotation:WithMinExponentDigits(minExponetDigits: number): ScientificNotation`
The minimum, padding with zeroes if necessary.

`function ScientificNotation:WithExponentSignDisplay(FormatNumber.SignDisplay exponentSignDisplay): ScientificNotation`
See FormatNumber.SignDisplay enum.

### CompactNotation (methods)
No methods currently but this is created just in case. This is a subclass of `Notation`.

### SimpleNotation (methods)
No methods currently but this is created just in case. This is a subclass of `Notation`.

## Precision
These are precision settings and changes to what places/figures the number rounds to, located in `FormatNumber.Precision`. The default is `Precision.integer():WithMinDigits(2)` for abbreviations and `Precision.maxFraction(6)` otherwise (for compatibility reasons).

### Static methods
`function Precision.integer(): FractionPrecision`
Rounds the number to the nearest integer

`function Precision.minFraction(minFractionDigits: number): FractionPrecision`
`function Precision.maxFraction(maxFractionDigits: number): FractionPrecision`
`function Precision.minMaxFraction(minFractionDigits: number, maxFractionDigits: number): FractionPrecision`
`function Precision.fixedFraction(fixedFractionDigits: number): FractionPrecision`
Rounds the number to a certain fractional digits (or decimal places), min is the minimum fractional (decimal) digits to show, max is the fractional digits (decimal places) to round, fixed refers to both min and max.

`function Precision.minSignificantDigits(minSignificantDigits: number): SignificantDigitsPrecision`
`function Precision.maxSignificantDigits(maxSignificantDigits: number): SignificantDigitsPrecision`
`function Precision.minMaxSignificantDigits(minSignificantDigits: number, maxSignificantDigits: number): SignificantDigitsPrecision`
`function Precision.fixedFraction(fixedSignificantDigits: number): SignificantDigitsPrecision`
Round the number to a certain significant digits; min, max, and fixed are specified above but with significant digits.

`function Precision.unlimited(): Precision`
Show all available digits to its full precision.

### FractionPrecision (methods)
`FractionPrecision` is subclass of `Precision` with more options for the fractional (decimal) digits precision. Calling these methods is not required.

`function FractionPrecision:WithMinDigits(minSignificantDigits: number): Precision`
Round to the decimal places specified by the FractionPrecision object but keep at least the amount of significant digit specified by the argument.

`function FractionPrecision:WithMaxDigits(maxSignificantDigits: number): Precision`
Round to the decimal places specified by the FractionPrecision object but don’t keep any more the amount of significant digit specified by the argument.

### SignificantDigitsPrecision (methods)
No methods currently but this is created just in case. This is a subclass of `Precision`.

## IntegerWidth

### Static methods
`function IntegerWidth.zeroFillTo(minInt: number): IntegerWidth`
Zero fill numbers at the integer part of the number to guarantee at least certain digit in the integer part of the number.

### Methods
`function IntegerWidth:TruncateAt(maxInt: number): IntegerWidth`
Truncates the integer part of the number to certain digits.

## Enums
The associated numbers in all these enums are an implementation detail, please do not rely on them so instead of using `0`, use `FormatNumber.SignDisplay.AUTO`.

### FormatNumber.GroupingStrategy
This determines how the grouping separator (comma by default) is inserted - integer part only. There are three options.

* OFF - no grouping.
* MIN2 - grouping only on 5 digits or above. (default for compact notation - for compatibility reasons)
* ON_ALIGNED - always group the value. (default unless it’s compact notation)

Example:
Grouping strategy|123|1234|12345|123456|1234567
-|-|-|-|-|-
OFF|123|1234|12345|123456|1234567
MIN2|123|1234|12,345|123,456|1,234,567
ON_ALIGNED|123|1,234|12,345|123,456|1,234,567

### FormatNumber.SignDisplay
This determines how you display the plus sign (`+`) and the minus sign (`-`):

* AUTO - Displays the minus sign only if the value is negative (that includes -0 and -NaN). (default)
* ALWAYS - Displays the plus/minus sign on all values.
* NEVER - Don’t display the plus/minus sign.
* EXCEPT_ZERO - Display the plus/minus sign on all values except zero, numbers that round to zero and NaN.
* NEGATIVE - Display the minus sign only if the value is negative but do not display the minus sign on -0 and -NaN.

Example:
Sign display|+12|-12|+0|-0
-|-|-|-|-
AUTO|12|-12|0|-0
ALWAYS|+12|-12|+0|-0
NEVER|12|12|0|0
EXCEPT_ZERO|+12|-12|0|0
NEGATIVE|12|-12|0|0

### FormatNumber.RoundingMode
This determines the rounding mode. I only documented three rounding modes but there are others undocumented if you need it.

* HALF_EVEN - Round it to the nearest even if it’s in the midpoint, round it up if it’s above the midpoint and down otherwise. (default unless it’s compact or scientific/engineering notation)
* HALF_UP - Round it away from zero if it’s in the midpoint or above, down otherwise. (most familiar, this is probably the method you are taught at school)
* DOWN - Round the value towards zero (truncates the value). (default for compact and scientific/engineering notation)

Example:
Rounding mode|1.0|1.2|1.5|1.8|2.0|2.2|2.5|2.8
-|-|-|-|-|-|-|-|-
HALF_EVEN|1.0|1.0|2.0|2.0|2.0|2.0|2.0|3.0
HALF_UP|1.0|1.0|2.0|2.0|2.0|2.0|3.0|3.0
DOWN|1.0|1.0|1.0|1.0|2.0|2.0|2.0|2.0

### FormatNumber.DecimalSeparatorDisplay
This determines how the decimal separator (`.` by default) is displayed.

* AUTO - only show the decimal separators if there are at least one digits after it (default)
* ALWAYS - always display the decimal separator, even if there's no digits after it

Example:
Decimal separator display|1|1.5
-|-|-
AUTO|1|1.5
ALWAYS|1.|1.5

# Simple API (FormatNumberFolder.Simple)
`function FormatNumber.Format(value: number, skeleton: string?): string`
Formats a number with the skeleton settings if provided.
See the Number Skeletons section of this API documentation for the skeleton syntax.

`function FormatNumber.FormatCompact(value: number, skeleton: string?): string`
Formats a number in compact notation.
You'll need to provide the suffixes in the `Simple` ModuleScript. Multiple instances of suffixes are not supported
See the Number Skeletons section of this API documentation for the full skeleton syntax, but here's the several skeleton syntax for quick reference if you want to change precision (e.g. decimal places)
Skeleton|Precision description
-|-
precision-integer|no decimal places
precision-integer/@@\*|whatever returns the longer result out of no decimal places and 2 significant digits (default)
.#|1 decimal place
.##|2 decimal places
.###|3 decimal places
@#|2 significant digits
@##|3 significant digits

# Number Skeletons
This feature is introduced in version 31.
The syntax is identical to the one used in ICU, so you can use this page for reference: https://unicode-org.github.io/icu/userguide/format_parse/numbers/skeletons.html#skeleton-stems-and-options
See the Main API documentation for the settings.
Do note that for this module, it only supports the following part of the Skeleton Stems and Options of the page linked:
- Notation (but ignore `compact-short`/`K` and `compact-long`/`KK` as that's not supported)
- Precision (but ignore `precision-increment/dddd`, `precision-currency`, `precision-currency-cash`, and Trailing Zero Display as that's not supported)
- Rounding Mode (but ignore `rounding-mode-unnecessary` as that's not supported)
- Integer Width
- Grouping (but ignore `group-auto` and `group-thousands` as that's not supported)
- Sign Display (but ignore any accounting sign display)
- Decimal Separator Display
