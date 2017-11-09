package PGMMT_lib;
use 5.006;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(get_user get_pwd get_admin get_apw get_webserver get_dbname get_peopletab get_grouprole get_statustab get_archivedb get_facsinfo get_meassubcatdetailstab get_meascatdetailstab get_sitetoinstrinfotab get_instrcodedetailstab get_instrclasstoinstrcattab get_instrcodetoinstrclasstab get_siteinfotab get_pmcodetoinstrclass get_instrclasstosourceclass get_instrclassdetailstab get_pmcodetomeascatalllower get_pmcodetomeassubcatalllower get_instrcatdetailstab get_pmtypedetailstab get_dsinfotab get_dsvarnameinfotab get_dsvarnamemeascatstab get_sourceclassdetails displaysite displayfac displayds displaypmt displayinstclass displayinstcode displaydod displaycomment distribute sendimplementation displaystatus displaydsMDdetails bottomlinks toplinks webpagesetup getnow displaycontacts displayclone dodlinks get_dbserver);
use DBI;
use Time::Local;
#!/usr/bin/perl
my $HOST = $ENV{'SERVER_NAME'};
my $remote_user=$ENV{'REMOTE_USER'};
my $VROOT=$ENV{'VROOT'};
if ($VROOT eq "") { $VROOT="/home/www/DB"; }
my $webserver=&get_webserver;
my $dbname = &get_dbname;
my $user = &get_user;
my $password= &get_pwd;
my $dbserver = &get_dbserver;
my $admin = &get_admin;
my $adminpw = &get_apw;
my $archivedb = &get_archivedb;
my $peopletab = &get_peopletab; #people db
my $grouprole = &get_grouprole; #people db
my $statustab = &get_statustab; #people db
my $dsinfotab = &get_dsinfotab; #user table
my $dsvarnameinfotab = &get_dsvarnameinfotab; #user table
my $dsvarnamemeascatstab = &get_dsvarnamemeascatstab; #user table
my $facinfotab = &get_facsinfo; # user table
my $sourceclassdetails = &get_sourceclassdetails; #user table
my $instrcodedetailstab = &get_instrcodedetailstab; #user table
my $siteinfotab = &get_siteinfotab; #user table
my $instrclasstoinstrcattab = &get_instrclasstoinstrcattab; #user table
my $instrclassdetailstab = &get_instrclassdetailstab; #user table
my $pmcodetoinstrclass = &get_pmcodetoinstrclass;  # user table
my $instrclasstosourceclass=&get_instrclasstosourceclass; # user table
my $pmcodetomeascatalllower = &get_pmcodetomeascatalllower; # user table
my $pmcodetomeassubcatalllower = &get_pmcodetomeassubcatalllower; #user table
my $meascatdetailstab = &get_meascatdetailstab; #user table
my $meassubcatdetailstab = &get_meassubcatdetailstab; #user table
my $pmtypedetailstab = &get_pmtypedetailstab; #user table
my $instrcatdetailstab = &get_instrcatdetailstab; # user table
my $instrcodetoinstrclasstab = &get_instrcodetoinstrclasstab; #user table
my $sitetoinstrinfotab = &get_sitetoinstrinfotab; #user table
################################################################################
sub get_user { return 'mmt_user'; }
sub get_pwd { return 'user_mmt'; }
sub get_admin { return 'mmtmgr'; }
sub get_apw { return 'adminmmt'; }
sub get_dbname { return 'mmt'; }
sub get_webserver { $HOST = $ENV{'SERVER_NAME'}; return $HOST; }
sub get_dbserver { 
	$HOST = $ENV{'SERVER_NAME'};
	if ($HOST =~ 'dev.www.db') {
		return 'xpand.ornl.gov';
	} else {
		return 'xpand.ornl.gov'; 
	}
}	
sub get_archivedb { 
	$HOST = $ENV{'SERVER_NAME'};
	if ($HOST =~ 'dev.www.db') {
		return 'arm_int2';
		$webserver='dev.www.db1.arm.gov';
	} else {
		return 'arm_int2'; 
		$webserver='www.db1.arm.gov';
	}
}
sub get_peopletab { 
	return 'people.people';
}
sub get_statustab { 
	return 'people.status_lookup';
}
sub get_grouprole { 
	return 'people.group_role';
}
sub get_siteinfotab { return 'site_info'; } # user table
sub get_sitetoinstrinfotab { return 'site_to_instr_info'; } # user table
sub get_facsinfo { return 'facility_info'; } # user table
sub get_dsinfotab { return 'datastream_info'; } # user table
sub get_dsvarnameinfotab { return 'datastream_var_name_info'; } # user table
sub get_dsvarnamemeascatstab { return 'datastream_var_name_meas_cats'; } #user table
sub get_instrcatdetailstab { return 'instr_category_details'; } # user table
sub get_instrclassdetailstab { return 'instr_class_details'; } #user table
sub get_instrcodetoinstrclasstab { return 'instr_code_to_instr_class'; } # user table
sub get_instrcodedetailstab { return 'instr_code_details'; } # user table
sub get_instrclasstoinstrcattab { return 'instr_class_to_instr_cat'; } # user table
sub get_meassubcatdetailstab { return 'meas_subcategory_details'; } # user table
sub get_meascatdetailstab { return 'meas_category_details';} #user table
sub get_pmcodetomeascatalllower { return 'PM_code_to_meas_cat'; } #user table
sub get_pmtypedetailstab { return 'PM_type_details'; } #user table
sub get_pmcodetomeassubcatalllower { return 'PM_code_to_meas_subcat'; } # user table
sub get_pmcodetoinstrclass { return 'PM_code_to_instr_class'; } # user table
sub get_instrclasstosourceclass { return 'instr_class_to_source_class'; } # user table
sub get_sourceclassdetails { return 'source_class_details'; } #user table
###############################################################################
# web page set up
###############################################################################
sub webpagesetup
{
	print $query->header;
	print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
	print "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n";
	print "<head>\n";
	print "<title>MMT:MetaData Management Tool</title>\n";
	print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
	print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
	print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/arm_adv.css\"; --></style>\n";
	print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
	print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/fc.css\"; --></style>\n";
	print "<style type=\"text/css\" media=\"all\">\n";
	print "#content {margin-right:0;background-image: none;}\n";
	print "table {width: 100%; margin: 0; padding: 0;}\n";
	print "table,th,td {\n";
	print "border:1px solid black;\n";
	print "cellspacing:10px;\n";
	print "vertical-align:top;\n";
	print "}\n";
	print ".red {\n";
	print "color: red;\n";
	print "}\n";
	print "</style>\n";
	print "</head>\n";
	print '<body class=\"iops\">';
	print '<div id=\"content\">';
}
###############################################################################
# links at page top
###############################################################################
sub toplinks
{	
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	my $usid = shift;
	my $nmf = shift;
	my $nml = shift;
	my $tp = shift;
	#get the users reviewer function
	$funcDesc="";
	$countfunc=0;
	if ($tp ne "") {	
		$sth_getfunc = $dbh->prepare("SELECT distinct person_id,reviewers.revFunction,revFuncLookup.revFuncDesc from reviewers,revFuncLookup where person_id=$usid AND reviewers.revFunction=revFuncLookup.revFunction AND reviewers.type='$tp'");
        	if (!defined $sth_getfunc) { die "Cannot  statement: $DBI::errstr\n"; }
	} else {
	
		$sth_getfunc = $dbh->prepare("SELECT distinct person_id,reviewers.revFunction,revFuncLookup.revFuncDesc from reviewers,revFuncLookup where person_id=$usid AND reviewers.revFunction=revFuncLookup.revFunction");
        	if (!defined $sth_getfunc) { die "Cannot  statement: $DBI::errstr\n"; }
	}
	$sth_getfunc->execute;
	while($getfunc = $sth_getfunc->fetch) {
		if ($countfunc == 0) {
			$funcDesc=$getfunc->[1];
		} else {
			$funcDesc="$funcDesc".", "."$getfunc->[1]";
		}
		$countfunc = $countfunc + 1;
	}
	if ($funcDesc eq "") {
		$funcDesc="Guest";
	}
	print "<small>\n";
	print "$nmf $nml: $funcDesc Reviewer</small><br>\n";
	$dbh->disconnect();
}
###############################################################################
# links at page bottom
###############################################################################
sub bottomlinks
{
	my $idn = shift;
	my $otype = shift;
	my $dontdo = shift;
	if (($idn ne "") && ($dontdo ne "x")) {
		print "<strong><a href=\"reviewMetaData.pl?IDNo=$idn\">Metadata Assignment/Review</a></strong><p>\n";
	}	
	print "<strong><h3><a href=\"MMTMetaData.pl?type=$otype\">MMT Summary Page</a></h3></strong><p>\n";
	print "<strong><h3><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></h3></strong><p>\n";
	if ($idn ne "") {
		print "<a href=\"statusHistory.pl?IDNo=$idn\" target=stathist>View Status History</a><br />\n";
		print "<a href=\"whoswho.pl?IDNo=$idn\" target=who>Display Who's Who</a><br />\n";
	}	
}
################################################################################
# subroutine to display contact objects summary
################################################################################
sub displaycontacts
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      	
	my $IDNo = shift;
	my $sortby = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";	
	$sortable=0;
	if ($IDNo eq "") {
		$sortable=1;
	}
	if ($sortable == 0) {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=8 align=center><strong><font color=blue>ARM Contacts</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%>Submit Date</th><th width=10%>Submitter</th><th width=10%><font color=blue>Contact Name</font></th><th width=20%><font color=blue>Group</font></th><th width=15%><font color=blue>Role</font></th><th width=15%><font color=blue>Sub-Role</font></th></font><th width=10%>Review Status</th>\n";
		print "<th width=10%>People DB (grouprole) Status</th>\n";
		print "</tr>";
	} else {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";	
		print "<th colspan=8 align=center><strong><font color=blue>ARM Contacts</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=entry_date\" style=\"text-decoration: none; color:black\">Submit Date</a></th><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=submitter\" style=\"text-decoration: none; color:black\">Submitter</a></th><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=contact\" style=\"text-decoration: none;color: blue\">Contact Name</a></font></th><th width=20%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=group\" style=\"text-decoration: none; color: black\">Group</a></th><th width=15%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=role\" style=\"text-decoration: none;color: black\">Role</a></th><th width=15%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=subrole\" style=\"text-decoration: none; color: black\">Sub-Role</a></th><th><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=rstatus\" style=\"text-decoration: none; color: black\">Review Status</a></th>\n";
		print "<th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=CL&sortby=dbstatus\" style=\"text-decoration: none\">People DB (grouprole) Status</a></th>\n";
		print "</tr>";		
	}	
	if ($IDNo eq "") {
		if ($sortby eq "") {		
			$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs where instContacts.IDNo=IDs.IDNo and type='CL' order by instContacts.IDNo desc");
        		if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
		} else {
			if ($sortby eq "submitter") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs,$peopletab where instContacts.IDNo=IDs.IDNo and instContacts.submitter=$peopletab.person_id and type='CL' order by name_last,instContacts.group_name,instContacts.role_name,instContacts.subrole_name,instContacts.IDNo");
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
			} elsif ($sortby eq "contact") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs,$peopletab where instContacts.IDNo=IDs.IDNo and instContacts.contact_id=$peopletab.person_id and type='CL' order by name_last,instContacts.group_name,instContacts.role_name,instContacts.subrole_name,instContacts.IDNo");	
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }			
			} elsif ($sortby eq "group") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs where instContacts.IDNo=IDs.IDNo and type='CL' order by instContacts.group_name,instContacts.role_name,instContacts.subrole_name,instContacts.IDNo");	
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }				
			} elsif ($sortby eq "role") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs where instContacts.IDNo=IDs.IDNo and type='CL' order by instContacts.role_name,instContacts.group_name,instContacts.subrole_name,instContacts.IDNo");	
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }			
			} elsif ($sortby eq "subrole") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs where instContacts.IDNo=IDs.IDNo and type='CL' order by instContacts.subrole_name,instContacts.group_name,instContacts.role_name,instContacts.IDNo");	
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }				
			} elsif ($sortby eq "rstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs where instContacts.IDNo=IDs.IDNo and type='CL' order by IDs.revStatus,instContacts.group_name,instContacts.role_name,instContacts.subrole_name,instContacts.IDNo");
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }			
			} elsif ($sortby eq "dbstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs where instContacts.IDNo=IDs.IDNo and type='CL' order by IDs.DBstatus,instContacts.group_name,instContacts.role_name,instContacts.subrole_name,instContacts.IDNo");
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }			
			} elsif ($sortby eq "entry_date") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instContacts.IDNo,type,revStatus,DBstatus,entry_date from instContacts,IDs where instContacts.IDNo=IDs.IDNo and type='CL' order by IDs.entry_date desc,instContacts.IDNo");
				if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }					
			}	
		}				
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}			
	$countstar=0;
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while($getIDs = $sth_getIDs->fetch) {
		$Idno = $getIDs->[0];
		print "<tr>\n";
		$sth_getcontacts = $dbh->prepare("SELECT IDNo,submitter,contact_id,group_name,role_name,subrole_name,statusFlag from instContacts WHERE IDNo=$Idno order by IDNo");
		if (!defined $sth_getcontacts) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getcontacts->execute;
		while($getcontacts = $sth_getcontacts->fetch) {
			$REVstat=$getIDs->[2];
			$DBstat=$getIDs->[3];
			$entry_date=$getIDs->[4];
			@tmp=();
			@tmp=split(/ /,$entry_date);
			$entry_date=$tmp[0];
			$submitter="";
			$submittername="";
			$contactid="";
			$contactname="";
			$groupname="";
			$rolename="";
			$subrolename="";
			$status="";
			$checkstatthisone=0;
			$exist=0;
			$submittername="";
			$submitter=$getcontacts->[1];
			$sth_getperson=$dbh->prepare("SELECT name_first,name_last from $peopletab where $peopletab.person_id=$submitter");
			if (!defined $sth_getperson) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getperson->execute;
			while($getperson = $sth_getperson->fetch) {
				$submittername="$getperson->[0]"." "."$getperson->[1]";
			}
			$contactid=$getcontacts->[2];
			$sth_getperson=$dbh->prepare("SELECT name_first,name_last from $peopletab where $peopletab.person_id=$contactid");
			if (!defined $sth_getperson) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getperson->execute;
			while($getperson = $sth_getperson->fetch) {
				$contactname="$getperson->[0]"." "."$getperson->[1]";
			}
			$groupname=$getcontacts->[3];
			$rolename=$getcontacts->[4];
			$subrolename=$getcontacts->[5];
			if ($subrolename eq "") {
				$subrolename="NULL";
			} else {
				$subrolename="\'$subrolename\'";
				
			}
			$status=$getcontacts->[6];
			$REVstatdesc="";
			$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
			if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getstatdesc->execute;
			while ($getstatdesc = $sth_getstatdesc->fetch) {
				$REVstatdesc=$getstatdesc->[1];
			}
			$fontcolor="black";
			$dbfontcolor="black";
			$newcontactnotation=0;
			if ($REVstat == 0) {
				$fontcolor="red";
			}
			if ($REVstat == 1) {
				$fontcolor="green";
			}
			if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
				$dbfontcolor="blue";
			}
			if ($DBstat == -2) {
				$dbfontcolor="red";
			}
			$DBstatdesc="";
			$sth_getDBstatdesc=$dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");
			if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getDBstatdesc->execute;
			while ($getDBstatdesc = $sth_getDBstatdesc->fetch) {
				$DBstatdesc=$getDBstatdesc->[1];
			}
			$newcontactnotation=0;
			$origgroupname="";
			$origrolename="";
			$origsubrolename="";
			$sth_getpeople = $dbh->prepare("SELECT count(*),count(*) from $grouprole where $grouprole.person_id=$contactid and $grouprole.group_name='$groupname'");
			if (!defined $sth_getpeople) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getpeople->execute;
			while ($getpeople = $sth_getpeople->fetch) {
				$newcontactnotation = $getpeople->[0];
			}
			$exist=0;
			print "<td>$entry_date</td>\n";
			if (($newcontactnotation == 0) && ($DBstat != -2)) {
				print "<td>$submittername</td><td><font color=blue><strong>$contactname</strong></font></td>\n";
				print "<td><strong><font color=red>$groupname</font></strong><br /><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
			} elsif (($newcontactnotation != 0) && ($DBstat != -2))  {
				print "<td>$submittername</td><td><font color=blue><strong>$contactname</strong></font></td>\n";
				print "<td><strong><font color=blue>$groupname</font></strong><br /><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
				$exist=1;
			} elsif (($newcontactnotation != 0) && ($DBstat == -2)) {
				print "<td>$submittername</td><td><font color=blue><strong>$contactname</strong></font></td>\n";
				print "<td><strong><font color=blue>$groupname </font><font color=red>-</font></strong><br /><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
				$exist=1;
			}
			$numofcomments=0;
			$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
			if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_countcomments->execute;
			while ($countcomments = $sth_countcomments->fetch) {
				$numofcomments = $countcomments->[0];
			}
			if ($numofcomments > 0) {
				print " <small><font color=green><strong>(c)</strong></font></small></td>";
			} else {
				print "</td>\n";
			}
			$sth_getpeople = $dbh->prepare("SELECT count(*),count(*) from $grouprole where $grouprole.person_id=$contactid and $grouprole.group_name='$groupname' and $grouprole.role_name='$rolename'");
			if (!defined $sth_getpeople) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getpeople->execute;
			while ($getpeople = $sth_getpeople->fetch) {
				$newcontactnotation = $getpeople->[0];
			}				
			if (($newcontactnotation == 0) && ($DBstat != -2)) {
				print "<td><strong><font color=red>$rolename</font></strong></td>";
				$exist=0;
			} elsif (($newcontactnotation != 0) && ($DBstat != -2))  {
				print "<td><strong><font color=blue>$rolename</font></strong></td>";
				$exist=1;
			} elsif (($newcontactnotation != 0) && ($DBstat == -2)) {
				print "<td><strong><font color=blue>$rolename</font> <font color=red>-</font></strong></td>";
				$exist=1;
			}
			$sth_getpeople = $dbh->prepare("SELECT count(*),count(*) from $grouprole where $grouprole.person_id=$contactid and $grouprole.group_name='$groupname' and $grouprole.role_name='$rolename' and $grouprole.subrole_name=$subrolename");
			if (!defined $sth_getpeople) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getpeople->execute;
			while ($getpeople = $sth_getpeople->fetch) {
				$newcontactnotation = $getpeople->[0];
			}				
			$_=$subrolename;
			s/\'//,g;
			s/\'//,g;
			$prsub=$_;
			if ($prsub eq "NULL") {
				$prsub="";
			} 
			if (($newcontactnotation == 0) && ($DBstat != -2)) {
				print "<td><strong><font color=red>$prsub</font></strong></td>";
				$exist=0;
			} elsif (($newcontactnotation != 0) && ($DBstat != -2)) {
				print "<td><strong><font color=blue>$prsub</font></strong></td>";
				$exist=1;
			} elsif (($newcontactnotation != 0) && ($DBstat == -2)) {
				print "<td><strong><font color=blue>$prsub</font> ";
				if ($prsub != "") {
					print "<font color=red>-</font>";
				}
				print "</strong></td>";
				$exist=1;			
			}
			print "<td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";
			print "<td><font color=$dbfontcolor><strong>$DBstatdesc</strong></font></td>\n";
			print "</tr>\n";
		}
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();			
}
################################################################################
# subroutine to display clone objects summary
################################################################################
sub displayclone 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;     	
	my $IDNo = shift;
	my $sortby = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	if ($IDNo eq "") {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where type='CI' order by IDNo desc");
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}
	$countstar=0;
	# note: clones are not reviewed.  They go directly to sql implementation instructions.
	# there is no reviewer status for this MMT object
	print "<div id=\"tableContainer\">\n";
	print "<table cellspacing=\"0\">\n";
	print "<th colspan=7 align=center><strong><font color=blue>Clone</font> Submissions</strong></th>\n";
	print "<tr><th width=10%>Submit Date</th><th>Submitter</th><th>Originating Site/Facility</th><th>Originating Datastream Class(es)</th><th>Destination Site/Facility</th><th>Destination Datastream Class(es)";
	print "<th width=20%>ARCHIVE DB Status</th>\n";
	print "</tr>";
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$skip=0;
		$Idno = $getIDs->[0];
		$REVstat=$getIDs->[2];
		$DBstat=$getIDs->[3];
		$entry_date=$getIDs->[4];
		$osite="";
		$ofac="";
		$submitter="";
		$nsite="";
		$nfac="";
		$instcode="";
		$dataLevel="";
		$status="";
		$ninstcode="";
		$ninsstcodename="";
		$ndatalevel="";	
		$sth_getclone = $dbh->prepare("SELECT distinct IDNo,osite,ofacility_code,nsite,nfacility_code,$peopletab.name_last,$peopletab.name_first,statusFlag from clone,$peopletab WHERE clone.submitter=$peopletab.person_id AND clone.IDNo=$Idno order by IDNo");			
		if (!defined $sth_getclone) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getclone->execute;
		while($getclone = $sth_getclone->fetch) {
			$osite=$getclone->[1];
			$ofac=$getclone->[2];
			$submitter="$getclone->[6]"." "."$getclone->[5]";
			$nsite=$getclone->[3];
			$nfac=$getclone->[4];
			$status=$getclone->[7];
			$dbfontcolor="black";
			$DBstatdesc="";		
			$sth_getDBstatdesc = $dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");			
			if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getDBstatdesc->execute;
			while($getDBstatdesc = $sth_getDBstatdesc->fetch) {
				$DBstatdesc=$getDBstatdesc->[1];
			}
			if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
				$dbfontcolor="blue";
				$DBstatdesc="Submitted to Archive for Implementation";

			}
			print "<tr>\n";	
			$yyentry_date="";
			$mmentry_date="";
			$ddentry_date="";
			$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
			if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxentrydate->execute;
			while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
				$entry_date=$getmaxentrydate->[0];
				$yyentry_date=$getmaxentrydate->[1];
				$mmentry_date=$getmaxentrydate->[2];
				$ddentry_date=$getmaxentrydate->[3];
				$len=0;
				$len = length $mmentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmentry_date="0"."$mmentry_date";
					} else {
						$mmentry_date=$mmentry_date;
					}
				} else {
					$mmentry_date="";
				}
				$len=0;
				$len = length $ddentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddentry_date="0"."$ddentry_date";
					} else {
						$ddentry_date=$ddentry_date;
					}
				} else {
					$ddentry_date="";
				}
				if ($entry_date ne "") {
					$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
				} else {
					$nentry_date="";
				}				
			}
			$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";
			print "<td>$entry_date</td>";
			print "<td>$submitter</td>";
			print "<td>$osite:$ofac</td>";
			$countds=0;
			$sth_getds = $dbh->prepare("SELECT instrument_code,data_level from clone where IDNo=$Idno order by instrument_code");
			if (!defined $sth_getds) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getds->execute;
			while ($getds = $sth_getds->fetch) {
				if ($countds == 0) {
					print "<td>"."$getds->[0]"."\."."$getds->[1]";
				} else {
					print "<br>"."$getds->[0]"."\."."$getds->[1]";
				}
				$countds = $countds + 1;
			}
			print "</td>\n";
			print "<td><strong><font color=blue>$nsite:$nfac</font></strong>";
			$numofcomments=0;
			
			$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
			if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_countcomments->execute;
			while ($countcomments = $sth_countcomments->fetch) {
				$numofcomments = $countcomments->[0];
			}
			if ($numofcomments > 0) {
				print " <small><font color=green><strong>(c)</strong></font></small>";
			}
			print "<br /><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
			print "</td>";
			$thiscode="";
			$thiscodename="";
			$thisdl="";
			$countds=0;
			
			$sth_getds = $dbh->prepare("SELECT instrument_code,data_level,ninstrument_code,ninstrument_code_name,ndata_level from clone where IDNo=$Idno order by instrument_code,data_level");
			if (!defined $sth_getds) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getds->execute;
			while ($getds = $sth_getds->fetch) {
				if ($getds->[2] ne "") {
					$thiscode=$getds->[2];
					$thiscodename=$getds->[3];
				} else {
					$thiscode=$getds->[0];
					$thiscodename="";
				}
				if ($getds->[4] ne "") {
					$thisdl=$getds->[4];
				} else {
					$thisdl=$getds->[1];
				}
				if (($getds->[2] ne "") || ($getds->[4] ne "")) {
					if ($countds == 0) {
						print "<td>"."$thiscode"."\."."$thisdl ";
						if ($thiscodename ne "") {
							print " ($thiscodename)";
						}
					} else {
						print "<br>"."$thiscode"."\."."$thisdl ";
						if ($thiscodename ne "") {
							print " ($thiscodename)";
						}
					}
				} else {
					if ($countds == 0) {
						print "<td>NO CHANGE";
					}
				}
				$countds = $countds + 1;
			}
			print "</td>\n";
			print "<td><strong><font color=$dbfontcolor>$DBstatdesc</font></strong></td>";
			print "</tr>";
		}
	}
	print "</table>\n";
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
################################################################################
# subroutine to display site objects summary
################################################################################
sub displaysite 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	my $IDNo = shift;
	my $sortby = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	$sortable=0;
	if ($IDNo eq "") {
		$sortable=1;
	}
	if ($sortable == 0) {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=11 align=center><strong><font color=blue>Site</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><br>Submit Date</th><th width=10%><br>Latest Update</th><th width=10%><br>Submitter</th><th width=10%><font color=blue><br>Site</font></th><th width=20%><br>Site Name</th><th width=10%>Start Date<br>(YYYY-MM-DD)</th><th width=10%>End Date<br>(YYYY-MM-DD)</th><th width=10%>Site<br>Type</th><th><br>Production?</th><th><br>Review Status</th>\n";
		print "<th width=10%>DB (arm_int)<br>Status</th>\n";
		print "</tr>";
	} else {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";	
		print "<th colspan=11 align=center><strong><font color=blue>Site</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><font color=\"green\"><strong><br>+ </strong></font><a href=\"MMTMetaData.pl?type=S&sortby=entry_date\" style=\"text-decoration: none; color:black\">Submit Date</a></font></th><th width=10%><br>Latest  Update</th><th width=10%><font color=\"green\"><strong><br>+ </strong></font><a href=\"MMTMetaData.pl?type=S&sortby=submitter\" style=\"text-decoration: none; color:black\">Submitter</a></th><th width=10%><font color=\"green\"><strong><br>+ </strong></font><a href=\"MMTMetaData.pl?type=S&sortby=site\" style=\"text-decoration: none;color: blue\">Site</a></font></th><th width=20%><br>Site Name</th><th width=10%>Start Date<br>(YYYY-MM-DD)</th><th width=10%>End Date<br>(YYYY-MM-DD)</th><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=S&sortby=type\" style=\"text-decoration: none; color: black\">Site<br>Type</a></th><th><br>Production?</th><th><font color=\"green\"><strong><br>+ </strong></font><a href=\"MMTMetaData.pl?type=S&sortby=rstatus\" style=\"text-decoration: none; color: black\">Review Status</a></th>\n";
		print "<th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=S&sortby=dbstatus\" style=\"text-decoration: none\">DB (ARM_int) Status</a></th>\n";
		print "</tr>";		
	}
	if ($IDNo eq "") {
		if ($sortby eq "") {
		
			$sth_getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs where sites.IDNo=IDs.IDNo and type='S' order by sites.IDNo desc");
		} else {
			if ($sortby eq "submitter") {
				$sth_getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs,$peopletab where sites.IDNo=IDs.IDNo and sites.submitter=$peopletab.person_id and type='S' order by name_last,sites.IDNo");
			
			} elsif ($sortby eq "site") {
				$sth_getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs where sites.IDNo=IDs.IDNo and type='S' order by sites.site");					
			} elsif ($sortby eq "type") {
				$sth_getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs where sites.IDNo=IDs.IDNo and type='S' order by sites.site_type");		
			} elsif ($sortby eq "rstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs where sites.IDNo=IDs.IDNo and type='S' order by IDs.revStatus,sites.IDNo");
			} elsif ($sortby eq "dbstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs where sites.IDNo=IDs.IDNo and type='S' order by IDs.DBstatus,sites.IDNo");
			} elsif ($sortby eq "entry_date") {
				$sth_getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs where sites.IDNo=IDs.IDNo and type='S' order by IDs.entry_date desc,sites.site");
			# need to figure out how to SORT by update date which means I would need to redo alot of the on-the-fly queries and store results in arrays to sort... not worth it?!
			#} elsif ($sortby eq "update_date") {
			#	@getIDs = $dbh->prepare("SELECT distinct sites.IDNo,type,revStatus,DBstatus,entry_date from sites,IDs where sites.IDNo=IDs.IDNo and type='S' order by IDs.entry_date desc,sites.site");			
			}
		}		
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}	
	$countstar=0;
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$skip=0;
		$Idno = $getIDs->[0];
		$sth_checkds = $dbh->prepare("SELECT count(*),count(*) from DS where IDNo=$Idno");
		if (!defined $sth_checkds) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checkds->execute;
		while ($checkds = $sth_checkds->fetch) {
			$skip=$checkds->[0];
		}
		if ($skip == 0) {
			$REVstat=$getIDs->[2];
			$DBstat=$getIDs->[3];
			$entry_date=$getIDs->[4];
			@tmp=();
			@tmp=split(/ /,$entry_date);
			$entry_date=$tmp[0];
			$site="";
			$site_name="";
			$submitter="";
			$start_date="";
			$styr="";
			$stmn="";
			$stdy="";
			$end_date="";
			$endyr="";
			$endmn="";
			$enddy="";
			$site_type="";
			$fmstdate="";
			$fmenddate="";
			$status="";
			$production="";
			$comment_date="";
			$status_date="";
			$yycomment_date="";
			$mmcomment_date="";
			$ddcomment_date="";
			$yystatus_date="";
			$mmstatus_date="";
			$ddstatus_date="";
			$yyentry_date="";
			$mmentry_date="";
			$ddentry_date="";
			$ncomment_date="";
			$nstatus_date="";
			# getmaxcommentdate, getmaxstatusdate and getmaxentrydate are used to try and determine what was the latest date for any action with the submission			
			$sth_getmaxcommentdate = $dbh->prepare("SELECT commentDate,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate) from comments where IDNo=$Idno and commentDate=(SELECT max(commentDate) from comments where IDNo=$Idno)");			
			if (!defined $sth_getmaxcommentdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxcommentdate->execute;
			while($getmaxcommentdate = $sth_getmaxcommentdate->fetch) {
				$comment_date=$getmaxcommentdate->[0];
				$yycomment_date=$getmaxcommentdate->[1];
				$mmcomment_date=$getmaxcommentdate->[2];
				$ddcomment_date=$getmaxcommentdate->[3];
				$len=0;
				$len = length $mmcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmcomment_date="0"."$mmcomment_date";
					} else {
						$mmcomment_date=$mmcomment_date;
					}
				} else {
					$mmcomment_date="";
				}
				$len=0;
				$len = length $ddcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddcomment_date="0"."$ddcomment_date";
					} else {
						$ddcomment_date=$ddcomment_date;
					}
				} else {
					$ddcomment_date="";
				}
				if ($comment_date ne "") {
					$ncomment_date="$yycomment_date"."$mmcomment_date"."$ddcomment_date";
				} else {
					$ncomment_date="";
				}				
			}
			
			$sth_getmaxstatusdate = $dbh->prepare("SELECT statusDate,DATE_PART('year',statusDate),DATE_PART('month',statusDate),DATE_PART('day',statusDate) from reviewerStatus where IDNo=$Idno and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$Idno)");
			if (!defined $sth_getmaxstatusdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxstatusdate->execute;
			while ($getmaxstatusdfate = $sth_getmaxstatusdate->fetch) {
				$status_date=$getmaxstatusdate->[0];
				$yystatus_date=$getmaxstatusdate->[1];
				$mmstatus_date=$getmaxstatusdate->[2];
				$ddstatus_date=$getmaxstatusdate->[3];
				$len=0;
				$len = length $mmstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmstatus_date="0"."$mmstatus_date";
					} else {
						$mmstatus_date=$mmstatus_date;
					}
				} else {
					$mmstatus_date="";
				}
				$len=0;
				$len = length $ddstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddstatus_date="0"."$ddstatus_date";
					} else {
						$ddstatus_date=$ddstatus_date;
					}
				} else {
					$ddstatus_date="";
				}
				if ($status_date ne "") {
					$nstatus_date="$yystatus_date"."$mmstatus_date"."$ddstatus_date";
				} else {
					$nstatus_date="";
				}			
			}
			$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
			if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxentrydate->execute;
			while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
				$entry_date=$getmaxentrydate->[0];
				$yyentry_date=$getmaxentrydate->[1];
				$mmentry_date=$getmaxentrydate->[2];
				$ddentry_date=$getmaxentrydate->[3];
				$len=0;
				$len = length $mmentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmentry_date="0"."$mmentry_date";
					} else {
						$mmentry_date=$mmentry_date;
					}
				} else {
					$mmentry_date="";
				}
				$len=0;
				$len = length $ddentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddentry_date="0"."$ddentry_date";
					} else {
						$ddentry_date=$ddentry_date;
					}
				} else {
					$ddentry_date="";
				}
				if ($entry_date ne "") {
					$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
				} else {
					$nentry_date="";
				}				
			}
			if ($ncomment_date eq "") {
				$ncomment_date=$nentry_date;
			}
			if ($nstatus_date eq "") {
				$nstatus_date =$nentry_date;
			}
			if ($ncomment_date > $nentry_date) {
				$update_date=$ncomment_date;
				if ($nstatus_date > $update_date) {
					$update_date=$nstatus_date;
				}
				
			} elsif ($nstatus_date > $nentry_date) {
				$update_date=$nstatus_date;
				if ($ncomment_date > $update_date) {
					$update_date=$ncomment_date;
				}
			} else {
				$update_date=$nentry_date;
			}			
			$upy = substr($update_date,0,4);
			$upm = substr($update_date,4,2);
			$upd = substr($update_date,6,2);
			$nupdate_date="$upm"."-"."$upd"."-"."$upy";
			$nupdate_date="$upy"."-"."$upm"."-"."$upd";
			$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";
			$sth_getnewsites = $dbh->prepare("SELECT sites.IDNo,site,site_name,start_date,end_date,sites.site_type,$peopletab.name_last,$peopletab.name_first,stype_desc,DATE_PART('year',start_date),DATE_PART('month',start_date),DATE_PART('day',start_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date),statusFlag,production,IDs.entry_date from sites,$peopletab,site_type_desc,IDs WHERE sites.submitter=$peopletab.person_id AND sites.IDNo=$Idno AND sites.site_type=site_type_desc.site_type and sites.IDNo=IDs.IDNo");
			if (!defined $sth_getnewsites) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getnewsites->execute;
			while ($getnewsites = $sth_getnewsites->fetch) {
				$checkstatthisone=0;
				$exist=0;
				$site=$getnewsites->[1];
				$site_name=$getnewsites->[2];
				$submitter="$getnewsites->[7]"." "."$getnewsites->[6]";
				$start_date=$getnewsites->[3];
				$end_date=$getnewsites->[4];
				$site_type=$getnewsites->[5];
				$site_type_desc=$getnewsites->[8];
				$styr=$getnewsites->[9];
				$stmn=$getnewsites->[10];
				$stdy=$getnewsites->[11];
				$endyr=$getnewsites->[12];
				$endmn=$getnewsites->[13];
				$enddy=$getnewsites->[14];
				$status=$getnewsites->[15];
				$production=$getnewsites->[16];
				$len=0;
				$len = length $stmn;
				if ($len < 2) {
					$stmn="0"."$stmn";
				}
				$len=0;
				$len = length $stdy;
				if ($len < 2) {
					$stdy="0"."$stdy";
				}
				$sstdate="$styr"."-"."$stmn"."-"."$stdy";
				if ($endyr ne "") {
					$len=0;
					$len = length $endmn;
					if ($len < 2) {
						$endmn="0"."$endmn";
					}
					$len=0;
					$len = length $enddy;
					if ($len < 2) {
						$enddy="0"."$enddy";
					}
					$senddate="$endyr"."-"."$endmn"."-"."$enddy";
				} else {
					$senddate="";
				}
				$REVstatdesc="";
				$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
				if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getstatdesc->execute;
				while ($getstatdesc = $sth_getstatdesc->fetch) {
					$REVstatdesc=$getstatdesc->[1];
				}
				$fontcolor="black";
				$dbfontcolor="black";
				$newsitenotation=0;
				if ($REVstat == 0) {
					$fontcolor="red";
				}
				if ($REVstat == 1) {
					$fontcolor="green";
				}
				if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
					$dbfontcolor="blue";

				}
				$DBstatdesc="";
				$sth_getDBstatdesc=$dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");
				if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getDBstatdesc->execute;
				while ($getDBstatdesc = $sth_getDBstatdesc->fetch) {
					$DBstatdesc=$getDBstatdesc->[1];
				}
				$newsitenotation=1;
				$origsite="";
				$origsitename="";
				$origstartdate="";
				$origenddate="";
				$origstyr="";
				$origstmn="";
				$origstdy="";
				$origendyr="";
				$origendmn="";
				$origenddy="";
				$origproduction="";
				$origsitetype="";		
				$sth_getarchive = $dbh->prepare("SELECT distinct upper(site_code),site_name,DATE_PART('year',start_date),DATE_PART('month',start_date),DATE_PART('day',start_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date),production,site_type from $archivedb.$siteinfotab where upper(site_code)='$site'");
				if (!defined $sth_getarchive) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getarchive->execute;
				while ($getarchive = $sth_getarchive->fetch) {
					$origsite=$getarchive->[0];
					$origsitename=$getarchive->[1];
					$origstyr=$getarchive->[2];
					$origstmn=$getarchive->[3];
					$origstdy=$getarchive->[4];
					$origendyr=$getarchive->[5];
					$origendmn=$getarchive->[6];
					$origenddy=$getarchive->[7];
					$origproduction=$getarchive->[8];
					$origsitetype=$getarchive->[9];
					$len=0;
					$len = length $origstmn;
					if ($len < 2) {
						$origstmn="0"."$origstmn";
					}
					$len=0;
					$len = length $origstdy;
					if ($len < 2) {
						$origstdy = "0"."$origstdy";
					}
					$origstartdate="$origstyr"."-"."$origstmn"."-"."$origstdy";
					if ($origendyr ne "") {
						$len=0;
						$len = length $origendmn;
						if ($len < 2) {
							$origendmn = "0"."$origendmn";
						}
						$len=0;
						$len = length $origenddy;
						if ($len < 2) {
							$origenddy = "0"."$origenddy";
						}
						$origenddate="$origendyr"."-"."$origendmn"."-"."$origenddy";
					} else {
						$origenddate="";
					}
				}
				$exist=0;
				if ("$site" ne "$origsite") {
					$newsitenotation = 0;
				}
				print "<tr>";
				print "<td>$entry_date</td><td>$nupdate_date</td><td>$submitter</td>";
				if ($newsitenotation == 0) {
					print "<td><strong><font color=red>$site</font></strong>";
					$exist=0;
				} else {
					print "<td><strong><font color=blue>$site</font></strong>";
					$exist=1;
				}
				$numofcomments=0;	
				$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
				if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countcomments->execute;
				while ($countcomments = $sth_countcomments->fetch) {
					$numofcomments = $countcomments->[0];
				}
				print "<br /><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
				if ($numofcomments > 0) {
					print " <small><font color=green><strong>(c)</strong></font></small>";
				}
				print "</td>";
				# check current MMT db status (DBstat)
				if ((($DBstat == 1) || ($DBstat == 2)) && ($origsitename ne $site_name)) {
					print "<td>$site_name <font color=red><strong>*</strong></font></td>\n";
					$countstar = $countstar + 1;
					$checkstatthisone = $checkstatthisone + 1;
				} else {
					print "<td>$site_name</td>\n";
				}
				if ((($DBstat == 1) || ($DBstat == 2)) && ($origstartdate ne $sstdate)) {
					print "<td>$sstdate <font color=red><strong>*</strong></font></td>\n";
					$countstar = $countstar + 1;
					$checkstatthisone = $checkstatthisone + 1;	
				} else {
					print "<td>$sstdate</td>\n";
				}
				if ((($DBstat == 1) || ($DBstat == 2)) && ($origenddate ne $senddate))  {
					print "<td>$senddate <font color=red><strong>*</strong></font></td>\n";
					$countstar = $countstar + 1;
					$checkstatthisone = $checkstatthisone + 1;
				} else {
					print "<td>$senddate</td>\n";
				}
				if ((($DBstat == 1) || ($DBstat == 2)) && ($origsitetype ne $site_type)) {
					print "<td>$site_type_desc <font color=red><strong>*</strong></font></td>\n";
					$countstar = $countstar + 1;
					$checkstatthisone = $checkstatthisone + 1;
				} else {
					print "<td>$site_type_desc</td>\n";
				}
				$pdesc="";
				$sth_getpdesc=$dbh->prepare("SELECT prodType,prodTypeDesc from prod_type_desc WHERE prodType='$production'");
				if (!defined $sth_getpdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getpdesc->execute;
				while ($getpdesc = $sth_getpdesc->fetch) {
					$pdesc=$getpdesc->[1];
				}
				if ((($DBstat == 1) || ($DBstat == 2)) && ($origproduction ne $production)) {
					print "<td>$pdesc <font color=red><strong>*</strong></font></td>\n";
					$countstar = $countstar + 1;
					$checkstatthisone = $checkstatthisone + 1;
				} else {
					print "<td>$pdesc</td>\n";
				}
				print "<td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";
				print "<td><font color=$dbfontcolor><strong>$DBstatdesc</strong></font></td>\n";
				print "</tr>\n";
			}
		}
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE Site = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED Site = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
################################################################################
# subroutine to display facility objects summary
################################################################################
sub displayfac 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	print "<div id=\"tableContainer\">\n";
	print "<table cellspacing=\"0\">\n";
	print "<th colspan=9 align=center><strong><font color=blue>Facility</font> Submissions for Review</strong></th>\n";
	print "<tr><th width=10%><br>Submit Date</th><th width=10%><br>Latest Update</th><th width=10%><br>Submitter</th><th width=15%><br />Site</th><th width=30%><font color=blue><br />Facilities</font></th><th width=10%>Facility Start Date<br />(YYYY-MM-DD)</th><th width=10%>Facility End Date<br />(YYYY-MM-DD)</th><th width=10%>Review<br />Status</th>\n";
	print "<th width=10%>DB (ARM_int)<br />Status</th>\n";
	print "</tr>";
	my $IDNo = shift;
	my $sortby = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	my $entry_date="";
	if ($IDNo eq "") {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where type='F' order by IDNo desc");
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}
	$countstar=0;
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$exist=0;
		$checkstatthisone=0;
		$Idno = $getIDs->[0];
		$skip=0;
		$sth_checkds = $dbh->prepare("SELECT count(*),count(*) from DS where IDNo=$Idno");
		if (!defined $sth_checkds) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checkds->execute;
		while ($checkds = $sth_checkds->fetch) {
			$skip=$checkds->[0];
		}
		if ($skip == 0) {
			$REVstat=$getIDs->[2];
			$DBstat=$getIDs->[3];
			$entry_date=$getIDs->[4];
			@tmp=();
			@tmp=split(/ /,$entry_date);
			$entry_date=$tmp[0];
			$chksite="";
			$site_name="";
			$inarch=0;						
			$comment_date="";
			$status_date="";
			$yycomment_date="";
			$mmcomment_date="";
			$ddcomment_date="";
			$yystatus_date="";
			$mmstatus_date="";
			$ddstatus_date="";
			$yyentry_date="";
			$mmentry_date="";
			$ddentry_date="";
			$ncomment_date="";
			$nstatus_date="";
			$sth_getmaxcommentdate = $dbh->prepare("SELECT commentDate,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate) from comments where IDNo=$Idno and commentDate=(SELECT max(commentDate) from comments where IDNo=$Idno)");
			if (!defined $sth_getmaxcommentdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxcommentdate->execute;
			while ($getmaxcommentdate = $sth_getmaxcommentdate->fetch) {
				$comment_date=$getmaxcommentdate->[0];
				$yycomment_date=$getmaxcommentdate->[1];
				$mmcomment_date=$getmaxcommentdate->[2];
				$ddcomment_date=$getmaxcommentdate->[3];
				$len=0;
				$len = length $mmcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmcomment_date="0"."$mmcomment_date";
					} else {
						$mmcomment_date=$mmcomment_date;
					}
				} else {
					$mmcomment_date="";
				}
				$len=0;
				$len = length $ddcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddcomment_date="0"."$ddcomment_date";
					} else {
						$ddcomment_date=$ddcomment_date;
					}
				} else {
					$ddcomment_date="";
				}
				if ($comment_date ne "") {
					$ncomment_date="$yycomment_date"."$mmcomment_date"."$ddcomment_date";
				} else {
					$ncomment_date="";
				}			
			}
			$sth_getmaxstatusdate = $dbh->prepare("SELECT statusDate,DATE_PART('year',statusDate),DATE_PART('month',statusDate),DATE_PART('day',statusDate) from reviewerStatus where IDNo=$Idno and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$Idno)");
			
			if (!defined $sth_getmaxstatusdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxstatusdate->execute;
			while ($getmaxstatusdate = $sth_getmaxstatusdate->fetch) {
				$status_date=$getmaxstatusdate->[0];
				$yystatus_date=$getmaxstatusdate->[1];
				$mmstatus_date=$getmaxstatusdate->[2];
				$ddstatus_date=$getmaxstatusdate->[3];
				$len=0;
				$len = length $mmstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmstatus_date="0"."$mmstatus_date";
					} else {
						$mmstatus_date=$mmstatus_date;
					}
				} else {
					$mmstatus_date="";
				}
				$len=0;
				$len = length $ddstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddstatus_date="0"."$ddstatus_date";
					} else {
						$ddstatus_date=$ddstatus_date;
					}
				} else {
					$ddstatus_date="";
				}
				if ($status_date ne "") {
					$nstatus_date="$yystatus_date"."$mmstatus_date"."$ddstatus_date";
				} else {
					$nstatus_date="";
				}				
			}
			$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
			if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxentrydate->execute;
			while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
				$entry_date=$getmaxentrydate->[0];
				$yyentry_date=$getmaxentrydate->[1];
				$mmentry_date=$getmaxentrydate->[2];
				$ddentry_date=$getmaxentrydate->[3];
				$len=0;
				$len = length $mmentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmentry_date="0"."$mmentry_date";
					} else {
						$mmentry_date=$mmentry_date;
					}
				} else {
					$mmentry_date="";
				}
				$len=0;
				$len = length $ddentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddentry_date="0"."$ddentry_date";
					} else {
						$ddentry_date=$ddentry_date;
					}
				} else {
					$ddentry_date="";
				}
				if ($entry_date ne "") {
					$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
				} else {
					$nentry_date="";
				}			
			}
			if ($ncomment_date eq "") {
				$ncomment_date=$nentry_date;
			}
			if ($nstatus_date eq "") {
				$nstatus_date =$nentry_date;
			}
			if ($ncomment_date > $nentry_date) {
				$update_date=$ncomment_date;
				if ($nstatus_date > $update_date) {
					$update_date=$nstatus_date;
				}
				
			} elsif ($nstatus_date > $nentry_date) {
				$update_date=$nstatus_date;
				if ($ncomment_date > $update_date) {
					$update_date=$ncomment_date;
				}
			} else {
				$update_date=$nentry_date;
			}					
			$upy = substr($update_date,0,4);
			$upm = substr($update_date,4,2);
			$upd = substr($update_date,6,2);
			$nupdate_date="$upy"."-"."$upm"."-"."$upd";
			$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";
			$sth_gets = $dbh->prepare("SELECT distinct IDNo,site from facilities where IDNo=$Idno");
			if (!defined $sth_gets) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_gets->execute;
			while ($gets = $sth_gets->fetch) {
				$chksite = uc $gets->[1];
			}
			$sth_checksite = $dbh->prepare("SELECT distinct upper(site_code),site_name from $archivedb.$siteinfotab where upper(site_code)='$chksite'");
			if (!defined $sth_checksite) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_checksite->execute;
			while ($checksite = $sth_checksite->fetch) {
				$chksite=$checksite->[0];
				$site_name=$checksite->[1];
				$inarch = 1;
			}
			if ($site_name eq "") {
				$sth_checksite = $dbh->prepare("SELECT distinct IDNo,site,site_name from sites where site='$chksite'");
				if (!defined $sth_checksite) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checksite->execute;
				while ($checksite = $sth_checksite->fetch) {
					$chksite=$checksite->[1];
					$site_name=$checksite->[2];
				}
			}
			$submitter="";
			$sth_getsubm = $dbh->prepare("SELECT distinct $peopletab.name_first,$peopletab.name_last from facilities,$peopletab WHERE facilities.submitter=$peopletab.person_id AND facilities.IDNo=$Idno");
			if (!defined $sth_getsubm) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getsubm->execute;
			while ($getsubm = $sth_getsubm->fetch) {
				$submitter="$getsubm->[0]"." $getsubm->[1]";
			}
			print "<tr>";
			print "<td>$entry_date</td><td>$nupdate_date</td><td>$submitter</td>";
			if ($inarch == 1) {
				print "<td>$chksite: $site_name</td>\n";
			} else {
				print "<td><font color=red><strong>$chksite: $site_name</strong></font></td>\n";
			}
			$facility_code="";
			$facility_name="";
			$start_date="";
			$end_date="";
			$styr="";
			$stmn="";
			$stdy="";
			$fmstdate="";
			$endyr="";
			$endmn="";
			$enddy="";
			$fmenddate="";
			$reformatstdate="";
			$reformatenddate="";
			$facno=0;
			$printfac="";
			$printfmst="";
			$printfmend="";
			$statflag="";
			$sth_getfac = $dbh->prepare("SELECT IDNo,facility_code,facility_name,eff_date,end_date,DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date),statusFlag from facilities WHERE facilities.IDNo=$Idno order by facility_code");
			if (!defined $sth_getfac) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getfac->execute;
			while ($getfac = $sth_getfac->fetch) {
				$exist=0;
				$checkstatthisone=0;
				$facility_code=$getfac->[1];
				$facility_name=$getfac->[2];
				$start_date=$getfac->[3];
				$end_date=$getfac->[4];
				$styr=$getfac->[5];
				$stmn=$getfac->[6];
				$stdy=$getfac->[7];
				$endyr=$getfac->[8];	
				$endmn=$getfac->[9];
				$enddy=$getfac->[10];
				$statflag=$getfac->[11];
				$len=0;
				$len=length $stmn;
				if ($len < 2) {
					$stmn="0"."$stmn";
				}
				$len=0;
				$len=length $stdy;
				if ($len < 2) {
					$stdy="0"."$stdy";
				}
				if ($styr ne "") {
					$fmstdate="$stmn"."/"."$stdy"."/"."$styr";
					$reformatstdate="$styr"."-"."$stmn"."-"."$stdy";
				} else {
					$fmstdate="---------------";
					$reformatstdate="---------------";
				}
				if ($endyr ne "") {
					$len=0;
					$len=length $endmn;
					if ($len < 2) {
						$endmn="0"."$endmn";
					}
					$len=0;
					$len=length $enddy;
					if ($len < 2) {
						$enddy="0"."$enddy";
					}
					$fmenddate="$endmn"."/"."$enddy"."/"."$endyr";
					$reformatenddate="$endyr"."-"."$endmn"."-"."$enddy";
				} else {
					$fmenddate="---------------";
					$reformatenddate="---------------";
				}
				if ($facno == 0) {
					if ($statflag == 0) {
						$printfac="<font color=red><strong>$facility_code: $facility_name</strong></font>";
						$printfmst="$reformatstdate";
						$printfmend="$reformatenddate";
						$exist=0;
					} else {
						$ca=0;
						$sth_chka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code' and facility_name='$facility_name'");
						if (!defined $sth_chka) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_chka->execute;
						while ($chka = $sth_chka->fetch) {
							$ca=$chka->[0];
						}
						if ($ca == 0) {
							$cb = 0;
							$sth_checkb = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code'");
							if (!defined $sth_checkb) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_checkb->execute;
							while ($checkb = $sth_checkb->fetch) {
								$cb=$checkb->[0];
							}
							if ($cb == 0) {
								$printfac="$facility_code: $facility_name <strong><font color=red>*</font></strong>";
							} else {
								$printfac="<font color=blue><strong>$facility_code: $facility_name </font><font color=red>*</font></strong>";
							}
							$countstar=$countstar+1;
							$checkstatthisone = $checkstatthisone + 1;
						} else {
							$printfac="<font color=blue><strong>$facility_code: $facility_name</strong></font>";
							$exist=1;
						}
						$ca=0;
						
						$sth_chka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code' and eff_date='$fmstdate'");
						
						if (!defined $sth_chka) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_chka->execute;
						while ($chka = $sth_chka->fetch) {
							$ca=$chka->[0];
						}
						if ($ca == 0) {
							$fsy="";
							$fsm="";
							$fsd="";
							$fstart="";
							$sth_doublecheck=$dbh->prepare("SELECT DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code'");
							if (!defined $sth_doublecheck) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_doublecheck->execute;
							while ($doublecheck = $sth_doublecheck->fetch) {
								$fsy=$doublecheck->[0];
								$len=0;
								$len = length $doublecheck->[1];
								if ($len < 2) {
									$fsm="0"."$doublecheck->[1]";
								} else {
									$fsm=$doublecheck->[1];
								}
								$len=0;
								$len = length $doublecheck->[2];
								if ($len < 2) {
									$fsd="0"."$doublecheck->[2]";
								} else {
									$fsd=$doublecheck->[2];
								}
							}
							$fstart="$fsm"."/"."$fsd"."/"."$fsy";
							if ($fmstdate ne $fstart) {
								$printfmst="$reformatstdate <strong><font color=red>*</font></strong>";
								$countstar=$countstar+1;
								$checkstatthisone = $checkstatthisone + 1;
							}
						} else {
							$printfmst="$reformatstdate";
						}
						$ca=0;
						$sth_chka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code' and end_date='$fmenddate'");
						if (!defined $sth_chka) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_chka->execute;
						while ($chka = $sth_chka->fetch) {
							$ca=$chka->[0];
						}
						if ($ca == 0) {
							$fey="";
							$fem="";
							$fed="";
							$fend="";
							$sth_doublecheck=$dbh->prepare("SELECT DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code'");
							if (!defined $sth_doublecheck) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_doublecheck->execute;
							while ($doublecheck = $sth_doublecheck->fetch) {
								$fey=$doublecheck->[0];
								$len=0;
								$len = length $doublecheck->[1];
								if ($len < 2) {
									$fem="0"."$doublecheck->[1]";
								} else {
									$fem=$doublecheck->[1];
								}
								$len=0;
								$len = length $doublecheck->[2];
								if ($len < 2) {
									$fed="0"."$doublecheck->[2]";
								} else {
									$fed=$doublecheck->[2];
								}
								$fend="$fem"."/"."$fed"."/"."$fey";
							}
							if ($fmenddate ne $fend) {
								$printfmend="$reformatenddate <strong><font color=red>*</font></strong>";
								$countstar=$countstar+1;
								$checkstatthisone = $checkstatthisone + 1;
							} else {
								$printfmend="$reformatenddate";
							}
						} else {
							$printfmend="$reformatenddate";
						}
					}
				} else {
					if ($statflag == 0) {	
						$printfac="$printfac"."<br>"."<font color=red><strong>$facility_code: $facility_name</strong></font>";
						$printfmst="$printfmst"."<br>"."$reformatstdate";
						$printfmend="$printfmend"."<br>"."$reformatenddate";
						$exist=0;
					} else {
						$ca=0;	
						$sth_chka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code' and facility_name='$facility_name'");
						if (!defined $sth_chka) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_chka->execute;
						while ($chka = $sth_chka->fetch) {
							$ca=$chka->[0];
						}
						if ($ca == 0) {
							$cb = 0;
							$sth_checkb = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code'");
							if (!defined $sth_checkb) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_checkb->execute;
							while ($checkb = $sth_checkb->fetch) {
								$cb=$checkb->[0];
							}
							if ($cb == 0) {
								$printfac="$printfac"."<br>"."<font color=red><strong>$facility_code: $facility_name <strong></font></strong>";
							} else {
								$printfac="$printfac"."<br>"."<font color=blue><strong>$facility_code: $facility_name </font><font color=red>*</font></strong>";
							}
							$countstar=$countstar+1;
							$checkstatthisone = $checkstatthisone + 1;
						} else {
							$printfac="$printfac"."<br>"."<font color=blue><strong>$facility_code: $facility_name</strong></font>";
							$exist=1;
						}
						$ca=0;
						$sth_chka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code' and eff_date='$fmstdate'");
						if (!defined $sth_chka) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_chka->execute;
						while ($chka = $sth_chka->fetch) {
							$ca=$chka->[0];
						}
						if ($ca == 0) {
							$fsy="";
							$fsm="";
							$fsd="";
							$fstart="";
							$sth_doublecheck=$dbh->prepare("SELECT DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code'");
							if (!defined $sth_doublecheck) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_doublecheck->execute;
							while ($doublecheck = $sth_doublecheck->fetch) {
								$fsy=$doublecheck->[0];
								$len=0;
								$len = length $doublecheck->[1];
								if ($len < 2) {
									$fsm="0"."$doublecheck->[1]";
								} else {
									$fsm=$doublecheck->[1];
								}
								$len=0;
								$len = length $doublecheck->[2];
								if ($len < 2) {
									$fsd="0"."$doublecheck->[2]";
								} else {
									$fsd=$doublecheck->[2];
								}
								$fstart="$fsm"."/"."$fsd"."/"."$fsy";
							}
							if ($fmstdate ne $fstart) {	
								$printfmst="$printfmst"."<br>"."$reformatstdate<font color=red><strong>*</font></strong>";
								$countstar=$countstar+1;
								$checkstatthisone = $checkstatthisone + 1;
							} else {
								$printfmst="$printfmst"."<br>"."$reformatstdate";
							}
						} else {
							$printfmst="$printfmst"."<br>"."$reformatstdate";
						}
						$ca=0;
						$sth_chka = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code' and end_date='$fmenddate'");
						if (!defined $sth_chka) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_chka->execute;
						while ($chka = $sth_chka->fetch) {
							$ca=$chka->[0];
						}
						if ($ca == 0) {
							$fey="";
							$fem="";
							$fed="";
							$fend="";
							$sth_doublecheck=$dbh->prepare("SELECT DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from $archivedb.$facinfotab where upper(site_code)='$chksite' and facility_code='$facility_code'");
							if (!defined $sth_doublecheck) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_doublecheck->execute;
							while ($doublecheck = $sth_doublecheck->fetch) {
								$fey=$doublecheck->[0];
								$len=0;
								$len = length $doublecheck->[1];
								if ($len < 2) {
									$fem="0"."$doublecheck->[1]";
								} else {
									$fem=$doublecheck->[1];
								}
								$len=0;
								$len = length $doublecheck->[2];
								if ($len < 2) {
									$fed="0"."$doublecheck->[2]";
								} else {
									$fed=$doublecheck->[2];
								}
								$fend="$fem"."/"."$fed"."/"."$fey";
							}
							if ($fmenddate ne $fend) {
								$printfmend="$printfmend"."<br>"."$reformatenddate <strong><font color=red>*</font></strong>";
								$countstar=$countstar+1;
								$checkstatthisone = $checkstatthisone + 1;
							} else {
								$printfmend="$printfmend"."<br>"."$reformatenddate";
							}

						} else {
							$printfmend="$printfmend"."<br>"."$reformatenddate";
						}
					}
				}
				$facno = $facno + 1;								
			}
			$printfac="$printfac"."<br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
			$REVstatdesc="";
			$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
			if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getstatdesc->execute;
			while ($getstatdesc = $sth_getstatdesc->fetch) {
				$REVstatdesc=$getstatdesc->[1];
			}
			$DBstatdesc="";
			$sth_getDBstatdesc=$dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");
			if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getDBstatdesc->execute;
			while ($getDBstatdesc = $sth_getDBstatdesc->fetch) {
				$DBstatdesc=$getDBstatdesc->[1];
			}
			$fontcolor="black";
			$dbfontcolor="black";
			if ($REVstat == 0) {
				$fontcolor="red";
			}
			if ($REVstat == 1) {
				$fontcolor="green";
			}
			if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
				$dbfontcolor="blue";
			}
			$numofcomments=0;
			$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
			if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_countcomments->execute;
			while ($countcomments = $sth_countcomments->fetch) {
				$numofcomments = $countcomments->[0];
			}
			print "<td>$printfac";
			if ($numofcomments > 0) {
				print " <small><font color=green><strong>(c)</strong></font></small>";
			}
			print "</td><td>$printfmst</td><td>$printfmend</td><td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";
			print "<td><font color=$dbfontcolor><strong>$DBstatdesc</strong></font></td>\n";
			print "</tr>\n";
		}
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE Facility = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED Facility (or Site) = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
################################################################################
# subroutine to display instrument class objects summary
################################################################################
sub displayinstclass 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      	
	my $IDNo = shift;
	my $sortby = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	$sortable=0;
	if ($IDNo eq "") {
		$sortable=1;
	}
	if ($sortable == 0) {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=11 align=center><strong><font color=blue>Instrument Class</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%>Submit Date</th><th width=10%>Latest Update</th><th width=10%>Submitter</th><th width=15%><font color=blue>Instrument Class</font></th><th width=15%>Instrument Class Name</th><th width=20%>Contact</th><th width=20%>Web Page Description</th><th width=20%>Instrument Categories</th><th width=10%>Source Classes</th><th>Review Status</th>\n";
		print "<th>DB (ARM_int) Status</th>\n";
		print "</tr>";
	} else {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";	
		print "<th colspan=11 align=center><strong><font color=blue>Instrument Class</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=I&sortby=entry_date\" style=\"text-decoration: none; color:black\">Submit Date</a></th><th width=10%>Latest Update</th><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=I&sortby=submitter\" style=\"text-decoration: none; color:black\">Submitter</a></th><th width=10%><font color=\"green\"><strong>+ </strong></font><font color=blue><a href=\"MMTMetaData.pl?type=I&sortby=instrument\" style=\"text-decoration: none;color: blue\">Instrument Class</a></font></th><th width=15%>Instrument Class Name</th><th width=20%>Contact</th><th width=20%>Web Page Description</th><th width=20%>Instrument Categories</th><th width=10%>Source Classes</th><th><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=I&sortby=rstatus\" style=\"text-decoration: none; color: black\">Review Status</a></th>\n";
		print "<th><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=I&sortby=dbstatus\" style=\"text-decoration: none\">DB (ARM_int) Status</a></th>\n";
		print "</tr>";		
	}
	$countminus=0;
	$countstar=0;
	if ($IDNo eq "") {
		if ($sortby eq "") {
			$sth_getIDs = $dbh->prepare("SELECT distinct instClass.IDNo,type,revStatus,DBstatus,entry_date from instClass,IDs where instClass.IDNo=IDs.IDNo and type='I' order by instClass.IDNo desc");
		} else {
			if ($sortby eq "submitter") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instClass.IDNo,type,revStatus,DBstatus,entry_date from instClass,IDs,$peopletab where instClass.IDNo=IDs.IDNo and instClass.submitter=$peopletab.person_id and type='I' order by name_last,instClass.IDNo");
			
			} elsif ($sortby eq "instrument") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instClass.IDNo,type,revStatus,DBstatus,entry_date from instClass,IDs where instClass.IDNo=IDs.IDNo and type='I' order by instClass.instrument_class");		
			} elsif ($sortby eq "rstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instClass.IDNo,type,revStatus,DBstatus,entry_date from instClass,IDs where instClass.IDNo=IDs.IDNo and type='I' order by IDs.revStatus,instClass.IDNo");
			} elsif ($sortby eq "dbstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instClass.IDNo,type,revStatus,DBstatus,entry_date from instClass,IDs where instClass.IDNo=IDs.IDNo and type='I' order by IDs.DBstatus,instClass.IDNo");
			} elsif ($sortby eq "entry_date") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instClass.IDNo,type,revStatus,DBstatus,entry_date from instClass,IDs where instClass.IDNo=IDs.IDNo and type='I' order by IDs.entry_date desc,instClass.IDNo");			
			}			
		}				
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$Idno = $getIDs->[0];
		$skip=0;
		$sth_checkds = $dbh->prepare("SELECT count(*),count(*) from DS where IDNo=$Idno");
		if (!defined $sth_checkds) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checkds->execute;
		while ($checkds = $sth_checkds->fetch) {
			$skip=$checkds->[0];
		}		
		if ($skip == 0) {
			$DBstat=$getIDs->[3];
			$REVstat=$getIDs->[2];
			$entry_date=$getIDs->[4];
			@tmp=();
			@tmp=split(/ /,$entry_date);
			$entry_date=$tmp[0];
			$class="";
			$class_name="";
			$submitter="";
			$comment_date="";
			$status_date="";
			$yycomment_date="";
			$mmcomment_date="";
			$ddcomment_date="";
			$yystatus_date="";
			$mmstatus_date="";
			$ddstatus_date="";
			$yyentry_date="";
			$mmentry_date="";
			$ddentry_date="";
			$ncomment_date="";
			$nstatus_date="";
			$sth_getmaxcommentdate = $dbh->prepare("SELECT commentDate,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate) from comments where IDNo=$Idno and commentDate=(SELECT max(commentDate) from comments where IDNo=$Idno)");
			if (!defined $sth_getmaxcommentdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxcommentdate->execute;
			while ($getmaxcommentdate = $sth_getmaxcommentdate->fetch) {
				$comment_date=$getmaxcommentdate->[0];
				$yycomment_date=$getmaxcommentdate->[1];
				$mmcomment_date=$getmaxcommentdate->[2];
				$ddcomment_date=$getmaxcommentdate->[3];
				$len=0;
				$len = length $mmcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmcomment_date="0"."$mmcomment_date";
					} else {
						$mmcomment_date=$mmcomment_date;
					}
				} else {
					$mmcomment_date="";
				}
				$len=0;
				$len = length $ddcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddcomment_date="0"."$ddcomment_date";
					} else {
						$ddcomment_date=$ddcomment_date;
					}
				} else {
					$ddcomment_date="";
				}
				if ($comment_date ne "") {
					$ncomment_date="$yycomment_date"."$mmcomment_date"."$ddcomment_date";
				} else {
					$ncomment_date="";
				}			
			}
			$sth_getmaxstatusdate = $dbh->prepare("SELECT statusDate,DATE_PART('year',statusDate),DATE_PART('month',statusDate),DATE_PART('day',statusDate) from reviewerStatus where IDNo=$Idno and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$Idno)");
			if (!defined $sth_getmaxstatusdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxstatusdate->execute;
			while ($getmaxstatusdate = $sth_getmaxstatusdate->fetch) {
				$status_date=$getmaxstatusdate->[0];
				$yystatus_date=$getmaxstatusdate->[1];
				$mmstatus_date=$getmaxstatusdate->[2];
				$ddstatus_date=$getmaxstatusdate->[3];
				$len=0;
				$len = length $mmstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmstatus_date="0"."$mmstatus_date";
					} else {
						$mmstatus_date=$mmstatus_date;
					}
				} else {
					$mmstatus_date="";
				}
				$len=0;
				$len = length $ddstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddstatus_date="0"."$ddstatus_date";
					} else {
						$ddstatus_date=$ddstatus_date;
					}
				} else {
					$ddstatus_date="";
				}
				if ($status_date ne "") {
					$nstatus_date="$yystatus_date"."$mmstatus_date"."$ddstatus_date";
				} else {
					$nstatus_date="";
				}				
			}
			$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
			if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxentrydate->execute;
			while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
				$entry_date=$getmaxentrydate->[0];
				$yyentry_date=$getmaxentrydate->[1];
				$mmentry_date=$getmaxentrydate->[2];
				$ddentry_date=$getmaxentrydate->[3];
				$len=0;
				$len = length $mmentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmentry_date="0"."$mmentry_date";
					} else {
						$mmentry_date=$mmentry_date;
					}
				} else {
					$mmentry_date="";
				}
				$len=0;
				$len = length $ddentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddentry_date="0"."$ddentry_date";
					} else {
						$ddentry_date=$ddentry_date;
					}
				} else {
					$ddentry_date="";
				}
				if ($entry_date ne "") {
					$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
				} else {
					$nentry_date="";
				}				
			}
			if ($ncomment_date eq "") {
				$ncomment_date=$nentry_date;
			}
			if ($nstatus_date eq "") {
				$nstatus_date =$nentry_date;
			}
			if ($ncomment_date > $nentry_date) {
				$update_date=$ncomment_date;
				if ($nstatus_date > $update_date) {
					$update_date=$nstatus_date;
				}
				
			} elsif ($nstatus_date > $nentry_date) {
				$update_date=$nstatus_date;
				if ($ncomment_date > $update_date) {
					$update_date=$ncomment_date;
				}
			} else {
				$update_date=$nentry_date;
			}
			
			
			$upy = substr($update_date,0,4);
			$upm = substr($update_date,4,2);
			$upd = substr($update_date,6,2);
			$nupdate_date="$upy"."-"."$upm"."-"."$upd";
			$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";					
			print "<tr>\n";
			$sth_getclasses = $dbh->prepare("SELECT distinct IDNo,instrument_class,instrument_class_name,$peopletab.name_last,$peopletab.name_first from instClass,$peopletab WHERE instClass.submitter=$peopletab.person_id AND instClass.IDNo=$Idno");
			if (!defined $sth_getclasses) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getclasses->execute;
			while ($getclasses = $sth_getclasses->fetch) {
				$checkstatthisone=0;
				$class=$getclasses->[1];
				$class_name=$getclasses->[2];
				$webblurb="";
				$sth_getblurb = $dbh->prepare("SELECT IDNo,instPageDesc from instWebPageBlurb where IDNo=$Idno");
				if (!defined $sth_getblurb) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getblurb->execute;
				while ($getblurb = $sth_getblurb->fetch) {
					$webblurb=$getblurb->[1];
				}
				$sth_checkclassname = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclassdetailstab where instrument_class_code='$class' and instrument_class_name='$class_name'");
				if (!defined $sth_checkclassname) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkclassname->execute;
				while ($checkclassname = $sth_checkclassname->fetch) {
					if (($checkclassname->[0] == 0) && ($DBstat != 0)) {
						$class_name="$getclasses->[2]"." <font color=red>*</font>";
						$countstar=$countstar + 1;
						$checkstatthisone = $checkstatthisone + 1;
					}
				}
				$submitter="$getclasses->[4]"." "."$getclasses->[3]";
				$catlist="";
				$totcat=0;
				$sth_countcat = $dbh->prepare("SELECT count(*),count(*) from instCats where IDNo=$Idno");
				if (!defined $sth_countcat) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countcat->execute;
				while ($countcat = $sth_countcat->fetch) {
					$totcat = $countcat->[0];
				}
				if ($totcat > 0) {
					$cno=0;
					$sth_getcats = $dbh->prepare("SELECT instCats.inst_category_code,statusFlag from instCats where IDNo=$Idno");
					if (!defined $sth_getcats) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getcats->execute;
					while ($getcats = $sth_getcats->fetch) {
						$inarch=0;
						$sth_checkarch = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$class' and instrument_category_code='$getcats->[0]'");
						if (!defined $sth_checkarch) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkarch->execute;
						while ($checkarch = $sth_checkarch->fetch) {
							$inarch = $checkarch->[0];
						}
						if ($cno == 0) {
							if ($inarch > 0) {
								$catname="";
								$sth_getcatname=$dbh->prepare("SELECT instrument_category_code,instrument_category_name from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getcats->[0]'");
								if (!defined $sth_getcatname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getcatname->execute;
								while ($getcatname = $sth_getcatname->fetch) {
									$catname="$getcatname->[1]";
								}
								$catlist="$getcats->[0] ($catname)";
							} else {
								$catname="";
								$sth_getcatname=$dbh->prepare("SELECT instrument_category_code,instrument_category_name from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getcats->[0]'");
								if (!defined $sth_getcatname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getcatname->execute;
								while ($getcatname = $sth_getcatname->fetch) {
									$catname="$getcatname->[1]";
								}
								if ((($DBstat == -1 ) ||  ($DBstat == 1)) && ($getcats->[1] == 0)) {
									$catlist="$getcats->[0] ($catname) <font color=red>*</font>";
									$countstar = $countstar + 1;
									$checkstatthisone = $checkstatthisone + 1;
								} else {
									$catlist="$getcats->[0] ($catname)";
								}
							}
						} else {
							if ($inarch > 0) {
								$catname="";
								$sth_getcatname=$dbh->prepare("SELECT instrument_category_code,instrument_category_name from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getcats->[0]'");
								if (!defined $sth_getcatname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getcatname->execute;
								while ($getcatname = $sth_getcatname->fetch) {
									$catname="$getcatname->[1]";
								}
								$catlist= "$catlist"."<br>"."$getcats->[0] ($catname)";
							} else {
							
								$catname="";
								$sth_getcatname=$dbh->prepare("SELECT instrument_category_code,instrument_category_name from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getcats->[0]'");
								if (!defined $sth_getcatname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getcatname->execute;
								while ($getcatname = $sth_getcatname->fetch) {
									$catname="$getcatname->[1]";
								}
								if ((($DBstat == -1 ) ||  ($DBstat == 1)) && ($getcats->[1]== 0)) {
									$catlist= "$catlist"."<br>"."$getcats->[0] ($catname)<font color=red>*</font>";
									$countstar = $countstar + 1;
									$checkstatthisone = $checkstatthisone + 1;
								} else {
									$catlist= "$catlist"."<br>"."$getcats->[0] ($catname)";
								}
							}
						}
						$cno = $cno + 1;
					}
					$sth_getarch = $dbh->prepare("SELECT instrument_category_code,instrument_class_code from $archivedb.$instrclasstoinstrcattab where instrument_class_code='$class'");
					if (!defined $sth_getarch) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getarch->execute;
					while ($getarch = $sth_getarch->fetch) {
						$inmmt=0;
						$sth_checkmmt = $dbh->prepare("SELECT count(*),count(*) from instCats WHERE inst_category_code='$getarch->[0]' and IDNo=$Idno");
						if (!defined $sth_checkmmt) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkmmt->execute;
						while ($checkmmt = $sth_checkmmt->fetch) {
							$inmmt = $checkmmt->[0];
						}
						if ($cno == 0) {
							if ($inmmt == 0) {
								$catname="";
								$sth_getcatname=$dbh->prepare("SELECT instrument_category_code,instrument_category_name from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getarch->[0]'");
								if (!defined $sth_getcatname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getcatname->execute;
								while ($getcatname = $sth_getcatname->fetch) {
									$catname="$getcatname->[1]";
								}	
								$catlist="<font color=red>$getarch->[0] ($catname) <strong>\-</font></strong>";
								$countminus = $countminus + 1;
								$checkstatthisone = $checkstatthisone + 1;
							}
						} else {
							if ($inmmt == 0) {
								$catname="";
								$sth_getcatname=$dbh->prepare("SELECT instrument_category_code,instrument_category_name from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getarch->[0]'");
								if (!defined $sth_getcatname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getcatname->execute;
								while ($getcatname = $sth_getcatname->fetch) {
									$catname="$getcatname->[1]";
								}
								$catlist= "$catlist"."<br>"."<font color=red>$getarch->[0] ($catname) <strong>\-</font></strong>";
								$countminus = $countminus + 1;
								$checkstatthisone = $checkstatthisone + 1;	
							}
						}
						$cno = $cno + 1;
					}		
				}
				$sourcelist="";
				$totsource=0;
				$sth_countsource = $dbh->prepare("SELECT count(*),count(*) from sourceClass where IDNo=$Idno");
				if (!defined $sth_countsource) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countsource->execute;
				while ($countsource = $sth_countsource->fetch) {
					$totsource = $countsource->[0];
				}
				if ($totsource > 0) {
					$sno=0;
					$sth_getsources = $dbh->prepare("SELECT source_class,statusFlag from sourceClass where IDNo=$Idno");
					if (!defined $sth_getsources) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getsources->execute;
					while ($getsources = $sth_getsources->fetch) {
						$inarch=0;
						$sth_checkarch = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclasstosourceclass WHERE instrument_class_code='$class' and source_class_code='$getsources->[0]'");
						if (!defined $sth_checkarch) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkarch->execute;
						while ($checkarch = $sth_checkarch->fetch) {
							$inarch = $checkarch->[0];
						}
						if ($sno == 0) {
							if ($inarch > 0) {
								$sourcelist="$getsources->[0]";
							} else {
								if ((($DBstat == -1 ) ||  ($DBstat == 1)) && ($getcats->[1] == 0)) {
								
									$sourcelist="$getsources->[0] <font color=red>*</font>";
									$countstar = $countstar + 1;
									$checkstatthisone = $checkstatthisone + 1;
								} else {
									$sourcelist="$getsources->[0]";
								}
							}
						} else {
							if ($inarch > 0) {
								$sourcelist= "$sourcelist"."<br>"."$getsources->[0]";
							} else {
								if ((($DBstat == -1 ) ||  ($DBstat == 1)) && ($getcats->[1]== 0)) {
									$sourcelist= "$sourcelist"."<br>"."$getsources->[0] <font color=red>*</font>";
									$countstar = $countstar + 1;
									$checkstatthisone = $checkstatthisone + 1;
								} else {
									$sourcelist= "$sourcelist"."<br>"."$getsources->[0]";
								}
							}
						}
						$sno = $sno + 1;
					}
					$sth_getarch = $dbh->prepare("SELECT source_class_code,instrument_class_code from $archivedb.$instrclasstosourceclass where instrument_class_code='$class'");
					if (!defined $sth_getarch) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getarch->execute;
					while ($getarch = $sth_getarch->fetch) {
						$inmmt=0;
						$sth_checkmmt = $dbh->prepare("SELECT count(*),count(*) from sourceClass WHERE source_class='$getarch->[0]' and IDNo=$Idno");
						if (!defined $sth_checkmmt) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkmmt->execute;
						while ($checkmmt = $sth_checkmmt->fetch) {
							$inmmt = $checkmmt->[0];
						}
						if ($sno == 0) {
							if ($inmmt == 0) {
								$sourcelist="<font color=red>$getarch->[0] <strong>\-</font></strong>";
								$countminus = $countminus + 1;
								$checkstatthisone = $checkstatthisone + 1;
							}
						} else {
							if ($inmmt == 0) {
								$sourcelist= "$sourcelist"."<br>"."<font color=red>$getarch->[0] <strong>-</font></strong>";
								$countminus = $countminus + 1;
								$checkstatthisone = $checkstatthisone + 1;
								
							}
						}
						$sno = $sno + 1;
					}											
				}
				$countmnt=0;
				$mentorlist="";
				$sth_getmentors = $dbh->prepare("SELECT distinct $grouprole.person_id,name_first,name_last,$grouprole.group_name,$grouprole.role_name,$grouprole.subrole_name from $grouprole,$peopletab WHERE $grouprole.person_id=$peopletab.person_id and $grouprole.role_name=upper('$class') and $grouprole.group_name not like '%Reminder%'");
				if (!defined $sth_getmentors) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getmentors->execute;
				while ($getmentors = $sth_getmentors->fetch) {
					if ($countmnt == 0) {
						$mentorlist = "$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5]";
					} else {
						$mentorlist = "$mentorlist"."<br>"."$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5]";
					}
					$countmnt = $countmnt + 1;
				}
				$sth_getmentors = $dbh->prepare("SELECT distinct instContacts.contact_id,name_first,name_last,instContacts.group_name,instContacts.role_name,instContacts.subrole_name from instContacts,$peopletab WHERE instContacts.role_name=upper('$class') and instContacts.contact_id=$peopletab.person_id AND instContacts.contact_id not in (SELECT distinct person_id from $grouprole where $grouprole.role_name=upper('$class'))");
				if (!defined $sth_getmentors) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getmentors->execute;
				while ($getmentors = $sth_getmentors->fetch) {
					if ($countmnt == 0) {
						$mentorlist = "$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5] <font color=red><strong>*</strong></font>";
					} else {
						$mentorlist = "$mentorlist"."<br>"."$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5] <font color=red><strong>*</strong></font>";
					}
					$countmnt = $countmnt + 1;
				}	
				$REVstatdesc="";
				$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
				if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getstatdesc->execute;
				while ($getstatdesc = $sth_getstatdesc->fetch) {
					$REVstatdesc=$getstatdesc->[1];
				}
				$DBstatdesc="";
				$sth_getDBstatdesc=$dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");
				if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getDBstatdesc->execute;
				while ($getDBstatdesc = $sth_getDBstatdesc->fetch) {
					$DBstatdesc=$getDBstatdesc->[1];
				}
				$fontcolor="black";
				$dbfontcolor="black";
				if ($REVstat == 0) {
					$fontcolor="red";
				}
				if ($REVstat == 1) {
					$fontcolor="green";
				}
				if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
					$dbfontcolor="blue";
				}
				$numofcomments=0;
				$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
				if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countcomments->execute;
				while ($countcomments = $sth_countcomments->fetch) {
					$numofcomments = $countcomments->[0];
				}
				print "<td>$entry_date</td><td>$nupdate_date</td><td>$submitter</td>";
				if ($DBstat == 0) {
					print "<td><strong><font color=red>$class</font></strong><br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					$exist=0;
				} else {
					print "<td><strong><font color=blue>$class</font></strong><br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					$exist=1;
				}
				if ($numofcomments > 0) {
					print " <small><font color=green><strong>(c)</strong></font></small>";
				}
				print "</td>";
				print "<td>$class_name</td>";
				if ($mentorlist ne "") {
					print "<td>$mentorlist</td>";
				} else {
					if (($sourcelist =~ "arm") || ($sourcelist =~ "eval") || ($sourcelist =~ "ext")) {
						print "<td><font color=red><strong>NOT DEFINED YET</strong></font></td>";
					} else {
					
						print "<td>MAY BE DEFINED IN OTHER DOCUMENTATION (OME)</td>";
					}
				}
				print "<td>$webblurb</td>";
				print "<td>$catlist</td><td>$sourcelist</td><td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";		
				print "<td><font color=$dbfontcolor><strong>$DBstatdesc</strong></font></td>\n";
				print "</tr>\n";
			}
		}
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE Instrument Class = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED Instrument Class = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated/added in this review or defined elsewhere</strong></font></small><br>\n";
	}
	if ($countminus > 0) {
		print "<small><font color=red><strong>- = fields being updated/removed in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
################################################################################
# subroutine to display instrument code objects summary - not implemented yet! (5/5/2016)
################################################################################
sub displayinstcode 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	my $IDNo = shift;
	my $sortby = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	$sortable=0;
	if ($IDNo eq "") {
		$sortable=1;
	}
	#print "IDNo $IDNo<br>\n";
	if ($sortable == 0) {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=9 align=center><strong><font color=blue>Instrument Code</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%>Submit Date</th><th width=10%>Latest Update</th><th width=10%>Submitter</th><th width=15%><font color=blue>Instrument Code</font></th><th width=20%>Instrument Code Name</th><th width=10%>Instrument Class</th><th width=15%>Review Status</th>\n";
		print "<th width=15%>DB (ARM_int) Status</th>\n";
		print "</tr>";
	} else {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";	
		print "<th colspan=9 align=center><strong><font color=blue>Instrument Code</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=IC&sortby=entry_date\" style=\"text-decoration: none; color:black\">Submit Date</a></th>\n";
		print "<th width=10%>Latest Update</th>\n";
		print "<th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=IC&sortby=submitter\" style=\"text-decoration: none; color:black\">Submitter</a></th>\n";
		print "<th width=15%><font color=\"green\"><strong>+ </strong></font><font color=blue><a href=\"MMTMetaData.pl?type=IC&sortby=instrument_code\" style=\"text-decoration: none;color: blue\">Instrument Code</a></font></th>\n";
		print "<th width=20%>Instrument Code Name</th>\n";
		print "<th width=10%>Instrument Class</th><th width=15%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=IC&sortby=rstatus\" style=\"text-decoration: none; color: black\">Review Status</a></th>\n";
		print "<th width=15%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=IC&sortby=dbstatus\" style=\"text-decoration: none\">DB (ARM_int) Status</a></th>\n";
		print "</tr>";		
	}
	$countminus=0;
	$countstar=0;
	if ($IDNo eq "") {
		if ($sortby eq "") {
			$sth_getIDs = $dbh->prepare("SELECT distinct instCodes.IDNo,type,revStatus,DBstatus,entry_date from instCodes,IDs where instCodes.IDNo=IDs.IDNo and type='IC' order by instCodes.IDNo desc");			
		} else {
			if ($sortby eq "submitter") {			
				$sth_getIDs = $dbh->prepare("SELECT distinct instCodes.IDNo,type,revStatus,DBstatus,entry_date from instCodes,IDs,$peopletab where instCodes.IDNo=IDs.IDNo and instCodes.submitter=$peopletab.person_id and type='IC' order by name_last,instCodes.IDNo");			
			} elsif ($sortby eq "instrument_code") {				
				$sth_getIDs = $dbh->prepare("SELECT distinct instCodes.IDNo,type,revStatus,DBstatus,entry_date from instCodes,IDs,$peopletab where instCodes.IDNo=IDs.IDNo and instCodes.submitter=$peopletab.person_id and type='IC' order by instCodes.instrument_code");		
			} elsif ($sortby eq "rstatus") {				
				$sth_getIDs = $dbh->prepare("SELECT distinct instCodes.IDNo,type,revStatus,DBstatus,entry_date from instCodes,IDs,$peopletab where instCodes.IDNo=IDs.IDNo and instCodes.submitter=$peopletab.person_id and type='IC' order by IDs.revStatus,instCodes.IDNo");
			} elsif ($sortby eq "dbstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instCodes.IDNo,type,revStatus,DBstatus,entry_date from instCodes,IDs,$peopletab where instCodes.IDNo=IDs.IDNo and instCodes.submitter=$peopletab.person_id and type='IC' order by IDs.DBstatus,instCodes.IDNo");
			} elsif ($sortby eq "entry_date") {
				$sth_getIDs = $dbh->prepare("SELECT distinct instCodes.IDNo,type,revStatus,DBstatus,entry_date from instCodes,IDs,$peopletab where instCodes.IDNo=IDs.IDNo and instCodes.submitter=$peopletab.person_id and type='IC' order by IDs.entry_date desc,instCodes.IDNo");			
			}
		}				
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDs.IDNo,IDs.type,IDs.revStatus,IDs.DBstatus,IDs.entry_date from IDs,instCodes,$peopletab where instCodes.IDNo=IDs.IDNo and instCodes.submitter=$peopletab.person_id and IDs.IDNo=$IDNo");
	}
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$Idno = $getIDs->[0];
		$entry_date=$getIDs->[4];
		$skip=0;
		$sth_checkds = $dbh->prepare("SELECT count(*) from DS where IDNo=$Idno");
		if (!defined $sth_checkds) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checkds->execute;
		while ($checkds = $sth_checkds->fetch) {
			$skip=$checkds->[0];
		}
		#print "Idno $Idno, skip $skip<br>\n";
		#exit;
		if ($skip == 0) {
			$DBstat=$getIDs->[3];
			$REVstat=$getIDs->[2];
			$entry_date=$getIDs->[4];
			@tmp=();
			@tmp=split(/ /,$entry_date);
			$entry_date=$tmp[0];
			$code="";
			$code_name="";
			$code_print="";
			$code_name_print="";
			$class_print="";
			$submitter="";
			$class="";
			$submitDate=$getIDs->[6];
			$comment_date="";
			$status_date="";
			$yycomment_date="";
			$mmcomment_date="";
			$ddcomment_date="";
			$yystatus_date="";
			$mmstatus_date="";
			$ddstatus_date="";
			$yyentry_date="";
			$mmentry_date="";
			$ddentry_date="";
			$ncomment_date="";
			$nstatus_date="";
			$sth_getmaxcommentdate = $dbh->prepare("SELECT commentDate,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate) from comments where IDNo=$Idno and commentDate=(SELECT max(commentDate) from comments where IDNo=$Idno)");
			if (!defined $sth_getmaxcommentdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxcommentdate->execute;
			while ($getmaxcommentdate = $sth_getmaxcommentdate->fetch) {
				$comment_date=$getmaxcommentdate->[0];
				$yycomment_date=$getmaxcommentdate->[1];
				$mmcomment_date=$getmaxcommentdate->[2];
				$ddcomment_date=$getmaxcommentdate->[3];
				$len=0;
				$len = length $mmcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmcomment_date="0"."$mmcomment_date";
					} else {
						$mmcomment_date=$mmcomment_date;
					}
				} else {
					$mmcomment_date="";
				}
				$len=0;
				$len = length $ddcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddcomment_date="0"."$ddcomment_date";
					} else {
						$ddcomment_date=$ddcomment_date;
					}
				} else {
					$ddcomment_date="";
				}
				if ($comment_date ne "") {
					$ncomment_date="$yycomment_date"."$mmcomment_date"."$ddcomment_date";
				} else {
					$ncomment_date="";
				}				
			}
			$sth_getmaxstatusdate = $dbh->prepare("SELECT statusDate,DATE_PART('year',statusDate),DATE_PART('month',statusDate),DATE_PART('day',statusDate) from reviewerStatus where IDNo=$Idno and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$Idno)");
			if (!defined $sth_getmaxstatusdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxstatusdate->execute;
			while ($getmaxstatusdate = $sth_getmaxstatusdate->fetch) {
				$status_date=$getmaxstatusdate->[0];
				$yystatus_date=$getmaxstatusdate->[1];
				$mmstatus_date=$getmaxstatusdate->[2];
				$ddstatus_date=$getmaxstatusdate->[3];
				$len=0;
				$len = length $mmstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmstatus_date="0"."$mmstatus_date";
					} else {
						$mmstatus_date=$mmstatus_date;
					}
				} else {
					$mmstatus_date="";
				}
				$len=0;
				$len = length $ddstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddstatus_date="0"."$ddstatus_date";
					} else {
						$ddstatus_date=$ddstatus_date;
					}
				} else {
					$ddstatus_date="";
				}
				if ($status_date ne "") {
					$nstatus_date="$yystatus_date"."$mmstatus_date"."$ddstatus_date";
				} else {
					$nstatus_date="";
				}				
			}
			$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
			if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxentrydate->execute;
			while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
				$entry_date=$getmaxentrydate->[0];
				$yyentry_date=$getmaxentrydate->[1];
				$mmentry_date=$getmaxentrydate->[2];
				$ddentry_date=$getmaxentrydate->[3];
				$len=0;
				$len = length $mmentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmentry_date="0"."$mmentry_date";
					} else {
						$mmentry_date=$mmentry_date;
					}
				} else {
					$mmentry_date="";
				}
				$len=0;
				$len = length $ddentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddentry_date="0"."$ddentry_date";
					} else {
						$ddentry_date=$ddentry_date;
					}
				} else {
					$ddentry_date="";
				}
				if ($entry_date ne "") {
					$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
				} else {
					$nentry_date="";
				}				
			}
			if ($ncomment_date eq "") {
				$ncomment_date=$nentry_date;
			}
			if ($nstatus_date eq "") {
				$nstatus_date =$nentry_date;
			}
			if ($ncomment_date > $nentry_date) {
				$update_date=$ncomment_date;
				if ($nstatus_date > $update_date) {
					$update_date=$nstatus_date;
				}
				
			} elsif ($nstatus_date > $nentry_date) {
				$update_date=$nstatus_date;
				if ($ncomment_date > $update_date) {
					$update_date=$ncomment_date;
				}
			} else {
				$update_date=$nentry_date;
			}					
			$upy = substr($update_date,0,4);
			$upm = substr($update_date,4,2);
			$upd = substr($update_date,6,2);
			$upy = substr($update_date,0,4);
			$upm = substr($update_date,4,2);
			$upd = substr($update_date,6,2);
			$nupdate_date="$upy"."-"."$upm"."-"."$upd";
			$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";		
			print "<tr>\n";		
			#print "SELECT distinct IDNo,instrument_code,instrument_code_name,$peopletab.name_last,$peopletab.name_first,lower(instrument_class) from instCodes,$peopletab WHERE instCodes.submitter=$peopletab.person_id AND instCodes.IDNo=$Idno<br>\n";
			$sth_getcodes = $dbh->prepare("SELECT distinct IDNo,instrument_code,instrument_code_name,$peopletab.name_last,$peopletab.name_first,lower(instrument_class) from instCodes,$peopletab WHERE instCodes.submitter=$peopletab.person_id AND instCodes.IDNo=$Idno");
			if (!defined $sth_getcodes) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcodes->execute;
			while ($getcodes = $sth_getcodes->fetch) {
				$checkstatthisone=0;
				$code=$getcodes->[1];
				$code_name=$getcodes->[2];
				$class=$getcodes->[5];
				#print "SELECT count(*) from $archivedb.$instrcodedetailstab where instrument_code='$code'<br>\n";
				$sth_checkcode = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodedetailstab where instrument_code='$code'");
				if (!defined $sth_checkcode) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkcode->execute;
				while ($checkcode = $sth_checkcode->fetch) {
					if ($checkcode->[0] == 0) {
						# this code doesnt exist - display in red - set DB status to 0
						$code_print="<font color=red><strong>"."$code"."</font></strong>";
						$code_name_print="<font color=red><strong>"."$code_name"."</font><strong>";
						$class_print="$class";
						$DBstat=0;		
					} else {
						#code exists, check for change in code name
						#print "SELECT count(*) from $archivedb.$instrcodedetailstab where instrument_code='$code' AND instrument_name='$code_name'<br>\n";
						$sth_checkcodename = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodedetailstab where instrument_code='$code' AND instrument_name='$code_name'");
						if (!defined $sth_checkcodename) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkcodename->execute;
						while ($checkcodename = $sth_checkcodename->fetch) {
							#print "checkcodename $checkcodename->[0]<br>\n";
							#exit;
							if ($checkcodename->[0] == 0) {
								# the code name has changed! partially in the db - set DB status to -1
								$code_print="$code";
								$code_name_print="$code_name"."<font color=red><strong> *</strong></font>";
								$countstar=$countstar + 1;
								#print "code_print $code_print, code_name_print $code_name_print<br>\n";
								#$checkstatthisone = $checkstatthisone + 1;
								$DBstat=-1;
								#check instrument class here to see if that has been reassigned as well
								#print "SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_class_code)='$class' AND instrument_code='$code'<br>\n";
								$sth_checkclassname = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_class_code)='$class' AND instrument_code='$code'");
								if (!defined $sth_checkclassname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checkclassname->execute;
								while ($checkclassname = $sth_checkclassname->fetch) {
									#print "checkclassname $checkclassname->[0]<br>\n";
									#exit;
									if ($checkclassname->[0] == 0) {
										#new class to code association as well!
										$class_print = "$class"." <font color=red><strong>*</strong></font>";
										$countstar = $countstar+1;
										#$checkstatthisone = $checkstatthisone + 1;
									} else {
										# this class/code association is OK
										#NEED TO CHECK IF THERE ARE OTHERS THAT SHOULD NOT BE ASSOCIATED ANY LONGER!
										$class_print="$class";
										#$checkstatthisone = $checkstatthisone + 1;
									}
								}
							} else {
								#print "code_print $code_print, code_name_print $code_name_print, class_print $class_print<br>\n";
								
								#code and code name exist! next check instrument class association
								#print "SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_class_code)='$class' AND instrument_code='$code'<br\n";
								$sth_checkclassname = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_class_code)='$class' AND instrument_code='$code'");
								if (!defined $sth_checkclassname) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checkclassname->execute;
								while ($checkclassname = $sth_checkclassname->fetch) {
									#print "checkclassname $checkclassname->[0]<br>\n";
									#exit;
									if ($checkclassname->[0] == 0) {
										#new class to code association
										$code_print="$code";
										$code_name_print="$code_name";
										$class_print="$class"." <font color=red><strong>*</strong></font>";
										$DBstat=-1;
									} else {
										#no new associations
										#This class/code pair exists, but make sure there are no others that shouldnt be associated
										$checkclass2=0;
										$sth_checkclassname2 = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where instrument_code='$code'");
										if (!defined $sth_checkclassname2) { die "Cannot  statement: $DBI::errstr\n"; }
										$sth_checkclassname2->execute;
										while ($checkclassname2 = $sth_checkclassname2->fetch) {
											$checkclass2=$checkclassname2->[0];
										}
										if ($checkclass2 > 1) {
											#there is another class assigned - this is not allowed
											# print it on display but indicate it should be deleted!
											$dcl=0;
											$sth_checkclassname3 = $dbh->prepare("SELECT instrument_class_code from $archivedb.$instrcodetoinstrclasstab where instrument_code='$code' and lower(instrument_class_code) != '$class'");
											if (!defined $sth_checkclassname3) { die "Cannot  statement: $DBI::errstr\n"; }
											$sth_checkclassname3->execute;
											while ($checkclassname3 = $sth_checkclassname3->fetch) {
												if ($dcl == 0) {
													$class_print="$class<br><font color=red><strong>$checkclassname3->[0] -</strong></font>";
												} else {
													$class_print="$class_print"."<br><font color=red><strong>-</strong>$checkclassname3->[0]</strong></font>";
												}
												$dcl = $dcl + 1;
											}
											$DBstat=-1;
											$code_print="$code";
											$code_name_print="$code_name";
										
										
										} else {
										
											$code_print="$code";
											$code_name_print="$code_name";
											$class_print="$class";
											$DBstat=2;
										}
									}
								}			
							} 
						}
					}	
					
				}
				#print "code_print $code_print, code_name_print $code_name_print, class_print $class_print<br>\n";
				$submitter="$getcodes->[4]"." "."$getcodes->[3]";
				
				$REVstatdesc="";
				$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
				if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getstatdesc->execute;
				while ($getstatdesc = $sth_getstatdesc->fetch) {
					$REVstatdesc=$getstatdesc->[1];
				}
				$DBstatdesc="";
				$sth_getDBstatdesc=$dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");
				if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getDBstatdesc->execute;
				while ($getDBstatdesc = $sth_getDBstatdesc->fetch) {
					$DBstatdesc=$getDBstatdesc->[1];
				}
				$fontcolor="black";
				$dbfontcolor="black";
				if ($REVstat == 0) {
					$fontcolor="red";
				}
				if ($REVstat == 1) {
					$fontcolor="green";
				}
				if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
					$dbfontcolor="blue";
				}
				$numofcomments=0;
				$sth_countcomments = $dbh->prepare("SELECT count(*) from comments where IDNo=$Idno");
				if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countcomments->execute;
				while ($countcomments = $sth_countcomments->fetch) {
					$numofcomments = $countcomments->[0];
				}
				print "<td>$entry_date</td><td>$nupdate_date</td><td>$submitter</td>";
				if ($DBstat == 0) {
					print "<td>$code_print<br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					$exist=0;
				} else {
					print "<td><strong><font color=blue>$code_print</font></strong><br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					$exist=1;
				}
				if ($numofcomments > 0) {
					print " <small><font color=green><strong>(c)</strong></font></small>";
				}
				print "</td>";
				#if ($DBstat == 0) {
				#	print "<td><strong><font color=red>$code_name_print</font></strong></td><td>$class_print</td>";
				#} else {
				print "<td>$code_name_print</td><td>$class_print</td>";
				#}
				print "<td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";		
				print "<td><font color=$dbfontcolor><strong>$DBstatdesc</strong></font></td>\n";
				print "</tr>\n";
			}
		}
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE Instrument Code = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED Instrument Code = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated/added in this review or defined elsewhere</strong></font></small><br>\n";
	}
	if ($countminus > 0) {
		print "<small><font color=red><strong>- = fields being updated/removed in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
#################################################################################
# subroutine to display primary measurement type objects summary
#################################################################################
sub displaypmt 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	my $IDNo = shift;
	my $sortby = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	$oldID="";
	$sortable=0;
	if ($IDNo eq "") {
		$sortable=1;
	}
	if ($sortable == 0) {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=9 align=center><strong><font color=blue>Primary Measurement Type</font> Submissions for Review</strong></th>\n";
		print "<tr><th>Submit Date</th><th width=10%>Latest Update</th><th width=10%>Submitter</th><th><font color=blue>PMT</font></th><th>PMT Name</th><th>PMT Description</th><th>Meas Category Codes:Sub-Category Codes</th><th>Review Status</th>\n";
		print "<th>DB (ARM_int) Status</th>\n";
		print "</tr>";
	} else {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";	
		print "<th colspan=9 align=center><strong><font color=blue>Primary Measurement Type</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=PMT&sortby=entry_date\" style=\"text-decoration: none; color:black\">Submit Date</a></th><th width=10%>Latest Update</th><th width=10%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=PMT&sortby=submitter\" style=\"text-decoration: none; color:black\">Submitter</a></th><th><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=PMT&sortby=primmeas\" style=\"text-decoration: none; color:blue\">PMT</a></th><th>PMT Name</th><th>PMT Description</th><th>Meas Category Codes:Sub-Category Codes</th><th><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=PMT&sortby=rstatus\" style=\"text-decoration: none; color:black\">Review Status</a></th>\n";
		print "<th><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=PMT&sortby=dbstatus\" style=\"text-decoration: none; color:black\">DB (ARM_int) Status</a></th>";
		print "</tr>";	
	}		
	if ($IDNo eq "") {
		if ($sortby eq "") {
			$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where type='PMT' order by IDNo desc");
		} else {
			if ($sortby eq "submitter") {
				$sth_getIDs = $dbh->prepare("SELECT distinct primMeas.IDNo,type,revStatus,DBstatus,entry_date from primMeas,IDs,$peopletab where primMeas.IDNo=IDs.IDNo and primMeas.submitter=$peopletab.person_id and type='PMT' order by name_last,primMeas.IDNo");		
			} elsif ($sortby eq "primmeas") {
				$sth_getIDs = $dbh->prepare("SELECT distinct primMeas.IDNo,type,revStatus,DBstatus,entry_date from primMeas,IDs where primMeas.IDNo=IDs.IDNo and type='PMT' order by primMeas.primary_meas_code");		
			} elsif ($sortby eq "rstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct primMeas.IDNo,type,revStatus,DBstatus,entry_date from primMeas,IDs where primMeas.IDNo=IDs.IDNo and type='PMT' order by IDs.revStatus,primMeas.IDNo");
			} elsif ($sortby eq "dbstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct primMeas.IDNo,type,revStatus,DBstatus,entry_date from primMeas,IDs where primMeas.IDNo=IDs.IDNo and type='PMT' order by IDs.DBstatus,primMeas.IDNo");
			} elsif ($sortby eq "entry_date") {
				$sth_getIDs = $dbh->prepare("SELECT distinct primMeas.IDNo,type,revStatus,DBstatus,entry_date from primMeas,IDs where primMeas.IDNo=IDs.IDNo and type='PMT' order by IDs.entry_date desc,primMeas.IDNo");			
			}		
		}			
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}			
	$countstar=0;
	$countminus=0;
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$Idno = $getIDs->[0];
		$entry_date=$getIDs->[4];
		$skip=0;
		$sth_chkds = $dbh->prepare("SELECT count(*),count(*) from DS where IDNo=$Idno");
		if (!defined $sth_chkds) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_chkds->execute;
		while ($chkds = $sth_chkds->fetch) {
			$skip = $chkds->[0];
		}
		if ($skip == 0) {
			$REVstat=$getIDs->[2];
			$DBstat=$getIDs->[3];
			$comment_date="";
			$status_date="";
			$yycomment_date="";
			$mmcomment_date="";
			$ddcomment_date="";
			$yystatus_date="";
			$mmstatus_date="";
			$ddstatus_date="";
			$yyentry_date="";
			$mmentry_date="";
			$ddentry_date="";
			$ncomment_date="";
			$nstatus_date="";
			$sth_getmaxcommentdate = $dbh->prepare("SELECT commentDate,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate) from comments where IDNo=$Idno and commentDate=(SELECT max(commentDate) from comments where IDNo=$Idno)");
			if (!defined $sth_getmaxcommentdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxcommentdate->execute;
			while ($getmaxcommentdate = $sth_getmaxcommentdate->fetch) {
				$comment_date=$getmaxcommentdate->[0];
				$yycomment_date=$getmaxcommentdate->[1];
				$mmcomment_date=$getmaxcommentdate->[2];
				$ddcomment_date=$getmaxcommentdate->[3];
				$len=0;
				$len = length $mmcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmcomment_date="0"."$mmcomment_date";
					} else {
						$mmcomment_date=$mmcomment_date;
					}
				} else {
					$mmcomment_date="";
				}
				$len=0;
				$len = length $ddcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddcomment_date="0"."$ddcomment_date";
					} else {
						$ddcomment_date=$ddcomment_date;
					}
				} else {
					$ddcomment_date="";
				}
				if ($comment_date ne "") {
					$ncomment_date="$yycomment_date"."$mmcomment_date"."$ddcomment_date";
				} else {
					$ncomment_date="";
				}				
			}
			$sth_getmaxstatusdate = $dbh->prepare("SELECT statusDate,DATE_PART('year',statusDate),DATE_PART('month',statusDate),DATE_PART('day',statusDate) from reviewerStatus where IDNo=$Idno and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$Idno)");
			if (!defined $sth_getmaxstatusdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxstatusdate->execute;
			while ($getmaxstatusdate = $sth_getmaxstatusdate->fetch) {
				$status_date=$getmaxstatusdate->[0];
				$yystatus_date=$getmaxstatusdate->[1];
				$mmstatus_date=$getmaxstatusdate->[2];
				$ddstatus_date=$getmaxstatusdate->[3];
				$len=0;
				$len = length $mmstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmstatus_date="0"."$mmstatus_date";
					} else {
						$mmstatus_date=$mmstatus_date;
					}
				} else {
					$mmstatus_date="";
				}
				$len=0;
				$len = length $ddstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddstatus_date="0"."$ddstatus_date";
					} else {
						$ddstatus_date=$ddstatus_date;
					}
				} else {
					$ddstatus_date="";
				}
				if ($status_date ne "") {
					$nstatus_date="$yystatus_date"."$mmstatus_date"."$ddstatus_date";
				} else {
					$nstatus_date="";
				}				
			}
			$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
			if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxentrydate->execute;
			while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
				$entry_date=$getmaxentrydate->[0];
				$yyentry_date=$getmaxentrydate->[1];
				$mmentry_date=$getmaxentrydate->[2];
				$ddentry_date=$getmaxentrydate->[3];
				$len=0;
				$len = length $mmentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmentry_date="0"."$mmentry_date";
					} else {
						$mmentry_date=$mmentry_date;
					}
				} else {
					$mmentry_date="";
				}
				$len=0;
				$len = length $ddentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddentry_date="0"."$ddentry_date";
					} else {
						$ddentry_date=$ddentry_date;
					}
				} else {
					$ddentry_date="";
				}
				if ($entry_date ne "") {
					$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
				} else {
					$nentry_date="";
				}				
			}
			if ($ncomment_date eq "") {
				$ncomment_date=$nentry_date;
			}
			if ($nstatus_date eq "") {
				$nstatus_date =$nentry_date;
			}
			if ($ncomment_date > $nentry_date) {
				$update_date=$ncomment_date;
				if ($nstatus_date > $update_date) {
					$update_date=$nstatus_date;
				}				
			} elsif ($nstatus_date > $nentry_date) {
				$update_date=$nstatus_date;
				if ($ncomment_date > $update_date) {
					$update_date=$ncomment_date;
				}
			} else {
				$update_date=$nentry_date;
			}					
			$upy = substr($update_date,0,4);
			$upm = substr($update_date,4,2);
			$upd = substr($update_date,6,2);
			$nupdate_date="$upy"."-"."$upm"."-"."$upd";
			$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";		
			$sth_getpmt = $dbh->prepare("SELECT distinct IDNo,submitter,primary_meas_code,primary_meas_name from primMeas where IDNo=$Idno");
			if (!defined $sth_getpmt) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getpmt->execute;
			while ($getpmt = $sth_getpmt->fetch) {
				$exist=0;
				$checkstatthisone=0;
				$descpmt="";
				$sth_getpmdesc=$dbh->prepare("SELECT IDNo,primary_meas_desc from primMeas where IDNo=$getpmt->[0]");
				if (!defined $sth_getpmdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getpmdesc->execute;
				while ($getpmdesc = $sth_getpmdesc->fetch) {
					$descpmt=$getpmdesc->[1];
				}
				print "<tr>\n";
				$fname="";
				$lname="";
				$fullname="";
				$sth_getsubmname = $dbh->prepare("SELECT $peopletab.name_last,$peopletab.name_first from $peopletab WHERE $peopletab.person_id=$getpmt->[1]");
				if (!defined $sth_getsubmname) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getsubmname->execute;
				while ($getsubmname = $sth_getsubmname->fetch) {
					$fname=$getsubmname->[1];
					$lname=$getsubmname->[0];
				}
				$fullname="$fname"." "."$lname";
				if ($DBstat == 0) {
					$dbcolor="red";
					$exist=0;
				} else {
					$dbcolor="blue";
					$exist=1;
				}
				$numofcomments=0;
				$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
				if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countcomments->execute;
				while ($countcomments = $sth_countcomments->fetch) {
					$numofcomments = $countcomments->[0];
				}
				print "<td>$entry_date</td><td>$nupdate_date</td><td>$fullname</td><td><strong><font color=$dbcolor>$getpmt->[2]</font></strong><br /><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
				if ($numofcomments > 0) {
					print "<small><font color=green><strong> (c)</strong></font></small>";
				}
				print "</td>";
				$sth_chk1 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmtypedetailstab WHERE primary_meas_type_code='$getpmt->[2]' and primary_meas_type_name='$getpmt->[3]'");
				if (!defined $sth_chk1) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_chk1->execute;
				while ($chk1 = $sth_chk1->fetch) {
					if ($chk1->[0] > 0) {
						print "<td>$getpmt->[3]</td>";
					} else {
						if ($DBstat == 0) {
							print "<td>$getpmt->[3]</td>";
						} else {
							print "<td>$getpmt->[3] <font color=red><strong>*</strong></font></td>";
							$countstar = $countstar + 1;
							$checkstatthisone=$checkstatthisone + 1;
						}
					}
				}
				$newdescpmt="";
				$_=$descpmt;
				s/'/''/g;
				$newdescpmt=$_;
				$sth_chk2 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmtypedetailstab WHERE primary_meas_type_code='$getpmt->[2]' and primary_meas_type_desc like '$newdescpmt'");
				if (!defined $sth_chk2) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_chk2->execute;
				while ($chk2 = $sth_chk2->fetch) {
					if ($chk2->[0] > 0) {
						print "<td>$descpmt</td>";
					} else {
						if ($DBstat == 0) {
							print "<td>$descpmt</td>";
						} else {
							print "<td>$descpmt <font color=red><strong>*</strong></font></td>";
							$countstar = $countstar + 1;
							$checkstatthisone = $checkstatthisone + 1;
						}
					}
				}
				print "<td width=15%>\n";	
				$countmc=0;
				$sth_getmeascat=$dbh->prepare("SELECT distinct meas_category_code,meas_subcategory_code,statusFlag from measCats where IDNo=$getpmt->[0]");
				if (!defined $sth_getmeascat) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getmeascat->execute;
				while ($getmeascat = $sth_getmeascat->fetch) {
					if ($countmc == 0) {
						if ((($DBstat == -1 ) ||  ($DBstat == 1)) && ($getmeascat->[2] == 0)) {
							if ($getmeascat->[1] ne "") {
								print "$getmeascat->[0]: $getmeascat->[1] <font color=red><strong>*</strong></font>";
							} else {
								print "$getmeascat->[0]: N/A <font color=red><strong>*</strong></font>";
							}
							$countstar = $countstar + 1;
							$checkstatthisone = $checkstatthisone + 1;
						} else {
							if ($getmeascat->[1] ne "") {
								print "$getmeascat->[0]: $getmeascat->[1]";
							} else {
								print "$getmeascat->[0]: N/A ";
							}
						}
					} else {
						if ((($DBstat == -1 ) ||  ($DBstat == 1)) && ($getmeascat->[2] == 0)) {
							if ($getmeascat->[1] ne "") {
								print "<br />$getmeascat->[0]: $getmeascat->[1] <font color=red><strong>*</strong></font>";
							} else {
								print "<br />$getmeascat->[0]:- N/A <font color=red><strong>*</strong></font>";
							}
							$countstar = $countstar + 1;
							$checkstatthisone = $checkstatthisone + 1;
						} else {
							if ($getmeascat->[1] ne "") {
								print "<br />$getmeascat->[0]: $getmeascat->[1]";
							} else {
								print "<br />$getmeascat->[0]:- N/A";
							}
						}
					}
					$countmc = $countmc + 1;
				}
				$sth_getcurcats = $dbh->prepare("SELECT distinct $archivedb.$pmcodetomeascatalllower.primary_meas_type_code,$archivedb.$pmcodetomeascatalllower.meas_category_code,$archivedb.$pmcodetomeassubcatalllower.meas_subcategory_code from $archivedb.$pmcodetomeascatalllower,$archivedb.$pmcodetomeassubcatalllower,$archivedb.$meassubcatdetailstab WHERE $archivedb.$pmcodetomeascatalllower.primary_meas_type_code='$getpmt->[2]' and $archivedb.$pmcodetomeascatalllower.primary_meas_type_code=$archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code and $archivedb.$pmcodetomeassubcatalllower.primary_meas_type_code='$getpmt->[2]' and $archivedb.$pmcodetomeassubcatalllower.meas_subcategory_code=$archivedb.$meassubcatdetailstab.meas_subcategory_code and $archivedb.$pmcodetomeascatalllower.meas_category_code=$archivedb.$meassubcatdetailstab.meas_category_code and $archivedb.$pmcodetomeascatalllower.meas_category_code=$archivedb.$meassubcatdetailstab.meas_category_code order by $archivedb.$pmcodetomeascatalllower.meas_category_code,$archivedb.$pmcodetomeassubcatalllower.meas_subcategory_code");
				if (!defined $sth_getcurcats) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getcurcats->execute;
				while ($getcurcats = $sth_getcurcats->fetch) {
					$matchit=0;
					$sth_checkmeas = $dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$getpmt->[0] and meas_category_code='$getcurcats->[1]' and meas_subcategory_code='$getcurcats->[2]'");
					if (!defined $sth_checkmeas) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkmeas->execute;
					while ($checkmeas = $sth_checkmeas->fetch) {
						$matchit=$checkmeas->[0];
					}
					if ($matchit == 0) {
						if ($countmc > 0) {
							print "<br /><font color=red>$getcurcats->[1]: $getcurcats->[2] <strong>\-</font></strong>";
							$countminus = $countminus + 1;
							$checkstatthisone = $checkstatthisone + 1;
						} else {
							print "<font color=red>$getcurcats->[1]: $getcurcats->[2] <strong>\-</font></strong>";
							$countminus = $countminus + 1;
							$checkstatthisone = $checkstatthisone + 1;
						}
						$countmc = $countmc + 1;
					}
				}		
				print "</td>\n";
			}
			$REVstatdesc="";
			$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
			if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getstatdesc->execute;
			while ($getstatdesc = $sth_getstatdesc->fetch) {
				$REVstatdesc=$getstatdesc->[1];
			}
			$DBstatdesc="";
			$sth_getDBstatdesc=$dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");
			if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getDBstatdesc->execute;
			while ($getDBstatdesc = $sth_getDBstatdesc->fetch) {
				$DBstatdesc=$getDBstatdesc->[1];
			}
			$fontcolor="black";
			$dbfontcolor="black";
			if ($REVstat == 0) {
				$fontcolor="red";
			}
			if ($REVstat == 1) {
				$fontcolor="green";
			}
			if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
				$dbfontcolor="blue";
			}
			print "<td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";
			print "<td><font color=$dbfontcolor><strong>$DBstatdesc</strong></font></td>\n";
			print "</tr>\n";
		}
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE PMT = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED PMT = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated/added in review</strong></font></small><br />\n";
	}
	if ($countminus > 0) {
		print "<small><font color=red><strong>- = fields being removed as part of the update in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
################################################################################
# subroutine to display submissions of DOD objects for review
################################################################################
sub displaydod 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	my $IDNo = shift;
	my $sortby = shift;
	my $filter = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	$sortable=0;
	if ($IDNo eq "") {
	print "<div id=\"iops\">\n";
	print "<form method=\"post\" action=\"admin/MMTMetadata.pl\">";	
	if ($filter eq "") {
		$filter="all";
		$prfilter="Show All Review Status";
	} else {
		if ($filter eq "0") {
			$prfilter="Waiting for Review";
		}
		if ($filter eq "1") {
			$prfilter="Review in Progress";
		}
		if ($filter eq "2") {
			$prfilter="Approved";
		}
		if ($filter eq "9999") {
			$prfilter="Abandoned/OBE/Rejected";
		}
		if ($filter eq "all") {
			$prfilter="Show All Review Status";
		}
	}	
	print "<table cellspacing=\"0\">\n";
	print "<th colspan=5 align=\"left\"><strong>Review Status Filter</strong></th><tr>\n";
	if ($filter eq "") {
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small></td></tr></table>\n";
	} elsif ($filter eq "0") {
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\" checked><small>Waiting for Review</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small></td></tr></table>\n";
	} elsif ($filter eq "1") {
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\" checked><small>Review in Progress</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small></td></tr></table>\n";
	} elsif ($filter eq "2") {
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\" checked><small>Approved</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small></td></tr></table>\n";
	} elsif ($filter eq "9999") {
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\" checked><small>Abandoned/OBE/Rejected</small></td>\n"; 
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small></td></tr></table>\n";

	} elsif ($filter eq "all") {
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
		print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\" checked><small>Show All Review Status</small></td></tr></table>\n";
	}
	
	print "<input type=\"hidden\" name=\"type\" value=\"DOD\">\n";
	print "<input type=\"submit\" name=\"submit\" value=\"Submit Filter\"><p>\n";	
	}
	#print "</form>\n";
	if ($IDNo eq "") {
		$sortable=1;
	}
	if ($sortable == 0) {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=14 align=center><strong><font color=blue>DOD</font> Submitted for Review</strong></th>\n";
		print "<tr><th width=10%><br />Submit Date</th><th width=10%><br />Latest Update</th><th width=10%><br />Submitter</th><th width=15%><br />Contacts</th><th width=10%><font color=blue><br>DS Class (DS Class Desc)</font></th><th><br>DOD Version</th><th width=5%><br>Data Vol<br /> >8GB?</th><th width=5%><br>Site(s):Facility(ies)</th><th width=20%><br />Instrument Class</th><th><br>Source<br>Class</th><th width=10%><br>This<br>Release Type</th><th width=10%><br>Deadline?</th><th><br />DOD Review Status</th><th width=8%><br>DMF/XDC-Production Release</th>";
		print "</tr>";	
	} else {
		print "<div id=\"tableContainer\">\n";
		print "<table cellspacing=\"0\">\n";	
		print "<th colspan=14 align=center><strong><font color=blue>DOD</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><br /><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DOD&sortby=entry_date&filter=$filter\" style=\"text-decoration: none; color:black\">Submit Date</a></th><th width=10%><br>Latest Update</th><th width=10%><br /><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DOD&sortby=submitter&filter=$filter\" style=\"text-decoration: none; color:black\">Submitter</a></th><th width=15%><br />Contacts</th><th width=10%><br><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DOD&sortby=dsBase&filter=$filter\" style=\"text-decoration: none; color: blue\">DS Class (DS Class Desc)</a></th><th><br>DOD Version</th><th width=5%><br>Data Vol<br /> >8GB?</th><th width=5%><br>Site(s):Facility(ies)</th><th width=20%><br /><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DOD&sortby=instrument&filter=$filter\" style=\"text-decoration: none; color:black\">Instrument Class</a></th><th><br>Source<br>Class</th><th><br>This<br>Release Type</th><th width=10%><br>Deadline?</th><th><br /><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DOD&sortby=rstatus&filter=$filter\" style=\"text-decoration: none; color:black\">DOD Review Status</a></th><th width=8%><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DOD&sortby=dbstatus&filter=$filter\" style=\"text-decoration: none; color:black\"><br>DMF/XDC-Production Release</th>";
		print "</tr>";	
	
	}	
	$filtclause="";
	if (($filter ne "") && ($filter ne "all")) {
		$filtclause = " and IDs.revStatus = $filter ";
	}
	if ($IDNo eq "") {
		if ($sortby eq "") {
			$sth_getIDs = $dbh->prepare("SELECT distinct DOD.IDNo,type,revStatus,DBstatus,entry_date from DOD,IDs where DOD.IDNo=IDs.IDNo and type='DOD' $filtclause order by DOD.IDNo desc");
		} else {
			if ($sortby eq "submitter") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DOD.IDNo,type,revStatus,DBstatus,entry_date from DOD,IDs,$peopletab where DOD.IDNo=IDs.IDNo and DOD.submitter=$peopletab.person_id and type='DOD' $filtclause order by name_last,DOD.IDNo");		
			} elsif ($sortby eq "dsBase") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DOD.IDNo,type,revStatus,DBstatus,entry_date from DOD,IDs where DOD.IDNo=IDs.IDNo and type='DOD' $filtclause order by DOD.dsBase,DOD.dataLevel");		
			} elsif ($sortby eq "rstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DOD.IDNo,type,revStatus,DBstatus,entry_date from DOD,IDs where DOD.IDNo=IDs.IDNo and type='DOD' $filtclause order by IDs.revStatus,DOD.IDNo");
			} elsif ($sortby eq "instrument") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DOD.IDNo,type,revStatus,DBstatus,entry_date from DOD,instClass,IDs where DOD.IDNo=instClass.IDNo and DOD.IDNo=IDs.IDNo and type='DOD' $filtclause order by instrument_class,DOD.IDNo");
			} elsif ($sortby eq "dbstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DOD.IDNo,type,revStatus,DBstatus,entry_date from DOD,IDs where DOD.IDNo=IDs.IDNo and type='DOD' $filtclause order by IDs.revStatus,IDs.DBstatus,DOD.IDNo");
			} elsif ($sortby eq "entry_date") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DOD.IDNo,type,revStatus,DBstatus,entry_date from DOD,IDs where DOD.IDNo=IDs.IDNo and type='DOD' $filtclause order by IDs.entry_date desc,DOD.IDNo");			
			}		
		}			
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}	
	$countstar=0;
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$Idno = $getIDs->[0];
		$entry_date=$getIDs->[4];
		@tmp=();
		@tmp=split(/ /,$entry_date);
		$entry_date=$tmp[0];
		$skip=0;
		$sth_checkds = $dbh->prepare("SELECT count(*),count(*) from DS where IDNo=$Idno");
		if (!defined $sth_checkds) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checkds->execute;
		while ($cgeckds = $sth_checkds->fetch) {
			$skip=$checkds->[0];
		}
		if ($skip == 0) {
			$DBstat=$getIDs->[3];
			$REVstat=$getIDs->[2];
			$dsClass="";
			$dsBase="";
			$dsBaseDesc="";
			$dVol="";
			$dataLevel="";
			$DODversion="";
			$submitter="";
			$instClass="";
			$instClName="";
			$instClStat="";
			$sourceClass="";
			$sourceClStat="";
			$iseval="";
			$deaddate="";
			$comment_date="";
			$status_date="";
			$yycomment_date="";
			$mmcomment_date="";
			$ddcomment_date="";
			$yystatus_date="";
			$mmstatus_date="";
			$ddstatus_date="";
			$yyentry_date="";
			$mmentry_date="";
			$ddentry_date="";
			$ncomment_date="";
			$nstatus_date="";
			$sth_getmaxcommentdate = $dbh->prepare("SELECT commentDate,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate) from comments where IDNo=$Idno and commentDate=(SELECT max(commentDate) from comments where IDNo=$Idno)");
			if (!defined $sth_getmaxcommentdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxcommentdate->execute;
			while ($getmaxcommentdate = $sth_getmaxcommentdate->fetch) {
				$comment_date=$getmaxcommentdate->[0];
				$yycomment_date=$getmaxcommentdate->[1];
				$mmcomment_date=$getmaxcommentdate->[2];
				$ddcomment_date=$getmaxcommentdate->[3];
				$len=0;
				$len = length $mmcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmcomment_date="0"."$mmcomment_date";
					} else {
						$mmcomment_date=$mmcomment_date;
					}
				} else {
					$mmcomment_date="";
				}
				$len=0;
				$len = length $ddcomment_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddcomment_date="0"."$ddcomment_date";
					} else {
						$ddcomment_date=$ddcomment_date;
					}
				} else {
					$ddcomment_date="";
				}
				if ($comment_date ne "") {
					$ncomment_date="$yycomment_date"."$mmcomment_date"."$ddcomment_date";
				} else {
					$ncomment_date="";
				}				
			}
			$sth_getmaxstatusdate = $dbh->prepare("SELECT statusDate,DATE_PART('year',statusDate),DATE_PART('month',statusDate),DATE_PART('day',statusDate) from reviewerStatus where IDNo=$Idno and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$Idno)");
			if (!defined $sth_getmaxstatusdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxstatusdate->execute;
			while ($getmaxstatusdate = $sth_getmaxstatusdate->fetch) {
				$status_date=$getmaxstatusdate->[0];
				$yystatus_date=$getmaxstatusdate->[1];
				$mmstatus_date=$getmaxstatusdate->[2];
				$ddstatus_date=$getmaxstatusdate->[3];
				$len=0;
				$len = length $mmstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmstatus_date="0"."$mmstatus_date";
					} else {
						$mmstatus_date=$mmstatus_date;
					}
				} else {
					$mmstatus_date="";
				}
				$len=0;
				$len = length $ddstatus_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddstatus_date="0"."$ddstatus_date";
					} else {
						$ddstatus_date=$ddstatus_date;
					}
				} else {
					$ddstatus_date="";
				}
				if ($status_date ne "") {
					$nstatus_date="$yystatus_date"."$mmstatus_date"."$ddstatus_date";
				} else {
					$nstatus_date="";
				}				
			}
			$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
			if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxentrydate->execute;
			while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
				$entry_date=$getmaxentrydate->[0];
				$yyentry_date=$getmaxentrydate->[1];
				$mmentry_date=$getmaxentrydate->[2];
				$ddentry_date=$getmaxentrydate->[3];
				$len=0;
				$len = length $mmentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$mmentry_date="0"."$mmentry_date";
					} else {
						$mmentry_date=$mmentry_date;
					}
				} else {
					$mmentry_date="";
				}
				$len=0;
				$len = length $ddentry_date;
				if ($len > 0) {
					if ($len < 2) {
						$ddentry_date="0"."$ddentry_date";
					} else {
						$ddentry_date=$ddentry_date;
					}
				} else {
					$ddentry_date="";
				}
				if ($entry_date ne "") {
					$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
				} else {
					$nentry_date="";
				}				
			}
			if ($ncomment_date eq "") {
				$ncomment_date=$nentry_date;
			}
			if ($nstatus_date eq "") {
				$nstatus_date =$nentry_date;
			}
			if ($ncomment_date > $nentry_date) {
				$update_date=$ncomment_date;
				if ($nstatus_date > $update_date) {
					$update_date=$nstatus_date;
				}
				
			} elsif ($nstatus_date > $nentry_date) {
				$update_date=$nstatus_date;
				if ($ncomment_date > $update_date) {
					$update_date=$ncomment_date;
				}
			} else {
				$update_date=$nentry_date;
			}					
			$upy = substr($update_date,0,4);
			$upm = substr($update_date,4,2);
			$upd = substr($update_date,6,2);
			$nupdate_date="$upy"."-"."$upm"."-"."$upd";
			$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";
			print "<tr>\n";
			$sth_getnewDOD = $dbh->prepare("SELECT distinct IDNo,dsBase,dataLevel,DODversion,$peopletab.name_last,$peopletab.name_first,dsBaseDesc,dVol,iseval,DATE_PART('year',deaddate),DATE_PART('month',deaddate),DATE_PART('day',deaddate) from DOD,$peopletab WHERE DOD.submitter=$peopletab.person_id AND DOD.IDNo=$Idno order by dsBase,dataLevel,DODversion");
			if (!defined $sth_getnewDOD) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getnewDOD->execute;
			while ($getnewDOD = $sth_getnewDOD->fetch) {
				$checkstatthisone=0;
				$dsBase=$getnewDOD->[1];
				$dataLevel=$getnewDOD->[2];
				$DODversion=$getnewDOD->[3];
				$dsClass="$dsBase"."\."."$dataLevel";
				$dsBaseDesc=$getnewDOD->[6];
				$dVol=$getnewDOD->[7];
				$iseval=$getnewDOD->[8];
				$yrddate=$getnewDOD->[9];
				$monddate=$getnewDOD->[10];
				$dayddate=$getnewDOD->[11];
				$len=0;
				$len = length $monddate;
				if ($len > 0) {
					if ($len < 2) {
						$monddate="0"."$monddate";
					} else {
						$monddate=$monddate;
					}
				} else {
					$monddate="";
				}
				$len=0;
				$len = length $dayddate;
				if ($len > 0) {
					if ($len < 2) {
						$dayddate="0"."$dayddate";
					} else {
						$dayddate=$dayddate;
					}
				} else {
					$dayddate="";
				}
				if ($yrddate ne "") {
					$deaddate="$yrddate"."-"."$monddate"."-"."$dayddate";
				} else {
					$deaddate="";
				}	
				
				
				
				
				
				
				
				$sth_getinstcl = $dbh->prepare("SELECT distinct instrument_class,instrument_class_name,statusFlag from instClass where IDNo=$Idno");
				if (!defined $sth_getinstcl) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getinstcl->execute;
				while ($getinstcl = $sth_getinstcl->fetch) {
					$instClass=$getinstcl->[0];
					$instClName=$getinstcl->[1];
					$instClStat=$getinstcl->[2];
				}
				$countcl=0;
				#print "SELECT distinct source_class,statusFlag from sourceClass where IDNo=$Idno<br>\n";
				$sth_getsourcecl = $dbh->prepare("SELECT distinct source_class,statusFlag from sourceClass where IDNo=$Idno");
				if (!defined $sth_getsourcecl) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getsourcecl->execute;
				while ($getsourcecl = $sth_getsourcecl->fetch) {
					#print "countcl $countcl<br>\n";
					if ($countcl == 0) {
						#print "source class $getsourcecl->[0], source class flag $getsourcecl->[1]<br>\n";
						if ($getsourcecl->[1] == 1) {
							$sourceClass=$getsourcecl->[0];
						} else {
							$isitnew=0;
							$sth_checkdodstat=$dbh->prepare("SELECT IDNo,statusFlag from DOD where IDNo=$Idno");
							if (!defined $sth_checkdodstat) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_checkdodstat->execute;
							while ($checkdodstat = $sth_checkdodstat->fetch) {
								if ($checkdodstat->[1] == 0) {
									$isitnew=1;
								}
							}
							if ($isitnew == 0) {
								$sourceClass="$getsourcecl->[0]"." <font color=red>*</font>";
								$countstar = $countstar + 1;
							} else {
								$sourceClass="$getsourcecl->[0]";
							}
						}
					} else {
						#print "source class $getsourcecl->[0], source class flag $getsourcecl->[1]<br>\n";
						if ($getsourcecl->[1] == 1) {
							$sourceClass="$sourceClass"."<br>"."$getsourcecl->[0]";
						} else {
							$isitnew=0;
							#print "SELECT IDNo,statusFlag from DOD where IDNo=$Idno<br>\n";
							$sth_checkdodstat=$dbh->prepare("SELECT IDNo,statusFlag from DOD where IDNo=$Idno");
							if (!defined $sth_checkdodstat) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_checkdodstat->execute;
							while ($checkdodstat = $sth_checkdodstat->fetch) {
								#print "dod stat flag $checkdodstat->[1]<br>\n";
								if ($checkdodstat->[1] == 0) {
									$isitnew=1;
								}
							}
							#print "isitnew $isitnew<br>\n";
							if ($isitnew == 1) {
								$sourceClass="$sourceClass"."<br>"."$getsourcecl->[0]"." <font color=red>*</font>";
								$countstar = $countstar + 1;
							} else {
								$sourceClass="$sourceClass"."<br>"."$getsourcecl->[0]";
							}
						}
					}
					$sourceClStat=$getsourcecl->[1];
					$countcl = $countcl + 1;
				}		
				$submitter="$getnewDOD->[5]"." "."$getnewDOD->[4]";	
				$loclist="";
				$totloc=0;
				$sth_countloc = $dbh->prepare("SELECT distinct IDNo,IDNo from facilities where IDNo=$Idno");
				if (!defined $sth_countloc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countloc->execute;
				while ($countloc = $sth_countloc->fetch) {
					$totloc = $totloc+ 1;
				}
				if ($totloc > 0) {
					$fno=0;
					$sth_getlocs = $dbh->prepare("SELECT facilities.site,facilities.facility_code,statusFlag from facilities where IDNo=$Idno order by site,facility_code");
					if (!defined $sth_getlocs) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getlocs->execute;
					while ($getlocs = $sth_getlocs->fetch) {
						if ($fno == 0) {
							if ($getlocs->[2] == 1) {
								$loclist="$getlocs->[0]:$getlocs->[1]";
							} else {
								$isitnew=0;
								$sth_checkdodstat=$dbh->prepare("SELECT IDNo,statusFlag from DOD where IDNo=$Idno");
								if (!defined $sth_checkdodstat) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checkdodstat->execute;
								while ($checkdodstat = $sth_checkdodstat->fetch) {
									if ($checkdodstat->[1] == 0) {
										$isitnew=1;
									}
								}
								if ($isitnew == 0) {
									$loclist="$getlocs->[0]:$getlocs->[1] <font color=red>*</font>";
									$countstar = $countstar + 1;
								} else {
									$loclist="$getlocs->[0]:$getlocs->[1]";
								}
							}
						} else {	
							if ($getlocs->[2] == 1) {
								$loclist= "$loclist"."<br>"."$getlocs->[0]:$getlocs->[1]";
							} else {
								$isitnew=0;
								$sth_checkdodstat=$dbh->prepare("SELECT IDNo,statusFlag from DOD where IDNo=$Idno");
								if (!defined $sth_checkdodstat) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checkdodstat->execute;
								while ($checkdodstat = $sth_checkdodstat->fetch) {
									if ($checkdodstat->[1] == 0) {
										$isitnew=1;
									}
								}
								if ($isitnew == 0) {
									$loclist="$loclist"."<br>"."$getlocs->[0]:$getlocs->[1] <font color=red>*</font>";
									$countstar = $countstar + 1;
								} else {
									$loclist="$loclist"."<br>"."$getlocs->[0]:$getlocs->[1]";
								}
							}
						}
						$fno = $fno + 1;
					}
				} else {
					$loclist="<font color=\"red\">UNSPECIFIED Sites</font>";
				}				
				$countmnt=0;
				$mentorlist="";
				$sth_getmentors = $dbh->prepare("SELECT distinct $grouprole.person_id,name_first,name_last,$grouprole.group_name,$grouprole.role_name,$grouprole.subrole_name from $grouprole,$peopletab WHERE $grouprole.person_id=$peopletab.person_id and $grouprole.role_name=upper('$instClass') and $grouprole.group_name not like '%Reminder%'");
				if (!defined $sth_getmentors) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getmentors->execute;
				while ($getmentors = $sth_getmentors->fetch) {
					if ($countmnt == 0) {
						$mentorlist = "$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5]";
					} else {
						$mentorlist = "$mentorlist"."<br>"."$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5]";
					}
					$countmnt = $countmnt + 1;
				}	
				$sth_getmentors = $dbh->prepare("SELECT distinct instContacts.contact_id,name_first,name_last,instContacts.group_name,instContacts.role_name,instContacts.subrole_name from instContacts,$peopletab WHERE instContacts.role_name=upper('$instClass') and instContacts.contact_id=$peopletab.person_id AND instContacts.contact_id not in (SELECT distinct person_id from $grouprole where $grouprole.role_name=upper('$instClass'))");
				if (!defined $sth_getmentors) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getmentors->execute;
				while ($getmentors = $sth_getmentors->fetch) {
					if ($countmnt == 0) {
						$mentorlist = "$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5] <font color=red><strong>*</strong></font>";
					} else {
						$mentorlist = "$mentorlist"."<br>"."$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5] <font color=red><strong>*</strong></font>";
					}
					$countmnt = $countmnt + 1;
				}									
				$REVstatdesc="";
				$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
				if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getstatdesc->execute;
				while ($getstatdesc = $sth_getstatdesc->fetch) {
					$REVstatdesc=$getstatdesc->[1];
				}
				$DBstatdesc="";
				$dbfontcolor="black";
				if ($DBstat == 2) {
					$DBstatdesc="Complete";
					$dbfontcolor="black";
				} else {
					if ($REVstat == 2) {
						$DBstatdesc="In Progress";
						$dbfontcolor="blue";
					} else {
						$DBstatdesc="Wait";
						$dbfontcolor="red";
					}
				}
				$fontcolor="black";
				if ($REVstat == 0) {
					$fontcolor="red";
				}
				if ($REVstat == 1) {
					$fontcolor="green";
				}				
				$numofcomments=0;
				$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
				if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countcomments->execute;
				while ($countcomments = $sth_countcomments->fetch) {
					$numofcomments = $countcomments->[0];
				}
				print "<td>$entry_date</td><td>$nupdate_date</td><td>$submitter</td>";
				if ($mentorlist ne "") {
					print "<td>$mentorlist</td>";
				} else {
					print "<td><font color=red><strong>NOT DEFINED YET</strong></font></td>";
				}
				if ($DBstat == 0) {
					if ($dsBaseDesc ne "") {
						print "<td><strong><font color=red>$dsClass</font></strong> ($dsBaseDesc)<br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					} else {
						print "<td><strong><font color=red>$dsClass</font></strong> (---)<br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					}
					$exist=0;
				} else {
					if ($dsBaseDesc ne "") {
						print "<td><strong><font color=blue>$dsClass</font></strong> ($dsBaseDesc)<br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					} else {
						print "<td><strong><font color=blue>$dsClass</font></strong> (---)<br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT-ID#: $Idno]</a>";
					}
					$exist=1;
				}
				if ($numofcomments > 0) {
					print " <small><font color=green><strong>(c)</strong></font></small>";
				}
				$dsmmtid="";
				#if ($REVstat == 2) {
					$sth_getdsmmtid=$dbh->prepare("SELECT IDNo,IDNo from DS where dsBase='$dsBase' and dataLevel='$dataLevel' and DODversion='$DODversion'");
					$sth_getdsmmtid->execute;
					while ($getdsmmtid = $sth_getdsmmtid->fetch) {
						$dsmmtid = $getdsmmtid->[0];
					}
					if ($dsmmtid ne "") {
						print "<br><a href=\"reviewMetaData.pl?IDNo=$dsmmtid\" style=\"text-decoration:none; color:blue;\"><small>[DS ID#: $dsmmtid]</small></a>";
					}
				#}
				
				
				
				print "</td>";
				print "<td><a href=\"https://pcm.arm.gov/pcm/?dodId=$dsBase.$dataLevel&versionId=$DODversion\" target=\"DOD_$DODversion\">$DODversion</a></td>";
				print "<td>";
				if ($dVol ne "") {
					if ($dVol eq "Y") {
						print "Yes</td>\n";
					} else {
						print "No</td>\n";
					}
				} else {
					print "---</td>\n";
				}
				print "<td>$loclist</td>";
				$iclst="";
				$iclfont="black";
				if ($instClass ne "") {
					if ($instClStat == 0) {
						$countstar = $countstar + 1;
						$iclfont="red";
					}
					print "<td>$instClass ($instClName)<font color=$iclfont><strong>$iclst</strong></font></td>\n";
				} else {
					print "<td>unassigned</td>\n";
				}
				$sclst="";
				$sclfont="black";
				if ($sourceClass ne "") {
					print "<td width=10%>$sourceClass<strong>$sclst</strong></font></td>\n";
				} else {
					print "<td>unassigned</td>\n";
				}
				if ($iseval eq "N") {
					print "<td>Production</td>\n";
				} elsif ($iseval eq "Y") {
					print "<td>Evaluation</td>\n";
				} else {
					print "<td> </td>\n";
				}
				print "<td>$deaddate</td>\n";
				print "<td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";
				print "<td><font color=$dbfontcolor><strong>$DBstatdesc</strong></font></td>";
				print "</tr>\n";
			}
		}
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE DS Class = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED DS Class = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated/added in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
#################################################################################
# subroutine to display datastreams object summary
#################################################################################
sub displayds 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      	
	my $IDNo = shift;
	my $sortby = shift;
	my $filter = shift;
	my $exabnd = shift;
	my $searchresults = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";
	$sortable=0;
	print "<div id=\"iops\">\n";
	if ($IDNo eq "") {
		print "<form method=\"post\" action=\"admin/MMTMetadata.pl\">";	
		if ($filter eq "") {
			$filter="all";
			$prfilter="Show All Review Status";
		} else {
			if ($filter eq "0") {
				$prfilter="Waiting for Review";
			}
			if ($filter eq "1") {
				$prfilter="Review in Progress";
			}
			if ($filter eq "2") {
				$prfilter="Approved";
			}
			if ($filter eq "9999") {
				$prfilter="Abandoned/OBE/Rejected";
			}
			if ($filter eq "all") {
				$prfilter="Show All Review Status";
			}
		}
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=6 align=\"left\"><strong>Review Status Filter</strong></th><tr>\n";
		if ($filter eq "") {
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small> \n";
			if ($exabnd eq "1") {
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\" checked><small>(exclude abandoned)</small></td>\n";
			} else {
		
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\"><small>(exclude abandoned)</small></td>\n";
			}
			if ($searchresults eq "") {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\"></td>\n";
			} else {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\" value=\"$searchresults\"></td>\n";
			}
			print "</tr></table>\n";
		} elsif ($filter eq "0") {
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\" checked><small>Waiting for Review</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small> \n";
			if ($exabnd eq "1") {
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\" checked><small>(exclude abandoned)</small></td>\n";
			} else {
		
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\"><small>(exclude abandoned)</small></td>\n";
			}
			if ($searchresults eq "") {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\"></td>\n";
			} else {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\" value=\"$searchresults\"></td>\n";
			}
			print "</tr></table>\n";
		} elsif ($filter eq "1") {
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\" checked><small>Review in Progress</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small> \n";
			if ($exabnd eq "1") {
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\" checked><small>(exclude abandoned)</small></td>\n";
			} else {
		
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\"><small>(exclude abandoned)</small></td>\n";
			}
			if ($searchresults eq "") {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\"></td>\n";
			} else {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\" value=\"$searchresults\"></td>\n";
			}
			print "</tr></table>\n";
		} elsif ($filter eq "2") {
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\" checked><small>Approved</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small> \n";
			if ($exabnd eq "1") {
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\" checked><small>(exclude abandoned)</small></td>\n";
			} else {
		
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\"><small>(exclude abandoned)</small></td>\n";
			}
			if ($searchresults eq "") {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\"></td>\n";
			} else {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\" value=\"$searchresults\"></td>\n";
			}
			print "</tr></table>\n";
		} elsif ($filter eq "9999") {
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\" checked><small>Abandoned/OBE/Rejected</small></td>\n"; 
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\"><small>Show All Review Status</small> \n";
			if ($exabnd eq "1") {
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\" checked><small>(exclude abandoned)</small></td>\n";
			} else {
		
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\"><small>(exclude abandoned)</small></td>\n";
			}
			if ($searchresults eq "") {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\"></td>\n";
			} else {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\" value=\"$searchresults\"></td>\n";
			}
			print "</tr></table>\n";

		} elsif ($filter eq "all") {
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"0\"><small>Waiting for Review</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"1\"><small>Review in Progress</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"2\"><small>Approved</small></td>\n";
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"9999\"><small>Abandoned/OBE/Rejected</small></td>\n"; 
			print "<td width=10%><input type=\"radio\" name=\"filter\" value=\"all\" checked><small>Show All Review Status</small> \n";
			if ($exabnd eq "1") {
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\" checked><small>(exclude abandoned)</small></td>\n";
			} else {
		
				print "<input type=\"checkbox\" name=\"exabnd\" value=\"1\"><small>(exclude abandoned)</small></td>\n";
			}
			if ($searchresults eq "") {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\"></td>\n";
			} else {
				print "<td width=10%>DS Base Search: <input type=\"text\" name=\"searchresults\" value=\"$searchresults\"></td>\n";
			}
			print "</tr></table>\n";
		}
		print "<input type=\"hidden\" name=\"type\" value=\"DS\">\n";
		print "<input type=\"submit\" name=\"submit\" value=\"Submit Filter\"><p>\n";	
	}
	if ($IDNo eq "") {
		$sortable=1;
	}
	print "<p><br>\n";
	if ($sortable == 0) {
		print "<table cellspacing=\"0\">\n";
		print "<th colspan=110 align=\"center\"><strong><font color=blue>Datastream</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><br>Submit Date</th><th witdh=10%><br>Latest Update</th><th><br>Submitter</th><th width=20% align=\"center\"><font color=blue>DS Class<br>(DS Class Desc)</font></th><th width=15% align=\"center\"><br />Contacts</th>";
		print "<th>Instrument<br />Categories</th><th>Instrument<br />Class</th><th width=12%>Source<br>Classes</th><th width=20%>Measurement Categories: Sub-Categories</th><th width=30%>Primary Meas  Type: Short Name: Long Name of Primary Variables</th><th>Review<br>Status</th>\n";
		print "</tr>\n";
	} else {
		print "<table cellspacing=\"0\">\n";	
		print "<th colspan=11 align=\"center\"><strong><font color=blue>Datastream</font> Submissions for Review</strong></th>\n";
		print "<tr><th width=10%><br><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DS&sortby=entry_date&filter=$filter&exabnd=$exabnd&searchresults=$searchresults\" style=\"text-decoration: none; color:black\">Submit Date</a></th><th width=10%><br>Latest Update</th><th width=15% align=\"center\"><font color=\"green\"><br /><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DS&sortby=submitter&filter=$filter&exabnd=$exabnd&searchresults=$searchresults\" style=\"text-decoration: none; color:black\">Submitter</a></th><th width=20% align=\"center\"><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DS&sortby=dsBase&filter=$filter&exabnd=$exabnd&searchresults=$searchresults\" style=\"text-decoration: none; color:blue\">DS Class<br>(DS Class Desc)</a></th><th width=15%><br />Contacts</th>";
		print "<th>Instrument<br />Categories</th><th width=10% align=\"center\"><font color=\"green\"><strong>+ </strong></font><font color=blue><a href=\"MMTMetaData.pl?type=DS&sortby=instrument&filter=$filter&exabnd=$exabnd&searchresults=$searchresults\" style=\"text-decoration: none;color: black\">Instrument<br />Class</a></font></th><th width=12%>Source<br>Classes</th><th width=20%><br>Meas Cats: Sub-Cats</th><th width=30%>Primary Meas  Type: Short Name:<br>Long Name of Primary Variables</th><th><font color=\"green\"><strong>+ </strong></font><a href=\"MMTMetaData.pl?type=DS&sortby=rstatus&filter=$filter&exabnd=$exabnd&searchresults\" style=\"text-decoration: none; color: black\">Review<br>Status</a></th>\n";
		print "</tr>\n";
	}
	$oldID="";
	$filtclause="";
	if (($filter ne "") && ($filter ne "all") ) {
		if ($exabnd ne "1")  {
			$filtclause = " and IDs.revStatus = $filter ";
		} else {
			if ($filter eq "9999") {
				$filtclause = " and IDs.revStatus = $filter ";
			} else {
				$filtclause = " and (IDs.revStatus = $filter and IDs.revStatus != 9999) ";
			}
		
		}
	} else {
		if ($exabnd eq "1") {
			$filtclause = " and IDs.revStatus != 9999 ";
		}
	}
	
	if ($searchresults ne "") {
		$filtclause = "$filtclause and DS.dsBase like '$searchresults' ";
	}
	if ($IDNo eq "") {
		if ($sortby eq "") {
			$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,IDs where DS.IDNo=IDs.IDNo and type='DS' $filtclause order by DS.dsBase,DS.dataLevel,DS.IDNo desc");	
		} else {
			if ($sortby eq "submitter") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,IDs,$peopletab where DS.IDNo=IDs.IDNo and DS.submitter=$peopletab.person_id and type='DS' $filtclause order by name_last,DS.dsBase,DS.dataLevel,DS.IDNo desc");	
			} elsif ($sortby eq "dsBase") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,IDs where DS.IDNo=IDs.IDNo and type='DS' $filtclause order by DS.dsBase,DS.dataLevel,DS.IDNo desc");		
			} elsif ($sortby eq "rstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,IDs where DS.IDNo=IDs.IDNo and type='DS' $filtclause order by IDs.revStatus,DS.dsBase,DS.dataLevel,DS.IDNo desc");
			} elsif ($sortby eq "dbstatus") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,IDs where DS.IDNo=IDs.IDNo and type='DS' $filtclause order by IDs.DBstatus,DS.dsBase,DS.dataLevel,DS.IDNo desc");
			} elsif ($sortby eq "instrument") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,instClass,IDs where DS.IDNo=instClass.IDNo and DS.IDNo=IDs.IDNo and type='DS' $filtclause order by instrument_class,DS.dsBase,DS.dataLevel,DS.IDNo desc");
			} elsif ($sortby eq "entry_date") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,IDs where DS.IDNo=IDs.IDNo and type='DS' $filtclause order by IDs.entry_date desc,DS.dsBase,DS.dataLevel,DS.IDNo desc");
			} elsif ($sortby eq "IDNo") {
				$sth_getIDs = $dbh->prepare("SELECT distinct DS.IDNo,type,revStatus,DBstatus,entry_date from DS,IDs where DS.IDNo=IDs.IDNo and type='DS' $filtclause order by DS.IDNo desc");
			}			
		}			
	} else {
		$sth_getIDs = $dbh->prepare("SELECT distinct IDNo,type,revStatus,DBstatus,entry_date from IDs where IDNo=$IDNo");
	}		
	$countstar=0;
	$countminus=0;
	if (!defined $sth_getIDs) { die "Cannot  statement : $DBI::errstr\n"; }
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$Idno = $getIDs->[0];
		$REVstat=$getIDs->[2];
		$DBstat=$getIDs->[3];
		$entry_date=$getIDs->[4];
		@tmp=();
		@tmp=split(/ /,$entry_date);
		$entry_date=$tmp[0];
		$dsBase="";
		$dataLevel="";
		$DODversion="";
		$dsBaseDesc="";
		$subln="";
		$subfn="";
		$comment_date="";
		$status_date="";
		$yycomment_date="";
		$mmcomment_date="";
		$ddcomment_date="";
		$yystatus_date="";
		$mmstatus_date="";
		$ddstatus_date="";
		$yyentry_date="";
		$mmentry_date="";
		$ddentry_date="";
		$ncomment_date="";
		$nstatus_date="";
		$sth_getmaxcommentdate = $dbh->prepare("SELECT commentDate,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate) from comments where IDNo=$Idno and commentDate=(SELECT max(commentDate) from comments where IDNo=$Idno)");
		if (!defined $sth_getmaxcommentdate) { die "Cannot statement: $DBI::errstr\n"; }
		$sth_getmaxcommentdate->execute;
		while ($getmaxcommentdate = $sth_getmaxcommentdate->fetch) {
			$comment_date=$getmaxcommentdate->[0];
			$yycomment_date=$getmaxcommentdate->[1];
			$mmcomment_date=$getmaxcommentdate->[2];
			$ddcomment_date=$getmaxcommentdate->[3];
			$len=0;
			$len = length $mmcomment_date;
			if ($len > 0) {
				if ($len < 2) {
					$mmcomment_date="0"."$mmcomment_date";
				} else {
					$mmcomment_date=$mmcomment_date;
				}
			} else {
				$mmcomment_date="";
			}
			$len=0;
			$len = length $ddcomment_date;
			if ($len > 0) {
				if ($len < 2) {
					$ddcomment_date="0"."$ddcomment_date";
				} else {
					$ddcomment_date=$ddcomment_date;
				}
			} else {
				$ddcomment_date="";
			}
			if ($comment_date ne "") {
				$ncomment_date="$yycomment_date"."$mmcomment_date"."$ddcomment_date";
			} else {
				$ncomment_date="";
			}				
		}
		$sth_getmaxstatusdate = $dbh->prepare("SELECT statusDate,DATE_PART('year',statusDate),DATE_PART('month',statusDate),DATE_PART('day',statusDate) from reviewerStatus where IDNo=$Idno and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$Idno)");
		if (!defined $sth_getmaxstatusdate) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getmaxstatusdate->execute;
		while ($getmaxstatusdate = $sth_getmaxstatusdate->fetch) {
			$status_date=$getmaxstatusdate->[0];
			$yystatus_date=$getmaxstatusdate->[1];
			$mmstatus_date=$getmaxstatusdate->[2];
			$ddstatus_date=$getmaxstatusdate->[3];
			$len=0;
			$len = length $mmstatus_date;
			if ($len > 0) {
				if ($len < 2) {
					$mmstatus_date="0"."$mmstatus_date";
				} else {
					$mmstatus_date=$mmstatus_date;
				}
			} else {
				$mmstatus_date="";
			}
			$len=0;
			$len = length $ddstatus_date;
			if ($len > 0) {
				if ($len < 2) {
					$ddstatus_date="0"."$ddstatus_date";
				} else {
					$ddstatus_date=$ddstatus_date;
				}
			} else {
				$ddstatus_date="";
			}
			if ($status_date ne "") {
					$nstatus_date="$yystatus_date"."$mmstatus_date"."$ddstatus_date";
			} else {
				$nstatus_date="";
			}				
		}
		$sth_getmaxentrydate = $dbh->prepare("SELECT entry_date,DATE_PART('year',entry_date),DATE_PART('month',entry_date),DATE_PART('day',entry_date) from IDs where IDNo=$Idno");
		if (!defined $sth_getmaxentrydate) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getmaxentrydate->execute;
		while ($getmaxentrydate = $sth_getmaxentrydate->fetch) {
			$entry_date=$getmaxentrydate->[0];
			$yyentry_date=$getmaxentrydate->[1];
			$mmentry_date=$getmaxentrydate->[2];
			$ddentry_date=$getmaxentrydate->[3];
			$len=0;
			$len = length $mmentry_date;
			if ($len > 0) {
				if ($len < 2) {
					$mmentry_date="0"."$mmentry_date";
				} else {
					$mmentry_date=$mmentry_date;
				}
			} else {
				$mmentry_date="";
			}
			$len=0;
			$len = length $ddentry_date;
			if ($len > 0) {
				if ($len < 2) {
					$ddentry_date="0"."$ddentry_date";
				} else {
					$ddentry_date=$ddentry_date;
				}
			} else {
				$ddentry_date="";
			}
			if ($entry_date ne "") {
				$nentry_date="$yyentry_date"."$mmentry_date"."$ddentry_date";
			} else {
				$nentry_date="";
			}				
		}
		if ($ncomment_date eq "") {
			$ncomment_date=$nentry_date;
		}
		if ($nstatus_date eq "") {
			$nstatus_date =$nentry_date;
		}
		if ($ncomment_date > $nentry_date) {
			$update_date=$ncomment_date;
			if ($nstatus_date > $update_date) {
				$update_date=$nstatus_date;
			}
				
		} elsif ($nstatus_date > $nentry_date) {
			$update_date=$nstatus_date;
			if ($ncomment_date > $update_date) {
				$update_date=$ncomment_date;
			}
		} else {
			$update_date=$nentry_date;
		}				
		$upy = substr($update_date,0,4);
		$upm = substr($update_date,4,2);
		$upd = substr($update_date,6,2);
		$nupdate_date="$upy"."-"."$upm"."-"."$upd";
		$entry_date="$yyentry_date"."-"."$mmentry_date"."-"."$ddentry_date";
		$dsBase="";
		$dsBaseDesc="";
		$dataLevel="";
		$DODversion="";		
		$sth_getDS=$dbh->prepare("SELECT IDNo,dsBase,dsBaseDesc,dataLevel,$peopletab.name_last,$peopletab.name_first,DODversion from DS,$peopletab WHERE DS.submitter=$peopletab.person_id AND DS.IDNo=$Idno");
		if (!defined $sth_getDS) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getDS->execute;
		while ($getDS = $sth_getDS->fetch) {
			$exist=0;
			$checkstatthisone=0;
			$dsBase=$getDS->[1];
			$dsBaseDesc=$getDS->[2];
			$dataLevel=$getDS->[3];
			$DODversion=$getDS->[6];
			$subln=$getDS->[4];
			$subfn=$getDS->[5];
			if ($DBstat == 0) {
				$dbcolor="red";
				$exist=0;
			} else {
				$dbcolor="blue";
				$exist=1;
			}
			$numofcomments=0;
			$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$Idno");
			if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_countcomments->execute;
			while ($countcomments = $sth_countcomments->fetch) {
				$numofcomments = $countcomments->[0];
			}
			print "<tr>\n";
			print "<td>$entry_date</td>\n";
			print "<td>$nupdate_date</td>\n";
			print "<td>$subfn $subln</td>\n";
			print "<td width=10%><strong><font color=$dbcolor>$dsBase\.$dataLevel</font></strong><br />($dsBaseDesc)<br><a href=\"reviewMetaData.pl?IDNo=$Idno\" style=\"text-decoration:none; color:blue;\">[MMT:ID# - $Idno]</a>\n";
			if ($numofcomments > 0) {
				print "<small><font color=green><strong> (c)</strong></font></small>";
			}
			$thisdodid="";
			$thisdodver="";
			if ($DODversion ne "") {
				$sth_getdodid=$dbh->prepare("SELECT IDNo,IDNo from DOD where dsBase='$dsBase' and dataLevel='$dataLevel' and DODversion='$DODversion'");
				if (!defined $sth_getdodid) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdodid->execute;
				while ($getdodid = $sth_getdodid->fetch) {
					$thisdodid=$getdodid->[0];
				}
			} else {
				$thisdodid="";
			}
			$thisdodfacs="";
			if ($thisdodid ne "") {
				$totfacsthisdod=0;
				$sth_countdodfac = $dbh->prepare("SELECT count(*) from facilities where IDNo=$thisdodid");
				if (!defined $sth_countdodfac) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countdodfac->execute;
				while ($countdodfac = $sth_countdodfac->fetch) {
					$totfacsthisdod=$countdodfac->[0];
				}
				$countdodfacs=0;
				$sth_getdodfacs = $dbh->prepare("SELECT distinct site,facility_code from facilities where IDNo=$thisdodid");
				if (!defined $sth_getdodfacs) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdodfacs->execute;
				while ($getdodfacs = $sth_getdodfacs->fetch) {
					if ($totfacsthisdod > 1) {
						if ($countdodfacs == 0) {
							$thisdodfacs="$getdodfacs->[0]:$getdodfacs->[1]";
						} else {
							$thisdodfacs="$thisdodfacs, $getdodfacs->[0]:$getdodfacs->[1]";
						}
						$countdodfacs = $countdodfacs + 1;
						
				
					} else {
						$thisdodfacs = "$getdodfacs->[0]:$getdodfacs->[1]";
					}
				}
			}
			if ($thisdodfacs ne "") {
				print "<br><small>Sites: $thisdodfacs (from DOD)<br>\n";				
			} else {
				print "<br><small><font color=\"red\">Sites: UNSPECIFIED</font><br>\n";
			}
			if ($DODversion ne "") {
				print "(<a href=\"reviewMetaData.pl?IDNo=$thisdodid\" style=\"text-decoration:none; color:blue;\"target=_new$thisdodid\">DOD $thisdodid</a>: <a href=\"https://pcm.arm.gov/pcm/?dodId=$dsBase.$dataLevel&versionId=$DODversion\" style=\"text-decoration:none; color:blue;\"target=_new$DODversion\">v$DODversion</a>)";
			}
			print "</small>";
			print "</td>";	
			$countmnt=0;
			$mentorlist="";
			$contactinst="";
			$sth_geti=$dbh->prepare("SELECT distinct instrument_class,instrument_class from instClass where IDNo=$Idno");
			if (!defined $sth_geti) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_geti->execute;
			while ($geti = $sth_geti->fetch) {
				$contactinst=$geti->[0];
			}
			if ($contactinst ne "") {		
				$sth_getmentors = $dbh->prepare("SELECT distinct $grouprole.person_id,name_first,name_last,$grouprole.group_name,$grouprole.role_name,$grouprole.subrole_name from $grouprole,$peopletab WHERE $grouprole.person_id=$peopletab.person_id and $grouprole.role_name=upper('$contactinst') and $grouprole.group_name not like '%Reminder%'");
				if (!defined $sth_getmentors) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getmentors->execute;
				while ($getmentors = $sth_getmentors->fetch) {
					if ($countmnt == 0) {
						$mentorlist = "$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5]";
					} else {
						$mentorlist = "$mentorlist"."<br>"."$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5]";
					}
					$countmnt = $countmnt + 1;
				}
				$sth_getmentors = $dbh->prepare("SELECT distinct instContacts.contact_id,name_first,name_last,instContacts.group_name,instContacts.role_name,instContacts.subrole_name from instContacts,$peopletab WHERE instContacts.role_name=upper('$contactinst') and instContacts.contact_id=$peopletab.person_id AND instContacts.contact_id not in (SELECT distinct person_id from $grouprole where $grouprole.role_name=upper('$contactinst'))");
				if (!defined $sth_getmentors) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getmentors->execute;
				while ($getmentors = $sth_getmentors->fetch) {
					if ($countmnt == 0) {
						$mentorlist = "$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5] <font color=red><strong>*</strong></font>";
					} else {
						$mentorlist = "$mentorlist"."<br>"."$getmentors->[1] $getmentors->[2] - $getmentors->[3] $getmentors->[5] <font color=red><strong>*</strong></font>";
					}
					$countmnt = $countmnt + 1;
				}
			} else {
				$countmnt=0;
				$mentorlist="";
			}				
			if ($mentorlist ne "") {
				print "<td width=20%>$mentorlist</td>";
			} else {
				print "<td width=20%><font color=red><strong>NOT DEFINED YET</strong></font></td>";
			}
			print "<td>\n";
			##### instrument category check
			$countic=0;
			$sth_getinstcat=$dbh->prepare("SELECT distinct inst_category_code,statusFlag from instCats where IDNo=$Idno order by inst_category_code");
			if (!defined $sth_getinstcat) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getinstcat->execute;
			while ($getinstcat = $sth_getinstcat->fetch) {
				if ($countic == 0) {
					print "$getinstcat->[0]";
					$countic = $countic + 1;
				} else {
					print "<br />$getinstcat->[0]";
					$countic = $countic + 1;
				}
			}
			$matchit=0;
			$sth_getcurcats = $dbh->prepare("SELECT distinct $archivedb.$sitetoinstrinfotab.instrument_category_code,$archivedb.$sitetoinstrinfotab.instrument_category_code from $archivedb.$sitetoinstrinfotab,$archivedb.$dsinfotab WHERE $archivedb.$sitetoinstrinfotab.instrument_code=$archivedb.$dsinfotab.instrument_code and $archivedb.$sitetoinstrinfotab.instrument_code='$dsBase' and $archivedb.$dsinfotab.data_level_code='$dataLevel' order by $archivedb.$sitetoinstrinfotab.instrument_category_code");
			if (!defined $sth_getcurcats) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcurcats->execute;
			while ($getcurcats = $sth_getcurcats->fetch) {
				$matchit=0;
				$sth_checkic = $dbh->prepare("SELECT count(*),count(*) from instCats where IDNo=$getDS->[0] and inst_category_code='$getcurcats->[0]'");
				if (!defined $sth_checkic) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkic->execute;
				while ($checkic = $sth_checkic->fetch) {
					$matchit=$checkic->[0];
				}
				if ($countic > 0) {
					print "<br />$getcurcats0->[0] ";
					$countminus = $countminus + 1;
					$checkstatthisone = $checkstatthisone + 1;
				} else {
					print "$getcurcats->[0] ";
					$countminus = $countminus + 1;
					$checkstatthisone = $checkstatthisone + 1;
				}
				$countic = $countic + 1;
			}
						
			if ($countic == 0) {
				$ticl="";
				# check to see if there is an inst category assigned to this instrument class elsewhere
				$tempclass="";
				$sth_getinstcl = $dbh->prepare("SELECT distinct IDNo,instrument_class from instClass where IDNo=$getDS->[0] order by IDNo");
				if (!defined $sth_getinstcl) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getinstcl->execute;
				while ($getinstcl = $sth_getinstcl->fetch) {
					$tempclass=$getinstcl->[1];
				}
				$sth_getidsno=$dbh->prepare("SELECT distinct IDNo,instrument_class from instClass where instrument_class='$tempclass'");
				if (!defined $sth_getidsno) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getidsno->execute;
				while ($getidsno = $sth_getidsno->fetch) {
					$sth_checkicagain = $dbh->prepare("SELECT inst_category_code,inst_category_code from instCats where IDNo=$getidsno->[0]");
					if (!defined $sth_checkicagain) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkicagain->execute;
					while ($checkicagain = $sth_checkicagain->fetch) {
						$ticl=$checkicagain->[0];
					}
				}
				if ($ticl ne "") {
					print "$ticl";
				} else {
					$sth_checkarchive=$dbh->prepare("SELECT distinct instrument_category_code,instrument_category_code from $archivedb.$sitetoinstrinfotab where lower(instrument_class_code)=lower('$tempclass')");
					if (!defined $sth_checkarchive) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkarchive->execute;
					while ($checkarchive = $sth_checkarchive->fetch) {
						$ticl=$checkarchive->[0];
					}
					if ($ticl ne "") {
						print "$ticl";
					} else {
						print " Not assigned";
					}
				}
			}
			print "</td><td>\n";
			##### end instrument category check
			$countinstc=0;
			$sth_getinstcl = $dbh->prepare("SELECT distinct instrument_class,statusFlag from instClass where IDNo=$getDS->[0] order by instrument_class");
			if (!defined $sth_getinstcl) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getinstcl->execute;
			while ($getinstcl = $sth_getinstcl->fetch) {
				if ($countinstc == 0) {
					if ($getinstcl->[1] == 0) {
						print "<font color=red><strong>$getinstcl->[0]</strong></font>";
					} else {
						print "$getinstcl->[0]";
					}
				} else {
					if ($getinstcl->[1] == 0) {
						print "<br /><font color=red><strong>$getinstcl->[0]</strong></font>";
					} else {
						print "<br />$getinstcl->[0]";
					}
				}
				$countinstc = $countinstc + 1;
			}
			$sth_getcurinst = $dbh->prepare("SELECT distinct instrument_code,instrument_class_code from $archivedb.$instrcodetoinstrclasstab where instrument_code='$dsBase' order by instrument_code,instrument_class_code");
			if (!defined $sth_getcurinst) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcurinst->execute;
			while ($getcurinst = $sth_getcurinst->fetch) {
				$matchit=0;
				$sth_checkic = $dbh->prepare("SELECT count(*),count(*) from instClass where IDNo=$getDS->[0] and instrument_class='$getcurinst->[1]'");
				if (!defined $sth_checkic) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkic->execute;
				while ($checkic = $sth_checkic->fetch) {
					$matchit = $checkic->[0];
				}
				if ($matchit == 0) {
					if ($countinstc == 0) {
						print "<font color=red>$getcurinst->[1] <strong>\-</font></strong>";
					} else {
						print "<br /><font color=red>$getcurinst->[1] <strong>\-</font></strong>";
					}
					$countminus = $countminus + 1;
					$checkstatthisone = $checkstatthisone + 1;
				}
				$countinstc = $countinstc + 1;
			}
			if ($countinstc == 0) {
				print " Not assigned";
			}
			print "</td>\n";
			print "<td>\n";
			$countsc=0;
			$sth_getscl = $dbh->prepare("SELECT distinct source_class,statusFlag from sourceClass where IDNo=$getDS->[0] order by source_class");
			if (!defined $sth_getscl) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getscl->execute;
			while ($getscl = $sth_getscl->fetch) {
				if ($countsc == 0) {
					if ($getscl->[1] == 0) {
						print "<font color=red><strong>$getscl->[0]</strong></font>\n";
					} else {
						print "$getscl->[0]";
					}
				} else {
					if ($getscl->[1] == 0) {
						print "<br /><font color=red><strong>$getscl->[0]</strong></font>\n";
					} else {
						print "<br />$getscl->[0]";
					}
				}
				$countsc = $countsc + 1;
			}
			$tempsclist="";
			$sth_getcursources = $dbh->prepare("SELECT distinct instrument_code,source_class_code,data_level_code from $archivedb.$dsinfotab where instrument_code='$dsBase' and data_level_code='$dataLevel' order by source_class_code");
			if (!defined $sth_getcursources) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcursources->execute;
			while ($getcursources = $sth_getcursources->fetch) {
				$matchit=0;	
				$sth_checkcursc = $dbh->prepare("SELECT IDNo,statusFlag from sourceClass where IDNo=$getDS->[0] and source_class='$getcursources->[1]' and statusFlag=1");
				if (!defined $sth_checkcursc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkcursc->execute;
				while ($checkcursc = $sth_checkcursc->fetch) {
					$matchit = $checkcursc->[0];
				}
				if ($matchit == 0) {
					if ($countsc > 0) {
						print "<br><font color=red>$getcursources->[1] \-</strong></font>";
					} else {
						print "<font color=red>$getcursources->[1] <strong>\-</strong></font>";
					}
					$countsc = $countsc + 1;
					$countminus = $countminus + 1;
					$checkstatthisone = $checkstatthisone + 1;
				}
			}
			if ($countsc == 0) {
				print " Not assigned";
			}
			print " </td>";
			print "<td>\n";
			$countmc=0;
			$sth_getmeascat=$dbh->prepare("SELECT distinct meas_category_code,meas_subcategory_code,statusFlag from measCats where IDNo=$getDS->[0] order by meas_category_code,meas_subcategory_code");
			if (!defined $sth_getmeascat) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmeascat->execute;
			while ($getmeascat = $sth_getmeascat->fetch) {
				if ($countmc == 0) {
					if ($getmeascat->[1] ne "") {
						if ($getmeascat->[2] == 0) {		
							print "<font color=red><strong>$getmeascat->[0]: $getmeascat->[1]</strong></font>\n";
						} else {
							print "$getmeascat->[0]: $getmeascat->[1]";
						}
					} else {
						if ($getmeascat->[2] == 0) {
							print "<font color=red><strong>$getmeascat->[0]: N/A </strong></font>";
						} else {
							print "$getmeascat->[0]: N/A";
						}
					}
				} else {
					if ($getmeascat->[1] ne "") {
						if ($getmeascat->[2] == 0) {
							print "<br /><font color=red><strong>$getmeascat->[0]: $getmeascat->[1]</strong></font>";
						} else {
							print "<br />$getmeascat->[0]: $getmeascat->[1] ";
						}
					} else {							
						if ($getmeascat->[2] == 0) {
							print "<br /><font color=red><strong>$getmeascat->[0]: N/A</strong></font>";
						} else {
							print "<br />$getmeascat->[0]: N/A";
						}
					}
				}
				$countmc = $countmc + 1;
			}
			$sth_getcurcats = $dbh->prepare("SELECT distinct $archivedb.$dsvarnamemeascatstab.meas_category_code,$archivedb.$dsvarnamemeascatstab.meas_category_code,$archivedb.$dsvarnamemeascatstab.meas_subcategory_code from $archivedb.$dsvarnamemeascatstab where $archivedb.$dsvarnamemeascatstab.datastream like '%$dsBase%$dataLevel' order by $archivedb.$dsvarnamemeascatstab.meas_category_code,$archivedb.$dsvarnamemeascatstab.meas_subcategory_code");
			if (!defined $sth_getcurcats) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcurcats->execute;
			while ($getcurcats = $sth_getcurcats->fetch) {
				$matchit=0;
				$sth_checkmeas = $dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$getDS->[0] and meas_category_code like '%$getcurcats->[1]%' and meas_subcategory_code like '%$getcurcats->[2]%'");
				if (!defined $sth_checkmeas) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkmeas->execute;
				while ($checkmeas = $sth_checkmeas->fetch) {
					$matchit=$checkmeas->[0];
				}
				if ($matchit == 0) {
					if ($countmc > 0) {
						print "<br /><font color=red>$getcurcats->[1]: $getcurcats->[2] \-</font></strong>";
						$countminus = $countminus + 1;
						$checkstatthisone = $checkstatthisone + 1;
					} else {
						print "<font color=red>$getcurcats->[1]: $getcurcats->[2] <strong>\-</font></strong>";
						$countminus = $countminus + 1;
						$checkstatthisone = $checkstatthisone + 1;
					}
					$countmc = $countmc + 1;
				}
			}
			if ($countmc == 0) {
				print " Not assigned\n";
			}
			print "</td>";
			print "<td>";
			$countit = 0;		
			$sth_getprimmeasmetadata=$dbh->prepare("SELECT count(*),count(*) from primMeas where IDNo=$Idno and statusFlag !=0");
			if (!defined $sth_getprimmeasmetadata) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getprimmeasmetadata->execute;
			while ($getprimmeasmetadata = $sth_getprimmeasmetadata->fetch) {			
				if ($getprimmeasmetadata->[0] > 0) {
					$curpm="";
					$curprimmeas="";
					$curvar="";
					$sth_getpmname=$dbh->prepare("SELECT distinct IDNo,primary_meas_code,primary_measurement,var_name from primMeas where IDNo=$Idno and statusFlag !=0 order by primary_meas_code");
					if (!defined $sth_getpmname) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getpmname->execute;
					while ($getpmname = $sth_getpmname->fetch) {
						$curpm=$getpmname->[1];
						$curprimmeas=$getpmname->[2];
						if ($getpmname->[3] eq "")  {
							$curvar="NULL";
						} else {
							$curvar="\'"."$getpmname->[3]"."\'";
						}
						$fincheck=0;
						$instclassstring="";
						$originstclassstring="";
						$sth_getcurinstclass=$dbh->prepare("SELECT distinct instrument_class,instrument_class from instClass where IDNo=$Idno order by instrument_class");
						if (!defined $sth_getcurinstclass) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getcurinstclass->execute;
						while ($getcurinstclass = $sth_getcurinstclass->fetch) {
							$originstclassstring=$getcurinstclass->[0];
							$instclassstring="%$getcurinstclass->[0]%";
							$sourceclassstring="";
							$origsourceclassstring="";
							$sth_getcursourceclass = $dbh->prepare("SELECT distinct source_class,source_class from sourceClass where IDNo=$Idno order by source_class");
							if (!defined $sth_getcursourceclass) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_getcursourceclass->execute;
							while ($getcursourceclass = $sth_getcursourceclass->fetch) {
								$origsourceclassstring=$getcursourceclass->[0];
								$sourceclassstring = "%$getcursourceclass->[0]%";
								$sth_checksourceinst=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclasstosourceclass WHERE instrument_class_code='$originstclassstring' and source_class_code='$origsourceclassstring'");
								if (!defined $sth_checksourceinst) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checksourceinst->execute;
								while ($checksourceinst = $sth_checksourceinst->fetch) {
									if ($checksourceinst->[0] > 0) {
										$sth_checkpminst=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetoinstrclass where instrument_class_code='$originstclassstring' AND primary_meas_type_code='$curpm'");
										if (!defined $sth_checkpminst) { die "Cannot  statement: $DBI::errstr\n"; }
										$sth_checkpminst->execute;
										while ($checkpminst = $sth_checkpminst->fetch) {
											if ($checkpminst->[0] > 0) {
												$sth_checkprimmeas = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$dsvarnameinfotab WHERE $archivedb.$dsvarnameinfotab.datastream like '%$dsBase%' and $archivedb.$dsvarnameinfotab.primary_meas_type_code='$curpm' and $archivedb.$dsvarnameinfotab.primary_measurement='$curprimmeas' and $archivedb.$dsvarnameinfotab.var_name=$curvar");
												if (!defined $sth_checkprimmeas) { die "Cannot  statement: $DBI::errstr\n"; }
												$sth_checkprimmeas->execute;
												while ($checkprimmeas = $sth_checkprimmeas->fetch) {
													if ($checkprimmeas->[0] > 0) {
														$fincheck = $fincheck + 1;
													}
												}
											}
										}
									}
								}	
							}
						}
						if ($countit == 0) {
							if ($fincheck == 0) {
								print "$getpmname->[1]:$getpmname->[3]:$getpmname->[2]<strong><font color=\"red\">*</font></strong>\n";
								$countstar = $countstar + 1;
							} else {
								print "$getpmname->[1]: $getpmname->[3]: $getpmname->[2]\n";
							}
						} else {
							if ($fincheck == 0) {
								print "<br />$getpmname->[1]: $getpmname->[3]: $getpmname->[2]<strong><font color=\"red\">*</font></strong>\n";
								$countstar = $countstar + 1;
							} else {
								print "<br />$getpmname->[1]: $getpmname->[3]: $getpmname->[2]\n";
							}
						}
						$countit = $countit + 1;
					}
				}
			}
			$sth_getprimmeasmetadata=$dbh->prepare("SELECT count(*),count(*) from primMeas where IDNo=$Idno and statusFlag=0");
			if (!defined $sth_getprimmeasmetadata) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getprimmeasmetadata->execute;
			while ($getprimmeasmetadata = $sth_getprimmeasmetadata->fetch) {
				if ($getprimmeasmetadata->[0] > 0) {
					$sth_getpmname=$dbh->prepare("SELECT distinct IDNo,primary_meas_code,primary_measurement,var_name from primMeas where IDNo=$Idno and statusFlag=0 order by primary_meas_code,primary_measurement");
					if (!defined $sth_getpmname) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getpmname->execute;
					while ($getpmname = $sth_getpmname->fetch) {
						if ($countit == 0) {
							print "<strong><font color=\"red\"><strong>$getpmname->[1]: $getpmname->[3]: $getpmname->[2]</font></strong>\n";
						} else {
							print "<br /><strong><font color=\"red\">$getpmname->[1]: $getpmname->[3]: $getpmname->[2]</font></strong>\n";
						}
						$countit = $countit + 1;
					}
				}
			}	
			if ($countit == 0) {
				print " Not assigned\n";
			}
			print " </td>\n";
		} 
		$REVstatdesc="";
		$sth_getstatdesc=$dbh->prepare("SELECT status,statusDesc from revStatus where status=$REVstat");
		if (!defined $sth_getstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getstatdesc->execute;
		while ($getstatdesc = $sth_getstatdesc->fetch) {
			$REVstatdesc=$getstatdesc->[1];
		}	
		$DBstatdesc="";
		$sth_getDBstatdesc=$dbh->prepare("SELECT status,statusDesc from status where status=$DBstat");
		if (!defined $sth_getDBstatdesc) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getDBstatdesc->execute;
		while ($getDBstatdesc = $sth_getDBstatdesc->fetch) {
			$DBstatdesc=$getDBstatdesc->[1];
		}
		$fontcolor="black";
		$dbfontcolor="black";
		if ($REVstat == 0) {
			$fontcolor="red";
		}
		if ($REVstat == 1) {
			$fontcolor="green";
		}
		if (($DBstat == 0) || ($DBstat == 1) || ($DBstat == -1)) {
			$dbfontcolor="blue";
		}
		print "<td><font color=$fontcolor><strong>$REVstatdesc</strong></font></td>";
		print "</tr>\n";
	}
	print "</table>\n";
	print "<small><font color=blue><strong>BLUE DS Class/Data Level = existing</strong></font></small><br>\n";
	print "<small><font color=red><strong>RED DS Class/Data Level, Inst Class, PMT = new (proposed)</strong></font></small><br>\n";
	if ($countstar > 0) {
		print "<small><font color=red><strong>* = fields being updated/added in this review or defined elsewhere</strong></font></small><br>\n";
	}
	if ($countminus > 0) {
		print "<small><font color=red><strong>- = fields being removed as part of the update in review</strong></font></small><br>\n";
	}
	if ($numofcomments > 0) {
		print "<small><font color=green><strong>(c) = Submission contains comments</strong></font></small><p>";
	}
	print "</div>\n";
	print "<p>\n";
	$dbh->disconnect();
}
######################################################
# subroutine to display ds detailed assignment section
sub displaydsMDdetails 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      	
	my $IDNo = shift;
	my $Idno="";
	my $DBstat="";
	my $REVstat="";	
	my $mcatfilt= shift;
	$sth_getIDs = $dbh->prepare("SELECT IDNo,type,revStatus,DBstatus from IDs where IDNo=$IDNo");	
	if (!defined $sth_getIDs) { die "Cannot  statement: $DBI::errstr\n"; }	
	$sth_getIDs->execute;
	while ($getIDs = $sth_getIDs->fetch) {
		$Idno = $getIDs->[0];
		$REVstat=$getIDs->[2];
		$DBstat=$getIDs->[3];
		# first check approval status of this DS corresponding DOD in MMT if it exists\n";
		$chkdsbase="";
		$chkdatalevel="";
		$chkDODversion="";
		$sth_getdsinfo=$dbh->prepare("SELECT dsBase,dataLevel,DODversion from DS where IDNo=$Idno");
		if (!defined $sth_getdsinfo) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdsinfo->execute;
		while ($getdsinfo = $sth_getdsinfo->fetch) {
			$chkdsbase=$getdsinfo->[0];
			$dsBase=$getdsinfo->[0]; #need later!
			$chkdsdatalevel=$getdsinfo->[1];
			$dataLevel=$getdsinfo->[1];  # need later !
			$chkDODversion=$getdsinfo->[2];
		}
		$tdodno="";
		$sth_chkdod=$dbh->prepare("SELECT IDNo,dsBase,dataLevel,DODversion from DOD where dsBase='$chkdsbase' and dataLevel='$chkdsdatalevel' and DODversion='$chkDODversion'");
		if (!defined $sth_chkdod) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_chkdod->execute;
		while ($chkdod = $sth_chkdod->fetch) {
			$tdodno=$chkdod->[0];
		}		
		if ($tdodno ne "") {
			$ct=0;
			$thisdodfacs="";
			$sth_chkdodfacs = $dbh->prepare("SELECT distinct site,facility_code from facilities where IDNo=$tdodno order by site,facility_code");
			if (!defined $sth_chkdodfacs) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_chkdodfacs->execute;
			while ($chkdodfacs = $sth_chkdodfacs->fetch) {
				if ($ct == 0) {
					$thisdodfacs="$chkdodfacs->[0]:$chkdodfacs->[1]";
				} else {
					$thisdodfacs="$thisdodfacs,$chkdodfacs->[0]:$chkdodfacs->[1]";
				}
				$ct = $ct + 1;
			}
			$thisdodfacs="("."$thisdodfacs".")";			
		}
		$stmessage="";
		if ($tdodno ne "") {
			$sth_getstat=$dbh->prepare("SELECT IDNo,revStatus from IDs where IDNo=$tdodno");
			if (!defined $sth_getstat) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getstat->execute;
			while ($getstat = $sth_getstat->fetch) {
				if ($getstat->[1] < 2) {
					$stmessage="DOD HAS NOT BEEN APPROVED YET! USE CAUTION IN ASSIGNING DS METADATA BELOW AS INST CLASS AND PRIMARY VARIABLES MAY CHANGE DURING DOD REVIEW";
				} else {
					$stmessage="";
				}
			}
		}
		print "<table>\n";
		print "<tr><th rowspan=1 colspan=3 bgcolor=\"#FFF999\"><font color=red align=left>Assign Metadata</font>";
		if ($stmessage ne "") {
			print "<font color=red>: NOTE TO MD EXPERTS: $stmessage</font>\n";
		}
		print "</th></tr>\n";
		print "<tr><th>Metadata Type</th><th align=center>Available in Archive, MMT and/or DSDB</th><th width=60%>Current Associations in MMT</th></tr>\n";
		print "<tr>\n";
		$countlist=0;
		print "<td><strong>INSTRUMENT CLASS</strong></td>\n";
		print "<td><SELECT name=\"new_inst_class\" size=8>";
		$countclass=0;
		@displayInstClass=();
		$countdisplayintcl=0;
		$sth_getinstclassarchive=$dbh->prepare("SELECT distinct $archivedb.$instrclassdetailstab.instrument_class_code,$archivedb.$instrclassdetailstab.instrument_class_name from $archivedb.$instrclassdetailstab ORDER by $archivedb.$instrclassdetailstab.instrument_class_code");
		if (!defined $sth_getinstclassarchive) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getinstclassarchive->execute;
		while ($getinstclassarchive = $sth_getinstclassarchive->fetch) {
			$inst_class=$getinstclassarchive->[0];
			$inst_class_name=$getinstclassarchive->[1];
			$displayInstClass[$countdisplayintcl]="$inst_class"."|"."$inst_class_name"."|"." ";
			$countdisplayintcl = $countdisplayintcl + 1;
		}
		$sth_getinstclassprop=$dbh->prepare("SELECT distinct instClass.instrument_class,instClass.instrument_class_name from instClass WHERE statusFlag=0 and instClass.instrument_class not in (SELECT distinct $archivedb.$instrclassdetailstab.instrument_class_code from $archivedb.$instrclassdetailstab) ORDER by instrument_class");
		if (!defined $sth_getinstclassprop) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getinstclassprop->execute;
		while ($getinstclassprop = $sth_getinstclassprop->fetch) {
			$inst_class=$getinstclassprop->[0];
			$inst_class_name=$getinstclassprop->[1];
			$displayInstClass[$countdisplayintcl]="$inst_class"."|"."$inst_class_name"."|"."****";
			$countdisplayintcl = $countdisplayintcl + 1;
		}
		@sortdisplayinstclass=();
		@sortdisplayinstclass=sort @displayInstClass;
		foreach $sdic (@sortdisplayinstclass) {
			@newicarray=();
			@newicarray=split(/\|/,$sdic);
			if ($newicarray[1] ne "") {
				if ($newicarray[2] eq "****") {	
					print "<OPTION class=\"red\" value=\"$newicarray[0]\">$newicarray[0] ($newicarray[1])</OPTION>\n";
				} else {
					print "<OPTION value=\"$newicarray[0]\">$newicarray[0] ($newicarray[1])</OPTION>\n";
				}
			} else {
				if ($newicarray[2] eq "****") {
					print "<OPTION class=\"red\" value=\"$newicarray[0]\">$$newicarray[0]</OPTION>\n";
				} else {
					print "<OPTION value=\"$newicarray[0]\">$newicarray[0]</option>\n";
				}
			} 
		}
		print "</SELECT><br><small><font color=red><i>RED=new objects proposed in MMT</i></font></small></TD>\n";
		print "<td witdh=60%><SELECT name=\"curr_inst_class\" size=8 multiple>\n";
		$countinstclass=0;
		@iclist=();
		$oldinst_class="";
		$sth_getcurrentasso=$dbh->prepare("SELECT distinct IDNo,instClass.instrument_class,statusFlag from instClass where IDNo=$Idno order by instClass.instrument_class");
		if (!defined $sth_getcurrentasso) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getcurrentasso->execute;
		while ($getcurrentasso = $sth_getcurrentasso->fetch) {
			$oldinst_class=$getcurrentasso->[1];
			$statusFlag=$getcurrentasso->[2];
			if ($statusFlag == 0) {
				$instclassname="";
				$instcatcodename="";
				$sth_getinstname=$dbh->prepare("SELECT instrument_class,instrument_class_name from instClass where IDNo=$Idno and instrument_class='$oldinst_class'");
				if (!defined $sth_getinstname) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getinstname->execute;
				while ($getinstname = $sth_getinstname->fetch) {
					$instclassname=$getinstname->[1];
				}
				if ($instclassname ne "") {
					print "<OPTION value=\"$oldinst_class\">$oldinst_class ($instclassname)</OPTION>\n";
				} else {
					print "<OPTION value=\"$oldinst_class\">$oldinst_class</OPTION>\n";
				}
			} else {
				print "<OPTION value=\"$oldinst_class\">$oldinst_class</OPTION>\n";
			}
			$iclist[$countinstclass] = $oldinst_class;
			$countinstclass = $countinstclass + 1;
		}
		print "</SELECT></TD></TR>\n";
		if (($countinstclass > 0) || ($keeppms == 1))  {
			print "<tr>\n";
			print "<td><strong>Source ClassES</strong></td> <td><SELECT name=\"new_source_class\" size=8 multiple>";
			$countlist=0;
			@source_class=();
			foreach $iclist (@iclist) {
				$sth_getsourceclassarchive=$dbh->prepare("SELECT distinct lower(source_class_code) from $archivedb.$sourceclassdetails order by source_class_code");
				if (!defined $sth_getsourceclassarchive) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getsourceclassarchive->execute;
				while ($getsourceclassarchive = $sth_getsourceclassarchive->fetch) {
					$sc=$getsourceclassarchive->[0];
					$source_class[$countlist]=$sc;
					$countlist = $countlist + 1;
				}	
			}
			@sortedsc=();
			@sortedsc=sort @source_class;
			$ossc="";
			foreach $sortedsc (@sortedsc) {
				if ($sortedsc ne $ossc) {
					$source_class="";
					$source_class_name="";
					$sth_getscname=$dbh->prepare("SELECT distinct lower(source_class_code),source_class_name from $archivedb.$sourceclassdetails where lower(source_class_code)='$sortedsc'");
					if (!defined $sth_getscname) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getscname->execute;
					while ($getscname = $sth_getscname->fetch) {
						$source_class=$getscname->[0];
						$source_class_name=$getscname->[1];
					}
					print "<OPTION value=\"$source_class\">$source_class ($source_class_name)</OPTION>\n";
					$ossc=$sortedsc;
				}
			}
			print "</SELECT></TD>\n";
			print "<td>\n";
			print "<SELECT name=\"curr_source_class\" size=8 multiple>\n";
			$countsc = 0;
			@sclist=();
			$sth_getcurrentsourceasso=$dbh->prepare("SELECT distinct IDNo,source_class,statusFlag from sourceClass where IDNo=$Idno order by source_class");
			if (!defined $sth_getcurrentsourceasso) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcurrentsourceasso->execute;
			while ($getcurrentsourceasso = $sth_getcurrentsourceasso->fetch) {
				$sclist[$countsc]=$getcurrentsourceasso->[1];
				$oldsource_class=$getcurrentsourceasso->[1];
				$statusFlag=$getcurrentsourceasso->[2];
				if ($statusFlag == 0) {
					print "<OPTION value=\"$oldsource_class\">$oldsource_class *</OPTION>\n";
				} else {
					print "<OPTION value=\"$oldsource_class\">$oldsource_class</OPTION>\n";
				}
				$countsc = $countsc + 1;
			}
			print "</SELECT></TD></TR>\n";
		} else {
			$countsc = 0;
		}
		if ($countsc > 0) {

			print "<tr><td><strong>PRIMARY MEAS TYPES:PRIMARY VARS<br /><i><font color=blue><small><br>";
			print "Primary Variables for this datastream class must be <font color=red>defined in the DOD in the <a href=\"https://pcm.arm.gov/pcm/\" target=pcm\">PCM</a> first</font> before Primary Measurement Types (PMTs) can be associated with them</i></font></small></strong></td>";				
			@pm=();
			$countlist=0;
			@mcatArray=();
			if ($mcatfilt ne "") {
				@mcatArray=split(/\0/,$mcatfilt);
			} 
			# get pmts....
			if (($mcatArray[0] eq "All") || ($mcatArray[0] eq "")) {
				$sth_getprimmeasarchive=$dbh->prepare("SELECT distinct $archivedb.$pmcodetomeascatalllower.primary_meas_type_code,$archivedb.$pmcodetomeascatalllower.primary_meas_type_code from $archivedb.$pmcodetomeascatalllower WHERE primary_meas_type_code not like 'PMCOD%' and primary_meas_type_code NOT LIKE 'Primary_Meas_Cod%' order by $archivedb.$pmcodetomeascatalllower.primary_meas_type_code");
				if (!defined $sth_getprimmeasarchive) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getprimmeasarchive->execute;
				while ($getprimmeasarchive = $sth_getprimmeasarchive->fetch) {
					$pm[$countlist]="$getprimmeasarchive->[0]"."|"." ";
					$countlist = $countlist + 1;
				}
			} else {			
				foreach $pmtomc (@mcatArray) {
					$sth_getprimmeasarchive=$dbh->prepare("SELECT distinct $archivedb.$pmcodetomeascatalllower.primary_meas_type_code,$archivedb.$pmcodetomeascatalllower.primary_meas_type_code from $archivedb.$pmcodetomeascatalllower WHERE meas_category_code='$pmtomc' AND primary_meas_type_code not like 'PMCOD%' and primary_meas_type_code NOT LIKE 'Primary_Meas_Cod%' order by $archivedb.$pmcodetomeascatalllower.primary_meas_type_code");
					if (!defined $sth_getprimmeasarchive) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getprimmeasarchive->execute;
					while ($getprimmeasarchive = $sth_getprimmeasarchive->fetch) {
						$pm[$countlist]="$getprimmeasarchive->[0]"."|"." ";
						$countlist = $countlist + 1;
					}
				}
			}
			if (($mcatArray[0] eq "All") || ($mcatArray[0] eq "")) {
				$sth_getprimmeasprop=$dbh->prepare("SELECT distinct primary_meas_code,primary_meas_code from primMeas where statusFlag=0 order by primary_meas_code");
				if (!defined $sth_getprimmeasprop) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getprimmeasprop->execute;
				while ($getprimmeasprop = $sth_getprimmeasprop->fetch) {
					$pm[$countlist]="$getprimmeasprop->[0]"."|"."****";
					$countlist = $countlist + 1;
				}
			} else {
				foreach $pmmc ($sth_mcatArray) {
					$sth_getprimmeasprop=$dbh->prepare("SELECT distinct primary_meas_code,primary_meas_code from primMeas,measCats where primMeas.statusFlag=0 and primMeas.IDNo=measCats.IDNo and meas_category_code='$pmmc'");
					if (!defined $sth_getprimmeasprop) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getprimmeasprop->execute;
					while ($getprimmeasprop = $sth_getprimmeasprop->fetch) {
						$pm[$countlist]="$getprimmeasprop->[0]"."|"."****";
						$countlist = $countlist + 1;
					}
				}
			}
			if ($countlist > 0) {
				$fromlist[0]=1;
			} else {
				$fromlist[0]=0;
			}
			if (($fromlist[1] > 0) || ($fromlist[0] > 0)) {
				@stdpm=();
				@stdpm=sort @pm;
				$oldstdpm="";
				print "<td width=10%><table border=\"0\" rules=\"none\"><tr><td>PM Types<br><SELECT name=\"new_prim_measB\" size=8>";
				foreach $sp (@stdpm) {
					if ($sp ne $oldstdpm) {
						@breakpm=();
						@breakpm=split(/\|/,$sp);
						if ($breakpm[1] eq "****") {
							print "<OPTION class=\"red\" VALUE=\"$breakpm[0]\">$breakpm[0]</OPTION>\n";
						} else {
							print "<OPTION VALUE=\"$breakpm[0]\">$breakpm[0]</OPTION>\n";
						}
					}
					$oldstdpm=$sp;
				}
				print "</SELECT><br><small><font color=red><i>RED=new objects proposed in MMT</i></font></small>\n";
				$countmcat=0;
				$countmcat=@mcatArray;
				if (($mcatArray[0] eq "All") || ($mcatArray[0] eq "")) {
					print "<br><input type=\"checkbox\" name=\"mcatfilt\" value=\"All\" checked>All";
					
					$sth_getmeascats=$dbh->prepare("SELECT distinct meas_category_code,meas_category_name from $archivedb.$meascatdetailstab order by meas_category_code");
					if (!defined $sth_getmeascats) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getmeascats->execute;
					while ($getmeascats = $sth_getmeascats->fetch) {
						print "<br><input type=\"checkbox\" name=\"mcatfilt\" value=\"$getmeascats->[0]\">$getmeascats->[0]";
					}
				} else {
					print "<br><input type=\"checkbox\" name=\"mcatfilt\" value=\"All\">All";
					$sth_getmeascats=$dbh->prepare("SELECT distinct meas_category_code,meas_category_name from $archivedb.$meascatdetailstab order by meas_category_code");
					if (!defined $sth_getmeascats) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getmeascats->execute;
					while ($getmeascats = $sth_getmeascats->fetch) {
						$match=0;
						foreach $mc (@mcatArray) {
							if ($mc eq "$getmeascats->[0]") {
								$match=1;	
							}
						}
						if ($match == 1) {
							print "<br><input type=\"checkbox\" name=\"mcatfilt\" value=\"$getmeascats->[0]\" checked>$getmeascats->[0]";
						} else {
							print "<br><input type=\"checkbox\" name=\"mcatfilt\" value=\"$getmeascats->[0]\">$getmeascats->[0]";
						}
					}
				}
				print "<br><small><input type=\"submit\" name=\"submit\" value=\"FILTER BY MEASCAT\"></small>\n";
				print "</td><td align=\"top\">";
				$oldpme="";
				$inx=0;
				@pmeas=();
				@pmeasloc=();
				@pmeaskey=();
				@fromwhichdb=();
				@sortedpmeas=();
				$countlist=0;
				@fromlist=(0,0);
				##################
				# gather a union of both arm archive primary measurements and primary variables from dsdb
				##################
				foreach $iclist (@iclist) {
					foreach $sclist (@sclist) {
						$sth_getprimmeasarchive=$dbh->prepare("SELECT distinct primary_measurement,var_name FROM $archivedb.$dsvarnameinfotab dvi inner join $archivedb.$dsinfotab di on dvi.datastream=di.datastream WHERE instrument_class_code='$iclist' AND instrument_code='$dsBase' AND source_class_code='$sclist' AND data_level_code='$dataLevel' ORDER by primary_measurement");
						if (!defined $sth_getprimmeasarchive) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getprimmeasarchive->execute;
						while ($getprimmeasarchive = $sth_getprimmeasarchive->fetch) {
							$pmeas[$countlist]=$getprimmeasarchive->[0];
							$pmeaskey[$countlist]=$getprimmeasarchive->[1];
							$pmeasloc[$countlist]="()";
							$fromwhichdb[$countlist]="ARCHIVEDB";
							$countlist = $countlist + 1;
							$fromlist[0]=1;
						}
					}
				}
				$fromlist[1]=0;
				#################
				################# ISSUE DISCOVERED 20150804!!!  We are not getting version specific, nor site/fac specific DOD info from web service
				################# We get back every variable for a datastream class and data level!
				#################
				################# work around.  Will have DOD version from approved DOD in MMT (DS table;DODversion field).  Pass DOD version to web service
				################# and only get back variables for a specific dod version!
				my $www = new LWP::UserAgent;
				my $req = new HTTP::Request( GET=> "https://engineering.arm.gov/dsdb/cgi-bin/procdb?action=ds-get-dod-vars&class=$dsBase&level=$dataLevel&version=$DODversion");
				$req->content_type('application/x-www-form-urlencoded');
				my $response = $www->request($req);
				exit(1) unless ($response->is_success);
				if ($response) {
					my $decoded_ref = JSON::XS::decode_json($response->content);
					while (($key,$value) = each %{$decoded_ref}) {
						$pmeas[$countlist]="$value->{'long_name'}";
						$lc="";
						while (($k, $v) = each %{$value->{'locations'}} ) {		
							if ($lc eq "") {
								$lc = "$k";
							} else {
								$lc = "$lc".","."$k";
							}
						}
						$_=$lc;
						s/\./\:/g;
						$lc=$_;
						$lc=uc($lc);
						$pmeasloc[$countlist]="($lc)";
						$pmeaskey[$countlist]=$key;
						$fromwhichdb[$countlist]="DSDB";
						$countlist = $countlist + 1;
						$fromlist[1]=1;
					}
				} else {	
					$dbh->disconnect();
					exit;
				}
				# sort the full list of pm
				$mergeidx=0;
				@mergpmlist=();

				foreach $partpm (@pmeas) {
					$mergpmlist[$mergeidx]="$pmeaskey[$mergeidx]"."|"."$partpm"."|"."$pmeasloc[$mergeidx]"."|"."$fromwhichdb[$mergeidx]";
					$pcmsitelist=$pmeasloc[$mergeidx];
					$mergeidx = $mergeidx + 1;
				}
				@sortedmglist=();
				@sortedmglist=sort @mergpmlist;		
				$countpmeaslist=@sortedmglist;
				if (($fromlist[0] == 1) && ($fromlist[1] == 1) && ($countpmeaslist > 0)) {
					print " Short Name:Long Name of Primary Variables (archiveDB & DSDB UNION)<br /><SELECT name=\"new_prim_measA\" size=8 multiple>";
				} elsif (($fromlist[0] == 1) && ($fromlist[1] == 0) && ($countpmeaslist > 0)) {
					print " Short Name:Long Name of Primary Variables (only from archiveDB)<br /><SELECT name=\"new_prim_measA\" size=8 multiple>";				
				} elsif (($fromlist[0] == 0) && ($fromlist[1] == 1) && ($countpmeaslist > 0)) {
					print " Short Name:Long Name of Primary Variables (only from DSDB)<br /><SELECT name=\"new_prim_measA\" size=8 multiple>";
				} else {
					if ($dataLevel eq "00") {
						print "THIS IS A RAW DATASTREAM <br />(No Primary Variables identified<br>in archiveDB or DSDB)<br />\n";
					}
				}
				$oldpme="";
				foreach $mp (@sortedmglist) {
					$hassites=0;
					$pcmsitelist="";
					if ($mp ne $oldpme) {
						@splitem=();
						@splitem=split(/\|/,$mp);
						$sth_checkmmt = $dbh->prepare("SELECT count(*),count(*) from primMeas where IDNo=$IDNo and primary_measurement='$splitem[1]'and var_name='$splitem[0]'");
						if (!defined $sth_checkmmt) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkmmt->execute;
						while ($checkmmt = $sth_checkmmt->fetch) {
							if ($checkmmt->[0] == 0) {
								if ($splitem[2] eq "()") {
									if ($splitem[3] eq "") {
										print "<OPTION VALUE=\"$splitem[0]|$splitem[1]\">$splitem[0]:$splitem[1]</option>\n";
									} else {
										print "<OPTION VALUE=\"$splitem[0]|$splitem[1]\">$splitem[0]:$splitem[1] ($splitem[3])</option>\n";
									}
								} else {
									$hassites=1;
									$pcmsitelist=$splitem[2];
									$_=$pcmsitelist;
									s/\(//g;
									s/\)//g;
									$pcmsitelist=$_;
									@tpcmlist=();
									@tpcmlist=split(/,/,$pcmsitelist);
									@sortedtpcmlist=sort @tpcmlist;
									$pcmsitelist="";
									$tc=0;
									foreach $spl (@sortedtpcmlist) {
										if ($tc == 0) {
											$pcmsitelist="$spl";
										} else {
											$pcmsitelist="$pcmsitelist".","."$spl";
										}
										$tc = $tc + 1;
									}
									$splitem[2]="("."$pcmsitelist".")";
									if ($splitem[3] eq "") {
										print "<OPTION VALUE=\"$splitem[0]|$splitem[1]\">$splitem[0]:$splitem[1] $splitem[2]</option>\n";	
									} else {
										print "<OPTION VALUE=\"$splitem[0]|$splitem[1]\">$splitem[0]:$splitem[1] $splitem[2] ($splitem[3])</option>\n";	
									}
								}
							}
						}
						$oldpme=$mp;
						$inx = $inx + 1;
					}
				}
				if ($dataLevel ne "00") {
					print "</SELECT>";
				}
				if ($hassites == 1) {
					$t1="("."$pcmsitelist".")";
					if ($t1 ne $thisdodfacs) {
						print "<font color=red><b>PLEASE VERIFY SITES FROM PCM AGAINST THOSE IDENTIFIED IN DOD; UPDATE DOD AND REAPPROVE IF NEEDED</b></font><br>\n";
					}
				}
				print "</td></tr></table>\n";
				print "</td>";
				print "<td>PM Types:Short Name:Long Name of Primary Variables<br /><SELECT name=\"curr_prim_meas\" size=8 multiple>\n";
				$countpm=0;
				@pmlist=();
				$sth_getcurrentprimmeasasso=$dbh->prepare("SELECT distinct IDNo,primMeas.primary_meas_code,primMeas.statusFlag,primMeas.primary_measurement,primMeas.var_name from primMeas where IDNo=$Idno order by primMeas.primary_meas_code,primMeas.var_name,primMeas.primary_measurement");
				if (!defined $sth_getcurrentprimmeasasso) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getcurrentprimmeasasso->execute;
				while ($getcurrentprimmeasasso = $sth_getcurrentprimmeasasso->fetch) {
					$oldprim_meas=$getcurrentprimmeasasso->[1];
					$oldprim_measurement=$getcurrentprimmeasasso->[3];
					$oldprim_var=$getcurrentprimmeasasso->[4];
					$statusFlag=$getcurrentprimmeasasso->[2];
					if ($statusFlag == 0) {
						print "<OPTION value=\"$oldprim_meas:$oldprim_var:$oldprim_measurement\">$oldprim_meas:$oldprim_var:$oldprim_measurement *</OPTION>\n";
					} else {
						print "<OPTION value=\"$oldprim_meas:$oldprim_var:$oldprim_measurement\">$oldprim_meas:$oldprim_var:$oldprim_measurement</OPTION>\n";
					}
					$pmlist[$countpm]="$oldprim_meas".":"."$oldprim_var".":"."$oldprim_measurement";
					$countpm = $countpm + 1;
				}
				print "</SELECT></TD>\n";
			} else {
				print "</td><td> </td><td> </td>";
			}
		}
		print "</TR>\n";
		print "</TABLE>\n";
		$countprop=0;
		$sth_countproposed=$dbh->prepare("SELECT count(*),count(*) from instClass where statusFlag=0 and IDNo=$Idno");
		if (!defined $sth_countproposed) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_countproposed->execute;
		while ($countproposed = $sth_countproposed->fetch) {
			if ($countproposed->[0] > 0) {
				$countprop = $countprop + 1;
			}
		}
		$sth_countproposed=$dbh->prepare("SELECT count(*),count(*) from instCats where statusFlag=0 and IDNo=$Idno");
		if (!defined $sth_countproposed) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_countproposed->execute;
		while ($countproposed = $sth_countproposed->fetch) {
			if ($countproposed->[0] > 0) {
				$countprop = $countprop + 1;
			}
		}
		$sth_countproposed=$dbh->prepare("SELECT count(*),count(*) from measCats where statusFlag=0 and IDNo=$Idno");
		if (!defined $sth_countproposed) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_countproposed->execute;
		while ($countproposed = $sth_countproposed->fetch) {
			if ($countproposed->[0] > 0) {
				$countprop = $countprop + 1;
			}
		}
		$sth_countproposed=$dbh->prepare("SELECT count(*),count(*) from sourceClass where statusFlag=0 and IDNo=$Idno");
		if (!defined $sth_countproposed) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_countproposed->execute;
		while ($countproposed = $sth_countproposed->fetch) {
			if ($countproposed->[0] > 0) {
				$countprop = $countprop + 1;
			}
		}
		$sth_countproposed=$dbh->prepare("SELECT count(*),count(*) from primMeas where statusFlag=0 and IDNo=$Idno");
		if (!defined $sth_countproposed) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_countproposed->execute;
		while ($countproposed = $sth_countproposed->fetch) {
			if ($countproposed->[0] > 0) {
				$countprop = $countprop + 1;
			}
		}
		print "<p><center><input type=\"submit\" name=\"submit\" value=\"ADD selected available associations from ARCHIVE DB\" /> <INPUT type=\"submit\" name=\"submit\" value=\"REMOVE selected associations from MMT DB\" /><br />(<font size=-2>NOTE: If you are removing the Instrument Class from the \"Associations made in MMT DB\" list<br />and want to <i>keep</i> existing Source Classes, primary variables and primary meas types already selected,<br />please check this box <input type=\"checkbox\" name=\"keeppms\" value=\"1\" align=\"bottom\"/> <i>BEFORE</i> pressing the \"REMOVE...\" button</font><br />\n";
		$countlist=0;
		$flagged=0;
		$printit=0;
		$message="";
		$sth_getcurpm=$dbh->prepare("SELECT distinct primary_meas_code,primary_measurement from primMeas where IDNo=$Idno");
		if (!defined $sth_getcurpm) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getcurpm->execute;
		while ($getcurpm = $sth_getcurpm->fetch) {
			$fincheck=0;
			$curpm=$getcurpm->[0];
			$curpmm=$getcurpm->[1];
			$instclassstring="";
			$sth_getcurinstclass=$dbh->prepare("SELECT distinct instrument_class,instrument_class from instClass where IDNo=$Idno order by instrument_class");
			if (!defined $sth_getcurinstclass) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcurinstclass->execute;
			while ($getcurinstclass = $sth_getcurinstclass->fetch) {
				$instclassstring="$getcurinstclass->[0]";
				$sth_countdsmeas = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$dsinfotab,$archivedb.$dsvarnameinfotab where $archivedb.$dsinfotab.datastream=$archivedb.$dsvarnameinfotab.datastream and $archivedb.$dsvarnameinfotab.primary_meas_type_code='$curpm' AND $archivedb.$dsvarnameinfotab.primary_measurement='$curpmm' and $archivedb.$dsinfotab.instrument_class_code='$instclassstring' and $archivedb.$dsinfotab.instrument_code='$dsBase'");
				if (!defined $sth_countdsmeas) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countdsmeas->execute;
				while ($countdsmeas = $sth_countdsmeas->fetch) {
					if ($countdsmeas->[0] > 0) {
						$sth_getcursourceclass = $dbh->prepare("SELECT distinct source_class,source_class from sourceClass where IDNo=$Idno order by source_class");
						if (!defined $sth_getcursourceclass) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getcursourceclass->execute;
						while ($getcursourceclass = $sth_getcursourceclass->fetch) {
							$sourceclassstring = "$getcursourceclass->[0]";
							$sth_countsc=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclasstosourceclass WHERE instrument_class_code='$instclassstring' and source_class_code='$sourceclassstring'");
							if (!defined $sth_countsc) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_countsc->execute;
							while ($countsc = $sth_countsc->fetch) {
								if ($countsc->[0] > 0) {
									$fincheck = $fincheck + 1;
								}
							}
						}
					} 	
				}
			}
			$displayinred=0;
			if ($fincheck == 0) {
				$printit = $printit + 1;
				$displayinred=1;
			}
		}
		if ($flagged != 1) {
			$alldone=0;
			$sth_countic=$dbh->prepare("SELECT count(*),count(*) from instClass where IDNo=$Idno");
			if (!defined $sth_countic) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_countic->execute;
			while ($countic = $sth_countic->fetch) {
				if ($countic->[0] > 0) {
					$sth_countica=$dbh->prepare("SELECT count(*),count(*) from instCats where IDNo=$Idno");
					if (!defined $sth_countica) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_countica->execute;
					while ($countica = $sth_countica->fetch) {
						if ($countica->[0] > 0) {
							$sth_countpm=$dbh->prepare("SELECT count(*),count(*) from primMeas where IDNo=$Idno");
							if (!defined $sth_countpm) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_countpm->execute;
							while ($countpm = $sth_countpm->fetch) {
								if ($countpm->[0] > 0) {
									$sth_countmc=$dbh->prepare("SELECT count(*),count(*) from measCats where IDNo=$Idno");
									if (!defined $sth_countmc) { die "Cannot  statement: $DBI::errstr\n"; }
									$sth_countmc->execute;
									while ($countmc = $sth_countmc->fetch) {
										if ($countmc->[0] > 0) {
											$sth_countsc=$dbh->prepare("SELECT count(*),count(*) from sourceClass where IDNo=$Idno");
											if (!defined $sth_countsc) { die "Cannot  statement: $DBI::errstr\n"; }
											$sth_countsc->execute;
											while ($countsc = $sth_countsc->fetch) {
												if ($countsc->[0] > 0) {
													$alldone=1;
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		print "</center>\n";
	}
	$dbh->disconnect();
}
################################################################################################################################################
# subroutine to display commenting section on any object type
sub displaycomment 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      	
	my $objct= shift;
	my $idn= shift;
	my $countcom=0;
	$sth_countcomments = $dbh->prepare("SELECT count(*),count(*) from comments where IDNo=$idn");
	if (!defined $sth_countcomments) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_countcomments->execute;
	while ($countcomments = $sth_countcomments->fetch) {
		$countcom=$countcomments->[0];
	}
	print "<hr>\n";
	if ($countcom > 0) {
		print "<table cellspacing=\"0\">\n";
		print "<tr>\n";
		print "<th rowspan=1 colspan=4 bgcolor=\"#FFF999\"><font color=red>Comment History</font></th></tr>\n";
		print "<tr><th>Date</th>\n";
		print "<th>Who</th>\n";
		print "<th>Comment</th></tr>\n";
		$origdate="";
		$origrev="";
		$origid="";
		$countdup = 0;
		$shade=0;
		$sth_getreviews=$dbh->prepare("SELECT IDNo,DATE_PART('year',commentDate),DATE_PART('month',commentDate),DATE_PART('day',commentDate),person_id,comment,DATE_PART('hour',commentDate),DATE_PART('minute',commentDate),DATE_PART('second',commentDate),commentDate from comments where IDNo=$idn order by commentDate,person_id");
		if (!defined $sth_getreviews) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getreviews->execute;
		while ($getreviews = $sth_getreviews->fetch) {
			$year=$getreviews->[1];
			$month=$getreviews->[2];
			$day=$getreviews->[3];
			$reviewer=$getreviews->[4];
			$review=$getreviews->[5];
			$hour=$getreviews->[6];
			$min=$getreviews->[7];
			$sec=$getreviews->[8];
			$cdate=$getreviews->[9];
			$_=$review;
			s/\n/<br>/g;
			$review=$_;
			$len=0;
			$len=length $month;
			if ($len < 2) {
				$month="0"."$month";
			}
			$len=0;
			$len=length $day;
			if ($len < 2) {
				$day="0"."$day";
			}
			$len=0;
			$len=length $hour;
			if ($len < 2) {
				$hour="0"."$hour";
			}
			$len=0;
			$len=length $min;
			if ($len < 2) {
				$min="0"."$min";
			}
			$len=0;
			$len=length $sec;
			if ($len < 2) {
				$sec="0"."$sec";
			}
			$revDate="$year"."-"."$month"."-"."$day"." $hour:$min:$sec";			
			$sth_getname=$dbh->prepare("SELECT name_first,name_last from $peopletab where person_id=$reviewer");
			if (!defined $sth_getname) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getname->execute;
			while ($getname = $sth_getname->fetch) {
				$rname_first=$getname->[0];
				$rname_last=$getname->[1];
			}
			$rfunc="";
			$countrfunc=0;
			$sth_getfunc=$dbh->prepare("SELECT distinct person_id,reviewers.revFunction,revFuncLookup.revFuncDesc from reviewers,revFuncLookup where person_id=$reviewer and reviewers.revFunction=revFuncLookup.revFunction and reviewers.type='$objct'");
			if (!defined $sth_getfunc) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getfunc->execute;
			while ($getfunc = $sth_getfunc->fetch) {
				$rfunc=$getfunc->[1];
				$rfuncD=$getfunc->[2];
			}
			if (($origdate ne $cdate) || (($origdate eq $cdate) && ($origid eq $reviewer) && ($origrev ne $review))) {
				if ($shade == 0) {
					print "<tr><td valign=middle>$revDate</td>\n";
					$shade = 1;
				} else {
					print "<tr class=\"shaded\"><td valign=middle>$revDate</td>\n";
					$shade = 0;
				}
				if ($rfunc ne "") {
					print "<td valign=middle>$rfuncD: $rname_first $rname_last</td>\n";
				} else {
					print "<td valign=middle>Guest: $rname_first $rname_last</td>\n";
				}
				print "<td valign=middle>$review</td>\n";
				print "</tr>\n";
			} elsif (($origdate eq $cdate) && ($origid eq $reviewer) && ($origrev eq $review)) {			
				if ($shade == 0) {
					$shade=1;
				} else {
					$shade=0;
				}
				if ($shade == 0) {
					print "<tr>\n";
					$shade=1;
				} else {
					print "<tr class=\"shaded\">\n";
					$shade=0;
				}
				print "<td valign=middle> </td><td valign=middle> </td>";
				print "<td valign=middle> </td></tr>\n";
			} 
			$origdate=$cdate;
			$origid=$reviewer;
			$origrev=$review;
		}
		print "</table>\n";	
	}
	print "<p><table cellspacing=\"0\">\n";
	print "<tr><th bgcolor=\"#FFF999\" colspan=4><font color=red>Enter comments below:</font> <input type=\"checkbox\" name=\"distemail\" value=\"1\" align=\"bottom\" checked/> send email notification of your comment to reviewers</th></tr>\n";
	print "<tr><td><textarea rows=10 cols=125 name=\"comment\" wrap=\"virtual\"></textarea></td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<p><INPUT type=\"submit\" name=\"submit\" VALUE=\"Enter Comment\" />\n";
	print "<hr />\n";
	$dbh->disconnect();
}
######################################################
# subroutine to email based on type of action (entry,comment,approval,inprogress,implementation,update) and 
# type of object (S-site,F-facility,I-instclass,IC-instcode,PMT-pmt,DS-datastream,DOD-DOD review)
sub distribute {
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	
	my $myuidc= shift;
	my $objct= shift;
	my $idn= shift;
	my $action = shift;
	my $cmmnt = shift;
	my $csubname="";
	if ($myuidc ne "") {
		$sth_getcsubmitter = $dbh->prepare("SELECT name_first,name_last from $peopletab where person_id=$myuidc");
		if (!defined $sth_getcsubmitter) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getcsubmitter->execute;
		while ($getcsubmitter = $sth_getcsubmitter->fetch) {
			$csubname = "$getcsubmitter->[0]"." "."$getcsubmitter->[1]";
		}
	}
	if (($action eq "comment") || ($action eq "implementation") || ($action eq "entry") || ($action eq "inprogress") || ($action eq "update")) {
		if ($objct eq "DOD") {
			$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='$objct'");
		} else {
			$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='MDATA' and reviewers.type='$objct'");	
		}
	}
	if ($action eq "approval") {
		if ($objct eq "DOD") {
			$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='DOD'");
		} else {
			$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='$objct' and (reviewers.revFunction='MDATA' or reviewers.revFunction='IMPL')");
		}
	}
	@did=();
	$countd=0;
	if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getdist->execute;
	while ($getdist = $sth_getdist->fetch) {
		$did[$countd]=$getdist->[0];
		$countd = $countd + 1;
	}
	if ($objct eq "I") {
		$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from instClass where IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getsub->[0];
			$countd = $countd + 1;
		}
	}
	if ($objct eq "IC") {
		$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from instCodes where IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getsub->[0];
			$countd = $countd + 1;
		}
	}
	if ($objct eq "CL") {
		$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from instContacts where IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getsub->[0];
			$countd = $countd + 1;
		}
	}
	if ($objct eq "S") {
		$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from sites where IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getsub->[0];
			$countd = $countd + 1;
		}
	}
	if ($objct eq "F") {
		$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from facilities where IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getsub->[0];
			$countd = $countd + 1;
		}
	}
	if ($objct eq "PMT") {
		$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from primMeas where IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getsub->[0];
			$countd = $countd + 1;
		}
	}
	if ($objct eq "DS") {
		$sth_getsub = $dbh->prepare("SELECT person_id,person_id from otherContacts WHERE IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getoth->[0];
			$countd = $countd + 1;
		}
	}			
	if ($objct eq "DOD") {
		$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from DOD where IDNo=$idn");
		if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getsub->execute;
		while ($getsub = $sth_getsub->fetch) {
			$did[$countd]=$getsub->[0];
			$countd = $countd + 1;
		}
	}
	#### added 06/09/2014 - archive implementor person would like to get distributions for site, facility, inst class, inst code, data stream and PMT submission, comments, etc
	if ( (($objct eq "PMT") || ($objct eq "DS") || ($objct eq "S") || ($objct eq "F") || ($objct eq "I") || ($objct eq "IC")) && (($action eq "comment") || ($action eq "Update")) ) {
		$sth_getarch = $dbh->prepare("SELECT DISTINCT person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.type='all' and reviewers.revFunction='IMPL'");
		if (!defined $sth_getarch) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getarch->execute;
		while ($getarch = $sth_getarch->fetch) {
			$did[$countd]=$getarch->[0];
			$countd = $countd + 1;
		}
	}	
	@sdl=();
	@sdl=sort @did;
	$oid="";
	$typedesc="";
	$typeshortname="";
	$sth_gettypedesc=$dbh->prepare("SELECT typeID,type_name from type where typeID='$objct'");
	if (!defined $sth_gettypedesc) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_gettypedesc->execute;
	while ($gettypedesc = $sth_gettypedesc->fetch) {
		$typeshortname=$gettypedesc->[0];
		$typedesc=$gettypedesc->[1];
	}
	$moresubjct="";
	if ($typeshortname eq "DOD") {
		$sth_getdodinfo = $dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$idn");
		if (!defined $sth_getdodinfo) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdodinfo->execute;
		while ($getdodinfo = $sth_getdodinfo->fetch) {
			$typedesc="DOD "."$getdodinfo->[0]"."\."."$getdodinfo->[1] "."V"."$getdodinfo->[2]";
		}
	}
	if ($objct eq "S") {
		$sth_getdetails=$dbh->prepare("SELECT site,site_name from sites where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]"." "."($getdetails->[1])";
		}
	} elsif ($objct eq "F") {
		$sth_getdetails=$dbh->prepare("SELECT site,facility_code from facilities where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]".": "."$getdetails->[1]";
		}
	} elsif ($objct eq "I") {
		$sth_getdetails=$dbh->prepare("SELECT instrument_class,instrument_class_name from instClass where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]"." ("."$getdetails->[1]".")";
		}
	} elsif ($objct eq "IC") {
		$sth_getdetails=$dbh->prepare("SELECT instrument_code,instrument_code_name from instCodes where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]"." ("."$getdetails->[1]".")";
		}
	} elsif ($objct eq "PMT") {
		$sth_getdetails=$dbh->prepare("SELECT primary_meas_code,primary_meas_code from primMeas where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]";
		}
	} elsif ($objct eq "DOD") {
		$sth_getdetails=$dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]"."\."."$getdetails->[1]"." (v "."$getdetails->[2]".")";
		}
	} elsif ($objct eq "CL") {
		$sth_getdetails=$dbh->prepare("SELECT group_name,role_name from instContacts where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]"."\/"."$getdetails->[1]";
		}
	} elsif ($objct eq "DS") {
		$sth_getdetails=$dbh->prepare("SELECT dsBase,dataLevel from DS where IDNo=$idn");
		if (!defined $sth_getdetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdetails->execute;
		while ($getdetails = $sth_getdetails->fetch) {
			$moresubjct="$getdetails->[0]"."\."."$getdetails->[1]";
		}
	}
	foreach $sdl (@sdl) {
		if ($sdl ne "$oid") {
			$email="";
			$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$sdl");
			if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getemail->execute;
			while ($getemail = $sth_getemail->fetch) {
				if ($action eq "entry") {
					open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: $typedesc ENTRY: $moresubjct - MMT# $idn\" \"$getemail->[1]\"");	
				} elsif ($action eq "comment") {
					open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: $typedesc COMMENT: $moresubjct - MMT# $idn\" \"$getemail->[1]\"");	
				} elsif ($action eq "approval") {
					open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: $typedesc APPROVAL: $moresubjct - MMT# $idn\" \"$getemail->[1]\"");
				} elsif ($action eq "implementation") {
					open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: $typedesc IMPLEMENTATION: $moresubjct - MMT# $idn\" \"$getemail->[1]\"");	
				} elsif ($action eq "inprogress") {
					open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: $typedesc REVIEW IN PROGRESS: $moresubjct - MMT# $idn\" \"$getemail->[1]\"");
				} elsif ($action eq "update") {
					open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: $typedesc UPDATE: $moresubjct - MMT# $idn\" \"$getemail->[1]\"");
				} else {
					open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: $typedesc: $moresubjct - MMT# $idn\" \"$getemail->[1]\"");
				}			
				if ($action eq "comment") {
					print MAIL "Comment entered by: $csubname\n\n";
					print MAIL "$cmmnt\n\n";
				}
				print MAIL "Please visit the MMT system at URL\nhttp://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn\n to view.\n";
				close(MAIL);
			}
		}
		$oid=$sdl;
	}
	$dbh->disconnect();	
}
###################################################################
sub sendimplementation {
	# send archive instructions for any needed additions/updates/deletions
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
	$now = &getnow;
	$_=$now;
	s/\///g;
	s/ //g;
	s/://g;
	$tnow=$_;
	$objct= shift;
	$idn= shift;
	$maindbstat = shift;	
	$emchk = shift;
	@idarray=();
	@dbstatarray=();
	$idx=0;
	if ($idn =~ "\:") {
		@idarray=split(/\:/,$idn);
	} else {
		$idarray[$idx]=$idn;
	}
	if ($maindbstat =~ "\:") {
		@dbstatarray=split(/\:/,$maindbstat);
	} else {
		$dbstatarray[$idx]=$maindbstat;
	}
	$idn="";
	$maindbstat="";
############################
	# contacts
	if ($objct eq "CL") {
		$idx=0;
		$sqlmentcount=0;
		@mentorsql=();
		$countarray=0;
		$countarray=@idarray;
		# the below was new work to write updates to a file for later automatic load into db
		# commented out the section for now - kjl 09/20/2017
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
		
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			$idstatcheck=0;
			# the below code ADDS mentors to people.group_role
			$checkgname="";
			$checkrname="";
			$contact_id="";
			$sth_getmentors = $dbh->prepare("SELECT distinct contact_id,group_name,role_name,subrole_name from instContacts WHERE IDNo=$idn");
			if (!defined $sth_getmentors) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmentors->execute;
			while ($getmentors = $sth_getmentors->fetch) {
				$checkgname=$getmentors->[1];
				$checkrname=$getmentors->[2];
				if ($getmentors->[3] eq "") {
					$checksrname="NULL";
				} else {
					$checksrname="\'$getmentors->[3]\'";
				}
				if ($checksrname eq "NULL") {
					$sth_checkit = $dbh->prepare("SELECT count(*) from $grouprole where person_id=$getmentors->[0] and group_name='$checkgname' and role_name='$checkrname' and subrole_name is $checksrname");
					
				} else {
					$sth_checkit = $dbh->prepare("SELECT count(*) from $grouprole where person_id=$getmentors->[0] and group_name='$checkgname' and role_name='$checkrname' and subrole_name=$checksrname");
				}
				if (!defined $sth_checkit) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkit->execute;
				while ($checkit = $sth_checkit->fetch) {
					if ($checkit->[0] == 0) {	
						#insert  into people db					
						$mentorsql[$sqlmentcount]="INSERT INTO $grouprole (person_id,group_name,role_name,subrole_name) values ($getmentors->[0],'$getmentors->[1]','$getmentors->[2]',$checksrname);";
						#print ARMINT2 "INSERT INTO $grouprole (person_id,group_name,role_name,subrole_name) values ($getmentors->[0],'$getmentors->[1]','$getmentors->[2]',$checksrname);\n";
						$sqlmentcount = $sqlmentcount + 1;
						$idstatcheck = $idstatcheck + 1;
					}
				}
			}
			# the below DELETES mentors from people.group_role
			#$temp="";
			#if ($checksrname eq "NULL") {
			#	print "SELECT person_id,group_name,role_name,subrole_name from $grouprole WHERE group_name='$checkgname' and role_name='$checkrname' and subrole_name is $checksrname<br>\n";
			#	$sth_checkmentors=$dbh->prepare("SELECT person_id,group_name,role_name,subrole_name from $grouprole WHERE group_name='$checkgname' and role_name='$checkrname' and subrole_name is $checksrname");
			#} else {
			#	print "SELECT person_id,group_name,role_name,subrole_name from $grouprole WHERE group_name='$checkgname' and role_name='$checkrname' and subrole_name=$checksrname<br>\n";
			#	$sth_checkmentors=$dbh->prepare("SELECT person_id,group_name,role_name,subrole_name from $grouprole WHERE group_name='$checkgname' and role_name='$checkrname' and subrole_name=$checksrname");
			#}
			#if (!defined $sth_checkmentors) { die "Cannot  statement: $DBI::errstr\n"; }
			#$sth_checkmentors->execute;
			#while ($checkmentors = $sth_checkmentors->fetch) {
			#	$temp=$checkmentors->[0];
			#	print "temp $temp<br>\n";
			#	if ($checksrname eq "NULL") {
			#		print "SELECT count(*) from instContacts where IDNo=$idn and group_name='$checkgname' and role_name='$checkrname' and contact_id=$temp and subrole_name is $checksrname<br>\n";
			#		$sth_checkcontacts = $dbh->prepare("SELECT count(*) from instContacts where IDNo=$idn and group_name='$checkgname' and role_name='$checkrname' and contact_id=$temp and subrole_name is $checksrname");
			#	} else {
			#		print "SELECT count(*) from instContacts where IDNo=$idn and group_name='$checkgname' and role_name='$checkrname' and contact_id=$temp and subrole_name=$checksrname<br>\n";
			#		$sth_checkcontacts = $dbh->prepare("SELECT count(*) from instContacts where IDNo=$idn and group_name='$checkgname' and role_name='$checkrname' and contact_id=$temp and subrole_name=$checksrname");
			#	}
			#	if (!defined $sth_checkcontacts) { die "Cannot  statement: $DBI::errstr\n"; }
			#	$sth_checkcontacts->execute;
			#	while ($checkcontacts = $sth_checkcontacts->fetch) {
			#		print "checkcontacts->[0] $checkcontacts->[0]<br>\n";
			#		if ($checkcontacts->[0] == 0) {
			#			#delete contact in people db
			#			if ($checksrname eq "NULL") {
			#				print "DELETE from $grouprole WHERE person_id=$checkmentors->[0] and group_name='$checkgname' and role_name='$checkrname' and subrole_name is $checksrname;<br>\n";
			#				$mentorsql[$sqlmentcount]="DELETE from $grouprole WHERE person_id=$checkmentors->[0] and group_name='$checkgname' and role_name='$checkrname' and subrole_name is $checksrname;";
			#			} else {
			#				print "DELETE from $grouprole WHERE person_id=$checkmentors->[0] and group_name='$checkgname' and role_name='$checkrname' and subrole_name=$checksrname;<br>\n";
			#				$mentorsql[$sqlmentcount]="DELETE from $grouprole WHERE person_id=$checkmentors->[0] and group_name='$checkgname' and role_name='$checkrname' and subrole_name=$checksrname;";
			#			}
			#			$sqlmentcount = $sqlmentcount + 1;
			#			$idstatcheck = $idstatcheck + 1;
			#		}
			#	}
			#}
			$idx = $idx + 1;
			
			if ($idstatcheck == 0) {
				print "NO People DB ENTRY/UPDATE required($idn): up-to-date!<br>\n";	
				print "Status of this entry (MMT# $idn) will be set to Approved/Completed<p>\n";
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");
				$doStatus = $dbh->do("UPDATE instContacts set statusFlag=2 where IDNo=$idn");
				
			} else {
				print "People DB ENTRY/UPDATE required($idn)<br>\n";
				print "Implementation Request sent<p>\n";
			}
			
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
			
		}
		#if ($countarray > 1) {
		#	close(ARMINT2);
		#}					
		# if there are sql commands ready, send notification to Kathy
		if ($emchk eq "") {
			if ($sqlmentcount > 0) {			
				$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=12");
				if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getemail->execute;
				while ($getemail = $sth_getemail->fetch) {
					if ($idx == 1) {
						open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: SQL - CONTACT Entry/Update/Delete - MMT# @idarray\" \"$getemail->[1]\"");	
					} else {
						open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: SQL Batch - CONTACT Entry/Update/Delete\" \"$getemail->[1]\"");
					}
					print MAIL "ENTRY/UPDATE/DELETE for contact is ready for implementation in archive metadata databases.\n";
					print MAIL "--------------------------------------------\n";
					print MAIL "SQL commands follow for your convenience:\n\n";
					foreach $sq (@mentorsql) {
						print MAIL "$sq\n";
					}
					if ($idx == 1) {
						foreach $idn (@idarray) {
							print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
						}
					} else {
						print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=CL";
					}
					close(MAIL);
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#$filetodel="$armintupdatesfile";
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}
	}	
#######################
	if ($objct eq "S") {
#########sites
		$idx=0;
		$sqlcount=0;
		@sql=();
		$countarray=0;
		$countarray=@idarray;
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
		
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			if ($dbstatarray[$idx] == 0) { # new site (according to last recorded in MMT) being processed: status = 0
				my $site="";
				my $site_name="";
				my $start_date="";
				my $end_date="";
				my $production="";
				my $site_type="";
				my $nend_date="";
				$sth_getsiteinfo=$dbh->prepare("SELECT lower(site),site_name,start_date,end_date,production,site_type,DATE_PART('year',start_date),DATE_PART('month',start_date),DATE_PART('day',start_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from sites where IDNo=$idn");
				if (!defined $sth_getsiteinfo) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getsiteinfo->execute;
				while ($getsiteinfo = $sth_getsiteinfo->fetch) {
					$site=$getsiteinfo->[0];
					$site_name=$getsiteinfo->[1];
					$styr=$getsiteinfo->[6];	
					$stmn = $getsiteinfo->[7];
					$stdy=$getsiteinfo->[8];
					$len=0;
					$len = length $stmn;
					if ($len < 2) {
						$stmn="0"."$stmn";
					}
					$len=0;
					$len = length $stdy;
					if ($len < 2) {
						$stdy="0"."$stdy";
					}
					$start_date="$stmn"."/"."$stdy"."/"."$styr";
					$endyr = $getsiteinfo->[9];
					$endmn=$getsiteinfo->[10];
					$enddy=$getsiteinfo->[11];
					if ($endyr ne "") {
						$len=0;
						$len = length $endmn;
						if ($len < 2) {
							$endmn="0"."$endmn";
						}
						$len=0;
						$len = length $enddy;
						if ($len < 2) {
							$enddy="0"."$enddy";
						}
						$end_date="$endmn"."/"."$enddy"."/"."$endyr";
					} else {
						$end_date="NULL";
					}
					$production=$getsiteinfo->[4];
					$site_type=$getsiteinfo->[5];
					if ($end_date eq "") {
						$nend_date="NULL";
					} else {
						 $nend_date="\'$end_date\'";
					}
				}
				$match=0;
				$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$siteinfotab WHERE site_code='$site'");
				if (!defined $sth_checksite) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checksite->execute;
				while ($checksite = $sth_checksite->fetch) {
					$match=$checksite->[0];
				}
				if ($match > 0) {
					$dbstatarray[$idx]=1;   # this site exists!  no need to insert it
				} else {
					# build sql file to send to archive	
					$sql[$sqlcount]="INSERT INTO arm_int2.$siteinfotab values('$site','$site_name','$start_date',$nend_date,'$production','$site_type','Y','Y');";
					#print ARMINT2 "INSERT INTO arm_int2_stage.$siteinfotab values('$site','$site_name','$start_date',$nend_date,'$production','$site_type','Y','Y');\n";
					$sqlcount = $sqlcount + 1;
					print "Archive DB ENTRY/UPDATE required ($idn: $site - $site_name)<p>\n";
				}
				$match=0;
			}
			if (($dbstatarray[$idx] == 1) || ($dbstatarray[$idx] == -1) || ($dbstatarray[$idx] == 2)) {
				# update site - at least some of this information has already been added to archive but may need updating
				my $thissite="";
				my $thissitename="";
				my $thisstartdate="";
				my $thisenddate="";
				my $thisproduction="";
				my $thissitetype="";
				$sth_getsite = $dbh->prepare("SELECT lower(site),site_name,start_date,end_date,production,site_type,DATE_PART('year',start_date),DATE_PART('month',start_date),DATE_PART('day',start_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from sites WHERE IDNo=$idn");
				if (!defined $sth_getsite) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getsite->execute;
				while ($getsite = $sth_getsite->fetch) {
					$thissite=$getsite->[0];
					$thissitename=$getsite->[1];
					$thisstartdate=$getsite->[2];
					$thisenddate=$getsite->[3];
					$thisproduction=$getsite->[4];
					$thissitetype=$getsite->[5];
					$styr=$getsite->[6];
					$stmn=$getsite->[7];
					$stdy=$getsite->[8];
					$endyr=$getsite->[9];
					$endmn=$getsite->[10];
					$enddy=$getsite->[11];
					if ($endyr ne "") {
						$len=0;
						$len = length $endmn;
						if ($len < 2) {
							$endmn="0"."$endmn";
						}
						$len=0;
						$len = length $enddy;
						if ($len < 2) {
							$enddy="0"."$enddy";
						}
						$thisenddate="$endmn"."/"."$enddy"."/"."$endyr";
					} else {
						$thisenddate="";
					}
					if ($thisenddate eq "") {
						$thisenddate="NULL";
					} else  {
						$thisenddate="\'$thisenddate\'";
					}
					$len=0;
					$len = length $stmn;
					if ($len < 2) {
						$stmn="0"."$stmn";
					}
					$len=0;
					$len = length $stdy;
					if ($len < 2) {
						$stdy="0"."$stdy";
					}
					$thisstartdate="$stmn"."/"."$stdy"."/"."$styr";
				}
				$match=0;
				$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$siteinfotab where site_code='$thissite'");
				if (!defined $sth_checksite) { die "Cannot statement: $DBI::errstr\n"; }
				$sth_checksite->execute;
				while ($checksite = $sth_checksite->fetch) {
					$match=$checksite->[0];
				}
				if ($match > 0) { # site code exists, check other fields in the table 
					$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$siteinfotab where site_code='$thissite' AND site_name='$thissitename'");
					if (!defined $sth_checksite) { die "Cannot statement: $DBI::errstr\n"; }
					$sth_checksite->execute;
					while ($checksite = $sth_checksite->fetch) {
						$match=$checksite->[0];
					}
					if ($match > 0) { # site code and site name match, continue checking
						$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$siteinfotab where site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate'");
						if (!defined $sth_checksite) { die "Cannot statement: $DBI::errstr\n"; }
						$sth_checksite->execute;
						while ($checksite = $sth_checksite->fetch) {
							$match=$checksite->[0];
						}
						if ($match > 0) { # site code, site name, and start date match, continue checking
							$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$siteinfotab where site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate' and end_date=$thisenddate");
							if (!defined $sth_checksite) { die "Cannot statement: $DBI::errstr\n"; }
							$sth_checksite->execute;
							while ($checksite = $sth_checksite->fetch) {
								$match = $checksite->[0];
							}
							if ($match > 0) { # site code, site name, start date and end date match, continue checking
								$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$siteinfotab where site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate' and end_date=$thisenddate and production='$thisproduction'");
								if (!defined $sth_checksite) { die "Cannot statement: $DBI::errstr\n"; }
								$sth_checksite->execute;
								while ($checksite = $sth_checksite->fetch) {
									$match = $checksite->[0];
								} 
								if ($match > 0) { # site code, site name, start date, end date and production match, continue checking
									$sth_checksite = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$siteinfotab WHERE site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate' and end_date=$thisenddate and production='$thisproduction' and site_type='$thissitetype'");
									if (!defined $sth_checksite) { die "Cannot statement: $DBI::errstr\n"; }
									$sth_checksite->execute;
									while ($checksite = $sth_checksite->fetch) {
										$match=$checksite->[0];
									}
									if ($match  > 0) { # site code, site name, start date, end date, production and site type all match - checking complete - this is fully implemented
										print "NO Archive DB ENTRY/UPDATE required ($idn: $thissite - $thissitename): up-to-date!<br>\n";	
										print "Status of this entry (MMT# $idn) will be set to Approved/Completed<p>\n";
										$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");
										$doStatus = $dbh->do("UPDATE sites set statusFlag=2 where IDNo=$idn");
										
									} else { # build sql for archive update of site type for an existing site
										$sql[$sqlcount]="UPDATE arm_int2.$siteinfotab set site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate' and end_date=$thisenddate and production='$thisproduction';";	
										#print ARMINT2 "UPDATE arm_int2_stage.$siteinfotab set site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate' and end_date=$thisenddate and production='$thisproduction';\n";		
										$sqlcount = $sqlcount + 1;
										print "Archive DB ENTRY/UPDATE required ($idn: $thissite - $thissitename)<p>\n";
									}
								} else {
									# build sql for archive update of production and site type for an existing site
									$sql[$sqlcount]="UPDATE arm_int2.$siteinfotab set production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate' and end_date=$thisenddate;";
									#print ARMINT2 "UPDATE arm_int2_stage.$siteinfotab set production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate' and end_date=$thisenddate;\n";
									$sqlcount = $sqlcount + 1;
									print "Archive DB ENTRY/UPDATE required ($idn: $thissite - $thissitename)<p>\n";
								}
							} else {
								# build sql for archive update of end date, production and site type for an existing site
								$sql[$sqlcount]="UPDATE arm_int2.$siteinfotab set end_date=$thisenddate,production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate';";
								#print ARMINT2 "UPDATE arm_int2_stage.$siteinfotab set end_date=$thisenddate,production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename' and start_date='$thisstartdate';\n";
								$sqlcount = $sqlcount + 1;
								print "Archive DB ENTRY/UPDATE required ($idn: $thissite - $thissitename)<p>\n";
							}
						} else {
							# build sql for archive update of start date, end date, production and site type for an existing site
							$sql[$sqlcount]="UPDATE arm_int2.$siteinfotab set start_date='$thisstartdate',end_date=$thisenddate,production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename';";
							#print ARMINT2 "UPDATE arm_int2_stage.$siteinfotab set start_date='$thisstartdate',end_date=$thisenddate,production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite' and site_name='$thissitename';\n";
							$sqlcount = $sqlcount + 1;
							print "Archive DB ENTRY/UPDATE required ($idn: $thissite - $thissitename)<p>\n";
						}
					} else {
						# build sql for archive update of site name, start date, end date, production and site type for an existing site
						$sql[$sqlcount]="UPDATE arm_int2.$siteinfotab set site_name='$thissitename',start_date='$thisstartdate',end_date=$thisenddate,production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite';";
						#print ARMINT2 "UPDATE arm_int2_stage.$siteinfotab set site_name='$thissitename',start_date='$thisstartdate',end_date=$thisenddate,production='$thisproduction',site_type='$thissitetype' WHERE site_code='$thissite';\n";
						$sqlcount = $sqlcount + 1;
						print "Archive DB ENTRY/UPDATE required ($idn: $thissite - $thissitename)<p>\n";
					}
				} else {
					# if we get here this site actually does NOT exist at archive yet (some kind of status conflict in mmt...)
					# - needs to be entered, not updated!
					# build sql for archive INSERT
					$sql[$sqlcount]="INSERT INTO arm_int2.$siteinfotab values('$thissite','$thissitename','$thisstartdate',$thisenddate,'$thisproduction','$thissitetype','Y','Y');";
					#print ARMINT2 "INSERT INTO arm_int2_stage.$siteinfotab values('$thissite','$thissitename','$thisstartdate',$thisenddate,'$thisproduction','$thissitetype','Y','Y');\n";
					$sqlcount = $sqlcount + 1;
					print "Archive DB ENTRY/UPDATE required ($idn: $thissite - $thissitename)<p>\n";
				} 
			}
			$idx = $idx + 1;
			
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
					
		}
		
		#if ($countarray > 1) {
		#	close(ARMINT2);
		#}
		
		# if there are sql commands ready, send notification to archive
		#print "sqlcount $sqlcount<br>\n";
		if ($emchk eq "") {
			if ($sqlcount > 0) {
				@sortedlist=();
				@sortedlist=sort @sql;
				$oldsq="";
				$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL'");	
				if (!defined $sth_getdist) { die "Cannot statement: $DBI::errstr\n"; }
				$sth_getdist->execute;
				while ($getdist = $sth_getdist->fetch) {
					$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$getdist->[0]");
					if (!defined $sth_getemail) { die "Cannot statement: $DBI::errstr\n"; }
					$sth_getemail->execute;
					while ($getemail = $sth_getemail->fetch) {
						if ($idx == 1) {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Site ENTRY/UPDATE ready for implementation- MMT# @idarray\" \"$getemail->[1]\"");	
						} else {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Batch - Site ENTRY/UPDATE ready for implementation\" \"$getemail->[1]\"");
						}
						print MAIL "ENTRY/UPDATE for site is ready for implementation in archive metadata databases.\n";
						print MAIL "--------------------------------------------\n";
						# no longer sending sql via email.  Archive will go to MMT tool to manually look at what needs updating
						#  change of plans as of 10/16/2014: adding back the following section to send sql to Harold at his request
						print MAIL "SQL commands follow for your convenience:\n\n";
						$oldsq="";
						foreach $sq (@sortedlist) {
							if ($oldsq ne $sq) {
								print MAIL "$sq\n";
							}
							$oldsq=$sq;
						}
						if ($idx == 1) {
							foreach $idn (@idarray) {
								print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
							}
						} else {
							print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=S";
						}
						close(MAIL);
					}
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}
	}
###############################################
###############################################
	if ($objct eq "F") {
		# facilities
		$sqlcount=0;
		$idx=0;
		@sql=();
		$countarray=0;
		$countarray=@idarray;
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			if ($dbstatarray[$idx] == 0) { # new site/facility being processed
				$sth_getfacs=$dbh->prepare("SELECT lower(site),facility_code,facility_name,eff_date,end_date,DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from facilities where IDNo=$idn");
				if (!defined $sth_getfacs) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getfacs->execute;
				while ($getfacs = $sth_getfacs->fetch) {
					$fstart="";
					$fend="";
					$styr="";
					$stmn="";
					$stdy="";
					$endyr="";
					$endmn="";
					$enddy="";
					$styr=$getfacs->[5];	
					$stmn = $getfacs->[6];
					$stdy=$getfacs->[7];
					$endyr = $getfacs->[8];
					$endmn=$getfacs->[9];
					$enddy=$getfacs->[10];
					if ($styr ne "") {
						$len=0;
						$len = length $stmn;
						if ($len < 2) {
							$stmn="0"."$stmn";
						}
						$len=0;
						$len = length $stdy;
						if ($len < 2) {
							$stdy="0"."$stdy";
						}
						$fstart="$styr"."$stmn"."$stdy";
					} else {
						$fstart="NULL";
					}
					if ($endyr ne "") {
						$len=0;
						$len = length $endmn;
						if ($len < 2) {
							$endmn="0"."$endmn";
						}
						$len=0;
						$len = length $enddy;
						if ($len < 2) {
							$enddy="0"."$enddy";
						}
						$fend="$endyr"."$endmn"."$enddy";
					} else {
						$fend="30010101";
					}
					if ($fstart eq "") {
						$fstart="NULL";
					} else {
						 $fstart="\'$fstart\'";
					}	
					if ($fend eq "") {
						$fend="\'30010101\'";
					} else {
						 $fend="\'$fend\'";
					}		
					
					# new facility implementation sql
					$match=0;
					$sth_checkfac = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab WHERE lower(site_code)='$getfacs->[0]' and facility_code='$getfacs->[1]'");
					if (!defined $sth_checkfac) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkfac->execute;
					while ($checkfac = $sth_checkfac->fetch) {
						$match=$checkfac->[0];
					}
					if ($match > 0) {
						$dbstatarray[$idx]=1;
					} else {		
						# build sql for archive  
						#print "INSERT INTO arm_int2.$facinfotab values('$getfacs->[0]','$getfacs->[1]','$getfacs->[2]',$fstart,$fend,'Y','Y',NULL,NULL,NULL);<br>\n";
						$sql[$sqlcount]="INSERT INTO arm_int2.$facinfotab (site_code,facility_code,facility_name,eff_date,end_date,visible,data_available,latitude,longitude,altitude) values('$getfacs->[0]','$getfacs->[1]','$getfacs->[2]',$fstart,$fend,'Y','Y',NULL,NULL,NULL);";
						#print ARMINT2 "INSERT INTO arm_int2_stage.$facinfotab (site_code,facility_code,facility_name,eff_date,end_date,visible,data_available,latitude,longitude,altitude) values('$getfacs->[0]','$getfacs->[1]','$getfacs->[2]',$fstart,$fend,'Y','Y',NULL,NULL,NULL);\n";
						$sqlcount = $sqlcount + 1;
					}
				}
			}
			if (($dbstatarray[$idx] == 1) || ($dbstatarray[$idx] == -1) || ($dbstatarray[$idx] == 2)) {
				# update facility sql
				my $thisfsite="";
				my $thisfaccode="";
				my $thisfacname="";
				my $thisfeffdate="";
				my $thisfenddate="";
				$countthisid=0;
				$sth_countfacsforthisid=$dbh->prepare("SELECT count(*),count(*) from facilities where IDNo=$idn");
				if (!defined $sth_countfacsforthisid) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countfacsforthisid->execute;
				while ($countfacsforthisid = $sth_countfacsforthisid->fetch) {
					$countthisid=$countfacsforthisid->[0];
				}
				$countinarchive=0;
				$countinmmt=0;
				$sth_getfacs = $dbh->prepare("SELECT lower(site),facility_code,facility_name,eff_date,end_date,DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from facilities where IDNo=$idn");
				if (!defined $sth_getfacs) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getfacs->execute;
				while ($getfacs = $sth_getfacs->fetch) {
					$thisfsite=$getfacs->[0];
					$thisfaccode=$getfacs->[1];
					$thisfacname=$getfacs->[2];
					$thisfeffdate=$getfacs->[3];
					$thisfenddate=$getfacs->[4];				
					$styr=$getfacs->[5];
					$stmn=$getfacs->[6];
					$stdy=$getfacs->[7];
					$endyr=$getfacs->[8];
					$endmn=$getfacs->[9];
					$enddy=$getfacs->[10];
					if ($thisfenddate eq "") {
						$thisfenddate="01/01/3001";
						$fenddate="30010101";
					} else  {
						$len=0;
						$len = length $endmn;
						if ($len < 2) {
							$endmn="0"."$endmn";
						}
						$len=0;
						$len = length $enddy;
						if ($len < 2) {
							$enddy = "0"."$enddy";
						}
						$thisfenddate="$endmn"."/"."$enddy"."/"."$endyr";
						$fenddate="$endyr"."$endmn"."$enddy";
					}
					$len=0;
					$len = length $stmn;
					if ($len < 2) {
						$stmn="0"."$stmn";
					}
					$len=0;
					$len = length $stdy;
					if ($len < 2) {
						$stdy = "0"."$stdy";
					}
					$thisfeffdate="$stmn"."/"."$stdy"."/"."$styr";
					$feffdate="$styr"."$stmn"."$stdy";
					$match=0;
					$sth_checkfac = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab WHERE lower(site_code)='$thisfsite' and facility_code='$thisfaccode'");
					if (!defined $sth_checkfac) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkfac->execute;
					while ($checkfac = $sth_checkfac->fetch) {
						$match = $checkfac->[0];
					}
					if ($match > 0) {
						$match=0;
						$sth_checkfac = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab WHERE lower(site_code) = '$thisfsite' AND facility_code='$thisfaccode' AND facility_name='$thisfacname'");
						if (!defined $sth_checkfac) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkfac->execute;
						while ($checkfac = $sth_checkfac->fetch) {
							$match = $checkfac->[0];
						}
						if ($match > 0) {
							$match=0;
							$sth_checkfac = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab WHERE lower(site_code) = '$thisfsite' AND facility_code='$thisfaccode' and facility_name='$thisfacname' AND eff_date='$thisfeffdate'");
							if (!defined $sth_checkfac) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_checkfac->execute;
							while ($checkfac = $sth_checkfac->fetch) {
								$match = $checkfac->[0];
							}
							if ($match > 0) {
								$match=0;
								$sth_checkfac = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$facinfotab WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode' and facility_name='$thisfacname' AND eff_date='$thisfeffdate' AND end_date='$thisfenddate'");
								if (!defined $sth_checkfac) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checkfac->execute;
								while ($checkfac = $sth_checkfac->fetch) {
									$match = $checkfac->[0];
								}
								if ($match > 0) {
									$countinarchive = $countinarchive + 1;
									
								} else {
									# build sql file for archive
									#print "UPDATE arm_int2.$facinfotab set end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode' AND facility_name='$thisfacname';<br>\n";
									$sql[$sqlcount]="UPDATE arm_int2.$facinfotab set end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode' AND facility_name='$thisfacname';";
									#print ARMINT2 "UPDATE arm_int2_stage.$facinfotab set end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode' AND facility_name='$thisfacname';\n";
									$sqlcount = $sqlcount + 1;
								}
							} else {
								# build sql file for archive
								#print "UPDATE arm_int2.$facinfotab set eff_date='$thisfeffdate',end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode' AND facility_name='$thisfacname';<br>\n";
								$sql[$sqlcount]="UPDATE arm_int2.$facinfotab set eff_date='$thisfeffdate',end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode' AND facility_name='$thisfacname';";
								#print ARMINT2 "UPDATE arm_int2_stage.$facinfotab set eff_date='$thisfeffdate',end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode' AND facility_name='$thisfacname';\n";
								$sqlcount = $sqlcount + 1;
							}
						} else {
							# build sql file for archive
							#print "UPDATE arm_int2.$facinfotab set facility_name='$thisfacname',eff_date='$thisfeffdate',end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode';<br>\n";
							$sql[$sqlcount]="UPDATE arm_int2.$facinfotab set facility_name='$thisfacname',eff_date='$thisfeffdate',end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode';";
							#print ARMINT2 "UPDATE arm_int2_stage.$facinfotab set facility_name='$thisfacname',eff_date='$thisfeffdate',end_date='$thisfenddate' WHERE lower(site_code)='$thisfsite' AND facility_code='$thisfaccode';\n";
							$sqlcount = $sqlcount + 1;
						}
					} else {
						# build sql file for archive
						#print "INSERT INTO arm_int2.$facinfotab values('$thisfsite','$thisfaccode','$thisfacname','$feffdate','$fenddate','Y','Y',NULL,NULL,NULL);<br>\n";
						$sql[$sqlcount]="INSERT INTO arm_int2.$facinfotab (site_code,facility_code,facility_name,eff_date,end_date,visible,data_available,latitude,longitude,altitude) values('$thisfsite','$thisfaccode','$thisfacname','$feffdate','$fenddate','Y','Y',NULL,NULL,NULL);";
						#print ARMINT2 "INSERT INTO arm_int2_stage.$facinfotab (site_code,facility_code,facility_name,eff_date,end_date,visible,data_available,latitude,longitude,altitude) values('$thisfsite','$thisfaccode','$thisfacname','$feffdate','$fenddate','Y','Y',NULL,NULL,NULL);\n";
						$sqlcount = $sqlcount + 1;
					}
				}
				if (($countinarchive > 0) && ($countinarchive eq $countthisid)) {
					print "NO Archive DB ENTRY/UPDATE required($idn): up-to-date!<br>\n";
					print "Status of this entry (MMT# $idn) will be set to Approved/Completed<p>\n";
					$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");
					$doStatus = $dbh->do("UPDATE facilities set statusFlag=2 where IDNo=$idn");
				} elsif ($countinarchive ne $countthisid) {			
					print "Archive DB ENTRY/UPDATE required($idn)<br>\n";
					$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 where IDNo=$idn");
					$doStatus = $dbh->do("UPDATE facilities set statusFlag=-1 where IDNo=$idn");
				}
			}
			$idx = $idx + 1;
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
			#if ($countarray > 1) {
			#	close(ARMINT2);
			#}					
		}
		if ($emchk eq "") {
			if ($sqlcount > 0) {
				@sortedlist=();
				@sortedlist=sort @sql;
				$oldsq="";
				######## send implementation notification to archive
				######## future step will be to apply implementation inst directly to arm_int2)
				######## and arm_apps databases via postgres replication
				######## 11/29/2016 - Harold is merging arm_apps table into arm_int2 so will change those inserts to match
				$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL'");	
				if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdist->execute;
				while ($getdist = $sth_getdist->fetch) {
					$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$getdist->[0]");
					if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getemail->execute;
					while ($getemail = $sth_getemail->fetch) {
						if ($idx == 1) {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Facility ENTRY/UPDATE ready for implementation- MMT# @idarray\" \"$getemail->[1]\"");	
						} else {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Batch - Facility ENTRY/UPDATE ready for implementation\" \"$getemail->[1]\"");
						}
						print MAIL "ENTRY/UPDATE for a facility(ies) ready for implementation in archive metadata databases.\n";
						print MAIL "--------------------------------------------\n";
						print MAIL "SQL commands follow for your convenience:\n\n";
						$oldsq="";
						foreach $sq (@sortedlist) {
							if ($oldsq ne $sq) {
								print MAIL "$sq\n";
							}
							$oldsq=$sq;
						}
						if ($idx == 1) {
							foreach $idn (@idarray) {
								print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
							}
						} else {
							print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=F";
						}
						close(MAIL);
					}
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}
	}	
###################################################
	if ($objct eq "I") {
		#instrument class
		$sqlcount=0;
		@sql=();
		$idx=0;
		$countarray=0;
		$countarray=@idarray;
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			$idstatcheck=0;
			if ($dbstatarray[$idx] == 0) {
				#  originally submitted as a new instrument class 
				$sth_getclass=$dbh->prepare("SELECT lower(instrument_class),instrument_class_name,statusFlag from instClass where IDNo=$idn");
				if (!defined $sth_getclass) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getclass->execute;
				while ($getclass = $sth_getclass->fetch) {
					$sth_getinstcat=$dbh->prepare("SELECT distinct inst_category_code,statusFlag from instCats where IDNo=$idn");
					if (!defined $sth_getinstcat) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getinstcat->execute;
					while ($getinstcat = $sth_getinstcat->fetch) {
						$match=0;
						# check that it really is a new instrument class
						$sth_checkit = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclasstoinstrcattab where lower(instrument_class_code)='$getclass->[0]' and instrument_category_code='$getinstcat->[0]'");
						if (!defined $sth_checkit) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkit->execute;
						while ($checkit = $sth_checkit->fetch) {
							$match=$checkit->[0];
						} 
						if ($match > 0) {
							# not new! already in arm_int at least partially
							$dbstatarray[$idx]=-1; # indicates partially in arm_int
							$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 where IDNo=$idn");
							$doStatus = $dbh->do("UPDATE instClass set statusFlag=1 where IDNo=$idn");
						} else {
							$sql[$sqlcount]="INSERT INTO arm_int2.$instrclasstoinstrcattab values('$getclass->[0]','$getinstcat->[0]');";
							#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclasstoinstrcattab values('$getclass->[0]','$getinstcat->[0]');\n";
							$sqlcount = $sqlcount + 1;
							$idstatcheck = $idstatcheck + 1;
						}
					}
					if ($dbstatarray[$idx] == 0) {
						$sth_getsource = $dbh->prepare("SELECT distinct source_class,statusFlag from sourceClass where IDNo=$idn");
						if (!defined $sth_getsource) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getsource->execute;
						while ($getsource = $sth_getsource->fetch) {
							$sth_checkarchive = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclasstosourceclass WHERE lower(instrument_class_code)='$getclass->[0]' and source_class_code='$getsource->[0]'");
							if (!defined $sth_checkarchive) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_checkarchive->execute;
							while ($checkarchive = $sth_checkarchive->fetch) {
								$match = $checkarchive->[0];
							}
							if ($match > 0) {
								# not new! already in arm_int at least partially
								$dbstatarray[$idx]=-1; # indicates partially in arm_int
								$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 where IDNo=$idn");
								$doStatus = $dbh->do("UPDATE instClass set statusFlag=1 where IDNo=$idn");
							} else {
								$sql[$sqlcount]="INSERT INTO arm_int2.$instrclasstosourceclass values('$getclass->[0]','$getsource->[0]');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclasstosourceclass values('$getclass->[0]','$getsource->[0]');\n";	
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							}
						}
						$match=0;
						$sth_checkarchive=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclassdetailstab where instrument_class_code='$getclass->[0]' and instrument_class_name='$getclass->[1]' ");
						if (!defined $sth_checkarchive) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkarchive->execute;
						while ($checkarchive = $sth_checkarchive->fetch) {
							$match = $checkarchive->[0];
						}
						if ($match > 0) {
							# not new! already in arm_int at least partially
							$dbstatarray[$idx]=-1; # indicates partially in arm_int
							$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 where IDNo=$idn");
							$doStatus = $dbh->do("UPDATE instClass set statusFlag=1 where IDNo=$idn");
						} else {
							$sql[$sqlcount]="INSERT INTO arm_int2.$instrclassdetailstab values('$getclass->[0]','$getclass->[1]','Y','Y');";
							#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclassdetailstab values('$getclass->[0]','$getclass->[1]','Y','Y');\n";	
							$sqlcount = $sqlcount + 1;
							$idstatcheck = $idstatcheck + 1;
						}
					}			
				}			
			}
			if (($dbstatarray[$idx] == 1) || ($dbstatarray[$idx] == -1) || ($dbstatarray[$idx] == 2)) {
				# update/new/delete instclass,inst category, Source Class 
				my $thisinstclass="";
				my $thisinstcode="";
				my $thisinstclassname="";
				my $thissourceclass="";
				my $matchps=0;
				$sth_getinst= $dbh->prepare("SELECT lower(instrument_class),instrument_class_name from instClass where IDNo=$idn");
				if (!defined $sth_getinst) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getinst->execute;
				while ($getinst = $sth_getinst->fetch) {
					$thisinstclass=$getinst->[0];
					$thisinstclassname=$getinst->[1];
					$match=0;
					$sth_checkinst = $dbh->prepare("SELECT count(*) from $archivedb.$instrclassdetailstab WHERE lower(instrument_class_code)='$thisinstclass' and instrument_class_name='$thisinstclassname'");
					if (!defined $sth_checkinst) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkinst->execute;
					while ($checkinst = $sth_checkinst->fetch) {
						$match = $checkinst->[0];
					}
					if ($match == 0) {
						$sth_checkinst2 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclassdetailstab WHERE lower(instrument_class_code)='$thisinstclass'");
						if (!defined $sth_checkinst2) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkinst2->execute;
						while ($checkinst2 = $sth_checkinst2->fetch) {
							$match = $checkinst2->[0];
						}
						if ($match == 0) {
							$sql[$sqlcount]="DELETE from arm_int2.$instrclassdetailstab where instrument_class_code='$thisinstclass' or instrument_class_name='$thisinstclassname';";	
							#print ARMINT2 "DELETE from arm_int2_stage.$instrclassdetailstab where instrument_class_code='$thisinstclass' or instrument_class_name='$thisinstclassname';\n";	
							$sqlcount = $sqlcount + 1;
							$sql[$sqlcount]="INSERT INTO arm_int2.$instrclassdetailstab values('$thisinstclass','$thisinstclassname','Y','Y');";
							#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclassdetailstab values('$thisinstclass','$thisinstclassname','Y','Y');\n";
							$sqlcount = $sqlcount + 1;
							$idstatcheck = $idstatcheck + 1;
						} else {
							$sql[$sqlcount]="UPDATE arm_int2.$instrclassdetailstab set instrument_class_name='$thisinstclassname' where lower(instrument_class_code)='$thisinstclass';";
							#print ARMINT2 "UPDATE arm_int2_stage.$instrclassdetailstab set instrument_class_name='$thisinstclassname' where lower(instrument_class_code)='$thisinstclass';\n";		
							$sqlcount = $sqlcount + 1;
							$idstatcheck = $idstatcheck + 1;
						}	
					}
					# check if new inst cats need to be inserted
					$lcinstClass = lc $instClass;
					$sth_checkcatsa = $dbh->prepare("SELECT inst_category_code from instCats where IDNo=$idn");
					if (!defined $sth_checkcatsa) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkcatsa->execute;
					while ($checkcatsa = $sth_checkcatsa->fetch) {
						$sth_checkcatsb = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab where lower(instrument_class_code)='$thisinstclass' and instrument_category_code='$checkcatsa->[0]'");
						if (!defined $sth_checkcatsb) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkcatsb->execute;
						while ($checkcatsb = $sth_checkcatsb->fetch) {
							if ($checkcatsb->[0] == 0) {
								$sql[$sqlcount]="INSERT INTO arm_int2.$instrclasstoinstrcattab values('$thisinstclass','$checkcatsa->[0]');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclasstoinstrcattab values('$thisinstclass','$checkcatsa->[0]');\n";
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							} 
						}
					}
					# check if existing inst cats need to be removed	
					$sth_checkcatsa = $dbh->prepare("SELECT instrument_category_code,instrument_category_code from $archivedb.$instrclasstoinstrcattab where lower(instrument_class_code)='$thisinstclass'");
					if (!defined $sth_checkcatsa) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkcatsa->execute;
					while ($checkcatsa = $sth_checkcatsa->fetch) {
						$sth_checkcatsb = $dbh->prepare("SELECT count(*),count(*) from instCats where IDNo=$idn and inst_category_code='$checkcatsa->[0]'");
						if (!defined $sth_checkcatsb) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkcatsb->execute;
						while ($checkcatsb = $sth_checkcatsb->fetch) {
							if ($checkcatsb->[0] == 0) {
								$sql[$sqlcount]="DELETE from arm_int2.$instrclasstoinstrcattab where lower(instrument_class_code)='$thisinstclass' and instrument_category_code='$checkcatsa->[0]';";	
								#print ARMINT2 "DELETE from arm_int2_stage.$instrclasstoinstrcattab where lower(instrument_class_code)='$thisinstclass' and instrument_category_code='$checkcatsa->[0]';\n";	
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							}
						}
					}
					# check if new sources need to be inserted
					$sth_checksourcea = $dbh->prepare("SELECT source_class,source_class from sourceClass where IDNo=$idn");
					if (!defined $sth_checksourcea) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checksourcea->execute;
					while ($checksourcea = $sth_checksourcea->fetch) {
						$sth_checksourceb = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclasstosourceclass where lower(instrument_class_code)='$thisinstclass' and source_class_code='$checksourcea->[0]'");
						if (!defined $sth_checksourceb) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checksourceb->execute;
						while ($checksourceb = $sth_checksourceb->fetch) {
							if ($checksourceb->[0] == 0) {
								$sql[$sqlcount]="INSERT INTO arm_int2.$instrclasstosourceclass values('$thisinstclass','$checksourcea->[0]');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclasstosourceclass values('$thisinstclass','$checksourcea->[0]');\n";
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							} 
						}
					}
					# check if existing sources need to be removed
					$sth_checksourcea = $dbh->prepare("SELECT source_class_code,source_class_code from $archivedb.$instrclasstosourceclass where lower(instrument_class_code)='$thisinstclass'");
					if (!defined $sth_checksourcea) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checksourcea->execute;
					while ($checksourcea = $sth_checksourcea->fetch) {
						$sth_checksourceb = $dbh->prepare("SELECT count(*),count(*) from sourceClass where IDNo=$idn and source_class='$checksourcea->[0]'");
						if (!defined $sth_checksourceb) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checksourceb->execute;
						while ($checksourceb = $sth_checksourceb->fetch) {
							if ($checksourceb->[0] == 0) {
								$sql[$sqlcount]="DELETE from arm_int2.$instrclasstosourceclass where lower(instrument_class_code)='$thisinstclass' and source_class_code='$checksourcea->[0]';";
								#print ARMINT2 "DELETE from arm_int2_stage.$instrclasstosourceclass where lower(instrument_class_code)='$thisinstclass' and source_class_code='$checksourcea->[0]';\n";
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							} 
						}
					}
					#  the below is for updating the site cat insts tables.... dont think I need to do this in the inst class module so I took it out.
					#  for an inst class, there isnt the notion of which site it belongs to initially... hmmmm......
					#@sciinstcodearray=();
					#$scisite="";
					#@scisdarray=();
					#@sciedarray=();
					#@sciretarray=();
					#$ct=0;
					#print "SELECT distinct site,instrument_code,start_date,end_date,retired from $archivedb.$sitecatinsttab WHERE instrument_class=\"$thisinstclass\"<br>\n";
					#@geticodes=$dbh->prepare("SELECT distinct site,instrument_code,start_date,end_date,retired from $archivedb.$sitecatinsttab WHERE instrument_class='$thisinstclass'");
					#foreach $geticodes (@geticodes) {
					#	$scisite=$geticodes->[0];
					#	$sciinstcodearray[$ct]=$geticodes->[1];
					#	$scisdarray[$ct]=$geticodes->[2];
					#	$sciedarray[$ct]=$geticodes->[3];		
					#	$sciretarray[$ct]=$geticodes->[4];
					#	$ct = $ct + 1;
					#}
					#print "ct $ct<br>\n";
					#if ($ct > 0) {
					#	$sql[$sqlcount]="DELETE FROM arm_int.site_category_instruments where instrument_class='$thisinstclass';";
					#	$sqlcount = $sqlcount+1;
					#	$idstatcheck = $idstatcheck + 1;
					#	@geticats=$dbh->prepare("SELECT distinct inst_category_code,inst_category_code from instCats where IDNo=$idn");
					#	foreach $geticats (@geticats) {
					#		$sql[$sqlcount]="INSERT INTO arm_int.site_category_instruments values('$scisite','$geticats->[0]','$thisinstclass','$sciinstcodearray[$c]','$scisdarray[$c]','$sciedarray[$c]','$sciretarray[$c]');";
					#		$sqlcount = $sqlcount+1;
					#		$idstatcheck = $idstatcheck + 1;
					#	}
					#}
				}
			}
			if ($idstatcheck == 0) {
				print "NO Archive DB ENTRY/UPDATE required($idn): up-to-date!<br>\n";	
				print "Status of this entry (MMT# $idn) will be set to Approved/Completed<p>\n";
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");
				$doStatus = $dbh->do("UPDATE instClass set statusFlag=2 where IDNo=$idn");
			} else {
				print "Archive DB ENTRY/UPDATE required($idn)<br>\n";
				print "Implementation Request sent to archive<p>\n";
			}
			$idx = $idx + 1;
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
			#if ($countarray > 1) {
			#	close(ARMINT2);
			#}								
		}
		if ($emchk eq "") {
			if ($sqlcount > 0) {
				@sortedlist=();
				@sortedlist=sort @sql;
				$oldsq="";
				######## send implementation notification to archive 
				######## future step is to apply implementation inst directly to archive arm_int2 database via postgres replication				
				########     11/29/2016 - Harold is merging arm_apps table into arm_int2 so will change those inserts to match
				$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL'");	
				if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdist->execute;
				while ($getdist = $sth_getdist->fetch) {
					$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$getdist->[0]");
					if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getemail->execute;
					while ($getemail = $sth_getemail->fetch) {
						if ($idx == 1) {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Instrument Class ENTRY/UPDATE ready for implementation - MMT# @idarray\" \"$getemail->[1]\"");	
						} else {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Batch - Instrument Class ENTRY/UPDATE ready for implementation\" \"$getemail->[1]\"");
						}
						print MAIL "ENTRY/UPDATE for Instrument Class(es) ready for implementation in archive metadata databases.\n";
						print MAIL "SQL commands follow for your convenience:\n";
						print MAIL "--------------------------------------------\n\n";
						$oldsq="";
						foreach $sq (@sortedlist) {
							if ($oldsq ne $sq) {
								print MAIL "$sq\n";
							}
							$oldsq=$sq;
						}
						if ($idx == 1) {
							foreach $idn (@idarray) {
								print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
							}
						} else {
							print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=I";		
						}
						close(MAIL);
					}
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}
		$webblurb="";	
		$countids=0;
		$countids = @idarray;
		# for now do not send batch "web blurbs" - only if this is an individual approval
		# NEED TO WORK ON THIS SECTION BELOW - need to figure out how to access word press to get updated blurb
		# or to compare blurb in mmt to blurb in wordpress!
		if ($countids == 1) {
			foreach $idn (@idarray) {
				$chkit="";
				$sth_getblurb = $dbh->prepare("SELECT instrument_class,instPageDesc,instrument_class_name from instClass,instWebPageBlurb where instClass.IDNo=instWebPageBlurb.IDNo and instClass.IDNo=$idn");
				if (!defined $sth_getblurb) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getblurb->execute;
				while ($getblurb = $sth_getblurb->fetch) {
					$webblurb="Instrument Class: "."$getblurb->[0]\n";
					$webblurb = "$webblurb"."Instrument Class Name: "."$getblurb->[2]\n";
					$webblurb = "$webblurb"."Web Page Description: "."$getblurb->[1]\n";
					$chkit="$getblurb->[1]";
				}
				$len=0;
				$len=length $chkit;
				if ($len > 1) {
					$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL-WEB' and reviewers.type='$objct'");
					if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getdist->execute;
					while ($getdist = $sth_getdist->fetch) {
						$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$getdist->[0]");
						if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getemail->execute;
						while ($getemail = $sth_getemail->fetch) {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: WEB PAGE- Suggested Text for Instrument Class Web Page Description(s)\" \"$getemail->[1]\"");	
					
							print MAIL "--------------------------------------------\n";
							print MAIL "$webblurb\n";
							print MAIL "--------------------------------------------\n";
							print MAIL "\nPlease see the MMT for additional details.\n";
							print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn\n";
							close(MAIL);
						}
					}
				}
			}
		}
	}	
####################################		
	# instrument code request
	if ($objct eq "IC") {
		#print "in here<br>\n";
		$sqlcount=0;
		@sql=();
		$idx=0;
		$countarray=0;
		$countarray=@idarray;
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
		
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			$idstatcheck=0;
			#print "SELECT lower(instrument_code),instrument_code_name,lower(instrument_class) from instcodes where IDNo=$idn<br>\n";
			#exit;
			$sth_getcode=$dbh->prepare("SELECT lower(instrument_code),instrument_code_name,lower(instrument_class) from instcodes where IDNo=$idn");
			if (!defined $sth_getcode) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcode->execute;
			while ($getcode = $sth_getcode->fetch) {
				$match=0;
				# check if it is a new instrument code
				#print "SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code)='$getcode->[2]'<br>\n";
				#exit;
				$sth_checkit = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code)='$getcode->[2]'");
				if (!defined $sth_checkit) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkit->execute;
				while ($checkit = $sth_checkit->fetch) {
					$match=$checkit->[0];
				} 
				#print "match $match<br>\n";
				if ($match > 0) {
					; #code/class pair exists - no insert needed in instrcodetoinstrclasstab
		
				} else {
					# code/class pair doesnt exist - add it
					$sql[$sqlcount]="INSERT INTO arm_int2.$instrcodetoinstrclasstab values('$getcode->[0]','$getcode->[2]');";
					#print ARMINT2 "INSERT INTO arm_int2_stage.$instrcodetoinstrclasstab values('$getcode->[0]','$getcode->[2]');\n";
					$sqlcount = $sqlcount + 1;
					$idstatcheck = $idstatcheck + 1;
				}
				# double check that there are not more than one class for this code
				$counterror=0;
				#print "SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_code)='$getcode->[0]'<br>\n";
				$sth_checkforerror = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where lower(instrument_code)='$getcode->[0]' AND lower(instrument_class_code) != '$getcode->[2]'");
				
				if (!defined $sth_checkforerror) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkforerror->execute;
				while ($checkforerror = $sth_checkforerror->fetch) {
					$counterror=$checkforerror->[0];
				}
				#print "counterror $counterror<br>\n";
				#print "found more than one class for this code....<br>\n";
				
				if ($counterror > 0) {
					#print "in here<br>\n";
					# found more than 1 code/class pairs - need to delete any besides this one
					#print "DELETE FROM arm_int2.$sitetoinstrinfotab WHERE lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code) != '$getcode->[2]';<br>\n";
					$sql[$sqlcount]="DELETE FROM arm_int2.$sitetoinstrinfotab WHERE lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code) != '$getcode->[2]';";
					#print ARMINT2 "DELETE FROM arm_int2.$sitetoinstrinfotab WHERE lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code) != '$getcode->[2]'';\n";
					$sqlcount = $sqlcount + 1;
					$idstatcheck = $idstatcheck + 1;
					#print "DELETE FROM arm_int2.$instrcodetoinstrclasstab WHERE lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code) != '$getcode->[2]'<br>\n";
					$sql[$sqlcount]="DELETE FROM arm_int2.$instrcodetoinstrclasstab WHERE lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code) != '$getcode->[2]';";
					#print ARMINT2 "DELETE FROM arm_int2.$instrcodetoinstrclasstab WHERE lower(instrument_code)='$getcode->[0]' and lower(instrument_class_code) != '$getcode->[2]'';\n";
					$sqlcount = $sqlcount + 1;
					$idstatcheck = $idstatcheck + 1;
				
				}
				$matchcn=0;
				#print "SELECT count(*) from $archivedb.$instrcodedetailstab WHERE lower(instrument_code)='$getcode->[0]' and instrument_name='$getcode->[1]'<br>\n";
				$sth_checkcodename = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodedetailstab WHERE lower(instrument_code)='$getcode->[0]' and instrument_name='$getcode->[1]'");
				if (!defined $sth_checkcodename) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkcodename->execute;
				while ($checkcodename = $sth_checkcodename->fetch) {
					$matchcn = $checkcodename->[0];
				}
				#print "matchcn $matchcn<br>\n";
				if ($matchcn > 0) {
						; #no updates needed - code and code name in instrcodedetailstab
				} else {
					# check if we are missing the code altogether in instrcodedetails first - if not just update name
					$matchc=0;
					#print "SELECT count(*) from $archivedb.$instrcodedetailstab WHERE lower(instrument_code)='$getcode->[0]'<br>\n";
					$sth_checkcode = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodedetailstab WHERE lower(instrument_code)='$getcode->[0]'");
					if (!defined $sth_checkcode) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkcode->execute;
					while ($checkcode = $sth_checkcode->fetch) {
						$matchc=$checkcode->[0];
					}
					#print "matchc $matchc<br>\n";
					if ($matchc > 0) {
						# no inserts needed, but update to code name is
						#update to code name is needed
						$dbstatarray[$idx]=-1; # indicates partially in arm_int2
						$doStatus = $dbh->do("UPDATE IDs set DBstatus=1 where IDNo=$idn");
						$doStatus = $dbh->do("UPDATE instCodes set statusFlag=-1 where IDNo=$idn and lower(instrument_class)='$getcode->[3]'");
						# update code name
						$sql[$sqlcount]="UPDATE arm_int2.$instrcodedetailstab set instrument_name='$getcode->[1]' WHERE lower(instrument_code)='$getcode->[0]';";
						#print ARMINT2 "UPDATE arm_int2_stage.$instrcodedetailstab set instrument_name='$getcode->[1]' WHERE lower(instrument_code)='$getcode->[0]';\n";
						$sqlcount = $sqlcount + 1;
						$idstatcheck = $idstatcheck + 1;
					} else {
						#if matchc == 0, insert is needed
						$dbstatarray[$idx]=0; # not implemented in arm_int2
						$doStatus = $dbh->do("UPDATE IDs set DBstatus=1 where IDNo=$idn");
						$doStatus = $dbh->do("UPDATE instCodes set statusFlag=-1 where IDNo=$idn and lower(instrument_class)='$getcode->[3]'");
							
						$sql[$sqlcount]="INSERT INTO arm_int2.$instrcodedetailstab values('$getcode->[0]','$getcode->[1]','Y','Y');";
						#print ARMINT2 "INSERT INTO arm_int2.$instrcodedetailstab values('$getcode->[0]','$getcode->[1]','Y','Y');\n";
						$sqlcount = $sqlcount + 1;
						$idstatcheck = $idstatcheck + 1;
							
						
					}
				}
			}
			if ($idstatcheck == 0) {
				print "NO Archive DB ENTRY/UPDATE required($idn): up-to-date!<br>\n";	
				print "Status of this entry (MMT# $idn) will be set to Approved/Completed<p>\n";
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");
				$doStatus = $dbh->do("UPDATE instcodes set statusFlag=2 where IDNo=$idn");
			} else {
				print "Archive DB ENTRY/UPDATE required($idn)<br>\n";
				print "Implementation Request sent to archive<p>\n";
			}
			$idx = $idx + 1;			
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
			#if ($countarray > 1) {
			#	close(ARMINT2);
			#}								
		}
		if ($emchk eq "") {
			if ($sqlcount > 0) {
				######## send implementation notification to archive 
				######## future step is to apply implementation inst directly to archive arm_int2 database via postgres replication				
				########     11/29/2016 - Harold is merging arm_apps table into arm_int2 so will change those inserts to match
				$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL'");	
				if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdist->execute;
				while ($getdist = $sth_getdist->fetch) {
					$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$getdist->[0]");
					if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getemail->execute;
					while ($getemail = $sth_getemail->fetch) {
						if ($idx == 1) {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Instrument Code ENTRY/UPDATE ready for implementation - MMT# @idarray\" \"$getemail->[1]\"");	
						} else {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Batch - Instrument Code ENTRY/UPDATE ready for implementation\" \"$getemail->[1]\"");
						}
						print MAIL "ENTRY/UPDATE for Instrument Code(s) ready for implementation in archive metadata databases.\n";
						print MAIL "SQL commands follow for your convenience:\n";
						print MAIL "--------------------------------------------\n\n";
						foreach $sq (@sql) {
							print MAIL "$sq\n";
						}
						if ($idx == 1) {
							foreach $idn (@idarray) {
								print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
							}
						} else {
							print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=IC";		
						}
						close(MAIL);
					}
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}
	
	
	}
	

	
####################################
	# primary measurement type request
	if ($objct eq "PMT") {
		$sqlcount=0;
		@sql=();
		$idx=0;
		$countarray=0;
		$countarray=@idarray;
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
		
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			$chkit="";
			$sth_getpm=$dbh->prepare("SELECT primary_meas_code,primary_meas_code from primMeas where IDNo=$idn");
			if (!defined $sth_getpm) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getpm->execute;
			while ($getpm = $sth_getpm->fetch) {
				$chkit=$getpm->[0];
			}
			$sth_chkarchive = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmtypedetailstab WHERE primary_meas_type_code='$chkit'");
			if (!defined $sth_chkarchive) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_chkarchive->execute;
			while ($chkarchive = $sth_chkarchive->fetch) {
				$isit=$chkarchive->[0];
			}
			if ($isit > 0) {
				$dbstatarray[$idx]=-1;
			} else {
				$dbstatarray[$idx]=0;
			}
			$idstatcheck=0;
			if ($dbstatarray[$idx] == 0) {
				# Send new primary measurement type code implementation sql to archive
				@sql=();
				$sth_getpmt=$dbh->prepare("SELECT primary_meas_code,primary_meas_name,primary_meas_desc,statusFlag from primMeas where IDNo=$idn");
				if (!defined $sth_getpmt) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getpmt->execute;
				while ($getpmt = $sth_getpmt->fetch) {
					$sql[$sqlcount]="INSERT INTO arm_int2.$pmtypedetailstab values('$getpmt->[0]','$getpmt->[1]','$getpmt->[2]','Y','Y');";
					#print ARMINT2 "INSERT INTO arm_int2_stage.$pmtypedetailstab values('$getpmt->[0]','$getpmt->[1]','$getpmt->[2]','Y','Y');\n";
					$sqlcount = $sqlcount + 1;
					$idstatcheck = $idstatcheck + 1;
					$omcat="";
					$sth_getmeascat=$dbh->prepare("SELECT distinct meas_category_code,meas_subcategory_code,statusFlag from measCats where IDNo=$idn order by meas_category_code,meas_subcategory_code");
					if (!defined $sth_getmeascat) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getmeascat->execute;
					while ($getmeascat = $sth_getmeascat->fetch) {
						if ($getmeascat->[0] ne $omcat) {
							$chkcounting=0;
							$sth_chkfirst = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeascatalllower WHERE primary_meas_type_code='$getpmt->[0]' and meas_category_code='$getmeascat->[0]'");
							if (!defined $sth_chkfirst) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_chkfirst->execute;
							while ($chkfirst = $sth_chkfirst->fetch) {
								$chkcounting=$chkfirst->[0];
							}
							if ($chkcounting == 0) {	
								$sql[$sqlcount]="INSERT INTO arm_int2.$pmcodetomeascatalllower values('$getpmt->[0]','$getmeascat->[0]');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$pmcodetomeascatalllower values('$getpmt->[0]','$getmeascat->[0]');\n";
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							}
						}
						if ($getmeascat->[1] ne "") {
							$chkcounting=0;
							$sth_chkfirst = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeassubcatalllower WHERE primary_meas_type_code='$getpmt->[0]' AND meas_subcategory_code='$getmeascat->[1]'");
							if (!defined $sth_chkfirst) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_chkfirst->execute;
							while ($chkfirst = $sth_chkfirst->fetch) {
								$chkcounting=$chkfirst->[0];
							}
							if ($chkcounting == 0) {
								$sql[$sqlcount]="INSERT INTO arm_int2.$pmcodetomeassubcatalllower values('$getpmt->[0]','$getmeascat->[1]');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$pmcodetomeassubcatalllower values('$getpmt->[0]','$getmeascat->[1]');\n";
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							}
						}
						$omcat=$getmeascat->[0];
					}
				}
			}
			if (($dbstatarray[$idx] == 1) || ($dbstatarray[$idx] == -1) || ($dbstatarray[$idx] == 2)) {
				# Send update/new/delete pmt,meas category/subcategory implementation sql to archive
				my $thispmtcode="";
				my $thispmtname="";
				my $thispmtdesc="";
				my $thismeascat="";
				my $thismeassubcat="";
				$sth_getpmt= $dbh->prepare("SELECT primary_meas_code,primary_meas_name,primary_meas_desc from primMeas where IDNo=$idn");
				if (!defined $sth_getpmt) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getpmt->execute;
				while ($getpmt = $sth_getpmt->fetch) {
					$thispmt=$getpmt->[0];
					$thispmtname=$getpmt->[1];
					$thispmtdesc=$getpmt->[2];
					$match=0;
					$checkdesc=0;
					$sth_checkpmtdesc=$dbh->prepare("SELECT primary_meas_type_code,primary_meas_type_desc,primary_meas_type_name from $archivedb.$pmtypedetailstab WHERE primary_meas_type_code='$thispmt'");
					if (!defined $sth_checkpmtdesc) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkpmtdesc->execute;
					while ($checkpmtdesc = $sth_checkpmtdesc->fetch) {
						if ($thispmtdesc eq $checkpmtdesc->[1]) {
							$checkdesc=1;
							if ($thispmtname eq $checkpmtdesc->[2]) {
								$checkdesc=1;
							} else {
								$checkdesc=-1;
							}
						} else {
							$checkdesc=-1;
						}
					}
					if ($checkdesc == -1) {
						$sql[$sqlcount]="UPDATE arm_int2.$pmtypedetailstab set primary_meas_type_desc='$thispmtdesc',primary_meas_type_name='$thispmtname' WHERE primary_meas_type_code='$thispmt';";
						#print ARMINT2 "UPDATE arm_int2_stage.$pmtypedetailstab set primary_meas_type_desc='$thispmtdesc',primary_meas_type_name='$thispmtname' WHERE primary_meas_type_code='$thispmt';\n";
						$sqlcount = $sqlcount + 1;
						$idstatcheck = $idstatcheck + 1;
					}
					# handle meascats/subcats
					$catscount=0;
					$subcatscount=0;
					$omcat="";
					$sth_checkcatsa = $dbh->prepare("SELECT distinct meas_category_code,meas_subcategory_code from measCats where IDNo=$idn order by meas_category_code,meas_subcategory_code");
					if (!defined $sth_checkcatsa) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_checkcatsa->execute;
					while ($checkcatsa = $sth_checkcatsa->fetch) {
						if ($checkcatsa->[0] ne $omcat) {
							$chkcounting=0;
							$sth_chkit = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeascatalllower WHERE primary_meas_type_code='$thispmt' and meas_category_code='$checkcatsa->[0]'");
							if (!defined $sth_chkit) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_chkit->execute;
							while ($chkit = $sth_chkit->fetch) {
								$chkcounting=$chkit->[0];
							}
							if ($chkcounting == 0) {
								$sql[$sqlcount]="INSERT INTO arm_int2.$pmcodetomeascatalllower values('$thispmt','$checkcatsa->[0]');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$pmcodetomeascatalllower values('$thispmt','$checkcatsa->[0]');\n";
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							}
						}
						if ($checkcatsa->[1] ne "") {
							$chkcounting = 0;
							$sth_chkit=$dbh->prepare("SELECT count(*),count(*) from $archivedb.$pmcodetomeassubcatalllower WHERE primary_meas_type_code='$thispmt' and meas_subcategory_code='$checkcatsa->[1]'");
							if (!defined $sth_chkit) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_chkit->execute;
							while ($chkit = $sth_chkit->fetch) {
								$chkcounting = $chkit->[0];
							}
							if ($chkcounting == 0) {
								$sql[$sqlcount]="INSERT INTO arm_int2.$pmcodetomeassubcatalllower values('$thispmt','$checkcatsa->[1]');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$pmcodetomeassubcatalllower values('$thispmt','$checkcatsa->[1]');\n";
								$sqlcount = $sqlcount + 1;
								$idstatcheck = $idstatcheck + 1;
							}
						}
						$omcat=$checkcatsa->[0];	
					}
				}
			}
			if ($idstatcheck == 0) {
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");
				$doStatus = $dbh->do("UPDATE primMeas set statusFlag=2 where IDNo=$idn");
				print "NO Archive DB ENTRY/UPDATE required($idn): up-to-date!<br>\n";	
				print "Status of this entry (MMT# $idn) will be set to Approved/Completed<p>\n";
			} else {
				if ($sqlcount > 0) {
					$doStatus = $dbh->do("UPDATE primMeas set statusFlag=$dbstatarray[$idx] where IDNo=$idn");
					$doStatus = $dbh->do("UPDATE IDs set DBstatus=$dbstatarray[$idx] where IDNo=$idn");
					print "Archive DB ENTRY/UPDATE required($idn)<br>\n";
					print "Implementation request sent to archive<p>\n";
				}
			}
			$idx = $idx + 1;			
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
			#if ($countarray > 1) {
			#	close(ARMINT2);
			#}								
		}
		if ($emchk eq "") {
			if ($sqlcount > 0) {
				@sortedlist=();
				@sortedlist=sort @sql;
				$oldsq="";
				$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL'");	
				if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdist->execute;
				while ($getdist = $sth_getdist->fetch) {
					$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$getdist->[0]");
					if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getemail->execute;
					while ($getemail = $sth_getemail->fetch) {
						if ($idx == 1) {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: PMT ENTRY/UPDATE ready for implementation - MMT# @idarray\" \"$getemail->[1]\"");	
						} else {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Batch - PMT ENTRY/UPDATE ready for implementation\" \"$getemail->[1]\"");
						}
						print MAIL "ENTRY/UPDATE for a PMT ready for implementation in archive metadata databases.\n";
						print MAIL "--------------------------------------------\n";
						print MAIL "SQL commands follow for your convenience:\n\n";
						$oldsq="";
						foreach $sq (@sortedlist) {
							if ($oldsq ne $sq) {
								print MAIL "$sq\n";
							}
							$oldsq=$sq;
						}	
						if ($idx == 1) {
							foreach $idn (@idarray) {
								print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
							}
						} else {
							print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=PMT";
						}
					close(MAIL);
					}
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}				
	}
#########################
	if ($objct eq "CI") {
	###### clone request
		$idx=0;
		$sqlcount=0;
		@sql=();
		$countarray=0;
		$countarray=@idarray;
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
		
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			$idno=$idn;
			$doublecheckstatarray=0;
			$OK=0;
			@tabslist=();
			@tabslist=();
			$tabcount=0;
			@sortedtabslist=();
			# check implementation status at archive
			my $nsite="";
			my $nfaccode="";
			my $osite="";
			my $ofaccode="";
			my $ocinstcode="";  # from the clone table
			my $ncinstcode="";  # from the clone table
			my $oinstcode="";
			my $oinstclass="";
			$sth_getcloneinfo = $dbh->prepare("SELECT distinct lower(osite),ofacility_code,lower(nsite),nfacility_code,data_level from clone where IDNo=$idn");	
			if (!defined $sth_getcloneinfo) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcloneinfo->execute;
			while ($getcloneinfo = $sth_getcloneinfo->fetch) {
				$osite=$getcloneinfo->[0];
				$ofaccode=$getcloneinfo->[1];
				$nsite=$getcloneinfo->[2];
				$nfaccode=$getcloneinfo->[3];
			}
			$nsitestart=""; # use start and end dates for new site
			$nsiteend="";
			$sth_getdates = $dbh->prepare("SELECT distinct start_date,end_date from $archivedb.$siteinfotab where upper(site_code)=upper('$nsite')");	
			if (!defined $sth_getdates) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getdates->execute;
			while ($getdates = $sth_getdates->fetch) {
				$nsitestart=$getdates->[0];
				$nsiteend=$getdates->[1];
			}
			if ($nsitestart eq "") {
				$nsitestart="NULL";
			} else {
				$nsitestart="'"."$nsitestart"."'";
			}
			if ($nsiteend eq "") {
				$nsiteend="NULL";
			} else {
				$nsiteend="'"."$nsiteend"."'";
			}		
			$existinstcode=0;
			#get old (and possibly new) instrument codes and data levels from the clone table
			$sth_getinstcode = $dbh->prepare("SELECT distinct IDNo,instrument_code,ninstrument_code,ninstrument_code_name,ndata_level from clone where IDNo=$idn");	
			if (!defined $sth_getinstcode) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getinstcode->execute;
			while ($getinstcode = $sth_getinstcode->fetch) {
				$ocinstcode=$getinstcode->[1];
				$ncinstcode=$getinstcode->[2];
				$ncinstcodename=$getinstcode->[3];
				if ($ncinstcode eq "") {
					$sth_getcountcl = $dbh->prepare("SELECT distinct instrument_class_code,instrument_code from $archivedb.$instrcodetoinstrclasstab where instrument_code='$ocinstcode'");	
					if (!defined $sth_getcountcl) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getcountcl->execute;
					while ($getcountcl = $sth_getcountcl->fetch) {
						$oinstclass=$getcountcl->[0];
						$oinstcode=$getcountcl->[1];
						$sth_getsitetoinstr = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$sitetoinstrinfotab where site_code='$nsite' and instrument_class_code='$oinstclass' and instrument_code='$ocinstcode'");	
						if (!defined $sth_getsitetoinstr) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getsitetoinstr->execute;
						while ($getsitetoinstr = $sth_getsitetoinstr->fetch) {
							$OK=$getsitetoinstr->[0];
						}
						#print "OK $OK<br>\n";
						if ($OK > 0) {
							$OK=1;		
						} else { 
							$OK=0; #not in site_to_instr_info table
							$tabslist[$tabcount]="$sitetoinstrinfotab: $ocinstcode for site $nsite";
							$tabcount = $tabcount + 1;
							
							$sth_getcat = $dbh->prepare("SELECT instrument_class_code,instrument_category_code from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$oinstclass'");	
							if (!defined $sth_getcat) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_getcat->execute;
							while ($getcat = $sth_getcat->fetch) {
								$instcat=$getcat->[1];		
								#print "INSERT INTO arm_int2_stage.$sitetoinstrinfotab values ('$nsite','$instcat','$oinstclass','$ocinstcode',$nsitestart,$nsiteend,'N','Y','Y');\n";
								$sql[$sqlcount]="INSERT INTO arm_int2.$sitetoinstrinfotab values ('$nsite','$instcat','$oinstclass','$ocinstcode',$nsitestart,$nsiteend,'N','Y','Y');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$sitetoinstrinfotab values ('$nsite','$instcat','$oinstclass','$ocinstcode',$nsitestart,$nsiteend,'N','Y','Y');\n";
								$sqlcount = $sqlcount + 1;
								$existinstcode = $existinstcode + 1;
							}
						}
					}
				} elsif ($ncinstcode ne "") {
					$sth_getcountcl = $dbh->prepare("SELECT distinct instrument_class_code,instrument_code from $archivedb.$instrcodetoinstrclasstab where instrument_code='$ocinstcode'");	
					if (!defined $sth_getcountcl) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getcountcl->execute;
					while ($getcountcl = $sth_getcountcl->fetch) {
						$oinstclass=$getcountcl->[0];
						$oinstcode=$getcountcl->[1]; # but will not be used - will use old inst class and new inst code instead for insert if needed
						#check site_to_instr_info table - likely need an insert for new inst code
						$sth_getsitetoinstr = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$sitetoinstrinfotab where site_code='$nsite' and instrument_class_code='$oinstclass' and instrument_code='$ncinstcode'");	
						if (!defined $sth_getsitetoinstr) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getsitetoinstr->execute;
						while ($getsitetoinstr = $sth_getsitetoinstr->fetch) {
							$OK=$getsitetoinstr->[0];
						}
						if ($OK > 0) {
							$OK=1;		
						} else { 
							$OK=0; #not in site_to_instr_info table
							$checkthissql=0;
							$tabslist[$tabcount]="$sitetoinstrinfotab $ncinstcode for site $nsite";
							$tabcount = $tabcount + 1;
							$sth_getcat = $dbh->prepare("SELECT instrument_class_code,instrument_category_code from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$oinstclass'");	
							if (!defined $sth_getcat) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_getcat->execute;
							while ($getcat = $sth_getcat->fetch) {
								$instcat=$getcat->[1];	
								#print "INSERT INTO arm_int2.$sitetoinstrinfotab values ('$nsite','$instcat','$oinstclass','$ncinstcode',$nsitestart,$nsiteend,'N','Y','Y')<br>\n";
								$sql[$sqlcount]="INSERT INTO arm_int2.$sitetoinstrinfotab values ('$nsite','$instcat','$oinstclass','$ncinstcode',$nsitestart,$nsiteend,'N','Y','Y');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$sitetoinstrinfotab values ('$nsite','$instcat','$oinstclass','$ncinstcode',$nsitestart,$nsiteend,'N','Y','Y');\n";
								$sqlcount = $sqlcount + 1;
								$chkthissql = 1;
								$existinstcode = $existinstcode + 1;
							}
							if ($chkthissql == 0) {
								print "cannot insert into site_to_instr_info table - cannot find needed values from the instr_class_to_instr_cat table for $oinstclass!<br>\n";
							}
						}
						#check inst code in instr_code_details table - likely need an insert for new inst code
						$countcd=0;
						$sth_checkinstcodedetails = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrcodedetailstab WHERE instrument_code='$ncinstcode'");	
						if (!defined $sth_checkinstcodedetails) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkinstcodedetails->execute;
						while ($checkinstcodedetails = $sth_checkinstcodedetails->fetch) {
							$countcd = $checkinstcodedetails->[0];
						}
						if ($countcd == 0) { #not in instr_code_details table
							$chkthissql=0;
							$tabslist[$tabcount]="$instrcodedetailstab: $ncinstcode ($ncinstcodename)";
							$tabcount = $tabcount + 1;
							$sth_getcat = $dbh->prepare("SELECT instrument_class_code,instrument_category_code from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$oinstclass'");	
							if (!defined $sth_getcat) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_getcat->execute;
							while ($getcat = $sth_getcat->fetch) {
								$instcat=$getcat->[1];		
								#print "INSERT INTO arm_int2.$instrcodedetailstab values ('$ncinstcode','$ncinstcodename','Y','Y')<br>\n";
								$sql[$sqlcount]="INSERT INTO arm_int2.$instrcodedetailstab values ('$ncinstcode','$ncinstcodename','Y','Y');";
								#print ARMINT2 "INSERT INTO arm_int2_stage.$instrcodedetailstab values ('$ncinstcode','$ncinstcodename','Y','Y');\n";
								$sqlcount = $sqlcount + 1;
								$chkthissql=1;
								$existinstcode = $existinstcode + 1;
							}
						}
						if (($chkthissql == 0) && ($countcd == 0)) {
							print "cannot insert into instr_code_details tab because cannot find needed values in the instr_class_to_instr_cat tab for $oinstclass!<br>\n";
						}
						#check inst code in instr_code_to_instr_class table - likely need an insert for new inst code
						$countcd=0;
						$sth_checkinstrcodetoinstrclass = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrcodetoinstrclasstab WHERE instrument_code='$ncinstcode'");	
						if (!defined $sth_checkinstrcodetoinstrclass) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkinstrcodetoinstrclass->execute;
						while ($checkinstrcodetoinstrclass = $sth_checkinstrcodetoinstrclass->fetch) {
							$countcd = $checkinstrcodetoinstrclass->[0];
						}
						if ($countcd == 0) {
							$tabslist[$tabcount]="$instrcodetoinstrclasstab: $ncinstcode ($ncinstcodename) - class $oinstclass";
							$tabcount = $tabcount + 1;
							#print "INSERT INTO arm_int2.$instrcodetoinstrclasstab values ('$ncinstcode','$oinstclass')<br>\n";
							$sql[$sqlcount]="INSERT INTO arm_int2.$instrcodetoinstrclasstab values ('$ncinstcode','$oinstclass');";
							#print ARMINT2 "INSERT INTO arm_int2_stage.$instrcodetoinstrclasstab values ('$ncinstcode','$oinstclass');\n";
							$sqlcount = $sqlcount + 1;
							$existinstcode= $existinstcode + 1;	
						}
					}
				}
			}
			#print "existinstcode $existinstcode, tabcount $tabcount<br>\n";
			if (($existinstcode == 0) && ($tabcount > 0)) {
				print "CANNOT FORMULATE SQL FOR SITE_TO_INSTR_INFO, INSTR_CODE_DETAILS or INSTR_CODE_TO_INSTR_CLASS TABLE<br>MISSING SOME KEY PIECES FROM SOURCE SELECTION.<BR>THIS CLONE WILL NEED ATTENTION<br>\n";
			}
			$instclass="";
			$sourceclass="";
			$nsourceclass="";
			$instcode="";
			$ninstcode="";
			$datalevel="";
			$ndatalevel="";
			$sth_geticdl = $dbh->prepare("SELECT distinct IDNo,instrument_code,data_level,ninstrument_code,lower(nsite),nfacility_code,lower(osite),ofacility_code,ndata_level from clone where IDNo=$idn");	
			if (!defined $sth_geticdl) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_geticdl->execute;
			while ($geticdl = $sth_geticdl->fetch) {
				$instcode ="'"."$geticdl->[1]"."'";
				$datalevel="'"."$geticdl->[2]"."'";	
				if ($geticdl->[3] ne "") {
					$ninstcode="'"."$geticdl->[3]"."'";
					if ($geticdl->[8] ne "") {
						$ndatalevel="'"."$geticdl->[8]"."'";
						$nds = "$geticdl->[4]"."$geticdl->[3]"."$geticdl->[5]"."\."."$geticdl->[8]";
					} else {
						$ndatalevel="NULL";
						$nds = "$geticdl->[4]"."$geticdl->[3]"."$geticdl->[5]"."\."."$geticdl->[2]";
					}
				} else {
					$ninstcode="NULL";
					if ($geticdl->[8] ne "") {
						$ndatalevel="'"."$geticdl->[8]"."'";
						$nds = "$geticdl->[4]"."$geticdl->[1]"."$geticdl->[5]"."\."."$geticdl->[8]";
					} else {
						$ndatalevel="NULL";
						$nds = "$geticdl->[4]"."$geticdl->[1]"."$geticdl->[5]"."\."."$geticdl->[2]";
					}	
				}
				$ods = "$geticdl->[6]"."$geticdl->[1]"."$geticdl->[7]"."\."."$geticdl->[2]";
				$sth_getndsvars = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$dsvarnameinfotab where datastream='$nds'");	
				if (!defined $sth_getndsvars) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getndsvars->execute;
				while ($getndsvars = $sth_getndsvars->fetch) {
					$OK=$getndsvars->[0];
				}
				if ($OK > 0) {
					$OK=1;		
				} else { 
					$OK=0; # new datastream not in datastream_var_name_info table
					$countoldindsvar=0;
					$oldindsvar=0;
					$sth_getodsvars = $dbh->prepare("SELECT var_name,primary_meas_type_code,primary_measurement,start_date,end_date,upd_start_date,upd_end_date,visible,data_available from $archivedb.$dsvarnameinfotab where datastream='$ods'");	
					if (!defined $sth_getodsvars) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getodsvars->execute;
					while ($getodsvars = $sth_getodsvars->fetch) {
						$pm="";
						if ($getodsvars->[2] eq "") {
							$pm="NULL";
						} else {
							$temp="";
							$_=$getodsvars->[2];
							s/'/''/g;
							$temp=$_;
							$pm="'"."$temp"."'";
						}
						$upstart="";
						if ($getodsvars->[5] eq "") {
							$upstart="NULL";
						} else {
							$upstart="'"."$getodsvars->[5]"."'";
						}
						$upend="";
						if ($getodsvars->[6] eq "") {
							$upend="NULL";
						} else {
							$upend="'"."$getodsvars->[6]"."'";
						}
						$visible="";
						if ($getodsvars->[7] eq "") {
							$visible="NULL";
						} else {
							$visible="'"."$getodsvars->[7]"."'";
						}
						$dataavail="";
						if ($getodsvars->[8] eq "") {
							$dataavail="NULL";
						} else {
							$dataavail="'"."$getodsvars->[8]"."'";
						}
						#print "INSERT INTO arm_int2_stage.$dsvarnameinfotab values('$nds','$getodsvars->[0]','$getodsvars->[1]',$pm,$nsitestart,$nsiteend,$upstart,$upend,$visible,$dataavail);\n";
						$sql[$sqlcount]="INSERT INTO arm_int2.$dsvarnameinfotab values('$nds','$getodsvars->[0]','$getodsvars->[1]',$pm,$nsitestart,$nsiteend,$upstart,$upend,$visible,$dataavail);";
						#print ARMINT2 "INSERT INTO arm_int2_stage.$dsvarnameinfotab values('$nds','$getodsvars->[0]','$getodsvars->[1]',$pm,$nsitestart,$nsiteend,$upstart,$upend,$visible,$dataavail);\n";
						$sqlcount = $sqlcount + 1;
						$countoldindsvar=$countoldindsvar + 1;
						$oldindsvar = $oldindsvar + 1;
					}
					if ($oldindsvar > 0) {
						$tabslist[$tabcount]="$dsvarnameinfotab: $nds";
						$tabcount = $tabcount + 1;
					}
				}
				$sth_getinstclass = $dbh->prepare("SELECT distinct instrument_class,instrument_class from $archivedb.datastream_instrument_class where datastream='$ods'");	
				if (!defined $sth_getinstclass) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getinstclass->execute;
				while ($getinstclass = $sth_getinstclass->fetch) {
					$instclass=$getinstclass->[0];
					if ($ninstcode eq "NULL") {
						$ninstcode=$instcode;
					}
					if ($ndatalevel eq "NULL") {
						$ndatalevel=$datalevel;
					}
					$nsourceclass="";
					$sourceclass="";
					$sth_getsource = $dbh->prepare("SELECT source_class,source_class from $archivedb.datastream_instrument_class where datastream='$ods' and facility_code='$ofaccode' and site='$osite' and data_level=$datalevel and instrument_class='$instclass'");	
					if (!defined $sth_getsource) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getsource->execute;
					while ($getsource = $sth_getsource->fetch) {
						$sourceclass="'"."$getsource->[0]"."'";
						if (($getsource->[0] =~ "armderiv") || ($getsource->[0] =~ "extderiv") || ($getsource->[0] =~ "extobs") || ($getsource->[0] =~ "armobs")) {
							if ($getsource->[0] =~ "armderiv") {
								$nsourceclass="'"."VAP"."'";
							}
							if ($getsource->[0] =~ "extderiv") {
								$nsourceclass="'"."external"."'";
							}
							if ($sourceclass =~ "extobs") {
								$nsourceclass="'"."external"."'";
							}
							if ($sourceclass =~ "armobs") {
								$nsourceclass="'"."instrument"."'";
							}
						} else {
							$nsourceclass=$sourceclass;
						}
					}
					if ($sourceclass ne "") {
						if ($nsourceclass eq "") {
							if (($sourceclass =~ "armderiv") || ($sourceclass =~ "extderiv") || ($sourceclass =~ "extobs") || ($sourceclass =~ "armobs")) {
								if ($sourceclass =~ "armderiv") {
									$nsourceclass="'"."VAP"."'";
								}
								if ($sourceclass =~ "extderiv") {
									$nsourceclass="'"."external"."'";
								}
								if ($sourceclass =~ "extobs") {
									$nsourceclass="'"."external"."'";
								}
								if ($sourceclass =~ "armobs") {
									$nsourceclass="'"."instrument"."'";
								}
							}
						}
						if ($nsourceclass eq "") {
							$sth_getdsinstclass = $dbh->prepare("SELECT count(*),count(*) from $archivedb.datastream_instrument_class where site='$nsite' and datastream='$nds' and instrument_class='$instclass' and facility_code='$nfaccode' and data_level=$ndatalevel and (source_class=$sourceclass or source_class is NULL)");	
						} else {
							$sth_getdsinstclass = $dbh->prepare("SELECT count(*),count(*) from $archivedb.datastream_instrument_class where site='$nsite' and datastream='$nds' and instrument_class='$instclass' and facility_code='$nfaccode' and data_level=$ndatalevel and (source_class=$sourceclass or source_class=$nsourceclass)");	
						}
						if (!defined $sth_getdsinstclass) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getdsinstclass->execute;
						while ($getdsinstclass = $sth_getdsinstclass->fetch) {
							$OK=$getdsinstclass->[0];
						}
						if ($OK > 0) {
							$OK=1;		
						} else { 
							$OK=0;	# new datastream not in datastream_instrument_class table
							$tabslist[$tabcount]="datastream_instrument_class: $nds";
							$tabcount = $tabcount + 1;
							
							$sth_getdsinstclass = $dbh->prepare("SELECT min_date,max_date from $archivedb.datastream_instrument_class where site='$osite' and datastream='$ods' and instrument_class='$instclass' and facility_code='$ofaccode' and data_level=$datalevel and (source_class=$sourceclass or source_class=$nsourceclass)");	
							if (!defined $sth_getdsinstclass) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_getdsinstclass->execute;
							while ($getdsinstclass = $sth_getdsinstclass->fetch) {
								#print "INSERT INTO arm_int2.datastream_instrument_class values('$nsite','$nds','$instclass','$nfaccode',$ndatalevel,$nsourceclass,$nsitestart,$nsiteend);\n";
								$sql[$sqlcount]="INSERT INTO arm_int2.datastream_instrument_class values('$nsite','$nds','$instclass','$nfaccode',$ndatalevel,$nsourceclass,$nsitestart,$nsiteend);";
								#print ARMINT2 "INSERT INTO arm_int2_stage.datastream_instrument_class values('$nsite','$nds','$instclass','$nfaccode',$ndatalevel,$nsourceclass,$nsitestart,$nsiteend);\n";
								$sqlcount = $sqlcount + 1;
							}
							
						}
					}
				}
				$sth_getnmeasdesc = $dbh->prepare("SELECT count(*),count(*) from $archivedb.measurement_description where datastream='$nds'");	
				if (!defined $sth_getnmeasdesc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getnmeasdesc->execute;
				while ($getnmeasdesc = $sth_getnmeasdesc->fetch) {
					$OK = $getnmeasdesc->[0];
				}
				#print "$nds $OK<br>\n";
				if ($OK > 0) {
					$OK=1;		
				} else { 
					$OK=0; #new datastream not in measurement_description
					$tabslist[$tabcount]="measurement_description: $nds";
					$tabcount = $tabcount + 1;
					$now=&getnow;
					$sourceexist = 0;
					#print "SELECT var_name,header_long_name,measurement,units,eff_date,end_date,GFA_codes,iop,sci_rel,custodian,added_date,meas_supplier from $archivedb.measurement_description where datastream='$ods'<br>\n";
					$sth_getomeasdesc = $dbh->prepare("SELECT var_name,header_long_name,measurement,units,eff_date,end_date,GFA_codes,iop,sci_rel,custodian,added_date,meas_supplier from $archivedb.measurement_description where datastream='$ods'");	
					if (!defined $sth_getomeasdesc) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getomeasdesc->execute;
					while ($getomeasdesc = $sth_getomeasdesc->fetch) {
						if ($getomeasdesc->[0] eq "") {
							$varname="NULL";
						} else {
							$varname="'"."$getomeasdesc->[0]"."'";
						}
						$temp="";
						$_=$getomeasdesc->[1];
						s/'/''/g;
						$temp=$_;
						if ($getomeasdesc->[1] eq "") {
							$hlname="NULL";
						} else {
							$hlname="'"."$temp"."'";
						}
						$temp="";
						$_=$getomeasdesc->[2];
						s/'/''/g;
						$temp=$_;
						if ($getomeasdesc->[2] eq "") {
							$meas="NULL";
						} else {
							$meas="'"."$temp"."'";
						}
						if ($getomeasdesc->[3] eq "") {
							$units="NULL";
						} else {
							$units="'"."$getomeasdesc->[3]"."'";
						}
						if (($getomeasdesc->[6] eq "") || ($getomeasdesc->[6] eq " ")) {
							$GFA_codes="NULL";
						} else {
							$GFA_codes="'"."$getomeasdesc->[6]"."'";
						}
						if (($getomeasdesc->[7] eq "") || ($getomeasdesc->[7] eq " ")) {
							$iop="NULL";
						} else {
							$iop="'"."$getomeasdesc->[7]"."'";
						}
						if ($getomeasdesc->[8] eq "") {
							$scirel="NULL";
						} else {
							$scirel="'"."$getomeasdesc->[8]"."'";
						}
						if ($getomeasdesc->[9] eq "") {
							$custodian="NULL";
						} else {
							$custodian="'"."$getomeasdesc->[9]"."'";
						}
						if (($getomeasdesc->[11] eq "") || ($getomeasdesc->[11] eq "null")) {
							$meassup="NULL";
						} else {
							$meassup="'"."$getomeasdesc->[11]"."'";
						}
						@splitdod=();
						if ($custodian =~ "dod-v") {
							@splitdod=split(/v/,$custodian);
						}
						$temps="";
						$temps=$geticdl->[6];
						$tempf="";
						$tempf=$geticdl->[7];
						$tempd="";
						if ($splitdod[1] ne "") {
							$custodian="'"."$temps"."$tempf"."v$splitdod[1]";
						} else {
							$custodian="'"."$temps"."$tempf"."'";
						}
						#print "INSERT INTO arm_int2.measurement_description values($varname,$hlname,$meas,$units,'$nds',$nsitestart,$nsiteend,$GFA_codes,$iop,$scirel,$custodian,'$now',$meassup);";
						$sql[$sqlcount]="INSERT INTO arm_int2.measurement_description values($varname,$hlname,$meas,$units,'$nds',$nsitestart,$nsiteend,$GFA_codes,$iop,$scirel,$custodian,'$now',$meassup);";
						#print ARMINT2 "INSERT INTO arm_int2_stage.measurement_description values($varname,$hlname,$meas,$units,'$nds',$nsitestart,$nsiteend,$GFA_codes,$iop,$scirel,$custodian,'$now',$meassup);\n";
						$sqlcount = $sqlcount + 1;
						$sourceexist = $sourceexist + 1;
					}
					
					#print "source exist $sourceexist, tabcount $tabcount<br>\n";
					if ($sourceexist == 0)  {
						print "THERE ARE NO MEASUREMENT_DESCRIPTION ENTRIES FOR THE CLONE SOURCE! $ods<br>\n";
						print "UNABLE TO DEVELOP SQL FOR MEASURMENT_DESCRIPTION INSERTS for $nds!<br>\n";
						print "THIS CLONE SUBMISSION WILL NEED ATTENTION!<p>\n";
					}
					
				
				$sourceexist = 0;		
					
				}	
			}
			
			if (($sqlcount == 0) && ($tabcount == 0)){
				$doublecheckstatarray=2;
				print "<br>NO Archive DB ENTRY required($idn): metadata up-to-date!<br>\n";	
				print "Status of this clone request (MMT# $idn) will be set to Completed<p>\n";
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");	
				$doStatus = $dbh->do("UPDATE clone set statusFlag=2 where IDNo=$idn");	
			} else {
				$doublecheckstatarray=0;
				$doStatus = $dbh->do("UPDATE clone set statusFlag=0 where IDNo=$idn");
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=0 where IDNo=$idn");
				print "<br>Archive DB ENTRY required ($idn)<br>\n";
				if ($sqlcount > 0) {
					print "Implementation request sent to archive<p>\n";
				}	
			}
			@sortedtabslist=();
			@sortedtabslist = sort @tabslist;
			$oldt="";
			$counttab=0;
			foreach $t (@sortedtabslist) {
				if ($t ne $oldt) {
					if ($counttab == 0) {
						print "ADDITIONS NEEDED IN THE FOLLOWING ARCHIVE TABLE(s):<p><dd>$t<br>";
					} else {
						print "$t<br>";
					}
					$counttab = $counttab + 1;
				}
				
			}
			print "</dd><br>\n";
			$idx = $idx + 1;			
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
			#if ($countarray > 1) {
			#	close(ARMINT2);
			#}					
		}
		# if there are sql commands ready, send notification to archive and submitter
		#print "emchk $emchk, sqlcount $sqlcount<br>\n";
		if ($emchk eq "") {
			if ($sqlcount > 0) {
				@sortedlist=();
				@sortedlist=sort @sql;
				$oldsq="";
				$countsend=0;
				@sendto=();
				$subm="";
				$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL'");	
				if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdist->execute;
				while ($getdist = $sth_getdist->fetch) {
					$sendto[$countsend]=$getdist->[0];
					$countsend = $countsend + 1;
				}
				if ($idx == 1) {
					foreach $idn (@idarray) {
						$sth_getsub = $dbh->prepare("SELECT distinct submitter,submitter from clone where IDNo=$idn");	
						if (!defined $sth_getsub) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getsub->execute;
						while ($getsub = $sth_getsub->fetch) {
							$sendto[$countsend]=$getsub->[0];
							$subm=$getsub->[0];
						}
					}
				}
				@sortedsendto=();
				@sortedsendto=sort @sendto;
				$ost="";
				foreach $st (@sortedsendto) {
					if ($ost ne $st) {
						$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$st");	
						if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getemail->execute;
						while ($getemail = $sth_getemail->fetch) {
							if ($idx == 1) {
								open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Clone submission ready for implementation- MMT# @idarray\" \"$getemail->[1]\"");	
							} else {
								open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Batch - Clone submissions ready for implementation\" \"$getemail->[1]\"");
							}
							print MAIL "Clone request for implementation in archive metadata databases (new request or additional table inserts).\n";
							print MAIL "--------------------------------------------\n";
							if ($st ne $subm) {
								print MAIL "SQL commands for entire clone follow for your convenience:\n\n";
								$oldsq="";
								foreach $sq (@sortedlist) {
									if ($oldsq ne $sq) {
										print MAIL "$sq\n";
									}
									$oldsq=$sq;
								}
							} else {
								$thiscounts=0;
								$sth_checkifimpl = $dbh->prepare("SELECT count(*),count(*) from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL' and reviewers.person_id=$st");	
								if (!defined $sth_checkifimpl) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checkifimpl->execute;
								while ($checkifimpl = $sth_checkifimpl->fetch) {
									$thiscounts=$checkifimpl->[0];
								}
								if ($thiscounts > 0) {
									print MAIL "SQL commands for entire clone follow for your convenience:\n\n";
									$oldsq="";
									foreach $sq (@sortedlist) {
										if ($oldsq ne $sq) {
											print MAIL "$sq\n";
										}
										$oldsq=$sq;
									}
								}
							}
							if ($idx == 1) {
								foreach $idn (@idarray) {
									print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
								}
							} else {
								print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=CI";
							}
							close(MAIL);
						}
					}
					$ost=$st;
					
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}
	}

#########################	
	if ($objct eq "DOD") {
		print "The synchronize script will check the DSDB at the DMF, to see whether approved DODs have been installed into production<br>\n";
		print "If so, the status for the task of DMF Installing into production will be set to implemented, the Archive will be sent a notice<br>\n";
		print "and the overall status for this DOD review will be set to Approved/Complete<br>\n";
		print "This does not work for XDC installed DODs, (or those being run at other facilities?). XDC will manually set status to implemented for XDC via MMT status change<p>\n";
		$countstat = 0;
		$countdod = 0;
		foreach $idn (@idarray) {
			$class="";
			$level="";
			$version="";
			$status=1;
			$sth_getdod = $dbh->prepare("SELECT distinct dsBase,dataLevel,DODversion from DOD where IDNo=$idn");
			if (!defined $sth_getdod) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getdod->execute;
			while ($getdod = $sth_getdod->fetch) {
				$class=$getdod->[0];
				$level=$getdod->[1];
				$version=$getdod->[2];
				$countlist=0;
				#print "https://engineering.arm.gov/pcm/cgi-bin/procdb?action=dod-get&class=$class&level=$level&version=$version&prod=1<br>\n";
				my $www = new LWP::UserAgent;
				my $req = new HTTP::Request( GET=> "https://engineering.arm.gov/pcm/cgi-bin/procdb?action=dod-get&class=$class&level=$level&version=$version&prod=1");
				$req->content_type('application/x-www-form-urlencoded');
				$status=1;
				my $response = $www->request($req);
				eval {
  					my $decoded_ref = JSON::XS::decode_json($response->content);
					1;
				} or do {
					$status=0;
					1;
				};
				if ($status == 1) {
					$countdod = $countdod + 1;
					$now=&getnow;
					$countrevstat=0;
					$sth_checkoverallstat = $dbh->prepare("SELECT revStatus,DBstatus from IDs where IDNo=$idn");
					if (!defined $sth_checkoverallstat) { die "Cannot  statement: $DBI::errstr\n"; }
					$oarstat=0;
					$oadbstat=0;
					$sth_checkoverallstat->execute;
					while ($checkoverallstat = $sth_checkoverallstat->fetch) {
						$oarstat=$checkoverallstat->[0];
						$oadbstat=$checkoverallstat->[1];
					}
					if (($oarstat != 2) || ($oadbstat !=2)) {
						$sth_getimplid=$dbh->prepare("SELECT distinct reviewers.person_id,reviewers.person_id FROM reviewers WHERE type='DOD' and revFunction='IMPL-PROD'");
						if (!defined $sth_getimplid) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_getimplid->execute;
						while ($getimplid = $sth_getimplid->fetch) {
							$success=0;
							$checkstat="";
							$rev_id=$getimplid->[0];
							$countrevstat = $countrevstat + 1;
							$doStatus = $dbh->do("INSERT INTO reviewerStatus values ($idn,$rev_id,2,'$now')");
							if ( ! defined $doStatus ) {
								print "An error has occurred during entry of reviewr status.<br>\n";
								print "</BODY></HTML>\n";
								$dbh->disconnect();
								exit;
							}
							$sth_checks=$dbh->prepare("SELECT status,status from reviewerStatus where IDNo=$idn and person_id=$rev_id and status=2 and statusDate='$now'");
							if (!defined $sth_checks) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_checks->execute;
							while ($checks = $sth_checks->fetch) {
								$checkstat = $checks->[0];
							}
							if ($checkstat == 2) {
								$success=$success + 1;;
							}
						}
						$doStatus = $dbh->do("UPDATE IDs set revStatus=2,DBstatus=2 WHERE IDNo=$idn");
						if ( ! defined $doStatus ) {
							print "An error has occurred during overall update of status.<br>\n";
							print "</BODY></HTML>\n";
							$dbh->disconnect();
							exit;
						}
						if ($countrevstat = $success) {
							# this section will send notification to archive that this has been implemented!
							# NO LONGER SENDING NOTICE TO ARCHIVE - THEY DO NOT DO ANYTHING WITH RESPECT TO METADATA UPDATES
							# WHEN A DOD IS APPROVED.  THEY WAIT FOR MMT PUSH
							#print "Archive notification will be sent for MMT# $idn: DOD $class\.$level V$version<br>\n";
							#@em=();
							#$countem=0;
							#$sth_getarchiveimpl = $dbh->prepare("SELECT distinct reviewers.person_id,reviewers.person_id FROM reviewers where revFunction='IMPL' order by person_id");
							#if (!defined $sth_getarchiveimpl) { die "Cannot  statement: $DBI::errstr\n"; }
							#$sth_getarchiveimpl->execute;
							#while ($getarchiveimpl = $sth_getarchiveimpl->fetch) {
							#	$em[$countem]=$getarchiveimpl->[0];
							#	$countem = $countem + 1;
							#}
							#foreach $e (@em) {
							#	$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$e");
							#	if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
							#	$sth_getemail->execute;
							#	while ($getemail = $sth_getemail->fetch) {
							#		open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: DOD Installed into Production at DMF/XDC- MMT# $idn\" \"$getemail->[1]\"");	#
							#		print MAIL "DOD $class\.$level Ver $version (MMT# $idn) has been installed into production at the DMF or the XDC.\n";
							#		print MAIL "--------------------------------------------\n";
							#		print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
							#		close(MAIL);
							#	}
							#}
						}
					} 	
				}
			}
		}
	}	
###################################
	if ($objct eq "DS") {
		$sqlcount=0;
		@sql=();
		$idx=0;
		$sqlcount=0;
		$countarray=0;
		$countarray=@idarray;
		#if ($countarray > 1) {
		#	$armintupdatesfile="/home/www/DB/data/MMT/batch.updates.$tnow";
		#	open(ARMINT2, "> $armintupdatesfile");
		#}
		foreach $idn (@idarray) {
		
			#if ($countarray == 1) {
			#	$armintupdatesfile="/home/www/DB/data/MMT/$idn.updates.$tnow";
			#	open(ARMINT2, "> $armintupdatesfile");
			#}
			$checkforrawds=0;
			$idstatcheck=0;
			$firstone=0;
			$sth_getpms=$dbh->prepare("SELECT distinct primary_meas_code,primary_meas_code from primMeas where IDNo=$idn order by primary_meas_code");
			if (!defined $sth_getpms) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getpms->execute;
			while ($getpms = $sth_getpms->fetch) {
				$checkforraw = $checkforraw + 1;
				$fincheck=0;
				$curpm=$getpms->[0];
				$curic="";
				$countinst=0;
				$sth_getcurinstclass=$dbh->prepare("SELECT distinct instrument_class from instClass where IDNo=$idn order by instrument_class");
				if (!defined $sth_getcurinstclass) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getcurinstclass->execute;
				while ($getcurinstclass = $sth_getcurinstclass->fetch) {
					$curic=$getcurinstclass->[0];
					$countinst = $countinst + 1;
					$sth_countpm=$dbh->prepare("SELECT count(*) from $archivedb.$pmcodetoinstrclass WHERE primary_meas_type_code='$curpm' and instrument_class_code='$curic'");
					if (!defined $sth_countpm) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_countpm->execute;
					while ($countpm = $sth_countpm->fetch) {
						if ($countpm->[0] > 0) {
							# this one matches - no new associations
							$doStatus = $dbh->do("UPDATE primMeas set statusFlag=1 where IDNo=$idn");
							$doStatus = $dbh->do("UPDATE instClass set statusFlag=1 where IDNo=$idn");
							$fincheck = $fincheck + 1;
						} else {
							#INSERT NEEDED
							$sql[$sqlcount]="INSERT INTO arm_int2.$pmcodetoinstrclass values('$curpm','$curic');";
							#print ARMINT2 "INSERT INTO arm_int2_stage.$pmcodetoinstrclass values('$curpm','$curic');\n";
							$sqlcount = $sqlcount + 1;
						}
					}		
				}
			}
			$cursc="";
			$countsource=0;
			$curic="";
			$sth_getcurinstclass=$dbh->prepare("SELECT distinct instrument_class from instClass where IDNo=$idn order by instrument_class");
			if (!defined $sth_getcurinstclass) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcurinstclass->execute;
			while ($getcurinstclass = $sth_getcurinstclass->fetch) {
				$curic=$getcurinstclass->[0];
			}
			$sth_getcursourceclass = $dbh->prepare("SELECT distinct source_class from sourceClass where IDNo=$idn order by source_class");
			if (!defined $sth_getcursourceclass) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getcursourceclass->execute;
			while ($getcursourceclass = $sth_getcursourceclass->fetch) {
				$countsource = $countsource + 1;
				$cursc=$getcursourceclass->[0];
				$sth_countsc=$dbh->prepare("SELECT count(*) from $archivedb.$instrclasstosourceclass WHERE instrument_class_code='$curic' and source_class_code='$cursc'");
				if (!defined $sth_countsc) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countsc->execute;
				while ($countsc = $sth_countsc->fetch) {
					if ($countsc->[0] > 0) {
						# this one matches - no new associations
						$fincheck = $fincheck + 1;
					} else {
						#INSERT/UPDATE NEEDED
						$sql[$sqlcount]="INSERT INTO arm_int2.$instrclasstosourceclass values('$curic','$cursc');";
						#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclasstosourceclass values('$curic','$cursc');\n";
						$sqlcount = $sqlcount + 1;
					}
				}
				
			}
			$compare=$countinst + $countsource;
			if ($fincheck != $compare) {
				$idstatcheck = $idstatcheck + 1;
			}
			# check inst category code for this inst class
			$sth_getinstcats = $dbh->prepare("SELECT distinct inst_category_code from instCats,instClass where instCats.IDNo=$idn and instCats.IDNo=instClass.IDNo and instrument_class='$curic'");
			if (!defined $sth_getinstcats) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getinstcats->execute;
			while ($getinstcats = $sth_getinstcats->fetch) {
				$sth_checkarchive = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab WHERE instrument_category_code='$getinstcats->[0]' and instrument_class_code='$curic'");
				if (!defined $sth_checkarchive) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkarchive->execute;
				while ($checkarchive = $sth_checkarchive->fetch) {
					if ($checkarchive->[0] > 0) {
						#this one matches - no new associations
					} else {
						#INSERT/UPDATE NEEDED?
						$sql[$sqlcount]="INSERT INTO arm_int2.$instrclasstoinstrcattab values ('$curic','$getinstcats->[0]');";
						#print ARMINT2 "INSERT INTO arm_int2_stage.$instrclasstoinstrcattab values ('$curic','$getinstcats->[0]');\n";
						$sqlcount = $sqlcount + 1;
						$idstatcheck = $idstatcheck + 1;
					} 
				}
			}
			#######################
			#### FUTURE ENHANCEMENT HERE - REMOVE OLD INSTRUMENT CATEGORIES FOR THIS INSTRUMENT CLASS IF THERE 
			#### ARE OLD/OUTDATED INSTRUMENT CATEGORY CODES LISTED IN ARM_INT2 FOR THIS CLASS
			#### IS INSTRUMENT_CLASS_CODE TO INSTRUMENT_CATEGORY_CODE ONE TO ONE?????  CAN ONLY DO THE DELETE OF 
			#### THAT ASSUMPTION IS CORRECT
			#######################
			
			
			####  check if this instrument class is related to the instrument code
			####  first determine the instrument_code for each datastream
			####  then check the instr_code_to_instr_class table to see if there is an entry.  
			####  if not, add it			
			$dsinstcode="";
			$dsdatalevel="";
			$sth_getinstcode=$dbh->prepare("SELECT dsBase,dataLevel from DS where IDNo=$idn");
			if (!defined $sth_getinstcode) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getinstcode->execute;
			while ($getinstcode = $sth_getinstcode->fetch) {
				$dsinstcode=$getinstcode->[0];
				$dsdatalevel=$getinstcode->[1];
			}
			################
			####FUTURE ENHANCEMENT - need to REMOVE erroneous instrument class to instrument_code 
			####associations from the instrcodetoinstrclass 
			####table prior to insert of newinstrcodetoinstrclass!!!!!
			####(not sure how to accomplish that - see above question)
			###############
			
					
			$sth_geticla=$dbh->prepare("SELECT distinct instrument_class from instClass where IDNo=$idn");
			if (!defined $sth_geticla) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_geticla->execute;
			while ($geticla = $sth_geticla->fetch) {
				$chekem=0;
				$sth_checkarchiveicotoicl=$dbh->prepare("SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where instrument_class_code='$geticla->[0]' and instrument_code='$dsinstcode'");
				if (!defined $sth_checkarchiveicotoicl) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_checkarchiveicotoicl->execute;
				while ($checkarchiveicotoicl = $sth_checkarchiveicotoicl->fetch) {
					$chekem=$checkarchiveicotoicl->[0];
				}
				if ($chekem > 0) {
					#this one matches - no new associations
				} else {
					#INSERT/UPDATE NEEDED?
					# check to see if this instrument_code is already associated with a different instrument class, if so, do an update
					$sth_countarchiveicotoicl=$dbh->prepare("SELECT count(*) from $archivedb.$instrcodetoinstrclasstab where instrument_code='$dsinstcode'");
					if (!defined $sth_countarchiveicotoicl) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_countarchiveicotoicl->execute;
					while ($countarchiveicotoicl = $sth_countarchiveicotoicl->fetch) {
						if ($countarchiveicotoicl->[0] == 0) {
							#DO INSERT
							$sql[$sqlcount]="INSERT INTO arm_int2.$instrcodetoinstrclasstab values ('$dsinstcode','$geticla->[0]');";
							#print ARMINT2 "INSERT INTO arm_int2_stage.$instrcodetoinstrclasstab values ('$dsinstcode','$geticla->[0]');\n";
							$sqlcount = $sqlcount = $sqlcount + 1;
						} else {
							#DO UPDATE
							$sql[$sqlcount]="UPDATE arm_int2.$instrcodetoinstrclasstab set instrument_class_code='$geticla->[0]' WHERE instrument_code='$dsinstcode';";
							#print ARMINT2 "UPDATE arm_int2_stage.$instrcodetoinstrclasstab set instrument_class_code='$geticla->[0]' WHERE instrument_code='$dsinstcode';\n";
							$sqlcount = $sqlcount + 1;
							#DO UPDATE
							$sql[$sqlcount]="UPDATE arm_int2.$sitetoinstrinfotab set instrument_class_code='$geticla->[0]' WHERE instrument_code='$dsinstcode';";
							#print ARMINT2 "UPDATE arm_int2_stage.$sitetoinstrinfotab set instrument_class_code='$geticla->[0]' WHERE instrument_code='$dsinstcode';\n";
						}
						$sqlcount = $sqlcount + 1;
						$idstatcheck = $idstatcheck + 1;
					}
				} 	
			}
			### need to check instr_code details table here!
			$dsinstc="";
			$dscdesc="";
			$sth_getinstcode=$dbh->prepare("SELECT dsBase,dsBaseDesc from DS where IDNo=$idn");
			if (!defined $sth_getinstcode) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getinstcode->execute;
			while ($getinstcode = $sth_getinstcode->fetch) {
				$dsinstc=$getinstcode->[0];
				$dscdesc=$getinstcode->[1];
			}		
			$countcodedetails=0;
			$sth_countdscode=$dbh->prepare("SELECT count(*) from $archivedb.$instrcodedetailstab where instrument_code='$dsinstc' and instrument_name='$dscdesc'");
			if (!defined $sth_countdscode) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_countdscode->execute;
			while ($countdscode = $sth_countdscode->fetch) {
				$countcodedetails = $countdscode->[0];
			}
			if ($countcodedetails == 0) {
				# need to first check if perhaps just the instrument_name has changed
				$countdscn=0;
				$sth_countdscodename = $dbh->prepare("SELECT count(*) from $archivedb.$instrcodedetailstab where instrument_code='$dsinstc'");
				if (!defined $sth_countdscodename) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_countdscodename->execute;
				while ($countdscodename = $sth_countdscodename->fetch) {
					$countdscn=$countdscodename->[0];
				}
				if ($countdscn == 0) {
					# need to insert - no matches
					$sql[$sqlcount]="INSERT INTO arm_int2.$instrcodedetailstab values('$dsinstc','$dscdesc','Y','Y');";
					#print ARMINT2 "INSERT INTO arm_int2_stage.$instrcodedetailstab values('$dsinstc','$dscdesc','Y','Y');\n";
					$sqlcount = $sqlcount + 1;
					$idstatcheck = $idstatcheck + 1;
				} else {
					#need to update instrument name here; inst code exists
					$sql[$sqlcount]="UPDATE arm_int2.$instrcodedetailstab set instrument_name='$dscdesc' WHERE instrument_code='$dsinstc';";
					#print ARMINT2 "UPDATE arm_int2_stage.$instrcodedetailstab set instrument_name='$dscdesc' WHERE instrument_code='$dsinstc';\n";
					$sqlcount = $sqlcount + 1;
					$idstatchec = $idstatcheck + 1;	
				}		
			} 		
			$dodid="";
			$dodsite="";
			$dodfac="";
			$dodfacn="";
			$dodver="";
			$sth_getDS=$dbh->prepare("SELECT IDNo,DODversion from DS where IDNo=$idn");
			if (!defined $sth_getDS) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getDS->execute;
			while ($getDS = $sth_getDS->fetch) {
				$dodver=$getDS->[1];
			}
			$sth_getdodid=$dbh->prepare("SELECT DOD.IDNo from DOD,IDs where DOD.IDNo=IDs.IDNo and dsBase='$dsinstcode' and dataLevel='$dsdatalevel' and IDs.revStatus=2 and DOD.DODversion='$dodver'");
			if (!defined $sth_getdodid) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getdodid->execute;
			while ($getdodid = $sth_getdodid->fetch) {
				$dodid=$getdodid->[0];
			}
			#get site/facility from linked dod in order to create a full ds name
			if ($dodid ne "") {
				###### need to  check site to instr info table!  need: site, instrument_class_code, instrument_code, inst_category_code
				# get instrument class and instrument code for IDNo=$idn
				# get sites for IDNo=$dodid
				# get instrument_category codes for IDNo=$idn
				# for each site, for each inst category code, check site_to_instr_info for site/instclass/$dsinstcode/inst cat code
				# if not found, insert into site_to_instr_info
				$checkem=0;
				$sth_getsiteinfo=$dbh->prepare("SELECT distinct lower(site) from facilities where IDNo=$dodid");
				if (!defined $sth_getsiteinfo) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getsiteinfo->execute;
				while ($getsiteinfo = $sth_getsiteinfo->fetch) {
					$sth_getinstcatinfo=$dbh->prepare("SELECT distinct instrument_category_code from $archivedb.$instrclasstoinstrcattab where instrument_class_code='$curic'");
					if (!defined $sth_getinstcatinfo) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getinstcatinfo->execute;
					while ($getinstcatinfo = $sth_getinstcatinfo->fetch) {
						$sth_checkarchsitetoinstrinfo = $dbh->prepare("SELECT count(*) from $archivedb.$sitetoinstrinfotab where $archivedb.$sitetoinstrinfotab.site_code='$getsiteinfo->[0]' and $archivedb.$sitetoinstrinfotab.instrument_class_code='$curic' and $archivedb.$sitetoinstrinfotab.instrument_code='$dsinstcode' and $archivedb.$sitetoinstrinfotab.instrument_category_code='$getinstcatinfo->[0]'");
						if (!defined $sth_checkarchsitetoinstrinfo) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkarchsitetoinstrinfo->execute;
						$chekem=0;
						while ($checkarchsitetoinstrinfo = $sth_checkarchsitetoinstrinfo->fetch) {
							$chekem=$checkarchsitetoinstrinfo->[0];
						}
						if ($chekem == 0) {
							#INSERT
							###### get min(eff_date) and max(end_date) from arm_int2.facility_info table to use here!
							$seffdate="";
							$senddate="";
							$sth_getmoresiteinfo=$dbh->prepare("SELECT min(eff_date),max(end_date) from $archivedb.$facinfotab where lower(site_code)=lower('$getsiteinfo->[0]')");
							if (!defined $sth_getmoresiteinfo) { die "Cannot  statement: $DBI::errstr\n"; }
							$sth_getmoresiteinfo->execute;
							while ($getmoresiteinfo = $sth_getmoresiteinfo->fetch) {
							
								$seffdate=$getmoresiteinfo->[0];
								$senddate=$getmoresiteinfo->[1];
							}
							$sql[$sqlcount]="INSERT INTO arm_int2.$sitetoinstrinfotab values('$getsiteinfo->[0]','$getinstcatinfo->[0]','$curic','$dsinstcode','$seffdate','$senddate','N','Y','Y');";
							#print ARMINT2 "INSERT INTO arm_int2_stage.$sitetoinstrinfotab values('$getsiteinfo->[0]','$getinstcatinfo->[0]','$curic','$dsinstcode','$seffdate','$senddate','N','Y','Y');\n";
							$sqlcount = $sqlcount + 1;
							$idstatcheck = $idstatcheck + 1;
						}
					}
				}
				$countsiteindod=0;
				$sth_getsitefac=$dbh->prepare("SELECT distinct lower(site),facility_code,facility_name from facilities where IDNo=$dodid order by site,facility_code");
				if (!defined $sth_getsitefac) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getsitefac->execute;
				while ($getsitefac = $sth_getsitefac->fetch) {
					$countsiteindod=$countsiteindod + 1;
					$dodsite=$getsitefac->[0];
					$dodfac=$getsitefac->[1];
					$dodfacn=$getsitefac->[2];
					$fullds="$dodsite"."$dsinstcode"."$dodfac"."\."."$dsdatalevel";
					#print "fullds $fullds<br>\n";
					######## no updates will be formulated for datastream_info table as per harold email of 06/17/2015
					######## Archive no longer wants updates to datastream_info table
					#@getcursourceclass = $dbh->prepare("SELECT distinct source_class,source_class from sourceClass where IDNo=$idn order by source_class");
					#foreach $getcursourceclass (@getcursourceclass) {
					#	@checkardet = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$dsinfotab where $archivedb.$dsinfotab.instrument_code='$dsinstcode' and $archivedb.$dsinfotab.instrument_class_code='$curic' and $archivedb.$dsinfotab.data_level_code='$dsdatalevel' and site_code='$dodsite' and facility_code='$dodfac' and source_class_code='$getcursourceclass->[0]' and datastream='$fullds'");
					#	
					#	foreach $checkardet (@checkardet) {
					#		if ($checkardet->[0] == 0) {
					#			# INSERT/UPDATE NEEDED
					#			$sql[$sqlcount]="INSERT INTO arm_int2.datastream_info values('$fullds','$dodfac','$dodsite','19900101','30010101','$dsinstcode','$getcursourceclass->[0]','$dsdatalevel','Y','Y','$curic','N');";
					#			$idstatcheck = $idstatcheck + 1;
					#		}
					#	}
					#}
					
					
					
					
					########################
					# determine if need to enter a record in new eval datastream table
					$addevaltab=0;
					$delevaltab=0;
					$sth_getdodevalnote = $dbh->prepare("SELECT iseval from DOD where IDNo=$dodid");
					#print "in here<br>\n";
					if (!defined $sth_getcursourceclass) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getdodevalnote->execute;
					while ($getdodevalnote = $sth_getdodevalnote->fetch) {
						if ($getdodevalnote->[0] =~ "Y") {
							$addevaltab=1;
						} elsif ($getdodevalnote->[0] =~ "N") {
							$delevaltab=1;
						}
					}
					#print "addevtab $addevtab<br>\n";
					if ($addevaltab != 0) {		
						$sth_checkevaltab = $dbh->prepare("SELECT count(*) from $archivedb.eval_datastreams where $archivedb.eval_datastreams.source_class_code like '%eval%' and datastream='$fullds'");
						if (!defined $sth_checkevaltab) { die "Cannot statement: $DBI::errstr\n"; }
						$sth_checkevaltab->execute;
						while ($checkevaltab = $sth_checkevaltab->fetch) {
							if ($checkevaltab->[0] == 0) {
								# INSERT NEEDED for this ds for an eval product - need to determine
								# the appropriate Source Class though!! evalderiv, evalobs??
								# get all eval type Source Classes from DS record
								# then for each of these eval sources, add a record in new table
								$sth_getevalsc = $dbh->prepare("SELECT distinct source_class from sourceclass where IDNo=$idn");
								if (!defined $sth_getevalsc) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getevalsc->execute;
								$evalins="";
								while ($getevalsc = $sth_getevalsc->fetch) {
									$evalins=$getevalsc->[0];
									if ($evalins =~ 'eval') {
										$sql[$sqlcount]="INSERT INTO arm_int2.eval_datastreams values('$fullds','$evalins');";
										#print ARMINT2 "INSERT INTO arm_int2_stage.eval_datastreams values('$fullds','$evalins');\n";
										$sqlcount = $sqlcount + 1;
										$idstatcheck = $idstatcheck + 1;
									}
								}
							}
						}
					}
					#########################
					###### if this is a prod DOD submission, make sure to remove from eval_datastreams if it exists
					###### look at all entries for this datastream in eval_datastreams
					###### and remove any that indicate a type of eval Source Class for this ds
					#########################
					if ($delevaltab != 0) {
						$sth_checkevaltab = $dbh->prepare("SELECT count(*) from $archivedb.eval_datastreams where $archivedb.eval_datastreams.source_class_code like '%eval%' and datastream='$fullds'");
						if (!defined $sth_checkevaltab) { die "Cannot statement: $DBI::errstr\n"; }
						$sth_checkevaltab->execute;
						while ($checkevaltab = $sth_checkevaltab->fetch) {
							if ($checkevaltab->[0] > 0) {
								# DELETE NEEDED for this ds to indicate its now production
								# for each of  eval source in eval_datastreams, delete it for this datastream
								$sth_getevalsc = $dbh->prepare("SELECT distinct source_class_code from $archivedb.eval_datastreams where datastream='$fullds'");
								if (!defined $sth_getevalsc) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_getevalsc->execute;
								$evaldel="";
								while ($getevalsc = $sth_getevalsc->fetch) {
									$evaldel=$getevalsc->[0];
									if ($evaldel =~ 'eval') {
										$sql[$sqlcount]="DELETE FROM arm_int2.eval_datastreams WHERE datastream='$fullds' and source_class_code='$evaldel';";
										#print ARMINT2 "DELETE FROM arm_int2_stage.eval_datastreams WHERE datastream='$fullds' and source_class_code='$evaldel';\n";
										$sqlcount = $sqlcount + 1;
										$idstatcheck = $idstatcheck + 1;
										### PREVIOUSLY, WE WERE INSTRUCTED TO NOT UPDATE or INSERT INTO DATASTREAM_INFO AS THE ARCHIVE "BLEW IT AWAY" EVERYDAY ANYWAY AND REBUILT IT
										### AS OF 2017 DEVELOPERS MEETING, HAROLD NOW SAYS I ALSO NEED TO UPDATE DATASTREAM_INFO AND CHANGE THE EVAL SOURCE CLASS TO A PRODUCTION SOURCE CLASS
										### FROM HAROLD (07/31/2017): "The only thing that MMT would need to do is change the source class from either 'evalderiv' or 'evalobs' to one of 'armobs', 'armderiv',
										### 'externalobs', or 'externalderiv' when a datastream moves from eval to regular status and the datastream is removed from the eval_datastreams table."
										### NEED TO ADD THAT CODE BELOW!
										###
										###
										###
										###
										#print "The source class of the former eval product was $evaldel<br>\n";
										#print "Find the corresponding production source class, and then update datastream_info for $fullds<br>\n";
									}
								}
							}
						}
					
					
					
					}
					$sth_getmmtdsdetails = $dbh->prepare("SELECT distinct primary_meas_code,primary_measurement,var_name from primMeas where IDNo=$idn");
					if (!defined $sth_getmmtdsdetails) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getmmtdsdetails->execute;
					while ($getmmtdsdetails = $sth_getmmtdsdetails->fetch) {
						$sth_checkpmdetails = $dbh->prepare("SELECT count(*) from $archivedb.$dsvarnameinfotab WHERE $archivedb.$dsvarnameinfotab.datastream='$fullds' and $archivedb.$dsvarnameinfotab.primary_meas_type_code='$getmmtdsdetails->[0]' and $archivedb.$dsvarnameinfotab.primary_measurement='$getmmtdsdetails->[1]' and $archivedb.$dsvarnameinfotab.var_name='$getmmtdsdetails->[2]'");
						if (!defined $sth_checkpmdetails) { die "Cannot  statement: $DBI::errstr\n"; }
						$sth_checkpmdetails->execute;
						while ($checkpmdetails = $sth_checkpmdetails->fetch) {
							if ($checkpmdetails->[0] == 0) {
								#INSERT/UPDATE NEEDED
								# exact datastream/pmt/pm/var_name combination does not exist
								# check a few other things.
								# perhaps only the pm (primary measurement long name) is changing?
								$sth_checkifdsvarexists = $dbh->prepare("SELECT count(*) from $archivedb.$dsvarnameinfotab WHERE $archivedb.$dsvarnameinfotab.datastream='$fullds' and $archivedb.$dsvarnameinfotab.primary_meas_type_code='$getmmtdsdetails->[0]' and $archivedb.$dsvarnameinfotab.var_name='$getmmtdsdetails->[2]'");
								if (!defined $sth_checkifdsvarexists) { die "Cannot  statement: $DBI::errstr\n"; }
								$sth_checkifdsvarexists->execute;
								while ($checkifdsvarexists = $sth_checkifdsvarexists->fetch) {
									if ($checkifdsvarexists->[0] == 0) {
										# datastream/pmt/var_name combination does not exist
										# check a few other things
										# perhaps the pmt (primary meas code) is changing?
										$sth_checkpmcdetails = $dbh->prepare("SELECT count(*) from $archivedb.$dsvarnameinfotab WHERE $archivedb.$dsvarnameinfotab.datastream='$fullds' and $archivedb.$dsvarnameinfotab.var_name='$getmmtdsdetails->[2]'");
										if (!defined $sth_checkpmcdetails) { die "Cannot  statement: $DBI::errstr\n"; }
										$sth_checkpmcdetails->execute;
										while ($checkpmcdetails = $sth_checkpmcdetails->fetch) {
											if ($checkpmcdetails->[0] == 0) {
												#this datastream/varname pair does not exist
												#insert required
												#print "INSERT IN
												$sql[$sqlcount]="INSERT INTO arm_int2.$dsvarnameinfotab values('$fullds','$getmmtdsdetails->[2]','$getmmtdsdetails->[0]','$getmmtdsdetails->[1]','19900101','30010101','Y','Y','Y','Y');";
												#print ARMINT2 "INSERT INTO arm_int2_stage.$dsvarnameinfotab values('$fullds','$getmmtdsdetails->[2]','$getmmtdsdetails->[0]','$getmmtdsdetails->[1]','19900101','30010101','Y','Y','Y','Y');\n";
												$sqlcount = $sqlcount + 1;
												$idstatcheck = $idstatcheck + 1;
											} else {
												#update of pmt needed for this datastream/var name pair
												# (also update primary measurement for good measure)
												
												$sql[$sqlcount]="UPDATE arm_int2.$dsvarnameinfotab set primary_measurement='$getmmtdsdetails->[1]',primary_meas_type_code='$getmmtdsdetails->[0]' WHERE arm_int2.$dsvarnameinfotab.datastream='$fullds' and arm_int2.$dsvarnameinfotab.var_name='$getmmtdsdetails->[2]';";
												#print ARMINT2 "UPDATE arm_int2_stage.$dsvarnameinfotab set primary_measurement='$getmmtdsdetails->[1]',primary_meas_type_code='$getmmtdsdetails->[0]' WHERE arm_int2_stage.$dsvarnameinfotab.datastream='$fullds' and arm_int2_stage.$dsvarnameinfotab.var_name='$getmmtdsdetails->[2]';\n";
												$sqlcount = $sqlcount + 1;
												$idstatcheck = $idstatcheck + 1;
											}
											
										}
				
									} else {
										#update needed for primary measurement
										
										$sql[$sqlcount]="UPDATE arm_int2.$dsvarnameinfotab set primary_measurement='$getmmtdsdetails->[1]' WHERE arm_int2.$dsvarnameinfotab.datastream='$fullds' and arm_int2.$dsvarnameinfotab.primary_meas_type_code='$getmmtdsdetails->[0]' and arm_int2.$dsvarnameinfotab.var_name='$getmmtdsdetails->[2]';";
										#print ARMINT2 "UPDATE arm_int2_stage.$dsvarnameinfotab set primary_measurement='$getmmtdsdetails->[1]' WHERE arm_int2_stage.$dsvarnameinfotab.datastream='$fullds' and arm_int2_stage.$dsvarnameinfotab.primary_meas_type_code='$getmmtdsdetails->[0]' and arm_int2_stage.$dsvarnameinfotab.var_name='$getmmtdsdetails->[2]';\n";
										$sqlcount = $sqlcount + 1;
										$idstatcheck = $idstatcheck + 1;
									}
								}
				
							}
						}
						#### at metadata summit 6/9-10/2015, Harold asked can we remove the datastream_var_name_meas_cats table 
						#### given that a PMT defines the measurement category and subcategory?
						#### MMT does not use the table other than below to provide info it thought the archive wanted, so I will
						#### soon comment out this section that attempts to provide the  sql directives to the archive (for now)
						###### 07/30/2015 - Harold requested I no longer send the datastream_var_name_meas_cats update - 
						######  commenting out below section today
						#@getmmtdsmeascats = $dbh->prepare("SELECT distinct meas_category_code,meas_subcategory_code from measCats where IDNo=$idn");
						#foreach $getmmtdsmeascats (@getmmtdsmeascats) {
						#	$tmc=$getmmtdsmeascats->[0];
						#	$tmsc=$getmmtdsmeascats->[1];
						#	if ($tmsc eq "") {
						#		$tmsc="NULL";
						#	} else {
						#		$tmsc="'"."$tmsc"."'";
						#	}
						#	@checkarchdsmeascats = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$dsvarnamemeascatstab WHERE $archivedb.$dsvarnamemeascatstab.datastream='$fullds' and $archivedb.$dsvarnamemeascatstab.var_name='$getmmtdsdetails->[2]' and $archivedb.$dsvarnamemeascatstab.meas_category_code='$getmmtdsmeascats->[0]' and $archivedb.$dsvarnamemeascatstab.meas_subcategory_code=$tmsc");
						
						#	foreach $checkarchdsmeascats (@checkarchdsmeascats) {
						#		if ($checkarchdsmeascats->[0] == 0) {
						#			#INSERT/UPDATE NEEDED
						#			
						#			$sql[$sqlcount]="INSERT INTO arm_int2.datastream_var_name_meas_cats values('$fullds','$getmmtdsdetails->[2]','$tmc',$tmsc,'19900101','30010101','Y','Y','Y','Y');";
						#			$sqlcount = $sqlcount + 1;
						#			$idstatcheck = $idstatcheck + 1;
						#		}
						#	}
						#}
					}
				}
				
			}
			if ($idstatcheck == 0) {
				if ($countsiteindod != 0) {
					print "NO Archive DB ENTRY/UPDATE required ($idn): up-to-date!<br>\n";	
					print "Status of this entry (MMT# $idn) will be set to Approved/Completed<p>\n";
					$doStatus = $dbh->do("UPDATE IDs set DBstatus=2 where IDNo=$idn");
					$doStatus = $dbh->do("UPDATE DS set statusFlag=2 where IDNo=$idn");
					$doStatus = $dbh->do("UPDATE primMeas set statusFlag=2 where IDNo=$idn");
					$doStatus = $dbh->do("UPDATE instClass set statusFlag=2 where IDNo=$idn");
				} else {
					if ($checkforraw == 0) {
						print "RAW DATASTREAM - NO PMT to PMVAR IMPLEMENTATION COMPILED FOR ARCHIVE<br>\n";
					} else {
						$sql[$sqlcount]="ARCHIVE DB ENTRY/UPDATE MAY BE REQUIRED ($idn). No site information entered via MMT DOD submission/review/approval to formulate sql directives for archive updates";
						$sqlcount = $sqlcount + 1;
						print "<b><font color=\"red\">Archive DB ENTRY/UPDATE MAY BE REQUIRED ($idn).  No sites entered via DOD submission to formulate sql for archive updates</font></b><br><p>\n";
					}
				}
			} else {
				if ($sqlcount > 0) {
					print "Archive DB ENTRY/UPDATE required($idn)<br>\n";
					print "Implementation request sent to archive<p>\n";
				}
			}
			$idx = $idx + 1;			
			#if ($countarray == 1) {
			#	$filetodel="$armintupdatesfile";
			#	close(ARMINT2);	
			#}
			#if ($countarray > 1) {
			#	close(ARMINT2);
			#}					
		}
		# below sends email after all approved DS entries are synchronized
		if ($emchk eq "") {
			if ($sqlcount > 0) {
				@sortedsql=();
				@sortedsql=sort @sql;
				$sth_getdist = $dbh->prepare("SELECT distinct person_id,person_id from reviewers,revFuncsByType where reviewers.revFunction=revFuncsByType.revFunction and reviewers.revFunction='IMPL'");
				if (!defined $sth_getdist) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getdist->execute;
				while ($getdist = $sth_getdist->fetch) {
					$sth_getemail = $dbh->prepare("SELECT person_id,email from $peopletab where person_id=$getdist->[0]");
					if (!defined $sth_getemail) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getemail->execute;
					while ($getemail = $sth_getemail->fetch) {
						if ($idx == 1) {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Datastream ENTRY/UPDATE ready for implementation- MMT# @idarray\" \"$getemail->[1]\"");	
						} else {
							open(MAIL,"|$VROOT/lib/dbmail -s \"MMT: Batch - Datastream, ENTRY/UPDATE ready for implementation\" \"$getemail->[1]\"");
						}
						print MAIL "ENTRY/UPDATE for a Datastream ready for implementation in archive metadata databases.\n";
						print MAIL "--------------------------------------------\n";
						print MAIL "SQL commands (some still under development) follow for your convenience:\n\n";
						$dup="";
						foreach $sq (@sortedsql) {
							if ($dup ne $sq) {
								print MAIL "$sq\n";
							}
							$dup = $sq;
						}
						if ($idx == 1) {
							foreach $idn (@idarray) {
								print MAIL "\nYou can visit the MMT system at URL http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$idn";
							}
						} else {
							print MAIL "\nhttp://$webserver/cgi-bin/MMT/admin/MMTMetaData.pl?type=DS";
						}
						close(MAIL);
					}
				}
			} else {
				####### NEED TO DELETE THE EMPTY ARMINT2 SQL FILE!
				#unlink ($filetodel) || print "having trouble deleting $filetodel: $!";
			}
		}
						
	}
	$dbh->disconnect();
}
#########################################
sub displaystatus 
{
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      	
	my $objct = shift;
	my $idn = shift;
	my $useid = shift;
	my $howmanyfunc=0;
	$sth_countfunc=$dbh->prepare("SELECT distinct revFunction from revFuncsByType where type='$objct'");
	if (!defined $sth_countfunc) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_countfunc->execute;
	while ($countfunc = $sth_countfunc->fetch) {
		$howmanyfunc=$howmanyfunc + 1;
	}
	print "<table cellspacing=\"0\">\n";
	print "<tr><th rowspan=1 colspan=$howmanyfunc bgcolor=\"#FFF999\"><font color=red>Current Status</font></th></tr><tr>\n";
	$sth_getfunctions=$dbh->prepare("SELECT distinct revFuncsByType.revFunction,revFuncDesc from revFuncsByType,revFuncLookup WHERE type='$objct' and revFuncsByType.revFunction=revFuncLookup.revFunction order by revFuncNo");
	if (!defined $sth_getfunctions) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getfunctions->execute;
	while ($getfunctions = $sth_getfunctions->fetch) {
		print "<th>$getfunctions->[1]</th>\n";
	}
	print "</tr><tr>\n";
	$sth_getreviewStat=$dbh->prepare("SELECT distinct reviewers.revFunction,revFuncNo from reviewers,revFuncLookup,revFuncsByType WHERE reviewers.revFunction=revFuncLookup.revFunction and reviewers.type='$objct' and revFuncsByType.type=reviewers.type and reviewers.revFunction=revFuncsByType.revFunction order by revFuncNo");
	if (!defined $sth_getreviewStat) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_getreviewStat->execute;
	while ($getreviewStat = $sth_getreviewStat->fetch) {
	# go through each type of review function and get the latest status!
		$func=$getreviewStat->[0];
		$sth_checkcount=$dbh->prepare("SELECT count(*),count(*) from reviewerStatus,reviewers where IDNo=$idn and reviewers.revFunction='$func' and reviewers.type='$objct' and (statusDate=null or statusDate=(SELECT max(statusDate) from reviewerStatus,reviewers where IDNo=$idn and revFunction='$func' and reviewers.type='$objct'))");
		if (!defined $sth_checkcount) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checkcount->execute;
		while ($checkcount = $sth_checkcount->fetch) {
		# if there are review statuses for this function type, get the latest one
			if ($checkcount->[0] >= 1) {
				$countcompare=0;
				$sth_chkdate=$dbh->prepare("SELECT count(*),count(*) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and reviewers.revFunction='$func' and reviewers.type='$objct'");
				if (!defined $sth_chkdate) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_chkdate->execute;
				while ($chkdate = $sth_chkdate->fetch) {
					$countcompare=$chkdate->[0];
				}
				$max=0;
				# if countcompare is not equal to checkcount, then that means there were previous iterations of this review function
				# prior to the latest set of them
				# if countcompare is equal to checkcount, then there is just one set for this function type but they all have the same entry date, so we will just use the highest status value
				if ($countcompare == $checkcount->[0]) {
					$sth_getstat=$dbh->prepare("SELECT distinct status,reviewerStatus.person_id from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and reviewers.revFunction='$func' and reviewers.type='$objct' and status=(SELECT max(status) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and revFunction='$func' and reviewers.type='$objct')");
				# otherwise we need to get the highest status value for the latest review date for this function type
				} else {
					$maxdate="null";
					$sth_getmaxrevdate=$dbh->prepare("SELECT max(statusDate),max(statusDate) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and reviewers.revFunction='$func' and reviewers.type='$objct'");
					if (!defined $sth_getmaxrevdate) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getmaxrevdate->execute;
					while ($getmaxrevdate = $sth_getmaxrevdate->fetch) {
						$maxdate="\'"."$getmaxrevdate->[0]"."\'";
					}
					$sth_getstat=$dbh->prepare("SELECT distinct status,reviewerStatus.person_id from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and reviewers.revFunction='$func' and reviewers.type='$objct' and statusDate=$maxdate and status=(SELECT max(status) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and reviewers.revFunction='$func' and reviewers.type='$objct' and statusDate=$maxdate)");
				}
				if (!defined $sth_getstat) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getstat->execute;
				while ($getstat = $sth_getstat->fetch) {
					$statNo=$getstat->[0];
					$prid=$getstat->[1];
					$sth_getdesc=$dbh->prepare("SELECT status,statDesc from revStatLookup where func='$func' and status=$statNo");
					if (!defined $sth_getdesc) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getdesc->execute;
					while ($getdesc = $sth_getdesc->fetch) {
						$statDesc=$getdesc->[1];
					}
					$sth_getrev=$dbh->prepare("SELECT person_id,name_first,name_last from $peopletab where person_id=$prid");
					if (!defined $sth_getrev) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getrev->execute;
					while ($getrev = $sth_getrev->fetch) {
						if ($statNo == 0) {
							if ($max == 0) {
								$prname="$getrev->[1]"." "."$getrev->[2]";
								print "<td valign=middle>$statDesc</td>\n";	
							}
						} else {
							if ($max == 0) {
								$prname="$getrev->[1]"." "."$getrev->[2]";
								print "<td valign=middle>$statDesc</td>\n";
							}
						}
						$max = $max + 1;
					}
				}
			} else {
				$sth_getstat=$dbh->prepare("SELECT distinct status,reviewerStatus.person_id from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and reviewers.revFunction='$func' and reviewers.type='$objct' and (statusDate=null or statusDate=(SELECT max(statusDate) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id AND IDNo=$idn and reviewers.type='$objct' and reviewers.revFunction='$func'))");
				if (!defined $sth_getstat) { die "Cannot  statement: $DBI::errstr\n"; }
				$sth_getstat->execute;
				while ($getstat = $sth_getstat->fetch) {
					$statNo=$getstat->[0];
					$prid=$getstat->[1];
					$sth_getdesc=$dbh->prepare("SELECT status,statDesc from revStatLookup where func='$func' and status=$statNo");
					if (!defined $sth_getdesc) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getdesc->execute;
					while ($getdesc = $sth_getdesc->fetch) {
						$statDesc=$getdesc->[1];
					}
					$sth_getrev=$dbh->prepare("SELECT person_id,name_first,name_last from $peopletab where person_id=$prid");
					if (!defined $sth_getrev) { die "Cannot  statement: $DBI::errstr\n"; }
					$sth_getrev->execute;
					while ($getrev = $sth_getrev->fetch) {
						$prname="$getrev->[1]"." "."$getrev->[2]";
						print "<td valign=middle>$statDesc</td>\n";
					}
				}
			}
		}
	}
	print "</tr>\n";
	print "</table>";
	print "<p>\n";
	my $yourfunc="";
	my $funct="";
	$sth_checkfunc  = $dbh->prepare("SELECT person_id,revFunction from reviewers where person_id=$useid and type='$objct'");
	if (!defined $sth_checkfunc) { die "Cannot  statement: $DBI::errstr\n"; }
	$sth_checkfunc->execute;
	while ($checkfunc = $sth_checkfunc->fetch) {
		$yourfunc=$checkfunc->[1];
		$funct="R";
	}
	if ($yourfunc eq "") {
		$sth_checksupfunc= $dbh->prepare("SELECT person_id,revFunction from suppReviewers where person_id=$useid and IDNo=$idn");
		if (!defined $sth_checksupfunc) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_checksupfunc->execute;
		while ($checksupfunc = $sth_checksupfunc->fetch) {
			$yourfunc = $checksupfunc->[1];
			$funct="S";
		}
	}
	if ($yourfunc ne "") {
		$yourfuncstatus="";
		$maxdate="null";
		if ($funct eq "S") {
			$sth_getmaxrevdate=$dbh->prepare("SELECT max(statusDate),max(statusDate) from reviewerStatus,suppReviewers where reviewerStatus.person_id=suppReviewers.person_id and reviewerStatus.IDNo=suppReviewers.IDNo and reviewerStatus.IDNo=$idn and suppReviewers.revFunction='$yourfunc'");
			if (!defined $sth_getmaxrevdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxrevdate->execute;
			while ($getmaxrevdate = $sth_getmaxrevdate->fetch) {
				$maxdate="\'"."$getmaxrevdate->[0]"."\'";
			}
			$sth_getstat=$dbh->prepare("SELECT distinct status,reviewerStatus.person_id from reviewerStatus,suppReviewers where reviewerStatus.person_id=suppReviewers.person_id and reviewerStatus.IDNo=suppReviewers.IDNo and IDNo=$idn and suppReviewers.revFunction='$yourfunc' and statusDate=$maxdate and status=(SELECT max(status) from reviewerStatus,suppReviewers where reviewerStatus.person_id=suppReviewers.person_id and reviewerStatus.IDNo=suppReviewers.IDNo AND IDNo=$idn and suppReviewers.revFunction='$yourfunc' and statusDate=$maxdate)");
			if (!defined $sth_getstat) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getstat->execute;
			while ($getstat = $sth_getstat->fetch) {
				$yourfuncstatus=$getstat->[0];
			}
		} else {
			$sth_getmaxrevdate=$dbh->prepare("SELECT max(statusDate),max(statusDate) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id and reviewerStatus.IDNo=$idn and reviewers.revFunction='$yourfunc' and reviewers.type='$objct'");
			if (!defined $sth_getmaxrevdate) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getmaxrevdate->execute;
			while ($getmaxrevdate = $sth_getmaxrevdate->fetch) {
				$maxdate="\'"."$getmaxrevdate->[0]"."\'";
			}
			#if ($maxdate ne "") {
			$sth_getstat=$dbh->prepare("SELECT distinct status,reviewerStatus.person_id from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id and reviewerStatus.IDNo=$idn and reviewers.revFunction='$yourfunc' and reviewers.type='$objct' and statusDate=$maxdate and status=(SELECT max(status) from reviewerStatus,reviewers where reviewerStatus.person_id=reviewers.person_id and reviewerStatus.IDNo=$idn and reviewers.type='$objct' and reviewers.revFunction='$yourfunc' and statusDate=$maxdate)");
			if (!defined $sth_getstat) { die "Cannot  statement: $DBI::errstr\n"; }
			$sth_getstat->execute;
			while ($getstat = $sth_getstat->fetch) {
				$yourfuncstatus=$getstat->[0];	
			}
			#} else {
			#	$yourfuncstatus=0;
			#}
		}
		$sth_getdesc=$dbh->prepare("SELECT distinct status,statDesc from revStatLookup where func='$yourfunc' and status=$yourfuncstatus");
		if (!defined $sth_getdesc) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdesc->execute;
		while ($getdesc = $sth_getdesc->fetch) {
			$statDesc=$getdesc->[1];
		}
		print "Your status: \n";
		print "<select name=\"newstat\" size=0>\n";
		$oldstatdesc="";
		$sth_getchoices=$dbh->prepare("SELECT distinct status,statDesc,func from revStatLookup where func='$yourfunc' order by status");
		if (!defined $sth_getchoices) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getchoices->execute;
		while ($getchoices = $sth_getchoices->fetch) {
			$countstat=0;
			$statid=$getchoices->[0];
			$statdesc=$getchoices->[1];
			if ($statid == $yourfuncstatus)  {
				if ($oldstatdesc ne $statdesc) {
					print "<option value=\"$statid\" selected=\"selected\">$statdesc</option>\n";
				}	
			} else {
				if ($oldstatdesc ne $statdesc) {
					print "<option value=\"$statid\"> $statdesc</option>\n";
				}
			}
			$oldstatdesc=$statdesc;
		}
		print "</select>\n";
		print "<INPUT type=\"submit\" name=\"submit\" VALUE=\"Update Status\" />\n";
	}
	$dbh->disconnect();
}
############################################################
### subroutine to display linked DODs 
sub dodlinks {
	my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
	my $userid = $user;
	my $password=$password;
	my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      	
	my $idn= shift;
	$sth_getlinks = $dbh->prepare("SELECT distinct origIDNo,linkedIDNo from linkedDODs where origIDNo=$idn");
	if (!defined $sth_getlinks) { die "Cannot  statement: $DBI::errstr\n"; }
	$countl=0;
	print "<p>Linked DODs: \n";
	$sth_getlinks->execute;
	while ($getlinks = $sth_getlinks->fetch) {	
		$thisdodbase="";
		$thisdodlevel="";
		$thisdodversion="";
		$sth_getdoddetails=$dbh->prepare("SELECT dsBase,dataLevel,DODversion from DOD where IDNo=$getlinks->[1]");	
		if (!defined $sth_getdoddetails) { die "Cannot  statement: $DBI::errstr\n"; }
		$sth_getdoddetails->execute;
		while ($getdoddetails = $sth_getdoddetails->fetch) {
			$thisdodbase=$getdoddetails->[0];
			$thisdodlevel=$getdoddetails->[1];
			$thisdodversion=$getdoddetails->[2];
		}
		if ($countl == 0) {
			print "<a href=\"http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$getlinks->[1]\" target=\"DOD$getlinks->[1]\">$getlinks->[1]</a> - $thisdodbase\.$thisdodlevel (V$thisdodversion)\n";
		} else {
			print ", <a href=\"http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$getlinks->[1]\" target=\"DOD$getlinks->[1]\">$getlinks->[1]</a> - $thisdodbase\.$thisdodlevel (V$thisdodversion)\n";
		}
		$countl = $countl + 1;
	}
	if ($countl == 0) {
		print "None\n";
	}
	print "<p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" VALUE=\"Link/Unlink DODs\"><br><p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" VALUE=\"Copy comments to a linked DOD\">\n";
	$dbh->disconnect();
	
}
############################################################
### subroutine to calculate current "now" time to stamp updated records
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
1; #return true

