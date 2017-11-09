#!/usr/bin/perl 

use CGI qw(:cgi-lib);
ReadParse();
use DBI;
use PGMMT_lib;
use Time::Local;
use JSON;
use POSIX qw(strftime);
my $VROOT=$ENV{'VROOT'};
my $remote_user=$ENV{'REMOTE_USER'};
my $query = new CGI;
$query->charset('UTF-8');
my $json = new JSON();
my $user = &get_user;
my $password= &get_pwd;
my $peopletab = &get_peopletab;
my $grouprole = &get_grouprole;
my $statustab = &get_statustab; 
my $dbname = &get_dbname;
my $archivedb = &get_archivedb;
my $webserver=&get_webserver;
my $dbserver = &get_dbserver;
my $pmcodetoinstrclass=&get_pmcodetoinstrclass; #user table
my $instrclasstosourceclass=&get_instrclasstosourceclass; #user table
my $dsinfotab = &get_dsinfotab; #user table
my $instrcodedetailstab = &get_instrcodedetailstab; #user table
my $siteinfotab = &get_siteinfotab; #user table
my $facinfotab = &get_facsinfo;  #user table
my $instrclassdetailstab = &get_instrclassdetailstab; #user table
my $instrcodetoinstrclasstab = &get_instrcodetoinstrclasstab; #user table

my $sub_date = strftime('%Y%m%d%H%M', localtime());
my $subyr=substr($sub_date,0,4);
my $submon=substr($sub_date,4,2);
my $subday=substr($sub_date,6,2);
my $subhour=substr($sub_date,8,2);
my $submin=substr($sub_date,10,2);
my $submitDate="$submon"."/"."$subday"."/"."$subyr"." "."$subhour".":"."$submin";

$IDNo=$in{IDNo};
$dsBase=$in{dsBase};
$dsBaseDesc=$in{dsBaseDesc};
$dataLevel=$in{dataLevel};
$type=$in{type};
$DODver=$in{DODver};
$sites=$in{sites};
$psites=$in{psites};
$instClass=$in{instClass};
$submit=$in{submit};
$instClassName=$in{instClassName};
$sources=$in{sources};
$dVol=$in{dVol};
$iseval=$in{iseval};
$deaddate=$in{deaddate};
$comment=$in{comment};
@sourceclassarray=();
@instclassarray=();
@sitesarray=();
@psitesarray=();

# here is the access to the MMT database
my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
my $userid = $user;
my $password=$password;
my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr; 

#*******************************************************************************
if ($submit eq "RESET FORM") {
	$instClass="";
	$instClassName="";
	if ($IDNo eq "") {
		$dsBase="";
		$dataLevel="";
		$DODver="";
		$dsBaseDesc="";
		$dVol="";
		$iseval="";
		$deaddate="";
	}
	$sources="";
	$comment="";
}

if (($IDNo ne "") && ($submit ne "Submit for DOD Review")) {
	$sth_getDOD=$dbh->prepare("SELECT dsBase,dataLevel,DODversion,dsBaseDesc,dVol,iseval,deaddate from DOD where IDNo=$IDNo");
	if (!defined $sth_getDOD) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getDOD->execute;
        while ($getDOD = $sth_getDOD->fetch) {
		$dsBase=$getDOD->[0];
		$dataLevel=$getDOD->[1];
		$DODver=$getDOD->[2];
		$dsBaseDesc=$getDOD->[3];
		$dVol=$getDOD->[4];
		$iseval=$getDOD->[5];
		$deaddate=$getDOD->[6];
	}
	if ($submit ne "RESET INSTRUMENT CLASS") {
		$instClass="";
		$instClassName="";
		$sth_getinstclass = $dbh->prepare("SELECT distinct instrument_class,instrument_class_name from instClass where IDNo=$IDNo");
		if (!defined $sth_getinstclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_getinstclass->execute;
        	while ($getinstclass = $sth_getinstclass->fetch) {
			$instClass=$getinstclass->[0];
			$instClassName=$getinstclass->[1];
		}
		$countsc=0;
		@sourceclassarray=();
		$sth_getsourceclass = $dbh->prepare("SELECT distinct source_class,source_class from sourceClass where IDNo=$IDNo");
		if (!defined $sth_getsourceclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclass->execute;
        	while ($getsourceclass = $sth_getsourceclass->fetch) {
			$sourceclassarray[$countsc]=$getsourceclass->[0];
			$countsc = $countsc + 1;
		}
	} else {
		$instClass="";
		$instClassName="";
		@sourceclassarray=();
		$sources="";
	}
}

if (($dsBase ne "") && ($dataLevel ne "") && ($DODver ne "") && ($submit ne "Submit for DOD Review")) {
	$submit = "Get DOD Versions";
}
print $query->header;
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n";
print "<head>\n";
print "<title>MMT: DOD Review</title>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/arm_adv.css\"; --></style>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/fc.css\"; --></style>\n";
print "<style type=\"text/css\" media=\"all\">\n";
print "#content {margin-right:0;background-image: none;}\n";
print "</style>\n";
print '<style type="text/css">
table,th,td {
	border:1px solid black;
	cellspacing:10px;
}
</style>
';
print '<style type="text/css">
P {text-indent: 30pt;
}
</style>
';
print '<style type="text/css">
p {text-indent: 0pt;
}
</style>
';
print "</head>\n";
print '<body class=\"iops\">';
print '<div id="content">';
print "<form method=\"post\" name=\"MMT\" action=\"DOD.pl\" enctype=\"multipart/form-data\">\n";
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
	$dbh->disconnect();
	exit;
}
&toplinks($user_id,$user_first,$user_last,"DOD");
$now=&getnow;
print "<hr>\n";
if (($submit eq "RESET INSTRUMENT CLASS") || ($submit eq "RESET FORM")) {
	if ($IDNo eq "") {
		$dsBase="";
		$dataLevel="";
		$dsBaseDesc="";
		$dVol="";
		$iseval="";
		$deaddate="";
	}
	$instClass="";
	$instClassName="";
	$sources="";
	$DODver="";
}

if (($dsBase eq "") || ($submit eq "RESET INSTRUMENT CLASS") || ($submit eq "RESET FORM")) {
	print "<strong>Submit a DOD to MMT Review Process</strong><p>\n";
	if ($IDNo ne "") {
		$sth_getDODdetails = $dbh->prepare("SELECT dsBase,dataLevel,submitter,DODversion,statusFlag,dsBaseDesc,dVol,iseval,deaddate from DOD where IDNo=$IDNo");
		if (!defined $sth_getDODdetails) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_getDODdetails->execute;
        	while ($getDODdetails = $sth_getDODdetails->fetch) {
			$dsBase=$getDODdetails->[0];
			$dataLevel=$getDODdetails->[1];
			$submitter=$getDODdetails->[2];
			$DODver=$getDODdetails->[3];
			$Bstat=$getDODdetails->[4];
			$dsBaseDesc=$getDODdetails->[5];
			$dVol=$getDODdetails->[6];
			$iseval=$getDODdetails->[7];
			$deaddate=$getDODdetails->[8];
			
		}
	} else {
		$IDNo="";
	}
	if (($submit ne "RESET INSTRUMENT CLASS") && ($submit ne "RESET FORM")) {
		if ($in{dsBase} ne "") {
			$dsBase=$in{dsBase};
		} 
		if ($in{dataLevel} ne "") {
			$dataLevel=$in{dataLevel};
		}
		if ($in{DODver} ne "") {
			$DODver=$in{DODver};
		}
		if ($in{dsBaseDesc} ne "") {
			$dsBaseDesc=$in{dsBaseDesc};
		}
		if ($in{dVol} ne "") {
			$dVol=$in{dVol};
		}
		if ($in{comment} ne "") {
			$comment=$in{comment};
		}
		if ($in{iseval} ne "") {
			$iseval=$in{iseval};
		}
		if ($in{deaddate} ne "") {
			$deaddate=$in{deaddate};
		}
		# need to know how sites will be fed to this code - may require changes below
		if ($in{sites} ne ""){
			if ($sites =~ ",") {
				@sitesarray=split(/\,/,$in{sites});
			} else {
				@sitesarray=split(/\0/,$in{sites});
			}
			@sortsitesarray=sort @sitesarray;
			@sitesarray=();
			@sitesarray=@sortsitesarray;
		} else {
			if ($in{sitesarray} ne "") {
				@sitesarray=$in{@sitesarray};
			} else {
				$sitesarray[0]="";
			}
		}
		if ($in{psites} ne ""){
			if ($psites =~ ",") {
				@psitesarray=split(/\,/,$in{psites});
			} else {
				@psitesarray=split(/\0/,$in{psites});
			}
			@sortpsitesarray=sort @psitesarray;
			@psitesarray=();
			@psitesarray=@sortpsitesarray;
		} else {
			if ($in{psitesarray} ne "") {
				@psitesarray=$in{@psitesarray};
			} else {
				$psitesarray[0]="";
			}
		}
		if ($in{instClass} ne "") {
			$instClass=$in{instClass};
		}
		if ($in{process} ne "") {
			$process=$in{process};
		}
		if ($in{sources} ne "") {
			@sourceclassarray=split(/\0/,$in{sources});
			@sortsourceclassarray=sort @sourceclassarray;
			@sourceclassarray=();
			@sourceclassarray=@sortsourceclassarray;
		} else {
			if ($in{sourceclassarray} ne "") {
				@sourceclassarray=$in{@sourceclassarray};
			} else {
				$sourceclassarray[0]="";
			}
		}
		if ($submit eq "Get DOD Versions") {
			if (($dsBase ne "") && ($dataLevel ne "")) {
				$type=$submit;
			} else {
				$type="";
			}
			$submit="REV DOD";
		}
		$numofsites=@sitesarray;
		$numofpsites=@psitesarray;
		$numofsources=@sourceclassarray;
		$countsite=0;
		$countpsite=0;
		$countsc=0;
	}
}
if ($submit eq "Submit for DOD Review") {
	if (($dsBase eq "") || ($DODver eq "") || ($dataLevel eq "") || ($instClass eq "") || ($dsBaseDesc eq "") || ($dVol eq "") || ($iseval eq ""))  {
		print "Instrument Code\.Data Level, DOD version, datastream description, instrument class, data volume and whether Evaluation process answers are all required fields. Please go back with your browser and fill in this information.<br /><br />\n";
		print "Instrument Code: $dsBase<br>\n";
		print "Data Level: $dataLevel<br>\n";
		print "DODver: $DODver<br>\n";
		print "Datastream Description: $dsBaseDesc<br>\n";
		@tmpcl=();
		@tmpcl=split(/ /,$instClass);
		print "Instrument Class: $tmpcl[0]<br>\n";
		print "Data Volume: $dVol<br><br>\n";
		print "Is this Evaluation?: $iseval<br><br>\n";
		print "<hr align=\"left\" size=\"1\" />\n";
		print '</div>';
		$dbh->disconnect();
		exit;
	}
	$countmatch=0;
	if ($in{sites} ne "") {
		@sitesarray=split(/\0/,$in{sites});
		@sortsitesarray=sort @sitesarray;
		@sitesarray=();
		@sitesarray=@sortsitesarray;
	} else {
		if ($in{sitesarray} ne "") {
			@sitesarray=split(/ /,$in{sitesarray});
		} else {
			$sitesarray[0]="";
		}
	}
	if ($in{psites} ne "") {
		@psitesarray=split(/\0/,$in{psites});
		@sortpsitesarray=sort @psitesarray;
		@pitesarray=();
		@psitesarray=@sortpsitesarray;
	} else {
		if ($in{psitesarray} ne "") {
			@psitesarray=split(/ /,$in{psitesarray});
		} else {
			$psitesarray[0]="";
		}
	}
	if ($in{sources} ne "") {
		@sourceclassarray=split(/\0/,$in{sources});
		@sortsourceclassarray=sort @sourceclassarray;
		@sourceclassarray=();
		@sourceclassarray=@sortsourceclassarray;
	} else {
		if ($in{sourceclassarray} ne "") {
			@sourceclassarray=split(/ /,$in{sourceclassarray});
		} else {
			$sourceclassarray[0]="";
		}
	}
	$numofsites=0;
	$numofsites=@sitesarray;
	$numofpsites=0;
	$numofpsites=@psitesarray;
	$numofsources=0;
	$numofsources=@sourceclassarray;
	if ($numofsites > 0) {
		print "<INPUT TYPE=\"HIDDEN\" NAME=\"sites\" value=\"@sitesarray\" />\n";
	} else {
		print "<INPUT TYPE=\"HIDDEN\" NAME=\"sites\" value=\"\" />\n";
	}
	if ($numofpsites > 0) {
		print "<INPUT TYPE=\"HIDDEN\" NAME=\"psites\" value=\"@psitesarray\" />\n";
	} else {
		print "<INPUT TYPE=\"HIDDEN\" NAME=\"psites\" value=\"\" />\n";
	}
	if ($numofsources > 0) {
		print "<INPUT TYPE=\"HIDDEN\" NAME=\"sources\" value=\"@sourceclassarray\" />\n";
	} else {
		print "<INPUT TYPE=\"HIDDEN\" NAME=\"sources\" value=\"\" />\n";
	}
	if ($IDNo ne "") {
		print "<input type=\"HIDDEN\" NAME=\"IDNo\" value=\"$IDNo\" />\n";
	}
	if ($dsBase ne "") {
		print "<input type=\"HIDDEN\" NAME=\"dsBase\" value=\"$dsBase\" />\n";
	}
	if ($dsBaseDesc ne "") {
		print "<input type=\"HIDDEN\" NAME=\"dsBaseDesc\" value=\"$dsBaseDesc\" />\n";
	}
	if ($dataLevel ne "") {
		print "<input type=\"HIDDEN\" NAME=\"dataLevel\" value=\"$dataLevel\" />\n";
	}
	if ($DODver ne "") {
		print "<input type=\"HIDDEN\" NAME=\"DODver\" value=\"$DODver\" />\n";
	}
	if ($dVol ne "") {
		print "<input type=\"HIDDEN\" NAME=\"dVol\" value=\"$dVol\" />\n";
	}
	if ($iseval ne "") {
		print "<input type=\"HIDDEN\" NAME=\"iseval\" value=\"$iseval\" />\n";
	}
	if ($deaddate ne "") {
		print "<input type=\"HIDDEN\" NAME=\"deaddate\" value=\"$deaddate\" />\n";
	}

	if ($comment ne "") {
		print "<input type=\"HIDDEN\" NAME=\"comment\" value=\"$comment\" />\n";
	}
	if ($instClass ne "") {
		print "<input type=\"HIDDEN\" NAME=\"instClass\" value=\"$instClass\" />\n";
	}
	$emailaddr="";
	$firstName="";
	$lastName="";
	$sth_getemail = $dbh->prepare("SELECT DISTINCT name_first,name_last,email,person_id FROM $peopletab WHERE person_id=$user_id");
	if (!defined $sth_getemail) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getemail->execute;
        while ($getemail = $sth_getemail->fetch) {
		$firstName=$getemail->[0];
		$lastName=$getemail->[1];
		$emailaddr=$getemail->[2];
	}
	$newdsBase="";
	$newdsBase="\'$dsBase\'";
	$newdsBaseDesc="";
	$newdsBaseDesc="\'$dsBaseDesc\'";
	$newdataLevel="";
	$newdataLevel="\'$dataLevel\'";
	$newDODver="";
	$newDODver="\'$DODver\'";
	$newdVol="";
	$newdVol="\'$dVol\'";
	if ($iseval ne "") {
		if ($iseval =~ "'") {
			$newiseval=$iseval;
		} else {
			$newiseval="\'$iseval\'";
		}
	} else {
		$newiseval="NULL";
	}
	if ($deaddate ne "") {
		if ($deaddate =~ "'") {
			$newdeaddate=$deaddate;
		} else {
			$newdeaddate="\'$deaddate\'";
		}
	} else {
		$newdeaddate="NULL";
	}
	$REVstat=0;
	# need to figure out appropriate DB stat for below - set to 0 for now.....
	if ($in{DBstat} ne "") {
		$DBstat=$in{DBstat};
	} else {
		$DBstat=0;
	}
	$type="DOD";
	$now=&getnow;
	$new=1;
	if ($IDNo eq "") {
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
		$doStatus = $dbh->do("INSERT INTO DOD (IDNo,submitter,submitDate,dsBase,dataLevel,DODversion,statusFlag,dsBaseDesc,dVol,iseval,deaddate) values ($IDNo,$user_id,'$now',$newdsBase,$newdataLevel,$newDODver,$DBstat,$newdsBaseDesc,$newdVol,$newiseval,$newdeaddate)");
		if ( ! defined $doStatus ) {
			print "<hr />\n";
			print "An error has occurred during entry (DOD table). <br>\n";
			print "Please check your input and try again<br />\n";
			$dbh->disconnect();
			exit;
		}

	} else {
		$doStatus = $dbh->do("UPDATE DOD set dsBase=$newdsBase,dataLevel=$newdataLevel,DODversion=$newDODver,statusFlag=$DBstat,dsBaseDesc=$newdsBaseDesc,dVol=$newdVol,iseval=$newiseval,deaddate=$newdeaddate WHERE IDNo=$IDNo");
		$new=0;
	}
	# it was decided on 2/8/2012 that it would not necessary to track facilities in DOD review 
	# commented out the below code section	
	# on 2/28/2012 we decided we WOULD track facilities in the DOD review afterall so I uncommented the below section
	# each sitesarray record will have site:facilitycode
	# since end_date is optional, need to check for null and define accordingly
	# also on 2/28/2012 we decided to include selection of an instrument class at this point
	# 05/17/2012  need to also get the source classes associated with the instrument class!
	# on 8/30/2013 we also added a data volume question and required the datastream class description (removed from DS table)
	@sfarray=();
	if ($IDNo ne "") {
		$doStatus = $dbh->do("DELETE from facilities where IDNo=$IDNo");
		foreach $s (@sitesarray) {
			@sfarray=split(/:/,$s);
			$sth_getfname = $dbh->prepare("SELECT distinct facility_name,eff_date,end_date from $archivedb.$facinfotab where upper(site_code)='$sfarray[0]' and facility_code='$sfarray[1]'");
			if (!defined $sth_getfname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getfname->execute;
        		while ($getfname = $sth_getfname->fetch) {
				$edate="";
				if ($getfname->[2] eq "") {
					$edate="NULL";
				} else {
					$edate="\'"."$getfname->[2]"."\'";
				}
				$statflag=1;
				$doStatus = $dbh->do("INSERT INTO facilities(IDNo,submitter,site,facility_code,facility_name,eff_date,end_date,statusFlag) values ($IDNo,$user_id,'$sfarray[0]','$sfarray[1]','$getfname->[0]','$getfname->[1]',$edate,$statflag)");
				if ( ! defined $doStatus ) {
					print "<hr />\n";
					print "An error has occurred during entry in facilities Table. Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
			}
		}
		foreach $ps (@psitesarray) {
			@psfarray=split(/:/,$ps);
			$match=0;
			$sth_getfcount = $dbh->prepare("SELECT count(*) from facilities where upper(site)='$psfarray[0]' and upper(facility_code)='$psfarray[1]' and IDNo=$IDNo");
			if (!defined $sth_getfcount) { die "Cannot prepare statement: $DBI::errstr\n"; }
       			$sth_getfcount->execute;
       			while ($getfcount = $sth_getfcount->fetch) {
				$match=$getfcount->[0];
			}
			if ($match == 0) {
				$sth_getfname=$dbh->prepare("SELECT distinct facility_code,facility_name,eff_date,end_date,statusFlag from facilities where upper(site)='$psfarray[0]' and upper(facility_code)='$psfarray[1]'");
				if (!defined $sth_getfname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getfname->execute;
        			while ($getfname = $sth_getfname->fetch) {
					if ($getfname->[2] eq "") {
						$edate="NULL";
					} else {
						$edate="\'"."$getfname->[2]"."\'";
					}
					# need to check if the site/fac currently associated with this DOD - if not, the statusflag should be 0!!!}
					$statflag=$getfname->[4];
					$doStatus = $dbh->do("INSERT INTO facilities(IDNo,submitter,site,facility_code,facility_name,eff_date,end_date,statusFlag) values ($IDNo,$user_id,'$psfarray[0]','$psfarray[1]','$getfname->[1]','$getfname->[2]',$edate,$statflag)");
					if ( ! defined $doStatus ) {
						print "<hr />\n";
						print "An error has occurred during entry in facilities Table. Please try again<br />\n";#
						$dbh->disconnect();
						exit;
					}
				}
			}
		}

		# insert a record into instClass table for the instClass selected/defined
		# need to figure out the statusFlag (0 if a new one defined, 0 if a proposed one defined, 
		# 1 if an existing is selected	
		@instclassarray=();
		$stfl=0;
		$sstfl=0;
		@instclassarray=split(" ",$instClass);
		$instClass=$instclassarray[0];
		$instClassName="";
		$sourceClassName="";
		$sth_countinsts = $dbh->prepare("SELECT count(*) from $archivedb.$instrclassdetailstab where lower(instrument_class_code)='$instClass'");
		if (!defined $sth_countinsts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_countinsts->execute;
        	while ($countinsts = $sth_countinsts->fetch) {
			$stfl=$countinsts->[0];
		}
		if ($stfl > 0) {
			$stfl=1; # this instrument class exists at the archive
		};
		$sth_countsourceclasses=$dbh->prepare("SELECT count(*) from $archivedb.$instrclasstosourceclass where lower(instrument_class_code)='$instClass'");
		if (!defined $sth_countsourceclasses) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_countsourceclasses->execute;
       	 	while ($countsourceclasses = $sth_countsourceclasses->fetch) {
			$sstfl=$countsourceclasses->[0];
		}
		
		if ($sstfl > 0) {
			$sstfl=1; # there is an instrument class to source class match at the archive
		}
		if ($stfl == 1) {
			$sth_getinstclname = $dbh->prepare("SELECT instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab where lower(instrument_class_code)=lower('$instClass')");
		} else {
			$sth_getinstclname = $dbh->prepare("SELECT instrument_class,instrument_class_name from instClass where lower(instrument_class)=lower('$instClass')");
		}
		if ($sstfl == 1) {
			$sth_getsourceclname = $dbh->prepare("SELECT instrument_class_code,source_class_code from $archivedb.$instrclasstosourceclass where lower(instrument_class_code)=lower('$instClass')");
		} else {
			$sth_getsourceclname= $dbh->prepare("SELECT distinct sourceClass.IDNo,source_class from sourceClass,instClass where sourceClass.IDNo=instClass.IDNo and lower(instClass.instrument_class)=lower('$instClass')");
		}
		if (!defined $sth_getinstclname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getinstclname->execute;
        	while ($getinstclname = $sth_getinstclname->fetch) {
			$instClassName=$getinstclname->[1];
		}
		$countsc=0;
		@sourceClassName=();
		if (!defined $sth_getsourceclname) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsourceclname->execute;
        	while ($getsourceclname = $sth_getsourceclname->fetch) {
			$sourceClassName[$countsc]=$getsourceclname->[1];
			$countsc = $countsc + 1;
		}
		$doStatus = $dbh->do("DELETE from instClass where IDNo=$IDNo");
		$doStatus = $dbh->do("INSERT into instClass (IDNo,submitter,instrument_class,instrument_class_name,statusFlag) values ($IDNo,$user_id,'$instClass','$instClassName',$stfl)");
		if ( ! defined $doStatus) {
			print "<hr />\n";
			print "An error has occurred during entry (instClass table - instClass $instClass). Please try again<br />\n";
			$dbh->disconnect();
			exit;
		}
		$doStatus = $dbh->do("DELETE from sourceClass where IDNo=$IDNo");
		$countforcontactsc=0;
		$doit=0;
		$oldsc="";
		foreach $scl (@sourceClassName) {
			if ($scl ne $oldsc) {
				$doStatus = $dbh->do("INSERT into sourceClass (IDNo,submitter,source_class,statusFlag) values ($IDNo,$user_id,'$scl',$stfl)");
				if ( ! defined $doStatus) {
					print "<hr />\n";
					print "An error has occurred during entry (sourceClass table - sourceClass $scl). Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
				# need to check whether group role has any contacts for this instrument class/source class in people db	
				####################
				if ($scl eq "armderiv") {
					$countforcontactsc = $countforcontactsc + 1;
					$armderdev=0;
					$armdertrans=0;
					$sth_checkmincontacts=$dbh->prepare("SELECT distinct group_name,role_name,subrole_name from $grouprole where group_name='VAP Contact' and upper(role_name)=upper('$instClass') and (subrole_name = 'Developer' or subrole_name = 'Translator')");
					if (!defined $sth_checkmincontacts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_checkmincontacts->execute;
        				while ($checkmincontacts = $sth_checkmincontacts->fetch) {
						if ($checkmincontacts->[2] eq "Translator") {
							$armdertrans = $armdertrans + 1;
						}
						if ($checkmincontacts->[2] eq "Developer") {
							$armderdev=$armderdev + 1;
						}
					}
					# if armderdev = 0 or armdertrans = 0, now need to check instContacts table in MMT in case they are under review
					if (($armderdev == 0) || ($armdertrans == 0)) {
						$sth_checkmincontacts=$dbh->prepare("SELECT distinct group_name,role_name,subrole_name from instContacts where group_name='VAP Contact' and upper(role_name)=upper('$instClass') and (subrole_name = 'Developer' or subrole_name = 'Translator')");
						if (!defined $sth_checkmincontacts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        					$sth_checkmincontacts->execute;
        					while ($checkmincontacts = $sth_checkmincontacts->fetch) {
							if ($checkmincontacts->[2] eq "Translator") {
								$armdertrans = $armdertrans + 1;
							}
							if ($checkmincontacts->[2] eq "Developer") {
								$armderdev=$armderdev + 1;
							}
						}
					
					}
					$displaymessage="";
					if (($armderdev >=1) || ($armdertrans >=1)) {
						$doit = $doit + 1;	
					}
					if ($armderdev == 0) {
						$displaymessage="$displaymessage"."<br>No Developer contacts have been entered yet for this VAP";
					}	
				}
		 		######################
				if ($scl eq "armobs") {
					$countforcontactsc = $countforcontactsc + 1;
					$armobsdev=0;
					$armobsment=0;
					$sth_checkmincontacts=$dbh->prepare("SELECT distinct group_name,role_name,subrole_name from $grouprole where (group_name='Inst. Mentor' or group_name='Instrument Contact') and upper(role_name)=upper('$instClass') and (subrole_name is null or subrole_name = 'Developer')");
					if (!defined $sth_checkmincontacts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_checkmincontacts->execute;
        				while ($checkmincontacts = $sth_checkmincontacts->fetch) {
						if ($checkmincontacts->[2] eq "") {
							$armobsment = $armobsment + 1;
						}
						if ($checkmincontacts->[2] eq "Developer") {
							$armobsdev=$armobsdev + 1;
						}
					}
					# if armobsdev = 0 or armobsment = 0, now need to check instContacts table in MMT  in case they are under review
					if (($armobsdev == 0) || ($armobsment == 0)) {
						$sth_checkmincontacts=$dbh->prepare("SELECT distinct group_name,role_name,subrole_name from instContacts where (group_name='Inst. Mentor' or group_name='Instrument Contact') and upper(role_name)=upper('$instClass') and (subrole_name is null or subrole_name = 'Developer')");
						if (!defined $sth_checkmincontacts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        					$sth_checkmincontacts->execute;
        					while ($checkmincontacts = $sth_checkmincontacts->fetch) {
							if ($checkmincontacts->[2] eq "") {
								$armobsment = $armobsment + 1;
							}
							if ($checkmincontacts->[2] eq "Developer") {
								$armobsdev=$armobsdev + 1;
							}
						}
					}
					$displaymessage="";
					if (($armobsdev >= 1) || ($armobsment >= 1)) {
						$doit = $doit + 1;
					}
					if ($armobsdev == 0) {
						$displaymessage="$displaymessage"."<br>No Developer contacts have been entered yet for the instrument class you selected";
					}			
				}
				#####################
				if (($scl eq "extderiv") || ($scl eq "extobs")) {
					$countforcontactsc = $countforcontactsc + 1;
					$extcontact=0;
					$sth_checkmincontacts=$dbh->prepare("SELECT count(*),count(*) from $grouprole where group_name='XDS Contact' and upper(role_name)=upper('$instClass')");
					if (!defined $sth_checkmincontacts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_checkmincontacts->execute;
        				while ($checkmincontacts = $sth_checkmincontacts->fetch) {
						$extcontact=$checkmincontacts->[0];
					}
					# if extdevelop == 0 or extcontact = 0 or exttrans = 0, now need to check instContacts table in MMT in case they are under review
					if ($extcontact == 0) {
						$sth_checkmincontacts=$dbh->prepare("SELECT count(*),count(*) from instContacts where group_name='XDS Contact' and upper(role_name)=upper('$instClass')");
						if (!defined $sth_checkmincontacts) { die "Cannot prepare statement: $DBI::errstr\n"; }
        					$sth_checkmincontacts->execute;
        					while ($checkmincontacts = $sth_checkmincontacts->fetch) {
							$extcontact=$checkmincontacts->[0];
						}
					}
					$displaymessage="";
					if ($extcontact >= 1) {
						$doit = $doit + 1;
					}
					if ($extcontact == 0) {
						$displaymessage="$displaymessage"."<br>No External contacts for the instrument class selected have been entered yet";
					}
						
				}
			}
			$oldsc=$scl;							
		}
		if ($newiseval =~ "Y") {
			$countinmmteval=0;
			$sth_countcursc = $dbh->prepare("SELECT count(*) from sourceClass,instClass where sourceClass.IDNo=instClass.IDNo and lower(instClass.instrument_class)=lower('$instClass') and source_class like '%eval%' and sourceClass.IDNo=$IDNo");
			if (!defined $sth_countcursc) { 
				die "Cannot prepare statement: $DBI::errstr\n"; 
			}
        		$sth_countcursc->execute;
       			while ($countcursc = $sth_countcursc->fetch) {
       				$countinmmteval=$countcursc->[0];
       			}
       		}
		if (($countinmmteval == 0) && ($newiseval =~ "Y")) {
			foreach $scl (@sourceClassName) {
				if ($scl eq "armderiv") {
					$doStatus = $dbh->do("INSERT into sourceClass (IDNo,submitter,source_class,statusFlag) values ($IDNo,$user_id,'evalderiv',0)");
					if ( ! defined $doStatus) {
						print "<hr />\n";
						print "An error has occurred during entry (sourceClass table - sourceClass evalderiv). Please try again<br />\n";
						$dbh->disconnect();
						exit;
					}
				} elsif ($scl eq "armobs") {
					
					$doStatus = $dbh->do("INSERT into sourceClass (IDNo,submitter,source_class,statusFlag) values ($IDNo,$user_id,'evalobs',0)");
					if ( ! defined $doStatus) {
						print "<hr />\n";
						print "An error has occurred during entry (sourceClass table - sourceClass evalobs). Please try again<br />\n";
						$dbh->disconnect();
						exit;
					}
				
				} elsif ($scl eq "extobs") {
					$doStatus = $dbh->do("INSERT into sourceClass (IDNo,submitter,source_class,statusFlag) values ($IDNo,$user_id,'evalobs',0)");
					if ( ! defined $doStatus) {
						print "<hr />\n";
						print "An error has occurred during entry (sourceClass table - sourceClass evalobs). Please try again<br />\n";
						$dbh->disconnect();
						exit;
					}				
				}
			}
		}
		# insert a review status record for all reviewers
		$revidarray=();
		$countr=0;
		$sth_getrid = $dbh->prepare("SELECT person_id,person_id from reviewers where type='$type' and person_id !=$user_id order by person_id");
		if (!defined $sth_getrid) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getrid->execute;
       		while ($getrid = $sth_getrid->fetch) {
			$revidarray[$countr]=$getrid->[0];
			$countr = $countr + 1;
		}
		$revidarray[$countr]=$user_id;
		@sortedrevidarray=();
		@sortedrevidarray=sort @revidarray;
		$oldrid="";
		foreach $srevid (@sortedrevidarray) {
			if ($oldrid ne $srevid) {
				$stflag=0;
				$sth_checkprev = $dbh->prepare("SELECT status,IDNo from reviewerStatus where IDNo=$IDNo and person_id=$srevid and statusDate=(SELECT max(statusDate) from reviewerStatus where IDNo=$IDNo and person_id=$srevid)");
				if (!defined $sth_checkprev) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_checkprev->execute;
        			while ($checkprev = $sth_checkprev->fetch) {
					$stflag=$checkprev->[0];
				}
				$doStatus = $dbh->do("INSERT into reviewerStatus (IDNo,person_id,status,statusDate) values ($IDNo,$srevid,$stflag,'$now')");
				if ( ! defined $doStatus) {
					print "<hr />\n";
					print "An error has occurred during entry (reviewerStatus table). Please try again<br />\n";
					$dbh->disconnect();
					exit;
				}
				$oldrid=$srevid;
			}
		}
		if ($comment ne "") {
			$tcomment="";
			$_=$comment;
			s/'/''/g;
			$tcomment=$_;
			$doStatus = $dbh->do("INSERT INTO comments (IDNo,commentDate,person_id,comment) values ($IDNo,'$now',$user_id,'$tcomment')");
			if ( ! defined $doStatus ) {
				print "<hr />\n";
				print "An error has occurred during entry (DOD table). <br>\n";
				print "Please check your input and try again<br />\n";
				$dbh->disconnect();
				exit;
			}
		}
		$submit="DOD Submitted";
	} 
}
if ($submit eq "DOD Submitted") {
	@emailarray=();
	$emailcount=0;
	if ($new == 1) {
		print "<strong>Thank you for submitting your DOD to the MMT DOD Review process. THe following information has been submitted for your DOD:</strong><p>\n";
		
		print "<dd>Submitter: $firstName $lastName</dd>\n";
		print "<dd>Datastream Class: $dsBase\.$dataLevel</dd>\n";
		print "<dd>DOD Version: $DODver\n";
		print "<dd> </dd>\n";
		print "<dd>Datastream Class Description: $dsBaseDesc</dd>\n";
		print "<dd>Is daily data volume expected to exceed 8 GB? \n";
		if ($dVol eq "Y") {
			print "Yes</dd>\n";
			} else {
			print "No</dd>\n";
		}
		print "<dd>Do you have an urgent deadline that you are trying to meet? If yes, what is your deadline (YYYY.MM.DD)? $deaddate</dd>\n";
		print "<dd>Is the data generated from this process being released to evaluation or production? \n";
		if ($iseval =~ "Y") {
			print "Evaluation</dd>\n";
		} elsif ($iseval =~ "N") {
			print "Production</dd>\n";
		} else {
			print "</dd>\n";
		}
		
		print "<dd>Site(s)/Facility(ies): @sitesarray</dd>\n";
		print "<dd>Instrument Class: $instClass</dd><p>\n";		
		print "<strong>Email will be distributed as follows:</strong><br />\n";
	} else {
		print "<strong>Thank you for updating your DOD submission to the MMT DOD Review process.</strong><p>\n";
		print "<strong>Email will be distributed as follows:</strong><br />\n";
	}
	print "<P><strong>Submitter:</strong> ";
	$sth_getsub = $dbh->prepare("SELECT person_id,name_first,name_last,email from $peopletab where person_id=$user_id");
	if (!defined $sth_getsub) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getsub->execute;
        while ($getsub = $sth_getsub->fetch) {
		print "$getsub->[1] $getsub->[2]";
		$emailarray[$emailcount]=$getsub->[3];
		$emailcount = $emailcount + 1;
	}
	print "<p><strong>DOD Reviewer(s):</strong> ";
	$countdodg=0;
	$sth_getrevdod = $dbh->prepare("SELECT reviewers.person_id,$peopletab.name_first,$peopletab.name_last,email,reviewers.revFunction from reviewers,$peopletab where reviewers.person_id=$peopletab.person_id and reviewers.type='DOD' order by reviewers.revFunction,$peopletab.name_last");
	if (!defined $sth_getrevdod) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getrevdod->execute;
        while ($getrevdod = $sth_getrevdod->fetch) {
		print "<dd>$getrevdod->[4]: $getrevdod->[1] $getrevdod->[2]</dd>";
		$emailarray[$emailcount]=$getrevdod->[3];
		$countdodg = $countdodg + 1;
		$emailcount = $emailcount + 1;
	}
	@sortedemail = sort @emailarray;
	$oldem = "";
	foreach $em (@sortedemail) {
		if ($em ne $oldem) {
			$emsubj="";
			if ($new == 1) {
				$emsubj="Submitted for REVIEW";
			} else {
				$emsubj="Submission in MMT UPDATED";
			}
			open(MAIL,"|/home/www/DB/lib/dbmail -r \"webformadmin\@arm.gov\" -s \"MMT: DOD $emsubj: $dsBase\.$dataLevel Version: $DODver (MMT# $IDNo)\" \"$em\"");
			print MAIL "Submitter: $firstName $lastName\n";
			print MAIL "\n";
			print MAIL "Datastream Class: $dsBase\.$dataLevel\n";
			print MAIL "Datastream Class Description: $dsBaseDesc\n";
			print MAIL "DOD Version: $DODver\n";
			print MAIL "Instrument Class: $instClass\n";
			print MAIL "Deadline? $deaddate\n";
			print MAIL "Is the data generated from this process being released to evaluation or production? ";
			if ($iseval =~ "Y") {
				print MAIL "Evaluation\n";
			} elsif ($iseval =~ "N") {
				print MAIL "Production\n";
			} else {
				print MAIL "\n";
			}	
			print MAIL "\n";
			if ($comment ne "") {
				print MAIL "Submitter Comment: $comment\n\n";
			}
			print MAIL "http://$webserver/cgi-bin/MMT/admin/reviewMetaData.pl?IDNo=$IDNo\n";
			close(MAIL);
		}
		$oldem = $em;
	}
	print "<br>";
	print "<strong>You have completed the DOD metadata entry submission process required for an Ingest/VAP Developer</strong>\n";
	if ($doit == 0) {
		print " <strong>but please note:</strong>\n";
		print "<dd>$displaymessage</dd>";
		print "<p>\n";
		print "<dd><strong>You can enter a contact now using this <a href=\"Contacts.pl?procType=N&pcm=1&rolename=$instClass&source=@sourceClassName\">link</a></font></strong></dd><br>\n";
	} else {
		print "<br>\n";
	}
	print "<hr>\n";
	&bottomlinks($IDNo,"DOD");
	print "</div>\n";
	print "</form>\n";
	$dbh->disconnect();
	exit;
}
if (($dsBase eq "") || ($dataLevel eq "")) {
	if ($dsBase ne "") {
		print "<p><strong>Instrument Code: </strong><INPUT TYPE=\"text\" NAME=\"dsBase\" SIZE=\"50\" value=\"$dsBase\"> \n";
	} else {
		print "<P><strong>Instrument Code</strong><INPUT TYPE=\"text\" NAME=\"dsBase\" SIZE=\"50\" value=\"\" maxlength=25/> \n";
	}
	if ($dataLevel ne "") {
		print " <strong>Data Level: </strong><SELECT name=\"dataLevel\"><option value=\"$dataLevel\">$dataLevel</option>\n";
	} else {
		print "<strong>Data Level</strong> \n";
		print "<select NAME=\"dataLevel\"> \n";
		print "<option value=\"\"> </option>\n";
		$sth_ret = $dbh->prepare("SELECT distinct $archivedb.$dsinfotab.data_level_code,$archivedb.$dsinfotab.data_level_code FROM $archivedb.$dsinfotab order by data_level_code");
		if (!defined $sth_ret) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_ret->execute;
        	while ($ret = $sth_ret->fetch) {
			print "<option value=\"$ret->[0]\">$ret->[0]</option>\n";
		}
		print "</select>\n";
	}
	$type="";
} else {
	print "<p><strong>Instrument Code:</strong> $dsBase<br>\n";
	print "<INPUT TYPE=\"hidden\" name=\"dsBase\" value=\"$dsBase\">\n";
	print "<strong>Data Level:</strong> $dataLevel<br>\n";
	print "<INPUT TYPE=\"hidden\" name=\"dataLevel\" value=\"$dataLevel\">\n";

}
if (($IDNo eq "") && ($submit ne "Get DOD Versions")) {
	print "<input type=\"submit\" name=\"submit\" value=\"Get DOD Versions\"></dd>\n";
}
if  (($type eq "") && (($dsBase eq "") || ($dataLevel eq "")) ) {
	print "<br></div>\n";
	print "</form>\n";
	$dbh->disconnect();
	exit;
}
if ($submit eq "Get DOD Versions") {
	$exista=0;
	$existb=0;
	#first check archive
	# is this at the archive in production already?
	$sth_checkarchive=$dbh->prepare("SELECT count(*) from $archivedb.$dsinfotab where instrument_code='$dsBase' and data_level_code='$dataLevel'");
	if (!defined $sth_checkarchive) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_checkarchive->execute;
        while ($checkarchive = $sth_checkarchive->fetch) {
		$exista=$checkarchive->[0];
	}
	#is this in mmt already?
	$sth_checkMMT = $dbh->prepare("SELECT count(*),count(*) from DOD where dsBase='$dsBase' and dataLevel='$dataLevel'");
	if (!defined $sth_checkMMT) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_checkMMT->execute;
        while ($checkMMT = $sth_checkMMT->fetch) {
		$existb=$checkMMT->[0];
	}
	$sth_getName = $dbh->prepare("SELECT instrument_code,instrument_name from $archivedb.$instrcodedetailstab WHERE instrument_code='$dsBase'");
	if (!defined $sth_getName) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getName->execute;
        while ($getName = $sth_getName->fetch) {
		if ($dsBaseDesc eq "") {
			$dsBaseDesc=$getName->[1];
		}
	}
	if (($exista == 0) && ($existb == 0)) {
		# not an archive production datastream
		# not registered in MMT for DOD review yet
		print "<input type=\"hidden\" name=\"DBstat\" value=0>\n";
		print "<br><strong>DOD Version: </strong>\n";
		print "<INPUT TYPE=\"hidden\" name=\"DODver\" value=\"$DODver\">\n";
		print "v$DODver<p>\n";
		if ($dsBaseDesc eq "") {
			print "<strong><font color=red>Datastream Class Description:</font></strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		} else {
			print "<strong>Datastream Class Description:</strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"$dsBaseDesc\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		}
		if ($dVol ne "") {
			if ($dVol eq "Y") {
				print "<p><strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\" checked>Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
			} else {
				print "<p><strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\" checked>No<p>\n";
			}	
		} else {
			print "<p><strong><font color=red>Is daily data volume expected to exceed 8 GB?</font></strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
		}
		if ($deaddate ne "") {
			print "<p><strong>Do you have an urgent deadline that you are trying to meet?  If so, what is your deadline? (YYYY.MM.DD) <input type=\"text\" name=\"deaddate\" value=\"$deaddate\" size=10 maxlength=10><p>\n";
		} else {
			print "<p><strong><font color=red>Do you have an urgent deadline that you are trying to meet?  If so, what is your deadline? (YYYY.MM.DD)</font> <input type=\"text\" name=\"deaddate\" value=\"$deaddate\" size=10 maxlength=10><p>\n";
		}
		if ($iseval ne "") {
			if ($iseval =~ "Y") {
				print "<p><strong>Is the data generated from this process being released to evaluation or production?</strong> <input type=radio name=\"iseval\" value=\"Y\" checked>Evaluation <input type=radio name=\"iseval\" value=\"N\">Production<p>\n";
			} else {
				print "<p><strong>Is the data generated from this process being released to evaluation or production?</strong> <input type=radio name=\"iseval\" value=\"Y\">Evaluation <input type=radio name=\"iseval\" value=\"N\" checked>Production<p>\n";
			}	
		} else {
			print "<p><strong><font color=red>Is the data generated from this process being released to evaluation or production?</font></strong> <input type=radio name=\"iseval\" value=\"Y\">Evaluation <input type=radio name=\"iseval\" value=\"N\">Production<p>\n";
		}
		if (($sites eq "") && ($psites eq "") && ($DODver ne "")) {
			print "<strong>The DOD in PCM is non-specific as to sites:facilities.  You need to limit this review submission to specific sites:facilities to be selected below</strong><br>\n";
			print "<table>\n";
			print "<tr><td><strong>SITES:FACILITIES<br>(from arm_int)</strong></td>\n";
			print " <td><SELECT name=\"sites\" size=10 multiple>\n";
			$sth_getsites=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
			if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsites->execute;
        		while ($getsites = $sth_getsites->fetch) {	
				$match=0;
				print "<option value=\"$getsites->[0]:$getsites->[1]\">$getsites->[0]:$getsites->[1]</option>\n";
			}
			print "</SELECT></td>\n";
			$countproposed=0;
			$sth_countp = $dbh->prepare("SELECT count(*) from facilities where statusFlag < 0");
			if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_countp->execute;
        		while ($countp = $sth_countp->fetch) {
				$countproposed=$countp->[0];
			}
			if ($countproposed > 0) {
				print "</tr><tr><td><strong>PROPOSED SITES:FACILITIES<br>(in MMT for review)</strong></td>\n";
				print "<td><SELECT name=\"psites\" size=6 multiple>\n";
				$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),facility_code from facilities where statusFlag<= 0 order by site,facility_code");
				if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getpropsite->execute;
        			while ($getpropsite = $sth_getpropsite->fetch) {
					$match=0;
					$sth_getsite=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
					if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getsite->execute;
        				while ($getsite = $sth_getsite->fetch) {
						if (($getsite->[0] eq $getpropsite->[0]) && ($getsite->[3] eq $getpropsite->[1])){
							$match = 1;
						}
					}
					if ($match == 0) {
						print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\">$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
					}
				}
				print "</SELECT></td>\n";
			}
			print "</tr></table><p>\n";
						
		} else {
			if ($sites eq "") {
				print "<strong>For this DOD submission in review, you can select additional sites (or deselect sites) below</strong><br>\n";
				print "<table>\n";
				print "<tr><td><strong>SITES:FACILITIES<br>(from arm_int)</strong></td>\n";
				print " <td><SELECT name=\"sites\" size=10 multiple>\n";
				
				$sth_getsites=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
				if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getsites->execute;
        			while ($getsites = $sth_getsites->fetch) {	
					$match=0;
					foreach $sl (@sitel) {
						@sn=();
						@sn=split(/\:/,$sl);
						if (($getsites->[0] eq $sn[0]) && ($getsites->[1] eq $sn[1])) {
							$match=1;
						}
					}
					if ($match == 1) {
						print "<option value=\"$getsites->[0]:$getsites->[1]\" selected>$getsites->[0]:$getsites->[1]</option>\n";
				
					} else {
						print "<option value=\"$getsites->[0]:$getsites->[1]\">$getsites->[0]:$getsites->[1]</option>\n";
					}
				}
				print "</SELECT></td>\n";
				$countproposed=0;
				$sth_countp = $dbh->prepare("SELECT count(*) from facilities where upper(site) not in (SELECT distinct upper(site_code) from $archivedb.$siteinfotab)");
				if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_countp->execute;
        			while ($countp = $sth_countp->fetch) {
					$countproposed=$countp->[0];
				}
				if ($countproposed > 0) {
					print "</tr><tr><td><strong>PROPOSED SITES:FACILITIES<br>(in MMT for review)</strong></td>\n";
					print "<td><SELECT name=\"psites\" size=6 multiple>\n";
					$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),facility_code from facilities where statusFlag=0 order by site");
					if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getpropsite->execute;
        				while ($getpropsite = $sth_getpropsite->fetch) {
						$match=0;
						$sth_getsite=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
						if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        					$sth_getsite->execute;
        					while ($getsite = $sth_getsite->fetch) {
							if ($getsites->[0] eq $getpropsite->[0]) {
								$match = 1;
							}
						}
						if ($match == 0) {
							print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\">$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
						}
					}
				}
				print "</SELECT></td>\n";
				print "</tr></table><p>\n";
					
			} else {
				if ($DODver ne "") {
					print "<strong>The sites associated with this DOD in the PCM are pre-selected below.</strong><br>\n";
				}
				print "For this DOD submission in review, you can select additional sites (or deselect sites) as needed<br>\n";
				print "<table>\n";
				print "<tr><td><strong>SITES:FACILITIES<br>(from arm_int)</strong></td>\n";
				print " <td><SELECT name=\"sites\" size=10 multiple>\n";
				@sitesarray=();
				@sortedsitesarray=();
				@sitesarray=split(/\,/,$sites);
				@sortedsitesarray=sort @sitesarray;
				$sth_getsites=$dbh->prepare("SELECT upper(site_code),upper(facility_code) from $archivedb.$facinfotab WHERE upper(site_code) not like 'D%' order by site_code,facility_code");
				if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getsites->execute;
       				while ($getsites = $sth_getsites->fetch) {
					$match=0;
					@tempsfarray=();
					foreach $sf (@sortedsitesarray) {
						$tfa="";
						$tfc="";
						@tempsfarray=split(/-/,$sf);
						$tfa=uc $tempsfarray[0];
						$tfc=uc $tempsfarray[1];
						$tempsfarray[0]=$tfa;
						$tempsfarray[1]=$tfc;
						if (($getsites->[0] eq "$tempsfarray[0]") && ($getsites->[1] eq "$tempsfarray[1]")) {
							$match=1;
						}
					}
					if ($match == 1) {
						print "<option value=\"$getsites->[0]:$getsites->[1]\" selected>$getsites->[0]:$getsites->[1]</option>\n";
					} else {
						print "<option value=\"$getsites->[0]:$getsites->[1]\">$getsites->[0]:$getsites->[1]</option>\n";
					}
				}
				
				print "</SELECT></td>\n";
				$countproposed=0;
				$sth_countp = $dbh->prepare("SELECT count(*) from facilities where upper(site) not in (SELECT distinct upper(site_code) from $archivedb.$siteinfotab)");
				if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_countp->execute;
        			while ($countp = $sth_countp->fetch) {
					$countproposed=$countp->[0];
				}
				if ($countproposed > 0) {
					print "</tr><tr><td><strong>PROPOSED SITES:FACILITIES<br>(in MMT for review)</strong></td>\n";
					print "<td><SELECT name=\"psites\" size=6 multiple>\n";
					$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),facility_code from facilities where statusFlag=0 order by site");
					if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getpropsite->execute;
        				while ($getpropsite = $sth_getpropsite->fetch) {
						$match=0;
						$sth_getsite=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
						if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        					$sth_getsite->execute;
        					while ($getsite = $sth_getsite->fetch) {
							if ($getsites->[0] eq $getpropsite->[0]) {
								$match = 1;
							}
						}
						if ($match == 0) {
							print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\">$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
						}
					}
				}
				print "</SELECT></td>\n";
				print "</tr></table><p>\n";
			}			
		}	
	} elsif (($exista  > 0) && ($existb == 0)) {
		print "<input type=\"hidden\" name=\"DBstat\" value=1>\n";		
		print " DOD Version: <select name=\"DODver\">\n";
		print "<option value=\"$DODver\" selected>v$DODver</option>\n";
		print "</select><p>\n";
		$sth_getName = $dbh->prepare("SELECT instrument_code,instrument_name from $archivedb.$instrcodedetailstab WHERE instrument_code='$dsBase'");
		if (!defined $sth_getName) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getName->execute;
        	while ($getName = $sth_getName->fetch) {
			if ($dsBaseDesc eq "") {
				$dsBaseDesc=$getName->[1];
			}
		}
		if ($dsBaseDesc eq "") {
			print "<strong><font color=red>Datastream Class Description:</font></strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		} else {
			print "<strong>Datastream Class Description:</strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"$dsBaseDesc\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		}
		if ($dVol ne "") {
			if ($dVol eq "Y") {
				print "<strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\" checked>Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
			} else {
				print "<strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\" checked>No<p>\n";
			}	
		} else {
			print "<strong><font color=red>Is daily data volume expected to exceed 8 GB?</font></strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
		}
		
		if ($deaddate ne "") {
			print "<p><strong>Do you have an urgent deadline that you are trying to meet?  If so, what is your deadline? (YYYY.MM.DD) <input type=\"text\" name=\"deaddate\" value=\"$deaddate\" size=10 maxlength=10><p>\n";
		} else {
			print "<p><strong><font color=red>Do you have an urgent deadline that you are trying to meet?  If so, what is your deadline? (YYYY.MM.DD)</font> <input type=\"text\" name=\"deaddate\" value=\"$deaddate\" size=10 maxlength=10><p>\n";
		}
		if ($iseval ne "") {
			if ($iseval =~ "Y") {
				print "<p><strong>Is the data generated from this process being released to evaluation or production?</strong> <input type=radio name=\"iseval\" value=\"Y\" checked>Evaluation <input type=radio name=\"iseval\" value=\"N\">Production<p>\n";
			} else {
				print "<p><strong>Is the data generated from this process being released to evaluation or production?</strong> <input type=radio name=\"iseval\" value=\"Y\">Evaluation <input type=radio name=\"iseval\" value=\"N\" checked>Production<p>\n";
			}	
		} else {
			print "<p><strong><font color=red>Is the data generated from this process being released to evaluation or production?</font></strong> <input type=radio name=\"iseval\" value=\"Y\">Evaluation <input type=radio name=\"iseval\" value=\"N\">Production<p>\n";
		}
		print "<p><strong>This datastream class (instrument_code/data level code) is in the archive production metdata database.\n";
		$sth_getName = $dbh->prepare("SELECT instrument_code,instrument_name from $archivedb.$instrcodedetailstab WHERE instrument_code='$dsBase'");
		if (!defined $sth_getName) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getName->execute;
        	while ($getName = $sth_getName->fetch) {
			if ($dsBaseDesc eq "") {
				$dsBaseDesc=$getName->[1];
			}
			print "<dd>$dsBase\.$dataLevel: $getName->[1]</dd><p>\n";
		}

		print "<strong>This datastream class is currently listed as installed at the following locations:\n";
		$sts="";
		$counts=0;
		$sth_getlocs = $dbh->prepare("SELECT upper(site_code),instrument_code,facility_code,data_level_code from $archivedb.$dsinfotab WHERE instrument_code='$dsBase' and data_level_code='$dataLevel' order by site_code,facility_code");
		if (!defined $sth_getlocs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getlocs->execute;
        	while ($getlocs = $sth_getlocs->fetch) {
			$sitesarray[$counts]="$getlocs->[0]:$getlocs->[2]";
			if ($getlocs->[0] ne $sts) {
				print "<dd>$getlocs->[0]:$getlocs->[2]\n";
			} else {
				print ", $getlocs->[2]\n";
			}
			$sts=$getlocs->[0];
			$counts = $counts + 1;
		}
		if ($counts == 0) {
			print "LOCATION METADATA for $dsBase\.$dataLevel IS INCOMPLETE\n";
		}
		print "</dd>\n";
		print "<p>For this DOD submission in review, you can select additional sites (or deselect sites) below:<p>\n";
		print "<table>\n";
		print "<tr><td><strong>SITES:FACILITIES</strong></td>\n";
		print " <td><SELECT name=\"sites\" size=10 multiple>\n";
		
		$sth_getsites=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
		if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getsites->execute;
        	while ($getsites = $sth_getsites->fetch) {	
			$match=0;
			foreach $sl (@sitesarray) {
				@sn=();
				@sn=split(/\:/,$sl);
				if (($getsites->[0] eq $sn[0]) && ($getsites->[3] eq $sn[1])) {
					$match=1;
				}
			}
			if ($match == 1) {
				print "<option value=\"$getsites->[0]:$getsites->[3]\" selected>$getsites->[0]:$getsites->[3]</option>\n";
				
			} else {
				print "<option value=\"$getsites->[0]:$getsites->[3]\">$getsites->[0]:$getsites->[3]</option>\n";
			}
		}
		print "</SELECT></td>\n";
		$countproposed=0;
		$sth_countp = $dbh->prepare("SELECT count(*) from facilities where upper(site) not in (SELECT distinct upper(site_code) from $archivedb.$siteinfotab)");
		if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_countp->execute;
        	while ($countp = $sth_countp->fetch) {
			$countproposed=$countp->[0];
		}
		if ($countproposed > 0) {
			print "</tr><tr><td><strong>PROPOSED SITES:FACILITIES<br>(in MMT for review)</strong></td>\n";
			print "<td><SELECT name=\"psites\" size=10 multiple>\n";
			$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),facility_code from facilities where statusFlag=0 order by site");
			if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getpropsite->execute;
        		while ($getpropsite = $sth_getpropsite->fetch) {
				$match=0;
				$sth_getsite=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
				if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getsite->execute;
        			while ($getsite = $sth_getsite->fetch) {
					if (($getsites->[0] eq $getpropsite->[0]) && ($getsites->[3] eq $getpropsite->[1])) {
						$match = 1;
					}
				}
				if ($match == 0) {
					print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\">$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
				}
			}
		}
		print "</SELECT></td></table>\n";		
	} elsif (($exista == 0) && ($existb > 0)) {
		print "<input type=\"hidden\" name=\"DBstat\" value=0>\n";
		print "<strong>DOD Version: </strong>\n";
		print "<INPUT TYPE=\"hidden\" name=\"DODver\" value=\"$DODver\">\n";
		print "v$DODver<br>\n";
		
		
		if ($dsBaseDesc eq "") {
			print "<strong><font color=red>Datastream Class Description:</font></strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		} else {
			print "<strong>Datastream Class Description:</strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"$dsBaseDesc\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		}
		if ($dVol ne "") {
			if ($dVol eq "Y") {
				print "<strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\" checked>Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
			} else {
				print "<strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\" checked>No<p>\n";
			}	
		} else {
			print "<strong><font color=red>Is daily data volume expected to exceed 8 GB?</font></strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
		}
		print "<strong><br>Do you have an urgent deadline that you are trying to meet? If yes, what is your deadline (YYYY.MM.DD)?</strong> <input type=\"test\" name=\"deaddate\" value=$deaddate><br>\n";
		print "<strong>Is the data generated from this process being released to evaluation or production?</strong> \n";
		if ($iseval ne "") {
			if ($iseval =~ "Y") {
				print " <input type=radio name=\"iseval\" value=\"'Y'\" checked>Evaluation <input type=radio name=\"iseval\" value=\"N\">Production<p>\n";
			} else {
				print " <input type=radio name=\"iseval\" value=\"'Y'\">Evaluation <input type=radio name=\"iseval\" value=\"N\" checked>Production<p>\n";
			}	
		} else {
			print " <input type=radio name=\"iseval\" value=\"Y\">Evaluation <input type=radio name=\"iseval\" value=\"N\">Production <font color=red><i>required</i></font><p>\n";
		}
		$countdods=0;
		if ($IDNo eq "") {
			$sth_getDOD = $dbh->prepare("SELECT IDNo,submitter,submitDate,dsBase,dataLevel,DODversion,statusFlag,dsBaseDesc,dVol,iseval,deaddate from DOD where dsBase='$dsBase' AND dataLevel='$dataLevel' order by DODversion");
		} else {
			$sth_getDOD = $dbh->prepare("SELECT IDNo,submitter,submitDate,dsBase,dataLevel,DODversion,statusFlag,dsBaseDesc,dVol,iseval,deaddate from DOD where dsBase='$dsBase' AND dataLevel='$dataLevel' and IDNo !=$IDNo order by DODversion");
		}
		if (!defined $sth_getDOD) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getDOD->execute;
        	while ($getDOD = $sth_getDOD->fetch) {
			if ($countdods == 0)  {
				print "<strong>MMT: DOD(s) have already been submitted for review for the following DOD version(s):<p>";
				$countdods = $countdods + 1;
			}
			print "<dd>$getDOD->[5] (MMT#: $getDOD->[0]) - ";
			$counts=0;
			$sth_getsites = $dbh->prepare("SELECT IDNo,site,facility_code from facilities where IDNo=$getDOD->[0]");
			if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsites->execute;
        		while ($getsites = $sth_getsites->fetch) {
				if ($counts == 0) {
					print "$getsites->[1]:$getsites->[2]";
				} else {
					print ", $getsites->[1]:$getsites->[2]";
				}
				$counts = $counts + 1;
			}
			
			
			if ($counts == 0) {
				print "LOCATION METADATA for $dsBase\.$dataLevel v$DODver IS INCOMPLETE\n";
				print "</dd>\n";
				print "<p>For this DOD submission in review, you can select additional sites (or deselect sites) below:<p>\n";
				print "<table>\n";
				print "<tr><td><strong>SITES:FACILITIES</strong></td>\n";
				print " <td><SELECT name=\"sites\" size=10 multiple>\n";
		
				$sth_getsites=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
				if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getsites->execute;
        			while ($getsites = $sth_getsites->fetch) {	
					$match=0;
					foreach $sl (@sitesarray) {
						@sn=();
						@sn=split(/\:/,$sl);
						if (($getsites->[0] eq $sn[0]) && ($getsites->[3] eq $sn[1])) {
							$match=1;
						}
					}
					if ($match == 1) {
						print "<option value=\"$getsites->[0]:$getsites->[3]\" selected>$getsites->[0]:$getsites->[3]</option>\n";
				
					} else {
						print "<option value=\"$getsites->[0]:$getsites->[3]\">$getsites->[0]:$getsites->[3]</option>\n";
					}
				}
				print "</SELECT></td>\n";
				$countproposed=0;
				$sth_countp = $dbh->prepare("SELECT count(*) from facilities where upper(site) not in (SELECT distinct upper(site_code) from $archivedb.$siteinfotab)");
				if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_countp->execute;
        			while ($countp = $sth_countp->fetch) {
					$countproposed=$countp->[0];
				}
				if ($countproposed > 0) {
					print "</tr><tr><td><strong>PROPOSED SITES:FACILITIES<br>(in MMT for review)</strong></td>\n";
					print "<td><SELECT name=\"psites\" size=10 multiple>\n";
					$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),facility_code from facilities where statusFlag=0 order by site");
					if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getpropsite->execute;
        				while ($getpropsite = $sth_getpropsite->fetch) {
						$match=0;
						$sth_getsite=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
						if (!defined $sth_getsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        					$sth_getsite->execute;
        					while ($getsite = $sth_getsite->fetch) {
							if (($getsites->[0] eq $getpropsite->[0]) && ($getsites->[3] eq $getpropsite->[1])) {
								$match = 1;
							}
						}
						if ($match == 0) {
							print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\">$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
						}
					}
				}
				print "</SELECT></td></table>\n";
			}	
			
			
			
			
			
			print "</dd>\n";
			print "<p>If you want to comment on or review one of the above DOD versions already submitted toi MMT: DOD Review, please go back to the MMT Summary page<br />and select the MMT# for that DOD version to begin/continue the review process.<br>\n";
		}
		if ($IDNo ne "") {
			@break=();
			@break = split(/ /,$DODver);
			print "<strong>Current MMT Site List:</strong> ";	
			@sitel = ();
			$cs=0;
			$sth_getsites=$dbh->prepare("SELECT upper(site),facility_code from facilities WHERE IDNo=$IDNo order by site,facility_code");
			if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsites->execute;
        		while ($getsites = $sth_getsites->fetch) {
				$sitel[$cs]="$getsites->[0]:$getsites->[1]";
				if ($cs == 0) {
					print "$sitel[$cs]";
				} else {
					print ",$sitel[$cs]";
				}
				$cs = $cs + 1;
			}
			if ($cs == 0) {
				print "<font color=red>UNSPECIFIED Sites</font>";
			}
			print "</dd><p>\n";
			print "For this DOD submission in review, you can select additional sites (or deselect sites) below:<p>\n";
			print "<table>\n";
			print "<tr><td><strong>SITES:FACILITIES</strong></td>\n";
			print " <td><SELECT name=\"sites\" size=10 multiple>\n";
			
			$sth_getsites=$dbh->prepare("SELECT distinct upper($archivedb.$siteinfotab.site_code),$archivedb.$siteinfotab.site_name,$archivedb.$siteinfotab.site_type,$archivedb.$facinfotab.facility_code from $archivedb.$siteinfotab,$archivedb.$facinfotab WHERE $archivedb.$siteinfotab.site_code=$archivedb.$facinfotab.site_code and $archivedb.$siteinfotab.site_code not like 'D%' order by $archivedb.$siteinfotab.site_code,$archivedb.$facinfotab.facility_code");
			if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsites->execute;
        		while ($getsites = $sth_getsites->fetch) {	
				$match=0;
				foreach $sl (@sitel) {
					@sn=();
					@sn=split(/\:/,$sl);
					if (($getsites->[0] eq $sn[0]) && ($getsites->[3] eq $sn[1])) {
						$match=1;
					}
				}
				if ($match == 1) {
					print "<option value=\"$getsites->[0]:$getsites->[3]\" selected>$getsites->[0]:$getsites->[3]</option>\n";
				
				} else {
					print "<option value=\"$getsites->[0]:$getsites->[3]\">$getsites->[0]:$getsites->[3]</option>\n";
				}
			}
			print "</SELECT></td>\n";
			$countproposed=0;
			$sth_countp = $dbh->prepare("SELECT count(*) from facilities where statusFlag <= 0");
			if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_countp->execute;
        		while ($countp = $sth_countp->fetch) {
				$countproposed=$countp->[0];
			}
			if ($countproposed > 0) {
				print "</tr><tr><td><strong>PROPOSED SITES:FACILITIES<br>(in MMT for review)</strong></td>\n";
				print "<td><SELECT name=\"psites\" size=10 multiple>\n";
				$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),facility_code from facilities where statusFlag <= 0 order by site,facility_code");
				if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getpropsite->execute;
        			while ($getpropsite = $sth_getpropsite->fetch) {
					$match=0;
					$sth_getsites = $dbh->prepare("SELECT DISTINCT upper(site),facility_code from facilities,IDs where IDs.IDNo=facilities.IDNo and IDs.type='DOD' and facilities.IDNo=$IDNo and upper(site) = '$getpropsite->[0]' and facility_code='$getpropsite->[1]'  order by site,facility_code");
					if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getsites->execute;
        				while ($getsites = $sth_getsites->fetch) {
						$match=0;
						if (($getsites->[0] eq $getpropsite->[0]) && ($getsites->[1] eq $getpropsite->[1])) {
							$match = 1;
						}
					}	
					if ($match == 0) {
						print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\">$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
					} else {
						print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\" selected>$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
					}
				}
			}
			print "</SELECT></td>\n";
		}
		print "</tr></table><p>\n";
					
	} elsif (($exista > 0) && ($existb > 0)) {
		print "<input type=\"hidden\" name=\"DBstat\" value=1>\n";
		print "<br><strong>DOD Version:</strong> v$DODver<p>\n";
		print "<input type=\"hidden\" name=\"DODver\" value=\"$DODver\">\n";
		if ($dsBaseDesc eq "") {
			print "<strong><font color=red>Datastream Class Description:</font></strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"$dsBaseDesc\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		} else {
			print "<strong>Datastream Class Description:</font></strong> <INPUT TYPE=\"text\" name=\"dsBaseDesc\" value=\"$dsBaseDesc\" size=100 maxlength=255> <small><i><a href=\"metadataexamples.pl?mdtype=instcodename\" target=\"examples\">examples</a></i></small><br>\n";
		}
		if ($dVol ne "") {
			if ($dVol eq "Y") {
				print "<strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\" checked>Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
			} else {
				print "<strong>Is daily data volume expected to exceed 8 GB?</strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\" checked>No<p>\n";
			}	
		} else {
			print "<strong><font color=red>Is daily data volume expected to exceed 8 GB?</font></strong> <input type=radio name=\"dVol\" value=\"Y\">Yes <input type=radio name=\"dVol\" value=\"N\">No<p>\n";
		}
		if ($deaddate ne "") {
			print "<p><strong>Do you have an urgent deadline that you are trying to meet?  If so, what is your deadline? (YYYY.MM.DD) <input type=\"text\" name=\"deaddate\" value=\"$deaddate\" size=10 maxlength=10><p>\n";
		} else {
			print "<p><strong><font color=red>Do you have an urgent deadline that you are trying to meet?  If so, what is your deadline? (YYYY.MM.DD)</font> <input type=\"text\" name=\"deaddate\" value=\"$deaddate\" size=10 maxlength=10><p>\n";
		}
		if ($iseval ne "") {
			if ($iseval =~ "Y") {
				print "<p><strong>Is the data generated from this process being released to evaluation or production?</strong> <input type=radio name=\"iseval\" value=\"Y\" checked>Evaluation <input type=radio name=\"iseval\" value=\"N\">Production<p>\n";
			} else {
				print "<p><strong>Is the data generated from this process being released to evaluation or production?</strong> <input type=radio name=\"iseval\" value=\"Y\">Evaluation <input type=radio name=\"iseval\" value=\"N\" checked>Production<p>\n";
			}	
		} else {
			print "<p><strong><font color=red>Is the data generated from this process being released to evaluation or production?</font></strong> <input type=radio name=\"iseval\" value=\"Y\">Evaluation <input type=radio name=\"iseval\" value=\"N\">Production<p>\n";
		}
		print "<p><strong>This datastream class (instrument_code/data level) is in the archive production metadata database:<br />\n";
		$sth_getName = $dbh->prepare("SELECT instrument_code,instrument_name from $archivedb.$instrcodedetailstab WHERE instrument_code='$dsBase'");
		if (!defined $sth_getName) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getName->execute;
        	while ($getName = $sth_getName->fetch) {
			print "<dd>$dsBase: $getName->[1]</dd><p>\n";
		}
		print "This datastream class is listed as installed at the following locations:<br>\n";
		$sts="";
		$countst=0;
		$sth_getlocs = $dbh->prepare("SELECT upper(site_code),instrument_code,facility_code,data_level_code from $archivedb.$dsinfotab WHERE instrument_code='$dsBase' and data_level_code='$dataLevel' order by site_code,facility_code");
		if (!defined $sth_getlocs) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getlocs->execute;
        	while ($getlocs = $sth_getlocs->fetch) {
			if ($countst == 0) {
				$sitelist="<dd>$getlocs->[0]:$getlocs->[2]";
			} else {
				$sitelist="$sitelist".","."$getlocs->[0]:$getlocs->[2]";
			}
			$countst = $countst + 1;
		}
		print "$sitelist</dd><p>\n";
		if ($IDNo eq "") {
			$sth_getDOD = $dbh->prepare("SELECT IDNo,submitter,submitDate,dsBase,dataLevel,DODversion,statusFlag from DOD where dsBase='$dsBase' AND dataLevel='$dataLevel' order by DODversion");
		} else {
			$sth_getDOD = $dbh->prepare("SELECT IDNo,submitter,submitDate,dsBase,dataLevel,DODversion,statusFlag,dsBaseDesc,dVol from DOD where dsBase='$dsBase' AND dataLevel='$dataLevel' and IDNo !=$IDNo order by DODversion");
		}
		$countdods = 0;
		if (!defined $sth_getDOD) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getDOD->execute;
        	while ($getDOD = $sth_getDOD->fetch) {
			if ($countdods == 0)  {
				print "<strong><font color=red>An MMT: DOD Review has already begun for the following DOD version(s):</font><p>";
				$countdods = $countdods + 1;
			}
			print "<dd>$getDOD->[5] (MMT#: $getDOD->[0]) ";
			print "</dd><p>To comment on/review the above DOD version that is already in MMT: DOD Review, please go back to the MMT Summary page<br />and select its MMT# to begin/continue the review process.<br>\n";
			if ($DODver == $getDOD->[5]) {print "</form>\n";
				print "<div class=\"spacer\"></div>\n";
				print "<hr />\n";
				&bottomlinks($IDNo,"DOD");
				print "</div>\n";
				print "</body>\n";
				print "</html>\n";
				$dbh->disconnect();
				exit;
			}
		}
		if ($IDNo ne "") {
			@break=();
			@break = split(/ /,$DODver);
			print "<strong>Current MMT Site List:</strong> ";	
			@sitel = ();
			$cs=0;
			$sth_getsites=$dbh->prepare("SELECT upper(site),facility_code from facilities WHERE IDNo=$IDNo order by site,facility_code");
			if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsites->execute;
        		while ($getsites = $sth_getsites->fetch) {
				$sitel[$cs]="$getsites->[0]:$getsites->[1]";
				if ($cs == 0) {
					print "<dd>$sitel[$cs]";
				} else {
					print ",$sitel[$cs]";
				}
				$cs = $cs + 1;
			}
			if ($cs == 0) {
				print "<font color=red>UNSPECIFIED Sites</font>";
			}
			print "</dd><p>\n";
			print "For this DOD submission in review, you can select additional sites (or deselect sites) below:<p>\n";
			print "<table>\n";
			print "<tr><td><strong>SITES:FACILITIES<br>(arm_int and MMT)</strong></td>\n";
			print "<td><select name=\"sites\" multiple size=10>\n";
			$sth_getsites=$dbh->prepare("SELECT distinct upper(site_code),facility_code from $archivedb.$facinfotab where upper(site_code) not like 'D%' order by site_code,facility_code");
			if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getsites->execute;
        		while ($getsites = $sth_getsites->fetch) {
				$match=0;
				foreach $sl (@sitel) {
					@sn=();
					@sn=split(/\:/,$sl);
					if (($getsites->[0] eq $sn[0]) && ($getsites->[1] eq $sn[1])) {
						$match=1;
					}
				}
				if ($match == 1) {
					print "<option value=\"$getsites->[0]:$getsites->[1]\" selected>$getsites->[0]:$getsites->[1]</option>\n";
				
				} else {
					print "<option value=\"$getsites->[0]:$getsites->[1]\">$getsites->[0]:$getsites->[1]</option>\n";
				}
			}
			print "</SELECT></td>\n";
			$countproposed=0;
			$sth_countp = $dbh->prepare("SELECT count(*) from facilities where upper(site) not in (SELECT distinct upper(site_code) from $archivedb.$siteinfotab)");
			if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_countp->execute;
        		while ($countp = $sth_countp->fetch) {
				$countproposed=$countp->[0];
			}
			if ($countproposed > 0) {
				print "</tr><tr><td><strong>PROPOSED SITES:FACILITIES<br>(in MMT for review)</strong></td>\n";
				print "<td><SELECT name=\"psites\" size=6 multiple>\n";
				$sth_getpropsite = $dbh->prepare("SELECT distinct upper(site),facility_code from facilities where statusFlag=0 order by site");
				if (!defined $sth_getpropsite) { die "Cannot prepare statement: $DBI::errstr\n"; }
        			$sth_getpropsite->execute;
        			while ($getpropsite = $sth_getpropsite->fetch) {
					$match=0;
					$sth_getsites=$dbh->prepare("SELECT distinct upper(site),facility_code from facilities where IDNo=$IDNo and statusFlag=0");
					if (!defined $sth_getsites) { die "Cannot prepare statement: $DBI::errstr\n"; }
        				$sth_getsites->execute;
        				while ($getsites = $sth_getsites->fetch) {
						if (($getsites->[0] eq $getpropsite->[0]) && ($getsites->[1] eq $getpropsite->[1])) {
							$match = 1;
						}
					}
					if ($match == 0) {
						print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\">$getpropsite->[0]: $getpropsite->[1]</OPTION>\n";
					} else {
						print "<OPTION value=\"$getpropsite->[0]:$getpropsite->[1]\" selected>$getpropsite->[0]:$getpropsite->[1]</OPTION>\n";
					}
				}
			}
			print "</SELECT></td>\n";
		}
		print "</tr></table><p>\n";
	}
	print "</strong><p>\n";
	$sth_trytofindclass = $dbh->prepare("SELECT distinct instrument_class_code,instrument_code from $archivedb.$instrcodetoinstrclasstab WHERE instrument_code='$dsBase'");
	if (!defined $sth_trytofindclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_trytofindclass->execute;
        while ($trytofindclass = $sth_trytofindclass->fetch) {
		$instClass=$trytofindclass->[0];
	}
	print "<strong>Select an existing OR proposed instrument class below</strong><br><small>(If you don\'t see an appropriate instrument class in either list below, please contact a \"Metadata Expert\" for assistance. Or, if you are comfortable doing so, you can <a href=\"InstClass.pl?procType=N\" target=\"newclass\"> propose a new instrument class here</a> yourself (then reload this page and select your proposed instrument class)</small)</a></strong><p>\n";
	print "<table>\n";
	print "<tr><td><strong>EXISTING INSTRUMENT CLASSES<br>(from arm_int)</strong></td>\n";
	print " <td><SELECT name=\"instClass\" size=10>\n";
	$sth_getinstclass=$dbh->prepare("SELECT distinct instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab order by instrument_class_code");
	if (!defined $sth_getinstclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getinstclass->execute;
        while ($getinstclass = $sth_getinstclass->fetch) {
		if (($instClass eq $getinstclass->[0]) && ($submit ne "RESET INSTRUMENT CLASS")) {
			print "<OPTION value=\"$getinstclass->[0] 1\" selected>$getinstclass->[0]: $getinstclass->[1]</OPTION>\n";
		} else {
			print "<OPTION value=\"$getinstclass->[0] 1\">$getinstclass->[0]: $getinstclass->[1]</OPTION>\n";
		}
	}
	print "</SELECT></td>\n";
	$countproposed=0;
	$sth_countp = $dbh->prepare("SELECT count(*) from instClass where instrument_class not in (SELECT distinct instrument_class_code from $archivedb.$instrclassdetailstab)");
	if (!defined $sth_countp) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_countp->execute;
        while ($countp = $sth_countp->fetch) {
		$countproposed=$countp->[0];
	}
	if ($countproposed > 0) {
		print "</tr><tr><td><strong>PROPOSED INSTRUMENT CLASSES<br>(in MMT for review)</strong></td>\n";
		print "<td><SELECT name=\"instClass\" size=10>\n";
		$sth_getpropinstclass = $dbh->prepare("SELECT distinct instrument_class,instrument_class_name from instClass,IDs where instClass.IDNo=IDs.IDNo and IDs.type='I' order by instrument_class");
		if (!defined $sth_getpropinstclass) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getpropinstclass->execute;
        	while ($getpropinstclass = $sth_getpropinstclass->fetch) {
			$match=0;
			$sth_geticl=$dbh->prepare("SELECT distinct instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab order by instrument_class_code");
			if (!defined $sth_geticl) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_geticl->execute;
        		while ($geticl = $sth_geticl->fetch) {
				if (($geticl->[0] eq $getpropinstclass->[0]) && ($submit ne "RESET INSTRUMENT CLASS")) {
					$match = 1;
				}
			}
			if ($match == 0) {
				if ($instClass eq "$getpropinstclass->[0]") {
					print "<OPTION value=\"$getpropinstclass->[0] 0\" selected>$getpropinstclass->[0]: $getpropinstclass->[1]</OPTION>\n";
				} else {
					print "<OPTION value=\"$getpropinstclass->[0] 0\">$getpropinstclass->[0]: $getpropinstclass->[1]</OPTION>\n";
				}
			}
		}
		print "</td></SELECT><p>\n";
	}
	print "</tr></table><p>\n";
	print "<strong>Comment</strong> (optional):<br>\n";
	if ($comment ne "") {
		print "<textarea name=\"comment\" rows=5 cols=100>$comment</textarea><p>\n";
	} else {
		print "<textarea name=\"comment\" rows=5 cols=100></textarea><p>\n";
	}

	if ($IDNo ne "") {
		print "<INPUT TYPE=\"HIDDEN\" name=\"IDNo\" value=\"$IDNo\">\n";
		print "<strong>Click <a href=\"Contacts.pl?pcm=1&procType=N&rolename=$instClass&source=@sourceclassarray\">here</a> to add contacts for this DOD</strong><p>\n";
	}
	print "<INPUT TYPE=\"submit\" NAME=\"submit\" value=\"Submit for DOD Review\" /> (to include any updates made above)<p><INPUT TYPE=\"submit\" NAME=\"submit\" value=\"RESET INSTRUMENT CLASS\" /> ";
	if ($IDNo eq "") {
		print "<INPUT TYPE=\"submit\" name=\"submit\" value=\"RESET FORM\">\n";
	}
} 
print "</form>\n";
print "<div class=\"spacer\"></div>\n";
print "<hr />\n";
&bottomlinks($IDNo,"DOD");
$dbh->disconnect();
print "</div>\n";
print "</body>\n";
print "</html>\n";


