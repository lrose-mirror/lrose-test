#!/usr/bin/env python

#===========================================================================
#
# Grid and plot irregular dataProduce plots for noise mon data by time
#
#===========================================================================

from __future__ import print_function

import os
import sys
import subprocess
from optparse import OptionParser
import numpy as np
from scipy.interpolate import griddata
from numpy import convolve
from numpy import linalg, array, ones
import matplotlib.pyplot as plt
from matplotlib import dates
import numpy.ma as ma
from numpy.random import uniform, seed
import math
import datetime
import contextlib

def main():

#   globals

    global options
    global debug

# parse the command line

    usage = "usage: %prog [options]"
    parser = OptionParser(usage)
    parser.add_option('--debug',
                      dest='debug', default=False,
                      action="store_true",
                      help='Set debugging on')
    parser.add_option('--verbose',
                      dest='verbose', default=False,
                      action="store_true",
                      help='Set verbose debugging on')
    parser.add_option('--width',
                      dest='figWidthMm',
                      default=400,
                      help='Width of figure in mm')
    parser.add_option('--height',
                      dest='figHeightMm',
                      default=200,
                      help='Height of figure in mm')
    parser.add_option('--minX',
                      dest='minX',
                      default=-2.0,
                      help='Minimum X val')
    parser.add_option('--maxX',
                      dest='maxX',
                      default=2.0,
                      help='Maximum X val')
    parser.add_option('--minY',
                      dest='minY',
                      default=-2.0,
                      help='Minimum Y val')
    parser.add_option('--maxY',
                      dest='maxY',
                      default=2.0,
                      help='Maximum Y val')
    parser.add_option('--nX',
                      dest='nX',
                      default=200,
                      help='Number of regular grid locations in X')
    parser.add_option('--nY',
                      dest='nY',
                      default=200,
                      help='Number of regular grid locations in Y')
    parser.add_option('--nPts',
                      dest='nPts',
                      default=500,
                      help='Number of points in data set')

    (options, args) = parser.parse_args()
    
    if (options.verbose):
        options.debug = True

    global nPts, minX, maxX, minY, maxY, xRange, yRange
    nPts = int(options.nPts)
    minX = float(options.minX)
    maxX = float(options.maxX)
    minY = float(options.minY)
    maxY = float(options.maxY)
    xRange = maxX - minX
    yRange = maxY - minY

    if (options.debug):
        print("Running %prog", file=sys.stderr)
        print("  minX: ", options.minX, file=sys.stderr)
        print("  maxX: ", options.maxX, file=sys.stderr)
        print("  minY: ", options.minY, file=sys.stderr)
        print("  maxY: ", options.maxY, file=sys.stderr)
        print("  nX: ", options.nX, file=sys.stderr)
        print("  nY: ", options.nY, file=sys.stderr)
        print("  nPts: ", options.nPts, file=sys.stderr)

    # render the plot
    
    doPlot()

    sys.exit(0)
    
########################################################################
# Plot

def doPlot():
    
    # make up some randomly distributed data
    seed(1234)
    x = uniform(minX,maxX,nPts)
    y = uniform(minY,maxY,nPts)
    z = x*np.exp(-x**2-y**2)
    # define grid.
    xi = np.linspace(minX - xRange / 100.0,
                     maxX + xRange / 100.0,
                     options.nX)
    yi = np.linspace(minY - yRange / 100.0,
                     maxY + yRange / 100.0,
                     options.nY)
    # grid the data.
    zi = griddata((x, y), z, (xi[None,:], yi[:,None]), method='cubic')
    # contour the gridded data, plotting dots at the randomly spaced data points.
    CS = plt.contour(xi,yi,zi,15,linewidths=0.5,colors='k')
    CS = plt.contourf(xi,yi,zi,15,cmap=plt.cm.jet)
    plt.colorbar() # draw colorbar
    # plot data points.
    plt.scatter(x,y,marker='o',c='b',s=5)
    plt.xlim(minX,maxX)
    plt.ylim(minY,maxY)
    plt.title('griddata test (%d points)' % nPts)
    plt.show()

########################################################################
# Run a command in a shell, wait for it to complete

def runCommand(cmd):

    if (options.debug):
        print("running cmd:",cmd, file=sys.stderr)
    
    try:
        retcode = subprocess.call(cmd, shell=True)
        if retcode < 0:
            print("Child was terminated by signal: ", -retcode, file=sys.stderr)
        else:
            if (options.debug):
                print("Child returned code: ", retcode, file=sys.stderr)
    except OSError as e:
        print("Execution failed:", e, file=sys.stderr)

########################################################################
# Run - entry point

if __name__ == "__main__":
   main()

