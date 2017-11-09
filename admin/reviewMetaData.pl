#!/usr/bin/perl 

use CGI qw(:cgi-lib);
ReadParse();
$query=new CGI;
$query->charset('UTF-8');
use JSON::XS;
use DBI;
use Time::Local;
use LWP;
use PGMMT_lib;
use HTTP::Request;
my $VROOT=$ENV{'VROOT'};
my $remote_user=$ENV{'REMOTE_USER'};
my $user = &get_user;
my $password= &get_pwd;
my $peopletab = &get_peopletab;
my $dbname = &get_dbname;
my $statustab = &get_statustab;
my $archivedb = &get_archivedb;
my $webserver=&get_webserver;
my $dbserver = &get_dbserver;
my $dsvarnamemeascatstab = &get_dsvarnamemeascatstab; #user table
my $dsinfotab = &get_dsinfotab; #user table
my $dsvarnameinfotab = &get_dsvarnameinfotab; #user table
my $sitetoinstrinfotab = &get_sitetoinstrinfotab; #user table
my $instrclasstoinstrcattab = &get_instrclasstoinstrcattab;#user_table
my $instrclassdetailstab = &get_instrclassdetailstab;#user table
my $pmcodetomeascatalllower = &get_pmcodetomeascatalllower; #user table
my $pmcodetomeassubcatalllower = &get_pmcodetomeassubcatalllower; #user table
my $meassubcatdetailstab = &get_meassubcatdetailstab; #user table

########################################
# get stuff from calling perl script
my $IDNo=$in{IDNo}; 
my $new_source_class=$in{new_source_class};
my $curr_source_class=$in{curr_source_class};
my $new_inst_cats=$in{new_inst_cats};
my $curr_inst_cats=$in{curr_inst_cats};
my $new_inst_class=$in{new_inst_class};
my $curr_inst_class=$in{curr_inst_class};
my $new_meas_cats=$in{new_meas_cats};
my $curr_meas_cats=$in{curr_meas_cats};
my $new_prim_measA=$in{new_prim_measA};
my $new_prim_measB=$in{new_prim_measB};
my $curr_prim_meas=$in{curr_prim_meas};
my $submit = $in{submit};
my $comment=$in{comments};
my $mcatfilt = $in{mcatfilt};
my $keeppms="";
$keeppms=$in{keeppms};
if ($keeppms eq "") {
	$keeppms=0;
}	
##################################################################
# here is the access to the MMT database
my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
my $userid = $user;
my $password=$password;
my $dbh = DBI->connect($dsn,$userid,$password, {'RaiseError'=> 1}) or die $DBI::errstr; 
my $name_first="";
my $name_last="";
my $firstName="";
my $lastName="";
##################################################################
# get user information and display it
if ($remote_user ne "") {
	my $sth_person = $dbh->prepare("SELECT person_id,name_first,name_last from people.people where upper(user_name)=upper('$remote_user')");
        if (!defined $sth_person) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_person->execute;
        while ($person = $sth_person->fetch) {
        	$user_id=$person->[0];
		$user_first=$person->[1];
		$user_last=$person->[2];
	}	
} else {
	print "You are not logged into the MMT: metadata system<p>\n";
	$dbh->disconnect();
	exit;
}
# prepare form page
print $query->header;
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n";
print "<head>\n";
print "<title>MMT: Review</title>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/fc.css\"; --></style>\n";
print "<style type=\"text/css\" media=\"all\">\n";
print "#tableContainer {width:100%; height:250px; overflow: scroll; padding: 0;}\n";
print "table { width: 100%; margin: 0; padding: 0;}\n";
print "table,th,td {border:1px solid black; cellspacing:10px;vertical-align:top;}\n";
print ".red { color: red;}\n";
print "</style>\n";
print "</head>\n";
print "<body class=\"iops\">\n";
print "<div id=\"content\">\n";
if ($IDNo eq "") {
	$dsBase=$in{dsBase};
	$dataLevel=$in{dataLevel};
	$DODver = $in{DODver};
	$sth_getid = $dbh->prepare("SELECT distinct IDNo,IDNo from DOD where dsBase='$dsBase' and dataLevel='$dataLevel' and DODversion='$DODver'");
	if (!defined $sth_getid) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getid->execute;
	while($getid = $sth_getid->fetch) {
		$IDNo=$getid->[0];
	}
	if ($IDNo eq "") {
		print "<p><strong><br>That MMT does not exist</strong><br>\n";
		print "</body>\n";
		print "</html>\n";
		$dbh->disconnect();
		exit;
	}
}
print "<form method=\"post\" action=\"reviewMetaData.pl\">\n";
print "<INPUT type=\"HIDDEN\" name=\"IDNo\" value=\"$IDNo\" />\n";
print "<p>\n";
##################################################################
$type="";
$sth_gettype = $dbh->prepare("SELECT IDNo,type from IDs where IDNo=$IDNo");
if (!defined $sth_gettype) { die "Cannot prepare statement: $DBI::errstr\n"; }
$sth_gettype->execute;
while ($gettype = $sth_gettype->fetch) {
	$type=$gettype->[1];
}	
# get the users reviewer function and display it
$funcDesc="";
$countfunc = 0;
$sth_getfunc=$dbh->prepare("SELECT person_id,reviewers.revFunction,revFuncLookup.revFuncDesc from reviewers,revFuncLookup where person_id=$user_id AND reviewers.revFunction=revFuncLookup.revFunction and reviewers.type='$type'");
if (!defined $sth_getfunc) { die "Cannot prepare statement: $DBI::errstr\n"; }
$sth_getfunc->execute;
while ($getfunc = $sth_getfunc->fetch) {
	if ($countfunc == 0) {
		$funcDesc=$getfunc->[1];
	} else {
		$funcDesc = "$funcDesc".", "."$getfunc->[1]";
	}
	$countfunc = $countfunc + 1;
}
if ($funcDesc eq "") {
	$funcDesc="Guest";
}
$now=&getnow;
################################################################
if ($type eq "") {
	print "<center><h3>MetaData Management Tool (MMT): Main Menu</h3></center>";
	### display menu
	print "<p><strong><h3>Select an object below to <strong>begin an ARM metadata assignment or review process:</h3></strong><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=S\">Site</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=F\">Facility</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=I\">Instrument Class</a></strong> <small>(define new/update existing)</small></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=CL\">Contacts</a></strong><small> (Inst./VAP/Datastream, etc.)</small></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=DOD\">Review a DOD</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=DS\">ARM Datastream</a></strong> <small>(cannot be fully completed until its DOD is approved)</small></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=CI\">Clone Datastreams from an Existing Site/Facility to Another</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=PMT\">Primary Measurement Type</a></strong></dd><p>\n";
	print "<hr>\n";
	print "</form>\n";
	print "<div class=\"spacer\"></div>\n";
	print "</div>\n";
	print "</body>\n";
	print "</html>\n";
	$dbh->disconnect();
	exit;
}
print "<center><h3><br>MetaData Management Tool (MMT): Assignment/Review</h3></center>";
print "<small>\n";
print "$user_first $user_last: $funcDesc Reviewer</small><hr />\n";

##################################################################
# Determine what type of object is being reviewed
if ($type eq "S") {
	$tabName="sites";
}
if ($type eq "F") {
	$tabName="facilities";
}
if ($type eq "I") {
	$tabName="instClass";
}
if ($type eq "PMT") {
	$tabName="primMeas";
}
if ($type eq "DS") {
	$tabName="DS";
}
if ($type eq "DOD") {
	$tabName="DOD";
}
if ($type eq "CL") {
	$tabName="instContacts";
}
if ($type eq "CI") {
	$tabName="clone";
}
if ($type eq "IC") {
	$tabName="instCodes";
}
###################################################################
# display the link/unlink DOD page
if ($submit eq "Link/Unlink DODs") {
	$thisbase="",
	$thislevel="";
	$thisvers="";
	$sth_getthisdod = $dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$IDNo");
	if (!defined $sth_getthisdod) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getthisdod->execute;
	while ($getthisdod = $sth_getthisdod->fetch) {
		$thisbase=$getthisdod->[0];
		$thislevel=$getthisdod->[1];
		$thisvers=$getthisdod->[2];
	}
	print "<hr>\n";
	print "<strong><p>If you are using this feature to <i><font color=blue>Link</font></i>, you will be adding a DOD link to this DOD.<p>If you are using this feature to <i><font color=blue>Unlink</font></i>, you will not be removing a DOD submitted for review, just the '<i>link</i>' that connects it to this DOD. \n";
	print "<hr />\n";
	print "<form method=\"POST\" action=\"reviewMetaData.pl\">";
	print "<large><strong><font color=blue><u>LINK</u></font></strong></large><p>\n";
	print "<strong>Link DOD $IDNo - $thisbase\.$thislevel (V$thisvers) to DOD </strong>\n";
	print "<select name=\"linkdod\">\n";
	print "<option value=\"\" selected>Select a DOD from the list</option>\n";
	$sth_getalldods=$dbh->prepare("SELECT distinct IDNo,IDNo from IDs where IDNo != $IDNo and IDs.type='DOD' order by IDNo desc");
	if (!defined $sth_getalldods) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getalldods->execute;
	while ($getalldods = $sth_getalldods->fetch) {
		$checkcount=0;
		$sth_getdods = $dbh->prepare("SELECT count(*),count(*) from linkedDODs where origIDNo=$IDNo and linkedIDNo=$getalldods->[0]");
		if (!defined $sth_getdods) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_getdods->execute;
		while ($getdods = $sth_getdods->fetch) {
			$checkcount = $getdods->[0];
		}
		if ($checkcount == 0) {
			$dodname="";
			$countdet = 0;
			$sth_getdetails = $dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$getalldods->[0]");
			if (!defined $sth_getdetails) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getdetails->execute;
			while ($getdetails = $sth_getdetails->fetch) {
				$dodname="$getdetails->[0]"."\."."$getdetails->[1]"." (V$getdetails->[2])";
			}
			print "<option value=\"$getalldods->[0]\">$getalldods->[0] - $dodname</option>\n";
		}
	}
	print "</select>";
	print "</td></tr></table>\n";
	print "<INPUT TYPE=\"checkbox\" name=\"copythem\" value=\"Y\"> Include comments?<br>\n";
	print "<p><INPUT TYPE=\"submit\" name=\"submit\" VALUE=\"Link it!\">\n";
	print "<hr>\n";
	print "<p><large><strong><font color=blue><u>UNLINK</u></font></strong></large><p>\n";
	print "<strong>Unlink the following DODs from DOD $IDNo - $thisbase\.$thislevel (V$thisvers) </strong>\n";
	print " <select name=\"unlinkdod\">\n";
	print "<option value=\"\" selected>Select a DOD from the list</option>\n";
	$sth_getdods=$dbh->prepare("SELECT distinct origIDNo,linkedIDNo from linkedDODs where origIDNo=$IDNo order by linkedIDNo desc");
	if (!defined $sth_getdods) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getdods->execute;
	while ($getdods = $sth_getdods->fetch) {
		$dodname="";
		$sth_getdetails = $dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$getdods->[1]");
		if (!defined $sth_getdetails) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$dodname="$getdetails->[0]"."\."."$getdetails->[1]"." (V$getdetails->[2])";
		}
		print "<option value=\"$getdods->[1]\">$getdods->[1] - $dodname</option>\n";
	}
	print "</select>";
	print "</td></tr></table>\n";
	print "<p><INPUT TYPE=\"submit\" name=\"submit\" VALUE=\"Unlink it!\">\n";
	print "</form><hr />\n";
	print "</body></html>\n";
	$dbh->disconnect();
	exit;
}
###################################################################
# display the copy comments page
if ($submit eq "Copy comments to a linked DOD") {
	$thisbase="",
	$thislevel="";
	$thisvers="";
	$sth_getthisdod = $dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$IDNo");
	if (!defined $sth_getthisdod) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getthisdod->execute;
	while ($getthisdod = $sth_getthisdod->fetch) {
		$thisbase=$getthisdod->[0];
		$thislevel=$getthisdod->[1];
		$thisvers=$getthisdod->[2];
	}
	print "<hr>\n";
	print "<form method=\"POST\" action=\"reviewMetaData.pl\">";
	print "<strong>Copy full comment history from DOD $IDNo - $thisbase\.$thislevel (V$thisvers) to:</strong><p>\n";
	print "<table><tr>\n";
	print "<td>DOD:</td><td><select name=\"todod\">\n";
	print "<option value=\"\" selected>Select a linked DOD from the list</option>\n";
	$sth_getalldods=$dbh->prepare("SELECT distinct linkedIDNo,linkedIDNo from linkedDODs where origIDNo = $IDNo order by linkedIDNo desc");
	if (!defined $sth_getalldods) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getalldods->execute;
	while ($getalldods = $sth_getalldods->fetch) {
		$dodname="";
		$countdet = 0;
		$sth_getdetails = $dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$getalldods->[0]");
		if (!defined $sth_getdetails) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$dodname="$getdetails->[0]"."\."."$getdetails->[1]"." (V$getdetails->[2])";
		}
		print "<option value=\"$getalldods->[0]\">$getalldods->[0] - $dodname</option>\n";
	}
	print "</select></td></tr></table>\n";
	print "<p><INPUT TYPE=\"submit\" name=\"submit\" VALUE=\"Copy!\">\n";
	print "</form><hr />\n";
	print "</body></html>\n";
	$dbh->disconnect();
	exit;
}
#####################################
#copy comments to a linked DOD
# no email distributed
if ($submit eq "Copy!") {
	if ($in{todod} ne "") {
		$todod=$in{todod};
	} else {
		$todod="";
	}
	if ($todod ne "") {
		$sth_getcomments = $dbh->prepare("SELECT IDNo,commentDate,person_id,comment from comments where IDNo=$IDNo and (comment not like 'DOD %are linked' and comment not like 'DOD %are no longer linked.' and comment not like 'Comments copied to DOD%')");
		if (!defined $sth_getcomments) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_getcomments->execute;
		while ($getcomments = $sth_getcomments->fetch) {
			$now=&getnow;
			$newcomment="";
			$commentcopy="";
			$commentcopy="Comment From DOD $IDNo: "."$getcomments->[3]";
			$_=$commentcopy;
			s/'/''/g;
			$newcomment=$_;
			$doStatus = $dbh->do("INSERT into comments values($todod,'$getcomments->[1]',$getcomments->[2],'$newcomment')");
			if ( ! defined $doStatus ) {
				print "<hr />\n";
				print "An error has occurred during insert. Please try again<br />\n";
				$dbh->disconnect();
				exit;
			}	

		}
	}
	$submit="";		
}


#####################################
# link a DOD
# no email is distributed 
if ($submit eq "Link it!") {
	if ($in{linkdod} ne "") {
		$linkdod=$in{linkdod};
	} else {
		$linkdod="";
	}
	if ($linkdod ne "") {
		$sth_countdups = $dbh->prepare("SELECT count(*),count(*) from linkedDODs where origIDNo=$IDNo and linkedIDNo=$linkdod");
		if (!defined $sth_countdups) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countdups->execute;
		while ($countdups = $sth_countdups->fetch) {
			$countd=$countdups->[0];
		}
		if ($countd == 0) {
			$now=&getnow;
			$doStatus = $dbh->do("INSERT into linkedDODs (origIDNo,linkedIDNo,entry_date,submitter_id) values ($IDNo,$linkdod,'$now',$user_id)");
			if ( ! defined $doStatus ) {
				print "<hr />\n";
				print "An error has occurred during insert - A. Please try again<br />\n";
				$dbh->disconnect();
				exit;
			}
		}
		$sth_countdups = $dbh->prepare("SELECT count(*),count(*) from linkedDODs where origIDNo=$linkdod and linkedIDNo=$IDNo");
		if (!defined $sth_countdups) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countdups->execute;
		while ($countdups = $sth_countdups->fetch) {
			$countd=$countdups->[0];
		}
		if ($countd == 0) {
			$now=&getnow;
			$doStatus = $dbh->do("INSERT into linkedDODs (origIDNo,linkedIDNo,entry_date,submitter_id) values ($linkdod,$IDNo,'$now',$user_id)");
			if ( ! defined $doStatus ) {
				print "<hr />\n";
				print "An error has occurred during insert - B. Please try again<br />\n";
				$dbh->disconnect();
				exit;
			}
		}
		if ($in{copythem} eq "Y") {
			$countc=0;
			$sth_getcomments = $dbh->prepare("SELECT IDNo,commentDate,person_id,comment from comments where IDNo=$IDNo and (comment not like 'DOD %are linked.' and comment not like 'DOD %are no longer linked.' and comment not like 'Comments copied to DOD%')");
			if (!defined $sth_getcomments) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getcomments->execute;
			while ($getcomments = $sth_getcomments->fetch) {
				$countc = $countc + 1;
				$newcomment="";
				$commentcopy="";
				$commentcopy="Comment From DOD $IDNo: "."$getcomments->[3]";
				$_=$commentcopy;
				s/'/''/g;
				$newcomment=$_;
				$doStatus = $dbh->do("INSERT into comments values($linkdod,'$getcomments->[1]',$getcomments->[2],'$newcomment')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert - E - $countc. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}	
		}
	}
	$submit="";		
}
#####################################
# unlink a DOD
# no email is distributed
if ($submit eq "Unlink it!") {
	if ($in{unlinkdod} ne "") {
		$unlinkdod=$in{unlinkdod};
	} else {
		$unlinkdod="";
	}
	if ($unlinkdod ne "") {
		$doStatus = $dbh->do("DELETE from comments WHERE IDNo=$unlinkdod AND comment like 'Comment From DOD $IDNo%'");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during delete - A. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		$doStatus = $dbh->do("DELETE from comments WHERE IDNo=$IDNo AND comment like 'Comment From DOD $unlinkdod%'");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during delete - B. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		$doStatus = $dbh->do("DELETE from linkedDODs WHERE origIDNo=$IDNo and linkedIDNo=$unlinkdod");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during delete - C. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		$doStatus = $dbh->do("DELETE from linkedDODs WHERE origIDNo=$unlinkdod and linkedIDNo=$IDNo");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during delete - D. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
	}
	$submit="";		
}

###################################################################
if ($submit eq "Update Status")  {
	### on 5/25/2012, Rick and I decided that archive implementation status column and setting and checking
	### will no longer be needed. I developed a standalone script that generates all sql needed to sync
	### arm_int2 with approved objects in the mmt db.  Archive will no longer have to acknowledge 
	### implementations completed in the mmt.
	### the standalone script can also generate a batch of sql for all necessary updates.  Then the archive
	### can run the batch.  This will also make it easier to switch to a diff method of implementation
	### of the sql through a web service or direct access later. We will also be able to run and rerun the script
	### anytime we need to.
	$now=&getnow;
	$newstat=$in{newstat};
	$doStatus = $dbh->do("INSERT into reviewerStatus values ($IDNo,$user_id,$newstat,'$now')");
	if ( ! defined $doStatus ) {
		print "An error has occurred updating your status. Please contact the database administrator\n";
		print "</form></body></html>\n";
		$dbh->disconnect();
		exit;
	}
	$mainREVStat="";
	$mainDBStat="";
	$sth_getoverallStat = $dbh->prepare("SELECT IDNo,revStatus,DBstatus from IDs where IDNo=$IDNo");
	if (!defined $sth_getoverallStat) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getoverallStat->execute;
	while ($getoverallStat = $sth_getoverallStat->fetch) {
		$mainREVStat=$getoverallStat->[1];
		$mainDBStat=$getoverallStat->[2];
	}
	# now need to evaluate the current individual reviewer status (all reviewers) and adjust MMT IDs 
	# table overall REV status
	# if needed and distribute email if overall status changes
	# get the review functions associated with this MMT object type
	@overallstat=();
	$countfuncs=0;
	$sth_getfuncs = $dbh->prepare("SELECT revFuncLookup.revFunction,revFuncNo from revFuncLookup,revFuncsByType WHERE revFuncLookup.revFunction=revFuncsByType.revFunction and (revFuncsByType.type='$type') order by revFuncNo");
	if (!defined $sth_getfuncs) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getfuncs->execute;
	while ($getfuncs = $sth_getfuncs->fetch) {
		$sth_getmaxrevdate=$dbh->prepare("SELECT max(statusDate),max(statusDate) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id and reviewerStatus.IDNo=$IDNo and reviewers.revFunction='$getfuncs->[0]' and (reviewers.type='$type')");
		if (!defined $sth_getmaxrevdate) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_getmaxrevdate->execute;
		while ($getmaxrevdate = $sth_getmaxrevdate->fetch) {
			$maxdate="\'"."$getmaxrevdate->[0]"."\'";
			$sth_getstat=$dbh->prepare("SELECT distinct status,reviewerStatus.person_id from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id and reviewerStatus.IDNo=$IDNo and reviewers.revFunction='$getfuncs->[0]' and (reviewers.type='$type') and statusDate=$maxdate and status=(SELECT max(status) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id and reviewerStatus.IDNo=$IDNo and reviewers.revFunction='$getfuncs->[0]' and reviewers.type='$type' and statusDate=$maxdate)");
			if (!defined $sth_getstat) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getstat->execute;
			while ($getstat = $sth_getstat->fetch) {
				$overallstat[$countfuncs]="$getfuncs->[0]"."|"."$getstat->[0]";
			}
			$countfuncs = $countfuncs + 1;	
		}
	}
	$ct=0;
	@tmp=();
	@farray=();
	@sarray=();
	foreach $oas (@overallstat) {
		@tmp=split(/\|/,$oas);
		$farray[$ct]=$tmp[0];
		$sarray[$ct]=$tmp[1];
		$ct = $ct + 1;	 
	}
	$ct=0;
	$countf=@farray;
	$fs0=0;
	$fs1=0;
	$fs2=0;
	$fs9999=0;
	foreach $f (@farray) {
		if ($sarray[$ct] == 0) {
			$fs0=$fs0 + 1;
		} elsif ($sarray[$ct] == 1) {
			$fs1 = $fs1 + 1;
		} elsif ($sarray[$ct] == 2) {
			$fs2 = $fs2 + 1;
		} elsif ($sarray[$ct] == 9999) {
			$fs9999 = $fs9999 + 1;
		} 
		$ct = $ct + 1;
	}
	$oldRstat="";
	$sth_chkold=$dbh->prepare("SELECT revStatus,revStatus from IDs where IDNo=$IDNo");
	if (!defined $sth_chkold) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_chkold->execute;
	while ($chkold = $sth_chkold->fetch) {
		$oldRstat=$chkold->[0];
	}
	$oldDBstat="";
	$sth_chkolddb=$dbh->prepare("SELECT DBstatus,DBstatus from IDs where IDNo=$IDNo");
	if (!defined $sth_chkolddb) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_chkolddb->execute;
	while ($chkolddb = $sth_chkolddb->fetch) {
		$oldDBstat=$chkolddb->[0];
	}
	$ctimpl=0;
	$sth_getimplcount = $dbh->prepare("SELECT count(*),count(*) from revFuncLookup,revFuncsByType WHERE revFuncLookup.revFunction=revFuncsByType.revFunction and revFuncsByType.type='$type' and revFuncLookup.revFunction like 'IMPL%'");
	if (!defined $sth_getimplcount) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getimplcount->execute;
	while ($getimplcount = $sth_getimplcount->fetch) {
		$ctimpl=$getimplcount->[0];
	}
	#is there implementor team(n/0,y/1): $ctimpl<br>\n";
	$countchk=0;
	$countchk = $countf-$ctimpl;
	if (($fs9999 > 0) && ($newstat == 9999)) {
		#someone marked this as abandoned/rejected! - set all status to 9999 - no turning back!\n";
		$doStatus = $dbh->do("UPDATE IDs set revStatus=9999,DBstatus=9999 where IDNo=$IDNo");		
		# also need to set all individual reviewer statuses to abandoned
		$now=&getnow;
		$sth_getfuncs = $dbh->prepare("SELECT distinct revFuncLookup.revFunction,revFuncNo from revFuncLookup,revFuncsByType WHERE revFuncLookup.revFunction=revFuncsByType.revFunction and revFuncsByType.type='$type'");
		if (!defined $sth_getfuncs) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_getfuncs->execute;
		while ($getfuncs = $sth_getfuncs->fetch) {
			$sth_getrevs =  $dbh->prepare("SELECT distinct reviewers.person_id,reviewers.person_id from reviewers WHERE revFunction='$getfuncs->[0]' and reviewers.type='$type'");
			if (!defined $sth_getrevs) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getrevs->execute;
			while ($getrevs = $sth_getrevs->fetch) {
				$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],9999,'$now')");		
			}
		}					
	} elsif (($fs2 == $countf) && (($oldRstat == 2) || ($oldRstat == 9999))) {
		$doStatus = $dbh->do("UPDATE IDs set revStatus=2 where IDNo=$IDNo");
		if ($oldDBstat != 2) {
			#overall reviewer status set to approved, db status to implemented\n";
			$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$IDNo");
		}		
	} elsif (($fs2 == $countchk) && ($fs2 != 0)) {
		if ($oldRstat != 2) {
			#overall reviewer status set to approved, but not implemented\n";
			$doStatus = $dbh->do("UPDATE IDs set revStatus=2 where IDNo=$IDNo");
			print "<strong>APPROVAL NOTIFICATION SENT</strong><p>\n";
			&distribute($user_id,"$type",$IDNo,'approval');
		}
		if ($oldDBstat > 1) {
			$doStatus = $dbh->do("UPDATE IDs set DBstatus=1 where IDNo=$IDNo");
		}		
	} else {
		if ($fs1 > 0) {
			if ($oldRstat != 1) {
				#overall reviewer status set to in progress\n";
				$doStatus = $dbh->do("UPDATE IDs set revStatus=1 where IDNo=$IDNo");
			}
			if (($fs0 != 1) && ($newstat !=2)) {
				print "<strong>IN PROGRESS NOTIFICATION SENT</strong><p>\n";	
				#print "user_id $user_id, type $type, IDNo $IDNo<br>\n";
				&distribute($user_id,"$type",$IDNo,'inprogress');
			}
			if ($oldDBstat > 1) {
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=1 where IDNo=$IDNo");
			}
			if ($oldRstat > 1) {
			# also need to set individual reviewer approved statuses back to inprogress
			# also need to set individual implementor appproved statuses back to pending
				$now=&getnow;
				$another=0;
				$sth_getfuncs = $dbh->prepare("SELECT distinct revFuncLookup.revFunction,revFuncNo from revFuncLookup,revFuncsByType WHERE revFuncLookup.revFunction=revFuncsByType.revFunction and revFuncsByType.type='$type'");
				if (!defined $sth_getfuncs) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_getfuncs->execute;
				while ($getfuncs = $sth_getfuncs->fetch) {
					$sth_getrevs =  $dbh->prepare("SELECT distinct reviewers.person_id,reviewers.person_id from reviewers WHERE revFunction='$getfuncs->[0]' and reviewers.type='$type'");
					if (!defined $sth_getrevs) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_getrevs->execute;
					while ($getrevs = $sth_getrevs->fetch) {
						if ($getrevs->[0] == $user_id) {
							$another = 1;
						}
						if ($getfuncs->[0] eq "IMPL") {
							$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],0,'$now')");
						} else {
							$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],1,'$now')");
						}		
					}
				}
				if ($another == 1) {
					sleep 1;
					$now=&getnow;
					if ($myfunc eq "IMPL") {
						$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$user_id,0,'$now')");
					} else {
						$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$user_id,1,'$now')");
					}
				}	
			}
		} elsif ($fs0 == $countf) {
			if ($oldRstat != 0) {
				# overall reviewer status set to pending - inactive!
				$doStatus = $dbh->do("UPDATE IDs set revStatus=0 where IDNo=$IDNo");
				print "<strong>ALL STATUS SET BACK TO INACTIVE! - no distribution</strong><p>\n";
			}
			if ($oldDBstat > 1) {
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=1 where IDNo=$IDNo");
			}
			if ($oldRstat > 0) {
				# also need to set individual reviewer approved statuses back to inactive
				# also need to set individual implementor appproved statuses back to pending
				$now=&getnow;
				$another=0;
				$sth_getfuncs = $dbh->prepare("SELECT distinct revFuncLookup.revFunction,revFuncNo from revFuncLookup,revFuncsByType WHERE revFuncLookup.revFunction=revFuncsByType.revFunction and revFuncsByType.type='$type'");
				if (!defined $sth_getfuncs) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_getfuncs->execute;
				while ($getfuncs = $sth_getfuncs->fetch) {
					$sth_getrevs =  $dbh->prepare("SELECT distinct reviewers.person_id,reviewers.person_id from reviewers WHERE revFunction='$getfuncs->[0]' and reviewers.type='$type'");
					if (!defined $sth_getrevs) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_getrevs->execute;
					while ($getrevs = $sth_getrevs->fetch) {
						if ($getrevs->[0] == $user_id) {
							$another=1;
						}
						if ($getfuncs->[0] eq "IMPL") {
							$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],0,'$now')");
						} else {
							$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$getrevs->[0],0,'$now')");
						}
					}
					if ($another == 1) {
						sleep 1;
						$now=&getnow;
						if ($myfunc eq "IMPL") {
							$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$user_id,0,'$now')");
						} else {
							$dostatus = $dbh->do("INSERT INTO reviewerStatus values($IDNo,$user_id,0,'$now')");
						}
					}
				}
			}
		} 
	}
	$mainREVStat="";
	$mainDBStat="";
	$sth_getoverallStat = $dbh->prepare("SELECT IDNo,revStatus,DBstatus from IDs where IDNo=$IDNo");
	if (!defined $sth_getoverallStat) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getoverallStat->execute;
	while ($getoverallStat = $sth_getoverallStat->fetch) {
		$mainREVStat=$getoverallStat->[1];
		$mainDBStat=$getoverallStat->[2];
	}
	# mainDBStat 0 - not in DB, submitted to MMT for review
	# mainDBStat 1 - in DB, submitted to MMT for updates/review
	# mainDBStat 2 - entries/updates to DB complete
	# mainDBStat -1 - partially in DB, submitted to MMT for updates/review
	# mainDBStat 9 - in MMT, waiting sync with DB
	# mainREVStat 0 - pending review - inactive
	# mainREVStat 1 - review in progress
	# mainREVStat 2 - approved, pending implementation/sync at archive
	# mainREVStat 3 - implemented - complete
	if (($mainREVStat == 2) && ($mainDBStat != 2) && ($mainREVStat != $oldRstat)) {
		if ($type ne "DOD") {
			print "<strong>IMPLEMENTATION REQUEST SENT (IF APPLICABLE).</strong><p>\n";
			&sendimplementation("$type",$IDNo,$mainDBStat);
		}
		if ($type eq "DOD") {	
			print "ARM Metadata experts will also begin additional metadata assignments in MMT assigning DOD primary variables to ARM primary measurement types now.<br>You are not required to participate in that assignment process but feel free to do so if you wish.<p>\n";
			##### here is where I will create the DS table record now that the DOD has been approved!
			##### Note: a DS record for the DOD can be created at anytime prior to DOD approval,
			##### and may have been! So, before creating a new DS table record, I will need to check
			##### that one has not already been started.  If not, create new, if it has, update that record
			##### with final DOD selections (in particular, use submitter of DOD for DS submitter, DSC description and inst class)
			$DSsubmitter="";
			$DSdsBase="";
			$DSdataLevel="";
			$DSdsBaseDesc="";
			$DSDODversion="";
			$DSiseval="";
			$DSdeaddate="";
			$sth_getdodinfo=$dbh->prepare("SELECT submitter,dsBase,dataLevel,dsBaseDesc,DODversion,iseval,deaddate from DOD where IDNo=$IDNo");
			if (!defined $sth_getdodinfo) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getdodinfo->execute;
			while ($getdodinfo = $sth_getdodinfo->fetch) {
				$DSsubmitter=$getdodinfo->[0];
				$DSdsBase=$getdodinfo->[1];
				$DSdataLevel=$getdodinfo->[2];
				$DSdsBaseDesc=$getdodinfo->[3];
				$DSDODversion=$getdodinfo->[4];
				$DSiseval=$getdodinfo->[5];
				$DSdeaddate=$getdodinfo->[6];
			}
			# need to enter a DS table entry now 
			$newDSdsBase="";
			$newDSdsBase="\'$DSdsBase\'";
			$newDSdsBaseDesc="";
			$newDSdsBaseDesc="\'$DSdsBaseDesc\'";
			$newDSdataLevel="";
			$newDSdataLevel="\'$DSdataLevel\'";
			$newDSDODversion="";
			$newDSDODversion="\'$DSDODversion\'";
			$REVstat=0;
			$DSexista=0;
			$DSexistb=0;
			$DSprocess="";
			$sth_checkarchive=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$dsinfotab where instrument_code='$DSdsBase' and data_level_code='$DSdataLevel'");
			if (!defined $sth_checkarchive) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_checkarchive->execute;
			while ($checkarchive = $sth_checkarchive->fetch) {
				$DSexista=$checkarchive->[0];
			}
			$sth_checkMMT = $dbh->prepare("SELECT count(*),count(*) from DS where dsBase='$DSdsBase' and dataLevel='$DSdataLevel' and DODversion='$DSDODversion'");
			if (!defined $sth_checkMMT) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_checkMMT->execute;
			while ($checkMMT = $sth_checkMMT->fetch) {
				$DSexistb=$checkMMT->[0];
			}
			if (($DSexista == 0) && ($DSexistb == 0)) {
				$DSprocess="Bn";
			} elsif (($DSexista  > 0) && ($DSexistb == 0)) {
				$DSprocess="Ma";
			} elsif (($DSexista == 0) && ($DSexistb > 0)) {
				$DSprocess="Mb";
			} elsif (($DSexista > 0) && ($DSexistb > 0)) {
				$DSprocess="Mba";
			}
			$DBstat=1;
			if ($DSprocess eq "Bn") {
				$DBstat=0;
			} 
			$DStype="DS";
			$now=&getnow;
			$newDS=0;
			if ($DSexistb == 0) {
				$newDS=1;
				$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$DStype',$DBstat,$REVstat,'$now')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
				# retrieve the IDNo which was created by insert above (identity field)
				$DSIDNo="";
				$sth_getDSIDNo=$dbh->prepare("SELECT IDNo,type,entry_date from IDs where type='$DStype' and DBstatus=$DBstat and revStatus=$REVstat and entry_date='$now'");
				if (!defined $sth_getDSIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_getDSIDNo->execute;
				while ($getDSIDNo = $sth_getDSIDNo->fetch) {
					$DSIDNo=$getDSIDNo->[0];
				}
				# Insert DS
				
				$doStatus = $dbh->do("INSERT INTO DS (IDNo,submitter,submitDate,dsBase,dataLevel,dsBaseDesc,statusFlag,DODversion) values ($DSIDNo,$DSsubmitter,'$now',$newDSdsBase,$newDSdataLevel,$newDSdsBaseDesc,$DBstat,$newDSDODversion)");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during entry (DS table). <br>\n";
					print "Please check your input and try again<br />\n";
					$dbh->disconnect();
					exit;
				}			
			} else {
				$sth_getDSID=$dbh->prepare("SELECT IDNo,dsBase,dataLevel from DS where dsBase='$DSdsBase' and dataLevel='$DSdataLevel' and DODversion='$DSDODversion'");
				if (!defined $sth_getDSID) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_getDSID->execute;
				while ($getDSID = $sth_getDSID->fetch) {
					$DSIDNo=$getDSID->[0];
				}
				# Update DS
				$doStatus = $dbh->do("UPDATE DS set submitter=$DSsubmitter,dsBaseDesc=$newDSdsBaseDesc,DODversion=$newDSDODversion where IDNo=$DSIDNo");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during update (DS table-dsBaseDesc). <br>\n";
					print "Please check your input and try again<br />\n";
					$dbh->disconnect();
					exit;
				}	
				
			}				
			# insert a review status record for all reviewers of DS 
			$revidarray=();
			$countr=0;
			$sth_getrid = $dbh->prepare("SELECT person_id,person_id from reviewers where type='$DStype' order by person_id");
			if (!defined $sth_getrid) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getrid->execute;
			while ($getrid = $sth_getrid->fetch) {
				$revidarray[$countr]=$getrid->[0];
				$countr = $countr + 1;
			}
			@sortedrevidarray=();
			@sortedrevidarray=sort @revidarray;
			$oldrid="";
			foreach $srevid (@sortedrevidarray) {
				if ($oldrid ne $srevid) {
					$doStatus = $dbh->do("INSERT into reviewerStatus (IDNo,person_id,status,statusDate) values ($DSIDNo,$srevid,0,'$now')");
					if ( ! defined $doStatus) {
						print "<hr />\n";
						print "An error has occurred during entry (reviewerStatus table). Please try again<br />\n";
						$dbh->disconnect();
						exit;
					}
					$oldrid=$srevid;
				}
			}
			$DSinstClass="";
			$DSinstClassName="";
			$DSicstat=1;
			$sth_getDODinstclass = $dbh->prepare("SELECT instrument_class,instrument_class_name,statusFlag from instClass where IDNo=$IDNo");
			if (!defined $sth_getDODinstclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getDODinstclass->execute;
			while ($getDODinstclass = $sth_getDODinstclass->fetch) {
				$DSinstClass=$getDODinstclass->[0];
				$DSinstClassName=$getDODinstclass->[1];
				$DSicstat = $getDODinstclass->[2];
			}
			if ($DSexistb != 0) {	
				$doStatus = $dbh->do("UPDATE instClass set submitter=$DSsubmitter,instrument_class='$DSinstClass',instrument_class_name='$DSinstClassName',statusFlag=$DSicstat WHERE IDNo=$DSIDNo");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during update to DS -instClass table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			} else {
				$doStatus = $dbh->do("INSERT INTO instClass (IDNo,submitter,instrument_class,instrument_class_name,statusFlag) values ($DSIDNo,$DSsubmitter,'$DSinstClass','$DSinstClassName',$DSicstat)");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert into instClass table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			$DSsourceClass=();
			$scct=0;
			$sth_getDODsourceclass = $dbh->prepare("SELECT source_class,source_class from sourceClass where IDNo=$IDNo");
			if (!defined $sth_getDODsourceclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getDODsourceclass->execute;
			while ($getDODsourceclass = $sth_getDODsourceclass->fetch) {
				$DSsourceClass[$scct]=$getDODsourceclass->[0];
				$scct = $scct + 1;
			}
			if ($DSexistb != 0) {
				$doStatus = $dbh->do("DELETE from sourceClass where IDNo=$DSIDNo");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during delete sourceClass table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}	
			}
			foreach $dssc (@DSsourceClass) {
				$doStatus = $dbh->do("INSERT INTO sourceClass (IDNo,submitter,source_class,statusFlag) values ($DSIDNo,$DSsubmitter,'$dssc',1)");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert into sourceClass table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			# for instrument categories, first delete existing, then insert new
			@DSinstCats=();
			$countcde=0;
			$sth_getDODic=$dbh->prepare("SELECT distinct instrument_category_code,instrument_category_code from $archivedb.$instrclasstoinstrcattab where instrument_class_code='$DSinstClass'");
			if (!defined $sth_getDODic) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getDODic->execute;
			while ($getDODic = $sth_getDODic->fetch) {
				$DSinstCats[$countcde]=$getDODic->[0];
				$countcde = $countcde + 1;
			}
			if ($DSexistb != 0) {
				##### first delete existing instCats for DS and overwrite with new ones identified in the corresponding DOD
				$doStatus = $dbh->do("DELETE from instCats where IDNo=$DSIDNo");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during delete of instCats for DS. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			foreach $dsic (@DSinstCats) {
				$doStatus = $dbh->do("INSERT INTO instCats (IDNo,submitter,inst_category_code,statusFlag) values ($DSIDNo,$DSsubmitter,'$dsic',1)");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert into instCats table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			###### below checks the archive for the DOD and looks to see if there are meas cats and pmts already assigned
			#  if there are any meascats or pmts in existance for this particular datastream at the archive gather them here
			@DSmeasCats=();
			@DScats=();
			@DSpmts=();
			$countmcde=0;
			$countpmt=0;
			$sth_getpmts=$dbh->prepare("SELECT distinct primary_meas_type_code,instrument_class_code,instrument_code FROM $archivedb.$dsvarnameinfotab dvi inner join $archivedb.$dsinfotab di on di.datastream=dvi.datastream WHERE instrument_class_code='$DSinstClass' AND instrument_code='$DSdsBase' AND di.datastream like '%$DSdsBase%$DSdataLevel'");
			if (!defined $sth_getpmts) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getpmts->execute;
			while ($getpmts = $sth_getpmts->fetch) {
				$DSpmts[$countpmt]=$getpmts->[0];
				$sth_getmeascat=$dbh->prepare("SELECT distinct meas_category_code,meas_subcategory_code FROM $archivedb.$dsvarnamemeascatstab dmc inner join $archivedb.$dsinfotab di on dmc.datastream=di.datastream inner join $archivedb.$dsvarnameinfotab dvi on dmc.datastream=dvi.datastream WHERE di.instrument_class_code='$DSinstClass' AND di.instrument_code='$DSdsBase' AND di.datastream like '%$DSdsBase%$DSdataLevel' AND dvi.primary_meas_type_code='$DSpmts[$countpmt]'");
				if (!defined $sth_getmeascat) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_getmeascat->execute;
				while ($getmeascat = $sth_getmeascat->fetch) {
					$DSsc="";
					if ($getmeascat->[1] eq "") {
						$DSsc="$getmeascat->[0]";
					} else {
						$DSsc="$getmeascat->[0]"."("."$getmeascat->[1]".")";
					}
					$DScats[$countmcde]="$DSsc";
					$countmcde=$countmcde+1;			
				}
				$countpmt = $countpmt + 1;
			}
			@sortedDScats=();
			@sortedDScats=sort @DScats;
			@DScats=();
			$chksc="";
			$csc=0;
			foreach $sortcat (@sortedDScats) {
				if ($sortcat ne "$chksc") {
					$DScats[$csc]=$sortcat;
					$csc = $csc + 1;
				}
				$chksc=$sortcat;
			}
			if ($DSexistb != 0) {
				#### WHAT SHOULD I DO IF THIS DS ALREADY HAS MEAS CATS ASSIGNED BECAUSE DS ASSIGNMENT BEGAN BEFORE FINAL 
				#### APPROVAL OF THE DOD?
				#### FOR NOW I WILL LEAVE THEM IN THE MMT
				;
			}
			foreach $c (@DScats) {
				$DSmc="";
				$DSmsc="";
				@breakit=();
				#insert a meascat/submeascat record
				@breakit=split(/\(/,$c);
				$DSmc=$breakit[0];
				$_=$breakit[1];
				s/\)//g;
				$DSmsc=$_;
				if ($DSmsc eq "") {
					$DSmsc="NULL";
				} else {
					$DSmsc="'"."$DSmsc"."'";
				}
				if ($DSmc ne "MEAS_CAT_CODES") {
					# first check if it exists already so not inserting a duplicate!
					$doesmcexist=0;
					$sth_chkmc = $dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$DSIDNo and meas_category_code='$DSmc' and meas_subcategory_code=$DSmsc");
					if (!defined $sth_chkmc) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_chkmc->execute;
					while ($chkmc = $sth_chkmc->fetch) {
						$doesmcexist=$chkmc->[0];
					}
					if ($doesmcexist == 0) {
						$doStatus = $dbh->do("INSERT INTO measCats (IDNo,submitter,meas_category_code,meas_subcategory_code,statusFlag) values ($DSIDNo,$DSsubmitter,'$DSmc',$DSmsc,1)");
						if ( ! defined $doStatus ) {
							print "<hr />\n";
							print "An error has occurred during insert into measCats table. Please try again<br />\n";
							$dbh->disconnect();
							exit;
						}
					}
				}
			}
			if ($DSexistb != 0) {
				#### WHAT SHOULD I DO IF THIS DS ALREADY HAS PMTs ASSIGNED BECAUSE DS ASSIGNMENT BEGAN BEFORE FINAL 
				#### APPROVAL OF THE DOD?
				#### FOR NOW I WILL LEAVE THEM IN THE MMT
				;
			}	
			foreach $p (@DSpmts) {
				$DSthispmt=$p;
				#insert a pmt record
				#foreach pmt record, get all pms and insert records for each
				$sth_getpm=$dbh->prepare("SELECT DISTINCT primary_measurement,primary_meas_type_code,var_name FROM $archivedb.$dsvarnameinfotab WHERE primary_meas_type_code='$DSthispmt' AND $archivedb.$dsvarnameinfotab.datastream IN (SELECT distinct $archivedb.$dsinfotab.datastream FROM $archivedb.$dsinfotab WHERE instrument_class_code ='$DSinstClass' AND instrument_code='$DSdsBase')");
				if (!defined $sth_getpm) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_getpm->execute;
				while ($getpm = $sth_getpm->fetch) {
					$chkpmexist=0;
					$sth_chckpmt=$dbh->prepare("SELECT count(*),count(*) from primMeas where IDNo=$DSIDNo and primary_meas_code='$DSthispmt' and primary_measurement='$getpm->[0]' and var_name='$getpm->[2]'");
					if (!defined $sth_chckpmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_chckpmt->execute;
					while ($chckpmt = $sth_chckpmt->fetch) {
						$chkpmexist=$chckpmt->[0];
					}
					if ($chkpmexist == 0) {
						$doStatus = $dbh->do("INSERT INTO primMeas (IDNo,submitter,primary_meas_code,statusFlag,primary_measurement,var_name) values ($DSIDNo,$DSsubmitter,'$DSthispmt',1,'$getpm->[0]','$getpm->[2]')");
						if ( ! defined $doStatus ) {
							print "<hr />\n";
							print "An error has occurred during insert into primMeas table. Please try again<br />\n";
							$dbh->disconnect();
							exit;
						}
					}
				}
			}
			####### insert a comment if this particular DOD version was submitted as an evaluation product and if there is any deadline (eval or prod!)
			if ($DSiseval =~ 'Y') {
				#enter a comment into DS record saying this DOD version was submitted indicating it is an Evaluation product
				$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentdate,person_id,comment) values ($DSIDNo,'$now',12,'This DOD version was (re)submitted as an Evaluation Product. Please make sure the appropriate source class is included to associate with the instrument class selected.')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert into comments table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			if ($DSiseval =~ 'N') {
				#enter a comment into DS record saying this DOD version was submitted indicating it is a Production product
				
				$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentdate,person_id,comment) values ($DSIDNo,'$now',12,'This DOD version was (re)submitted as a Production Product. Please make sure the appropriate source class is included to associate with the instrument class selected')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert into comments table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			if ($DSdeaddate ne "") {
				#enter a comment into DS recording indicating there is a deadline for review
				$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentdate,person_id,comment) values ($DSIDNo,'$now',$DSsubmitter,'There is a deadline for review of $DSdeaddate as requested by the DOD submitter')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert into comments table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			#################################################
			# need to work towards using distribute function to handle mailing and remove mailing section below
			#&distribute("$user_id","$type",$IDNo,"$objcttype");
			@DSemailarray=();
			$emailcount=0;
			# commented out section here where the DOD submitter will also get a copy of DS entry - not necessary I think 
			#@getsub = $dbh->prepare("SELECT person_id,name_first,name_last,email from $peopletab where person_id=$user_id");
			#foreach $getsub (@getsub) {
			#	$DSemailarray[$emailcount]=$getsub->[3];
			#	$emailcount = $emailcount + 1;
			#}
			$countmdg=0;
			$sth_getrevmd = $dbh->prepare("SELECT distinct reviewers.person_id,$peopletab.name_first,$peopletab.name_last,$peopletab.email from reviewers,$peopletab where reviewers.person_id=$peopletab.person_id and reviewers.revFunction='MDATA' and type='DS'");
			if (!defined $sth_getrevmd) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getrevmd->execute;
			while ($getrevmd = $sth_getrevmd->fetch) {
				$DSemailarray[$emailcount]=$getrevmd->[3];
				$emailcount = $emailcount + 1;
			}
			@DSsortedemail = sort @DSemailarray;
			$oldem = "";
			$typedesc="";
			$sth_gettypedesc=$dbh->prepare("SELECT typeID,type_name from type where typeID='DS'");
			if (!defined $sth_gettypedesc) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_gettypedesc->execute;
			while ($gettypedesc = $sth_gettypedesc->fetch) {
				$typedesc=$gettypedesc->[1];
			}	
			foreach $em (@DSsortedemail) {
				if ($em ne $oldem) {
					if ($newDS == 0 ) {
						$thissubj="UPDATE";
					} else {
						$thissubj="ENTRY";
					}
					open(MAIL,"|/home/www/DB/lib/dbmail -r \"webformadmin\@arm.gov\" -s \"MMT: $typedesc $thissubj ($DSdsBase\.$DSdataLevel) - MMT# $DSIDNo\" \"$em\"");
					$DSuser_first="";
					$DSuser_last="";
					$sth_getsubm=$dbh->prepare("SELECT name_first,name_last from $peopletab where person_id=$DSsubmitter");
					if (!defined $sth_getsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_getsubm->execute;
					while ($getsubm = $sth_getsubm->fetch) {
						$DSuser_first=$getsubm->[0];
						$DSuser_last=$getsubm->[1];
					}
					if ($newDS == 1) {
						print MAIL "Datastream Entry created automatically upon approval of DOD\n\n";
					} else {
						print MAIL "Datastream Entry updated to reflect approved DOD\n\n";
					}
					print MAIL "DOD Submitter: $DSuser_first $DSuser_last\n";
					print MAIL "\n";
					print MAIL "Datastream Class: $DSdsBase\.$DSdataLevel\n";
					print MAIL "DataStream Class Description: $DSdsBaseDesc\n\n";
					print MAIL "http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$DSIDNo\n";
					close(MAIL);
				}
				$oldem = $em;	
			}
			##################		
		} 
	} else {
		;
	}
}
#################################################################################
if ($type eq "DS") {
	if ($submit eq "ADD selected available associations from ARCHIVE DB") {
		$commenttrigger=0;
		@commenttype=();
		if ($new_inst_class ne "") {
			$sth_checkinsts=$dbh->prepare("SELECT count(*),count(*) from instClass where IDNo=$IDNo");
			if (!defined $sth_checkinsts) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_checkinsts->execute;
			while ($checkinsts = $sth_checkinsts->fetch) {
				$checkcount=$checkinsts->[0];
			}
			if ($checkcount == 0) {
				@newinsts=();
				@newinsts=split(/\0/,$new_inst_class);
				foreach $i (@newinsts) {
					$duplicate=0;
					$sth_checkdups=$dbh->prepare("SELECT count(*),count(*) from instClass where IDNo=$IDNo and instrument_class='$i'");
					if (!defined $sth_checkdups) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_checkdups->execute;
					while ($checkdups = $sth_checkdups->fetch) {
						$duplicate=$checkdups->[0];
					}
					$inarch=0;
					$sth_checkarchive = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclassdetailstab where instrument_class_code='$i'");
					if (!defined $sth_checkarchive) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_checkarchive->execute;
					while ($checkarchive = $sth_checkarchive->fetch) {
						$inarch = $checkarchive->[0];
					}
					if ($duplicate == 0) {
						if ($inarch > 0) {
							$icname="";
							$sth_getinstname = $dbh->prepare("SELECT distinct instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab WHERE instrument_class_code='$i'");
							if (!defined $sth_getinstname) { die "Cannot prepare statement: $DBI::errstr\n"; }
							$sth_getinstname->execute;
							while ($getinstname = $sth_getinstname->fetch) {
								$icname=$getinstname->[1];
							}
							$doStatus = $dbh->do("INSERT INTO instClass values($IDNo,$user_id,'$i','$icname',1)");
							$commenttype[$commenttrigger]="Inst Class $i added";
							$commenttrigger=$commenttrigger+1;
							
						} else {
							$icname="";
							$sth_getinstname = $dbh->prepare("SELECT distinct instrument_class,instrument_class_name from instClass where instrument_class='$i'");
							if (!defined $sth_getinstname) { die "Cannot prepare statement: $DBI::errstr\n"; }
							$sth_getinstname->execute;
							while ($getinstname = $sth_getinstname->fetch) {
								$icname=$getinstname->[1];
							}
							$doStatus = $dbh->do("INSERT INTO instClass values($IDNo,$user_id,'$i','$icname',0)");
							
							$commenttype[$commenttrigger]="Inst Class $i added";
							$commenttrigger=$commenttrigger+1;
							
						}
					}
					$oistc="";
					$existscat=0;
					$sth_getinstcodes=$dbh->prepare("SELECT distinct instrument_category_code,instrument_category_code from $archivedb.$instrclasstoinstrcattab where instrument_class_code='$i'");
					if (!defined $sth_getinstcodes) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_getinstcodes->execute;
					while ($getinstcodes = $sth_getinstcodes->fetch) {
						$counti=0;
						$existscat = $existscat + 1;
						$sth_checkdb=$dbh->prepare("SELECT count(*),count(*) from instCats where inst_category_code='$getinstcodes->[0]' and IDNo=$IDNo");
						if (!defined $sth_checkdb) { die "Cannot prepare statement: $DBI::errstr\n"; }
						$sth_checkdb->execute;
						while ($checkdb = $sth_checkdb->fetch) {
							$counti=$checkdb->[0];
						}
						if ($counti == 0) {
							$doStatus = $dbh->do("INSERT INTO instCats values($IDNo,$user_id,'$getinstcodes->[0]',1)");
						}
						$oistc=$getinstcodes->[0];
					}
					if ($existscat == 0) {
						if ($inarch > 0) {
							print "THERE ARE NO INSTRUMENT CATEGORIES ASSOCIATED WITH THIS EXISTING INSTRUMENT CLASS. - Contact ARCHIVE DB ADMINS - METADATA ERROR IN ARM_INT!<br />\n";
						} else {
							$newidnum="";
							$sth_getid=$dbh->prepare("SELECT IDs.IDNo,instrument_class from IDs,instClass where instrument_class='$i' and IDs.IDNo=instClass.IDNo and IDs.type='I'");
							if (!defined $sth_getid) { die "Cannot prepare statement: $DBI::errstr\n"; }
							$sth_getid->execute;
							while ($getid = $sth_getid->fetch) {
								$newidnum=$getid->[0];
							}
							$sth_getinstcat = $dbh->prepare("SELECT distinct inst_category_code,inst_category_code from instCats,instClass where instCats.IDNo=instClass.IDNo and instClass.instrument_class='$i' and instClass.IDNo=$newidnum");
							$icodename="";
							if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
							$sth_getinstcat->execute;
							while ($getinstcat = $sth_getinstcat->fetch) {
								$icodename=$getinstcat->[0];
								$doStatus = $dbh->do("INSERT INTO instCats values($IDNo,$user_id,'$getinstcat->[0]',1)");
							}
						}
					}
				}
			} else {
				print "Cannot add more than one instrument class per DS Class/data_level.<br />\n";
			}
		}
		if ($new_source_class ne "") {
			@newsources=();
			@newsources=split(/\0/,$new_source_class);
			foreach $s (@newsources) {
				$duplicate=0;
				$sth_checkdups=$dbh->prepare("SELECT count(*),count(*) from sourceClass where IDNo=$IDNo and source_class='$s'");
				if (!defined $sth_checkdups) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_checkdups->execute;
				while ($checkdups = $sth_checkdups->fetch) {
					$duplicate=$checkdups->[0];
				}
				if ($duplicate == 0) {
					$doStatus = $dbh->do("INSERT INTO sourceClass values($IDNo,$user_id,'$s',1)");
					
					$commenttype[$commenttrigger]="Source Class $s added";
					$commenttrigger=$commenttrigger+1;
				}
			}
		}
		if (($new_prim_measA ne "") && ($new_prim_measB ne "")) {
			@newprimmeasA=();
			@newprimmeasA=split(/\0/,$new_prim_measA);
			$newprimmeasB=$new_prim_measB;
			foreach $pm (@newprimmeasA) {
				@splitem=();
				@splitem=split(/\|/,$pm);
				$duplicate=0;
				$sth_checkdups=$dbh->prepare("SELECT count(*),count(*) from primMeas where IDNo=$IDNo and primary_measurement='$splitem[1]' and var_name='$splitem[0]' and primary_meas_code='$newprimmeasB'");
				if (!defined $sth_checkdups) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_checkdups->execute;
				while ($checkdups = $sth_checkdups->fetch) {
					$duplicate=$checkdups->[0];
				}
				if ($duplicate == 0) {
					$thisstatflag=1;
					$thispmn="null";
					$thispmd="null";
					$sth_getstatflag=$dbh->prepare("SELECT primary_meas_code,primary_meas_name,primary_meas_desc,statusFlag from primMeas where primary_meas_code='$newprimmeasB'");
					if (!defined $sth_getstatflag) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_getstatflag->execute;
					while ($getstatflag = $sth_getstatflag->fetch) {
						$thisstatflag=$getstatflag->[3];
						if ($getstatflag->[1] ne "") {
							$thispmn="\'"."$getstatflag->[1]"."\'";
						} else {
							$thispmn="null";
						}
						if ($getstatflag->[2] ne "") {
							$tdesc="";
							$_=$getstatflag->[2];
							s/'/''/g;
							$tdesc=$_;
							$thispmd="\'"."$tdesc"."\'";
						} else {
							$thispmd="null";
						}
					}
					if ($thisstatflag == 1) {
						$doStatus = $dbh->do("INSERT INTO primMeas values($IDNo,$user_id,'$newprimmeasB',null,null,'$splitem[1]',$thisstatflag,'$splitem[0]')");
					} else {
						$doStatus = $dbh->do("INSERT INTO primMeas values($IDNo,$user_id,'$newprimmeasB',$thispmn,$thispmd,'$splitem[1]',$thisstatflag,'$splitem[0]')");
					}
					
					$commenttype[$commenttrigger]="$newprimmeasB:$splitem[0]:$splitem[1] added";
					$commenttrigger=$commenttrigger+1;
				}
				$countmc=0;
				$omcc="";
				$smcc="";
				$mcsc="";
				$sth_sortedmcc=$dbh->prepare("SELECT distinct meas_category_code,meas_category_code from $archivedb.$pmcodetomeascatalllower where primary_meas_type_code='$newprimmeasB' order by meas_category_code");
				if (!defined $sth_sortedmcc) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_sortedmcc->execute;
				while ($sortedmcc = $sth_sortedmcc->fetch) {
					$smcc=$sortedmcc->[0];
					$countsubcat=0;
					$sth_countsubcategory=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$meassubcatdetailstab where meas_category_code='$smcc'");
					if (!defined $sth_countsubcategory) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_countsubcategory->execute;
					while ($countsubcategory = $sth_countsubcategory->fetch) {
						$countsubcat=$countsubcategory->[0];
					}
					if ($countsubcat > 0) {
						$mcsc="";
						if ($smcc ne $omcc) {
							$sth_getmcsc=$dbh->prepare("SELECT distinct meas_subcategory_code,meas_subcategory_code from $archivedb.$pmcodetomeassubcatalllower where $archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code='$newprimmeasB'");
							if (!defined $sth_getmcsc) { die "Cannot prepare statement: $DBI::errstr\n"; }
							$sth_getmcsc->execute;
							while ($getmcsc = $sth_getmcsc->fetch) {
								$mcsc="$getmcsc->[0]";
								$checkcount=0;
								if ($mcsc ne "NULL") {
									$countsubcat = $countsubcat + 1;
									$sth_countmcc=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeassubcatalllower where $archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code='$newprimmeasB' and $archivedb.$pmcodetomeassubcatalllower.meas_subcategory_code='$mcsc'");
									if (!defined $sth_countmcc) { die "Cannot prepare statement: $DBI::errstr\n"; }
									$sth_countmcc->execute;
									while ($countmcc = $sth_countmcc->fetch) {
										$checkcount=$countmcc->[0];
									}
								}
								if ($checkcount > 0) {
									#check if mc/msc pair actually exists
									$countmcmscvalid=0;
									$sth_checkmcscvalid=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$meassubcatdetailstab WHERE $archivedb.$meassubcatdetailstab.meas_category_code='$smcc' and $archivedb.$meassubcatdetailstab.meas_subcategory_code='$mcsc'");
									if (!defined $sth_checkmcscvalid) { die "Cannot prepare statement: $DBI::errstr\n"; }
									$sth_checkmcscvalid->execute;
									while ($checkmcscvalid = $sth_checkmcscvalid->fetch) {
										$countmcmscvalid=$checkmcscvalid->[0];
									}
									if ($countmcmscvalid > 0) {
										$duprec=1;
										$sth_checkexist=$dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$IDNo and meas_category_code='$smcc' and meas_subcategory_code='$mcsc'");
										if (!defined $sth_checkexist) { die "Cannot prepare statement: $DBI::errstr\n"; }
										$sth_checkexist->execute;
										while ($checkexist = $sth_checkexist->fetch) {
											$duprec=$checkexist->[0];
										}
										if ($duprec == 0) {
											$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$user_id,'$smcc','$mcsc',1)");
										}
										$duprec = 1;
									}
								}
							}
						}
					}
					if ($countsubcat == 0) {
						$duprec=1;
						$sth_checkexist=$dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$IDNo and meas_category_code='$smcc' and meas_subcategory_code=null");
						if (!defined $sth_checkexist) { die "Cannot prepare statement: $DBI::errstr\n"; }
						$sth_checkexist->execute;
						while ($checkexist = $sth_checkexist->fetch) {
							$duprec=$checkexist->[0];
						}
						if ($duprec == 0) {
							$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$user_id,'$smcc',null,1)");
						}
					}
					$omcc=$smcc;
				}
			}
		}
		$now=&getnow;
		$checkcomment="";
		if ($commenttrigger != 0) {	
			@newcommenttype=();
			@newcommenttype=sort @commenttype;
			foreach $ct (@newcommenttype) {
				if ($ct ne $checkcomment) {
					$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentDate,person_id,comment) values ($IDNo,'$now',$user_id,'$ct')");
					if ( ! defined $doStatus ) {
						print "An error has occurred adding your comment. Please contact the database administrator\n";
						print "</form></body></html>\n";
						$dbh->disconnect();
						exit;
					}
				}
				$checkcomment=$ct;
			}
		}		
	}
	if ($submit eq "REMOVE selected associations from MMT DB") {
		if ($keeppms == 1) {
			$message="YES";
		} else {
			$message="NO";
		}
		print "Keep PMT assignments? $message<br>\n";
		$commenttrigger=0;
		@commenttype=();
		if ($curr_inst_class ne "") {
			@currinsts=();
			@currinsts=split(/\0/,$curr_inst_class);
			foreach $i (@currinsts) {
				$doStatus = $dbh->do("DELETE from instClass where IDNo=$IDNo and instrument_class='$i'");
			}
			$doStatus = $dbh->do("DELETE from instCats where IDNo=$IDNo");
			if ($keeppms == 0) {
				$doStatus = $dbh->do("DELETE from measCats where IDNo=$IDNo");
				$doStatus = $dbh->do("DELETE from primMeas where IDNo=$IDNo");
				$doStatus = $dbh->do("DELETE from sourceClass where IDNo=$IDNo");
				$sth_getrid = $dbh->prepare("SELECT distinct person_id,person_id from reviewers where revFunction='MDATA' and type='$type'");
				foreach $getrid (@getrid) {
					$doStatus = $dbh->do("DELETE from reviewerStatus where IDNo=$IDNo AND person_id=$getrid");
				}
			}
		}
		
		if ($curr_prim_meas ne "") {
			@currprimmeas=();
			@currprimmeas=split(/\0/,$curr_prim_meas);
			foreach $pm (@currprimmeas) {
				@breakup=();
				@breakup=split(/:/,$pm);
				$vn="";
				if ($breakup[1] eq "") {
					$vn="NULL";
				} else {
					$vn="'"."$breakup[1]"."'";
				}
				$now=&getnow;
				$doStatus = $dbh->do("DELETE from primMeas where IDNo=$IDNo and primary_measurement='$breakup[2]' AND primary_meas_code='$breakup[0]' and var_name=$vn");
				$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentDate,person_id,comment) values ($IDNo,'$now',$user_id,'$breakup[0]:$breakup[1]:$breakup[2] removed ')");
			}
			$doStatus = $dbh->do("DELETE from measCats where IDNo=$IDNo");
			$sth_getprimmeas=$dbh->prepare("SELECT distinct primary_meas_code,primary_meas_code from primMeas where IDNo=$IDNo");
			if (!defined $sth_getprimmeas) { die "Cannot prepare statement: $DBI::errstr\n"; }
			$sth_getprimmeas->execute;
			while ($getprimmeas = $sth_getprimmeas->fetch) {
				$countit=0;
				$omcc="";
				$smcc="";
				$sth_sortedmcc=$dbh->prepare("SELECT distinct meas_category_code,meas_category_code from $archivedb.$pmcodetomeascatalllower where primary_meas_type_code='$getprimmeas->[0]' order by meas_category_code");
				if (!defined $sth_sortedmcc) { die "Cannot prepare statement: $DBI::errstr\n"; }
				$sth_sortedmcc->execute;
				while ($sortedmcc = $sth_sortedmcc->fetch) {
					$smcc=$sortedmcc->[0];
					$countsubcat=0;
					$sth_countsubcategory=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$meassubcatdetailstab where meas_category_code='$smcc'");
					if (!defined $sth_countsubcategory) { die "Cannot prepare statement: $DBI::errstr\n"; }
					$sth_countsubcategory->execute;
					while ($countsubcategory = $sth_countsubcategory->fetch) {
						$countsubcat=$countsubcategory->[0];
					}
					$countsub=0;
					if ($countsubcat > 0) {
						if ($smcc ne $omcc) {
							$scountit=0;
							@mscc=();
							$countsubcats=0;
							$smc="null";
							$sth_sortedmscc=$dbh->prepare("SELECT distinct meas_subcategory_code,meas_subcategory_code from $archivedb.$pmcodetomeassubcatalllower where primary_meas_type_code='$getprimmeas->[0]' order by meas_subcategory_code");
							$omscc="";
							if (!defined $sth_sortedmscc) { die "Cannot prepare statement: $DBI::errstr\n"; }
							$sth_sortedmscc->execute;
							while ($sortedmscc = $sth_sortedmscc->fetch) {
								$smc="\'$sortedmscc->[0]\'";
								if ($smc ne "null") {
									$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$user_id,'$smcc',$smc,1)");
									$countsub = $countsub + 1;
								}
							}
						}
					}
					if ($countsub == 0) {
						$doStatus = $dbh->do("INSERT INTO measCats values($IDNo,$user_id,'$smcc',null,1)");
					}
					$omcc=$sortedmcc;
				}
			}
		}
		if ($curr_source_class ne "") {
			@currsources=();
			@currsources=split(/\0/,$curr_source_class);
			foreach $s (@currsources) {
				$now=&getnow;
				$doStatus = $dbh->do("DELETE from sourceClass where IDNo=$IDNo and source_class='$s'");
				$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentDate,person_id,comment) values ($IDNo,'$now',$user_id,'source class $s removed')");
			}
			if ($keeppms == 0) {
				$doStatus = $dbh->do("DELETE from primMeas where IDNo=$IDNo");
				$doStatus = $dbh->do("DELETE from measCats where IDNo=$IDNo");
			}
		}
	}
}

############################################
if ($submit eq "Enter Comment") {
	$distemail=0;
	$distemail=$in{distemail};
	$now=&getnow;
	$comment=$in{comment};
	$origcomment=$in{comment};
	$_=$comment;
	s/'/''/g;
	$comment=$_;
	$checkdup=0;
	$countmatch=0;
	$oldcomment="";
	if ($comment ne "") {
		$sth_checkdups=$dbh->prepare("SELECT count(*) from comments where IDNo=$IDNo and person_id=$user_id and comment like '$comment'");
		if (!defined $sth_checkdups) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_checkdups->execute;
		while ($checkdups = $sth_checkdups->fetch) {
			$checkdup=$checkdups->[0];
		}
		if ($checkdup == 0) {
			$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentDate,person_id,comment) values ($IDNo,'$now',$user_id,'$comment')");
			if ( ! defined $doStatus ) {
				print "An error has occurred adding your comment. Please contact the database administrator\n";
				print "</form></body></html>\n";
				$dbh->disconnect();
				exit;
			}
			if ($comment ne $oldcomment) {
				if ($distemail == 1) {
					print"<strong>COMMENT DISTRIBUTED TO REVIEWERS</strong><p>\n";
					&distribute("$user_id","$type",$IDNo,'comment',"$origcomment");
				}
			}
			$oldcomment=$comment;
		} else {
			$countmatch = $countmatch + 1;
		}
	}
}
############################################
#### Display Summary Section
if ($type eq "CL") {
	if ($funcDesc ne "Guest") {
		print "<a href=\"Contacts.pl?IDNo=$IDNo\"><strong>Edit Submission?</a> \n";
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	}
	&displaycontacts($IDNo);
}
if ($type eq "CI") {
	if ($funcDesc ne "Guest") {
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	}
	&displayclone($IDNo);
}
if ($type eq "IC") {
	if ($funcDesc ne "Guest") {
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	}
	&displayinstcode($IDNo);
}
if ($type eq "S") {
	if ($funcDesc ne "Guest") {
		print "<a href=\"Site.pl?IDNo=$IDNo\"><strong>Edit Submission?</a> \n";
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	}
	
	&displaysite($IDNo);
}
if ($type eq "F") {
	if ($funcDesc ne "Guest") {
		print "<a href=\"Facility.pl?IDNo=$IDNo\"><strong>Edit Submission?</a> \n";
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	}
	&displayfac($IDNo);
}
if ($type eq "I") {
	if ($funcDesc ne "Guest") {
		print "<a href=\"InstClass.pl?IDNo=$IDNo\"><strong>Edit Submission?</a> \n";
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	}
	&displayinstclass($IDNo);
}
if ($type eq "PMT") {
	if ($funcDesc ne "Guest") {
		print "<a href=\"PMT.pl?IDNo=$IDNo\"><strong>Edit Submission?</a> \n";
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	}
	&displaypmt($IDNo);
}
if ($type eq "DOD") {
	print "<a href=\"DOD.pl?IDNo=$IDNo\"><strong>Edit Submission?</a> \n";
	print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
	print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
	print "</strong>\n";
	&displaydod($IDNo);
}
if ($type eq "DS") {
	$subid=0;
	if ($funcDesc ne "Guest") {
		print "<a href=\"DS.pl?IDNo=$IDNo\"><strong>Edit/View Basic Datatream Details?</a> \n";
		print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
		print "<a href=\"DailyMMTArchiveCompare.pl?mtype=$type&IDNo=$IDNo\" target=\"synchronize\">Synchronize this record with Archive</a><p>\n";
		print "</strong>\n";
	} else {
		$sth_checksubmitter = $dbh->prepare("SELECT submitter,submitter from DS where IDNo=$IDNo");
		if (!defined $sth_checksubmitter) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checksubmitter->execute;
		while ($checksubmitter = $sth_checksubmitter->fetch) {
			$subid=$checksubmitter->[0];
		}
		if ($subid == $user_id) {
			print "<a href=\"DS.pl?IDNo=$IDNo\"><strong>Edit/View Basic Datatream Details?</a> \n";
			print "<a href=\"Delete.pl?IDNo=$IDNo&type=$type\">Delete Submission from MMT?</a><p>\n";
			print "</strong>\n";
		}
	}
	&displayds($IDNo);
	$valid=0;
	$sth_checkuser=$dbh->prepare("SELECT count(*),count(*) from reviewers where person_id=$user_id and revFunction='MDATA' and type='$type' ");
	if (!defined $sth_checkuser) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_checkuser->execute;
	while ($checkuser = $sth_checkuser->fetch) {
		$valid=$checkuser->[0];
	}
	if ($valid == 0) {
		if ($subid == $user_id) {
			$valid=1;
		}
	}
	if ($valid > 0) {
		&displaydsMDdetails($IDNo,$mcatfilt);
	}
}

#################################################################################
# display comment history and input section
&displaycomment("$type",$IDNo);
#################################################################################
# display current status and status update section
if ($type ne "CI") {
	&displaystatus("$type",$IDNo,$user_id);
} else {
	print "NO STATUS UPDATE SECTION FOR CLONING<br>\n";
}
#################################################################################
# select and display linked DODs (7/30/2013)
if ($type eq "DOD") {
	&dodlinks($IDNo);
}
print "<hr>\n";
#################################################################################
# end of web page
print "</form>\n";
&bottomlinks($IDNo,"$type","x");
$IDNo="";
$dbh->disconnect();
print "</div>\n";
print "</BODY></HTML>\n";
