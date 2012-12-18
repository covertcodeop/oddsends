#!/usr/bin/env perl
#Copyright (C) 2010-2012 Zenko B. Klapko Jr.
#
#This file is linodeDynDns.pl
#
#linodeDynDns.pl source code is free software; you can redistribute it
#and/or modify it under the terms of the GNU General Public License as
#published by the Free Software Foundation; either version 2 of the License,
#or (at your option) any later version.
#
#linodeDynDns.pl source code is distributed in the hope that it will be
#useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Balloons Live! Wallpaper; if not, write to the Free Software
#Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
use strict;
use warnings;

use JSON;
use Data::Dumper;

open(FH,"<config.ini");
my @fileContents = <FH>;
close(FH);

my %config = ();
foreach my $line (@fileContents)
{
  chomp($line);
  my ($key, $value) = split(/=/,$line);
  $config{$key} = $value;
};
my $str = `wget -qO - https://api.linode.com/api/ --post-data "api_key=$config{'API_KEY'}&action=domainList"`;
my $jsonData = decode_json($str);

#print(Dumper($jsonData->{'DATA'}));

my @domainList = @{$jsonData->{'DATA'}};
foreach my $domain (@domainList)
{
	#	print($domain);
	if($domain->{'DOMAIN'} eq $config{'DOMAIN'})
	{
		print($domain->{'DOMAINID'} . "*" . $domain->{'DOMAIN'} . "\n");
    $str = `wget -qO - https://api.linode.com/api/ --post-data "api_key=$config{'API_KEY'}&action=domainResourceList&DomainID=$domain->{'DOMAINID'}"`;
    $jsonData = decode_json($str);
    my @resourceList = @{$jsonData->{'DATA'}};
    foreach my $resource (@resourceList)
    {
      if($resource->{'NAME'} eq $config{'HOSTNAME'})
      {
        print('Found it' . $resource->{'RESOURCEID'});
      };
    };
	};
};
