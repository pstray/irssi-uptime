#
# Copyright (C) 2002 by Peder Stray <peder@ninja.no>
#

use strict;
use Irssi;
use Irssi::Irc;

# ======[ Script Header ]===============================================

use vars qw{$VERSION %IRSSI};
($VERSION) = '$Revision: 1.2 $' =~ / (\d+\.\d+) /;
%IRSSI = (
	  name        => 'uptime',
	  authors     => 'Peder Stray',
	  contact     => 'peder@ninja.no',
	  url         => 'http://ninja.no/irssi/uptime.pl',
	  license     => 'GPL',
	  description => 'Try a little harder to figure out uptime',
	 );

# ======[ Helper functions ]============================================

# --------[ uptime_linux ]----------------------------------------------

sub uptime_linux {
    my($sys_uptime);
    my($irssi_start);
    local(*FILE);

    open FILE, "< /proc/uptime";
    $sys_uptime = (split " ", <FILE>)[0];
    close FILE;

    open FILE, "< /proc/$$/stat";
    $irssi_start = (split " ", <FILE>)[21];
    close FILE;

    return $sys_uptime - $irssi_start/100;
}

# --------[ uptime_solaris ]--------------------------------------------

sub uptime_solaris {
    my($irssi_start);

    $irssi_start = time - (stat("/proc/$$"))[9];

    return $irssi_start;
}

# ======[ Commands ]====================================================

# --------[ cmd_uptime ]------------------------------------------------

sub cmd_uptime {
    my($data,$server,$witem) = @_;
    my($time);
    my($sysname) = Irssi::parse_special('$sysname');

    if ($sysname eq 'Linux') {
	$time = uptime_linux;
    } elsif ($sysname eq 'SunOS') {
	$time = uptime_solaris;
    } else {
	$time = time - $^T;
    }

    my(@time,$str);
    for (60, 60, 24, 365) {
	push @time, $time%$_;
	$time = int($time/$_);
    }
    $str = sprintf "%dy %dd %dh %dm %ds", $time, @time[3,2,1,0];
    $str =~ s/^(0. )+//;

    if ($data && $server) {
	$server->command("/MSG $data uptime: $str");
    } elsif ($witem && ($witem->{type} eq "CHANNEL" ||
			$witem->{type} eq "QUERY")) {
	$witem->command("/MSG ".$witem->{name}." uptime: $str");
    } else {
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'uptime',
			   $str, $sysname);
    }
}

# ======[ Setup ]=======================================================

# --------[ Register commands ]-----------------------------------------

Irssi::command_bind('uptime', 'cmd_uptime');

# --------[ Register formats ]------------------------------------------

Irssi::theme_register(
[
 'uptime',
 '{line_start}{hilight Uptime:} $0 ($1)',
]);

# ======[ END ]=========================================================

# Local Variables:
# header-initial-hide: t
# mode: header-minor
# end:
