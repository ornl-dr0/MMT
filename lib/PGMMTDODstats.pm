package PGMMTDODstats;
use 5.006;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(getMMTDODstatsByDateRange);

#!/usr/bin/perl -w

use DBI;
use PGMMT_lib;
use Time::Local;

$dbname = &get_dbname;
$user = &get_user;
$password= &get_pwd;
$dbserver = &get_dbserver;
$peopletab = &get_peopletab;

#connect to database
$dsn = "dbi:Pg:dbname=arm_xdc;host=$dbserver;port=5432;";
$dbh = DBI->connect($dsn, $user, $password) or die $dsn;
#######################
# getStatsByDateRange
#######################


sub getMMTDODStatsByDateRange {
	my $startd = shift;
	my $endd = shift;
	# check date formats
	$start_date = check_date($startd);
	$end_date = check_date($endd);
	# run stats code
	my @ret = compile_stats_dates($start_date,$end_date);
	return @ret;
}
sub check_date {
	my $date_in = shift;
	if ( $date_in =~ m#^\d{4}\d{2}\d{2}$# ) {
		return $date_in;
	} else {
		print "Wrong format. Use YYYYMMDD\n";
		if (defined $dbh) {
			$dbh->disconnect;
			$dbh = undef;
		}

		exit;
	}
}

sub compile_stats_dates {
	# date range - parse and reformat
	my $cdate = shift;
	my $cdate2= shift;
	
	my $stimeperiod="$cdate"." 00:00:00";
	my $etimeperiod="$cdate2"." 23:59:59";

	@finalresults=();
	$countf=0;
	$now = &getnow;
	#get approved DODs that were submitted during the time range
	$sql = qq {
		SELECT DISTINCT idno
		FROM IDs
		WHERE type='DOD'
		AND revstatus != 9999
		AND entry_date >='$stimeperiod'
		AND entry_date <='$etimeperiod'
		order by entry_date, idno;
		
	
	};
	# removed from above query
	#AND revstatus=2
	
	$getid_stmt = $dbh->prepare($sql);
	$getid_stmt->execute or die $getid_stmt->errstr . $dbh->disconnect;
	$counttot=0;
	$finalresults[$countf]="MMT ID#|DS CLASS|VERSION|SUBMITTER|SUBMIT DATE|COMMENT/REVIEW DATE(S)|APPROVAL DATE(S)<br>";
	$countf = $countf + 1;
	while ($getid = $getid_stmt->fetch) {			
		$sql = qq {
			SELECT DISTINCT idno,submitter,name_first,name_last,dsbase,datalevel,dodversion,date_part('year',submitdate),date_part('month',submitdate),date_part('day',submitdate) 
			FROM dod,$peopletab
			WHERE idno = $getid->[0] and dod.submitter=$peopletab.person_id
		};
		$DOD="";
		$submitter="";
		$submitDate="";
		$dsClass="";
		$dodVer="";
		$getdod_stmt = $dbh->prepare($sql);
		$getdod_stmt->execute or die $getdod_stmt->errstr . $dbh->disconnect;
		while($getdod = $getdod_stmt->fetch) {
			$DOD=$getdod->[0];
			$counttot=$counttot+1;
			$submitter="$getdod->[2] $getdod->[3]";
			$dsClass="$getdod->[4].$getdod->[5]";
			$dodVer="$getdod->[6]";
			$mon="";
			if (length($getdod->[8]) < 2) {
				$mon="0$getdod->[8]";
			} else {
				$mon="$getdod->[8]";
			}
			$day="";
			if (length($getdod->[9]) < 2) {
				$day="0$getdod->[9]";
			} else {
				$day="$getdod->[9]";
			}
			$submitDate="$getdod->[7]"."-"."$mon"."-"."$day";		
			#remove some web page headings - tool requestor did not want them
			#if ($counttot > 1) {
			#	$finalresults[$countf] = "<p>---------------------<br>";
			#} else {
			#	$finalresults[$countf] = "<p>";
			#}
			#$countf = $countf + 1;
			#$finalresults[$countf]="MMT# $DOD - DS Class: <strong><font color=\"blue\">$dsClass (Version: $dodVer)</font></strong> Submitter: $submitter Submit Date: $submitDate<br><dd><strong>Comments/Review Dates: </strong>";
			
			
			
			$finalresults[$countf]="$DOD|$dsClass|$dodVer|$submitter|$submitDate";
			
			
			$countf = $countf + 1;
			$sql = qq {
				SELECT DISTINCT date_part('year',commentdate),date_part('month',commentdate),date_part('day',commentdate) 
				FROM reviewerstatus,comments
				WHERE reviewerstatus.idno=$DOD 
				AND reviewerstatus.idno=comments.idno
				AND status !=2
				ORDER BY commentdate;
			};
			$getrevdates_stmt = $dbh->prepare($sql);
			$getrevdates_stmt->execute or die $getrevdates_stmt->errstr . $dbh->disconnect;
			$countrd=0;
			$oldrevdate="";
			$newrevdate="";
			while ($getrevdates = $getrevdates_stmt->fetch) {
				$mon="";
				if (length($getrevdates->[1]) < 2) {
					$mon="0$getrevdates->[1]";
				} else {
					$mon="$getrevdates->[1]";
				}
				$day="";
				if (length($getrevdates->[2]) < 2) {
					$day="0$getrevdates->[2]";
				} else {
					$day="$getrevdates->[2]";
				}
				$newrevdate="$getrevdates->[0]"."-"."$mon"."-"."$day";
				if ($oldrevdate ne $newrevdate) {
					if ($countrd == 0) {
						$finalresults[$countf]="|$newrevdate";
					} else {
						$finalresults[$countf]="$finalresults[$countf], $newrevdate";
					}
					$countrd = $countrd + 1;
				}
				$oldrevdate=$newrevdate;	
			}
		        if ($oldrevdate eq "") {
		        	$finalresults[$countf]="|";
		        }
			$countf=$countf+1;
			#$finalresults[$countf]="</dd><strong><dd>Approval Date(s): </strong>";
			#$countf = $countf + 1;
			$sql = qq {
				SELECT DISTINCT date_part('year',statusdate),date_part('month',statusdate),date_part('day',statusdate) 
				FROM reviewerstatus 
				WHERE idno=$DOD 
				AND status = 2
				ORDER BY statusdate;
			};			 
			#AND statusdate=(SELECT max(statusdate) FROM reviewerstatus WHERE status = 2 and idno=$DOD) # this in above query if we only want final date
			$getapprdates_stmt = $dbh->prepare($sql);
			$getapprdates_stmt->execute or die $getapprdates_stmt->errstr . $dbh->disconnect;
			$countad=0;
			$oldapprdate="";
			$newapprdate="";
			while ($getapprdates = $getapprdates_stmt->fetch) {
				$mon="";
				if (length($getapprdates->[1]) < 2) {
					$mon="0$getapprdates->[1]";
				} else {
					$mon="$getapprdates->[1]";
				}
				$day="";
				if (length($getapprdates->[2]) < 2) {
					$day="0$getapprdates->[2]";
				} else {
					$day="$getapprdates->[2]";
				}
				$newapprdate="$getapprdates->[0]"."-"."$mon"."-"."$day";
				if ($oldapprdate ne $newapprdate) {
					if ($countad == 0) {
						$finalresults[$countf]="|$newapprdate";
					} else {
						$finalresults[$countf]="$finalresults[$countf], $newapprdate";
					}
					$countad=$countad + 1;
				}
				$oldapprdate=$newapprdate;
			}
			if ($oldapprdate eq "") {
		        	$finalresults[$countf]="|";
		        }
			$countf=$countf + 1;
			$finalresults[$countf]="<br>";
			$countf = $countf + 1;	
		}
		
	}
	$finalresults[$countf]="TOTAL for $cdate - $cdate2: $counttot";
	$countf = $countf + 1;
	return @finalresults;
}

sub getnow {
  ($sec,$min,$hour,$mday,$mon,$year)=gmtime;
  $mon = $mon+1;
  $dot=".";
  $colon=":";
  $slash="/";
  $separator=0;
  $space=" ";
	### handle occasions where month, day, year, hour, min
  ### and sec end up being one digit numbers - make them
  ### two digit numbers :)
  if ($mon < 10) {
     $mon="$separator$mon";
  }
  if ($mday < 10) {
     $mday="$separator$mday";
  }
  if ($year < 10) {
      $nyear="$separator$year";
  } else {
      $nyear="$year";
  }
  if (($year >=70) && ($year <=99)) {
      $nyear="19$year";
  } else {
      $nyear=substr($year,1,2);
      $nyear="20$nyear";
  }
  if ($hour < 10) {
     $hour="$separator$hour";
  }
  if ($min < 10) {
      $min="$separator$min";
  }
  if ($sec < 10) {
      $sec="$separator$sec";
  }
  $now=$nyear.$slash.$mon.$slash.$mday.$space.$hour.$colon.$min.$colon.$sec;
	$secsnow=timegm(0,0,0,$mday,$mon-1,$nyear);
  $today=$nyear.$mon.$mday;
	return $now;
}

1;
