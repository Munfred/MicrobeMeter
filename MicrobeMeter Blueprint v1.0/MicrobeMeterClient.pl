#!/usr/local/bin/perl

# Client script for connecting and collecting data from MicrobeMeter v1.0.
# Written by Kalesh Sasidharan
# Date: 2018/07/02
# Version: 1.0

# Requirements: Perl 5.005 or above. Win32::SerialPort and DBD::WMI for Windows OS or Device::SerialPort for macOS/Linux
# Usage: perl MicrobeMeterClient.pl or perl MicrobeMeterClient.pl ramp
# ramp - optional parameter for conducting LED intensity ramp-down measurements

# Note: This script works on both Windows and Mac operating systems. It was tested successfully on 32 and 64-bit Windows 8 and 10, and macOS version 10.13. Strawberry Perl is recommended for Windows. If you have problem installing Win32::SerialPort using cpan command, then try the following steps:
# Download Win32::SerialPort from CPAN
# perl Makefile.PL TESTPORT=port
# gmake
# gmake test
# gmake install

# This material is provided under the MicrobeMeter non-commercial, academic and personal use licence.
# By using this material, you agree to abide by the MicrobeMeter Terms and Conditions outlined on https://humanetechnologies.co.uk/terms-and-conditions-of-products/.

# © 2018 Humane Technologies Limited. All rights reserved.

require 5.005;
use strict;
use warnings;
use vars qw($osWindows);

# Loading the correct serial library based on the operating system
BEGIN {
    # Checking if the operating system is Windows
    $osWindows = ($^O eq "MSWin32") ? 1 : 0;
    # Loading the serial library
    if($osWindows) {
        eval ("use Win32::SerialPort");
        die "$@\n" if($@);
        eval ("use DBI");
        die "$@\n" if($@);
    } else {
        eval ("use Device::SerialPort");
        die "$@\n" if($@);
    }
}

my $dbHandler = "";                 # WMI database handler (it is used for finding the COM port name of MicrobeMeter on Windows)
my $wqlObj = "";                    # WQL object (it is used for finding the COM port name of MicrobeMeter on Windows)
my @portInfo;                       # Stores information regarding HC-06 COM port (applicable only on Windows)
my $portName = "";                  # Stores the Bluetooth port name
my $expName = "";                   # Stores the Experiment/Output file name
my @zombie;                         # Stores the list of unclosed Bluetooth connections
my $fVal;                           # Stores each unclosed Bluetooth connection
my $btPort;                         # Bluetooth port
my $output;                         # Stores output from the server
my $cFlag = 0;                      # Stores the count of attempted Bluetooth connections
my $wCount = 4;                     # Stores the number of failed Bluetooth connections attempts
my $conFlag = 0;                    # Stores the status of the Bluetooth connection
my $timeStamp;                      # Stores the time of each measurement
my $dataCtr = 0;                    # Stores the count of measurements
my $measurementDelay = 6;           # The delay at the server for each set of measurements (Measurement Time of MicrobeMeter v1.0 is ~5.2 seconds)
my $readDelay = 0;                  # The delay between measurements
my $expRun = "";                    # A variable to indicate the start of the experiment/measurement
my $blankRead = 1;                  # A variable to keep track of the number of Blank measurements
my @blankValues;                    # An array to store the Blank values from each port
my $rampDown = 0;                   # A variable indicating the type of measurement (single-measurement or LED intensity ramp-down measurements)
my $version = "MicrobeMeter v1.0";  # Name and version of the device

print "\n\n******* $version Data Logger *******\n";
# Checking the type of measurement (single-measurements or LED intensity ramp-down measurements)
$rampDown = ($#ARGV >= 0 && $ARGV[0] eq "ramp")? 1 : 0;

# Assigning/getting the Bluetooth port name
if ($osWindows) {
    # Getting the HC-06 (Bluetooth device name of MicrobeMeter) port details using WMI
    $dbHandler = DBI->connect("DBI:WMI:");
    $wqlObj = $dbHandler->prepare(<<WQL);
        SELECT DeviceID FROM Win32_PnPEntity WHERE Name = "HC-06"
WQL
    $wqlObj->execute();
    @portInfo = $wqlObj->fetchrow;
    if (scalar(@portInfo)) {
        # Finding the Device ID of HC-06
        $portInfo[0] =~ m/.+BLUETOOTHDEVICE_(.+)/;

        # Finding the COM port corresponding to the Device ID
        $wqlObj = $dbHandler->prepare(<<WQL);
            SELECT Name FROM Win32_PnPEntity WHERE DeviceID LIKE "%$1%" AND Name LIKE "%(COM%"
WQL
        $wqlObj->execute();
        @portInfo = $wqlObj->fetchrow;
        if (scalar(@portInfo)) {
            $portInfo[0] =~ m/.+\((COM\d+)\)/;
            $portName = $1;
        }
    }
    # Cleaning up
    $wqlObj = "";
    $dbHandler->disconnect;
} else {
    # Getting the Bluetooth port name (HC-06) from the list of ports
    # NOTE: This part is for macOS (or Linux)
    $portName = `ls /dev/tty.* | grep HC-06`;
    chomp($portName);
}

# If it cannot find the Bluetooth port name then ask the user
while ($portName eq "") {
    print "\nWhat is the Bluetooth port name? ";
    $portName = <STDIN>;
    chomp($portName);
}

# Getting the Output file/Experiment name from the user
while ($expName eq "") {
    $rampDown ? print "\nWhat is the output file name? " : print "\nWhat is the experiment name? ";
    $expName = <STDIN>;
    chomp($expName);
}

# Getting the Measurement Delay from the user
# Note: no additional delay is used between Ramp-Down measurements
if (!$rampDown) {
    while ($readDelay eq "" || $readDelay !~ /^\d*\.?\d*$/ || $readDelay < 0.1) {
        print "\nEnter delay between measurements in minutes (minimum is 0.1)? ";
        $readDelay = <STDIN>;
        chomp($readDelay);
    }
    # Converting Measurement Delay into seconds and subtracting the Measurement Time
    $readDelay = int(($readDelay *= 60) - $measurementDelay + 0.5);
}

print "\nConnecting to $version...\n";
while (1) {
    # Background check for establishing a new connection
    # NOTE: This part is for macOS (or Linux)
    if (!$osWindows && !$conFlag) {
        # Closing all the zombie HC-06 Bluetooth ports
        @zombie = `lsof | grep $portName`;
        foreach $fVal (@zombie) {
            if ($fVal =~ /\S+\s+(\d+)\s+.+/) {
                eval { `kill -9 $1`; };
                sleep (3);
            }
        }
    }
    else {
        # Closing the port for restarting the connection
        eval { $btPort->close; };
    }
    
    # Creating OS specific serial port object
    if ($osWindows) {
        if (!($btPort = Win32::SerialPort->new($portName))) {
            if ($wCount++ >= 4) {
                print ("\n\nPlease make sure MicrobeMeter is turned on. Please restart the computer if the problem persists.\n\n");
                $wCount = 0;
                sleep (5);
            } else {
            	print ("\n");
            	sleep (1);
            }
            next;
        }
    } else {
        if (!($btPort = Device::SerialPort->new($portName))) {
            if ($wCount++ >= 4) {
                print ("\n\nPlease make sure MicrobeMeter is turned on. Please restart the computer if the problem persists.\n\n");
                $wCount = 0;
                sleep (5);
            } else {
            	print ("\n");
            	sleep (1);
            }
            next;
        }
    }
    $wCount = 0;
    
    # Configuring and initiating the serial connection
    $btPort->baudrate(9600);
    $btPort->databits(8);
    $btPort->parity("none");
    $btPort->stopbits(1);
    $conFlag = 1;
    print "\n\nConnected to $version!";
    
    # Showing the Blank measurement prompt to the user
    while ($expRun ne "y" && $expRun ne "Y" && $blankRead == 1) {
        $rampDown ? print "\n\nStart the Ramp-Down measurements (y)? " : print "\n\nStart the Blank measurements (y)? ";
        $expRun = <STDIN>;
        chomp($expRun);
    }

    # Acquiring the data as long as it is connected to the server
    while (1) {
        # Setting up the Log file for writing errors
        open(my $OUTL, '>>', "$expName-LOG.txt") or die "Could not open file $expName-LOG.txt $!";
        # Adding version info into the Log file
        $blankRead == 1 && $cFlag == 0 && print $OUTL "$version\tExperiment Name: $expName\tDate: ".localtime(time);

        # Showing Blank insertion prompt
        if ($blankRead <= 4 && !$rampDown) {
            print "\nPlace the Blank Tube into Port $blankRead and press enter.";
            <STDIN>;
        }

        # Passing "R" or "\n" to the server to get LED intensity ramp-down measurements or single-measurements, respectively
        $rampDown ? $btPort->write("R") : $btPort->write("\n");
        $timeStamp = localtime(time);
        # Wait until measurement is done
        sleep($measurementDelay);
        $output = $btPort->lookfor();
        
        # If client didn’t hear from the server for four consecutive tries then restart
        if ($output eq "") {
            if ($cFlag++ >= 3) {
                print "\n$timeStamp\tConnection lost!";
                print $OUTL "\n$timeStamp\tConnection lost!";
                close $OUTL;
                last;
            }
            print "\n$timeStamp\tReconnecting to the MicrobeMeter...";
            print $OUTL "\n$timeStamp\tReconnecting to the MicrobeMeter...";
            close $OUTL;
            next;
        }
        $cFlag = 0;

        # Measuring Blank from each port. As the server reads all the ports per '\n' command, extracting the measurement only from the Blank containing port
        if ($blankRead <= 4 && !$rampDown) {
            # Extracting the Blank value of each port at a time from the server data-string
            if ($output =~ m/T:(.+)\tP1:(\d+)\tP2:(\d+)\tP3:(\d+)\tP4:(\d+)/) {
                if ($blankRead == 1) { $blankValues[0] = $2; }
                if ($blankRead == 2) { $blankValues[1] = $3; }
                if ($blankRead == 3) { $blankValues[2] = $4; }
                if ($blankRead == 4) { $blankValues[3] = $5; }
            }
            else {
                print "$timeStamp\tError\t$output";
                print $OUTL "\n$timeStamp\tError\t$output";
                close $OUTL;
                $cFlag++;   # Incrementing to avoid printing the version header twice
                $blankRead--;
            }

            $blankRead++;
            if ($blankRead < 5) {
                $output = "";
                next;
            } else {
                # Combining the Blank values to the format of a Server output string
                $output = "T:$1\tP1:$blankValues[0]\tP2:$blankValues[1]\tP3:$blankValues[2]\tP4:$blankValues[3]";
                print "\n\nPlace the Sample Tubes into Port 1 to 3, place the Blank Tube into Port 4 and press enter to start the measurements.";
                <STDIN>;
            }
        }

        # Opening a TSV file for storing the results
        open (my $OUTF, '>>', "$expName.tsv") or die "Could not open file $expName.tsv $!";
        # Initiating the measurement and data storage
        if ($dataCtr == 0) {
            print $OUTF "$version\tExperiment Name: $expName";
            if ($rampDown) {
                print $OUTF "\nLED Intensity Ramp-Down";
                print "\nLED Intensity Ramp-Down";
            }
            print $OUTF "\nTime\tTemperature\tPort_1\tPort_2\tPort_3\tPort_4";
            print "\n-------------------------------------------------------------------------------";
            print "\nRead#\tTime\t\t\t\tTemp.\tPort_1\tPort_2\tPort_3\tPort_4";
            print "\n-------------------------------------------------------------------------------";
        }

        do {
            # Showing the Blank identifier/measurement number
            $rampDown && $dataCtr == 0 && $dataCtr++;
            ($dataCtr == 0 && !$rampDown) ? print "\nBlank\t" : print "\n$dataCtr\t";
            $dataCtr++;
            
            # Extracting the data from the server data-string
            if ($output =~ m/T:(.+)\tP1:(\d+)\tP2:(\d+)\tP3:(\d+)\tP4:(\d+)/) {
                ($dataCtr == 1 && !$rampDown) ? print $OUTF "\n$timeStamp\t$1\t$2\t$3\t$4\t$5\tBlank" : print $OUTF "\n$timeStamp\t$1\t$2\t$3\t$4\t$5";
                print "$timeStamp\t$1\t$2\t$3\t$4\t$5";
            }
            else {
                print "$timeStamp\tError\t$output";
                print $OUTL "\n$timeStamp\tError\t$output";
            }

            $output = "";
            if ($rampDown) {
                $timeStamp = localtime(time);
                # Wait until measurement is done
                sleep($measurementDelay);
                $output = $btPort->lookfor()
            }
        } while ($output ne "");
        close $OUTF;
        close $OUTL;

        # Exiting the program after the LED Intensity Ramp-Down measurements
        if ($rampDown) {
            print "\nCompleted!\n";
            exit;
        }
        
        # Wait for next measurement
        sleep($readDelay);
    }
}