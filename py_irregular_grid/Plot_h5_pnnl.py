#!/usr/bin/env python
# coding: utf-8

# In[3]:


get_ipython().run_line_magic('load_ext', 'autoreload')
get_ipython().run_line_magic('autoreload', '2')


# In[62]:


get_ipython().run_line_magic('matplotlib', 'inline')
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.tri as tri
#import xarray
import pandas as pd
import os
import sys
import glob
import h5py as h5
import math


# In[45]:


import rex


# In[46]:


pathwestcoast = '/datasets/US_wave/v1.0.0/West_Coast/West_Coast_wave_2010.h5'
a = h5.File(pathwestcoast,'r')


# In[47]:


# list variables
a.keys()


# In[48]:


# pull attributes of parameters listed above
a['significant_wave_height']


# In[49]:


# Plot mean wave direction

#meta = pd.DataFrame(a['meta'][...])
mwd = a['mean_wave_direction'][:]
print(mwd)

coord = a['coordinates'][:]
print(coord)
print(coord.shape)
print(mwd.shape)


# In[50]:


lats = coord[:,0]
print(lats)
lons = coord[:,1]
print(lons)


# In[ ]:


# mean wave direction from only one time
mwd_0 = mwd[0,:]

# check dim sizes
print(a['coordinates'])
print(a['mean_wave_direction'])

print(lats.shape)
print(lats)

print(lons.shape)
print(lons)

print(mwd_0.shape)
print(mwd_0)

mwd_0[mwd_0 == -999] = math.nan
print(mwd_0)

# create evenly spaced xi,yi over lon/lat ranges

xi = np.linspace(np.min(lons), np.max(lons), 500)
yi = np.linspace(np.min(lats), np.max(lats), 500)

# Linearly interpolate the data (lons, lats) on a grid defined by (xi, yi).
triang = tri.Triangulation(lons, lats)
interpolator = tri.LinearTriInterpolator(triang, mwd_0)
Xi, Yi = np.meshgrid(xi, yi)
zi = interpolator(Xi, Yi)

fig1,ax1 = plt.subplots(1,1)
ax1.contour(xi, yi, zi, levels=14, linewidths=0.5, colors='k')
cntr1 = ax1.contourf(xi, yi, zi, levels=14, cmap="RdBu_r")

fig.colorbar(cntr1, ax=ax1)
ax1.plot(x, y, 'ko', ms=3)
ax1.set(xlim=(-2, 2), ylim=(-2, 2))
ax1.set_title('grid and contour (%d points, %d grid points)' %
              (npts, ngridx * ngridy))

plt.show()


# In[60]:


# now plot a contour plot
X, Y = np.meshgrid(lons, lats, sparse=True)


# In[40]:


Z = pd.DataFrame(mwd_0).round()
print(Z)


# In[ ]:





# In[ ]:





# In[41]:


fig,ax = plt.subplots(1,1)
cp = ax.contourf(X,Y,Z)

fig.colorbar(cp) # Add a colorbar to a plot
ax.set_title('Filled Contours Plot')
#ax.set_xlabel('x (cm)')
ax.set_ylabel('y (cm)')
plt.show()


# In[12]:


time = a['time_index']
print(time)


# # test from examples:

# In[13]:


# Extract the average wave height
# Open .h5 file
with h5.File('/datasets/US_wave/v1.0.0/West_Coast/West_Coast_wave_2010.h5', mode='r') as f:
    # Extract meta data and convert from records array to DataFrame
    meta = pd.DataFrame(f['meta'][...])
    # Significant Wave Height
    swh = f['significant_wave_height']
    # Extract scale factor
   # scale_factor = swh.attrs['scale_factor']
    # Extract, average, and unscale wave height
    mean_swh = swh[...].mean(axis=0) 

# Add mean wave height to meta data
meta['Average Wave Height'] = mean_swh

print(mean_swh)


# In[14]:


# Extract time-series data for a single site
# Open .h5 file
with h5.File('/datasets/US_wave/v1.0.0/West_Coast/West_Coast_wave_2010.h5', mode='r') as f:
    # Extract time_index and convert to datetime
    # NOTE: time_index is saved as byte-strings and must be decoded
    time_index = pd.to_datetime(f['time_index'][...].astype(str))
    # Initialize DataFrame to store time-series data
    time_series = pd.DataFrame(index=time_index)
    # Extract wave height, direction, and period
    for var in ['significant_wave_height', 'mean_wave_direction',
                'mean_absolute_period']:
        # Get dataset
        ds = f[var]
        # Extract scale factor
    #   scale_factor = ds.attrs['scale_factor']
        # Extract site 100 and add to DataFrame
        time_series[var] = ds[:, 100] 
        print(time_series['significant_wave_height'])


# # Read observations

# In[43]:


import netCDF4 as nc

fn = '/projects/hindcastra/Cook_Inlet/46076.nc'
ds = nc.Dataset(fn)

# Variables in File
print(ds)

for var in ds.variables.values():
    print(var)
    
# print wind speed    
print(ds['WSPD'])

# access data values
windspeed = ds['WSPD'][:]


# # Plot the obs (time series)

# In[ ]:





# In[ ]:




