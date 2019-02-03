#!/usr/bin/perl -w

use strict;
use Getopt::Std;
use Date::Format;
use Date::Parse;

my $progName=$0;
$progName =~ s/.*\///;
my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);
my $CRITICAL="CRITICAL";
my $exitState=$ERRORS{'OK'};
my $required_mode=0;
my $unwanted_mode=0;
my $ignore_case=0;

my $offset_window_mins=10;
my $offset_window_secs;
my @strings;
my %attempts;
my %successes;
my %match;
my $logFile="/var/log/messages";
my $Usage = "
This script reads backwards through the messages log (within the time window given) for entries matching the text given
If it finds examples of all the required strings it passes the check, otherwise it fails.

Usage: $progName -R <string>|-U <string> [-i] [-w <window>] [-l <logfile>] [-W] [-h]

        -l      Logfile to read (Default: $logFile)

        -R      Required Strings To Search For ( A single ; delimited string in double quotes, E.g. \"BIGTED.RBMTEST1;BIGTED.RBMTEST2;BIGTED.RBMTEST3;BIGTED.RBMTEST4\" )

        -U      Unwanted Strings To Search For ( A single ; delimited string in double quotes, E.g. \"ERROR\" )

	-W	Max error is warning, not critical

        -w      Window in minutes to do reverse search for (Default: $offset_window_mins)

	-i	Ignore case in search

        -h      Print this message

";

# Check that the no invalid options have been set
# Also check if -h has been asked for
#
if (! getopts ('hiWR:U:w:l:') ) {
        print $Usage;
	exit $ERRORS{'UNKNOWN'};
}

if ( defined $Getopt::Std::opt_W ) {
	my $null=$Getopt::Std::opt_W;
	$CRITICAL="WARNING";
}

if ( $Getopt::Std::opt_h || $Getopt::Std::opt_h ) {
        print $Usage;
	exit $ERRORS{'OK'};
}

if ( defined $Getopt::Std::opt_l ) {
	$logFile=$Getopt::Std::opt_l;
}

if ( defined $Getopt::Std::opt_i ) {
	my $null=$Getopt::Std::opt_i;
        $ignore_case=1;
}

if ( defined $Getopt::Std::opt_U ) {
        @strings=split /;/, $Getopt::Std::opt_U;
        foreach my $string (@strings) {
                $match{$string}=0;
        }
	$unwanted_mode=1;
}

if ( defined $Getopt::Std::opt_R ) {
        @strings=split /;/, $Getopt::Std::opt_R;
        foreach my $string (@strings) {
                $match{$string}=0;
        }
	$required_mode=1;
}

if ($required_mode + $unwanted_mode != 1) {
	print $Usage;
	print "Error: One and only one of Required or Unwanted must be selected\n\n";
	exit $ERRORS{'UNKNOWN'};
}

if ( defined $Getopt::Std::opt_w ) {
        $offset_window_mins=$Getopt::Std::opt_w;
}
$offset_window_secs=$offset_window_mins * 60;

my $nowTime=time();
my @nowTime=localtime($nowTime);
my $nowHMS=strftime('%H%M%S', @nowTime);

my $windowStart=time() - $offset_window_secs;
my @windowStart=localtime($windowStart);
my $windowStartHMS=strftime('%H%M%S', @windowStart);
my $yesterday=strftime('%Y-%m-%d', @windowStart);

my $yesterdayStartTime=0;
# Check if the search covers yesterday
if ($windowStartHMS > $nowHMS) {
	$yesterdayStartTime=$windowStartHMS;
	$windowStartHMS=0;
}

if (! open (LOGFILE, "<$logFile")) {
        print "${CRITICAL}: Failed to open $logFile for reading\n";
        exit $ERRORS{${CRITICAL}};
}

while (<LOGFILE>) {
	chomp;
	my $line=$_;
	my @field=split;
	my $date="$field[0] $field[1] $field[2]";
	my $timeStamp=str2time($date);
	if ($timeStamp) {
		if ($timeStamp > $windowStart) {
			&check_line($line);
		}
	}
}
close (LOGFILE);

if ($yesterdayStartTime) {
	my $lastLogfile="$logFile.$yesterday";
	if (open (YESTERDAY, "<$lastLogfile")) {
		while (<YESTERDAY>) {
			chomp;
			my $line=$_;
			my @field=split;
			my $date="$field[0] $field[1] $field[2]";
			my $timeStamp=str2time($date);
			if ($timeStamp) {
				if ($timeStamp > $windowStart) {
					&check_line($line);
				}
			}
		}
		close(YESTERDAY);
	}
}

# Finally once the log is processed, see what matches we have, Do this twice, so that the criticals are top of the list
if ($required_mode == 1) {
	foreach my $string (@strings) {
       		if ($match{$string} == 0) {
               		print "${CRITICAL}: No Matches for $string in ${logFile} in last $offset_window_mins minutes\n";
               		$exitState=$ERRORS{${CRITICAL}};
       		}
	}
	foreach my $string (@strings) {
       		if ($match{$string} >= 1) {
               		print "INFO: $match{$string} Matches were found in ${logFile} for $string, in last $offset_window_mins minutes\n";
       		}
	}
} else {
	foreach my $string (@strings) {
       		if ($match{$string} >= 1) {
               		print "${CRITICAL}: $match{$string} Matches for $string in ${logFile} in last $offset_window_mins minutes\n";
               		$exitState=$ERRORS{${CRITICAL}};
       		}
	}
	foreach my $string (@strings) {
       		if ($match{$string} == 0) {
               		print "INFO: No Matches were found in ${logFile} for $string, in last $offset_window_mins minutes\n";
       		}
	}
}

exit ${exitState};

sub check_line() {
	my $line = $_[0];

	foreach my $string (@strings) {
		if ( $ignore_case == 1 ) {
			if ( $line =~ /${string}/i ) {
				$match{$string}++;
			}
		} else {
			if ( $line =~ /${string}/ ) {
				$match{$string}++;
			}
		}
	}
}
