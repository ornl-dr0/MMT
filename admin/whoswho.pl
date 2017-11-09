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

$dbname = &get_dbname;
$user = &get_user;
$password= &get_pwd;
$webserver = &get_webserver;
$peopletab = &get_peopletab;
$archivedb = &get_archivedb;
$dbserver = &get_dbserver;
#*******************************************************************************
# get stuff from previous perl script
$IDNo=$in{IDNo};
$remote_user=$ENV{'REMOTE_USER'};
#*******************************************************************************
# here is the access to the IOP database
my $dsn = "DBI:Pg:dbname=arm_xdc;host=$dbserver;port=5432";
my $userid = $user;
my $password=$password;
my $dbh = DBI->connect($dsn,$userid,$password,  {'RaiseError'=> 1}) or die $DBI::errstr;      
my $armdefwebserver="";
if ($webserver =~ "c1.db") {
	$armdefwebserver="http://dev.www.arm.gov";
} else {
	$armdefwebserver="http://www.arm.gov";
}
#*******************************************************************************
# prepare form page
print $query->header;
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n";
print "<head>\n";
print "<title>MMT: Who's Who</title>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"/>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_basic.css\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/arm_adv.css\"; --></style>\n";
print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/shared/arm_print.css\" media=\"print\" />\n";
print "<style type=\"text/css\" media=\"screen\"><!-- \@import \"/shared/fc.css\"; --></style>\n";
print "<style type=\"text/css\" media=\"all\">\n";
print "#content {margin-right:0;background-image: none;}\n";
print "</style>\n";
print "</head>\n";
print "<body class=\"iops\">\n";
print "<div id=\"content\">\n";
$type="";
if ($IDNo ne "") {
	my $sth_gettype = $dbh->prepare("SELECT IDNo,type from IDs where IDNo=$IDNo");
	if (!defined $sth_gettype) { die "Cannot prepare statement: $DBI::errstr\n"; }
	$sth_gettype->execute;
	while ($row = $sth_gettype->fetch) {
		$type=$row->[1];
	}
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
&toplinks($user_id,$user_first,$user_last,$type);

print "<br />\n";
print "<INPUT TYPE=\"BUTTON\"value=\"Close this Window\" onClick=\"window.close(); return false;\"><p>\n";
&getnow;

print "<hr />";
print "<table cellspacing=\"0\">\n";
print "<tr><th rowspan=1 colspan=3 bgcolor=\"#FFF999\">Who's Who:</th></tr>\n";
print "<th>Object Type</th><th>Reviewer Function</th><th>Reviewer</th></tr>\n";
$countthem=0;
$func="";
$funcDesc="";
$object="";
if ($type ne "") {
	$sth_getwho=$dbh->prepare("SELECT distinct reviewers.revFunction,revFuncLookup.revFuncDesc,reviewers.person_id,$peopletab.name_first,$peopletab.name_last,reviewers.type,type.type_name from reviewers,revFuncLookup,$peopletab,type where reviewers.revFunction=revFuncLookup.revFunction and reviewers.person_id=$peopletab.person_id and reviewers.type=type.typeID and reviewers.type='$type' order by type,revFuncLookup.revFuncNo,$peopletab.name_last");
} else {
	$sth_getwho=$dbh->prepare("SELECT distinct reviewers.revFunction,revFuncLookup.revFuncDesc,reviewers.person_id,$peopletab.name_first,$peopletab.name_last,reviewers.type,type.type_name from reviewers,revFuncLookup,$peopletab,type where reviewers.revFunction=revFuncLookup.revFunction and reviewers.person_id=$peopletab.person_id and reviewers.type=type.typeID order by type,revFuncLookup.revFuncNo,$peopletab.name_last");
}

if (!defined $sth_getwho) { die "Cannot prepare statement: $DBI::errstr\n"; }
$sth_getwho->execute;
while ($getwho = $sth_getwho->fetch) {
	$countthem = $countthem + 1;
	$func=$getwho->[0];
	$funcDesc=$getwho->[1];
	$pid=$getwho->[2];
	$prname="$getwho->[3]"." "."$getwho->[4]";
	$otype=$getwho->[5];
	$object=$getwho->[6];
	print "<tr><td>$object</td><td>$funcDesc</td><td>$prname</td></tr>\n";	
}
$func="";
$funcDesc="";


$sth_getnotifyList=$dbh->prepare("SELECT notifyList.person_id,whenNotify,$peopletab.name_first,$peopletab.name_last from notifyList,$peopletab where notifyList.person_id=$peopletab.person_id order by whenNotify,$peopletab.name_last");
if (!defined $sth_getnotifyList) { die "Cannot prepare statement: $DBI::errstr\n"; }
$sth_getnotifyList->execute;
while ($getnotifyList = $sth_getnotifyList->fetch) {
	$countthem = $countthem + 1;
	$when=$getnotifyList->[1];
	$pid=$getnotifyList->[0];
	$prname="$getnotifyList->[2]"." "."$getnotifyList->[3]";
	print "<tr><td> </td><td>Notification on $when</td><td>$prname</td></tr>\n";
}
if ($countthem == 0) {
	print "<tr><td align=center>none</td></tr>\n";
}

print "</table>";
$dbh->disconnect();
print "</div>\n";
print "</BODY></HTML>\n";
