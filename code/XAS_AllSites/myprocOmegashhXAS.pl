#!/usr/bin/perl

use strict;
use warnings;
use Math::Trig;

my ($L,$N,$numbLegs,$center,$omegain,$domega,$totom,$Gamma,$Vc,$U,$V) = @ARGV;
my $usage = "#tot_number_sites #elec #legs #center w0 dw totw Gamma Vc U V";
defined($L)        or die "USAGE: $0 $usage\n";
defined($N) or die "USAGE: $0 $usage\n";
defined($numbLegs) or die "USAGE: $0 $usage\n";
defined($center)   or die "USAGE: $0 $usage\n";
defined($omegain)  or die "USAGE: $0 $usage\n";
defined($domega)   or die "USAGE: $0 $usage\n";
defined($totom)    or die "USAGE: $0 $usage\n";
defined($Gamma)   or die "USAGE: $0 $usage\n";
defined($Vc)    or die "USAGE: $0 $usage\n";
defined($U) or die "USAGE: $0 $usage\n";
defined($V) or die "USAGE: $0 $usage\n";


my @v1;
my @v2;
my @v3;
for (my $om =0; $om<$totom; $om++) {
	my $index = $om + 1;
	open(FIN,"runForinputXAS.L=$L.$index.cout") or die "$0: Cannot open runForinputXAS.L=$L.$index.cout : $!\n";
	my $status;
        print "reading from runForinputXAS.L=$L.$index.cout\n";	
	my $site = 0;
	while (<FIN>) {
	if (/P2/ and /gs/ and /Psi/) {next;}
	if (/P2/ and /gs/) {
		$status="p2";
	} elsif (/\|gs>/ and $_ !~ /P2/) {
        	$status="p1";
	} else {	
        next;
	}
	chomp;
	my @temp = split;
	die "$0: Line $_ ---> $status\n" unless (scalar(@temp)==5);
	my $site = $temp[0];
	if ($status eq "p1") {
		$v1[$site+$L*$om] = $temp[1];
	} else {
		$v1[$site+$L*$om] = 0.0;
	}
        $v2[$site+$L*$om] = $temp[1] if ($status eq "p2");
	$v3[$site+$L*$om] = $temp[4] if ($status eq "p2");
	$site++;
	}
	close(FIN);
}

if ($numbLegs==1){
	my $sitec = $center;
	my $outSpectrum0 = "outSpectrumXAS.chain.L.$L.N.$N.Gamma.$Gamma.Vc.$Vc.U.$U.V.$V.gnuplot";
	open(FOUTSPECTRUM0,"> $outSpectrum0") or die "$0: Cannot write to $outSpectrum0 : $!\n";
	for (my $om =0; $om<$totom; $om++) {
        	my $omega = $omegain+$om*$domega;
		my $sum0 = (1/pi)*$v2[$sitec+$L*$om];
        	print FOUTSPECTRUM0 "$omega $sum0\n";
	}
	close(FOUTSPECTRUM0);
	print STDERR "$0: Spectrum written to $outSpectrum0\n";
} 


if ($numbLegs==2){
	my $sitec = $center;
	my $outSpectrum0 = "outSpectrumXAS.ladder.Gamma.$Gamma.Vc.$Vc.gnuplot";
	open(FOUTSPECTRUM0,"> $outSpectrum0") or die "$0: Cannot write to $outSpectrum0 : $!\n";
	for (my $om =0; $om<$totom; $om++) {
        	my $omega = $omegain+$om*$domega;
        	my $sum0 = $v2[$sitec+$L*$om];
        	print FOUTSPECTRUM0 "$omega $sum0\n";
	}
	close(FOUTSPECTRUM0);
	print STDERR "$0: Spectrum written to $outSpectrum0\n";
} 

