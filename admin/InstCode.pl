#!/usr/bin/perl 

use CGI qw(:cgi-lib);
ReadParse();
$query=new CGI;
$query->charset('UTF-8');
use DBI;
use PGMMT_lib;
use Time::Local;
$VROOT=$ENV{'VROOT'};
$dbname = &get_dbname;
$user = &get_user;
$password= &get_pwd;
$dbserver = &get_dbserver;
$webserver = &get_webserver;
$peopletab = &get_peopletab;
$grouprole = &get_grouprole;
$archivedb = &get_archivedb;
$dbserver = &get_dbserver;
$instrcodedetailstab = &get_instrcodedetailstab; #user table
$instrclassdetailstab = &get_instrclassdetailstab; #user table
$instrcodetoinstrclass = &get_instrcodetoinstrclasstab; #user table

$remote_user=$ENV{'REMOTE_USER'};
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$procType=$in{procType};
$objcttype=$in{objcttype};
$submit = $in{submit};
$instClass=$in{instClass};
$instCode=$in{instCode};
$instCodeName=$in{instCodeName};
$user_id=$in{user_id};
$type="IC";
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
print "<title>MMT: Instrument Code Submission</title>\n";
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
print "<form method=\"post\" action=\"InstCode.pl\">\n";
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
	&bottomlinks($id,"IC");
	$dbh->disconnect();
	exit;
}
&toplinks($user_id,$user_first,$user_last,"IC");
######################
print "<hr>\n";

if ($submit eq "Reset") {
	if ($in{instCode} ne "") {
		$instCode=$in{instCode};
		$procType=$in{procType};		
	} else {
		$instCode = "";
	}
	if ($procType eq "N") {
		$submit="BEGIN";
	} else {
		$submit="Select";
	}
}
if (($procType eq "") && ($submit eq "") && ($IDNo eq "")) {
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"N\"><strong>Enter New Instrument Code?</strong><p>\n";
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"E\"><strong>Update Existing Instrument Code?</strong><p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"BEGIN\">\n";
	print "</form>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"IC");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "BEGIN") {
	if ($procType eq "N") {
		print "<strong>INSTRUMENT CODE</strong> (<a href=\"metadataexamples.pl?mdtype=instrument_code\" target=\"siteex\">examples</a>): <INPUT TYPE=\"text\" name=\"instCode\" maxlength=64 length=5><p>\n";
		print "<strong>INSTRUMENT CODE NAME</strong> (<a href=\"metadataexamples.pl?mdtype=instrument_code\" target=\"siteex\">examples</a>): <INPUT TYPE=\"text\" name=\"instCodeName\" maxlength=255 size=100><p>\n";
		print "<table>\n";
		print "<tr><td><strong>INSTRUMENT CLASS</strong>:</td>\n";
		print " <td><SELECT name=\"instClass\" size=20>\n";
		$sth_getinst=$dbh->prepare("SELECT distinct upper(instrument_class_code),instrument_class_name from $archivedb.$instrclassdetailstab order by instrument_class_code");
		if (!defined $sth_getinst) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinst->execute;
        	while ($getinst = $sth_getinst->fetch) {
			print "<OPTION value=\"$getinst->[0]\">$getinst->[0]: $getinst->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr></table><p>\n";	
		$objcttype="entry";
		print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
		print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"IC");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} elsif ($procType eq "E") {
		print "<table>\n";
		print "<tr><td><strong>EXISTING INSTRUMENT CODES</strong>:</td>\n";
		print " <td><SELECT name=\"instCode\" size=20>\n";
		$sth_getinstcode=$dbh->prepare("SELECT distinct lower(instrument_code),instrument_name from $archivedb.$instrcodedetailstab order by instrument_code,instrument_name");
		if (!defined $sth_getinstcode) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcode->execute;
        	while ($getinstcode = $sth_getinstcode->fetch) {
			print "<OPTION value=\"$getinstcode->[0]\">$getinstcode->[0]: $getinstcode->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr></table><p>\n";
		$objcttype="entry";
		print "<INPUT TYPE=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Select\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"IC");
		print "</div>\n";
		print "</BODY></HTML>\n";
		exit;
	} elsif ($procType eq "X") {
		print "<strong>ARCHIVE INSTRUMENT CLASSES</strong><p>\n";
		$countclasses=0;
		$sth_getinstclasses=$dbh->prepare("SELECT distinct upper(instrument_class_code) from $archivedb.$instrcodetoinstrclass order by instrument_class_code");
		if (!defined $sth_getinstclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstclasses->execute;
        	while ($getinstclasses= $sth_getinstclasses->fetch) {
        		if ($countclasses == 0) {      				
        			print "<SELECT name=\"instclasses\" multiple size=20> <OPTION value=\"$getinstclasses->[0]\">$getinstclasses->[0]</OPTION>\n";
        		} else {
        			print "<br><OPTION value=\"$getinstclasses->[0]\">$getinstclasses->[0]</OPTION>\n";
        		}
        		$countclasses = $countclasses + 1;
		}
		print "</SELECT><p>\n";
		print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
		print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Select Class(es)\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"IC");
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
if ($submit eq "Select Class(es)") {
	$tempclasslist="";
	@classlist=();
	$tempclasslist=$in{instclasses};
	@classlist=split(/\0/,$tempclasslist);
	
	print "<SELECT name=\"instclasscodepair\" multiple size=10>\n";
	foreach $cl (@classlist) {
		$sth_getinstcodes=$dbh->prepare("SELECT DISTINCT instrument_code from $archivedb.$instrcodetoinstrclass where lower('$cl')=lower(instrument_class_code) order by instrument_code");
		if (!defined $sth_getinstcodes) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcodes->execute;
        	while ($getinstcodes= $sth_getinstcodes->fetch) {
        		print "<OPTION value=\"$cl:$getinstcodes->[0]\">$cl: $getinstcodes->[0]</OPTION>\n";
        	}
        }
		print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
		print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Select Code(s)\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"IC");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
}
if ($submit eq "Select Code(s)") {
	print "DELETE INST CLASS/CODE ASSOCIATION HERE<br>\n";
	#$tempclasslist="";
	#@classlist=();
	#$tempclasslist=$in{instclasses};
	#@classlist=split(/\0/,$tempclasslist);
	
	#print "<SELECT name=\"instclasscodepair\" multiple size=10>\n";
	#foreach $cl (@classlist) {
		#print "SELECT DISTINCT instrument_code from $archivedb.$instrcodetoinstrclass where lower('$cl')=lower(instrument_class_code) order by instrument_code<br>\n";#
	#	$sth_getinstcodes=$dbh->prepare("SELECT DISTINCT instrument_code from $archivedb.$instrcodetoinstrclass where lower('$cl')=lower(instrument_class_code) order by instrument_code");
	#	if (!defined $sth_getinstcodes) { die "Cannot prepare statement: $DBI::errstr\n"; }
        #	$sth_getinstcodes->execute;
        #	while ($getinstcodes= $sth_getinstcodes->fetch) {
        #		print "<OPTION value=\"$cl:$getinstcodes->[0]\">$cl: $getinstcodes->[0]</OPTION>\n";
        #	}
       # }
	#	print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
		print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
	#	print " <input type=\"submit\" name=\"submit\" value=\"Select Code(s)\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"IC");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
}

if (($submit eq "Select") || (($IDNo ne "") && ($submit ne "Submit"))) {
	if ($IDNo eq "") {
		$sth_checkinmmt = $dbh->prepare("SELECT count(*) from instcodes,IDs where IDs.IDNo=instcodes.IDNo and IDs.type='IC' and instrument_code='$instCode'");
		if (!defined $sth_checkinmmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkinmmt->execute;
        	while ($checkinmmt = $sth_checkinmmt->fetch) {
			if ($checkinmmt->[0] > 0) {
				print "<strong><p>Sorry - this instrument code has already been submitted to the MMT for update/review.<p>Please go back to the mmt summary page to select it</strong><hr>\n";
				&bottomlinks($IDNo,"IC");
				print "</div>\n";
				print "</BODY></HTML>\n";
				$dbh->disconnect();
				exit;
			}
		}
		$sth_getcode = $dbh->prepare("SELECT distinct upper($archivedb.$instrclassdetailstab.instrument_class_code),$archivedb.$instrclassdetailstab.instrument_class_name,$archivedb.$instrcodedetailstab.instrument_code,$archivedb.$instrcodedetailstab.instrument_name from $archivedb.$instrclassdetailstab, $archivedb.$instrcodedetailstab, $archivedb.$instrcodetoinstrclass WHERE $archivedb.$instrcodetoinstrclass.instrument_class_code=$archivedb.$instrclassdetailstab.instrument_class_code and  $archivedb.$instrcodetoinstrclass.instrument_code=$archivedb.$instrcodedetailstab.instrument_code and  lower($archivedb.$instrcodetoinstrclass.instrument_code)='$instCode'");

	} else {
		$procType="E";
		print "<INPUT TYPE=\"hidden\" name=\"IDNo\" value=\"$IDNo\">\n";
		$sth_getcode = $dbh->prepare("SELECT lower(instrument_code),instrument_code_name,lower(instrument_class) from instCodes where IDNo=$IDNo");
		if (!defined $sth_getcode) { die "Cannot prepare statement: $DBI::errstr\n"; }
	}
        $sth_getcode->execute;
        while ($getcode = $sth_getcode->fetch) {
		$instCode=$getcode->[2];
		$instCodeName=$getcode->[3];
		$instClass=$getcode->[0];
		$instClassName=$getcode->[1];
	}
	
	
	print "<strong>INSTRUMENT CODE</strong>: $instCode<p>\n";
	print "<strong>INSTRUMENT CLASS</strong>:<br> \n";
	print "<SELECT name=\"instClass\" size=10>\n";
	$sth_getinst=$dbh->prepare("SELECT distinct upper(instrument_class_code),instrument_class_name from $archivedb.$instrclassdetailstab order by instrument_class_code");
	if (!defined $sth_getinst) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getinst->execute;
        while ($getinst = $sth_getinst->fetch) {
		if ($getinst->[0] eq $instClass) {
			print "<OPTION value=\"$getinst->[0]\" selected>$getinst->[0]: $getinst->[1]</OPTION>\n";
		} else {
			print "<OPTION value=\"$getinst->[0]\">$getinst->[0]: $getinst->[1]</OPTION>\n";
		}
	}
	print "</SELECT><p>\n";
	print "<strong>INSTRUMENT CODE NAME</strong> (<a href=\"metadataexamples.pl?mdtype=instrument_code\" target=\"icex\">examples</a>): <INPUT TYPE=\"text\" name=\"instCodeName\" value=\"$instCodeName\" maxlength=100 size=100><p>\n";
	print "<p>\n";
$objcttype="entry";
	print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
	print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
	print "<input type=\"hidden\" name=\"objcttype\" value=\"$objcttype\">\n";
	print "<input type=\"hidden\" name=\"instCode\" value=\"$instCode\">\n";
	print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
	print "</form>\n";
	&bottomlinks($IDNo,"IC");
	print "</div>\n";
	print "</BODY></HTML>\n";
	exit;
}
if ($submit eq "Submit") {
	$countmatch=0;
	
	if ($procTYpe =~ "N") {
		if (($user_id eq "") || ($instCode eq "") || ($instCodeName eq "") || ($instClass eq "")) {
			print "Required information not entered (instrument code, instrument code name, instrument class).  Go back and try again.<br>\n";
			$dbh->disconnect();
			exit;
		}
	}
	if ($procType =~ "N") {
		$sth_checkit=$dbh->prepare("SELECT count(*) from instCodes,IDs where instrument_code='$instCode' and instCodes.IDNo=IDs.IDNo and IDs.type='IC'");
		$sth_checkit->execute;
        	while ($checkit = $sth_checkit->fetch) {
			$countmatch=$checkit->[0];
		}
		if ($countmatch == 0) {	
			;
		} else {
			print "<strong>This instrument code has already been submitted to the MMT review process</strong><p>\n";
			print "<hr />\n";
			&bottomlinks($IDNo,"IC");
			print "</div>\n";
			print "</BODY></HTML>\n";
			$dbh->disconnect();
			exit;
		}
	}	
	if ($procType eq "E")  {	
		$sth_checkit=$dbh->prepare("SELECT count(*) from $archivedb.$instrcodedetailstab where instrument_code='$instCode'");
		if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkit->execute;
        	while ($checkit = $sth_checkit->fetch) {
			$countmatch=$checkit->[0];
		}
	}
	$stat=0;
	if ($countmatch == 0) {
		$stat=0;
	}
	if ($countmatch > 0) {
		$stat=1;
		
	}
	$REVstat=0;
	$newsubmission=0;
	$insertcode = 0;
	if ($IDNo ne "") {
		$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter from instCode where IDNo=$IDNo");
		if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getorigsubm->execute;
        	while ($getorigsubm = $sth_getorigsubm->fetch) {
			$nuser_id=$getorigsubm->[0];
		}
	}
	if ($IDNo ne "") {
		$doStatus=$dbh->do("UPDATE IDs set DBstatus=$stat where IDNo=$IDNo");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during update. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
	}
	$nuser_id=$user_id;
	if ($IDNo ne "") {
		$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from instCodes where IDNo=$IDNo");
		if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getorigsubm->execute;
        	while ($getorigsubm = $sth_getorigsubm->fetch) {
			$nuser_id=$getorigsubm->[0];
		}
	}
	if ($IDNo eq "") {
		$newsubmission=1;
		$now=&getnow;
		$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$type',$stat,$REVstat,'$now');");
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
		$doStatus=$dbh->do("INSERT into instCodes values ($IDNo,$nuser_id,'$instClass','$instCode','$instCodeName',$stat)");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}		
		
		$now=&getnow;
		$sth_getrevs = $dbh->prepare("SELECT distinct person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='$type' AND (reviewers.revFunction='MDATA' or reviewers.revFunction='IMPL' or reviewers.revFunction='IMPL-WEB')");
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
		
		
	} else {
		$objcttype='update';
		$exinst=0;
		
		$sth_checkinstc = $dbh->prepare("SELECT count(*) from instCodes where instrument_code='$instCode' and IDNo=$IDNo");
		
		if (!defined $sth_checkinstc) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkinstc->execute;
        	while ($checkinstc = $sth_checkinstc->fetch) {
			$exinst=$checkinstc->[0];
		}
		if ($exinst != 0) {
			@temp=();
			@temp=split(/\:/,$instClass);
			$instClass=$temp[0];
			$doStatus = $dbh->do("UPDATE instCodes set instrument_code='$instCode',instrument_class='$instClass',instrument_code_name='$instCodeName' WHERE IDNo=$IDNo");
		} else {
			$doStatus = $dbh->do("DELETE from instCodes where IDNo=$IDNo");
			$doStatus = $dbh->do("INSERT INTO instCodes values($IDNo,$nuser_id,'$instClass','$instCode','$instCodeName',0)");
			
		}
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during update. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		$now=&getnow;
		$sth_getrevs = $dbh->prepare("SELECT distinct person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='$type' AND (reviewers.revFunction='MDATA' or reviewers.revFunction='IMPL' or reviewers.revFunction='IMPL-WEB')");
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
	print "<p><strong>Instrument Code $instCode added to MMT for review</strong><p>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"IC");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
$dbh->disconnect();
