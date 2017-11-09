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
my $grouprole = &get_grouprole;
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
print "<title>MMT Menu</title>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
print "<style type=\"text/css\" media=\"screen\"></style>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
print "<style type=\"text/css\" media=\"screen\"></style>\n";
print "<style type=\"text/css\" media=\"all\">\n";
print "#content {margin-right:0;background-image: none;}\n";
print "#tableContainer {width:1080px; height:200px; overflow: scroll; padding: 0;}\n";
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
print "</head>\n";

my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
my $userid = $user;
my $password=$password;
my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
my $name_first="";
my $name_last="";
my $firstName="";
my $lastName="";
my $armdefwebserver="";
my $sybwebserver="";
if ($webserver =~ "dev.www.db") {
	$armdefwebserver="http://dev.www.arm.gov";
	$sybwebserver="http://dev.www.db1.arm.gov";
} else {
	$armdefwebserver="http://www.arm.gov";
	$sybwebserver="http://www.db1.arm.gov";
}
print '<body class=\"iops\">';
print '<div id="content">';

$submit=$in{submit};
$t=$in{t};

if (($submit eq "") && ($t eq "")) {
	print "<form method=\"post\" name=\"MMT\" action=\"MMTMenu.pl\">\n";
} else {

	print "<form method=\"post\" name=\"MMT\" action=\"MMTMetaData.pl\" enctype=\"multipart/form-data\">\n";
}
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
	$dbh->disconnect();
	exit;
}
print "<br>\n";
&toplinks($user_id,$user_first,$user_last,$type);
&getnow;
print "<center><h3>MetaData Management Tool (MMT): Main Menu</h3></center>";
print "<hr>\n";
if ($submit eq "RESET") {
	$submit="";
}
$dbh->disconnect();
if (($submit eq "") && ($t eq "")) {


	print "<p><strong><h2>Which type of metadata are you interested in making assignments for?</h2></strong><p>\n";
	print "<dd><strong><INPUT type=\"submit\" name=\"submit\" value=\"Routine ARM data\">\n";
	print " <INPUT type=\"submit\" name=\"submit\" value=\"Field Campaign\">\n";
	print " <INPUT type=\"submit\" name=\"submit\" value=\"PI or Evaluation Products\">\n";
	print "</dd></form><hr>\n";
	print "<div class=\"spacer\"></div>\n";
	print "<p><h2>Documentation:<p></h2>\n";
	print "<a href=\"/MMT/MMTUse.pdf\">MMT Description</a><p>";
	print "<a href=\"/MMT/mmt_personnel.pdf\">MMT  Personnel Interaction</a><p>\n";
	print "</div>\n";
	print "</body>\n";
	exit;
}
################################################################
### print menu
if (($submit ne "") || ($t ne "")) {
	if (($submit eq "Routine ARM data") || ($t eq "x")) {
		print "<p><strong><h2>Select an item from the MMT task list below to begin an ARM metadata assignment or review process:</h2></strong><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=S\">Site</a></strong> - Enter a new or update an existing site</dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=F\">Facility</a></strong> - Add a facility designation to an existing or newly proposed ARM site</dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=I\">Instrument Class</a></strong> - Define a new or update an existing instrument class</dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=IC\">Instrument Code</a></strong> - Define a new or update an existing instrument code</dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=CL\">Contacts</a></strong> - Add ARM contacts (Instrument Mentors, VAP Contacts, Translators, etc.)</dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=DOD\">Review a DOD</a></strong> - Comment on/Approve a DOD which has been submitted for review</dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=DS\">ARM Datastream</a></strong> - Assign ARM datastream level metadata <small><font color=red>(cannot be fully completed until its DOD with primary variables identified has been reviewed and approved)</small></font></dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=PMT\">Primary Measurement Type</a></strong> - Define new/update existing ARM primary measurement types</dd><p>\n";
		print "<dd><strong><a href=\"MMTMetaData.pl?type=CI\">Clone</a></strong>  - Clone existing datastreams from one site/facility to another</dd>\n";
		print "<p>\n";
		print "<hr>\n";
	} elsif ($submit eq "PI or Evaluation Products") {
		print "<strong><h2>PI Products and Evaluation Data Products Forms Menu</h2></strong><p>\n";
		print "<dd><strong><a href=\"/cgi-bin/PIP/admin/PIPMetaData.pl\">PI Data Product or Evaluation Data Product Metadata - View/Assign</strong></a></dd><p>\n";
		print "<dd><strong><a href=\"$sybwebserver/cgi-bin/PIP/admin/modifyPIPa.pl\">Modify a PI Data Product or Evaluation Data Product Registration</strong></a></dd><p>\n";
		print "<p>\n";
		print "<hr>\n";
	} elsif ($submit eq "Field Campaign") {
		print "<strong><h2>Field Campaign Metadata Forms Menu</h2></strong><p>\n";
		print "<dd><strong><a href=\"$sybwebserver/cgi-bin/IOP2/checkPIInst.pl\">Field Campaign PI/Instrument Metadata - View/Assign</strong></a></dd>\n";
		print "<p>\n";
		print "<hr>\n";
	}
	print "</form>\n";
}
print "<div class=\"spacer\"></div>\n";
print "<p><h2>Documentation:<p></h2>\n";
print "<a href=\"/MMT/MMTUse.pdf\">MMT Description</a><p>";
print "<a href=\"/MMT/mmt_personnel.pdf\">MMT  Personnel Interaction</a><p>\n";
print "<hr><a href=\"MMTMenu.pl?t=\">MAIN METADATA MENU</a><p>\n";
print "</div>\n";
print "</body>\n";
print "</html>\n";
$dbh->disconnect();
