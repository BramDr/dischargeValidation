library(ncdf4)
rm(list = ls())

infile = "data/grdcDischarge_global30min_largestArea.nc"
outfile = "data/sampleRhine.nc"

in.nc = nc_open(infile)
name = ncvar_get(in.nc, in.nc$var$river_name)
time = as.Date(in.nc$dim$time$vals, origin = "1806-01-01")
time.s = which(time == "1980-01-01")
time.e = which(time == "1983-12-31")
time.c = time.e - time.s + 1

time.dim = ncdim_def(name = in.nc$dim$time$name,
                     units = in.nc$dim$time$units,
                     vals = time.s:time.e,
                     calendar = "standard")
dis.var = ncvar_def(name = in.nc$var$dis$name,
                    units = in.nc$var$dis$units,
                    dim = list(in.nc$dim$lon, in.nc$dim$lat, time.dim),
                    missval = in.nc$var$dis$missval,
                    longname = in.nc$var$dis$longname,
                    prec = in.nc$var$dis$prec,
                    shuffle = in.nc$var$dis$shuffle,
                    compression = in.nc$var$dis$compression,
                    chunksizes = c(1,1,time.c))
river.var = in.nc$var$river_name
area.var = in.nc$var$area_observed
altitude.var = in.nc$var$altitude
days.var = in.nc$var$days_observations
out.nc = nc_create(filename = outfile, vars = list(dis.var, river.var, area.var, altitude.var, days.var))

for(x in 1:in.nc$dim$lon$len){
  for(y in 1:in.nc$dim$lat$len){
    if(name[x,y] != "RHINE RIVER"){
      next
    }

    print(1)
    ncvar_put(out.nc, out.nc$var$dis,
              vals = ncvar_get(in.nc, in.nc$var$dis, start = c(x,y,time.s), count = c(1,1,time.c)),
              start = c(x,y,1), count = c(1,1,-1))

    print(1)
    ncvar_put(out.nc, out.nc$var$river_name,
              vals = ncvar_get(in.nc, in.nc$var$river_name, start = c(1,x,y), count = c(-1,1,1)),
              start = c(1,x,y), count = c(-1,1,1))

    print(1)
    ncvar_put(out.nc, out.nc$var$area_observed,
              vals = ncvar_get(in.nc, in.nc$var$area_observed, start = c(x,y), count = c(1,1)),
              start = c(x,y), count = c(1,1))

    print(1)
    ncvar_put(out.nc, out.nc$var$altitude,
              vals = ncvar_get(in.nc, in.nc$var$altitude, start = c(x,y), count = c(1,1)),
              start = c(x,y), count = c(1,1))

    print(1)
    ncvar_put(out.nc, out.nc$var$days_observations,
              vals = ncvar_get(in.nc, in.nc$var$days_observations, start = c(x,y), count = c(1,1)),
              start = c(x,y), count = c(1,1))
  }
}
nc_close(out.nc)
nc_close(in.nc)
