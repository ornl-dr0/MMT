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
$submit = $in{submit};
$site=$in{site};
$psite=$in{psite};
$user_id=$in{user_id};
$type='F';
$countinmmt=$in{countinmmt};
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
print "<title>MMT: Facility Submission</title>\n";
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
	print "You are not logged into the MMT<p>\n";
	my $id="";
	&bottomlinks($IDNo,"F");
	$dbh->disconnect();
	exit;
}
&toplinks($user_id,$user_first,$user_last,"F");
print "<hr>\n";
if ($submit eq "Reset") {
	$psite="";
	$site="";
	$facility_code = "";
}
print "<form method=\"post\" action=\"Facility.pl\">\n";

if ($IDNo ne "") {
	$sth_chksite = $dbh->prepare("SELECT IDNo,site from facilities where IDNo=$IDNo");
	if (!defined $sth_chksite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_chksite->execute;
        while ($chksite = $sth_chksite->fetch) {
		$site=uc $chksite->[1];
	}
}
if (($site eq "") && ($psite eq "")) {
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
	$countproposed=0;

	$sth_countp = $dbh->prepare("SELECT count(*),count(*) from sites where upper(site) not in (SELECT distinct upper(site_code) from $archivedb.$sites)");
	if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_countp->execute;
        while ($countp = $sth_countp->fetch) {
		$countproposed=$countp->[0];
	}
	if ($countproposed > 0) {
		print "</tr><tr><td><strong>PROPOSED SITES</strong>:</td>\n";
		print "<td><SELECT name=\"psite\" size=6>\n";
		$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),site_name,site_type from sites order by site");
		if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getpropsite->execute;
        	while ($getpropsite = $sth_getpropsite->fetch) {
			$match=0;
			$sth_getsite=$dbh->prepare("SELECT distinct upper(site_code),site_name,site_type from $archivedb.$sites order by site_code");
			if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsite->execute;
        		while ($getsite = $sth_getsite->fetch) {
				if ($getsite->[0] eq $getpropsite->[0]) {
					$match = 1;
				}
			}
			if ($match == 0) {
				print "<OPTION value=\"$getpropsite->[0]\">$getpropsite->[0]: $getpropsite->[1]</OPTION>\n";
			}
		}
	}
	print "</tr></table><p>\n";
	print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" 
value=\"Reset\"> <hr>\n";
	print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
	&bottomlinks($IDNo,"F");
	print "</form>\n";
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
} else {
	if ($submit eq "") {
		$submit="Submit";
	}
}

if ($submit eq "Submit") {
	if ((($site eq "") && ($psite eq "")) || ($user_id eq "")) {
		print "Go back and select a site and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}
	if (($site ne "") && ($psite ne "")) {
		print "You can only choose one site at a time.  Please go back and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}	
	$countinmmt=0;
	if ($site ne "") {
		$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from facilities,IDs where site='$site' and facilities.IDNo=IDs.IDNo and IDs.type='F'");
	} elsif ($psite ne "") {
		$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from facilities,IDs where site='$psite' and facilities.IDNo=IDs.IDNo and IDs.type='F'");
	}
	if (!defined $sth_checksite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_checksite->execute;
        while ($checksite = $sth_checksite->fetch) {
	#check if site already in MMT process
		$countinmmt = $checksite->[0];
	}
	if ($countinmmt > 0) {
		$countinmmt=1;
	}
	if ($site ne "") {
		$countf=0;
		# existing site (at archive) - need to display all existing facilities 
		print "<strong>SITE Code:</strong> $site<p>\n";
		print "<strong>Existing Facility(ies):</strong><br>\n";	
		$sth_getfacs=$dbh->prepare("SELECT distinct upper($archivedb.$facs.site_code),$archivedb.$facs.facility_code,$archivedb.$facs.facility_name from $archivedb.$facs where upper($archivedb.$facs.site_code)='$site' order by $archivedb.$facs.facility_code");
		if (!defined $sth_getfacs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getfacs->execute;
        	while ($getfacs = $sth_getfacs->fetch) {
			print "<dd>$getfacs->[1]: $getfacs->[2]</dd>\n";
			$countf = $countf + 1;
		}
		if ($countinmmt > 0) {
			print "<p><strong>Proposed/Updated Facility(ies):</strong><br>\n";
			$sth_getfacs = $dbh->prepare("SELECT upper(site),facility_code,facility_name,facilities.IDNo from facilities,IDs where upper(site)='$site' and facilities.IDNo=IDs.IDNo and IDs.type='F' order by facility_code");
			if (!defined $sth_getfacs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getfacs->execute;
        		while ($getfacs = $sth_getfacs->fetch) {
				print "<dd>$getfacs->[1]: $getfacs->[2]</dd>\n";
				$countf = $countf + 1;
				$IDNo=$getfacs->[3];
			}
		}
		if ($countf == 0) {
			print "<dd>None so far</dd>\n";
		}
	} elsif ($psite ne "") {
		print "<strong>SITE: $psite</strong><p>\n";
		print "<strong>Proposed Facility(ies):<br>\n";
		$countf=0;
		
		$sth_getfacs = $dbh->prepare("SELECT upper(site),facility_code,facility_name,facilities.IDNo from facilities,IDs where upper(site)='$psite' and facilities.IDNo=IDs.IDNo and IDs.type='F' order by facility_code");
		if (!defined $sth_getfacs) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_getfacs->execute;
        	while ($getfacs = $sth_getfacs->fetch) {
			print "<dd>$getfacs->[1]: $getfacs->[2]</dd>\n";
			$IDNo=$getfacs->[3];
			$countf=1;
		}
		if ($countf == 0) {
			print "<dd>None so far</dd>\n";
		}
	}
	print "<p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"Add facilities?\"> ";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"Update existing/proposed facilities?\">\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"Delete facilities from MMT review?\">\n";
	print "<hr>\n";
	print "<INPUT TYPE=\"hidden\" name=\"countinmmt\" value=\"$countinmmt\">\n";
	if ($psite ne "") {
		print "<INPUT TYPE=\"hidden\" name=\"site\" value=\"$psite\">\n";
	} elsif ($site ne "") {
		print "<INPUT TYPE=\"hidden\" name=\"site\" value=\"$site\">\n";
	}
	print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"faccount\" value=\"0\">\n";
	if ($IDNo ne "") {
		print "<INPUT TYPE=\"hidden\" name=\"IDNo\" value=\"$IDNo\">\n";
	}
	print "</form>\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Add facilities?") {
	$faccount=$in{faccount};
	$site=$in{site};
	$user_id=$in{user_id};
	$countinmmt=$in{countinmmt};
	print "<strong>SITE CODE</strong>:$site<p>\n";
	$sth_checkexist = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs WHERE upper(site_code)='$site'");
	if (!defined $sth_checkexist) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_checkexist->execute;
        while ($checkexist = $sth_checkexist->fetch) {
		$countexist=$checkexist->[0];
	}
	if ($countexist > 0) {
		print "<dd><strong>Existing Facilities:</strong><br>\n";
		$sth_getfacs = $dbh->prepare("SELECT distinct facility_code,facility_name from $archivedb.$facs WHERE upper(site_code)='$site' and facility_code not in (SELECT distinct facility_code from facilities,IDs where site='$site' and facilities.IDNo=IDs.IDNo and IDs.type='F')");
		if (!defined $sth_getfacs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getfacs->execute;
        	while ($getfacs = $sth_getfacs->fetch) {
			print "<dd>$getfacs->[0]: $getfacs->[1]</dd>\n";
		}
		print "</dd>\n";
	}
	if ($countinmmt > 0) {
		print "<dd><strong>Proposed/Updated Facilities:</strong><br>\n";
		$sth_getfacs = $dbh->prepare("SELECT distinct facility_code,facility_name,facilities.IDNo from facilities,IDs where upper(site)='$site' and facilities.IDNo=IDs.IDNo and IDs.type='F'");
		if (!defined $sth_getfacs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getfacs->execute;
        	while ($getfacs = $sth_getfacs->fetch) {
			print "<dd>$getfacs->[0]: $getfacs->[1]</dd>\n";
			$IDNo=$getfacs->[2];
		}
		print "</dd>\n";
	}
	print "<p><strong>FACILITY CODE</strong> (<a href=\"metadataexamples.pl?mdtype=facility_code\" target=\"facex\">examples</a>): <INPUT TYPE=\"text\" name=\"facility_code\" maxlength=6><p>\n";
	print "<strong>FACILITY NAME</strong> (<a href=\"metadataexamples.pl?mdtype=facility_code\" target=\"facex\">examples</a>): <INPUT TYPE=\"text\" name=\"facility_name\" maxlength=100 size=\"100\"><p>\n";
	print "<strong>FACILITY START DATE</strong> (yyyymmdd): <input type=\"text\" name=\"fstart_date\" maxlength=\"8\" length=10><p>\n";
	print "<strong>FACILITY END DATE (optional)</strong> (yyyymmdd): <input type=\"text\" name=\"fend_date\" maxlength=\"8\" length=10><p>\n";
	print "<INPUT type=\"submit\" name=\"submit\" value=\"Add another facility?\"> ";
	print " <input type=\"submit\" name=\"submit\" value=\"Done adding facilities\"> <input type=\"submit\" name=\"submit\" 
value=\"Reset\"> <hr>\n";
	print "<INPUT TYPE=\"hidden\" name=\"site\" value=\"$site\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"countinmmt\" value=\"$countinmmt\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"faccount\" value=\"$faccount\">\n";
	if ($IDNo ne "") {
		print "<INPUT TYPE=\"hidden\" name=\"IDNo\" value=\"$IDNo\">\n";
	}
	print "</form>\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Delete facilities from MMT review?") {
	$countf=0;
	print "<strong>Please select facilities to delete from MMT review below:</strong><p>\n";
	$sth_getf = $dbh->prepare("SELECT facility_code,facility_name FROM facilities WHERE IDNo=$IDNo order by facility_code");
	if (!defined $sth_getf) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getf->execute;
        while ($getf = $sth_getf->fetch) {
		print "<INPUT TYPE=\"checkbox\" name=\"facility_code\" value=\"$getf->[0]\">$getf->[0]: $getf->[1]<br />\n";
	}
	if ($IDNo ne "") {
		print "<INPUT TYPE=\"HIDDEN\" name=\"IDNo\" value=\"$IDNo\">\n";
	}
	print "<br /><input type=\"submit\" name=\"submit\" value=\"Delete\"><p>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Delete") {
	@tempfc = split(/\0/,$in{facility_code});
	foreach $tfc (@tempfc) {
		$doStatus=$dbh->do("DELETE from facilities where IDNo=$IDNo and facility_code='$tfc'");
	}
	print "<strong>Facility(ies) Deleted from MMT Review<br>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Update existing/proposed facilities?") {
	$countf=0;
	print "<strong>Please make your updates in the fields below:</strong><p>\n";
	$sth_getf = $dbh->prepare("SELECT site_code,facility_code,facility_name,DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from $archivedb.$facs WHERE upper(site_code)='$site'  and facility_code not in (SELECT distinct facility_code from facilities,IDs where site='$site' and facilities.IDNo=IDs.IDNo and IDs.type='F') order by facility_code");
	if (!defined $sth_getf) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getf->execute;
        while ($getf = $sth_getf->fetch) {
		$sty="";
		$stm="";
		$std="";
		$endy="";
		$endm="";
		$endd="";
		$fsdate="";
		$fedate="";
		$nfaccode = "$getf->[1]"."|"."$countf";
		$nfacname = "$getf->[2]"."|"."$countf";
		$sty=$getf->[3];
		$stm=$getf->[4];
		$std=$getf->[5];
		$endy=$getf->[6];
		$endm=$getf->[7];
		$endd=$getf->[8];
		$len=0;
		$len=length $stm;
		if ($len < 2) {
			$stm = "0"."$stm";
		}
		$len=0;
		$len=length $std;
		if ($len < 2) {
			$std = "0"."$std";
		}
		$fsdate="$sty"."$stm"."$std";
		$nfacsdate = "$fsdate"."|"."$countf";
		$len=0;
		$len=length $endm;
		if ($len < 2) {
			$endm = "0"."$endm";
		}
		$len=0;
		$len=length $endd;
		if ($len < 2) {
			$endd = "0"."$endd";
		}
		$fedate="$endy"."$endm"."$endd";
		$nfacedate = "$fedate"."|"."$countf";
		if ((length $fedate) < 8) {
			$fedate="";
			$nfacedate="NULL"."|"."$countf";
		}
		print "<strong>FACILITY CODE</strong>: <INPUT TYPE=\"text\" name=\"fc$countf\" value=\"$getf->[1]\" maxlength=6 size=10><p>\n";
		print "<strong>FACILITY NAME</strong>: <INPUT TYPE=\"text\" name=\"fn$countf\" value=\"$getf->[2]\" maxlength=100 size=\"100\"><p>\n";
		print "<strong>FACILITY START DATE</strong> (yyyymmdd): <input type=\"text\" name=\"fs$countf\" value=\"$fsdate\" maxlength=\"8\" size=10><p>\n";
		print "<strong>FACILITY END DATE (optional)</strong> (yyyymmdd): <input type=\"text\" name=\"fe$countf\" value=\"$fedate\" maxlength=\"8\" length=10><hr />\n";
		print "<INPUT TYPE=\"HIDDEN\" name=\"ofc$countf\" value=\"$getf->[1]\">\n";
		print "<INPUT TYPE=\"HIDDEN\" name=\"ofn$countf\" value=\"$getf->[2]\">\n";
		print "<INPUT TYPE=\"HIDDEN\" name=\"ofs$countf\" value=\"$fsdate\">\n";
		print "<INPUT TYPE=\"HIDDEN\" name=\"ofe$countf\" value=\"$fedate\">\n";
		$countf = $countf + 1;	
	}
	if ($countinmmt > 0) {
		$sth_getf = $dbh->prepare("SELECT IDNo,facility_code,facility_name,DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from facilities where IDNo=$IDNo order by facility_code");
		if (!defined $sth_getf) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getf->execute;
        	while ($getf = $sth_getf->fetch) {
			$sty="";
			$stm="";
			$std="";
			$endy="";
			$endm="";
			$endd="";
			$fsdate="";
			$fedate="";
			$nfaccode = "$getf->[1]"."|"."$countf";
			$nfacname = "$getf->[2]"."|"."$countf";
			$sty=$getf->[3];
			$stm=$getf->[4];
			$std=$getf->[5];
			$endy=$getf->[6];
			$endm=$getf->[7];
			$endd=$getf->[8];
			$len=0;
			$len=length $stm;
			if ($len < 2) {
				$stm = "0"."$stm";
			}
			$len=0;
			$len=length $std;
			if ($len < 2) {
				$std = "0"."$std";
			}
			$fsdate="$sty"."$stm"."$std";
			$nfacsdate = "$fsdate"."|"."$countf";
			$len=0;
			$len=length $endm;
			if ($len < 2) {
				$endm = "0"."$endm";
			}
			$len=0;
			$len=length $endd;
			if ($len < 2) {
				$endd = "0"."$endd";
			}
			$fedate="$endy"."$endm"."$endd";
			$nfacedate = "$fedate"."|"."$countf";
			if ((length $fedate) < 8) {
				$fedate="";
				$nfacedate="NULL"."|"."$countf";
			}
			print "<strong>FACILITY CODE</strong>: <INPUT TYPE=\"text\" name=\"fc$countf\" value=\"$getf->[1]\" maxlength=6 size=10><p>\n";
			print "<strong>FACILITY NAME</strong>: <INPUT TYPE=\"text\" name=\"fn$countf\" value=\"$getf->[2]\" maxlength=100 size=\"100\"><p>\n";
			print "<strong>FACILITY START DATE</strong> (yyyymmdd): <input type=\"text\" name=\"fs$countf\" value=\"$fsdate\" maxlength=\"8\" size=10><p>\n";
			print "<strong>FACILITY END DATE (optional)</strong> (yyyymmdd): <input type=\"text\" name=\"fe$countf\" value=\"$fedate\" maxlength=\"8\" length=10><hr />\n";
			print "<INPUT TYPE=\"HIDDEN\" name=\"ofc$countf\" value=\"$getf->[1]\">\n";
			print "<INPUT TYPE=\"HIDDEN\" name=\"ofn$countf\" value=\"$getf->[2]\">\n";
			print "<INPUT TYPE=\"HIDDEN\" name=\"ofs$countf\" value=\"$fsdate\">\n";
			print "<INPUT TYPE=\"HIDDEN\" name=\"ofe$countf\" value=\"$fedate\">\n";
			$countf = $countf + 1;	
		}
	}

	if ($IDNo ne "") {
		print "<INPUT TYPE=\"HIDDEN\" name=\"IDNo\" value=\"$IDNo\">\n";
	}
	print "<INPUT TYPE=\"HIDDEN\" name=\"countinmmt\" value=\"$countinmmt\">\n";
	print "<INPUT TYPE=\"HIDDEN\" name=\"site\" value=\"$site\">\n";
	print "<INPUT TYPE=\"HIDDEN\" name=\"countf\" value=\"$countf\">\n";
	print "<br /><input type=\"submit\" name=\"submit\" value=\"Update\"><p>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Update") {
	$countf=$in{countf};
	$c=0;
	if ($countinmmt == 0) {
		$DBstat="";
		$sth_checkarchive = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs WHERE upper(site_code)='$site'");
		if (!defined $sth_checkarchive) { die "Cannot prepare statement test: $DBI::errstr\n"; }
        	$sth_checkarchive->execute;
        	while ($checkarchive = $sth_checkarchive->fetch) {
			if ($checkarchive->[0] > 0) {
				$sth_checkfac = $dbh->prepare("SELECT count(*),count(*) from facilities,IDs where upper(site)='$site' and statusFlag=0 and facilities.IDNo=IDs.IDNo and IDs.type='F'");
				if (!defined $sth_checkfac) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checkfac->execute;
       			 	while ($checkfac = $sth_checkfac->fetch) {
					if ($checkfac->[0] > 0) {
						$DBstat=-1;
					} else {
						$DBstat=1;
					}
				}
			} else {
				$DBstat=0;
			}
		}
		$REVstat=0;
		$now=&getnow;
		$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$type',$DBstat,$REVstat,'$now')");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		# retrieve the IDNo which was created by insert above (identity field)
		$IDNo="";
		$sth_getIDNo=$dbh->prepare("SELECT IDNo,type,entry_date from IDs where type='$type' and DBstatus=$DBstat and revStatus=$REVstat and entry_date='$now'");
		if (!defined $sth_getIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getIDNo->execute;
        	while ($getIDNo = $sth_getIDNo->fetch) {
			$IDNo=$getIDNo->[0];
		}
	} else {
		$DBstat="";
		
		$sth_checkarchive = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs WHERE upper(site_code)='$site'");
		if (!defined $sth_checkarchive) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkarchive->execute;
        	while ($checkarchive = $sth_checkarchive->fetch) {
			if ($checkarchive->[0] > 0) {
				$sth_checkfac = $dbh->prepare("SELECT count(*),count(*) from facilities,IDs where upper(site)='$site' and statusFlag=0 and facilities.IDNo=IDs.IDNo and IDs.type='F'");
				if (!defined $sth_checkfac) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checkfac->execute;
       				while ($checkfac = $sth_checkfac->fetch) {
					if ($checkfac->[0] > 0) {
						$DBstat=-1;
					} else {
						$DBstat=1;
					}
				}
			} else {
				$DBstat=0;
			}
		}
	}
	$countinarchive=0;
	while ($c < $countf) {
		$fc="";
		$fn="";
		$fs="";
		$fe="";
		$ofc="";
		$ofn="";
		$ofs="";
		$ofe="";
		$$namefc="fc"."$c";
		$$namefn="fn"."$c";
		$$namefs="fs"."$c";
		$$namefe="fe"."$c";
		$$oldnamefc="ofc"."$c";
		$$oldnamefn="ofn"."$c";
		$$oldnamefs="ofs"."$c";
		$$oldnamefe="ofe"."$c";
		$fc=$in{$$namefc};
		$fn=$in{$$namefn};
		$fs=$in{$$namefs};
		$fe=$in{$$namefe};
		$ofc=$in{$$oldnamefc};
		$ofn=$in{$$oldnamefn};
		$ofs=$in{$$oldnamefs};
		$ofe=$in{$$oldnamefe};
		if ($fe eq "") {
			$ufe="\'30010101\'";
		} else {
			$ufe="\'$fe\'";
		}
		if ($ofe eq "") {
			$oufe="\'30010101\'";
		} else {
			$oufe="\'$ofe\'";
		}
		$match=0;
		$sth_chkdb = $dbh->prepare("SELECT count(*),count(*) from facilities,IDs where site='$site' and facility_code='$fc' and facilities.IDNo=IDs.IDNo and IDs.type='F'");
		if (!defined $sth_chkdb) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_chkdb->execute;
        	while ($chkdb = $sth_chkdb->fetch) {
			$match=$chkdb->[0];
		}
		$nuser_id=$user_id;
		if ($IDNo ne "") {
			$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from facilities where IDNo=$IDNo");
			if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getorigsubm->execute;
        		while ($getorigsubm = $sth_getorigsubm->fetch) {
				$nuser_id=$getorigsubm->[0];
			}
		}
		if ($match > 0) {
			$doit=0;
			$sth_checkdb = $dbh->prepare("SELECT count(*),count(*) from facilities where IDNo=$IDNo and site='$site' and facility_code='$fc' and facility_name='$fn' and eff_date='$fs' and end_date=$ufe");
			if (!defined $sth_checkdb) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checkdb->execute;
       			while ($checkdb = $sth_checkdb->fetch) {
				$doit=$checkdb->[0];
			}
			if ($doit == 0) {
				$doStatus = $dbh->do("UPDATE facilities set facility_code='$fc',facility_name='$fn',eff_date='$fs',end_date=$ufe WHERE IDNo=$IDNo and facility_code='$ofc' and facility_name='$ofn' and eff_date='$ofs'");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during update. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
				$countinarchive = $countinarchive + 1;
			}
		} else {
			$match=0;
			$sth_checkarch = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs where upper(site_code)='$site' and facility_code='$fc' AND facility_name='$fn'");
			if (!defined $sth_checkarch) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checkarch->execute;
        		while ($checkarch = $sth_checkarch->fetch) {
				$match=$checkarch->[0];
			}
			if ($match == 0) {
				$doStatus = $dbh->do("INSERT INTO facilities values($IDNo,$nuser_id,'$site','$fc','$fn','$fs',$ufe,1)");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			} else {
				$afstart="";
				$afend="";
				$afsy="";
				$afsm="";
				$afsd="";
				$afey="";
				$afem="";
				$afed="";
				$sth_checkdates = $dbh->prepare("SELECT DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from $archivedb.$facs where upper(site_code)='$site' and facility_code='$fc' and facility_name='$fn'");
				if (!defined $sth_checkdates) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checkdates->execute;
        			while ($checkdates = $sth_checkdates->fetch) {
					$afsy=$checkdates->[0];
					$len=0;
					$len = length $checkdates->[1];
					if ($len < 2) {
						$afsm = "0"."$checkdates->[1]";
					} else {
						$afsm=$checkdates->[1];
					}
					$len=0;
					$len = length $checkdates->[2];
					if ($len < 2) {
						$afsd="0"."$checkdates->[2]";
					} else {
						$afsd=$checkdates->[2];
					}
					$afstart="$afsy"."$afsm"."$afsd";
					if ($checkdates->[3] ne "") {
						$afey=$checkdates->[3];
						$len=0;
						$len = length $checkdates->[4];
						if ($len < 2) {
							$afem="0"."$checkdates->[4]";
						} else {
							$afem=$checkdates->[4];
						}
						$len=0;
						$len = length $checkdates->[5];
						if ($len < 2) {
							$afed="0"."$checkdates->[5]";
						} else {
							$afed=$checkdates->[5];
						}
						$afend="\'"."$afey"."$afem"."$afed"."\'";
					} else {
						$afend="NULL";
					}
				}
				if (($fs eq $afstart) && ($ufe eq $afend)) {
					$match=1;
				} else {
					$match = 0;
				}
				if ($match == 0) {
					$sth_finalcheck=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs where upper(site_code)='$site' and facility_code='$fc' and facility_name='$fn'");
					if (!defined $sth_finalcheck) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_finalcheck->execute;
        				while ($finalcheck = $sth_finalcheck->fetch) {
						$countinarchive=$countinarchive + 1;
					}
					$doStatus = $dbh->do("INSERT INTO facilities values($IDNo,$nuser_id,'$site','$fc','$fn','$fs',$ufe,1)");
					if ( ! defined $doStatus ) {
						print "<hr />\n";
						print "An error has occurred during insert. Please try again<br />\n";
						$dbh->disconnect();
						exit;
					}
					$now=&getnow;
					$sth_getrevs = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type=\'$type\' and (reviewers.revFunction='MDATA' or reviewers.revFunction='IMPL')");
	
					if ($inprog == 0) {
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
					}
				}
			}
		}
		$c = $c + 1;
	}
	$chkc=0;
	$chkc2=0;
	$dstat=1;
	$sth_checkcount = $dbh->prepare("SELECT count(*),count(*) from facilities where IDNo=$IDNo and statusFlag=0");
	if (!defined $sth_checkcount) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_checkcount->execute;
        while ($checkcount = $sth_checkcount->fetch) {
		$chkc = $checkcount->[0];
	}
	$sth_checkcount = $dbh->prepare("SELECT count(*),count(*) from facilities where IDNo=$IDNo and statusFlag=1");
	if (!defined $sth_checkcount) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_checkcount->execute;
        while ($checkcount = $sth_checkcount->fetch) {
		$chkc2 = $checkcount->[0];
	}
	if ($chkc == $countf) {
		$dstat=0;
	}
	if (($chkc2 != $countf) && ($chkc2 > 0) && ($chkc > 0)) {
		$dstat=-1;
	}
	$doStatus = $dbh->do("UPDATE IDs set DBstatus=$dstat where IDNo=$IDNo");
	print "<strong>Facilities updated</strong><p>\n";
	print "<strong>NOTIFICATION OF UPDATE SENT TO REVIEWERS AND SUBMITTER</strong><p>\n";
	if ($countinmmt == 0) {
		$objcttype='entry';
	} else {
		$objcttype='update';
	}
	&distribute($nuser_id,"$type",$IDNo,"$objcttype");
	print "<hr />\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Add another facility?") {
	$facility_code=$in{facility_code};
	$facility_name=$in{facility_name};
	$fstart_date=$in{fstart_date};
	$fend_date=$in{fend_date};
	if ( ($site eq "")  || ($user_id eq "") || ($facility_code eq "") || ($facility_name eq "") || ($fstart_date eq "")) {	
	print "Required information not entered (facility code, facility name, start date).  Go back and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}
	$faccount=$in{faccount};
	if ($fend_date eq "") {
		$fend_date="NULL";
	}
	$countinmmt=$in{countinmmt};
	$site=$in{site};
	$user_id=$in{user_id};
	$faccode=$in{faccode};
	$facname=$in{facname};
	$facstdate=$in{facstdate};
	$facenddate=$in{facenddate};
	if ($faccount == 0) {
		$faccode="$facility_code";
		$facname="$facility_name";
		$facstdate="$fstart_date";
		$facenddate="$fend_date";
	} else {
		$faccode="$faccode"."|"."$facility_code";
		$facname="$facname"."|"."$facility_name";
		$facstdate="$facstdate"."|"."$fstart_date";
		$facenddate="$facenddate"."|"."$fend_date";
	}
	@tempfc=();
	@tempfn=();
	@tempfs=();
	@tempfe=();
	$countfsofar=0;
	print "<strong>SITE CODE</strong>:$site<br>\n";
	@tempfc=split(/\|/,$faccode);
	@tempfn=split(/\|/,$facname);
	$countfsofar=@tempfc;
	if ($countfsofar > 0) {
		$idxf=0;
		foreach $tfc (@tempfc) {
			print "<dd>$tfc: $tempfn[$idxf]</dd>\n";
			$idxf=$idxf + 1;
		}
	}
	print "<p>\n";
	$faccount = $faccount + 1;
	$facility_code="";
	$facility_name="";
	$fstart_date="";
	$fend_date="";
	print "<strong>FACILITY CODE</strong> (<a href=\"metadataexamples.pl?mdtype=facility_code\" target=\"facex\">examples</a>): <INPUT TYPE=\"text\" name=\"facility_code\" maxlength=6><p>\n";
	print "<strong>FACILITY NAME</strong> (<a href=\"metadataexamples.pl?mdtype=facility_code\" target=\"facex\">examples</a>): <INPUT TYPE=\"text\" name=\"facility_name\" maxlength=100 size=\"100\"><p>\n";
	print "<strong>FACILITY START DATE</strong> (yyyymmdd): <input type=\"text\" name=\"fstart_date\" maxlength=\"8\" length=10><p>\n";
	print "<strong>FACILITY END DATE (optional)</strong> (yyyymmdd): <input type=\"text\" name=\"fend_date\" maxlength=\"8\" length=10><p>\n";
	print "<INPUT type=\"submit\" name=\"submit\" value=\"Add another facility?\"> ";
	print " <input type=\"submit\" name=\"submit\" value=\"Done adding facilities\"> <input type=\"submit\" name=\"submit\" 
value=\"Reset\"> <hr>\n";
	print "<INPUT TYPE=\"hidden\" name=\"site\" value=\"$site\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"countinmmt\" value=\"$countinmmt\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"faccount\" value=\"$faccount\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"faccode\" value=\"$faccode\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"facname\" value=\"$facname\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"facstdate\" value=\"$facstdate\">\n";
	print "<INPUT TYPE=\"hidden\" name=\"facenddate\" value=\"$facenddate\">\n";
	if ($IDNo ne "") {
		print "<INPUT TYPE=\"hidden\" name=\"IDNo\" value=\"$IDNo\">\n";
	}
	print "</form>\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Done adding facilities") {
	$faccount=$in{faccount};
	$facility_code=$in{facility_code};
	$facility_name=$in{facility_name};
	$fstart_date=$in{fstart_date};
	$fend_date=$in{fend_date};
	if ($fend_date eq "") {
		$fend_date="NULL";
	}
	$site=$in{site};
	$psite=$in{psite};
	$user_id=$in{user_id};
	$faccode=$in{faccode};
	$facname=$in{facname};
	$facstdate=$in{facstdate};
	$facenddate=$in{facenddate};
	$countinmmt=$in{countinmmt};
	if ( ($site eq "") || ($user_id eq "") || ($facility_code eq "") || ($facility_name eq "") || ($fstart_date eq "")) {
		print "Required information not entered (facility code, facility name, start date).  Go back and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}
	$nuser_id=$user_id;
	if ($IDNo ne "") {
		$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from instClass where IDNo=$IDNo");
		if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_getorigsubm->execute;
       	 	while ($getorigsubm = $sth_getorigsubm->fetch) {
			$nuser_id=$getorigsubm->[0];
		}
	}
	if ($faccount > 0) {
		$faccode="$faccode"."|"."$facility_code";
		$facname="$facname"."|"."$facility_name";
		$facstdate="$facstdate"."|"."$fstart_date";
		$facenddate="$facenddate"."|"."$fend_date";
	} else {
		$faccode="$facility_code";
		$facname="$facility_name";
		$facstdate="$fstart_date";
		$facenddate="$fend_date";
	}
	@faccodearray=();
	@facnamearray=();
	@facstdatearray=();
	@facenddatearray=();
	@faccodearray=split(/\|/,$faccode);
	@facnamearray=split(/\|/,$facname);
	@facstdatearray=split(/\|/,$facstdate);
	@facenddatearray=split(/\|/,$facenddate);
	$type='F';
	$stat=0;
	$DBstat=0;
	$REVstat=0;
	$idx=0;
	$now=&getnow;
	$inprog=0;
	$sth_chksite=$dbh->prepare("SELECT distinct facilities.IDNo,site from facilities,IDs where site='$site' and facilities.IDNo=IDs.IDNo and IDs.type='F'");
	if (!defined $sth_chksite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_chksite->execute;
        while ($chksite = $sth_chksite->fetch) {
		if ($chksite->[1] eq "$site") {
			$inprog=1;
		}
	}
	if ($inprog == 0) {
		$countex=0;
		foreach $fc (@faccodearray) {
			$sth_checkarchive = $dbh->prepare("SELECT facility_code,facility_code from $archivedb.$facs where upper($archivedb.$facs.site_code)='$site' and facility_code='$fc'");
			if (!defined $sth_checkarchive) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checkarchive->execute;
        		while ($checkarchive = $sth_checkarchive->fetch) {
				$countex = $countex + 1;
			}
		}
		$DBstat=0;
		$countex2=0;
		$sth_countarchive2 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs where upper($archivedb.$facs.site_code)='$site'");
		if (!defined $sth_countarchive2) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_countarchive2->execute;
        	while ($countarchive2 = $sth_countarchive2->fetch) {
			$countex2 = $countarchive2->[0];
		}
		if ($countex == $countex2) {
			if ($countex2 == 0) {
				$DBstat=0;
			} else {
				$DBstat=1;
			}
		}
		if  (($countex != $countex2) && ($countex > 0)) {
			$DBstat=-1;
		}
		$now=&getnow;
		$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$type',$DBstat,$REVstat,'$now')");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		# retrieve the IDNo which was created by insert above (identity field)
		$IDNo="";
		$sth_getIDNo=$dbh->prepare("SELECT IDNo,type,entry_date from IDs where type='$type' and DBstatus=$DBstat and revStatus=$REVstat and entry_date='$now'");
		if (!defined $sth_getIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getIDNo->execute;
        	while ($getIDNo = $sth_getIDNo->fetch) {
			$IDNo=$getIDNo->[0];
		}
	} else {
		$IDNo="";
		$sth_getIDNo=$dbh->prepare("SELECT distinct facilities.IDNo,site from facilities,IDs where site='$site' and facilities.IDNo=IDs.IDNo and IDs.type='F'");
		if (!defined $sth_getIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getIDNo->execute;
        	while ($getIDNo = $sth_getIDNo->fetch) {
			$IDNo=$getIDNo->[0];
		}
	}
	$countinarchive=0;
	while ($idx <= $faccount) {
		$dbst="";
		$newedate="";
		if (($facenddatearray[$idx] eq "") || ($facenddatearray[$idx] eq "NULL"))  {
			$newedate="'"."30010101"."'";
		} else {
			$newedate="'"."$facenddatearray[$idx]"."'";
		}
		$sth_checkarchive = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs where upper($archivedb.$facs.site_code)='$site' and facility_code='$faccodearray[$idx]'");
		if (!defined $sth_checkarchive) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkarchive->execute;
        	while ($checkarchive = $sth_checkarchive->fetch) {
			if ($checkarchive->[0] > 0) {
				$dbst=-1;
				$countinarchive=$countinarchive + 1;
			} else {
				$dbst=0;
			}
		}
		$doStatus = $dbh->do("INSERT INTO facilities values($IDNo,$nuser_id,'$site','$faccodearray[$idx]','$facnamearray[$idx]','$facstdatearray[$idx]',$newedate,$dbst)");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		$idx = $idx + 1;
	}
	$ds=0;
	if ($countinarchive == 0) {
		$sth_checka  = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facs where upper($archivedb.$facs.site_code)='$site'");
		if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checka->execute;
        	while ($checka = $sth_checka->fetch) {
			if (checka->[0] > 0) {
				$sth_checkdb = $dbh->prepare("SELECT count(*),count(*) from facilities,IDs where site='$site' and statusFlag=1 and facilities.IDNo=IDs.IDNo and IDs.type='F'");
				if (!defined $sth_checkdb) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checkdb->execute;
        			while ($checkdb = $sth_checkdb->fetch) {
					if ($checkdb->[0] > 1) {
						$ds=-1;
					} else {
						$ds=0;
					}
				}
			}
		}
		$doStatus = $dbh->do("UPDATE IDs set DBstatus=$ds where IDNo=$IDNo");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
	} else {
		;	
	}
	$now=&getnow;
	$sth_getrevs = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type=\'$type\' and (reviewers.revFunction='MDATA' or reviewers.revFunction='IMPL')");
	
	if ($inprog == 0) {
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
	}
	print "<p><strong>Facilities for site $site added to MMT for review</strong><p>\n";
	print "<strong>NOTIFICATION SENT TO SUBMITTER AND REVIEWERS</strong><p>\n";
	if ($inprog == 0) {
		&distribute($nuser_id,"$type",$IDNo,'entry');
	} else {
		&distribute($nuser_id,"$type",$IDNo,'update');
	}
	print "<hr />\n";
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "No, I'm done for now") {
	&bottomlinks($IDNo,"F");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
print "</form>\n";
&bottomlinks($IDNo,"F");
print "</div>\n";
print "</BODY></HTML>\n";
$dbh->disconnect();
exit;
