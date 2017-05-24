#!/usr/bin/perl -CSDAL

use warnings;
use strict;
use IServ::Conf;

my $type;
my $act;
my $UserHomepages = $conf->{UserHomepages};
my @PHPUsers = @{$conf->{PHPUsers}};
my @PHPGroups = @{$conf->{PHPGroups}};

sub print_config() {
  print "  <Directory /$type/$act/Homepage/>\n";
  print "    # allow php\n";
  print "    php_admin_flag engine on\n";
  print "\n";
  print "    # no opcaching for scripts in homepage directories\n";
  print "    php_flag opcache.enable off\n";
  print "\n";
  print "    # jail the php scripts in the homepage directory to prevent\n";
  print "    # reading of system-wide configuration files\n";
  print "    php_value open_basedir /$type/$act/Homepage/:/tmp/\n";
  print "\n";
  print "    # default php settings\n";
  print "    php_value default_charset \"utf-8\"\n";
  print "    php_flag display_errors off\n";
  print "    php_value upload_max_filesize 1024M\n";
  print "    php_value post_max_size 1024M\n";
  print "    php_flag zlib.output_compression on\n";
  print "    php_value date.timezone \"Europe/Berlin\"\n";
  print "    php_admin_flag allow_url_fopen off\n";
  print "    php_admin_value max_input_vars 1000\n";
  print "  </Directory>\n";
  print "\n";
}

sub group_php() {
  $type = "group";
  foreach my $group (@PHPGroups) {
    # skip www group, it will treated separatly below,
    # because this sub will only called if user homepages are enabled.
    next unless $group ne "www";
    $act = $group;
    print_config();
  }
}

sub www_php() {
  $type = "group";
  foreach my $group (@PHPGroups) {
    # treat www group separatly, because this sub 
    # will also called if homepages are disable in general.
    next unless $group eq "www";
    print "  # WWW Group allowed to use PHP via iservcfg.\n";
    $act = $group;
    print_config();
  }
}

sub user_php() {
  $type = "home";
  print "  # User Homepages which are allowed to use PHP via iservcfg.\n";
  foreach my $user (@PHPUsers) {
    $act = $user;
    print_config();
  }
}

group_php() unless @PHPGroups < 1 or $UserHomepages == 0;
www_php() unless @PHPGroups < 1;
user_php() unless @PHPUsers < 1 or $UserHomepages == 0;
