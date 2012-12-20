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

my $ip = `wget -qO- ifconfig.me/ip`;
chomp($ip);
if(!($ip =~ /\d+\.\d+\.\d+\.\d+/))
{
  die('Could not reach the Internet to determine external IP address');
};

open(FH,"<config.ini") or die $!;
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
        $str = `wget -qO - https://api.linode.com/api/ --post-data "api_key=$config{'API_KEY'}&action=domainResourceSave&ResourceID=$resource->{'RESOURCEID'}&DomainID=$resource->{'DOMAINID'}&Name=$config{'HOSTNAME'}&Type=$resource->{'TYPE'}&Target=$ip"`;
   #$WGET --post-data "api_key=$APIKEY&action=domainSave&DomainID=$DOMAINID&Domain=$DOMAIN&Type=master&Status=$STATUS&SOA_Email=$SOAEMAIL"; echo
      };
    };
	};
};


# 'RESOURCEID' => 2679520,
#            'WEIGHT' => 5,
#            'NAME' => 'home',
#            'DOMAINID' => 87173,
#            'PRIORITY' => 10,
#            'TARGET' => '0.0.0.0',
#            'TTL_SEC' => 0,
#            'PROTOCOL' => '',
#            'TYPE' => 'a',
#            'PORT' => 80

