#!bin/bash
echo "Script by daohung"
echo " Update..."
apt update 
sleep 5;
apt-get update 
echo "Install apache2 "
sleep 5;
sudo apt install apache2 -y 
sleep 5;
echo "Start server apache2...."
service apache2 enable
service apache2 start
echo "Done! apache2"
sleep 5;
echo "Install mariadb"
sleep 5;
apt install -y software-properties-common mariadb-server mariadb-client 
sleep 5;
sed -i 's/#port/port/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sleep 5;
echo "Start mariadb"
systemctl start mariadb
systemctl enable mariadb
sleep 5;

mysql_secure_installation <<EOF

y
daohung22
daohung22
y
y
y
y
EOF
sleep 5;
echo "Done! MariaDB"

echo " Install Phpmyadmin "

DEBIAN_FRONTEND=noninteractive apt-get -y install phpmyadmin -y

sleep 5;
wget -c http://wordpress.org/latest.tar.gz
sleep 5;
tar -xzvf latest.tar.gz
sleep 5;
echo "Copy file config wp..."
cp /root/wordpress/wp-config-sample.php /root/wordpress/wp-config.php
sed -i 's/database_name_here/sinhvien/' /root/wordpress/wp-config.php
sed -i 's/username_here/mdbadmin/' /root/wordpress/wp-config.php
sed -i 's/password_here/daohung22/' /root/wordpress/wp-config.php
sed -i 's/localhost/172.16.0.55/' /root/wordpress/wp-config.php
sleep 5;
#rm -rf /var/www/html/*
#cp -r /root/wordpress/* /var/www/html/
echo "Done Wp"

sleep 5;
echo " Install Keepalived "
sudo apt-get install keepalived -y
sleep 5;
echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
touch /etc/keepalived/keepalived.conf
sleep 5;
sed -i 's/80/8080/' /etc/apache2/ports.conf
sed -i 's/80/8080/' /etc/apache2/sites-available/000-default.conf
echo "change port apache2 8080"
sleep 5;
keep=/etc/keepalived/keepalived.conf
cat > $keep <<EOF
! Configuration File for keepalived

global_defs {
  notification_email {
    sysadmin@mydomain.com
  }
  smtp_server localhost
  smtp_connect_timeout 30
  router_id LVS_MASTER    #khai báo route_id của keepalived
}

vrrp_script chk_apache2 {
  script "killall -0 apache2"
         interval 2
         weight 2
       }

vrrp_instance VI_1 {
    state $state
    interface ens33
    virtual_router_id 51
    priority $pri
    advert_int 1
    authentication {
  auth_type PASS
  auth_pass 12345
    }
    virtual_ipaddress {
        $ip_vip
    }
    track_script {
        chk_apache2
    }
}
EOF
sleep 5;
service keepalived restart 
service apache2 restart 
echo " Done Keepalive" 

echo " Install HAproxy"
sleep 5;
sudo apt install haproxy -y
sleep 5;
hapro=/etc/haproxy/haproxy.cfg
cat >> $hapro <<EOF
frontend http-in
        bind *:80
        default_backend app
    backend static
        balance roundrobin
        server static $ip_vip:80
    backend app
        balance roundrobin
        server test1 $ip_sv1:8080 check
        server test2 $ip_sv2:8080 check
EOF
sleep 5;
