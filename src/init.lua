local FormatNumber = { }

FormatNumber.Version = require(script.Version)

FormatNumber.Main = require(script.Main)
FormatNumber.Simple = require(script.Simple)

FormatNumber.Test = require(script.Test)

return table.freeze(FormatNumber)
