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
$grouprole = &get_grouprole;
$dbserver=&get_dbserver;
$instrclasstosourceclass=&get_instrclasstosourceclass; #user table
$remote_user=$ENV{'REMOTE_USER'};
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$procType=$in{procType};
$objcttype=$in{objcttype};
$submit = $in{submit};
$contactid = $in{contactid};
$groupname = $in{groupname};
$rolename = $in{rolename};
$subrolename = $in{subrolename};
$pcm="";
$pcm = $in{pcm};
if ($pcm eq "") {
	$pcm=0;
} else {
	$pcm=$in{pcm};
	$procType="N";

}
$type="CL";
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
print "<title>MMT: Contact Submission</title>\n";
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
&showifdev;
print "<body class=\"iops\">\n";
print "<div id=\"content\">\n";
print "<form method=\"post\" action=\"Contacts.pl\">\n";
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
	&bottomlinks($IDNo,"CL");
	exit;
}
######################
&toplinks($user_id,$user_first,$user_last,"CL");
print "<hr />\n";
if ($submit eq "Reset") {
	if ($in{groupname} ne "") {
		$groupname=$in{groupname};	
	} else {
		$groupname = "";
	}
	if ($in{rolename} ne "") {
		$rolename=$in{rolename};	
	} else {
		$rolename = "";
	}
	if ($in{subrolename} ne "") {
		$subrolename=$in{subrolename};	
	} else {
		$subrolename = "";
	}
	if ($in{oldgroupname} ne "") {
		$oldgroupname=$in{oldgroupname};	
	} else {
		$oldgroupname = "";
	}
	if ($in{oldrolename} ne "") {
		$oldrolename=$in{oldrolename};	
	} else {
		$oldrolename = "";
	}
	if ($in{oldsubrolename} ne "") {
		$oldsubrolename=$in{oldsubrolename};	
	} else {
		$oldsubrolename = "";
	}
	if ($in{contactid} ne "") {
		$contactid=$in{contactid};
	} else {
		$contactid="";
	}
	if ($in{oldcontactid} ne "") {
		$oldcontactid=$in{oldcontactid};
	} else {
		$oldcontactid="";
	}	
	if ($procType eq "N") {
		$submit="BEGIN";
	} else {
		$submit="Select";
	}
}
if (($procType eq "") && ($submit eq "") && ($IDNo eq "")) {
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"N\"><strong>Enter New Contact?</strong><p>\n";
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"E\"><strong>Update Existing Contact?</strong><p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"BEGIN\">\n";
	print "</form>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"CL");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if(($submit eq "BEGIN") || ($pcm == 1) || ($submit eq "Select Group") || ($submit eq "Select Role") || ($submit eq "Select Contact") || ($submit eq "Submit for Update") || ($submit eq "Submit for Deletion")) {
	if ($procType eq "N") {
		if (($pcm == 1) && ($procType == "N")) {
		print "<strong><p>Please select a contact from the \"Contact Name\" column, and a sub-role from the \"Sub-Role Name\" column.  \"Group Name\" and \"Role Name\" have been pre-selected for you (if possible) based upon the DOD you are submitting<p></strong>\n";
		}
		if ($pcm != 0) {
			$rolename="";
			$source="";
			@grouparray=();
			if ($in{rolename} ne "") {
				$rolename=$in{rolename};
			}
			if ($in{source} ne "") {
				$source=$in{source};
				@sourcearray=split(/\,/,$source);
			}
			foreach $s (@sourcearray) {
				if ($s eq "armderiv") {
					$grouparray[$ct]="VAP Contact";
				} elsif ($s eq "armobs") {
					$grouparray[$ct]="Inst. Mentor";
					$ct = $ct + 1;
					$grouparray[$ct]="Ingest Developer";
				} elsif (($s eq "extderiv") || ($s eq "extobs")) {
					$grouparray[$ct]="XDS Contact";
				}
				$ct = $ct + 1;
			}
		}
		print "<table cols=8>\n";
		print "<tr><td><strong>Contact Name</strong>:</td>\n";
		print "<td><SELECT name=\"contactid\" size=25>\n";
		$sth_getcontact=$dbh->prepare("SELECT distinct person_id,name_first,name_last,status from $peopletab where status not in ('R','D','E','I','M','N') order by name_last,name_first");
		if (!defined $sth_getcontact) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getcontact->execute;
        	while ($getcontact = $sth_getcontact->fetch) {
			print "<OPTION value=\"$getcontact->[0]\">$getcontact->[2], $getcontact->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "<td><strong>Group Name</strong>:</td>\n";
		print "<td><SELECT name=\"groupname\" size=25>\n";
		#check if coming directly from PCM or from DOD submission
		if (($pcm == 1) && ($procType eq "N")) {
			$sth_getgroup_name=$dbh->prepare("SELECT distinct group_name,group_name from $grouprole where group_name='Inst. Mentor' or group_name='Instrument Contact' or group_name='VAP Contact' or group_name='XDS Contact' order by group_name");		
		} else {
			$sth_getgroup_name=$dbh->prepare("SELECT distinct group_name,group_name from $grouprole where group_name !='Ingest Developer' order by group_name");
		};
		if (!defined $sth_getgroup_name) { die "Cannot prepare statement test: $DBI::errstr\n"; }
        	$sth_getgroup_name->execute;
        	while ($getgroup_name = $sth_getgroup_name->fetch) {
			$l=0;
			foreach $ga (@grouparray) {
				if ($ga eq $getgroup_name->[0]) {
					$l=1;
				}
			}
			if ($l == 1) {
				if ($getgroup_name->[0] eq "Inst. Mentor") {
					print "<OPTION value=\"$getgroup_name->[0]\" selected>Instrument Contact</OPTION>\n";
				} else {
					print "<OPTION value=\"$getgroup_name->[0]\" selected>$getgroup_name->[0]</OPTION>\n";
				}
			} else {
				if ($getgroup_name->[0] eq "Inst. Mentor") {
					print "<OPTION value=\"$getgroup_name->[0]\">Instrument Contact</OPTION>\n";
				}else {
					print "<OPTION value=\"$getgroup_name->[0]\">$getgroup_name->[0]</OPTION>\n";
				}
			}
		}
		print "</SELECT></td>\n";
		@rolearray=();
		$ictrole=0;
		$sth_getnewroles=$dbh->prepare("SELECT distinct upper(instrument_class),upper(instrument_class) from instClass,IDs where instClass.IDNo=IDs.IDNo and upper(instrument_class) not in  (SELECT distinct role_name from $grouprole) ORDER by instrument_class");
		if (!defined $sth_getnewroles) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getnewroles->execute;
        	while ($getnewroles = $sth_getnewroles->fetch) {
			$rolearray[$ictrole]=$getnewroles->[0];
			$ictrole = $ictrole + 1;
		}
		$sth_getrole_name=$dbh->prepare("SELECT distinct role_name,role_name from $grouprole order by role_name");	
		if (!defined $sth_getrole_name) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getrole_name->execute;
       		while ($getrole_name = $sth_getrole_name->fetch) {
			$rolearray[$ictrole]=$getrole_name->[0];
			$ictrole = $ictrole + 1;
		}
		$sth_getinst=$dbh->prepare("SELECT distinct upper($archivedb.$instrclasstosourceclass.instrument_class_code),upper($archivedb.$instrclasstosourceclass.instrument_class_code) from $archivedb.$instrclasstosourceclass order by $archivedb.$instrclasstosourceclass.instrument_class_code");
		if (!defined $sth_getinst) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinst->execute;
       		while ($getinst = $sth_getinst->fetch) {
			$rolearray[$ictrole]=$getinst->[0];
			$ictrole = $ictrole + 1;
		}
		@newrolearray=();
		@newrolearray=sort @rolearray;
		$oldrole="";
		$temprolename="";
		$temprolename=uc($rolename);
		if ($pcm == 1) {
			print "<td><strong>Role Name:<br>(Instrument/Vap Class)</strong></td>\n";
		} else {
			print "<td><strong>Role Name</strong>:</strong></td>\n";
		}
		print "<td><SELECT name=\"rolename\" size=25>\n";
		
		foreach $r (@newrolearray) {
			if ($r ne $oldrole) {
				if ($pcm == 1) {
					if ($r eq $temprolename) {
						print "<OPTION value=\"$r\" selected>$r</OPTION>\n";
					} else {
						print "<OPTION value=\"$r\">$r</OPTION>\n";
					}
				} else {
					print "<OPTION VALUE=\"$r\">$r</OPTION>\n";
				}
			}
			$oldrole=$r;
		}
		print "</SELECT></td>\n";
		print "<td><strong>Sub-Role Name</strong>:<br>(optional)</strong></td>\n";
		print "<td><SELECT name=\"subrolename\" size=25>\n";
		if ($pcm == 1) {
			$sth_getsubrole_name=$dbh->prepare("SELECT DISTINCT subrole_name from $grouprole WHERE subrole_name IS NOT NULL and (group_name = 'Inst. Mentor' or group_name='Instrument Contact' or group_name = 'VAP Contact' or group_name='Ingest Developer' or group_name = 'XDS Contact') order by subrole_name");
		} else {
			$sth_getsubrole_name=$dbh->prepare("SELECT distinct subrole_name,subrole_name from $grouprole where subrole_name IS NOT NULL order by subrole_name");
		}
		if (!defined $sth_getsubrole_name) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsubrole_name->execute;
        	while ($getsubrole_name = $sth_getsubrole_name->fetch) {
			print "<OPTION value=\"$getsubrole_name->[0]\">$getsubrole_name->[0]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr>\n";
		print "</table><p>\n";
		$objcttype="entry";
		if ($pcm == 1) {
			print "<input type=\"hidden\" name=\"pcm\" value=\"2\">\n";
		}
		print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
		print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"CL");
		print "</div>\n";
		print "</BODY></HTML>\n";
		exit;
	}
	if ($procType eq "E") {
		print "<strong>UPDATING OF CONTACTS IS STILL IN DEVELOPMENT. HOPE TO HAVE IT WORKING SOON!</strong><p>\n";
		$dbh->disconnect();
		exit;
		if ($in{groupname} ne "") { $groupname=$in{groupname}; } else { $groupname=""; }
		if ($in{rolename} ne "") { $rolename=$in{rolename}; } else { $rolename=""; }
		if ($in{subrolename} ne "") { $subrolename=$in{subrolename}; } else { $subrolename=""; }
		if ($in{contactid} ne "") { $contactid=$in{contactid} } else { $contactid=""; }
		if ($in{oldgroupname} ne "") { $oldgroupname=$in{oldgroupname};} else { $oldgroupname=""; }
		if ($in{oldrolename} ne "") { $oldrolename=$in{oldrolename}; } else { $oldrolename=""; }
		if ($in{oldsubrolename} ne "") { $oldsubrolename=$in{oldsubrolename}; } else { $oldsubrolename=""; }
		if ($in{oldcontactid} ne "") { $oldcontactid=$in{oldcontactid}; } else { $oldcontactid=""; }
		if ($groupname eq "") {
			print "<table>\n";
			print "<tr><td width=10%><strong>Existing Groups</strong>:</td>\n";
			print "<td><SELECT name=\"groupname\" size=25>\n";
			$sth_getgroups = $dbh->prepare("SELECT DISTINCT $grouprole.group_name,$grouprole.group_name from $grouprole order by group_name");
			if (!defined $sth_getgroups) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getgroups->execute;
        		while ($getgroups = $sth_getgroups->fetch) {
				if ($getgroups->[0] eq "Inst. Mentor") {
					print "<OPTION value=\"$getgroups->[0]\">Instrument Contact</OPTION>\n";
				} else {
					print "<OPTION value=\"$getgroups->[0]\">$getgroups->[0]</OPTION>\n";
				}
			}
			print "</SELECT></td>\n";
			print "</tr></table><p>\n";
			$objcttype="update";
			print "<INPUT TYPE=\"hidden\" name=\"procType\" value=\"$procType\">\n";
			print " <input type=\"submit\" name=\"submit\" value=\"Select Group\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
			print "</form>\n";
			&bottomlinks($IDNo,"CL");
			print "</div>\n";
			print "</BODY></HTML>\n";
			$dbh->disconnect();
			exit;
		}
		if (($submit eq "Select Group") && ($groupname ne "")) {
			$countg=0;
			$sth_countthem=$dbh->prepare("SELECT distinct role_name,subrole_name  from $grouprole where group_name='$groupname'");
			if (!defined $sth_countthem) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_countthem->execute;
        		while ($countthem = $sth_countthem->fetch) {
				$countg=$countg + 1;;
			};
			if ($countg > 1) {
				print "<table>\n";
				print "<tr><td colspan=2><strong>Group: $groupname</strong></td></tr>\n";
				print "<tr><td width=12%><strong>Roles (or Inst/VAP Classes)</strong>:</td>\n";
				$sth_getrole=$dbh->prepare("SELECT distinct role_name,subrole_name from $grouprole where group_name='$groupname' order by role_name,subrole_name");
				print "<td><SELECT name=\"rolename\" size=25>\n";
				if (!defined $sth_getrole) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getrole->execute;
        			while ($getrole = $sth_getrole->fetch) {
					print "<OPTION value=\"$getrole->[0]:$getrole->[1]\">$getrole->[0]";
					if ($getrole->[1] ne "") {
						print ":$getrole->[1]</OPTION>\n";
					} else {
						print "</OPTION>\n";
					}
				}
				print "</SELECT></td></tr></table>\n";			
				$objcttype="update";
				print "<INPUT TYPE=\"hidden\" name=\"groupname\" value=\"$groupname\">\n";
				print "<INPUT TYPE=\"hidden\" name=\"procType\" value=\"$procType\">\n";
				print " <input type=\"submit\" name=\"submit\" value=\"Select Role\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
				print "</form>\n";
				&bottomlinks($IDNo,"CL");
				print "</div>\n";
				print "</BODY></HTML>\n";
				$dbh->disconnect();
				exit;
			} else {
				$submit = "Select Role";
				$sth_getrole=$dbh->prepare("SELECT distinct role_name,subrole_name from $grouprole where group_name='$groupname' order by role_name,subrole_name");
				if (!defined $sth_getrole) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getrole->execute;
        			while ($getrole = $sth_getrole->fetch) {
					$rolename="$getrole->[0]"."\:"."$getrole->[1]";
				}
			}		
		}
		if (($submit eq "Select Role") && ($rolename ne "") && ($groupname ne "")) {
			$subrolename="";
			$newrolename="";
			@rolearray=();
			@rolearray=split(/\:/,$rolename);
			if ($rolearray[1] eq "") {
				$subrolename="NULL";
			} else {
				$subrolename="'"."$rolearray[1]"."'";
			}
			$newrolename=$rolearray[0];
			$newsubrolename=$rolearray[1];
			print "<table>\n";
			
			print "<tr><td colspan=2><strong>Group: $groupname</strong></td></tr>\n";
			print "<tr><td colspan=2><strong>Role: $newrolename\n";
			if ($subrolename ne "NULL") {
				print ": $rolearray[1]</strong></td></tr>\n";
			} else {
				print "</strong></td></tr>\n";
			}
			print "<tr><td width=10%><strong>Current Contact(s)</strong>:</td>\n";
			$sth_getcontact=$dbh->prepare("SELECT distinct $grouprole.person_id,name_first,name_last,status from $peopletab,$grouprole where $peopletab.person_id=$grouprole.person_id AND $grouprole.group_name='$groupname' AND role_name='$newrolename' and subrole_name=$subrolename AND status not in ('R','D','E','I','M','N') order by name_last,name_first");
			print "<td><SELECT name=\"contactid\" size=25>\n";			
			if (!defined $sth_getcontact) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getcontact->execute;
        		while ($getcontact = $sth_getcontact->fetch) {
				print "<OPTION value=\"$getcontact->[0]\">$getcontact->[2], $getcontact->[1]</OPTION>\n";
			}
			print "</SELECT></td></table>\n";
			$objcttype="update";
			print "<INPUT TYPE=\"hidden\" name=\"groupname\" value=\"$groupname\">\n";
			print "<INPUT TYPE=\"hidden\" name=\"rolename\" value=\"$newrolename\">\n";
			print "<INPUT TYPE=\"hidden\" name=\"procType\" value=\"$procType\">\n";
			print "<INPUT TYPE=\"hidden\" name=\"subrolename\" value=\"$newsubrolename\">\n";
			print " <input type=\"submit\" name=\"submit\" value=\"Select Contact\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
			print "</form>\n";
			&bottomlinks($IDNo,"CL");
			print "</div>\n";
			print "</BODY></HTML>\n";
			$dbh->disconnect();
			exit;
		}
		if (($submit eq "Select Contact") && ($contactid ne "") && ($rolename ne "") && ($groupname ne "")) {
			$oldcontactid=$contactid;
			$oldgroupname=$groupname;
			$oldrolename=$rolename;
			$oldsubrolename=$subrolename;
			print "<INPUT TYPE=\"HIDDEN\" name=\"oldcontactid\" value=\"$oldcontactid\">\n";
			print "<INPUT TYPE=\"HIDDEN\" name=\"oldgroupname\" value=\"$oldgroupname\">\n";
			print "<INPUT TYPE=\"HIDDEN\" name=\"oldrolename\" value=\"$oldrolename\">\n";
			if ($subrolename ne "") {
				print "<INPUT TYPE=\"HIDDEN\" name=\"oldsubrolename\" value=\"$oldsubrolename\">\n";
			} else {
				print "<INPUT TYPE=\"HIDDEN\" name=\"oldsubrolename\" value=\"\">\n";
			}
			print "<table>\n";
			print "<tr>\n";
			print "<th><strong>Contact</strong></th>\n";
			print "<th><strong>Group</strong></th>\n";
			print "<th><strong>Role</strong></th>\n";
			print "<th><strong>Sub-Role</strong></th>\n";
			print "</tr>\n";
			print "<td width=10%>\n";
			print "<SELECT name=\"contactid\" size=25>\n";
			$sth_getallpeople = $dbh->prepare("SELECT distinct person_id,name_last,name_first,status from $peopletab where status not in ('R','D','E','I','M','N') order by name_last,name_first");
			if (!defined $sth_getallpeople) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getallpeople->execute;
        		while ($getallpeople = $sth_getallpeople->fetch) {
				if ($oldcontactid eq $getallpeople->[0]) {
					print "<OPTION value=\"$oldcontactid\" SELECTED>$getallpeople->[1], $getallpeople->[2]</option>\n";
				} else {
					print "<OPTION value=\"$getallpeople->[0]\">$getallpeople->[1], $getallpeople->[2]</option>\n";
				}
			}
			print "</SELECT>\n";
			print "</td>\n";
			print "<td width=10%>\n";
			print "<SELECT name=\"groupname\" size=25>\n";
			$sth_getgroups=$dbh->prepare("SELECT distinct group_name,group_name from $grouprole order by group_name");
			if (!defined $sth_getgroups) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getgroups->execute;
        		while ($getgroups = $sth_getgroups->fetch) {
				if ($oldgroupname eq $getgroups->[0]) {
					if ($getgroups->[0] eq "Inst. Mentor") {
						print "<OPTION value=\"$getgroups->[0]\" SELECTED>Instrument Contact</OPTION>\n";
					} else {
						print "<OPTION value=\"$getgroups->[0]\" SELECTED>$getgroups->[0]</OPTION>\n";
					}
				} else {
					if ($getgroups->[0] eq "Inst. Mentor") {
						print "<OPTION value=\"$getgroups->[0]\">Instrument Contact</OPTION>\n";
					} else {
						print "<OPTION VALUE=\"$getgroups->[0]\">$getgroups->[0]</OPTION>\n";
					}
				}
			}
			print "</SELECT></td>\n";
			print "<td width=10%>\n";
			print "<SELECT name=\"rolename\" size=25>\n";
			$sth_getroles=$dbh->prepare("SELECT distinct role_name,role_name from $grouprole WHERE (role_name IS NOT NULL and role_name !=' ') order by role_name");
			if (!defined $sth_getroles) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getroles->execute;
        		while ($getroles = $sth_getroles->fetch) {
				if ($oldrolename eq $getroles->[0]) {
					print "<OPTION value=\"$oldrolename\" SELECTED>$getroles->[0]</option>\n";
				} else {
					print "<OPTION value=\"$getroles->[0]\">$getroles->[0]</option>\n";
				}
			}
			print "</SELECT></td>\n";
			print "<td width=10%>\n";
			print "<SELECT NAME=\"subrolename\" size=25>\n";
			$sth_getsubroles=$dbh->prepare("SELECT distinct subrole_name,subrole_name from $grouprole order by subrole_name");
			if (!defined $sth_getsubroles) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsubroles->execute;
        		while ($getsubroles = $sth_getsubroles->fetch) {
				if ($oldsubrolename eq $getsubroles->[0]) {
					print "<OPTION value=\"$oldsubrolename\" SELECTED>$getsubroles->[0]</OPTION>\n";
				} else {
					print "<OPTION VALUE=\"$getsubroles->[0]\">$getsubroles->[0]</OPTION>\n";
				}
			}
			print "</SELECT></td>\n";
			print "</tr></table>\n";
			print "<INPUT TYPE=\"hidden\" name=\"procType\" value=\"$procType\">\n";
			print " <input type=\"submit\" name=\"submit\" value=\"Submit for Update\"> <input type=\"submit\" name=\"submit\" value=\"Submit for Deletion\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
			print "</form>\n";
			&bottomlinks($IDNo,"CL");
			print "</div>\n";
			print "</BODY></HTML>\n";
			$dbh->disconnect();
			exit;
		}
		print "submit $submit, type $type, procType $procType, groupname $groupname, oldgroupname $oldgroupname, rolename $rolename, oldrolename $oldrolename, subrolename $subrolename, oldsubrolename $oldsubrolename, contactid $contactid, oldcontactid $oldcontactid<br>\n";
		if ((($submit eq "Submit for Update") || ($submit eq "Submit for Deletion")) && ($groupname ne "") && ($rolename ne "") && ($contactid ne "") && ($oldgroupname ne "") && ($oldrolename ne "") && ($oldcontactid ne "")) {
			if ($submit eq "Submit for Deletion") {
				#this item is being submitted for deletion - need to enter a record in MMT, but mark it with all - signs to indicate that the submission it for a deletion from the group role table! Do this by submitting to the IDs table with DBstatus -2
				
				
				$now=&getnow;
				print "INSERT INTO IDs values(DEFAULT,'$type',-2,0,'$now')<br>\n";
				$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$type',-2,0,'$now')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during insert. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
				# retrieve the IDNo which was created by insert above (identity field)
				$IDNo="";
				$sth_getIDNo=$dbh->prepare("SELECT IDNo,type,entry_date from IDs where type='$type' and DBstatus=-2 AND revStatus=0 and entry_date='$now'");
				if (!defined $sth_getIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getIDNo->execute;
        			while ($getIDNo = $sth_getIDNo->fetch) {
					$IDNo=$getIDNo->[0];
				}
				$nuser_id=$user_id;
				$newoldsubrolename="";
				if ($oldsubrolename ne "") {
					$newoldsubrolename="'"."$oldsubrolename"."'";
				} else {
					$newoldsubrolename="NULL";
				}
				
				$doStatus = $dbh->do("INSERT INTO instContacts values($IDNo,$nuser_id,$oldcontactid,'$oldgroupname','$oldrolename',$newoldsubrolename,0)");
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
			
				$objcttype='delete';
				print "<p><strong>Contact Deletion request in MMT for review</strong><p>\n";
				&distribute($user_id,"$type",$IDNo,"$objcttype");			
			}
			if ($submit eq "Submit for Update") {
				#this item is being submitted for updating - substitution of one person for another for a particular group/role. need to enter a record in MMT, but mark it with a * indicating it is a update - Do this by submitting to the IDs table with DBstatus ??? 1 for needing updates???  NOT WORKING YET
				$now=&getnow;
				print "INSERT INTO IDs values(DEFAULT,'$type',1,0,'$now')<br>\n";
				$doStatus = $dbh->do("INSERT INTO IDs values(DEFAULT,'$type',1,0,'$now')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during ID insert. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
				# retrieve the IDNo which was created by insert above (identity field)
				$IDNo="";
				$sth_getIDNo=$dbh->prepare("SELECT IDNo,type,entry_date from IDs where type='$type' and DBstatus=1 AND revStatus=0 and entry_date='$now'");
				if (!defined $sth_getIDNo) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getIDNo->execute;
        			while ($getIDNo = $sth_getIDNo->fetch) {
					$IDNo=$getIDNo->[0];
				}
				$nuser_id=$user_id;
				
				$newsubrolename="";
				if ($subrolename ne "") {
					$newsubrolename="'"."$subrolename"."'";
				} else {
					$newsubrolename="NULL";
				}
				print "INSERT INTO instContacts values($IDNo,$nuser_id,$contactid,'$groupname','$rolename',$newsubrolename,1)<br>\n";
				$doStatus = $dbh->do("INSERT INTO instContacts values($IDNo,$nuser_id,$contactid,'$groupname','$rolename',$newsubrolename,1)");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during contact insert. Please try again<br />\n";
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
			
				$objcttype='update';
				print "<p><strong>Contact Update request in MMT for review</strong><p>\n";
				&distribute($user_id,"$type",$IDNo,"$objcttype");
			}
		}
		print "<hr />\n";
		&bottomlinks($IDNo,"CL");
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
		$sth_getcontact = $dbh->prepare("SELECT distinct person_id,name_first,name_last from $peopletab where $peopletab.person_id=$contactid");
	} else {
		$procType="E";
		print "<INPUT TYPE=\"hidden\" name=\"IDNo\" value=\"$IDNo\">\n";
		$sth_getcontact = $dbh->prepare("SELECT distinct contact_id,name_first,name_last from instContacts,$peopletab WHERE IDNo=$IDNo and contact_id=$peopletab.person_id");
	}
	if (!defined $sth_getcontact) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getcontact->execute;
        while ($getcontact = $sth_getcontact->fetch) {
		$contactid=$getcontact->[0];
		$contactname="$getcontact->[2]".", "."$getcontact->[1]";
	}
	print "<strong>CONTACT NAME</strong>: $contactname<p>\n";
	print "<table>\n";
	@grouparray=();
	$gct=0;
	if ($IDNo eq "") {
		print "<STRONG> FEATURE UNDER DEVELOPMENT. COMING SOON!</Strong><br>\n";
		$dbh->disconnect();
		exit;
	} else {
		print "<td><strong>Group Name</strong>:</td>\n";
		print "<td><SELECT name=\"groupname\" size=25>\n";
		$sth_getgroups = $dbh->prepare("SELECT distinct group_name,role_name,subrole_name from instContacts where contact_id=$contactid and IDNo=$IDNo");
		if (!defined $sth_getgroups) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getgroups->execute;
        	while ($getgroups = $sth_getgroups->fetch) {
			$rolename="$getgroups->[1]";
			$subrolename="$getgroups->[2]";
			$groupname="$getgroups->[0]";
		}
		$sth_getgroups = $dbh->prepare("SELECT distinct group_name,group_name from $grouprole order by group_name");
		if (!defined $sth_getgroups) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getgroups->execute;
        	while ($getgroups = $sth_getgroups->fetch) {
			if ($groupname eq $getgroups->[0]) {
				if ($getgroups->[0] eq "Inst. Mentor") {
					print "<OPTION value=\"$getgroups->[0]\" selected>Instrument Contact</OPTION>\n";
				} else {
					print "<OPTION value=\"$getgroups->[0]\" selected>$getgroups->[0]</OPTION>\n";
				}
			} else {
				if ($getgroups->[0] eq "Inst. Mentor") {
					print "<OPTION value=\"$getgroups->[0]\">Instrument Contact</OPTION>\n";
				} else {
					print "<OPTION value=\"$getgroups->[0]\">$getgroups->[0]</OPTION>\n";
				}
			}
		}
		print "</SELECT></td>\n";
		print "<td><strong>Role Name</strong></td>\n";
		print "<td><SELECT name=\"rolename\" size=25>\n";		
		@newrolearray=();
		$nictrole=0;
		$sth_getnewroles=$dbh->prepare("SELECT distinct upper(instrument_class),upper(instrument_class) from instClass,IDs where instClass.IDNo=IDs.IDNo and upper(instrument_class) not in  (SELECT distinct role_name from $grouprole) ORDER by instrument_class");
		if (!defined $sth_getnewroles) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getnewroles->execute;
        	while ($getnewroles = $sth_getnewroles->fetch) {
			$newrolearray[$nictrole]=$getnewroles->[0];
			$nictrole = $nictrole + 1;
		}
		@rolearray=();
		$ictrole=0;
		$sth_getrole_name=$dbh->prepare("SELECT distinct role_name,role_name from $grouprole order by role_name");
		if (!defined $sth_getrole_name) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getrole_name->execute;
        	while ($getrole_name = $sth_getrole_name->fetch) {
			$rolearray[$ictrole]=$getrole_name->[0];
			$ictrole = $ictrole + 1;
		}
		foreach $nra (@newrolearray) {
			if ($rolename eq "$nra") {
				print "<OPTION class=\"red\" value=\"$nra\" selected>$nra</OPTION>\n";
			} else {
				print "<OPTION class=\"red\" value=\"$nra\">$nra</OPTION>\n";
			}
		}
		foreach $ora (@rolearray) {
			if ($rolename eq "$ora") {
				print "<OPTION value=\"$ora\" selected>$ora</OPTION>\n";
			} else {
				print "<OPTION value=\"$ora\">$ora</OPTION>\n";
			}
		}
		print "</select></td>\n";
		print "<td><strong>Sub-Role Name</strong></td>\n";
		print "<td><SELECT name=\"subrolename\" size=25>\n";
		$sth_getsubroles=$dbh->prepare("SELECT distinct subrole_name,subrole_name from $grouprole order by subrole_name");
		if (!defined $sth_getsubroles) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsubroles->execute;
        	while ($getsubroles = $sth_getsubroles->fetch) {
			if ($subrolename eq "$getsubroles->[0]") {
				print "<OPTION value=\"$getsubroles->[0]\" selected>$getsubroles->[0]</OPTION>\n";
			} else {
				print "<OPTION value=\"$getsubroles->[0]\">$getsubroles->[0]</OPTION>\n";
			}
		}	
		print "</SELECT></td>\n";	
	}	
	print "</tr></table><p>\n";
	print "<p>\n";
	$objcttype="entry";
	if ($IDNo ne "") {
		$objcttype="update";
	}
	print "<input type=\"hidden\" name=\"procType\" value=\"$procType\">\n";
	print "<input type=\"hidden\" name=\"objcttype\" value=\"$objcttype\">\n";
	print "<input type=\"hidden\" name=\"contactid\" value=\"$contactid\">\n";
	print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
	print "</form>\n";
	&bottomlinks($IDNo,"CL");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Submit") {
	$countmatch=0;
	if (($contactid eq "") || ($user_id eq "") || ($groupname eq "") || ($rolename eq "")) {
		print "Required information not entered (contact,group name, role name).  Go back and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}
	if ($subrolename eq "") {
		$subrolename="NULL";
	} else {
		$subrolename="\'$subrolename\'";
	}
	if ($procType eq "N") {
		$sth_checkit=$dbh->prepare("SELECT count(*),count(*) from instContacts,IDs where contact_id=$contactid and group_name='$groupname' and role_name='$rolename' and subrole_name=$subrolename and instContacts.IDNo=IDs.IDNo and IDs.type='CL'");
		if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkit->execute;
        	while ($checkit = $sth_checkit->fetch) {
			$countmatch=$checkit->[0];
		}
		if ($countmatch != 0) {
			print "<strong>This contact has already been submitted to the MMT review process</strong><p>\n";
			$dbh->disconnect();
			exit;
		}
	}
	if ($procType eq "E") {	
		if (($objcttype eq "entry") || ($objcttype eq "update")) {
			$sth_checkmmt = $dbh->prepare("SELECT count(*),count(*) from instContacts,IDs where contact_id=$contactid and group_name='$groupname' and role_name='$rolename' and subrole_name=$subrolename and instContacts.IDNo=IDs.IDNo and IDs.type='CL'");
			if (!defined $sth_checkmmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checkmmt->execute;
        		while ($checkmmt = $sth_checkmmt->fetch) {
				if ($checkmmt->[0] > 0) {
					print "<strong>This contact has already been submitted to the MMT review process</strong><p>\n";
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
		$nuser_id=$user_id;
		if ($IDNo ne "") {
			$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter,submitter from instContacts where IDNo=$IDNo");
			if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getorigsubm->execute;
        		while ($getorigsubm = $sth_getorigsubm->fetch) {
				$nuser_id=$getorigsubm->[0];
			}
		}
		$doStatus = $dbh->do("INSERT INTO instContacts values($IDNo,$nuser_id,$contactid,'$groupname','$rolename',$subrolename,$stat)");
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
			print "<p><strong>Contact added to MMT for review</strong><p>\n";
			&distribute($user_id,"$type",$IDNo,"$objcttype");
		} else {
			$objcttype='update';
			print "<p><strong>Contact in MMT for review</strong><p>\n";
			&distribute($user_id,"$type",$IDNo,"$objcttype");
		}
		if ($pcm > 0) {
			print "<hr><strong><a href=\"MMTMetaData.pl?type=DOD\">Metadata Management Tool (MMT): Summary Page</a></strong><p>\n";
			print "<strong><h3><a href=\"MMTMenu.pl\">MMT Main Menu</a></h3></strong><p>\n";
		} else {	
			print "<hr>\n";
			&bottomlinks($IDNo,"CL");
		}
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} else {
		$objcttype='update';
		$doStatus = $dbh->do("UPDATE instContacts set contact_id=$contactid,group_name='$groupname',role_name='$rolename',subrole_name=$subrolename,statusFlag=1 WHERE IDNo=$IDNo");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during update. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		print "<p><strong>Contact in MMT for review</strong><p>\n";
		print "<hr />\n";
		&bottomlinks($IDNo,"CL");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
}
$dbh->disconnect();
