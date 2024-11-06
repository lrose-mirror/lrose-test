#!/usr/bin/env python3

#=====================================================================
#
# Generate a hex color scale from RGB values
#
#=====================================================================

import os
import sys
import time
import datetime
from datetime import timedelta

import string
import subprocess
from optparse import OptionParser

from sys import stdin
from subprocess import call

def main():
    
    global options

    global thisScriptName
    thisScriptName = os.path.basename(__file__)

    # parse the command line

    # parseArgs()

    #print("============================");

    convertRgbToHex(0,0,0)
    convertRgbToHex(72,61,139)
    convertRgbToHex(0,0,128)
    convertRgbToHex(0,0,255)
    convertRgbToHex(30,144,255)
    convertRgbToHex(0,191,255)
    convertRgbToHex(64,224,208)
    convertRgbToHex(60,179,113)
    convertRgbToHex(34,139,34)
    convertRgbToHex(107,142,35)
    convertRgbToHex(154,205,50)
    convertRgbToHex(105,105,105)
    convertRgbToHex(112,128,144)
    convertRgbToHex(255,255,0)
    convertRgbToHex(255,215,0)
    convertRgbToHex(255,165,0)
    convertRgbToHex(255,127,80)
    convertRgbToHex(255,0,0)
    convertRgbToHex(199,21,133)
    convertRgbToHex(255,20,147)
    convertRgbToHex(218,112,214)
    convertRgbToHex(221,160,221)
    convertRgbToHex(255,182,193)
    convertRgbToHex(0,0,0)
    
    #print("============================")

    sys.exit(0)

########################################################################
# Compute sweep time

def convertRgbToHex(rr, gg, bb):

    rrHex = hex(rr)[2:]
    ggHex = hex(gg)[2:]
    bbHex = hex(bb)[2:]
    
    print(f"#{rrHex} {ggHex} {bbHex}")

########################################################################
# Parse the command line

def parseArgs():
    
    global options

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

    (options, args) = parser.parse_args()

    if (options.verbose):
        options.debug = True
        
    if (options.debug):
        print("Options:", file=sys.stderr)
        print("  debug? ", options.debug, file=sys.stderr)

########################################################################
# Run a command in a shell, wait for it to complete

def runCommand(cmd):

    if (options.debug):
        print("running cmd: ", cmd, file=sys.stderr)
    
    try:
        retcode = subprocess.call(cmd, shell=True)
        if retcode < 0:
            print("Child was terminated by signal: ", -retcode, file=sys.stderr)
        else:
            if (options.debug):
                print("Child returned code: ", retcode, file=sys.stderr)
    except OSError as e:
        print >>sys.stderr, "Execution failed:", e

########################################################################
# kick off main method

if __name__ == "__main__":

   main()
