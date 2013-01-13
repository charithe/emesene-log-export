#!/usr/bin/perl
################################################################################
#   Copyright 2008 Charith K. Ellawala
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
###############################################################################

use DBI qw(:sql_types);

# check command line arguments
if($#ARGV != 2)
{
	die("Usage: emlog.pl <path_to_db_file> <participant_email> <output_file>\n");
}

# assign args to meaningful names
my($dbfile,$email,$outfile) = @ARGV;

# open a connection to the db
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {RaiseError => 1}) or die $DBI::errstr;

# prepare the SQL and execute it
my $sth = $dbh->prepare("SELECT DISTINCT c.id, datetime(c.started,'unixepoch') FROM conversation c, conversation_event ce WHERE c.id = ce.id_conversation AND ce.id_user = (SELECT id FROM user WHERE account LIKE ?) ORDER BY c.started");
$sth->bind_param(1,"\%$email\%",SQL_VARCHAR);
$sth->execute();

# open the file for output
open(FH,">$outfile") or die "Unable to open $outfile for writing";

# HTML header. Change values here to customize the look
my $html = <<END;
<html>
	<head>
		<title>Emesene Chat Log</title>
		<style>
			body
			{
				font-family:Sans;
				font-size:12px;
			}
			
			.conv0
			{
				background-color:#E0E0E0;
				border:1px solid black;
				padding:5px;
			}
			
			.conv1
			{
				background-color:#FFFFFF;
				border:1px solid black;
				padding:5px;
			}
			
			.user0
			{
				color:blue;
				padding:3px;
				display:block;
				border-bottom:1px dashed gray;
			}
			
			.user1
			{
				color:red;
				padding:3px;
				display:block;
				border-bottom:1px dashed gray;
			}
		</style>
	</head>
	<body>
END
print FH $html;

# iterate through the conversations
my ($cid, $uid);
$cid = $uid = 0;

while(($id,$time) = $sth->fetchrow_array)
{
	$uid = 0;
	print FH "<div class=\"conv$cid\">";
	print FH "<h3>Conversation time: $time</h3><br/>\n";
	
	# get the content of the conversation
	my $sth2 = $dbh->prepare("SELECT u.account, ce.data, datetime(e.stamp,'unixepoch') FROM conversation_event ce, user u, event e WHERE ce.id_user = u.id AND ce.id_event = e.id AND ce.id_conversation = $id");
	$sth2->execute();
	
	my $prevacc = '';
	while(($acc,$txt,$ts) = $sth2->fetchrow_array)
	{
		# bit of modulo logic to colourize the different participants
		if($acc ne $prevacc)
		{
			$prevacc = $acc;
			$uid = ($uid + 1) % 2;
		}
		
		# The first two lines of the chat are garbage. Get rid of them here
		my @tmp = split(/\n/,$txt);
		splice(@tmp,0,2);
		$txt = join('<br/>',@tmp);		
		print FH "<span class=\"user$uid\"><i style=\"color:black;\">[$ts] $acc :</i><br/>&nbsp;&nbsp;&nbsp;&nbsp;$txt</span><br/>\n";
	}
	print FH "</div><br/>";
	$sth2->finish();
	$cid = ($cid + 1) % 2;		
}

print FH "</body>\n</html>";
close(FH);

# we are done
$sth->finish();
$dbh->disconnect();



