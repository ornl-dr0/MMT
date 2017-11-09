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
$pmtypedetailstab = &get_pmtypedetailstab; #user table
$meassubcatdetailstab = &get_meassubcatdetailstab; #user table
$pmcodetomeascatalllower = &get_pmcodetomeascatalllower; #user table
$pmcodetomeassubcatalllower = &get_pmcodetomeassubcatalllower; #user table
$meascatdetailstab = &get_meascatdetailstab; #user table

$remote_user=$ENV{'REMOTE_USER'};
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$procType=$in{procType};
$objcttype=$in{objcttype};
$submit = $in{submit};
$primary_meas_code=$in{primary_meas_code};
$primary_meas_name=$in{primary_meas_name};
$primary_meas_desc=$in{primary_meas_desc};
$meas_category_code=$in{meas_category_code};
############# on 5/25/2012, Rick asked me to remove the association of instclass to sourceclass from this object
#$instClass=$in{instClass};
#$sourceClass=$in{sourceClass};
$type='PMT';
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
print "<title>MMT: New Primary Measurement Type</title>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/arm_adv.css\"; --></style>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/fc.css\"; --></style>\n";
print "<style type=\"text/css\" media=\"all\">\n";
print "#content {margin-right:0;background-image: none;}\n";
print "</style>\n";
print "</head>\n";
print "<body class=\"iops\">\n";
print "<div id=\"content\">\n";
print "<form method=\"post\" action=\"PMT.pl\">\n";
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
&toplinks($user_id,$user_first,$user_last,"PMT");
print "<hr>\n";
if ($submit eq "Reset") {
	if ($in{primary_meas_code} ne"") {
		$primary_meas_code=$in{primary_meas_code};
		$procType=$in{procType};
	} else {
		$primary_meas_code="";
	}
	if ($procType eq "N") {
		$submit="BEGIN";
	} else {
		$submit="Select";
	}
}

if (($procType eq "") && ($submit eq "") && ($IDNo eq "")) {
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"N\"><strong>Enter New Primary Measurement Type?</strong><p>\n";
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"E\"><strong>Update Existing Primary Measurement Type?</strong><p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"BEGIN\">\n";
	print "</form>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"PMT");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "BEGIN") {
	if ($procType eq "N") {
		print "<strong>PRIMARY MEASUREMENT TYPE</strong> (<a href=\"metadataexamples.pl?mdtype=primmeascode\" target=\"primmeascodeex\">examples</a>) - max 16 chars: <INPUT TYPE=\"text\" name=\"primary_meas_code\" maxlength=16 size=20><p>\n";
		print "<strong>PRIMARY MEASUREMENT TYPE NAME</strong> (<a href=\"metadataexamples.pl?mdtype=primmeascode\" target=\"primmeascodeex\">examples</a>) - max 60 chars: <INPUT TYPE=\"text\" name=\"primary_meas_name\" maxlength=60 size=60><p>\n";
		print "<strong>PRIMARY MEASUREMENT TYPE DESCRIPTION</strong> (<a href=\"metadataexamples.pl?mdtype=primmeascode\" target=\"primmeascodeex\">examples</a>):<br /><textarea name=\"primary_meas_desc\" cols=100 rows=5></textarea><p>\n";
		print "<strong>Select the measurement category code(s)/subcategory code(s) below to which the new primary measurement type should belong:</strong><p>\n";
		print "<SELECT name=\"meas_category_code\" size=12 multiple>\n";
		$sth_getmeascat = $dbh->prepare("SELECT distinct meas_category_code,meas_category_name from $archivedb.$meascatdetailstab order by meas_category_code");
		if (!defined $sth_getmeascat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getmeascat->execute;
        	while ($getmeascat = $sth_getmeascat->fetch) {
			$countsubcat = 0;
			$subcat="";
			$subcatname="";
			$sth_getsubcat=$dbh->prepare("SELECT distinct meas_subcategory_code,meas_subcategory_name from $archivedb.$meassubcatdetailstab where meas_category_code='$getmeascat->[0]'");
			if (!defined $sth_getsubcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsubcat->execute;
        		while ($getsubcat = $sth_getsubcat->fetch) {
				$countsubcat = $countsubcat + 1;
				$subcat=$getsubcat->[0];
				$subcatname=$getsubcat->[1];
				if ($subcat ne "") {
					print "<OPTION value=\"$getmeascat->[0]:$subcat\">$getmeascat->[0]:$subcat ($getmeascat->[1]:$subcatname)</OPTION>\n";
				} else {
					print "<OPTION value=\"$getmeascat->[0]:null\">$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
				}
			}
			if ($countsubcat == 0) {
				print "<OPTION value=\"$getmeascat->[0]:null\">$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
			}
		}
		print "</SELECT><p>\n";
		#### on 5/25/2012 Rick wanted me to remove associating inst class and source class with pmt objects
		#print "<strong>Select at least one instrument class that this new primary measurement type should belong to:</strong><p>\n";
		$objcttype="entry";
		print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
		print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"PMT");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
	if ($procType eq "E") {
		print "<table>\n";
		print "<tr><td><strong>EXISTING PRIMARY MEASUREMENT TYPES</strong>:</td>\n";
		print " <td><SELECT name=\"primary_meas_code\" size=20>\n";
		$sth_getpmt = $dbh->prepare("SELECT distinct primary_meas_type_code,primary_meas_type_name from $archivedb.$pmtypedetailstab order by primary_meas_type_code");
		if (!defined $sth_getpmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getpmt->execute;
       	 	while ($getpmt = $sth_getpmt->fetch) {
			print "<OPTION value=\"$getpmt->[0]\">$getpmt->[0]: $getpmt->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr></table><p>\n";
		$objcttype="entry";
		print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
		print "<INPUT TYPE=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Select\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"PMT");
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
		$sth_checkinmmt = $dbh->prepare("SELECT count(*),count(*) from primMeas,IDs where IDs.IDNo=primMeas.IDNo and IDs.type='PMT' and primary_meas_code='$primary_meas_code'");
		if (!defined $sth_checkinmmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkinmmt->execute;
        	while ($checkinmmt = $sth_checkinmmt->fetch) {
			if ($checkinmmt->[0] > 0) {
				print "<strong><p>Sorry - this primary measurement type has already been submitted to the MMT for update/review.<p>Please go back to the mmt summary page to select it</strong><hr>\n";
				&bottomlinks($IDNo,"PMT");
				print "</div>\n";
				print "</BODY></HTML>\n";
				$dbh->disconnect();
				exit;
			}
		}		
		$sth_getpmt = $dbh->prepare("SELECT primary_meas_type_code,primary_meas_type_name,primary_meas_type_desc from $archivedb.$pmtypedetailstab WHERE primary_meas_type_code='$primary_meas_code'");
			
	} else {
		
		$procType="E";
		print "<INPUT TYPE=\"hidden\" name=\"IDNo\" value=\"$IDNo\">\n";
		$sth_getpmt = $dbh->prepare("SELECT primary_meas_code,primary_meas_name,primary_meas_desc from primMeas WHERE IDNo=$IDNo");
		
		if (!defined $sth_getpmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
	}
	$sth_getpmt->execute;
        while ($getpmt = $sth_getpmt->fetch) {
		$primary_meas_code=$getpmt->[0];
		$primary_meas_name=$getpmt->[1];
		$primary_meas_desc=$getpmt->[2];
	}
	print "<strong>PRIMARY MEASUREMENT TYPE</strong> (<a href=\"metadataexamples.pl?mdtype=primmeascode\" target=\"primmeascodeex\">examples</a>): <INPUT TYPE=\"text\" name=\"primary_meas_code\" value=\"$primary_meas_code\" maxlength=16 length=60><p>\n";
	print "<strong>PRIMARY MEASUREMENT TYPE NAME</strong> (<a href=\"metadataexamples.pl?mdtype=primmeascode\" target=\"primmeascodeex\">examples</a>): <INPUT TYPE=\"text\" name=\"primary_meas_name\" value=\"$primary_meas_name\" maxlength=60 size=60><p>\n";
	print "<strong>PRIMARY MEASUREMENT TYPE DESCRIPTION</strong> (<a href=\"metadataexamples.pl?mdtype=primmeascode\" target=\"primmeascodeex\">examples</a>):<br /><textarea name=\"primary_meas_desc\" cols=100 rows=5>$primary_meas_desc</textarea><p>\n";

	print "<table>\n";
	print "<th colspan=2><strong>MEASUREMENT CATEGORY:SUBCATEGORY CODES</strong></th>\n";
	print "<tr><td>Current Associations in ARM_int</td><td>Proposed Additions</td></tr>\n";	
	print "<tr><td><SELECT name=\"meas_category_code\" size=15 multiple>\n";
	$sth_getmeascat = $dbh->prepare("SELECT distinct meas_category_code,meas_category_name from $archivedb.$meascatdetailstab order by meas_category_code");
	if (!defined $sth_getmeascat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getmeascat->execute;
        while ($getmeascat = $sth_getmeascat->fetch) {
		$countsubcat = 0;
		$subcat="";
		$subcatname="";
		$sth_getsubcat = $dbh->prepare("SELECT distinct meas_subcategory_code,meas_subcategory_name from $archivedb.$meassubcatdetailstab where meas_category_code='$getmeascat->[0]'");
		if (!defined $sth_getsubcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsubcat->execute;
        	while ($getsubcat = $sth_getsubcat->fetch) {
			$countsubcat = $countsubcat + 1;
			$subcat=$getsubcat->[0];
			$subcatname=$getsubcat->[1];
			if ($subcat ne "") {
				$sth_checka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeascatalllower,$archivedb.$pmcodetomeassubcatalllower WHERE $archivedb.$pmcodetomeascatalllower.primary_meas_type_code='$primary_meas_code' and $archivedb.$pmcodetomeascatalllower.meas_category_code='$getmeascat->[0]' and $archivedb.$pmcodetomeassubcatalllower.meas_subcategory_code='$subcat' AND $archivedb.$pmcodetomeascatalllower.primary_meas_type_code=$archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code");
				if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checka->execute;
        			while ($checka = $sth_checka->fetch) {
					if ($checka->[0] != 0) {
						print "<OPTION value=\"$getmeascat->[0]:$subcat\" selected>$getmeascat->[0]:$subcat ($getmeascat->[1]:$subcatname)</OPTION>\n";
					} else {
						print "<OPTION value=\"$getmeascat->[0]:$subcat\">$getmeascat->[0]:$subcat ($getmeascat->[1]:$subcatname)</OPTION>\n";
					}
				}
			} else {
				$sth_checka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeascatalllower WHERE $archivedb.$pmcodetomeascatalllower.primary_meas_type_code='$primary_meas_code' and $archivedb.$pmcodetomeascatalllower.meas_category_code='$getmeascat->[0]'");
				if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checka->execute;
        			while ($checka = $sth_checka->fetch) {
					if ($checka->[0] != 0) {
						print "<OPTION value=\"$getmeascat->[0]:null\" selected>$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
					} else {
						print "<OPTION value=\"$getmeascat->[0]:null\">$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
					}
				}
			}
		}
		if (($countsubcat == 0) && ($subcat eq "")) {
			$sth_checka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeascatalllower WHERE $archivedb.$pmcodetomeascatalllower.primary_meas_type_code='$primary_meas_code' and $archivedb.$pmcodetomeascatalllower.meas_category_code='$getmeascat->[0]'");
			if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checka->execute;
        		while ($checka = $sth_checka->fetch) {
				if ($checka->[0] != 0) {
					print "<OPTION value=\"$getmeascat->[0]:null\" selected>$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
				} else {
					print "<OPTION value=\"$getmeascat->[0]:null\">$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
				}
			}
		}
	}
	print "</td>\n";
	print "</SELECT>\n";
	print "<td><SELECT name=\"meas_category_code\" size=15 multiple>\n";
	$sth_getmeascat = $dbh->prepare("SELECT distinct meas_category_code,meas_category_name from $archivedb.$meascatdetailstab order by meas_category_code");
	if (!defined $sth_getmeascat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getmeascat->execute;
        while ($getmeascat = $sth_getmeascat->fetch) {
		$countsubcat = 0;
		$subcat="";
		$subcatname="";
		$sth_getsubcat = $dbh->prepare("SELECT distinct meas_subcategory_code,meas_subcategory_name from $archivedb.$meassubcatdetailstab where meas_category_code='$getmeascat->[0]'");
		if (!defined $sth_getsubcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsubcat->execute;
        	while ($getsubcat = $sth_getsubcat->fetch) {
			$countsubcat = $countsubcat + 1;
			$subcat=$getsubcat->[0];
			$subcatname=$getsubcat->[1];
			if ($subcat eq "") {
				$nsubcat="null";
			} else {
				$nsubcat="'"."$subcat"."'";
			}
			if ($submit ne "Select") {
				$sth_getcurmeascat = $dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$IDNo and meas_category_code='$getmeascat->[0]' and meas_subcategory_code=$nsubcat and statusFlag=0");
				if (!defined $sth_getcurmeascat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getcurmeascat->execute;
        			while ($getcurmeascat = $sth_getcurmeascat->fetch) {
					if ($getcurmeascat->[0] == 0) {
						print "<OPTION value=\"$getmeascat->[0]:$subcat\">$getmeascat->[0]:$subcat ($getmeascat->[1]:$subcatname)</OPTION>\n";
					} else {
						print "<OPTION value=\"$getmeascat->[0]:$subcat\" selected>$getmeascat->[0]:$subcat ($getmeascat->[1]:$subcatname)</OPTION>\n";

					}
				}
			} else {
				print "<OPTION value=\"$getmeascat->[0]:$subcat\">$getmeascat->[0]:$subcat ($getmeascat->[1]:$subcatname)</OPTION>\n";
			}
				
		}
		if (($countsubcat == 0) && ($IDNo ne "")) {
			$sth_getcurmeascat = $dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$IDNo and meas_category_code='$getmeascat->[0]' and statusFlag=0");
			if (!defined $sth_getcurmeascat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getcurmeascat->execute;
        		while ($getcurmeascat = $sth_getcurmeascat->fetch) {
				if ($getcurmeascat->[0] == 0) {
					print "<OPTION value=\"$getmeascat->[0]:null\">$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
				} else {
					print "<OPTION value=\"$getmeascat->[0]:null\" selected>$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";

				}
			}
		}  elsif (($countsubcat == 0) && ($IDNo eq "")) {
			print "<OPTION value=\"$getmeascat->[0]:null\">$getmeascat->[0] ($getmeascat->[1])</OPTION>\n";
		}
	}
	print "</td>\n";
	print "</SELECT></tr>\n";
	print "</table>\n";	

####################################
	##### on /525/2012 Rick said we should not associate instrument class and source class with a pmt object- will do that elsewhere
	#print "<p>At least one instrument class must be selected below for this primary measurement type.<br />\n";
	#print "Instrument class(es) currently associated with the PMT are already pre-selected.<br />\n";
	#print "To make changes to the current archive list below, be sure to press the 'Ctrl' key.  If you do not,<br />\n";
	#print "existing selections will be de-selected!<br>\n";
	$objcttype="entry";
	print "<INPUT TYPE=\"hidden\" name=\"user_id\" value=\"$user_id\">\n";
	print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
	print "<input type=\"hidden\" name=\"objcttype\" value=\"$objcttype\">\n";
	print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
	print "</form>\n";
	&bottomlinks($IDNo,"PMT");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Submit") {
	$countmatch=0;
	# 5/25/2012 removed requirement for inst class and source class
	#if (($primary_meas_code eq "") || ($user_id eq "") || ($primary_meas_name eq "") || ($primary_meas_desc eq "") || ($instClass eq "") || ($sourceClass eq "") || ($meas_category_code eq "")) {
	#	print "Required information not entered (primary measurement code, name, description, measurement category(ies)/subcategories, instrument class(es) and source class(es)).  Go back and try again.<br>\n";
	if (($primary_meas_code eq "") || ($user_id eq "") || ($primary_meas_name eq "") || ($primary_meas_desc eq "") || ($meas_category_code eq "")) {
		print "Required information not entered (primary measurement code, name, description and measurement category(ies)/subcategories).  Go back and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}
	if ($procType eq "N") {
		$sth_checkit = $dbh->prepare("SELECT count(*),count(*) from primMeas where primary_meas_code='$primary_meas_code'");
		if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkit->execute;
        	while ($checkit = $sth_checkit->fetch) {
			$countmatch=$checkit->[0];
		}
		if ($countmatch == 0) {
			;
		} else {
			print "<strong>This primary measurement type has already been submitted to the MMT review process</strong><p>\n";
			$dbh->disconnect();
			exit;
		}
	}		
	if ($procType eq "E") {
		$sth_checkit = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmtypedetailstab  where primary_meas_type_code='$primary_meas_code'");
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
	if ($countmatch == 1) {
		$stat=1;
	}
	$REVstat=0;
	$newsubmission=0;
	if ($IDNo ne "") {
		$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from primMeas where IDNo=$IDNo");
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
		$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from primMeas where IDNo=$IDNo");
		if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getorigsubm->execute;
        	while ($getorigsubm = $sth_getorigsubm->fetch) {
			$nuser_id=$getorigsubm->[0];
		}
	}
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
		$sth_getIDNo = $dbh->prepare("SELECT IDNo,type,entry_date from IDs where type='$type' and DBstatus=$stat AND revStatus=$REVstat and entry_date='$now'");
		if (!defined $sth_getIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getIDNo->execute;
        	while ($getIDNo = $sth_getIDNo->fetch) {
			$IDNo=$getIDNo->[0];
		}
		$doStatus=$dbh->do("INSERT into primMeas values($IDNo,$nuser_id,'$primary_meas_code','$primary_meas_name','$primary_meas_desc',null,$stat,null)");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		@mcarray=();
		@mcarray=split(/\0/,$meas_category_code);
		$mmtmatch=0;
		$countinarchive=0;
		foreach $mc (@mcarray) {
			@temp=();
			@temp=split(/:/,$mc);
			$mcat=$temp[0];
			$mscat=$temp[1];
			$mmtmatch = $mmtmatch + 1;
			if ($mscat eq "null") {
				$sth_check3 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmtypedetailstab,$archivedb.$pmcodetomeascatalllower WHERE $archivedb.$pmtypedetailstab.primary_meas_type_code=$archivedb.$pmcodetomeascatalllower.primary_meas_type_code AND $archivedb.$pmtypedetailstab.primary_meas_type_code='$primary_meas_code' AND $archivedb.$pmcodetomeascatalllower.meas_category_code='$mcat'");
			} else {
				$sth_check3 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmtypedetailstab,$archivedb.$pmcodetomeascatalllower,$archivedb.$pmcodetomeassubcatalllower WHERE $archivedb.$pmtypedetailstab.primary_meas_type_code=$archivedb.$pmcodetomeascatalllower.primary_meas_type_code AND $archivedb.$pmtypedetailstab.primary_meas_type_code=$archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code AND $archivedb.$pmcodetomeascatalllower.primary_meas_type_code=$archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code AND $archivedb.$pmtypedetailstab.primary_meas_type_code='$primary_meas_code' AND $archivedb.$pmcodetomeascatalllower.meas_category_code='$mcat' AND $archivedb.$pmcodetomeassubcatalllower.meas_subcategory_code='$mscat'");
			}
			if (!defined $sth_check3) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_check3->execute;
        		while ($check3 = $sth_check3->fetch) {
				if ($mscat eq "null") {
					$newmscat="null";
				} else {
					$newmscat="\'"."$mscat"."\'";
				}
				if ($check3->[0] > 0) {
					$countinarchive=$countinarchive + 1;
					$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$nuser_id,'$mcat',$newmscat,1)");
					if ( ! defined $doStatus ) {
						print "<hr />\n";
						print "An error has occurred during insert. Please try again<br />\n";
						$dbh->disconnect();
						exit;
					}
				} else {
					$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$nuser_id,'$mcat',$newmscat,0)");
					if ( ! defined $doStatus ) {
						print "<hr />\n";
						print "An error has occurred during insert. Please try again<br />\n";
						$dbh->disconnect();
						exit;
					}
				}
			}
		}
		if ($countinarchive == $mmtmatch) {
			$doStatus = $dbh->do("UPDATE IDs set DBstatus=1 where IDNo=$IDNo");
			if ( ! defined $doStatus ) {
				print "<hr />\n";
				print "An error has occurred during update. Please try again<br />\n";
				$dbh->disconnect();
				exit;
			}
		} else {
			if ($countinarchive > 0) {
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 where IDNo=$IDNo");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during update. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			} 
		}
		$now=&getnow;
		$sth_getrevs = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='$type' AND (reviewers.revFunction='MDATA' or reviewers.revFunction='IMPL')");
		if (!defined $sth_getrevs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getrevs->execute;
        	while ($getrevs = $sth_getrevs->fetch) {
			$doStatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],0,\'$now\')");
			if ( ! defined $doStatus ) {
				print "<hr />\n";
				print "An error has occurred during insert. Please try again<br />\n";
				$dbh->disconnect();
				exit;
			}
		}
		if ($procType eq "N") {
			$objcttype='entry';
			print "<p><strong>PMT $primary_meas_code added to MMT for review</strong><p>\n";
		} else {
			$objcttype='update';
			print "<p><strong>PMT $primary_meas_code in MMT for review</strong><p>\n";
		}
		&distribute($nuser_id,"$type",$IDNo,"$objcttype");
		print "<hr />\n";
		&bottomlinks($IDNo,"PMT");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} else {
		$objcttype='update';
		@tmeasCatsArray=();
		@tmeasCatsArray=split(/\0/,$meas_category_code);
		@omeasCatsArray=();
		@omeasCatsArray=sort @tmeasCatsArray;
		@measCatsArray=();
		$omc="";
		$tc=0;
		foreach $omca (@omeasCatsArray) {
			if ($omca ne $omc) {
				$measCatsArray[$tc]=$omca;
				$tc = $tc + 1;
			}
			$omc = $omca;
		}

		if ($IDNo ne "") {
			$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from primMeas where IDNo=$IDNo");
			if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getorigsubm->execute;
        		while ($getorigsubm = $sth_getorigsubm->fetch) {
				$nuser_id=$getorigsubm->[0];
			}
		}
		$doStatus = $dbh->do("DELETE from measCats where IDNo=$IDNo");
		foreach $mc (@measCatsArray) {	
			@temp=();
			@temp=split(/\:/,$mc);
			$mcc=$temp[0];
			if ($temp[1] eq "null") {
				$mscc="null";
			} else {
				$mscc="'"."$temp[1]"."'";
			}
			if ($mscc eq "null") {
				$sth_check3 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeascatalllower WHERE $archivedb.$pmcodetomeascatalllower.primary_meas_type_code='$primary_meas_code' and $archivedb.$pmcodetomeascatalllower.meas_category_code='$mcc'");
			} else {
				$sth_check3 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeascatalllower,$archivedb.$pmcodetomeassubcatalllower WHERE $archivedb.$pmcodetomeascatalllower.primary_meas_type_code=$archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code AND $archivedb.$pmcodetomeascatalllower.primary_meas_type_code='$primary_meas_code' and $archivedb.$pmcodetomeascatalllower.meas_category_code='$mcc' AND $archivedb.$pmcodetomeassubcatalllower.meas_subcategory_code=$mscc");
			}
			if (!defined $sth_check3) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_check3->execute;
        		while ($check3 = $sth_check3->fetch) {	
				if ($check3->[0] > 0) {
					$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$nuser_id,'$mcc',$mscc,1)");					
				} else {	
					$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$nuser_id,'$mcc',$mscc,0)");
					# update IDs set DBstatus = -1
					$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 WHERE IDNo=$IDNo and DBstatus=1");
				}
			}
		}

		$doStatus = $dbh->do("UPDATE primMeas set primary_meas_code='$primary_meas_code',primary_meas_name='$primary_meas_name',primary_meas_desc='$primary_meas_desc' WHERE (IDNo=$IDNo or primary_meas_code='$primary_meas_code')");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during update. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		print "<p><strong>Primary Measurement Type $primary_meas_code in MMT for review</strong><p>\n";
		print "<hr />\n";
		&bottomlinks($IDNo,"PMT");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
}
$dbh->disconnect();
