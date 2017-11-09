#!/usr/bin/perl -w

#use strict;
use arm_cgi;
use CGI qw(:cgi-lib);
ReadParse();

use PGMMTDODstats;
use DBI;
use PGMMT_lib;
my $VROOT=$ENV{'VROOT'};
my $remote_user=$ENV{'REMOTE_USER'};

my $dbname = &get_dbname;
my $user = &get_user;
my $dbserver = &get_dbserver;
my $peopletab=&get_peopletab;
my $person_id=$in{person_id};
my $sd=$in{sd};
my $ed=$in{ed};
my $password =&get_pwd;
my $webserver = &get_webserver;
#connect to database
$dsn = "dbi:Pg:dbname=arm_xdc;host=$dbserver;port=5432;";
$dbh = DBI->connect($dsn, $user, $password) or die $dsn;

# get user info
if ($remote_user ne "") {
	$sql = qq {
		SELECT name_first, name_last, person_id, email
		FROM $peopletab
		WHERE lower(user_name) = lower('$remote_user')
	};
	$getpeople_stmt = $dbh->prepare($sql);
	if (!defined $getpeople_stmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
	if (!defined $getpeople_stmt->execute) { die "Cannot execute statement: $DBI::errstr\n"; }
	while ($getpeople = $getpeople_stmt->fetch) {
		$first_name=$getpeople->[0];
		$last_name=$getpeople->[1];
		$person_id=$getpeople->[2];
		$email=$getpeople->[3];
	}
} elsif ($person_id ne "") {
	$sql = qq {
		SELECT name_first, name_last, email, user_name
		FROM $peopletab
		WHERE person_id = $person_id
	};

	$getpeople_stmt = $dbh->prepare($sql);
	if (!defined $getpeople_stmt) { die "Cannot prepare statement: $DBI::errstr\n"; }
	if (!defined $getpeople_stmt->execute) { die "Cannot execute statement: $DBI::errstr\n"; }
	while ($getpeople = $getpeople_stmt->fetch) {
		$first_name = $getpeople->[0];
		$last_name = $getpeople->[1];
		$email=$getpeople->[2];
		$remote_user = lc($getpeople->[3]);
	}
}
my $arm_cgi = new arm_cgi;
my $query = $arm_cgi->header;
$arm_cgi->arm_doc;

print "
<head>
<title>DOD Stats</title>
";
$arm_cgi->arm_meta;
$arm_cgi->arm_css;
$arm_cgi->arm_js;
my $query   = $arm_cgi->get_query;
print '
<link rel="shortcut icon" href="/images/favicon.ico" />
<link rel="icon" href="/images/favicon.ico" />
';
if ($webserver =~ "dev") {
	print '<style type="text/css">
body {
	background-color: #fff;
	margin: 0;
	padding: 0;
	width: 100%;
	background-image: url(/images/development.gif);
	background-position: top left;
	background-repeat: repeat-y
}

</style>
';
}
print '<style type="text/css">
table,th,td {
	border:1px solid black;
}
</style>
';
print "<style type=\"text/css\" media=\"all\">\n";
print "     .popup";
print "{";
print "     COLOR: #0066CC;";
print "     CURSOR: Help;";
print "     TEXT-DECORATION: none";
print "}";
print "</style>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/jscalendar-1.0/calendar-blue2.css\">\n";
print "<script type=\"text/javascript\" src=\"/shared/overlib.js\"><!-- overLIB (c) Erik Bosrup .--></script>\n";
print "<script type=\"text/javascript\" src=\"/shared/jscalendar-1.0/calendar.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/shared/jscalendar-1.0/lang/calendar-en.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/shared/jscalendar-1.0/calendar-setup.js\"></script>\n";
print '
</head>
';
print '<div id="content">';
print "<p>\n";
if (($sd eq "") || ($ed eq "")) {
	print "<form enctype=\"multipart/form-data\" name=\"DODstats\" method=\"POST\" action=\"getDODstats.pl\">";
	print "<strong>Please enter a date range for MMT DOD Stats Compilation:</strong><p>\n";
	print "<table>\n";
	print "<tr valign=\"bottom\">\n";
	print "<td valign=\"bottom\">\n";
	print "<SPAN id=\"calendar-container\"></SPAN>\n";
	print "<label for=\"sd\"><b>Start Date:</b> (YYYYMMDD) </label>";
	if ($sd eq "")  {
		print "<input type=\"text\" name=\"sd\" id=\"sd\" size=10 maxlength=\"8\" value=\"\" tabindex=\"1\">";
	} else {
		print "<input type=\"text\" name=\"sd\" id=\"sd\" size=10 maxlength=\"8\" value=\"$sd\" tabindex=\"1\">";
	}
	print "<a href=\"javascript: void(0);\" onmouseover=\"overlib('Click here to choose a start date from the calendar', BGCOLOR, '#000000', FGCOLOR, '#FFFFCC', TEXTCOLOR, '#000000', MOUSEOFF, WRAP, CELLPAD, 5, RIGHT, ABOVE); return true;\" onmouseout=\"nd();return true;\">\n";
	print "<img src=\"/shared/jscalendar-1.0/img.gif\" name=\"imgCalendar\" id=\"sdate_trigger_a\" width=\"16\" height=\"16\" border=\"0\" alt=\"\"></a>\n";
	print "<script type=\"text/javascript\">";
	print " Calendar.setup({ \n";
	print "inputField     :     \"sd\",          //*\n";
	print "ifFormat        :     \"%Y%m%d\",\n";
	print "       range              :     [1993,new Date().getFullYear()],\n";
	print "       weekNumbers        :     false,\n";
	print "showsTime       :     false,\n";
	print "button          :     \"sdate_trigger_a\",        //*\n";
	print "step            :     1\n";
	print "});\n";
	print "</script>";
	print "</td>\n";
	print "<td>  </td>\n";
	print "<td valign=\"bottom\" align=\"left\">\n";
	print "<SPAN id=\"calendar-container\"></SPAN>";
	print "<label for=\"ed\" style=\"margin-left:1em\"><b>End Date:</b> (YYYYMMDD) </label>";
	if ($ed eq "") {
		print "<input type=\"text\" name=\"ed\" id=\"ed\" size=10 maxlength=8 onFocus=\"javascript:vDateType='1'\"  value=\"\" tabindex=\"2\">";
	} else {
		print "<input type=\"text\" name=\"ed\" id=\"ed\" size=10 maxlength=8 onFocus=\"javascript:vDateType='1'\" value=\"$ed\" tabindex=\"2\">";
	}
	print "<a href=\"javascript: void(0);\" onmouseover=\"overlib('Click here to choose an end date from the calendar', BGCOLOR, '#000000', FGCOLOR, '#FFFFCC', TEXTCOLOR, '#000000', MOUSEOFF, WRAP, CELLPAD, 5, RIGHT, ABOVE); return true;\" onmouseout=\"nd();return true;\">\n";
	print "<img src=\"/shared/jscalendar-1.0/img.gif\" name=\"imgCalendar\" id=\"edate_trigger_a\" width=\"16\" height=\"16\" border=\"0\" alt=\"\"></a>\n";
	print "<script type=\"text/javascript\">";
	print " Calendar.setup({ \n";
	print "inputField     :     \"ed\",          //*\n";
	print "ifFormat        :     \"%Y%m%d\",\n";
	print "       range              :     [1993,new Date().getFullYear()],\n";
	print "       weekNumbers        :     false,\n";
	print "showsTime       :     false,\n";
	print "button          :     \"edate_trigger_a\",        //*\n";
	print "step            :     2\n";
	print "});\n";
	print "</script>";
	print "</td>";
	print "</tr>";
	print "</table><p>\n";
	print "<small>(results may take a few minutes to compile.  Please be patient)</small><p>\n";
	print "<br><INPUT TYPE=submit VALUE=\"Submit\"> <INPUT TYPE=reset VALUE=\"Clear Form\"> ";
	print "<INPUT TYPE=\"hidden\" name=\"person_id\" value=\"$person_id\">\n";
	print "</form>\n";
	print '</div>';
	print "</body>\n";
	print "</html>\n";
	if (defined $dbh) {
		$dbh->disconnect;
		$dbh = undef;
	}

	exit;
} else {
	my @result = PGMMTDODstats::getMMTDODStatsByDateRange("$sd","$ed");
	$filename="MMTDODStats"."$sd"."\."."$ed";   # use this when we are able to write to an attachment and send....
	
	
	$countr = 0;	
	foreach $r (@result) {
		print "$r";
	}
}
if (defined $dbh) {
	$dbh->disconnect;
	$dbh = undef;
}
