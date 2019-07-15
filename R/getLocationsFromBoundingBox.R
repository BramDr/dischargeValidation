#' Get the location of stations based on the mask of the observation file and a bounding box
#'
#' @param obsFile Path to the observation file.
#' @param boundingBox Vector containing minimum longitude, maximum longitude, minimum latitude, maximum latitude (in that order)
#' @param obsVar bservation variable to be used as mask. If the variable is NA, it is assumed  the cell does not contain data. Variable dimensions > 2 only use the first slice of redundand dimensions. Defaults to GRDC_number.
#'
#' @return List of station locations containing lon/lat values in a vector.
#' @export
#'
#' @examples
#' obsFile = system.file("data", "obsSampleRhine.nc", package = "dischargeValidation", mustWork = T)
#' simFiles = system.file("data", "simSampleRhine.nc", package = "dischargeValidation", mustWork = T)
#'
#' locations = getLocationsFromBoundingBox(obsFile = obsFile, boundingBox = c(6.75,10.25,47.75,51.25))
#' @import ncdf4
getLocationsFromBoundingBox <- function(obsFile,
                                        boundingBox,
                                        obsVar = "area_observed"){
  locations = list()

  ## --- Load observation mask
  nc = nc_open(filename = obsFile)
  for(iVar in 1:nc$nvars){
    if(nc$var[[iVar]]$name == obsVar){
      start = count = rep(1, nc$var[[iVar]]$ndims)
      count[1:2] = -1

      obsMask = ncvar_get(nc = nc, varid = obsVar, start = start, count = count)
    }
  }

  obsLons = nc$dim$lon$vals
  obsLats = nc$dim$lat$vals
  nc_close(nc)

  if(!exists("obsMask")){
    stop(paste0("Could not find the observation mask variable \"", obsVar,"\""))
    return(locations)
  } else {
    print(paste0("Loaded observation mask (dimensions: ", dim(obsMask)[1], " by ", dim(obsMask)[2], ")"))
  }

  ## --- Find bounding box overlap based on lat/lon boundaries
  for(obsX in 1:dim(obsMask)[1]){
    for(obsY in 1:dim(obsMask)[2]){
      if(!(obsLons[obsX] >= boundingBox[1] && obsLons[obsX] <= boundingBox[2] &&
           obsLats[obsY] >= boundingBox[3] && obsLats[obsY] <= boundingBox[4])){
        next
      }
      if(is.na(obsMask[obsX,obsY])){
        next
      }

      locations[[length(locations) + 1]] = c(obsLons[obsX], obsLats[obsY])
    }
  }

  print(paste0("Found ", length(locations), " locations"))

  ## --- Return locations
  return(locations)
}
