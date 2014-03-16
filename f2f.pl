#!/usr/bin/perl
use strict;
use Time::HiRes;
use LWP::UserAgent;
my $ua = LWP::UserAgent->new(keep_alive => 0);
$ua->timeout(10);
$ua->env_proxy;

my $col = 'A';
my $row = 1;

while (1) {
    my $url = "http://www.ethercalc.net:8000/_/f2f/cells/$col$row";
    warn "$url\n";
    my $response = $ua->get($url);
    do { sleep 0.5; next } unless $response->is_success;
    my $json = $response->decoded_content;
    warn "$json\n";
    $json =~ /"datavalue":"[^"]+"/ or do { sleep 0.5; next };
    if ($json =~ /"datavalue":"go (\d+)"/) {
        show(slide => $1);
    }
    if ($json =~ /"datavalue":"[^"]*[hjbnm]/) {
        show("next");
    }
    elsif ($json =~ /"datavalue":"[^"]*[koipl]/) {
        show("previous");
    }
    elsif ($json =~ /"datavalue":"q(?:uit)?"/) {
        $row = 0;
        $col++;
    }
    $row++;
}

sub show {
    system(qq[osascript -e 'tell application "Keynote" to show @_']);
}
