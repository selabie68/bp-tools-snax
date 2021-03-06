use strict;
use Time::Piece;

# Modified for SNAX by Michael Smith (anarcist)
# Original Author: Eugene Luzgin @ EOS Tribe

my $producer = "<PRODUCER-NAME>";
my $wallet_pswd = "<WALLET-PASSWORD>";
my $datadir = "/root/producer"; #<- change path to yours
my $unlock_cmd = $datadir."/clisnax.sh wallet unlock --password ".$wallet_pswd;
my $prodstats_cmd = $datadir."/clisnax.sh get table snax snax producers -l 10000 | grep -A 7 ".$producer;
my $claim_cmd = $datadir."/clisnax.sh system claimrewards $producer -p $producer";
my $time_diff_24h = 86400;
my $log_entry = "";

open LOG, ">>$datadir/claim.log";
my @prodstats = `$prodstats_cmd`;
my $last_claim_time = 0;
foreach my $stat (@prodstats) {
	if($stat=~m/"last_claim_time": "([0-9]{10})/) {
		$last_claim_time = $1;
	}
}

my $current_time = time();
if($last_claim_time > 0) {
	my $diff_time = $current_time - $last_claim_time;
	print $last_claim_time."->".$current_time.": ".$diff_time. "\n";	
	# 24h period passed - call unlock wallet and claim:
	if($diff_time > $time_diff_24h) {
		#Unlock wallet:
		my $rt = `$unlock_cmd`;
		#Claim rewards:
		my @claim_response = `$claim_cmd`;
		$log_entry = join(' ', @claim_response);
	} else {
		print "Not time yet: ".($time_diff_24h-$diff_time)." secs left!\n";
	}
} else {
	$log_entry = "ERROR: Failed to get last claim time!\n";
}
if($log_entry) {
	print LOG $log_entry;
}
close LOG;
