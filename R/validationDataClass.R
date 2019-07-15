validationDataClass = function() {
  return("validationData")
}

#' Checks wether an object is of type "validationData"
#'
#' @param x The object
#'
#' @return  true or false
#' @export
#'
#' @examples
#' obsFile = system.file("data", "obsSampleRhine.nc", package = "dischargeValidation", mustWork = T)
#' simFiles = system.file("data", "simSampleRhine.nc", package = "dischargeValidation", mustWork = T)
#' locations = getLocationsFromBoundingBox(obsFile = obsFile, boundingBox = c(6.75,10.25,47.75,51.25))
#' data = getData(obsFile = obsFile, simFiles = simFiles, location = locations[1:4])
#'
#' isValidationData(data)
isValidationData = function(x) {
  if (class(x) == validationDataClass()) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}
