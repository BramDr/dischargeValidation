#' Get validation data object for further analysis
#'
#' @param obsFile Path to the observation file.
#' @param simFiles Path to the simulation file(s). This can also be an empty vector.
#' @param locations List of station locations containing lon/lat values in a vector.
#' @param simOrigins Date origin of the simulation(s). A value per simulation file is required. Defaults to VIC origin.
#' @param simVars Variable name of the simulation(s) to retreive. A value per simulation file is required. Defaults to VIC discharge variable.
#' @param simSkips Number of months to skip for the simulation(s). A value per simulation file is required. Defaults to 0.
#' @param obsOrigin Date origin of the observations.
#' @param obsVar Variable name of the observations to retreive.
#' @param attVars Variable name of attribute(s) to retrieve. If "all" is used, all attributes are retrieved. A variable is recognized as an attribute if it has only lon & lat dimensions (characters can have three dimensions to form strings).
#'
#' @return An object containing values for nloc, nsim, ntime, time, observations, simulations and the requested attributes
#' @export
#'
#' @import ncdf4
#' @examples
#' obsFile = system.file("data", "obsSampleRhine.nc", package = "dischargeValidation", mustWork = T)
#' simFiles = system.file("data", "simSampleRhine.nc", package = "dischargeValidation", mustWork = T)
#' locations = getLocationsFromBoundingBox(obsFile = obsFile, boundingBox = c(6.75,10.25,47.75,51.25))
#'
#' data = getData(obsFile = obsFile, simFiles = simFiles, location = locations[1:4])
getData <- function(obsFile,
                    simFiles,
                    locations,
                    simOrigins = rep("0000-12-30", length(simFiles)),
                    simVars = rep("OUT_DISCHARGE", length(simFiles)),
                    simSkips = rep(0, length(simFiles)),
                    obsOrigin = "1806-01-01",
                    obsVar = "dis",
                    attVars = "all")
{
  # Set time
  time = getTime(obsFile = obsFile,
                 simFiles = simFiles,
                 simOrigins = simOrigins,
                 simSkips = simSkips,
                 obsOrigin = obsOrigin)

  # Set attributes
  if(attVars == "all"){
    attVars = c()

    nc = nc_open(obsFile)
    for(var in nc$var){
      if((var$prec == "char" && var$ndims == 3) &&
         var$dim[[2]]$name == nc$dim$lon$name &&
         var$dim[[3]]$name == nc$dim$lat$name){
        attVars = c(attVars, var$name)
      } else if(var$ndims == 2 &&
        var$dim[[1]]$name == nc$dim$lon$name &&
        var$dim[[2]]$name == nc$dim$lat$name){
          attVars = c(attVars, var$name)
      }
    }
    nc_close(nc)
  }

  nloc = length(locations)
  nsim = length(simFiles)
  ntime = length(time)
  natt = length(attVars)

  observations = array(data = NA, dim = c(nloc, ntime))
  simulations = array(data = NA, dim = c(nloc, nsim, ntime))
  attributes.list = list()

  # Set values
  for (iLoc in 1:nloc) {
    location = locations[[iLoc]]
    print(paste0("Location: ",
                 location[2], " N ", location[1], " E ",
                 "(", iLoc, " of ", length(locations), ")"))

    # Load observation data
    observations[iLoc,1:ntime] = getValues(file = obsFile,
                                                 location = location,
                                                 variable = obsVar,
                                                 origin = obsOrigin,
                                                 time = time)

    for (iSim in 1:nsim) {
      simFile = simFiles[iSim]
      simOrigin = simOrigins[iSim]
      simVar = simVars[iSim]

      # Load simulation data
      simulations[iLoc,iSim,1:ntime] = getValues(file = simFile,
                                                       location = location,
                                                       variable = simVar,
                                                       origin = simOrigin,
                                                       time = time)
    }

    # Load attribute data
    attributes.list[[iLoc]] = getAttributes(file = obsFile,
                                                   location = location,
                                                   variable = attVars)
  }

  # Convert attributes
  attributes = list()
  for (iAtt in 1:natt){
    attVar = attVars[iAtt]
    for (iLoc in 1:nloc){
      value = unlist(attributes.list[[iLoc]][[attVar]], use.names = F)

      if(iLoc == 1){
        attributes[[attVar]] = value
      } else {
        attributes[[attVar]] = c(attributes[[attVar]], value)
      }
    }
  }

  ## Create object
  datum = list(nloc = nloc,
               ntime = ntime,
               nsim = nsim,
               time = time,
               observations = observations,
               simulations = simulations)
  datum = c(datum, attributes)
  class(datum) = validationDataClass()
  return(datum)
}
