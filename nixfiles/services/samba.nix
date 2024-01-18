{ config, pkgs, ... }:

{
  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = apu
      netbios name = apu
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user

      vfs objects = fruit streams_xattr  
      fruit:metadata = stream
      fruit:posix_rename = yes 
      fruit:veto_appledouble = no
      fruit:nfs_aces = no
      fruit:wipe_intentionally_left_blank_rfork = yes 
      fruit:delete_empty_adfiles = yes
    '';
    shares = {
      public = {
        path = "/media";
        public = "yes";
        comment = "Medien";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0777";
        "directory mask" = "0777";
        "force user" = "nobody";
      };
      homes = {
        path = "/var/smbhome/%S";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0700";
        "directory mask" = "0700";
        "valid users" = "%S";
      };
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  services.samba.openFirewall = true;

  services.avahi.extraServiceFiles = {
    smb = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_smb._tcp</type>
          <port>445</port>
        </service>
        <service>
          <type>_device-info._tcp</type>
          <port>0</port>
          <txt-record>model=MacPro7,1@ECOLOR=226,226,224</txt-record>
        </service>
      </service-group>
    '';
  };
}
