#!bin/bash
echo "Script by daohung"
echo "Update...."
apt update 
apt-get update 
sleep 5;
echo "Install mariadb..." 
apt install -y software-properties-common mariadb-server mariadb-client 
sed -i 's/3306/3307/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/#port/port/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
echo "Done config"
--------------------------------------------------------------------
touch /etc/mysql/conf.d/galera.cnf
gale=/etc/mysql/conf.d/galera.cnf
cat >> $gale <<EOF
[mysqld]
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2

wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so

wsrep_cluster_name="mdbcluster"
wsrep_cluster_address="gcomm://$ip_dba_1,$ip_dba_2,$ip_dba_3"

wsrep_sst_method=rsync

wsrep_node_address="$ip_dba_1"
wsrep_node_name="$name_node"
EOF
sleep 5;
#echo "Khoi dong cum cluster"
#galera_new_cluster
sleep 5;
echo "Install Keepalived"
sudo apt-get install keepalived -y
echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
touch /etc/keepalived/keepalived.conf
sleep 5;
keep=/etc/keepalived/keepalived.conf
cat > $keep <<EOF
global_defs {
        lvs_id LBL01
}

vrrp_sync_group SyncGroup01 {
        group {
                FloatIP1
        }
}

vrrp_script check_haproxy {
        script "killall -0 haproxy"
        interval 2
        weight 2
}

vrrp_instance FloatIP1 {
        state $state
        interface ens33
        virtual_router_id 10
        priority $pri
        advert_int 1
        virtual_ipaddress {
                $ip_vip
        }
        track_script {
                check_haproxy
        }
}
EOF
sleep 5;
service keepalived restart
sleep 5;
echo "Install Haproxy..."
apt install haproxy -y 
sleep 5;
hapro=/etc/haproxy/haproxy.cfg
cat >> $hapro <<EOF
  # Galera Cluster Frontend config
  frontend galera_cluster_frontend
      mode tcp
      bind $ip_vip:3306
      option tcplog
      default_backend galera_cluster_backend
  # Galera Cluster Backend config
  backend galera_cluster_backend
      mode tcp
      option tcpka
      balance leastconn
      option mysql-check user clustercheck
      server server01 $ip_dba_1:3307 check
      server server02 $ip_dba_2:3307 check
      server server03 $ip_dba_3:3307 check
  # HAProxy WebGUI
  listen stats # Define a listen section called "stats"
      bind :9000 # Listen on localhost:9000
      mode http
      stats enable  # Enable stats page
      stats hide-version  # Hide HAProxy version
      stats realm Haproxy\ Statistics  # Title text for popup window
      stats uri /stats  # Stats URI
      stats auth admin:admin
EOF
sleep 5;
sudo systemctl restart mysqld
ufw allow 3307
