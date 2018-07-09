## api_pxe.mine.io ( API on: pxe.mine.io:88 / 10.20.0.10:88 )

### Service URLs


* API: http://10.20.0.10:88/
* API-Documentation: http://10.20.0.10:88/readme
* Simple DHCP frontend: http://10.20.0.10:88/dhcp


### api.service systemd definition:

    [Unit]
    Description=api.pl
    After=syslog.target network.target remote-fs.target nss-lookup.target
     
    [Service]
    WorkingDirectory=/pxe/api
     
    ExecStart=/bin/sh -c "/pxe/api/api.pl 88 >> /pxe/api/log.log 2>&1"
     
    Type=simple
    Restart=on-failure
     
     
    [Install]
    WantedBy=multi-user.target


### Perl Dependencies:
 - HTTP-Server-Simple-CGI-PreFork   (requires IPv6 and debian packages 'libssl-dev' & 'libz-dev')
 - Net::ISC::DHCPd
 - JSON
 - *______ below should be installed by previous automatically ______*
 - Class::Load
 - File::Temp
 - IO::Pty
 - Moose
 - MooseX::Types
 - MooseX::Types::Path::Class
 - NetAddr::IP
 - Path::Class
 - Time::HiRes
 - Time::Local
 - HTTP::Server::Simple
 - IO::Socket::INET6
 - Net::Server
 - Net::Server::PreFork
 - Net::Server::Proto::SSLEAY
 - Net::Server::Single
 - Net::SSLeay
 - Socket6
 - *and possibly others*
