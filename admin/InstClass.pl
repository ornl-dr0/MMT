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
$grouprole = &get_grouprole;
$archivedb = &get_archivedb;
$dbserver = &get_dbserver;
$instrcatdetailstab = &get_instrcatdetailstab; #user table
$instrclassdetailstab = &get_instrclassdetailstab; #user table
$sourceclassdetails = &get_sourceclassdetails; #user table
$instrclasstosourceclass = &get_instrclasstosourceclass; #user table
$instrclasstoinstrcattab = &get_instrclasstoinstrcattab; #user table

$remote_user=$ENV{'REMOTE_USER'};
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$procType=$in{procType};
$objcttype=$in{objcttype};
$submit = $in{submit};
$instClass=$in{instClass};
$instClassName=$in{instClassName};
$instCat=$in{instCat};
$webblurb = $in{webblurb};
$user_id=$in{user_id};
$sourceClass=$in{sourceClass};
$type="I";
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
print "<title>MMT: Instrument Class Submission</title>\n";
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
print "<form method=\"post\" action=\"InstClass.pl\">\n";
$hidmtIDs=0;
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
	&bottomlinks($IDNo,"I");
	$dbh->disconnect();
	exit;
}
&toplinks($user_id,$user_first,$user_last,"I");
$last="";
if ($in{mtIDs} ne "") {
	$mtIDs=$in{mtIDs};
}
$mtid="";
$mtremove="";
@mtnew=();
if ($in{mtremove} ne "") {
	$mtremove=$in{mtremove};
}
$mtnumofmt=0;
@mtIDsarray=();
if ($submit eq "Reset") {
	if ($in{instClass} ne "") {
		$instClass=$in{instClass};
		$procType=$in{procType};
		
	} else {
		$instClass = "";
	}
	if ($procType eq "N") {
		$submit="BEGIN";
	} else {
		$submit="Select";
	}
}
print "<hr>\n";
if ($IDNo ne "") {
	print "<INPUT TYPE=\"HIDDEN\" name=\"IDNo\" value=\"$IDNo\">\n";
	$procType="X";
}
if ($procType ne "") {
	print "<INPUT TYPE=\"HIDDEN\" name=\"procType\" value=\"$procType\">\n";
}
if (($procType eq "") && ($submit eq "") && ($IDNo eq "")) {
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"N\"><strong>Enter New Instrument Class?</strong><p>\n";
	print "<INPUT TYPE=\"radio\" name=\"procType\" value=\"E\"><strong>Update Existing Instrument Class?</strong><p>\n";
	print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"BEGIN\">\n";
	print "</form>\n";
	print "<hr />\n";
	&bottomlinks($IDNo,"I");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if (($submit ne "") && ($submit ne "RESET") && ($submit ne "Submit") && ($submit ne "Select")) {
	$last=$in{last};
	$mtremove=$in{mtremove};
	@param =  $query->param();
	foreach $mt (@param) {
		if ($mt =~ "mtsubmit") {
			$mtid=substr($mt,8);
		}
	}
	if ($in{mtIDs} ne "") {
		$mtIDs=$in{mtIDs};
		@mtIDsarray=split(/\ /,$mtIDs);
	} else {
		$countmt=0;
		if ($IDNo ne "") {
			$sth_getment=$dbh->prepare("SELECT IDNo,person_id from instContacts WHERE IDNo=$IDNo");
			if (!defined $sth_getment) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getment->execute;
        		while ($getment = $sth_getment->fetch) {
				$mtIDsarray[$countmt]=$getment->[1];
				$countmt = $countmt + 1;
			}
		} else {
			@mtIDsarray=();
		}
	}
	$mtnumofmt=@mtIDsarray;
	if ($mtid ne "") {
		$mtIDsarray[$mtnumofmt]=$mtid;
	}
	$mtnumofmt=@mtIDsarray;
}
if (($submit eq "BEGIN") && ($IDNo ne "") ) {
	$procType="N";
}
#############################
if ($submit eq "Submit") {
	$mtIDs = $in{mtIDs};
	if ($mtIDs ne "") {
		@mtIDsarray=split(/\ /,$mtIDs);
	} else {
		@mtIDsarray=();
	}
	if ($IDNo ne "") {
		$sth_gettype = $dbh->prepare("SELECT distinct IDNo,type from IDs where IDNo=$IDNo");
		if (!defined $sth_gettype) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_gettype->execute;
        	while ($gettype = $sth_gettype->fetch) {
			$type=$gettype->[1];
		}
	}
	$countmatch=0;
	if (($instClass eq "") || ($user_id eq "") || ($instClassName eq "") || ($sourceClass eq "") || ($instCat eq "")) {
		print "Required information not entered (instrument class, instrument class name, instrument category, source class).  Go back and try again.<br>\n";
		$dbh->disconnect();
		exit;
	}
	if ($procType eq "N") {
		$sth_checkit=$dbh->prepare("SELECT count(*),count(*) from instClass,IDs where instrument_class='$instClass' and instClass.IDNo=IDs.IDNo and IDs.type='I'");
		if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkit->execute;
        	while ($checkit = $sth_checkit->fetch) {
			$countmatch=$checkit->[0];
		}
		if ($countmatch == 0) {	
			;
		} else {
			print "<strong>This instrument class has already been submitted to the MMT review process</strong><p>\n";
			print "<hr />\n";
			&bottomlinks($IDNo,"I");
			print "</div>\n";
			print "</BODY></HTML>\n";
			$dbh->disconnect();
			exit;
		}
	}		
	if (($procType eq "E") || (($procType ne "N") && ($IDNo ne ""))) {	

		$sth_checkit=$dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab where instrument_class_code='$instClass'");
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
	$insertinst = 0;
	if (($IDNo ne "") && ($type eq 'I')) {
		$doStatus=$dbh->do("UPDATE IDs set DBstatus=$stat where IDNo=$IDNo");
		$sth_checkinsts = $dbh->prepare("SELECT count(*) from instClass where IDNo=$IDNo and instrument_class='$instClass'");
		if (!defined $sth_checkinsts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkinsts->execute;
        	while ($checkinsts = $sth_checkinsts->fetch) {
			if ($checkinsts->[0] == 0) {
				$insertinst=1; # will need to insert an instClass record!
			}
		}
	}
	if (($IDNo eq "") || ($insertinst == 0)) { 
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
		@instCatsArray=();
		@instCatsArray=split(/\0/,$instCat);
		@sourceClassArray=();
		@sourceClassArray=split(/\0/,$sourceClass);
		$doStatus=$dbh->do("DELETE from instClass where IDNo=$IDNo");
		$doStatus=$dbh->do("DELETE from instWebPageBlurb where IDNo=$IDNo");
		$doStatus=$dbh->do("INSERT into instClass values($IDNo,$nuser_id,'$instClass','$instClassName',$stat)");
		
		#########  Need to send the web page blurb to wordpress!! - future work
		$newwebblurb="";
		$_=$webblurb;
		s/'/''/g;
		$newwebblurb=$_;
		$doStatus=$dbh->do("INSERT into instWebPageBlurb values($IDNo,$nuser_id,'$newwebblurb',$stat)");
		########
		
		$doStatus=$dbh->do("DELETE from sourceClass where IDNo=$IDNo");
		$doStatus=$dbh->do("DELETE from instCats where IDNo=$IDNo");
		$mmtmatch=0;
		$countinarchive=0;
		foreach $ic (@instCatsArray) {
			$mmtmatch=$mmtmatch + 1;
			$sth_check3 = $dbh->prepare("SELECT count(*) from $archivedb.$instrclassdetailstab,$archivedb.$instrclasstoinstrcattab WHERE $archivedb.$instrclassdetailstab.instrument_class_code='$instClass' and $archivedb.$instrclassdetailstab.instrument_class_code=$archivedb.$instrclasstoinstrcattab.instrument_class_code and $archivedb.$instrclasstoinstrcattab.instrument_category_code='$ic'");
			if (!defined $sth_check3) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_check3->execute;
        		while ($check3 = $sth_check3->fetch) {
				if ($check3->[0] > 0) {
					$countinarchive=$countinarchive + 1;
					$sth_checkit = $dbh->prepare("SELECT count(*),count(*) from instCats where IDNo=$IDNo and inst_category_code='$ic'");
					if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_checkit->execute;
        				while ($checkit = $sth_checkit->fetch) {
						if ($checkit->[0] == 0) {
							$doStatus = $dbh->do("INSERT INTO instCats values($IDNo,$nuser_id,'$ic',1)");
						}
					}
				} else {
					$sth_checkit = $dbh->prepare("SELECT count(*) from instCats where IDNo=$IDNo and inst_category_code='$ic'");
					if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_checkit->execute;
        				while ($checkit = $sth_checkit->fetch) {
						if ($checkit->[0] == 0) {
							$doStatus = $dbh->do("INSERT INTO instCats values($IDNo,$nuser_id,'$ic',0)");
						}
					}
				}
			}
		}
		foreach $sc (@sourceClassArray) {							
			$mmtmatch = $mmtmatch + 1;
			$sth_countinarch = $dbh->prepare("SELECT count(*) from $archivedb.$instrclassdetailstab,$archivedb.$instrclasstosourceclass WHERE $archivedb.$instrclassdetailstab.instrument_class_code='$instClass' and $archivedb.$instrclassdetailstab.instrument_class_code=$archivedb.$instrclasstosourceclass.instrument_class_code and $archivedb.$instrclasstosourceclass.source_class_code='$sc'");
			if (!defined $sth_countinarch) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_countinarch->execute;
        		while ($countinarch = $sth_countinarch->fetch) {
				if ($countinarch->[0] > 0) {
					$countinarchive = $countinarchive + 1;
					$sth_checkit = $dbh->prepare("SELECT count(*) from sourceClass where source_class='$sc' and IDNo=$IDNo");
					if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_checkit->execute;
        				while ($checkit = $sth_checkit->fetch) {
						if ($checkit->[0] == 0) {
							$doStatus = $dbh->do("INSERT INTO sourceClass values($IDNo,$nuser_id,'$sc',1)");
						}
					}
				} else {
					$sth_checkit = $dbh->prepare("SELECT count(*) from sourceClass where source_class='$sc' and IDNo=$IDNo");
					if (!defined $sth_checkit) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_checkit->execute;
        				while ($checkit = $sth_checkit->fetch) {
						if ($checkit->[0] == 0) {
							$doStatus = $dbh->do("INSERT INTO sourceClass values($IDNo,$nuser_id,'$sc',0)");
						}
					}
				}
			}
		}
		if ($countinarchive == $mmtmatch) {
			$doStatus = $dbh->do("UPDATE IDs set DBstatus=1 where IDNo=$IDNo");
		} else {
			if ($countinarchive > 0) {
				$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 where IDNo=$IDNo");
			} 
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
		# figure out if this is an inst mentor or vap contact......
		$isvap=0;
		$isinst=0;
		foreach $sc (@sourceClassArray) {
			if (($sc eq "armderiv") || ($sc eq "extderiv")) {
				$isvap=1;
			}
			if (($sc eq "armobs") || ($sc eq "extobs")) {
				$isinst=1;
			}
		}
		if ($procType eq "N") {
			$objcttype='entry';
			print "<p><strong>Instrument Class $instClass added to MMT for review</strong><p>\n";
		} else {
			$objcttype='update';
			print "<p><strong>Instrument Class $instClass in MMT for review</strong><p>\n";
		}
		&distribute("$user_id","$type",$IDNo,"$objcttype");
		print "<hr />\n";
		&bottomlinks($IDNo,"I");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} else {
		$objcttype='update';
		@tinstCatsArray=();
		@tinstCatsArray=split(/\0/,$instCat);
		@oinstCatsArray=();
		@oinstCatsArray=sort @tinstCatsArray;
		@instCatsArray=();
		$oic="";
		$tc=0;
		foreach $oica (@oinstCatsArray) {
			if ($oica ne $oic) {
				$instCatsArray[$tc]=$oica;
				$tc = $tc + 1;
			}
			$oic = $oica;
		}
		@tsourceClassArray=();
		@tsourceClassArray=split(/\0/,$sourceClass);
		@osourceClassArray=();
		@osourceClassArray=sort @tsourceClassArray;
		@sourceClassArray=();
		$osc="";
		$tc=0;
		foreach $osca (@osourceClassArray) {
			if ($osca ne $osc) {
				$sourceClassArray[$tc]=$osca;
				$tc = $tc + 1;
			}
			$osc = $osca;
		}
		$nuser_id=$user_id;
		if ($IDNo ne "") {
			$sth_getorigsubm = $dbh->prepare("SELECT distinct submitter from instClass where IDNo=$IDNo");
			if (!defined $sth_getorigsubm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getorigsubm->execute;
        		while ($getorigsubm = $sth_getorigsubm->fetch) {
				$nuser_id=$getorigsubm->[0];
			}
		}
		$doStatus = $dbh->do("DELETE from instWebPageBlurb where IDNo=$IDNo");
		$doStatus = $dbh->do("DELETE from instCats where IDNo=$IDNo");
		$doStatus = $dbh->do("DELETE from sourceClass where IDNo=$IDNo");
		foreach $ic (@instCatsArray) {	
			$sth_check3 = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclassdetailstab,$archivedb.$instrclasstoinstrcattab WHERE $archivedb.$instrclassdetailstab.instrument_class_code='$instClass' and $archivedb.$instrclassdetailstab.instrument_class_code=$archivedb.$instrclasstoinstrcattab.instrument_class_code and $archivedb.$instrclasstoinstrcattab.instrument_category_code='$ic'");
			if (!defined $sth_check3) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_check3->execute;
        		while ($check3 = $sth_check3->fetch) {
				if ($check3->[0] > 0) {
					$doStatus = $dbh->do("INSERT INTO instCats values($IDNo,$nuser_id,'$ic',1)");
				} else {
					$doStatus = $dbh->do("INSERT INTO instCats values($IDNo,$nuser_id,'$ic',0)");
					# update IDs set DBstatus = -1
					if ($type eq 'I') {
						$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 WHERE IDNo=$IDNo and DBstatus=1");
					}
				}
			}
		}
		foreach $sc (@sourceClassArray) {
			$sth_countinarch = $dbh->prepare("SELECT count(*),count(*) from $archivedb.$instrclassdetailstab,$archivedb.$instrclasstosourceclass WHERE $archivedb.$instrclassdetailstab.instrument_class_code='$instClass' and $archivedb.$instrclassdetailstab.instrument_class_code=$archivedb.$instrclasstosourceclass.instrument_class_code and $archivedb.$instrclasstosourceclass.source_class_code='$sc'");
			if (!defined $sth_countinarch) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_countinarch->execute;
        		while ($countinarch = $sth_countinarch->fetch) {
				if ($countinarch->[0] > 0) {	
					# insert sourceClass with stat=1
					$doStatus = $dbh->do("INSERT INTO sourceClass values($IDNo,$nuser_id,'$sc',1)");							
				} else {
					# insert into sourceClass with stat=0
					$doStatus = $dbh->do("INSERT INTO sourceClass values($IDNo,$nuser_id,'$sc',0)");
					if ($type eq 'I') {
					# update IDs set DBstatus=-1
						$doStatus = $dbh->do("UPDATE IDs set DBstatus=-1 WHERE IDNo=$IDNo and DBstatus=1");
					}
				}
			}
		}
		$exinst=0;
		$sth_checkinst = $dbh->prepare("SELECT count(*),count(*) from instClass where instrument_class='$instClass' and IDNo=$IDNo");
		if (!defined $sth_checkinst) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkinst->execute;
        	while ($checkinst = $sth_checkinst->fetch) {
			$exinst=$checkinst->[0];
		}
		if ($exinst != 0) {
			$doStatus = $dbh->do("UPDATE instClass set instrument_class='$instClass',instrument_class_name='$instClassName' WHERE IDNo=$IDNo");
		} else {
			$doStatus = $dbh->do("DELETE from instClass where IDNo=$IDNo");
			$doStatus = $dbh->do("INSERT INTO instClass values($IDNo,$nuser_id,'$instClass','$instClassName',0)");
		}
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during update. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		
		######## need to send webpageblurb back to wordpress! future work
		$doStatus = $dbh->do("INSERT into instWebPageBlurb values($IDNo,$nuser_id,'$newwebblurb',0)");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during update. Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		########
		
		#  need to update instContacts with mentor/vap contacts for this new inst class!
		# first need to figure out if this is an inst mentor or vap contact......
		$isvap=0;
		$isinst=0;
		foreach $sc (@sourceClassArray) {
			if (($sc eq "armderiv") || ($sc eq "extderiv")) {
				$isvap=1;
			}
			if (($sc eq "armobs") || ($sc eq "extobs")) {
				$isinst=1;
			}
		}
		# fist delete all existing inst mentor/vap contacts from mmt db
		$doStatus = $dbh->do("DELETE from instContacts where IDNo=$IDNo");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during instContacts update. Please try again<br />\n";		
			$dbh->disconnect();
			exit;
		}
		# now add in those identified in the update/submit form
		foreach $mtid (@mtIDsarray) {
			$IC = uc $instClass;
			if ($isvap > 0) {
				$doStatus = $dbh->do("INSERT INTO instContacts (IDNo,submitter,contact_id,group_name,role_name) values ($IDNo,$nuser_id,$mtid,'VAP Contact','$IC')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during entry (instContacts table). Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			if ($isinst > 0) {
				$doStatus = $dbh->do("INSERT INTO instContacts (IDNo,submitter,contact_id,group_name,role_name) values ($IDNo,$nuser_id,$mtid,'Inst. Mentor','$IC')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during entry (instContacts table). Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
			if (( $isvap == 0) && ($isinst == 0)) {
				$doStatus = $dbh->do("INSERT INTO instContacts (IDNo,submitter,contact_id,group_name,role_name) values ($IDNo,$nuser_id,$mtid,'Other Contact','$IC')");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during entry (instContacts table). Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
		}	
		print "<p><strong>Instrument Class $instClass in MMT for review</strong><p>\n";
		print "<hr />\n";
		&bottomlinks($IDNo,"I");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
}
########################## 
if ($procType eq "N") {
	print "<strong>INSTRUMENT CLASS</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instex\">examples</a>): <INPUT TYPE=\"text\" name=\"instClass\" value=\"$instClass\" maxlength=25><p>\n";

	print "<strong>INSTRUMENT CLASS  NAME</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instx\">examples</a>): <INPUT TYPE=\"text\" name=\"instClassName\" value=\"$instClassName\" maxlength=80 length=100><p>\n";

	#if ($instClass ne "") {
		####### need to get the description if it exists for this instrument class from wordpress - future work
	#}
	print "<strong>DESCRIPTION FOR INSTRUMENT/VAP WEB PAGE:</strong><br>\n";
	print "<textarea name=\"webblurb\" rows=5 cols=100>$webblurb</textarea><p>\n";
	#######
	
	print "<strong>Select instrument category(ies) below for the new instrument class:</strong><p>\n";
	print "<SELECT name=\"instCat\" size=6 multiple>\n";
	$sth_getinstcats = $dbh->prepare("SELECT distinct instrument_category_code,instrument_category_name from $archivedb.$instrcatdetailstab order by instrument_category_code");
	if (!defined $sth_getinstcats) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getinstcats->execute;
        while ($getinstcats = $sth_getinstcats->fetch) {
		print "<OPTION value=\"$getinstcats->[0]\">$getinstcats->[0]: $getinstcats->[1]</OPTION>\n";
	}
	print "</SELECT><p>\n";
	print "<strong>Select source class(es) for the new instrument class:</strong><p>\n";
	print "<SELECT name=\"sourceClass\" size=6 multiple>\n";
	$sth_getsourceclasses = $dbh->prepare("SELECT distinct source_class_code,source_class_name from $archivedb.$sourceclassdetails order by source_class_code");
	if (!defined $sth_getsourceclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getsourceclasses->execute;
        while ($getsourceclasses = $sth_getsourceclasses->fetch) {
		print "<OPTION value=\"$getsourceclasses->[0]\">$getsourceclasses->[0]: $getsourceclasses->[1]</OPTION>\n";
	}
	print "</SELECT><p>\n";
	$objcttype="entry";
	if ($mtnumofmt > 0) {
		if ($hidmtIDs == 0) {
			print "<input type=\"HIDDEN\" NAME=\"mtIDs\" value=\"@mtIDsarray\" />\n";
			$hidmtIDs=1;
		}
	}
	print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"><br>\n";
	print "<hr>\n";
	print "</form>\n";
	&bottomlinks($IDNo,"I");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
if ($procType eq "X") {
	$sth_getic = $dbh->prepare("SELECT IDNo,instrument_class,instrument_class_name from instClass where IDNo=$IDNo");
	if (!defined $sth_getic) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getic->execute;
        while ($getic = $sth_getic->fetch) {
		$instClass=$getic->[1];
		$instClassName=$getic->[2];
	}
	if ($instClass eq "") {
		print "<table>\n";
		print "<tr><td><strong>EXISTING INSTRUMENT CLASSES</strong>:</td>\n";
		print " <td><SELECT name=\"instClass\" size=15>\n";
		$sth_getinstclasses=$dbh->prepare("SELECT distinct instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab order by instrument_class_code");
		if (!defined $sth_getinstclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstclasses->execute;
        	while ($getinstclasses = $sth_getinstclasses->fetch) {
			print "<OPTION value=\"$getinstclasses->[0]\">$getinstclasses->[0]: $getinstclasses->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr></table><p>\n";
		$objcttype="entry";
		print " <input type=\"submit\" name=\"submit\" value=\"Select\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"I");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} else {
		print "<strong>INSTRUMENT CLASS</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instex\">examples</a>): <INPUT TYPE=\"text\" name=\"instClass\" value=\"$instClass\" maxlength=25><p>\n";

		print "<strong>INSTRUMENT CLASS  NAME</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instx\">examples</a>): <INPUT TYPE=\"text\" name=\"instClassName\" value=\"$instClassName\" maxlength=80 length=100><p>\n";

		# get description for instrument class from wordpress! future work
		print "<strong>DESCRIPTION FOR INSTRUMENT/VAP WEB PAGE:</strong><br>\n";
		$sth_getblurb = $dbh->prepare("SELECT IDNo,instPageDesc from instWebPageBlurb where IDNo=$IDNo");
		if (!defined $sth_getblurb) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getblurb->execute;
        	while ($getblurb = $sth_getblurb->fetch) {
			$webblurb = $getblurb->[1];
		}
		print "<textarea name=\"webblurb\" rows=5 cols=100>$webblurb</textarea><p>\n";
		######
		
		print "<table>\n";
		print "<th colspan=2><strong>INSTRUMENT CATEGORY(IES)</strong>:</th>\n";
		print "<tr><td>Current Associations in ARM_int</td><td>Proposed Additions</td></tr>\n";
		print "<tr><td><SELECT name=\"instCat\" size=6 multiple>\n";
		$sth_getinstcat = $dbh->prepare("SELECT distinct $archivedb.$instrclasstoinstrcattab.instrument_category_code from $archivedb.$instrclasstoinstrcattab,$archivedb.$instrcatdetailstab where $archivedb.$instrclasstoinstrcattab.instrument_category_code=$archivedb.$instrcatdetailstab.instrument_category_code order by $archivedb.$instrclasstoinstrcattab.instrument_category_code");
		if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcat->execute;
        	while ($getinstcat = $sth_getinstcat->fetch) {
			$instcatname="";
			$sth_getinstcatname = $dbh->prepare("SELECT distinct instrument_category_name,instrument_category_code from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_getinstcatname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getinstcatname->execute;
        		while ($getinstcatname = $sth_getinstcatname->fetch) {
				$instcatname=$getinstcatname->[0];
			}
			$sth_checka = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$instClass' and instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checka->execute;
        		while ($checka = $sth_checka->fetch) {
				if ($checka->[0] != 0) {
					print "<OPTION value=\"$getinstcat->[0]\" selected>$getinstcat->[0]: $instcatname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT>\n";
		print "<td><SELECT name=\"instCat\" size=6 multiple>\n";
		$sth_getinstcat = $dbh->prepare("SELECT distinct $archivedb.$instrclasstoinstrcattab.instrument_category_code from $archivedb.$instrclasstoinstrcattab order by $archivedb.$instrclasstoinstrcattab.instrument_category_code");
		if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcat->execute;
        	while ($getinstcat = $sth_getinstcat->fetch) {
			$instcatname="";
			$sth_getinstcatname = $dbh->prepare("SELECT distinct instrument_category_name,instrument_category_code from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_getinstcatname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getinstcatname->execute;
        		while ($getinstcatname = $sth_getinstcatname->fetch) {
				$instcatname=$getinstcatname->[0];
				if ($IDNo ne "") {
					$sth_getcurinstcat = $dbh->prepare("SELECT count(*) from instCats where IDNo=$IDNo and inst_category_code='$getinstcatname->[1]'");
					if (!defined $sth_getcurinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getcurinstcat->execute;
        				while ($getcurinstcat = $sth_getcurinstcat->fetch) {
						if ($getcurinstcat->[0] == 0) {
							print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
						} else {
							print "<OPTION value=\"$getinstcat->[0]\" selected>$getinstcat->[0]: $instcatname</OPTION>\n";
						}
					}
				} else {
					print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT></tr>\n";
		print "</table>\n";	
		print "<table>\n";
		print "<th colspan=2><strong>SOURCE CLASS(ES)</strong>:</th>\n";
		print "<tr><td>Current Associations in ARM_int</td><td>Proposed Additions</td></tr>\n";
		print "<tr><td><SELECT name=\"sourceClass\" size=6 multiple>\n";
		$sth_getsourceclasses = $dbh->prepare("SELECT distinct source_class_code,source_class_name from $archivedb.$sourceclassdetails order by source_class_code");
		if (!defined $sth_getsourceclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclasses->execute;
        	while ($getsourceclasses = $sth_getsourceclasses->fetch) {
			$scname=$getsourceclasses->[1];
			$sth_getcursource = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstosourceclass where source_class_code='$getsourceclasses->[0]' and instrument_class_code='$instClass'");
			if (!defined $sth_getcursource) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getcursource->execute;
        		while ($getcursource = $sth_getcursource->fetch) {
				if ($getcursource->[0] == 0) {
					print "<OPTION value=\"$getsourceclasses->[0]\">$getsourceclasses->[0]: $scname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getsourceclasses->[0]\" selected>$getsourceclasses->[0]: $scname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT>\n";
		print "<td><SELECT name=\"sourceClass\" size=6 multiple>\n";
		$sth_getsourceclass = $dbh->prepare("SELECT distinct $archivedb.$sourceclassdetails.source_class_code,$archivedb.$sourceclassdetails.source_class_name from $archivedb.$sourceclassdetails order by $archivedb.$sourceclassdetails.source_class_code");
		if (!defined $sth_getsourceclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclass->execute;
        	while ($getsourceclass = $sth_getsourceclass->fetch) {
			$scname=$getsourceclass->[1];
			if ($IDNo ne "") {
				$sth_getcursource = $dbh->prepare("SELECT count(*) from sourceClass where IDNo=$IDNo and source_class='$getsourceclass->[0]'");
				if (!defined $sth_getcursource) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getcursource->execute;
        			while ($getcursource = $sth_getcursource->fetch) {
					if ($getcursource->[0] == 0) {
						print "<OPTION value=\"$getsourceclass->[0]\">$getsourceclass->[0]: $scname</OPTION>\n";
					} else {
						print "<OPTION value=\"$getsourceclass->[0]\" selected>$getsourceclass->[0]: $scname</OPTION>\n";
					}
				}
			} else {
				print "<OPTION value=\"$getsourceclass->[0]\">$getsourceclass->[0]: $scname</option>\n";
			}
		}
		print "</td>\n";
		print "</SELECT></tr>\n";
		print "</table>\n";	
		$objcttype="update";
		print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"><br>\n";
		print "<hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"I");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
} 
if ($procType eq "E") {
	if ($instClass eq "") {
		print "<table>\n";
		print "<tr><td><strong>EXISTING INSTRUMENT CLASSES</strong>:</td>\n";
		print " <td><SELECT name=\"instClass\" size=15>\n";
		$sth_getinstclasses=$dbh->prepare("SELECT distinct instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab order by instrument_class_code");
		if (!defined $sth_getinstclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstclasses->execute;
        	while ($getinstclasses = $sth_getinstclasses->fetch) {
			print "<OPTION value=\"$getinstclasses->[0]\">$getinstclasses->[0]: $getinstclasses->[1]</OPTION>\n";
		}
		print "</SELECT></td>\n";
		print "</tr></table><p>\n";
		$objcttype="entry";
	
		print " <input type=\"submit\" name=\"submit\" value=\"Select\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"> <hr>\n";
		print "</form>\n";
		&bottomlinks($IDNo,"I");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	} else {
		$sth_getinstclass = $dbh->prepare("SELECT instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab WHERE instrument_class_code='$instClass'");
		if (!defined $sth_getinstclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstclass->execute;
        	while ($getinstclass = $sth_getinstclass->fetch) {
			$instClassName=$getinstclass->[1];
		}
		print "<strong>INSTRUMENT CLASS</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instex\">examples</a>): <INPUT TYPE=\"text\" name=\"instClass\" value=\"$instClass\" maxlength=25><p>\n";
		print "<strong>INSTRUMENT CLASS  NAME</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instx\">examples</a>): <INPUT TYPE=\"text\" name=\"instClassName\" value=\"$instClassName\" maxlength=80 length=100><p>\n";
		
		######### get instrument class description from wordpress! future work	
		print "<strong>DESCRIPTION FOR INSTRUMENT/VAP WEB PAGE:</strong><br>\n";
		print "<textarea name=\"webblurb\" rows=5 cols=100>$webblurb</textarea><p>\n";
		#########
		
		print "<table>\n";
		print "<th colspan=2><strong>INSTRUMENT CATEGORY(IES)</strong>:</th>\n";
		print "<tr><td>Current Associations in ARM_int</td><td>Proposed Additions</td></tr>\n";
		print "<tr><td><SELECT name=\"instCat\" size=6 multiple>\n";
		$sth_getinstcat = $dbh->prepare("SELECT distinct $archivedb.$instrclasstoinstrcattab.instrument_category_code from $archivedb.$instrclasstoinstrcattab order by $archivedb.$instrclasstoinstrcattab.instrument_category_code");
		if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcat->execute;
        	while ($getinstcat = $sth_getinstcat->fetch) {
			$instcatname="";
			$sth_getinstcatname = $dbh->prepare("SELECT distinct instrument_category_name,instrument_category_code from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_getinstcatname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getinstcatname->execute;
        		while ($getinstcatname = $sth_getinstcatname->fetch) {
				$instcatname=$getinstcatname->[0];
			}
			$sth_checka = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$instClass' and instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checka->execute;
        		while ($checka = $sth_checka->fetch) {
				if ($checka->[0] != 0) {
					print "<OPTION value=\"$getinstcat->[0]\" selected>$getinstcat->[0]: $instcatname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT>\n";
		print "<td><SELECT name=\"instCat\" size=6 multiple>\n";
		$sth_getinstcat = $dbh->prepare("SELECT distinct $archivedb.$instrclasstoinstrcattab.instrument_category_code from $archivedb.$instrclasstoinstrcattab order by $archivedb.$instrclasstoinstrcattab.instrument_category_code");
		if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcat->execute;
        	while ($getinstcat = $sth_getinstcat->fetch) {
			$instcatname="";
			$sth_getinstcatname = $dbh->prepare("SELECT distinct instrument_category_name,instrument_category_code from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_getinstcatname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getinstcatname->execute;
        		while ($getinstcatname = $sth_getinstcatname->fetch) {
				$instcatname=$getinstcatname->[0];
				if ($IDNo ne "") {
					$sth_getcurinstcat = $dbh->prepare("SELECT count(*) from instCats where IDNo=$IDNo and inst_category_code='$getinstcatname->[0]'");
					if (!defined $sth_getcurinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getcurinstcat->execute;
        				while ($getcurinstcat = $sth_getcurinstcat->fetch) {
						if ($getcurinstcat->[0] == 0) {
							print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
						} else {
							print "<OPTION value=\"$getinstcat->[0]\" selected>$getinstcat->[0]: $instcatname</OPTION>\n";
						}
					}
				} else {
					print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT></tr>\n";
		print "</table>\n";	
		print "<table>\n";
		print "<th colspan=2><strong>SOURCE CLASS(ES)</strong>:</th>\n";
		print "<tr><td>Current Associations in ARM_int</td><td>Proposed Additions</td></tr>\n";
		print "<tr><td><SELECT name=\"sourceClass\" size=6 multiple>\n";
		$sth_getsourceclasses = $dbh->prepare("SELECT distinct source_class_code,source_class_name from $archivedb.$sourceclassdetails order by source_class_code");
		if (!defined $sth_getsourceclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclasses->execute;
        	while ($getsourceclasses = $sth_getsourceclasses->fetch) {
			$scname=$getsourceclasses->[1];
			$sth_getcursource = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstosourceclass where source_class_code='$getsourceclasses->[0]' and instrument_class_code='$instClass'");
			if (!defined $sth_getcursource) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getcursource->execute;
        		while ($getcursource = $sth_getcursource->fetch) {
				if ($getcursource->[0] == 0) {
					print "<OPTION value=\"$getsourceclasses->[0]\">$getsourceclasses->[0]: $scname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getsourceclasses->[0]\" selected>$getsourceclasses->[0]: $scname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT>\n";
		print "<td><SELECT name=\"sourceClass\" size=6 multiple>\n";
		$sth_getsourceclass = $dbh->prepare("SELECT distinct $archivedb.$sourceclassdetails.source_class_code,$archivedb.$sourceclassdetails.source_class_name from $archivedb.$sourceclassdetails order by $archivedb.$sourceclassdetails.source_class_code");
		if (!defined $sth_getsourceclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclass->execute;
        	while ($getsourceclass = $sth_getsourceclass->fetch) {
			$scname=$getsourceclass->[1];
			if ($IDNo ne "") {
				$sth_getcursource = $dbh->prepare("SELECT count(*) from sourceClass where IDNo=$IDNo and source_class='$getsourceclass->[0]'");
				if (!defined $sth_getcursource) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getcursource->execute;
        			while ($getcursource = $sth_getcursource->fetch) {
					if ($getcursource->[0] == 0) {
						print "<OPTION value=\"$getsourceclass->[0]\">$getsourceclass->[0]: $scname</OPTION>\n";
					} else {
						print "<OPTION value=\"$getsourceclass->[0]\" selected>$getsourceclass->[0]: $scname</OPTION>\n";
					}
				}
			} else {
				print "<OPTION value=\"$getsourceclass->[0]\">$getsourceclass->[0]: $scname</option>\n";
			}
		}
		print "</td>\n";
		print "</SELECT></tr>\n";
		print "</table>\n";	
		$objcttype="update";
		if ($mtnumofmt > 0) {
			if ($hidmtIDs == 0) {
				print "<input type=\"HIDDEN\" NAME=\"mtIDs\" value=\"@mtIDsarray\" />\n";
				$hidmtIDs=1;
			}
		}
		print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"><br>\n";
		print "<hr>\n";;
		print "</form>\n";
		&bottomlinks($IDNo,"I");
		print "</div>\n";
		print "</BODY></HTML>\n";
		$dbh->disconnect();
		exit;
	}
} 
if ($procType eq "") {
	print "<strong>Please go back and make a selection</strong><p>\n";
	print "<input type=\"hidden\" name=\"submit\" value=\"\">\n";
	$dbh->disconnect();
	exit;
}	
if (($submit eq "Select") || (($IDNo ne "") && ($submit ne "Submit"))) {
	if ($IDNo eq "") {
		$sth_checkinmmt = $dbh->prepare("SELECT count(*) from instClass,IDs where instrument_class='$instClass' and instClass.IDNo=IDs.IDNo and IDs.type='I'");
		if (!defined $sth_checkinmmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_checkinmmt->execute;
        	while ($checkinmmt = $sth_checkinmmt->fetch) {
			if ($checkinmmt->[0] > 0) {
				print "<strong><p>Sorry - this instrument class has already been submitted to the MMT for update/review.<p>Please go back to the mmt summary page to select it</strong><hr>\n";
				&bottomlinks($IDNo,"I");
				print "</div>\n";
				print "</BODY></HTML>\n";
				$dbh->disconnect();
				exit;
			}
		}
		$sth_getinstclass = $dbh->prepare("SELECT instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab WHERE instrument_class_code='$instClass'");
	} else {
		if ($procType ne "X") {
			$procType="E";
		}
		
		######### get instrument class description from wordpress - future work
		$webblurb="";
		$sth_getblurb = $dbh->prepare("SELECT IDNo,instPageDesc from instWebPageBlurb where IDNo=$IDNo");
		if (!defined $sth_getblurb) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_getblurb->execute;
		while($getblurb = $sth_getblurb->fetch) {
			$webblurb = $getblurb->[1];
		}
		##########
		
		$sth_getinstclass = $dbh->prepare("SELECT distinct instrument_class,instrument_class_name from instClass WHERE IDNo=$IDNo");
	}
	if (!defined $sth_getinstclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getinstclass->execute;
        while ($getinstclass = $sth_getinstclass->fetch) {
		$instClass=$getinstclass->[0];
		$instClassName=$getinstclass->[1];
	}
	$countit=0;
	$mtIDs="";
	$cntmnt=@mtIDsarray;
	if ($cntmnt == 0) {
		$sth_getm = $dbh->prepare("SELECT contact_id,contact_id from instContacts where IDNo=$IDNo");
		if (!defined $sth_getm) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getm->execute;
        	while ($getm = $sth_getm->fetch) {
			$mtIDsarray[$countit] = $getm->[0];
			$countit = $countit + 1;
		}
	}
	$countit=0;
	$cntmnt=@mtIDsarray;
	if ($cntmnt == 0) {
		if ($instClass ne "") {
			$ucinst = uc $instClass;
			$sth_chkgrprole = $dbh->prepare("SELECT distinct person_id from $grouprole WHERE role_name='$ucinst' and (group_name like 'Inst. Mentor' or 'group_name like 'Instrument Contact' or group_name like 'VAP Contact') and subrole_name=null");
			if (!defined $sth_checkgrprole) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_chkgrprole->execute;
        		while ($chkgrprole = $sth_chkgrprole->fetch) {
				$mtIDsarray[$countit]=$chkgrprole->[0];
				$countit = $countit + 1;
			}
		}
	}
	$countit=0;
	$cntmnt=@mtIDsarray;
	foreach $mnt (@mtIDsarray) {
		$sth_ret = $dbh->prepare("SELECT name_last,name_first,affiliation,phone,email FROM $peopletab WHERE person_id=$mnt");
		if (!defined $sth_ret) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_ret->execute;
        	while ($ret = $sth_ret->fetch) {
			push(@Names, "@ret[0]->[1] @ret[0]->[0]");
			$labels{$mid}="@ret[0]->[1] @ret[0]->[0]";
			if ($countit == 0) {
				print " @ret[0]->[1] @ret[0]->[0]\n";
			} else {
				print ", @ret[0]->[1] @ret[0]->[0]\n";
			}
			$countit = $countit + 1;
		}
	}
	if ($hidmtIDs == 0) {
		print "<input type=\"hidden\" name=\"mtIDs\" value=\"@mtIDsarray\">\n";
		$hidmtIDs=1;
	}
	print "<strong>INSTRUMENT CLASS</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instclassex\">examples</a>): <INPUT TYPE=\"text\" name=\"instClass\" value=\"$instClass\" maxlength=64 length=50><p>\n";
	print "<strong>INSTRUMENT CLASS NAME</strong> (<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instclassex\">examples</a>): <INPUT TYPE=\"text\" name=\"instClassName\" value=\"$instClassName\" maxlength=100 size=100><p>\n";

	####### get instrument class description from wordpress	- future work
	print "<strong>DESCRIPTION FOR INSTRUMENT/VAP WEB PAGE:<br>\n";
	print "<textarea name=\"webblurb\" rows=5 cols=100>$webblurb</textarea><p>\n";
	#######
	
	if ($IDNo ne "") {
		print "<table>\n";
		print "<th colspan=2><strong>INSTRUMENT CATEGORY(IES)</strong>:</th>\n";
		print "<tr><td>Current Associations in ARM_int</td><td>Proposed Additions</td></tr>\n";
		print "<tr><td><SELECT name=\"instCat\" size=6 multiple>\n";
		$sth_getinstcat = $dbh->prepare("SELECT distinct $archivedb.$instrclasstoinstrcattab.instrument_category_code from $archivedb.$instrclasstoinstrcattab order by $archivedb.$instrclasstoinstrcattab.instrument_category_code");
		if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcat->execute;
        	while ($getinstcat = $sth_getinstcat->fetch) {
			$instcatname="";
			$sth_getinstcatname = $dbh->prepare("SELECT distinct instrument_category_name,instrument_category_code from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_getinstcatname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getinstcatname->execute;
        		while ($getinstcatname = $sth_getinstcatname->fetch) {
				$instcatname=$getinstcatname->[0];
			}
			$sth_checka = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$instClass' and instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checka->execute;
        		while ($checka = $sth_checka->fetch) {
				if ($checka->[0] != 0) {
					
					print "<OPTION value=\"$getinstcat->[0]\" selected>$getinstcat->[0]: $instcatname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT>\n";
		print "<td><SELECT name=\"instCat\" size=6 multiple>\n";
		$sth_getinstcat = $dbh->prepare("SELECT distinct $archivedb.$instrclasstoinstrcattab.instrument_category_code from $archivedb.$instrclasstoinstrcattab order by $archivedb.$instrclasstoinstrcattab.instrument_category_code");
		if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcat->execute;
        	while ($getinstcat = $sth_getinstcat->fetch) {
			$instcatname="";
			$sth_getinstcatname = $dbh->prepare("SELECT distinct instrument_category_name,instrument_category_code from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_getinstcatname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getinstcatname->execute;
        		while ($getinstcatname = $sth_getinstcatname->fetch) {
				$instcatname=$getinstcatname->[0];
			}
			$sth_getcurinstcat = $dbh->prepare("SELECT count(*) from instCats where IDNo=$IDNo and inst_category_code='$getinstcat->[0]' and statusFlag=0");
			if (!defined $sth_getcurinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getcurinstcat->execute;
        		while ($getcurinstcat = $sth_getcurinstcat->fetch) {
				if ($getcurinstcat->[0] == 0) {
					print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getinstcat->[0]\" selected>$getinstcat->[0]: $instcatname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT></tr>\n";
		print "</table>\n";	
	} else {
		print "<strong>INSTRUMENT CATEGORY(IES)</strong>:<br />\n";
		print "<SELECT name=\"instCat\" size=6 multiple>\n";
		$sth_getinstcat = $dbh->prepare("SELECT distinct $archivedb.$instrclasstoinstrcattab.instrument_category_code from $archivedb.$instrclasstoinstrcattab order by $archivedb.$instrclasstoinstrcattab.instrument_category_code");
		if (!defined $sth_getinstcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstcat->execute;
        	while ($getinstcat = $sth_getinstcat->fetch) {
			$instcatname="";
			$sth_checkcat = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$instClass' and instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_checkcat) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checkcat->execute;
        		while ($checkcat = $sth_checkcat->fetch) {
				$sth_getinstcatname = $dbh->prepare("SELECT distinct instrument_category_name,instrument_category_code from $archivedb.$instrcatdetailstab WHERE instrument_category_code='$getinstcat->[0]'");
				if (!defined $sth_getinstcatname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getinstcatname->execute;
        			while ($getinstcatname = $sth_getinstcatname->fetch) {
					$instcatname=$getinstcatname->[0];
				}
			}
			$sth_checka = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstoinstrcattab WHERE instrument_class_code='$instClass' and instrument_category_code='$getinstcat->[0]'");
			if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checka->execute;
        		while ($checka = $sth_checka->fetch) {
				if ($checka->[0] == 0) {
					print "<OPTION value=\"$getinstcat->[0]\">$getinstcat->[0]: $instcatname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getinstcat->[0]\" selected>$getinstcat->[0]: $instcatname</OPTION>\n";
				}
			}
		}
		print "</SELECT>\n";
	}
#############################################
	print "<p>\n";
	if ($IDNo ne "") {
		print "<table>\n";
		print "<th colspan=2><strong>SOURCE CLASS(ES)</strong>:</th>\n";
		print "<tr><td>Current Associations in ARM_int</td><td>Proposed Additions</td></tr>\n";
		print "<tr><td><SELECT name=\"sourceClass\" size=6 multiple>\n";
		$sth_getsourceclasses = $dbh->prepare("SELECT distinct source_class_code,source_class_name from $archivedb.$sourceclassdetails order by source_class_code");
		if (!defined $sth_getsourceclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclasses->execute;
        	while ($getsourceclasses = $sth_getsourceclasses->fetch) {
			$scname=$getsourceclasses->[1];
			$sth_getcursource = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstosourceclass where source_class_code='$getsourceclasses->[0]' and instrument_class_code='$instClass'");
			if (!defined $sth_getcursource) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getcursource->execute;
        		while ($getcursource = $sth_getcursource->fetch) {
				if ($getcursource->[0] == 0) {
					print "<OPTION value=\"$getsourceclasses->[0]\">$getsourceclasses->[0]: $scname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getsourceclasses->[0]\" selected>$getsourceclasses->[0]: $scname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT>\n";
		print "<td><SELECT name=\"sourceClass\" size=6 multiple>\n";
		$sth_getsourceclass = $dbh->prepare("SELECT distinct $archivedb.$sourceclassdetails.source_class_code,$archivedb.$sourceclassdetails.source_class_name from $archivedb.$sourceclassdetails order by $archivedb.$sourceclassdetails.source_class_code");
		if (!defined $sth_getsourceclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclass->execute;
        	while ($getsourceclass = $sth_getsourceclass->fetch) {
			$scname=$getsourceclass->[1];
			$sth_getcursource = $dbh->prepare("SELECT count(*) from sourceClass where IDNo=$IDNo and source_class='$getsourceclass->[0]' and statusFlag=0");
			if (!defined $sth_getcursource) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getcursource->execute;
        		while ($getcursource = $sth_getcursource->fetch) {
				if ($getcursource->[0] == 0) {
					print "<OPTION value=\"$getsourceclass->[0]\">$getsourceclass->[0]: $scname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getsourceclass->[0]\" selected>$getsourceclass->[0]: $scname</OPTION>\n";
				}
			}
		}
		print "</td>\n";
		print "</SELECT></tr>\n";
		print "</table>\n";	
	} else {
		print "<strong>SOURCE CLASS(ES)</strong>:<br />\n";
		print "<SELECT name=\"sourceClass\" size=6 multiple>\n";
		$sth_getsourceclass = $dbh->prepare("SELECT distinct $archivedb.$sourceclassdetails.source_class_code,$archivedb.$sourceclassdetails.source_class_name from $archivedb.$sourceclassdetails order by $archivedb.$sourceclassdetails.source_class_code");
		if (!defined $sth_getsourceclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclass->execute;
        	while ($getsourceclass = $sth_getsourceclass->fetch) {
			$scname=$getsourceclass->[1];
			$sth_checka = $dbh->prepare("SELECT count(*) from $archivedb.$instrclasstosourceclass WHERE source_class_code='$getsourceclass->[0]' and instrument_class_code='$instClass'");
			if (!defined $sth_checka) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_checka->execute;
        		while ($checka = $sth_checka->fetch) {
				if ($checka->[0] == 0) {
					print "<OPTION value=\"$getsourceclass->[0]\">$getsourceclass->[0]: $scname</OPTION>\n";
				} else {
					print "<OPTION value=\"$getsourceclass->[0]\" selected>$getsourceclass->[0]: $scname</OPTION>\n";
				}
			}
		}
	}
	print "</SELECT><p>\n";
	$objcttype="entry";
	if ($IDNo ne "") {
		$objcttype="update";
	}
	print "<input type=\"hidden\" name=\"objcttype\" value=\"$objcttype\">\n";
	print " <input type=\"submit\" name=\"submit\" value=\"Submit\"> <input type=\"submit\" name=\"submit\" value=\"Reset\"><br>\n";
	print "<hr>\n";
	print "</form>\n";
	&bottomlinks($IDNo,"I");
	print "</div>\n";
	print "</BODY></HTML>\n";
	$dbh->disconnect();
	exit;
}
$dbh->disconnect();
