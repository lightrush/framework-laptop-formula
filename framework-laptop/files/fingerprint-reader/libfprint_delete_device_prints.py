#!/usr/bin/env python3

# Import PyGObject
# PyGObject is a Python package which provides bindings for GObject based libraries such as GTK, GStreamer, WebKitGTK, GLib, GIO and many more.
from gi import require_version

# for arguments
from sys import argv
from os import geteuid

if geteuid() != 0:
    exit("You need to have root privileges to run this script.\nPlease try again, this time using 'sudo'. Exiting.")

# Load FPrint gi module
require_version('FPrint', '2.0')

# Import FPrint
from gi.repository import FPrint

# Get FPrint Context
fprint_context = FPrint.Context()

# Loop over FPrint devices
for fprint_device in fprint_context.get_devices():

    # Print device info
    print(fprint_device)
    print(fprint_device.get_driver())
    print(fprint_device.props.device_id)

    # Open the device synchronously.
    fprint_device.open_sync()

    # Get list of enrolled prints
    enrolled_fingerprints = fprint_device.list_prints_sync()
    print("Device has %d enrolled fingerprints." % len(enrolled_fingerprints))

    # Loop through enrolled fingerprints
    for fingerprint in enrolled_fingerprints:

        # Print fingerprint info
        date = fingerprint.props.enroll_date
        print('    %04d-%02d-%02d valid: %d' % (date.get_year(), date.get_month(), date.get_day(), date.valid()))
        print('    ' + str(fingerprint.props.finger))
        print('    ' + str(fingerprint.props.username))
        print('    ' + str(fingerprint.props.description))
        
        # check for delete flag
        if (len(argv) > 1 and argv[1] == "-d"):
            # Delete print
            print('Deleting print:')
            fprint_device.delete_print_sync(fingerprint)
            print('Deleted')

    # Close the device synchronously.
    fprint_device.close_sync()
