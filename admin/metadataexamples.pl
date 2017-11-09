#!/usr/bin/perl 

use CGI qw(:cgi-lib);
ReadParse();
$query=new CGI;
$query->charset('UTF-8');
use DBI;
use PGMMT_lib;
$VROOT=$ENV{'VROOT'};
use Arminclude;
$dbname = &get_dbname;
$user = &get_user;
$password= &get_pwd;
$webserver = &get_webserver;
$peopletab=&get_peopletab;
$grouprole=&get_grouprole;
$mdtype=$in{mdtype};
$archivedb = &get_archivedb;
$dbserver = &get_dbserver;
$primmeastypestab = &get_pmtypedetailstab; #user table
$dsinfotab = &get_dsinfotab; #user table
$instrclassdetailstab = &get_instrclassdetailstab; #user table
$instrcodetoinstrclasstab  = &get_instrcodetoinstrclasstab; # user table
$instrcodedetailstab = &get_instrcodedetailstab; #user table
$sites = &get_siteinfotab; #user table
$facs = &get_facsinfo; #user table

#*******************************************************************************
# here is the access to the MMT database
my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
my $userid = $user;
my $password=$password;
my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr; 
#*******************************************************************************
# prepare form page
print $query->header;
print "<html>\n";
print "<HEAD>\n";
print "  <TITLE>\n";
print "Existing Metadata in arm_int</TITLE>\n";
print "  <META NAME=\"description\" CONTENT=\"MMT Database\">\n";
print "  <META NAME=\"keywords\" CONTENT=\"MMT, database, admin\">\n";
print "  <META NAME=\"GENERATOR\" CONTENT=\"Mozilla/3.0\">\n";
print "</HEAD>\n";
&showifdev;
print "<BODY BGCOLOR=\"#FFFFFF\">\n";
if ($mdtype eq "instcode") {
	$mdtype = "instrument_code";
}
if ($mdtype eq "contacts") {
	print "<form><strong>EXISTING \"CONTACTS (role table:peopledb)\"</strong> <INPUT TYPE=\"BUTTON\" value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
	print "<table cols=4 border=5><th align=left>Contact Name</th><th align=left>Group Name</th><th align=left>Role Name</th><th align=left>Sub-Role Name</th>\n";
	$sth_getexample=$dbh->prepare("select $grouprole.person_id,name_last,name_first,group_name,role_name,subrole_name from $grouprole,$peopletab WHERE $grouprole.person_id=$peopletab.person_id order by name_last,name_first,group_name,role_name,subrole_name");
        if (!defined $sth_getexample) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getexample->execute;
        while ($getexample = $sth_getexample->fetch) {
		print "<tr><td>$getexample->[1], $getexample->[2]</td><td>$getexample->[3]</td><td>$getexample->[4]</td><td>$getexample->[5]</tr>\n";
	}
	print "</table>\n";
}
if (($mdtype eq "instclass") || ($mdtype eq "instclassname") ) {
	print "<form><strong>EXISTING \"INSTRUMENT CLASSES\" and \"INSTRUMENT CLASS NAMES\"</strong> <INPUT TYPE=\"BUTTON\" value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
	print "<table cols=2 border=5><th align=left>Instrument Class</th><th align=left>Instrument Class Name</th>\n";
	$sth_getexample=$dbh->prepare("select distinct instrument_class_code,instrument_class_name from $archivedb.$instrclassdetailstab order by instrument_class_code");
        if (!defined $sth_getexample) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getexample->execute;
       	while ($getexample = $sth_getexample->fetch) {
		print "<tr><td width=20%>$getexample->[0]</td><td>$getexample->[1]</td></tr>\n";
	}
	print "</table>\n";
	
	
	print "<p><strong>PROPOSED</strong> \"INSTRUMENT CLASSES\" (in MMT database)</br>\n";
	$anyproposed=0;
	$sth_getcount=$dbh->prepare("SELECT count(*),count(*) from instClass where statusFlag=0");
        if (!defined $sth_getcount) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getcount->execute;
       	while ($getcount = $sth_getcount->fetch) {
		$anyproposed=$getcount->[0];
	}
	if ($anyproposed > 0) {
		print "<table cols=2 border=5><th align=left>Instrument Class</th><th align=left>Instrument Class Name</th>\n";
		$sth_getexample2=$dbh->prepare("SELECT DISTINCT instrument_class,instrument_class from instClass where statusFlag=0 order by instrument_class");
       	 	if (!defined $sth_getexample2) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getexample2->execute;
       		while ($getexample2 = $sth_getexample2->fetch) {
			$old="";
			$sth_getdetails=$dbh->prepare("SELECT instrument_class_name,instrument_class_name from instClass where instrument_class='$getexample2->[0]'");
        		if (!defined $sth_getdetails) { die "Cannot prepare statement: $DBI::errstr\n"; }
        		$sth_getdetails->execute;
       			while ($getdetails = $sth_getdetails->fetch) {
				if ($getdetails->[0] ne $old) {
					print "<tr><td width=20%>$getexample2->[0]</td><td>$getdetails->[0]</td><td></tr>\n";
				}
				$old=$getdetails->[0];
			}
		}
	} else {
		print "<dd><small>NO PROPOSED \"INSTRUMENT CLASSES\" in MMT database</small></dd><p>\n";
	}	
		
}
if ($mdtype eq "site") {
	print "<form><strong>EXISTING \"SITES\"</strong> <INPUT TYPE=\"BUTTON\" value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
	print "<table cols=7 border=5><th align=left>Site</th><th align=left>Site Name</th><th align=left>Type</th><th align=left>Prod?</th><th align=left>Data Avail?</th><th align=left>Start Date</th><th align=left>End Date</th>\n";
	$sth_getexample=$dbh->prepare("SELECT distinct upper(site_code),site_name,site_type,production,data_available,start_date,end_date,DATE_PART('year',start_date),DATE_PART('month',start_date),DATE_PART('day',start_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from $archivedb.$sites order by site_code");
        if (!defined $sth_getexample) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getexample->execute;
       	while ($getexample = $sth_getexample->fetch) {
		$styr="";
		$stmn="";
		$stdy="";
		$endyr="";
		$endmn="";
		$enddy="";
		$styr=$getexample->[7];
		$stmn=$getexample->[8];
		$len="";
		$len=length $stmn;
		if ($len < 2) {
			$stmn="0"."$stmn";
		}
		$stdy=$getexample->[9];
		$len="";
		$len=length $stdy;
		if ($len != 2) {
			$stdy="0"."$stdy";
		}
		$endyr=$getexample->[10];
		$endmn=$getexample->[11];	
		$len="";
		$len=length $endmn;
		if ($len !=2) {
			$endmn="0"."$endmn";
		}
		$enddy=$getexample->[12];
		$len="";
		$len=length $enddy;
		if ($len != 2) {
			$enddy="0"."$enddy";
		}
		if ($styr ne "") {
			$start_date="$styr"."-"."$stmn"."-"."$stdy";
		} 
		if ($endyr ne "") {
			$end_date="$endyr"."-"."$endmn"."-"."$enddy";
		}
		print "<tr><td width=20%>$getexample->[0]</td><td>$getexample->[1]</td><td>$getexample->[2]</td><td>$getexample->[3]</td><td>$getexample->[4]</td><td>$start_date</td><td>$end_date</td></tr>\n";
	}
	print "</table>\n";
}
if ($mdtype eq "instrument_code") {
	print "<form><strong>EXAMPLES OF \"INSTRUMENT CODES\", \"INSTRUMENT CODE NAMES\" and \"INSTRUMENT CLASSES\"</strong> <INPUT TYPE=\"BUTTON\" value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
	print "<table cols=3 border=5><th align=left>Instrument Code</th><th align=left>Instrument Code Name</th><th align=left>Instrument Class</th>\n";
	$sth_getexample=$dbh->prepare("select distinct $archivedb.$instrcodetoinstrclasstab.instrument_code,$archivedb.$instrcodedetailstab.instrument_name,$archivedb.$instrcodetoinstrclasstab.instrument_class_code from $archivedb.$instrcodedetailstab,$archivedb.$instrcodetoinstrclasstab WHERE $archivedb.$instrcodedetailstab.instrument_code=$archivedb.$instrcodetoinstrclasstab.instrument_code order by $archivedb.$instrcodetoinstrclasstab.instrument_code,$archivedb.$instrcodetoinstrclasstab.instrument_class_code");
        if (!defined $sth_getexample) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getexample->execute;
       	while ($getexample = $sth_getexample->fetch) {
		print "<tr><td width=20%>$getexample->[0]</td><td>$getexample->[1]</td><td>$getexample->[2]</td></tr>\n";
	}
	print "</table>\n";
}
if ($mdtype eq "facility_code") {
	print "<form><strong>EXISTING \"SITES\",\"FACILITY CODES\" and \"FACILITY NAMES\"</strong> <INPUT TYPE=\"BUTTON\" value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
	print "<table cols=8 border=5><th align=left>Site</th><th align=left>Facility Code</th><th align=left>Facility Name</th><<th>Facility Start Date</th><th>Facility End Date</th><th>Latitude</th><th>Longitude</th><th>Altitude</th>\n";
	$sth_getexample=$dbh->prepare("SELECT distinct upper(site_code),facility_code,facility_name,latitude,longitude,altitude,eff_date,end_date,DATE_PART('year',eff_date),DATE_PART('month',eff_date),DATE_PART('day',eff_date),DATE_PART('year',end_date),DATE_PART('month',end_date),DATE_PART('day',end_date) from $archivedb.$facs where site_code not like 'D%' order by site_code,facility_code");
        if (!defined $sth_getexample) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getexample->execute;
       	while ($getexample = $sth_getexample->fetch) {
		$styr="";
		$stmn="";
		$stdy="";
		$endyr="";
		$endmn="";
		$enddy="";
		$styr=$getexample->[8];
		$stmn=$getexample->[9];
		$len="";
		$len=length $stmn;
		if ($len < 2) {
			$stmn="0"."$stmn";
		}
		$stdy=$getexample->[10];
		$len="";
		$len=length $stdy;
		if ($len != 2) {
			$stdy="0"."$stdy";
		}
		$endyr=$getexample->[11];
		$endmn=$getexample->[12];	
		$len="";
		$len=length $endmn;
		if ($len !=2) {
			$endmn="0"."$endmn";
		}
		$enddy=$getexample->[13];
		$len="";
		$len=length $enddy;
		if ($len != 2) {
			$enddy="0"."$enddy";
		}
		if ($styr ne "") {
			$start_date="$styr"."-"."$stmn"."-"."$stdy";
		} 
		if ($endyr ne "") {
			$end_date="$endyr"."-"."$endmn"."-"."$enddy";
		}
		print "<tr><td>$getexample->[0]</td><td>$getexample->[1]</td><td>$getexample->[2]</td><td>$start_date</td><td>$end_date</td><td>$getexample->[3]</td><td>$getexample->[4]</td><td>$getexample->[5]</td></tr>\n";
	}
	print "</table>\n";
}

if (($mdtype eq "instcode") || ($mdtype eq "instcodename") ) {
	print "<form><strong>EXAMPLES OF \"Datastream Class (INSTRUMENT CODE <font color=red>+</font> DATA LEVEL)\" and \"Datastream Class Description (INSTRUMENT CODE NAME)\"</strong> <INPUT TYPE=\"BUTTON\" value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
	print "<table cols=2 border=5><th align=left>Instrument Code</th><th align=left>Data Level</th><th align=left>Instrument Code Name</th>\n";
	$sth_getexample=$dbh->prepare("select distinct instrument_code,instrument_name from $archivedb.$instrcodedetailstab order by instrument_code");
        if (!defined $sth_getexample) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getexample->execute;
       	while ($getexample = $sth_getexample->fetch) {
		$dllist="";
		$countdl = 0;
		print "<tr><td width=15%>$getexample->[0]";
		$sth_getdl=$dbh->prepare("SELECT distinct instrument_code,data_level_code from $archivedb.$dsinfotab where instrument_code='$getexample->[0]'");
        	if (!defined $sth_getdl) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getdl->execute;
       		while ($getdl = $sth_getdl->fetch) {
			if ($countdl == 0) {
				$dllist="$getdl->[1]";
			} else {
				$dllist="$dllist".", "."$getdl->[1]";
			}
			$countdl = $countdl + 1;
		}
		print "<td>$dllist</td><td>$getexample->[1]</td></tr>\n";
	}
	print "</table>\n";
}
if (($mdtype eq "primmeascode") || ($mdtype eq "primmeascodename") || ($mdtype eq "primmeascodedesc") ) {
	print "<form><strong>EXAMPLES OF \"PRIM MEAS TYPES\", \"PRIM MEAS TYPE NAMES\" and \"PRIM MEAS TYPE DESCs\"</strong> <INPUT TYPE=\"BUTTON\" value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
	print "<table cols=3 border=5><th align=left>Prim Meas Type</th><th align=left>Prim Meas Type Name</th><th>Prim Meas Type Desc</th>\n";
	$sth_getexample=$dbh->prepare("select primary_meas_type_code,primary_meas_type_name,primary_meas_type_desc from $archivedb.$primmeastypestab order by primary_meas_type_code");
        if (!defined $sth_getexample) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getexample->execute;
       	while ($getexample = $sth_getexample->fetch) {
		print "<tr><td width=20%>$getexample->[0]</td><td>$getexample->[1]</td><td>$getexample->[2]</td></tr>\n";
	}
	print "</table>\n";
	print "<p><strong>PROPOSED</strong> \"PRIM MEAS TYPES\" (in MMT database)</br>\n";
	$anyproposed=0;
	$sth_getcount=$dbh->prepare("SELECT count(*),count(*) from primMeas where statusFlag=0");
        if (!defined $sth_getcount) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getcount->execute;
       	while ($getcount = $sth_getcount->fetch) {
		$anyproposed=$getcount->[0];
	}
	if ($anyproposed > 0) {
		print "<table cols=3 border=5><th align=left>Prim Meas Type</th><th align=left>Prim Meas Type Name</th><th>Prim Meas Type Desc</th>\n";
		$sth_getexample2=$dbh->prepare("SELECT DISTINCT primary_meas_code,primary_meas_code from primMeas where statusFlag=0 order by primary_meas_code");
        	if (!defined $sth_getexample2) { die "Cannot prepare statement: $DBI::errstr\n"; }
        	$sth_getexample2->execute;
       		while ($getexample2 = $sth_getexample2->fetch) {
			$old="";
			$sth_getdetails=$dbh->prepare("SELECT primary_meas_name,primary_meas_desc from primMeas where primary_meas_code='$getexample2->[0]'");
        		if (!defined $sth_getdetails) { die "Cannot prepare statement: $DBI::errstr\n"; }
       			$sth_getdetails->execute;
       			while ($getdetails = $sth_getdetails->fetch) {
				if ($getdetails->[0] ne $old) {
					print "<tr><td width=20%>$getexample2->[0]</td><td>$getdetails->[0]</td><td>$getdetails->[1]</td></tr>\n";
				}
				$old=$getdetails->[0];
			}
		}
	} else {
		print "<dd><small>NO PROPOSED \"PRIM MEAS TYPES\" in MMT database</small></dd><p>\n";
	}
}
$dbh->disconnect();
print "</form>\n";
print "</body>\n";
print "</html>\n";

