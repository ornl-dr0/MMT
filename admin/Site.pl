#!/usr/bin/perl 

use CGI qw(:cgi-lib);
ReadParse();
$query=new CGI;
$query->charset('UTF-8');
use DBI;
use Time::Local;
use PGMMT_lib;
$VROOT=$ENV{'VROOT'};
$dbname = &get_dbname;
$user = &get_user;
$password= &get_pwd;
$webserver = &get_webserver;
$peopletab = &get_peopletab;
$archivedb = &get_archivedb;
$dbserver = &get_dbserver;
$facs = &get_facsinfo; #user table
$sites = &get_siteinfotab; #user table
$remote_user=$ENV{'REMOTE_USER'};
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$procType=$in{procType};
$objcttype=$in{objcttype};
$submit = $in{submit};
$site=$in{site};
$site_name=$in{site_name};
$start_date=$in{start_date};
$end_date=$in{end_date};
$site_type=$in{site_type};
$production=$in{production};
$type="S";
#*******************************************************************************
# here is the access to the MMT database
my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
my $userid = $user;
my $password=$password;
my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr; 

#*******************************************************************************
# prepare form page
print $query->header;
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n";
print "<head>\n";
print "<title>MMT: Site Submission</title>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/arm_adv.css\"; --></style>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/fc.css\"; --></style>\n";
print "<style type=\"text/css\" media=\"all\">\n";
print "#content {margin-right:0;background-image: none;}\n";
print "</style>\n";
print "</head>\n";
&showifdev;
print "<body class=\"iops\">\n";
print "<div id=\"content\">\n";
print "<form method=\"post\" action=\"Site.pl\">\n";
if ($remote_user ne "") {
	$sth_getuser=$dbh->prepare("SELECT person_id,name_first,name_last from $peopletab where lower(user_name)=lower('$remote_user')");
        if (!defined $sth_getuser) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getuser->execute;
        while ($getuser = $sth_getuser->fetch) {
		$user_first=$getuser->[1];
		$user_last=$getuser->[2];
		$user_id=$getuser->[0];
	}
} else {
	print "You are not logged into the MMT system\n";
	&bottomlinks($IDNo,"S");
	$dbh->disconnect();
	exit;
}
######################
&toplinks($user_id,$user_first,$user_last,"S");
print "<hr />\n";
if ($submit eq "Reset") {
	if ($in{site} ne "") {
		$site=$in{site};
		$procType=$in{procType};
		
	} else {
		$site = "";
	}
	if ($procType eq "N") {
		$submit="BEGIN";
	} else {
		$submit="Select";
	}
}
if (($procType eq "") && ($submit eq "") && ($IDNo eq "")) {
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"N\"><strong>Enter New Site?</strong><p>\n";
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"E\"><strong>Update Existing Site?</strong><p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"BEGIN\">\n";
	print "</form>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"S");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "BEGIN") {
	if ($procType eq "N") {
		print "<strong>SITE CODE</strong> (<a href=\"metadataexamples.pl?mdtype=site\" target=\"siteex\">examples</a>): <INPUT TYPE=\"text\" name=\"site\" maxlength=4 length=5><p>\n";
		print "<strong>SITE NAME</strong> (<a href=\"metadataexamples.pl?mdtype=site\" target=\"siteex\">examples</a>): <INPUT TYPE=\"text\" name=\"site_name\" maxlength=64 size=100><p>\n";
		print "<strong>SITE START DATE</strong> (yyyymmdd): <input type=\"text\" name=\"start_date\" maxlength=\"8\" length=10><p>\n";
		print "<strong>SITE END DATE (optional)</strong> (yyyymmdd): <input type=\"text\" name=\"end_date\" maxlength=\"8\" length=10><p>\n";
		print "<table>\n";
		print "<tr><td><strong>SITE TYPE</strong>:</td>\n";
		print " <td><SELECT name=\"site_type\" size=6>\n";
		$sth_getsite_type=$dbh->prepare("SELECT distinct site_type,stype_desc from site_type_desc order by site_type");
		if (!defined $sth_getsite_type) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsite_type->execute;
       		while ($getsite_type = $sth_getsite_type->fetch) {
			print "<OPTION value=\"$getsite_type->[0]\">$getsite_type->[0]: $getsite_type->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr></table><p>\n";
		$objcttype="entry";
		print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"S");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
	if ($procType eq "E") {
		print "<table>\n";
		print "<tr><td><strong>EXISTING SITES</strong>:</td>\n";
		print " <td><SELECT name=\"site\" size=6>\n";
		$sth_getsite=$dbh->prepare("SELECT distinct upper(site_code),site_name,site_type from $archivedb.$sites order by site_code");
		if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsite->execute;
       		while ($getsite = $sth_getsite->fetch) {
			print "<OPTION value=\"$getsite->[0]\">$getsite->[0]: $getsite->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr></table><p>\n";

		$objcttype="entry";
		print "<INPUT TYPE=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Select\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"S");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} else {
		print "<strong>Please go back and make a selection</strong><p>\n";
		print "<input type=\"hidden\" name=\"submit\" value=\"\">\n";
		$dbh->disconnect();
		exit;
	}	
} 
if (($submit eq "Select") || (($IDNo ne "") && ($submit ne "Submit"))) {
	if ($IDNo eq "") {
		$sth_getsite = $dbh->prepare("SELECT upper(site_code),site_name,start_date,end_date,production,site_type,DATE_PART('year',start_date),DATE_PART('month',start_date),DATE_PART('day',start_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from $archivedb.$sites WHERE upper(site_code)='$site'");
	} else {
		$procType="E";
		print "<INPUT TYPE=\"hidden\" name=\"IDNo\" value=\"$IDNo\">\n";
		$sth_getsite = $dbh->prepare("SELECT upper(site),site_name,start_date,end_date,production,site_type,DATE_PART('year',start_date),DATE_PART('month',start_date),DATE_PART('day',start_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from sites WHERE IDNo=$IDNo");
	}
	if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getsite->execute;
       	while ($getsite = $sth_getsite->fetch) {
		$site=$getsite->[0];
		$site_name=$getsite->[1];
		$start_date=$getsite->[2];
		$end_date=$getsite->[3];
		$production=$getsite->[4];
		$site_type=$getsite->[5];
		$styr="";
		$stmn="";
		$stdy="";
		$endyr="";
		$endmn="";
		$enddy="";
		$styr=$getsite->[6];
		$stmn=$getsite->[7];
		$len="";
		$len=length $stmn;
		if ($len < 2) {
			$stmn="0"."$stmn";
		}
		$stdy=$getsite->[8];
		$len="";
		$len=length $stdy;
		if ($len != 2) {
			$stdy="0"."$stdy";
		}
		$endyr=$getsite->[9];
		$endmn=$getsite->[10];	
		$len="";
		$len=length $endmn;
		if ($len !=2) {
			$endmn="0"."$endmn";
		}
		$enddy=$getsite->[11];
		$len="";
		$len=length $enddy;
		if ($len != 2) {
			$enddy="0"."$enddy";
		}
		if ($styr ne "") {
			$start_date="$styr"."$stmn"."$stdy";
		} 
		if ($endyr ne "") {
			$end_date="$endyr"."$endmn"."$enddy";
		}
	}
	print "<strong>SITE CODE</strong> (<a href=\"metadataexamples.pl?mdtype=site\" target=\"siteex\">examples</a>): <INPUT TYPE=\"text\" name=\"site\" value=\"$site\" maxlength=4 length=5><p>\n";
	print "<strong>SITE NAME</strong> (<a href=\"metadataexamples.pl?mdtype=site\" target=\"siteex\">examples</a>): <INPUT TYPE=\"text\" name=\"site_name\" value=\"$site_name\" maxlength=64 size=100><p>\n";
	print "<strong>SITE START DATE</strong> (yyyymmdd): <input type=\"text\" name=\"start_date\" maxlength=\"8\" value=\"$start_date\" length=10><p>\n";
	print "<strong>SITE END DATE (optional)</strong> (yyyymmdd): <input type=\"text\" name=\"end_date\" maxlength=\"8\" value=\"$end_date\" length=10><p>\n";
	print "<table>\n";
	print "<tr><td><strong>SITE TYPE</strong>:</td>\n";
	print " <td><SELECT name=\"site_type\" size=6>\n";
	$sth_getsite_type=$dbh->prepare("SELECT distinct site_type,stype_desc from site_type_desc order by site_type");
	if (!defined $sth_getsite_type) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getsite_type->execute;
       	while ($getsite_type = $sth_getsite_type->fetch) {
		if ($site_type eq "$getsite_type->[0]") {
			print "<OPTION value=\"$getsite_type->[0]\" selected>$getsite_type->[0]: $getsite_type->[1]</OPTION>\n";
		} else {
			print "<OPTION value=\"$getsite_type->[0]\">$getsite_type->[0]: $getsite_type->[1]</OPTION>\n";
		}
	}
	print "</SELECT></td>\n";
	print "</tr></table><p>\n";
	print "<strong>PRODUCTION? ";
	if ($production ne "") {
		if ($production eq "Y") {
			print "<INPUT TYPE=\"radio\" name=\"production\" value=\"Y\" checked> Yes ";
			print "<INPUT TYPE=\"radio\" name=\"production\" value=\"N\">No\n";
		} else {
			print "<INPUT TYPE=\"radio\" name=\"production\" value=\"Y\" > Yes ";
			print "<INPUT TYPE=\"radio\" name=\"production\" value=\"N\" checked>No\n";
		}
	} else {
		print "<INPUT TYPE=\"radio\" name=\"production\" value=\"Y\" > Yes ";
		print "<INPUT TYPE=\"radio\" name=\"production\" value=\"N\">No\n";		
	}
	print "<p>\n";
	$objcttype="entry";
	if ($IDNo ne "") {
		$objcttype="update";
	}
	print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
	print "<input type=\"hidden\" name=\"objcttype\" value=\"$objcttype\">\n";
	print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
	print "</form>\n";
	&bottomlinks($IDNo,"S");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Submit") {
	$countmatch=0;
	if (($site eq "") || ($user_id eq "") || ($site_name eq "") || ($start_date eq "") || ($site_type eq "")) {
		print "Required information not entered (site, site name, start date, site type).  Go back and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}
	if ($procType eq "N") {
		$sth_checkit=$dbh->prepare("SELECT count(*),count(*) from sites,IDs where site='$site' and sites.IDNo=IDs.IDNo and IDs.type='S'");
		if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkit->execute;
       		while ($checkit = $sth_checkit->fetch) {
			$countmatch=$checkit->[0];
		}
		if ($countmatch == 0) {
			$site=uc $site;
			$len = length $start_date;
			if ($len != 8) {
				print "Start Date not in proper format. Try again.<br>\n";
				$dbh->disconnect();
				exit;
			}
			if ($end_date eq "") {
				$newend_date="'"."30010101"."'";
			} else {
				$len = length $end_date;
				if ($len != 8) {
					print "End Date not in proper format. Try again.<br>\n";
					$dbh->disconnect();
					exit;
				}
				$newend_date="'"."$end_date"."'";
			}
		} else {
			print "<strong>This site has already been submitted to the MMT review process</strong><p>\n";
			$dbh->disconnect();
			exit;
		}
	}
	if ($procType eq "E")  {
		
		$site=uc $site;
		$sth_checkit=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$sites  where upper(site_code)='$site'");
		if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkit->execute;
       		while ($checkit = $sth_checkit->fetch) {
			$countmatch=$checkit->[0];
		}
		$len = length $start_date;
		if ($len != 8) {
			print "Start Date not in proper format. Try again.<br>\n";
			$dbh->disconnect();
			exit;
		}
		if ($end_date eq "") {
			$newend_date="'"."30010101"."'";
		} else {
			$len = length $end_date;
			if ($len != 8) {
				print "End Date not in proper format. Try again.<br>\n";
				$dbh->disconnect();
				exit;
			}
			$newend_date="'"."$end_date"."'";
		}
		if ($objcttype eq "entry") {
			$sth_checkmmt = $dbh->prepare("SELECT count(*),count(*) from sites,IDs where site='$site' and sites.IDNo=IDs.IDNo and IDs.type='S'");
			if (!defined $sth_checkmmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checkmmt->execute;
       			while ($checkmmt = $sth_checkmmt->fetch) {
				if ($checkmmt->[0] > 0) {
					print "<strong>This site has already been submitted to the MMT review process</strong><p>\n";
					$dbh->disconnect();
					exit;
				}
			}
		}
	}		
	$stat=0;
	if ($countmatch == 0) {
		$stat=0;
	}
	if ($countmatch == 1) {
		$stat=1;
	}
	$REVstat=0;
	$newsubmission=0;
	if ($IDNo eq "") {
		$newsubmission=1;
		$now=&getnow;
		$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$type',$stat,$REVstat,'$now')");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		# retrieve the IDNo which was created by insert above (identity field)
		$IDNo="";
		$sth_getIDNo=$dbh->prepare("SELECT IDNo,type,entry_date from IDs where type='$type' and DBstatus=$stat AND revStatus=$REVstat and entry_date='$now'");
		if (!defined $sth_getIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getIDNo->execute;
       		while ($getIDNo = $sth_getIDNo->fetch) {
			$IDNo=$getIDNo->[0];
		}
		$site=uc $site;
		$nuser_id=$user_id;
		if ($IDNo ne "") {
			$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from sites where IDNo=$IDNo");
			if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getorigsubm->execute;
       			while ($getorigsubm = $sth_getorigsubm->fetch) {
				$nuser_id=$getorigsubm->[0];
			}
		}
		if ($procType eq "N") {
			$doStatus = $dbh->do("INSERT INTO sites values($IDNo,$nuser_id,'$site','$site_name','$start_date',$newend_date,'Y','$site_type',$stat)");
		} else {
			$doStatus = $dbh->do("INSERT INTO sites values($IDNo,$nuser_id,'$site','$site_name','$start_date',$newend_date,'$production','$site_type',$stat)");
		}
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		$now=&getnow;
		$sth_getrevs = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='$type' AND (reviewers.revFunction='MDATA' or reviewers.revFunction='IMPL')");
		if (!defined $sth_getrevs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getrevs->execute;
       		while ($getrevs = $sth_getrevs->fetch) {
			$doStatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],0,'$now')");
			if ( ! defined $doStatus ) {
				print "<hr />\n";
				print "An error has occurred during insert. Please try again<br />\n";
				$dbh->disconnect();
				exit;
			}
		}
		if ($procType eq "N") {
			$objcttype='entry';
			print "<p><strong>Site $site added to MMT for review</strong><p>\n";
			&distribute($nuser_id,"$type",$IDNo,"$objcttype");
		} else {
			$objcttype='update';
			print "<p><strong>Site $site in MMT for review</strong><p>\n";


			&distribute($nuser_id,"$type",$IDNo,"$objcttype");
		}
		print "<hr />\n";
		&bottomlinks($IDNo,"S");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} else {
		$objcttype='update';
		$doStatus = $dbh->do("UPDATE sites set site='$site',site_name='$site_name',start_date='$start_date',end_date=$newend_date,production='$production',site_type='$site_type',statusFlag=1 WHERE IDNo=$IDNo");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during update. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		print "<p><strong>Site $site in MMT for review</strong><p>\n";
		print "<hr />\n";
		&bottomlinks($IDNo,"S");
		print "</div>\n";
		print "</BODY>\n";
		print "</HTML>\n";

		$dbh->disconnect();		
		exit;
	}
}
$dbh->disconnect();
