library(dischargeValidation)

rm(list = ls())

obsFile = system.file("data", "obsSampleRhine.nc", package = "dischargeValidation", mustWork = T)
simFiles = system.file("data", "simSampleRhine.nc", package = "dischargeValidation", mustWork = T)

locations = getLocationsFromSimulations(obsFile = obsFile,
                                        simFile = simFiles)
locations = getLocationsFromBoundingBox(obsFile = obsFile,
                                        boundingBox = c(6.75,10.25,47.75,51.25))

data = getData(obsFile = obsFile,
              simFiles = simFiles,
              location = locations[1:4])
isValidationData(data)

data.agg = aggregateData(data)
