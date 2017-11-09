#!/usr/bin/perl 

use CGI qw(:cgi-lib);
ReadParse();
$query=new CGI;
$query->charset('UTF-8');

use DBI;
use Time::Local;
use PGMMT_lib;
$VROOT=$ENV{'VROOT'};
$remote_user=$ENV{'REMOTE_USER'};
$dbname = &get_dbname;
$user = &get_user;
$password= &get_pwd;
$webserver = &get_webserver;
$peopletab = &get_peopletab;
$grouprole = &get_grouprole;
$archivedb = &get_archivedb;
$dbserver=&get_dbserver;
$siteinfotab = &get_siteinfotab; #user table
$facinfotab = &get_facsinfo; #user table
$dsinfotab = &get_dsinfotab; #user table
$sitetoinstrinfotab = &get_sitetoinstrinfotab; #user table
$instrclasstoinstrcattab = &get_instrclasstoinstrcattab; #user table
$instrcodedetailstab = &get_instrcodedetailstab; #user table
$instrclassdetailstab = &get_instrclassdetailstab; #user table
$instrclasstoinstrcattab = &get_instrclasstoinstrcattab; #user table
$dsvarnameinfotab = &get_dsvarnameinfotab; #user table
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$objcttype=$in{objcttype};
$submit = $in{submit};
$site=$in{site};
$facility=$in{facility};
$datastream=$in{datastream};
$user_id=$in{user_id};
$newsite=$in{newsite};
$newfacility=$in{newfacility};
$newinstcode=$in{newinstcode};
$newinstcodename=$in{newinstcodename};
$newdatalevel=$in{newdatalevel};
$type="CI";
#*******************************************************************************
# here is the access to the Postgresql MMT database
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
print "<title>MMT: Clone Request</title>\n";
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
print "<form enctype=\"multipart/form-data\" method=\"POST\" name=\"clone\" action=\"Clone.pl\">\n";
if ($remote_user ne "") {
	$sth_getuser=$dbh->prepare("SELECT person_id,name_first,name_last from $peopletab where upper(user_name)=upper('$remote_user')");
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
	&bottomlinks($id,"");
	exit;
}
# check access to this very powerful clone feature since no review is required!
# use MMT table powerusers
$countpu=0;
$sth_getpu=$dbh->prepare("SELECT person_id,person_id from PowerUsers where person_id=$user_id");
if (!defined $sth_getpu) { die "Cannot prepare statement: $DBI::errstr\n"; }
$sth_getpu->execute;
while ($getpu = $sth_getpu->fetch) {
	$countpu=1;
}
&toplinks($user_id,$user_first,$user_last,"CI");
######################
print "<hr>\n";
if ($countpu == 0) {
	print "<h3><strong>We are sorry. You are not authorized to use this feature currently. Please contact the MMT DB admin to request permission. Thank you.</strong></h3><p>\n";
	my $id="";
	&bottomlinks($id,"");
	exit;
}
if (($submit eq "Continue") || ($newsite ne "")) {
	print "<input type=\"hidden\" NAME=\"user_id\" VALUE=\"$user_id\">\n";
	print "<input type=\"hidden\" NAME=\"site\" VALUE=\"$site\">\n";
	print "<input type=\"hidden\" NAME=\"facility\" VALUE=\"$facility\">\n";
	@dsarray=();
	$dslist="";
	if ($datastream =~ '\|') {
		$dslist=$datastream;
			
	} else {
		@dsarray=();
		@dsarray=split(/\0/,$datastream);
		$countds=0;
		$dslist="";
		foreach $ds (@dsarray) {
			if ($countds == 0) {
				$dslist=$ds;
			} else {
				$dslist = "$dslist"."|"."$ds";
			}
			$countds = $countds + 1;
		}	
	}		
	print "<input type=\"hidden\" NAME=\"datastream\" VALUE=\"$dslist\">\n";
	print "<p><h2><strong><font color=red>NOTE: A CLONE REQUEST SHOULD ONLY BE SUBMITTED IF THERE IS A <u>COMPLETE/ACCURATE</u> SET OF METADATA AT THE ARCHIVE FOR THE CLONE SOURCE.<br>YOU WILL, HOWEVER, BE ALLOWED TO PROVIDE A NEW INSTRUMENT CODE FOR A SINGLE DATASTREAM YOU ARE CLONING IF NEEDED.</font></strong></h2><hr>\n";
	print "<p><strong><h1>CLONE SOURCE: $site:$facility</h1>\n";
	@dsarray=();
	@dsarray=split(/\|/,$dslist);
	$countds=0;
	foreach $ds (@dsarray) {
		if ($countds == 0) {
			print "$ds";
		} else {
			print ", $ds";
		}
		$countds = $countds + 1;
	}
	print "<hr>\n";
	print "<p><strong><h1>CLONE TO\n";			
	if (($newsite ne "") && ($newfacility ne "")) {
		print ": $newsite:$newfacility \n";
		print "<input type=\"hidden\" NAME=\"newsite\" VALUE=\"$newsite\">\n";
		print "<input type=\"hidden\" NAME=\"newfacility\" VALUE=\"$newfacility\">\n";
		if ($newinstcode ne "") {
			print "<br>NEW INST CODE: $newinstcode ($newinstcodename) \n";
			print "<input type=\"hidden\" NAME=\"newinstcode\" VALUE=\"$newinstcode\">\n";
			print "<input type=\"hidden\" NAME=\"newinstcodename\" VALUE=\"$newinstcodename\">\n";
		}
		if ($newdatalevel ne "") {
			print "<br>NEW DATA LEVEL: $newdatalevel \n";
			print "<input type=\"hidden\" NAME=\"newdatalevel\" VALUE=\"$newdatalevel\">\n";
		}
		print "</strong></h1>\n";
	} elsif (($newsite ne "") && ($newfacility eq "")) {
		print "<input type=\"hidden\" NAME=\"newsite\" VALUE=\"$newsite\">\n";
		print "</h1><b>Site:</b> \n";
		$sth_getnewsite=$dbh->prepare("SELECT distinct(upper(site_code)),site_name from $archivedb.$siteinfotab where upper(site_code)=upper('$newsite')");
		if (!defined $sth_getnewsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getnewsite->execute;
        	while ($getnewsite = $sth_getnewsite->fetch) {
			print "$getnewsite->[0]: $getnewsite->[1]<p>";
		}
		#get facility list from arm_int2 tables
		print "<strong><font color=red>Facility</font>:</strong> \n";
		print "<select name=\"newfacility\">\n";	
		print "<option value=\"\">Select a new facility...</option>\n";
		$sth_getfacs=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE upper($archivedb.$siteinfotab.site_code)=upper($archivedb.$facinfotab.site_code) and upper($archivedb.$siteinfotab.site_code)=upper('$newsite') order by $archivedb.$facinfotab.facility_code");
		if (!defined $sth_getfacs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getfacs->execute;
        	while ($getfacs = $sth_getfacs->fetch) {
			print "<OPTION value=\"$getfacs->[1]\">$getfacs->[1]</OPTION>\n";
		} 
		print "</select> \n";
		if ($countds == 1) {
			print "<p>OPTIONALLY<br><dd><strong>IF</strong> the instrument code part of the datastream is changing as well, please enter the new instrument code information below<br>\n";
			print "<dd>Instrument Code:<input type=\"text\" name=\"newinstcode\"> \n";
			print "<dd>Instrument Code Name: <input type=\"text\" name=\"newinstcodename\">\n";
			print "<dd><small>(<a href=\"metadataexamples.pl?mdtype=instrument_code\" target=\"instcex\">examples of instrument codes and names</a>)</small>\n";
		}
		print "</dd><p>\n";
		if ($countds == 1) {
			print "<p><dd>IF</strong> the data level part of the datastream is changing as well, please select the new data level below \n";
			print "<dd>Data Level:<select name=\"newdatalevel\"> \n";
			print "<option value=\"\">Select a data level...</option>\n";
			$sth_getdl=$dbh->prepare("SELECT distinct data_level_code,data_level_code from $archivedb.data_level_details order by data_level_code");
			if (!defined $sth_getdl) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getdl->execute;
        		while ($getdl = $sth_getdl->fetch) {
				print "<OPTION value=\"$getdl->[0]\">$getdl->[0]</OPTION>\n";
			}
			print "</select>\n";
			
		}
		print "</dd></p>\n";
		print "<INPUT TYPE=submit name=\"submit\" VALUE=\"Submit Clone Request\"> <font color=red><strong> PLEASE DOUBLE CHECK YOUR CLONE REQUEST BEFORE SUBMITTING. IT WILL GO UNREVIEWED DIRECTLY TO THE ARCHIVE FOR IMPLEMENTATION</font></strong>\n"; 
		print "</form>\n";
		print "<hr><p>\n";
		&bottomlinks($IDNo,"CI");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;					
	} elsif ($newsite eq "") {
		# get sites from arm_int2
		print "</h1><b>Site:</b> \n";
		print "<select name=\"newsite\" onChange=\"form.submit()\">\n";
		print "<option value=\"\">Select a site...</option>\n";
		$sth_getsite=$dbh->prepare("SELECT distinct(upper(site_code)),site_name from $archivedb.$siteinfotab order by site_code");
		if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsite->execute;
        	while ($getsite = $sth_getsite->fetch) {
                	print "<option value=\'$getsite->[0]\'>$getsite->[0]: $getsite->[1]</option>\n";
		}
                print "</select><p>\n";
                print "<hr><p>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"CI");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
}
if ($submit eq "Submit Clone Request") {
	$REVstat=2;  #no review of clone request - set reviewer status to approved automatically
	$stat=0;
	$now=&getnow;
	$objcttype="new";
	$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$type',$stat,$REVstat,'$now')");
	if ( ! defined $doStatus ) {
		print "<hr />\n";
		print "An error has occurred during ID insert. Please try again<br />\n";
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
	$nuser_id=$user_id;
	foreach $ds (@dsarray) {
		#parse out current instrument_code for ds here!  regex from Harold...2/1/2016
		$datastream=$ds;
		$datastream =~/([A-Z]?[a-z]{3})(.*)([A-Z]{1}\d+)\.((\d|[a-z]{1})\d)/;
   		$inst_code = $2;
    		$data_level = $4;
		if (($newinstcode ne "") && ($newinstcode ne "NULL")) {
			$newinstcode="'"."$newinstcode"."'";
		} else {
			$newinstcode="NULL";
		}
		if (($newinstcodename ne "") && ($newinstcodename ne "NULL")) {
			$newinstcodename="'"."$newinstcodename"."'";
		} else {
			$newinstcodename="NULL";
		}
		if (($newdatalevel ne "") && ($newdatalevel ne "NULL")) {
			$newdatalevel="'"."$newdatalevel"."'";
		} else {
			$newdatalevel="NULL";
		}
		#insert the clone into MMT
		$doStatus = $dbh->do("INSERT INTO clone values ($IDNo,$nuser_id,'$site','$facility','$newsite','$newfacility','$inst_code','$data_level',$stat,$newinstcode,$newinstcodename,$newdatalevel)");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
	}
	$now=&getnow;
	# get implementation members for clone object
	$sth_getrevs=$dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='$type' AND reviewers.revFunction='IMPL'");
	if (!defined $sth_getrevs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getrevs->execute;
        while ($getrevs = $sth_getrevs->fetch) {
		$doStatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],$REVstat,'$now')");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during insert. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
	}
	print "CLONE IMPLEMENTATION REQUEST sent to Archive (copy to submitter)<p>\n";
	&sendimplementation("$type",$IDNo,0);
	print "<hr />\n";
	&bottomlinks($IDNo,"CI");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if (($submit ne "Submit Clone Request") && ($submit ne "Continue")) {
	if (($site ne "") && ($facility ne "") && ($datastream eq "")) {
		print "<input type=\"hidden\" NAME=\"user_id\" VALUE=\"$user_id\">\n";
		print "<input type=\"hidden\" NAME=\"site\" VALUE=\"$site\">\n";
		print "<input type=\"hidden\" NAME=\"facility\" VALUE=\"$facility\">\n";
		print "<p><h2><strong><font color=red>NOTE: A CLONE REQUEST SHOULD ONLY BE SUBMITTED IF THERE IS A <u>COMPLETE/ACCURATE</u> SET OF METADATA AT THE ARCHIVE FOR THE CLONE SOURCE.<br>YOU WILL, HOWEVER, BE ALLOWED TO PROVIDE A NEW INSTRUMENT CODE FOR A SINGLE DATASTREAM YOU ARE CLONING IF NEEDED.</strong></font></h2><hr>\n";
		print "<p><strong><h1>CLONE SOURCE</h1></strong>\n";	
		print "<b>Site:</b> \n";
		$sth_getsite=$dbh->prepare("SELECT distinct(upper(site_code)),site_name from $archivedb.$siteinfotab where upper(site_code) = upper('$site')");
		if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsite->execute;
        	while ($getsite = $sth_getsite->fetch) {
			print "$getsite->[0]: $getsite->[1]<p>";
			$lsite=lc $site;
		}
		print "<b>Facility:</b> \n";
		$sth_getfac=$dbh->prepare("SELECT distinct(facility_code),facility_code from $archivedb.$facinfotab where facility_code='$facility'");
		if (!defined $sth_getfac) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getfac->execute;
        	while ($getfac = $sth_getfac->fetch) {
			print "$getfac->[0]<p>";
		}
		print "<td><strong>Select datastream(s) to clone (you may select more than one)</strong>:<br>\n";
		$countem=0;
		$sth_countds=$dbh->prepare("SELECT count(*),count(*) from $archivedb.datastream_instrument_class where upper(site)=upper('$site') and facility_code='$facility'");
		if (!defined $sth_countds) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_countds->execute;
        	while ($countds = $sth_countds->fetch) {
			$countem=$countds->[0];
		}
		$countthisone=0;
		if ($countem > 0) {
			$lsite=lc $site;
			$chkds=0;
			$countthisone=0;
			print " <SELECT name=\"datastream\" size=10 multiple>\n";
			$sth_getds=$dbh->prepare("SELECT distinct datastream,datastream from $archivedb.datastream_instrument_class where upper(site)=upper('$site') and facility_code='$facility' order by datastream");
			if (!defined $sth_getds) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getds->execute;
        		while ($getds = $sth_getds->fetch) {
				# from the datasteam_info table, lookup all datastreams for the site and facility selected
				# now see whether these are in measurement_description as well
				# first draft of clone tool will exclude a clone request if the datastream isnt in both tables 1/1/2016
				# next draft of clone tool will need to recognize any datastream from either table, and when compiling the clone request, use a combo of both tables
				# to develop appropriate inserts to the table that is missing information. Currently,though, we dont have enought in MD to make a full datastream_info record
				# and we dont have enough info in datastream_info to make a full measurement_description record
				# That will be future work!
				$sth_checkds=$dbh->prepare("SELECT count(*) from $archivedb.measurement_description WHERE datastream='$getds->[0]'");
				if (!defined $sth_checkds) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checkds->execute;
        			while ($checkds = $sth_checkds->fetch) {
					$chkds=$checkds->[0];
				}
				if ($chkds > 0) {
					$countthisone = $countthisone + 1;
					print "<OPTION value=\"$getds->[0]\">$getds->[0]</OPTION>\n";
				}
			}
			print "</SELECT><p>\n";
		}
		if ($countthisone == 0) {
			print "<p>NO DATASTREAMS FOUND IN BOTH datastream_instrument_class and measurement_description tables for the source you selected ($site/$facility) so it cannot be cloned.<p>\n";
		} else {
		
			print "<INPUT TYPE=submit name=\"submit\" VALUE=\"Continue\">\n"; 
		}
		print "<hr><p>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"CI");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;					
	} elsif (($site ne "") && ($facility eq "")) {
		print "<input type=\"hidden\" NAME=\"site\" VALUE=\"$site\">\n";
		print "<input type=\"hidden\" NAME=\"person_id\" VALUE=\"$user_id\">\n";
		print "<p><h2><strong><font color=red>NOTE: A CLONE REQUEST SHOULD ONLY BE SUBMITTED IF THERE IS A <u>COMPLETE/ACCURATE</u> SET OF METADATA AT THE ARCHIVE FOR THE CLONE SOURCE.<br>YOU WILL, HOWEVER, BE ALLOWED TO PROVIDE A NEW INSTRUMENT CODE FOR A SINGLE DATASTREAM YOU ARE CLONING IF NEEDED.</font></strong></h2><hr>\n";
		print "<p><strong><h1>CLONE SOURCE</h1></strong>\n";	
		print "<b>Site:</b> \n";
		$sth_getsite=$dbh->prepare("SELECT distinct(upper(site_code)),site_name from $archivedb.$siteinfotab where upper(site_code) = '$site'");
		if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsite->execute;
        	while ($getsite = $sth_getsite->fetch) {
			print "$getsite->[0]: $getsite->[1]<p>";
		}
		print "<strong>Facility:</strong> \n";
		print "<select name=\"facility\" onChange=\"form.submit()\">\n";	
		print "<option value=\"\">Select a facility...</option>\n";
		$sth_getfacs=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE upper($archivedb.$siteinfotab.site_code)=upper($archivedb.$facinfotab.site_code) and upper($archivedb.$siteinfotab.site_code)=upper('$site') order by $archivedb.$facinfotab.facility_code");
		if (!defined $sth_getfacs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getfacs->execute;
        	while ($getfacs = $sth_getfacs->fetch) {
			print "<OPTION value=\"$getfacs->[1]\">$getfacs->[1]</OPTION>\n";
		} 
		print "</select>\n";
                print "<hr><p>\n";
                print "</form>\n";
                &bottomlinks($IDNo,"CI");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;                      			
	} elsif ($site eq "") {
		print "<input type=\"hidden\" NAME=\"person_id\" VALUE=\"$user_id\">\n";
		print "<p><h2><strong><font color=red>NOTE: A CLONE REQUEST SHOULD ONLY BE SUBMITTED IF THERE IS A <u>COMPLETE/ACCURATE</u> SET OF METADATA AT THE ARCHIVE FOR THE CLONE SOURCE.<br>YOU WILL, HOWEVER, BE ALLOWED TO PROVIDE A NEW INSTRUMENT CODE FOR A SINGLE DATASTREAM YOU ARE CLONING IF NEEDED.</font></strong></h2><hr>\n";
		print "<p><strong><h1>CLONE SOURCE</h1></strong>\n";	
		print "<b>Site:</b> \n";
		print "<select name=\"site\" onChange=\"form.submit()\">\n";
		print "<option value=\"\">Select a site...</option>\n";
		$sth_getsite=$dbh->prepare("SELECT distinct(upper(site_code)),site_name from $archivedb.$siteinfotab order by site_code");
		if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsite->execute;
        	while ($getsite = $sth_getsite->fetch) {
                	print "<option value=\'$getsite->[0]\'>$getsite->[0]: $getsite->[1]</option>\n";
		}
                print "</select><p>\n";
                print "<hr><p>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"CI");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
}
$dbh->disconnect();
