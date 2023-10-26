#!/usr/bin/env perl
# created on 2023-10-25

use warnings;
use utf8;
use 5.30.0;
use JSON::PP;
use Data::Dumper;

my $json = JSON::PP->new->utf8->allow_nonref;

my ($bottle_f, $artifact_f) = @ARGV;

$bottle_f =~ /\.(\w+)\.bottle\.json$/;
my $arch = $1;

my $data             = read_json($bottle_f);
my @bottle_bin_files = ($bottle_f);
while (my ($k, $v) = each %$data) {
  my $local_filename = $v->{bottle}{tags}{$arch}{local_filename};
  push @bottle_bin_files, $local_filename;
}

my @tar_cmd = ("tar", "-cvzf", $artifact_f, @bottle_bin_files);
say "Running @tar_cmd";
system(@tar_cmd) == 0 or die "system failed: $?";

sub read_json {
  my $f = shift;
  # read in bottle json to figure out which files we want to extract
  open my $fh, '<', $f or die "Can't open filehandle: $!";
  my $data = $json->decode(do { local $/; <$fh> });
  close $fh;
  return $data;
}
