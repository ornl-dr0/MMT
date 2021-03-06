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
my $webserver = &get_webserver;
my $peopletab = &get_peopletab;
my $archivedb = &get_archivedb;
my $dbserver = &get_dbserver;
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$remote_user=$ENV{'REMOTE_USER'};
#*******************************************************************************
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
print "<title>MMT: Review Status History</title>\n";
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
my $armdefwebserver="";
if ($webserver =~ "c1.db") {
	$armdefwebserver="http://dev.www.arm.gov";
} else {
	$armdefwebserver="http://www.arm.gov";
}
if ($remote_user ne "") {
	$sth_getuser=$dbh->prepare("SELECT person_id,name_first,name_last from $peopletab where upper(user_name)=upper('$remote_user')");
       if (!defined $sth_getuser) { die "Cannot prepare statement: $DBI::errstr\n"; }
        $sth_getuser->execute;
        while ($getuser = $sth_getuser->fetch) {
        	$user_id=$getuser->[0];
		$user_first=$getuser->[1];
		$user_last=$getuser->[2];
	}	
} else {
	print "You are not logged into the MMT system\n";
	$dbh->disconnect();
	exit;
}
$type="";
$sth_gettype = $dbh->prepare("SELECT IDNo,type from IDs where IDNo=$IDNo");
if (!defined $sth_gettype) { die "Cannot prepare statement: $DBI::errstr\n"; }
$sth_gettype->execute;
while ($gettype = $sth_gettype->fetch) {
	$type=$gettype->[1];
}
print "<br />\n";
print "<INPUT TYPE=\"BUTTON\"value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
&toplinks($user_id,$user_first,$user_last,$type);
&getnow;

print "<hr />";
print "<table cellspacing=\"0\">\n";
print "<tr><th rowspan=1 colspan=4 bgcolor=\"#FFF999\">Status History</th></tr>\n";
print "<tr><th>Date</th><th>Who</th><th>Review Group</th><th>Status</th></tr>\n";
$shade=0;
$func="";
$countthem=0;

$sth_getrevs = $dbh->prepare("SELECT statusDate,status,reviewerStatus.person_id from reviewerStatus where IDNo=$IDNo order by statusDate,status asc");
if (!defined $sth_getrevs) { die "Cannot prepare statement: $DBI::errstr\n"; }
$sth_getrevs->execute;
while ($getrevs = $sth_getrevs->fetch) {
	$statdate=$getrevs->[0];
	$stat=$getrevs->[1];
	$statid=$getrevs->[2];
	$sth_getrevFunc = $dbh->prepare("SELECT distinct reviewers.type,reviewers.revFunction,revFuncLookup.revFuncDesc from reviewers,revFuncLookup where reviewers.type='$type' and reviewers.person_id=$statid and reviewers.revFunction=revFuncLookup.revFunction");
	if (!defined $sth_getrevFunc) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getrevFunc->execute;
	while ($getrevFunc = $sth_getrevFunc->fetch) {
		$func=$getrevFunc->[1];
		$funcdesc=$getrevFunc->[2];
	}
	$sth_getstatdesc = $dbh->prepare("SELECT status,statDesc from revStatLookup where func='$func' and status=$stat");
	if (!defined $sth_getstatdesc) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getstatdesc->execute;
	while ($getstatdesc = $sth_getstatdesc->fetch) {
		$statdesc=$getstatdesc->[1];
	}
	$sth_getname = $dbh->prepare("SELECT name_first,name_last from $peopletab where person_id=$statid");
	if (!defined $sth_getname) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_getname->execute;
	while ($getname = $sth_getname->fetch) {
		$fname = $getname->[0];
		$lname = $getname->[1];
	}
	if ($shade == 0)  {
		$shade = 1;
	} elsif ($shade == 1) {
		$shade = 0;
	}
	$countthem = $countthem + 1;
	if ($shade == 0) {
		print "<tr class=\"shaded\"><td>$statdate</td><td>$fname $lname</td><td>$funcdesc</td><td valign=middle>$statdesc</td></tr>\n";
	} else {
		print "<tr><td>$statdate</td><td>$fname $lname</td><td>$funcdesc</td><td valign=middle>$statdesc</td></tr>\n";
	}

}


if ($countthem == 0) {
	print "<tr><td align=center>none</td></tr>\n";
} 
print "</table>";
print "</div>\n";
print "</BODY></HTML>\n";
