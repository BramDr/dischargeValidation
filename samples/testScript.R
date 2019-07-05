library(dischargeValidation)

rm(list = ls())

obsFile = "data/obsSampleRhine.nc"
simFiles = c("data/simSampleRhine.nc")

locations = getLocationsFromSimulations(obsFile = obsFile,
                                        simFile = simFiles)
locations = getLocationsFromBoundingBox(obsFile = obsFile,
                                        boundingBox = c(6.75,10.25,47.75,51.25))

data = getData(obsFile = obsFile,
              simFiles = simFiles,
              location = locations[1:4])
isValidationData(data)

data.agg = aggregateData(data)
