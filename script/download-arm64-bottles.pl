#!/usr/bin/env perl
# luckily this is an open source project, so
# I can do whatever I want. I can even use Perl :)

# This script does the following: it iterates through the *.bottle.json files,
# derives an artifact url for arm64 architecture and tries to download this file
# If successful, it extracts only the corresponding arm64 bottle files for the
# bottle files found the current directory.

use warnings;
use utf8;
use 5.30.0;
use JSON::PP;
use Data::Dumper;

my $json = JSON::PP->new->utf8->allow_nonref;

my $base_url = "https://bargsten.org/brew-artifacts";
my $found_bottles;
for my $bottle_f (<*.bottle.json>) {
  $found_bottles = 1;
  (my $artifact_f = $bottle_f) =~ s/\.(\w+)\.bottle\.json$/.arm64_$1.artifact.tar.gz/;
  my $arch = $1;

  (my $bottle_arm64_f = $bottle_f) =~ s/\.$arch\./.arm64_$arch./;

  # download the artifact
  my $url = "$base_url/$artifact_f";
  say "Downloading $url";

  my @curl_cmd = ("curl", "--location", "--fail", "--no-progress-meter", $url, "-o", $artifact_f);
  say "Running @curl_cmd";
  unless (system(@curl_cmd) == 0) {
    say "Could not download $url, skipping injection for this formula";
    exit 0;
  }

  my $data = read_json($bottle_f);

  my @bottle_bin_files = ($bottle_arm64_f);
  while (my ($k, $v) = each %$data) {
    my $local_filename = $v->{bottle}{tags}{$arch}{local_filename};
    $local_filename =~ s/\.$arch\./\.arm64_$arch\./;
    push @bottle_bin_files, $local_filename;
  }

  my @tar_cmd = ("tar", "-xvzf", $artifact_f, @bottle_bin_files);
  say "Running @tar_cmd";
  system(@tar_cmd) == 0 or die "system failed: $?";
}

unless ($found_bottles) {
  say "No bottles found!";
}

sub read_json {
  my $f = shift;
  # read in bottle json to figure out which files we want to extract
  open my $fh, '<', $f or die "Can't open filehandle: $!";
  my $data = $json->decode(do { local $/; <$fh> });
  close $fh;
  return $data;
}
