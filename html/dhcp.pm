package API::html::dhcp;

use strict; use warnings; use utf8; use feature ':5.10';

use JSON;

### Load our api-method module.
use methods::dhcp;


sub print {
    my $cgi = shift;
    
    ### Initialize JSON structure and execute API::methods::dhcp::run
    my $json = { meta => { rc => 200, msg => undef, method => undef, postdata => { method => 'dhcp' } }, data => {} };
    eval { $json->{meta}{postdata} = { %{$json->{meta}{postdata}}, %{decode_json($cgi->param('POSTDATA') || '{}')} }; 1; } or die 'error.decode_json: '.$@;
    my $generateDhcpdConf_sub = API::methods::dhcp::run($cgi,$json,1) || die "Error executing method! Try JSON API for detailed error.\n";
    my $dhcp = $json->{data}{dhcp};
    my $sitePath = $cgi->path_info();
    
    print $cgi->header, $cgi->start_html(
        -title=>"pxe.mine.io",
        -style=>{-code=>"body {background-color: #0B2F3A; color: #81BEF7; font-family: Arial, Helvetica, sans-serif; font-size: 17px;} 
                        a {color: #A9F5A9; text-decoration: none;} 
                        a:hover {text-decoration: underline;}"}
    );
    print "<div style='padding-bottom: 4px; color: #2EFEF7;'>service isc-dhcp-server: "
         .(${$dhcp->{status}{active}} ? '<span style="color: lightgreen;">running</span>' : '<span style="color: red;">stopped</span>')." - since: ".$dhcp->{status}{lstart}." (".$dhcp->{status}{etimes}." sec ago)</div>";
    print "<div>";
    print qq~<form><input style="margin-left: 10px; width: 220px; background-color: #A9F5A9; color: #0B2F3A; font-weight: bold; float: left; margin-right: 20px;" 
                        type="button" value="-- Reload --" onclick="window.location.href='http://$ENV{HTTP_HOST}$sitePath'" /></form> ~;
    print qq~<form><input style="margin-right: 20px; width: 220px; background-color: #a163ff; color: white; font-weight: bold; float: left;" 
                        type="button" value="-- API Dokumentation --" onclick="window.location.href='http://$ENV{HTTP_HOST}/readme'" /></form> ~;
    print qq~<form method="post" action="#showConf" enctype='text/plain'>
                <input type="hidden" name='{"generateDhcpdConf":1, "htmlFormTrash":"' value='"}'>
                <input style="margin-right: 20px; width: 220px; background-color: #ccccff; color: #333300; font-weight: bold; float: left;" type="submit" value="-- Show dhcpd.conf --"  />
             </form> ~;
    print qq~<form method="post" action="/" enctype='text/plain'>
                <input type="hidden" name='{"method":"dhcp", "htmlFormTrash":"' value='"}'>
                <input style="margin-right: 20px; width: 220px; background-color: lightblue; color: darkblue; font-weight: bold; float: left;" type="submit" value="-- Get JSON --" />
             </form> ~;
    print qq~<form method="post" enctype='text/plain'>
                <input type="hidden" name='{"method":"dhcp.service.restart", "htmlFormTrash":"' value='"}'>
                <input style="width: 220px; background-color: #F78181; color: #0B2F3A; font-weight: bold; float: left;" type="submit" value="! Restart ISC-DHCP-SERVER !"  />
             </form> ~;
    print "</div><br/><br/>";
    for my $groupName (sort keys %{$dhcp->{groups}}) {
        if ( $groupName =~ /winbios|.*-dev/ && keys %{$dhcp->{groups}{$groupName}{hosts}} > 0 && ( !grep{$_ =~ /pxe.test.*/i} keys %{$dhcp->{groups}{$groupName}{hosts}} or keys %{$dhcp->{groups}{$groupName}{hosts}} > 1 ) ) {
            print "<span style='margin-left: 10px; font-weight: bold; color: #FA58F4;'>[ $groupName ]</span><br/>";
        } else {
            print "<span style='margin-left: 10px; font-weight: bold;'>[ $groupName ]</span><br/>";
        }
        for my $hostName (sort keys %{$dhcp->{groups}{$groupName}{hosts}}) {
            print "<div style='margin-left: 50px; overflow: hidden;".
                ($hostName =~ /pxe.test.*/i ? "font-weight: bold; color: cyan;" : "")
                ."'><span style='float:left;'>".$hostName."</span>"
                ." <span style='margin-left: 5px; float:left; font-size: 11px;'>(".$dhcp->{groups}{$groupName}{hosts}{$hostName}{hardware_address}.")</span>";
            if($hostName =~ /pxe.test.*/i) {
                    for my $inGroupName (sort keys %{$dhcp->{groups}}) {
                        print qq~
                        <span style='float:left; margin-left: 5px; overflow: hidden;'>
                        <form method="post" enctype='text/plain' id="move_$hostName$inGroupName">
                            <input type="hidden" name='{"method":"dhcp.host.alter","params":{"group":"$inGroupName","name":"$hostName"}, "htmlFormTrash":"' value='"}'>
                            <a href="javascript:{}" onclick="document.getElementById('move_$hostName$inGroupName').submit(); return false;">&raquo; $inGroupName</a>
                        </form></span>
                        ~;
                    }
            } elsif ($groupName !~ /winbios|.*-dev/) {  ## winbios
                if($groupName !~ /nvidia.*/i) { 
                    print qq~
                    <span style='float:left; margin-left: 5px; overflow: hidden;'>
                    <form method="post" enctype='text/plain' id="move_winbios_$hostName">
                        <input type="hidden" name='{"method":"dhcp.host.alter","params":{"group":"winbios","name":"$hostName"}, "htmlFormTrash":"' value='"}'>
                        <a href="javascript:{}" onclick="document.getElementById('move_winbios_$hostName').submit(); return false;">&raquo; winbios</a>
                    </form></span>
                    ~;
                }
                if($groupName =~ /nvidia.*/i) {  ## nvidia-dev
                    print qq~
                    <span style='float:left; margin-left: 5px; overflow: hidden;'>
                    <form method="post" enctype='text/plain' id="move_nvidia-dev_$hostName">
                        <input type="hidden" name='{"method":"dhcp.host.alter","params":{"group":"nvidia-dev","name":"$hostName"}, "htmlFormTrash":"' value='"}'>
                        <a href="javascript:{}" onclick="document.getElementById('move_nvidia-dev_$hostName').submit(); return false;">&raquo; nvidia-dev</a>
                    </form></span>
                    ~;
                }
                if($groupName =~ /amd.*/i) {  ## amd-dev
                    print qq~
                    <span style='float:left; margin-left: 5px; overflow: hidden;'>
                    <form method="post" enctype='text/plain' id="move_amd-dev_$hostName">
                        <input type="hidden" name='{"method":"dhcp.host.alter","params":{"group":"amd-dev","name":"$hostName"}, "htmlFormTrash":"' value='"}'>
                        <a href="javascript:{}" onclick="document.getElementById('move_amd-dev_$hostName').submit(); return false;">&raquo; amd-dev</a>
                    </form></span>
                    ~;
                }
            } else {  ## back to vivso group (original group)
                print qq~
                <span style='float:left; margin-left: 5px; overflow: hidden;'>
                <form method="post" enctype='text/plain' id="move_vivso_$hostName">
                    <input type="hidden" name='{"method":"dhcp.host.alter","params":{"group":"$dhcp->{groups}{$groupName}{hosts}{$hostName}{vivso}","name":"$hostName"}, "htmlFormTrash":"' value='"}'>
                    <a style="color: #FA58F4;" href="javascript:{}" onclick="document.getElementById('move_vivso_$hostName').submit(); return false;">&raquo; $dhcp->{groups}{$groupName}{hosts}{$hostName}{vivso}</a>
                </form></span>
                ~;
            }
            print "</div>";
        }
    }
    if( $json->{meta}{postdata}{generateDhcpdConf} ) {
        print "<br/><hr/><pre style='font-size: 12px;' id='showConf'>", $cgi->escapeHTML( $generateDhcpdConf_sub->() ), "</pre>\n";
    }
    print $cgi->end_html;
}


1;