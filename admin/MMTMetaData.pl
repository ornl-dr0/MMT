#!/usr/bin/perl 

use arm_cgi;
use CGI qw(:cgi-lib);
ReadParse();
use DBI;
use lib qw(/var/www/DB/lib);
use PGMMT_lib; 
use Time::Local;
use JSON;
use POSIX qw(strftime);
my $VROOT=$ENV{'VROOT'};
my $query = new CGI;
$query->charset('UTF-8');
my $json = new JSON();
my $dbname = &get_dbname;
my $user = &get_user;
my $password= &get_pwd;
my $peopletab = &get_peopletab;
my $dbname = &get_dbname;
my $archivedb = &get_archivedb;
my $webserver=&get_webserver;
my $dbserver = &get_dbserver;
my $remote_user=$ENV{'REMOTE_USER'};
my $sub_date = strftime('%Y%m%d%H%M', localtime());
my $subyr=substr($sub_date,0,4);
my $submon=substr($sub_date,4,2);
my $subday=substr($sub_date,6,2);
my $subhour=substr($sub_date,8,2);
my $submin=substr($sub_date,10,2);
my $submitDate="$submon"."/"."$subday"."/"."$subyr"." "."$subhour".":"."$submin";
#*******************************************************************************
print $query->header;
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n";
print "<head>\n";
print "<title>MMT Summary</title>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
# BEGIN: Include DataTables from https://datatables.net/
print "<script type=\"text/javascript\" charset=\"utf8\" src=\"/shared/jquery-1.12.4.js\"></script>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/jquery.dataTables.min.css\">\n";
print "<script type=\"text/javascript\" charset=\"utf8\" src=\"/shared/jquery.dataTables.min.js\"></script>\n";
# END: Include DataTables from https://datatables.net/
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/arm_adv.css\"; --></style>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/fc.css\"; --></style>\n";
print "<style type=\"text/css\" media=\"all\">\n";
print "#content {margin-right:0;background-image: none;}\n";
print "table {width: 100%; margin: 0; padding: 0;}\n";
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
print '<style type="text/css">
/* Start by setting display:none to make this hidden.
   Then we position it in relation to the viewport window
   with position:fixed. Width, height, top and left speak
   for themselves. Background we set to 80% white with
   our animation centered, and no-repeating */
.modal {
    position:   fixed;
    z-index:    1000;
    top:        0;
    left:       0;
    height:     100%;
    width:      100%;
    background: rgba( 255, 255, 255, .8 ) 
                url("/images/loading-bar.gif") 
                50% 50% 
                no-repeat;
}
</style>
';
print "<script type=\"text/javascript\">\n";
print "    console.log(\"Loading...\");\n";
print "</script>\n";
print "</head>\n";
# here is the access to the MMT database
my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
my $userid = $user;
my $password=$password;
my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr; 
my $name_first="";
my $name_last="";
my $firstName="";
my $lastName="";
$type="";
$type=$in{type};
$filter="";
$filter=$in{filter};
&showifdev;
print '<body class=\"iops\">';
# Overlay...
print "<div id=\"overlay\" class=\"modal\"><!-- Loading Modal --></div>\n";
print '<div id="content">';
print "<form method=\"post\" name=\"MMT\" action=\"MMTMetaData.pl\" enctype=\"multipart/form-data\">\n";
if ($remote_user ne "") {
	my $sth_person = $dbh->prepare("SELECT person_id,name_first,name_last from people.people where upper(user_name)=upper('$remote_user')");
        if (!defined $sth_person) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_person->execute;
        while ($rowx = $sth_person->fetch) {
        	$user_id=$rowx->[0];
		$user_first=$rowx->[1];
		$user_last=$rowx->[2];
	}	
} else {
	print "You are not logged into the MMT<p>\n";
	my $id="";
	&bottomlinks($id,"");
	if (defined $dbh) {
		$dbh->disconnect;
		$dbh = undef;
	}
	exit;
}
&toplinks($user_id,$user_first,$user_last,$type);

print "<center><h3>MetaData Management Tool (MMT): Summary Page</h3></center><hr />";
$now=&getnow;
$submit=$in{submit};
if ($submit eq "RESET") {
	$submit="";
}

if ($type eq "") {
	################################################################
	print "<p><strong><h3>Select an object below to <strong>begin an ARM metadata assignment or review process:</h3></strong><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=S\">Site</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=F\">Facility</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=I\">Instrument Class</a></strong> <small>(define new/update existing)</small></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=IC\">Instrument Code</a></strong> <small>(define new/update existing)</small></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=CL\">Contacts</a></strong><small> (Inst./VAP/Datastream, etc.)</small></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=DOD\">Review a DOD</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=DS\">ARM Datastream</a></strong> <small>(cannot be fully completed until its DOD is approved)</small></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=CI\">Clone Existing Datastreams from one Site/Facility to Another</a></strong></dd><p>\n";
	print "<dd><strong><a href=\"MMTMetaData.pl?type=PMT\">Primary Measurement Type</a></strong></dd><p>\n";
	print "<hr>\n";
	print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<p>\n";
	print "<h3>Current MMT Submissions</h3><p>";
} else {
	if ($type eq "CL") {
		print "<p><strong><a href=\"Contacts.pl\">SUBMIT/UPDATE</a> an ARM Contact</strong><p>\n";
		print "<strong><a href=\"metadataexamples.pl?mdtype=contacts\" target=\"contactlist\">Display current ARM Contacts List</a></strong><p>\n";		
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='CL'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=CL\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		
		}
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";	
	} elsif ($type eq "S") {
		print "<p><strong><a href=\"Site.pl\">SUBMIT/UPDATE</a> ARM Site metadata</strong><p>\n";
		print "<strong><a href=\"metadataexamples.pl?mdtype=site\" target=\"sitelist\">Display current site list</a></strong><p>\n";
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='S'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=S\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		
		}		
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";
	} elsif ($type eq "F") {
		print "<p><strong><a href=\"Facility.pl\">SUBMIT/UPDATE</a> ARM Facility metadata</strong><p>\n";
		print "<strong>(<a href=\"metadataexamples.pl?mdtype=facility_code\" target=\"faclist\">Display current facility list</a>)</strong><p>\n";
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='F'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=F\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		
		}		
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<p>\n";
	} elsif ($type eq "I") {
		print "<p><strong><a href=\"InstClass.pl\">SUBMIT/UPDATE</a> ARM Instrument Class metadata</strong><p>\n";
		print "<strong>(<a href=\"metadataexamples.pl?mdtype=instclass\" target=\"instlist\">Display current instrument class list</a>)</strong><p>\n";
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='I'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=I\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		
		}			

		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";
	} elsif ($type eq "IC") {
		print "<p><strong><a href=\"InstCode.pl\">SUBMIT/UPDATE</a> ARM Instrument Code metadata for Archive DB</strong><p>\n";
		print "<strong>(<a href=\"metadataexamples.pl?mdtype=instcode\" target=\"instlist\">Display current instrument code list</a>)</strong><p>\n";
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='IC'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=IC\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		}	
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";
	} elsif ($type eq "PMT") {
		print "<p><strong><a href=\"PMT.pl\">SUBMIT/UPDATE</a> ARM Primary Measurement Type metadata</strong><p>\n";
		print "<strong>(<a href=\"metadataexamples.pl?mdtype=primmeascode\" target=\"pmtlist\">Display current primary meas type list</a>)</strong><p>\n";
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='PMT'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=PMT\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		
		}	
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";
	} elsif ($type eq "DS") {
		print "<p><strong><a href=\"DS.pl\">SUBMIT/UPDATE</a> ARM Datastream metadata</strong><p>\n";
		print "<strong>(<a href=\"metadataexamples.pl?mdtype=instcode\" target=\"instlist\">Display current datastream class (instcode.data level) list</a>)</strong><p>\n";
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='DS'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=DS\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		
		}	
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";
	} elsif ($type eq "DOD") {
		my $sth_checkauth = $dbh->prepare("SELECT count(*) from mmt.reviewers where person_id=$user_id and type='DOD'");
        	if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
        		if ($rowx->[0] > 0) {
        			print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=DOD\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		
		}	
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";
	} elsif ($type eq "CI") {
		print "<p><strong><a href=\"Clone.pl\">SUBMIT</a> a request to Clone Existing Datastreams from one Site/Facility to another</strong><p>\n";
		$sth_checkauth = $dbh->prepare("SELECT count(*),count(*) from reviewers where person_id=$user_id and type='CI'");
		if (!defined $sth_checkauth) { die "Cannot prepare statement: $DBI::errstr\n"; }
       	 	$sth_checkauth->execute;
       	 	while ($rowx = $sth_checkauth->fetch) {
			if ($checkauth->[0] > 0) {
				print "<strong><a href=\"DailyMMTArchiveCompare.pl?mtype=CI\" target=\"synchronize\">Synchronize with Archive DB</a></strong></p>\n";
			}
		}
		print "<strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
		print "<hr>\n";
		print "<br />Click on the applicable <strong>MMT-ID#</strong> in the table below to <strong>Continue/Update/Review metadata assignments already in progress</strong>.<br><font color=\"green\"><strong>+</strong></font> Sortable column<p>\n";
	}
}
###################################
### for each type of object, display those submitted for review
if ($type ne "") {
	$sth_gettypes = $dbh->prepare("SELECT distinct typeID,type_name from mmt.type where typeID='$type' order by typeOrder");
        if (!defined $sth_gettypes) { die "Cannot prepare statement: $DBI::errstr\n"; }
	
} else {
	$sth_gettypes = $dbh->prepare("SELECT distinct typeID,type_name from mmt.type order by typeOrder");
	if (!defined $sth_gettypes) { die "Cannot prepare statement: $DBI::errstr\n"; }

}
my $fullcount=0;
my @skipfacIds=();
my $tabName="";
my $tabNameDesc="";
my $totcount=0;
my $IDNo="";
$sth_gettypes->execute;
while ($rowx = $sth_gettypes->fetch) {
	$tabName=$rowx->[0];
	$tabNameDesc=$rowx->[1];	
	if ($tabName eq "CL") {
		# new contact object
		$totcount=0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.instContacts");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			&displaycontacts($IDNo,$sortby);
			$IDNo="";
		}
	}
	if ($tabName eq "S") {
		# new site object
		$totcount=0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.sites");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}	
		if ($totcount > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			&displaysite($IDNo,$sortby);
			$IDNo="";
		}
	}
	if ($tabName eq "F") {
		# new facility object
		$totcount = 0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.facilities");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount  > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			&displayfac($IDNo,$sortby);
			$IDNo="";
		}
	}
	if ($tabName eq "I") {
		# new instrument class object
		$totcount=0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.instClass");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			&displayinstclass($IDNo,$sortby);
			$IDNo="";
		}
	}
	if ($tabName eq "IC") {
		# new instrument code object
		$totcount=0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.instCodes");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			&displayinstcode($IDNo,$sortby);
			$IDNo="";
		}
	}
	if ($tabName eq "PMT") {
		# new primary measurement type object
		$totcount = 0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.primMeas");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount  > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			&displaypmt($IDNo,$sortby);
			$IDNo="";
		}
	}
	if ($tabName eq "DS") {
		# datastream object
		$totcount = 0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.DS");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			$filter="";
			$filter=$in{filter};
			$exabnd=$in{exabnd};
			$searchresults=$in{searchresults};
			&displayds($IDNo,$sortby,$filter,$exabnd,$searchresults);
			$IDNo="";
		}
	}
	if ($tabName eq "DOD") {
		# DOD review object
		$totcount = 0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.DOD");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			$filter="";
			$filter=$in{filter};
			&displaydod($IDNo,$sortby,$filter);
			$IDNo="";
		}
	}
	if ($tabName eq "CI") {
		# Clone object
		$totcount = 0;
		my $sth_countem = $dbh->prepare("SELECT count(*) from mmt.clone");
		if (!defined $sth_countem) { die "Cannot prepare statement: $DBI::errstr\n"; }
		$sth_countem->execute;
		while($rowx = $sth_countem->fetch) {
			$totcount = $rowx->[0];
		}
		if ($totcount > 0) {
			$IDNo="";
			$fullcount=1;
			$sortby="";
			$sortby=$in{sortby};
			&displayclone($IDNo,$sortby);
			$IDNo="";
		}
	}
		
}
if ($fullcount == 0) {
	print "<p><strong><dd>No submissions for review</dd></strong><hr>\n";
}
if (defined $dbh) {
	$dbh->disconnect;
	$dbh = undef;
}

print "</form>\n";
print "<p><strong><a href=\"MMTMenu.pl?t=x\">MMT Main Menu</a></strong><p>\n";
print "<div class=\"spacer\"></div>\n";
print "</div>\n";
print "</body>\n";
# BEGIN: Use DataTables from https://datatables.net/
print "<script type=\"text/javascript\">\n";
print "\$(window).on({\n";
print "    load: function(ex) {\n";
print "        ex.stopPropagation();  // Prevents the event from bubbling up the DOM tree";
print "        \$('#overlay').hide();\n";    
print "        \$('#overlay').removeClass(\"modal\");\n";    
print "        console.log(\"Loading DONE!\");\n";
print "    },\n";
print "    error: function(errorMsg, url, lineNumber, column, errorObj) {\n";
print "        console.log('error[' + lineNumber + '/' + column + ']: ' + errorMsg);\n";
print "    }\n";
print "});\n";
print "\$(document).on({\n";
print "    ready: function() {\n";
print "        console.log(\"Datatable...\");\n";
print "        \$('#mainTable').DataTable();\n";
print "        console.log(\"Datatable DONE!\");\n";
print "    }\n";
print "});\n";
print "</script>\n";
# END: Use DataTables from https://datatables.net/
print "</html>\n";
