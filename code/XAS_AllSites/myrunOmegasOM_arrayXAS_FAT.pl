#!/usr/bin/perl

use strict;
use warnings;
use Math::Trig;

my ($L,$N,$Gamma,$VC,$t,$U,$V,$test,$omegain,$omegatot,$omegastep,$offset,$m) = @ARGV;
my $message = "L N Gamma V_C t U V [test,nobatch,submit] omega_in omega_tot omega_step offset m \n";

defined($L) or die "USAGE: $0 $message\n";
defined($N) or die "USAGE: $0 $message\n";
defined($Gamma) or die "USAGE: $0 $message\n";
defined($VC) or die "USAGE: $0 $message\n";
defined($t) or die "USAGE: $0 $message\n";
defined($U) or die "USAGE: $0 $message\n";
defined($V) or die "USAGE: $0 $message\n";
defined($test) or die "USAGE: $0 $message\n";
defined($omegain) or die "USAGE $0 $message\n";
defined($omegatot) or die "USAGE $0 $message\n";
defined($omegastep) or die "USAGE $0 $message\n";
defined($offset) or die "USAGE $0 $message\n";
defined($m) or die "USAGE $0 $message\n";

my $twiceL = 2*$L;
my $Lminus2 = $L-2;
my $Lover2 = $L/2;
my $nup = $N/2;
my $ndown = $N/2;
my $totarrayIN = $offset+1;
my $totarray = $omegatot;
my $siteC = $L/2-1;
my @matrixHop;
my @matrixV;

for (my $i = 0; $i<$L; $i++) {
	for (my $j = 0; $j<$L; $j++) {
		$matrixHop[$i+$L*$j] = 0.0;
		$matrixV[$i+$L*$j]=0.0;
	}
}

for (my $i1 = 0; $i1<$L; $i1++) {
	for (my $i2 = 0; $i2<$L; $i2++) {
		if ($i1-$i2==1) {
			$matrixHop[$i1+$L*$i2] = 0;
			$matrixV[$i1+$L*$i2] = 0;
		}
		if ($i2-$i1==1) {
			$matrixHop[$i1+$L*$i2] = $t;
			$matrixV[$i1+$L*$i2] = $V;
		}				
	}
}


my $outBatch = "BatchOMarray_XAS.pbs";
print STDERR " About to create $outBatch\n";
open(FOUTB,"> $outBatch") or die "$0: Cannot write to $outBatch : $!\n";
print FOUTB<<EOF;
#!/bin/bash
#SBATCH --account=ACF-UTK0011
#SBATCH --nodes=1 --ntasks=4
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --time=24:00:00
#SBATCH --job-name L$L\_Hub_OM
#SBATCH --array=$totarrayIN-$totarray
date
module load intel-compilers/2021.2.0
module load hdf5/1.10.8-intel
module load cuda/11.4.2-gcc
module load magma

#module load hdf5/1.10.8-intel
#module load intel-mkl/2021.2.0
EOF
print FOUTB "./dmrg -f inputXAS.L=$L.\${SLURM_ARRAY_TASK_ID}.inp -p 12 \"<gs|identity|P2>,<gs|identity|gs>\" -p 12 -l runForinputXAS.L=$L.\${SLURM_ARRAY_TASK_ID}.cout\ndate\n";
close(FOUTB);
print STDERR "written $outBatch\n";




for (my $om = $offset; $om<$omegatot;$om++){
        my $omega = $omegain+$om*$omegastep;
        my $siteC = -1+($L/2);
        my $index = $om+1;
        my $out = "inputXAS.L=$L.$index.inp";
        open(FOUT,"> $out") or die "$0: Cannot write to $out : $!\n";
        print FOUT<<EOF;
TotalNumberOfSites=$L
EOF

print FOUT "NumberOfTerms=2\n";

print FOUT<<EOF;

DegreesOfFreedom=1
GeometryKind=LongRange
GeometryOptions=none
Connectors $L $L
EOF
for (my $i = 0; $i<$L; $i++) {
        for (my $j = 0; $j<$L; $j++) {
                print FOUT "$matrixHop[$i+$L*$j] ";
        }
        print FOUT "\n";
}
print FOUT<<EOF;
GeometryMaxConnections=0

EOF

print FOUT<<EOF;

DegreesOfFreedom=1
GeometryKind=LongRange
GeometryOptions=none
Connectors $L $L
EOF
for (my $i = 0; $i<$L; $i++) {
        for (my $j = 0; $j<$L; $j++) {
                print FOUT "$matrixV[$i+$L*$j] ";
        }
        print FOUT "\n";
}
print FOUT<<EOF;
GeometryMaxConnections=0
EOF

print FOUT<<EOF;
Model=HubbardOneBandExtended
EOF
print FOUT<<EOF;
hubbardU $L
EOF
        for (my $si=0; $si<$L; $si++){
                        print FOUT "$U ";
        }
        print FOUT "\n";
print FOUT<<EOF;
potentialV $twiceL
EOF
	for (my $si=0; $si<$L; $si++){
		if ($si==$siteC) { print FOUT "$VC ";}
		else {print FOUT "0 ";}
	}
	print FOUT "\n";
        for (my $si=0; $si<$L; $si++){
		if ($si==$siteC) { print FOUT "$VC ";}
		else {print FOUT "0 ";}
        }
        print FOUT "\n";

print FOUT<<EOF;
magneticV $L
EOF
	for (my $si=0; $si<$L; $si++){
		print FOUT "0.0 ";
	}
	print FOUT "\n";
print FOUT<<EOF;
InfiniteLoopKeptStates=68
FiniteLoops 4
-$Lminus2 $m 2 $Lminus2 $m 2 
-$Lminus2 $m 2 $Lminus2 $m 2 

TargetElectronsUp=$nup
TargetElectronsDown=$ndown
Threads=1
SolverOptions=CorrectionVectorTargeting,restart,minimizeDisk,fixLegacyBugs,vectorwithoffsets
CorrectionA=0
Version=version
RestartFilename=../dataGS_L$L\_N$N\_1500
OutputFile=dataGS_L$L\_N$N\_om$om
CorrectionVectorOmega=$omega
DynamicDmrgType=0
TSPProductOrSum=sum
CorrectionVectorFreqType=Real
CorrectionVectorEta=$Gamma
CorrectionVectorAlgorithm=Krylov
TSPAdvanceEach=$Lminus2
GsWeight=0.1

TSPSites 1 $siteC
TSPLoops 1 1

TSPOperator=expression
OperatorExpression=identity
EOF
close(FOUT);

if ($test eq "test") {
	print STDERR "Created $out!\n";
}

if ($test eq "nobatch") {
	system("./dmrg -f $out -p 12  \"<gs|c?0|P2>,<gs|c?0|gs>\" ");
	sleep(1);
}

}

if ($test eq "submit") {
	system("qsub $outBatch");
	sleep(1);
}

