#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use File::Basename;
use File::Find::Rule;
use Math::Round;
use HTTP::Date;
use Time::Zone;
use Cwd;

my $updated = 0;
my $skipped = 0;

my $opts = {
	'verbose'              => 0,
	'help'                 => \&help,
	'dry-run'              => 0,
	'min=f'                => 1.5,           # abs(Values) between this and 0 will not be scaled
	'scale=f'              => 1,             # multiply all values by
	'factor=f'             => 3,             # Round to the nearest factor
	'only-skipped|x'       => 0,             # Show only the skipped files
	'processed-suffix=s'   => '-updated'
};

prepOptions();

# print "Intook:\n" . Dumper($opts, \@ARGV);

main();

exit;

#
### SUBS ###
#

sub main {
	# If input args are empty, lets work on the current directory.
	push(@ARGV, getcwd()) if ($#ARGV == -1);
	my $processed_files = 0;

	my $excludeFiles = File::Find::Rule->file
			->name('.*') # Provide specific list of directories to *not* scan
			->discard;

	my $includeFiles = File::Find::Rule->file
			->name('*.*'); # search by file extensions


	foreach my $arg (@ARGV) {
		message('-----') if ($processed_files and $#ARGV);
		if (-d $arg) {
			my $directory = $arg;
			my @Files = File::Find::Rule->or( $excludeFiles, $includeFiles )->in($directory);
			# print map { "$_\n" } @Files;
			foreach my $file (@Files) {
				processFile($file);
			}
			$processed_files+= scalar(@Files);
		}
		elsif (-f $arg) {
			processFile($arg);
			$processed_files++;
		}
		else {
			message($arg . ' not found...');
		}
	}

	if ($processed_files) {
		message(sprintf('%d total files, %d files updated, %d skipped.', $processed_files, $updated, $skipped));
	}
	else {
		message('Could not find any files to work on. Nothing to do. Exiting :(');
	}
}

sub processFile($) {
	my $file = shift();
	my $ofh;
	my $modded_file = '';
	my $timestr;
	my $wetrun = !$opts->{'dry-run'};
	my $only_skipped = $opts->{'only-skipped'};

	message('Processing '. $file, 1);

	my ($filename, $dirs, $suffix) = fileparse($file, qr/\.[^.]*/);

	# Patterns to match
	if (
		$filename =~ /^(\d{8})_(\d{6})$/ or
		$filename =~ /^(\d{8})_(\d{6})\D?/ or
		$filename =~ /^download_(\d{8})_(\d{6})\D?/ or
		$filename =~ /^photo-(\d{8})_(\d{6})\D?/ or
		$filename =~ /^PANO_(\d{8})_(\d{6})\D?/ or
		$filename =~ /^IMG_(\d{8})_(\d{6})\D?/ or
		$filename =~ /^VID_(\d{8})_(\d{6})/
	) {
		$timestr = "$1T$2Z";
	}
	elsif ( $filename =~ /^(\d{4})-(\d{2})-(\d{2}) (\d{2}).(\d{2}).(\d{2})$/ ) {
		$timestr = "$1$2$3T$4$5$6Z";
	}
	elsif ( $filename =~ /^video-(\d{4})-(\d{2})-(\d{2})-(\d{2})-(\d{2})-(\d{2})$/ ) {
		$timestr = "$1$2$3T$4$5$6Z";
	}

	# Established a timestamp, ready to proceed.
	if ($timestr and !$only_skipped) {
		my $time = str2time($timestr);
		# $time = time2str($time);
		# $time = str2time($time . '-0800');

		if (defined($time)) {
			$time = ($time - tz_local_offset());
			message(sprintf('%-32s   Time: %s', $filename.$suffix, time2str($time)));

			if ($wetrun and defined($time)) {
				utime($time, $time, $file) || warn "Couldn't touch $file: $!";
				$updated++;
			}
		}
	}
	elsif (!defined($timestr)) {
		message(sprintf('%-32s   SKIPPED', $filename.$suffix));
		$skipped++;
	}
}

sub message {
	my $threshold = scalar(@_) >= 2 ? pop() : 0;
	print @_, "\n" if ($opts->{'verbose'} >= $threshold);
}

sub prepOptions {
	my ($cleanoptions, @OptSwitches);
	foreach my $key (keys %{$opts}) {
		(my $o = $key) =~ s/[^\w\-].*$//;
		$cleanoptions->{$o} = $opts->{$key};
		push(@OptSwitches, $key);
		delete $opts->{$key};
	}
	$opts = $cleanoptions;

	GetOptions($opts, @OptSwitches) or help();
}

sub help {
	my ($opt_name, $opt_value) = @_;
	my $script_name = \$0;
	my $help_text = <<END_HELP;
==============================================================
----- Welcome to the Filename->Date Checker and Updater  -----
==============================================================

  $ $script_name <folder> <folder> <file> <file>

Below are the supported options.

  USEFUL SWITCHES
    -d or --dry-run    =  Run in pretend mode, and don't modify any files.
    --processed-suffix =  This string will be appended to the end of processed
			  filenames. (Default: "-updated")

  LESS USEFUL SWITCHES
    -v or --verbose    =  Turn on verbose output, show everything we are doing.
    -h or --help       =  Show this help.

END_HELP
	$opt_value ? print $help_text : die "See --help below:\n" . $help_text;
	exit;
}
