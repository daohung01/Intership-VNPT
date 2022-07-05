# Xây dựng hệ thống Web Server High Availability

Mục Lục:

1. [Mô hình - Ý tưởng](#1)
2. [Cấu hình Network](#2)
3. [Cài đặt và Cấu hình trên: Server 1 - Server 2](#3)
- [3.1 Cài đặt và Cấu hình Apache](#31)
- [3.2 Cài đặt và Cấu hình MariaDB](#32)
- [3.3 Cài đặt và Cấu hình php để sử dụng phpMyadmin](#33)
- [3.4 Cài đặt và Cấu hình WordPress](#34)
4. [Cài đặt và Cấu hình Galere Database Cluser trên: DBA1 - DBA2 - DBA3](#4)
- [4.1 Thiết lập cụm Galera Cluster trên DB1](#41)
- [4.2 Thiết lập cụm Galera Cluster trên DB2](#42)
- [4.3 Thiết lập cụm Galera Cluster trên DB3](#43)
5. [Cài đặt và Cấu hình Keepalived](#5)
- [5.1 Cài đặt và cấu hình keepalived trên: Server 1 - Server 2](#51)
- [5.2 Cài đặt và cấu hình keepalived trên: DBA1 - DBA2 - DBA3](#52)
6. [Cài đặt và Cấu hình HAProxy](#6)
- [6.1 Cài đặt và cấu hình HAProxy trên: Server 1 - Server 2](#61)
- [6.2 Cài đặt và cấu hình HAProxy trên: DBA1 - DBA2 - DBA3](#62)

7. [MariaDB for Remote Client Access](#7)
<a name="1"></a>

### Mô hình hoạt động:

![update](https://user-images.githubusercontent.com/86958621/163297169-314646c5-dce3-4ec2-8a9c-66e18c060c29.png)

### Ý tưởng : 

- Xây dựng hệ thống web server high availability sử dụng nhiều loại Service và các phần mềm khác nhau như Web, MySQL, NFS, PhpMyadmin, Wordpress...

- Cấu hình Keepalived dùng VIP cho:  Server 1 - Server 2

- Cấu hình Keepalived dùng VIP cho: DBA1 - DBA2 - DBA3

- Server 1 và Server 2 sẽ sử dụng storage MariaDB của Database Cluster

- Đồng bộ Database: DBA1 - DBA2 - DBA3

- Haproxy dùng VIP để cân bằng tải cho: Server 1 - Server 2

- Haproxy dùng VIP để cân bằng tải cho: DBA1 - DBA2 - DBA3

<a name="2"></a>

## 2. Cấu hình Network:

- Cấu hình iptables để các server trong mạng `host only` có thể truy cập Internet.

      iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
      iptables -A FORWARD -i ens33 -o ens36 -j ACCEPT
      iptables -A FORWARD -o ens33 -i ens36 -j ACCEPT
      echo "1" > /proc/sys/net/ipv4/ip_forward

<a name="3"></a>

## 3. Cấu hình trên Server 1 và Server 2:

<a name="31"></a>

### 3.1 Cài đặt và Cấu hình Apache

- Do phpMyadmin giúp quản lý Database trên giao diện web lên ta cần thêm gói apache để có giao diện web: 

      sudo apt install apache2 -y

- Sau đó chạy dịch vụ bằng lệnh: 

      service apache enable
      service apache start

<a name="32"></a>

### 3.2 Cài đặt MariaDB: 

      apt install -y software-properties-common mariadb-server mariadb-client

- Khởi động dịch vụ MariaDB:

      systemctl start mariadb
      systemctl enable mariadb

- Cho phép cải thiện khả năng bảo mật với lệnh sau :

      mysql_secure_installation

![image](https://user-images.githubusercontent.com/96831921/160666427-5d9ba14c-8712-445e-acc4-a54d3b2bb285.png)

1. Bấm Enter để tiếp tục.

2. Nhập vào y để tạo mật khẩu root mới cho MariaDB. Sau đó hãy nhập vào mật khẩu mà bạn sẽ sử dụng cho user root khi đăng nhập mariaDB

3. Nhập y để xóa user mặc định

4. Nhập vào n vì mình muốn có thể truy cập mariadb từ xa.

5. Nhập y để xóa cơ sở dữ liệu test và xóa truy cập vào nó.

6. Nhập y để tải lại bảng đặc quyền ngay lúc này.

<a name="33"></a>

### 3.3 Cài php để sử dụng phpMyadmin: 

      apt-get install phpmyadmin -y

- Hướng dẫn active tài khoản root trong phpmyadmin

      mysql -u root
      UPDATE mysql.user SET authentication_string = PASSWORD('mật khẩu') WHERE user = 'root'; # Thiết lập mật khẩu cho tài khoản root
      UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root'; # Thiết lập active tài khoản root để login vào phpmyadmin
      FLUSH PRIVILEGES; # Thực hiện refresh để phpmyadmin nhận tài khoản

- Trên giao diện phpMyadmin tạo 1 Database và một user được phép hoạt động ở mọi nơi.

![a1](https://user-images.githubusercontent.com/96831921/160045236-7a4e558d-9181-44be-a989-6ee5834a6211.png)

<a name="34"></a>

### 3.4 Cài đặt WordPress trong Ubuntu 20.04

#### 3.5.1 Tải phiên WordPress bản mới nhất bằng lệnh:

       wget -c http://wordpress.org/latest.tar.gz

#### 3.5.2 Sau khi quá trình tải xuống hoàn tất, hãy giải nén tệp đã lưu trữ bằng lệnh `tar`:

        tar -xzvf latest.tar.gz

#### 3.5.3 Copy file config và chỉnh sửa trước khi nhận database:

       root@hung1:/home/hung1/storage# vim wp-config.php
            define( 'DB_NAME', 'sinhvien' );
            define( 'DB_USER', 'mdbadmin' );
            define( 'DB_PASSWORD', 'daohung22' );
            define( 'DB_HOST', '172.16.0.55' );

Lưu ý: phần MySQL hostname điền ip VIP của cụm Database Cluster

- Vào file config của mariaDB cấu hình cho phép kết nối từ xa với máy chủ cơ sở dữ liệu MySQL: 

- Nếu có địa chỉ 0.0.0.0, máy chủ MySQL chấp nhận các kết nối trên tất cả các giao diện IPv4 của máy chủ: 

      vim /etc/mysql/mariadb.conf.d/50-server.cnf
      port                    = 3306
      bind-address            = 0.0.0.0
      sudo systemctl restart mysqld

<a name="4"></a>

## 4. Cài đặt và Cấu hình Galere Database Cluser trên: DBA1 - DBA2 - DBA3

Mô hình hoạt động:

![mariadb](https://user-images.githubusercontent.com/86958621/163298512-e8f755e8-525a-48ee-bd11-75b915f7cfbe.png)

- Cài đặt MariaDB trên cả 3 node:

      apt install -y software-properties-common mariadb-server mariadb-client

<a name="41"></a>


#### Thiết lập cụm Galera trên DBA1:

- Chỉnh sửa cấu hình máy chủ MariaDB

      sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

- Thay đổi dòng sau: 

      bind-address    = 0.0.0.0
      server-id       = 1

Lưu ý: Server-id chỉ là một số được sử dụng để xác định cá thể MariaDB trong quá trình giám sát và thử nghiệm cụm.

- Tiếp theo, chúng ta sẽ tạo cấu hình cho cụm Galera trên mỗi máy chủ MariaDB.

      sudo nano /etc/mysql/conf.d/galera.cnf

- Điều chỉnh các cài đặt sau cho từng máy chủ, sao chép vào từng tệp `galera.cnf` và lưu.

      [mysqld]
      binlog_format=ROW
      default-storage-engine=innodb
      innodb_autoinc_lock_mode=2
      
      wsrep_on=ON
      wsrep_provider=/usr/lib/galera/libgalera_smm.so
      
      wsrep_cluster_name="mdbcluster"
      wsrep_cluster_address="gcomm://172.16.0.133,172.16.0.134,172.16.0.135"
      
      wsrep_sst_method=rsync
      
      wsrep_node_address="172.16.0.133"
      wsrep_node_name="DBA1"

<a name="42"></a>

#### Thiết lập cụm Galera trên DBA2:

- Chỉnh sửa cấu hình máy chủ MariaDB

      sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

- Thay đổi dòng sau: 

      bind-address    = 0.0.0.0
      server-id       = 2

Lưu ý: Server-id chỉ là một số được sử dụng để xác định cá thể MariaDB trong quá trình giám sát và thử nghiệm cụm.

- Tiếp theo, chúng ta sẽ tạo cấu hình cho cụm Galera trên mỗi máy chủ MariaDB.

      sudo nano /etc/mysql/conf.d/galera.cnf

- Điều chỉnh các cài đặt sau cho từng máy chủ, sao chép vào từng tệp `galera.cnf` và lưu.

      [mysqld]
      binlog_format=ROW
      default-storage-engine=innodb
      innodb_autoinc_lock_mode=2
      
      wsrep_on=ON
      wsrep_provider=/usr/lib/galera/libgalera_smm.so
      
      wsrep_cluster_name="mdbcluster"
      wsrep_cluster_address="gcomm://172.16.0.133,172.16.0.134,172.16.0.135"
      
      wsrep_sst_method=rsync
      
      wsrep_node_address="172.16.0.134"
      wsrep_node_name="DBA2"

<a name="43"></a>

#### Thiết lập cụm Galera trên DBA3:

- Chỉnh sửa cấu hình máy chủ MariaDB

      sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

- Thay đổi dòng sau: 

      bind-address    = 0.0.0.0
      server-id       = 3

Lưu ý: Server-id chỉ là một số được sử dụng để xác định cá thể MariaDB trong quá trình giám sát và thử nghiệm cụm.

- Tiếp theo, chúng ta sẽ tạo cấu hình cho cụm Galera trên mỗi máy chủ MariaDB.

      sudo nano /etc/mysql/conf.d/galera.cnf

- Điều chỉnh các cài đặt sau cho từng máy chủ, sao chép vào từng tệp `galera.cnf` và lưu.

      [mysqld]
      binlog_format=ROW
      default-storage-engine=innodb
      innodb_autoinc_lock_mode=2
      
      wsrep_on=ON
      wsrep_provider=/usr/lib/galera/libgalera_smm.so
      
      wsrep_cluster_name="mdbcluster"
      wsrep_cluster_address="gcomm://172.16.0.133,172.16.0.134,172.16.0.135"
      
      wsrep_sst_method=rsync
      
      wsrep_node_address="172.16.0.135"
      wsrep_node_name="DBA3"

#### Khởi động Galera Cluster trên DBA1:

      sudo galera_new_cluster

- Bây giờ khởi động lại MariaDB trên hai máy chủ khác để chúng tham gia vào cụm.

- Khởi động lại MariaDB trên DBA2 & DBA3:

      sudo systemctl restart mariadb

- Xác minh trạng thái cụm bằng lệnh sau:

      mysql -u root -p -e "SHOW STATUS LIKE 'wsrep_cluster_size'"

- DBA1 sẽ nhận được kết quả sau: 

      +--------------------+-------+
      | Variable_name      | Value |
      +--------------------+-------+
      | wsrep_cluster_size | 1     |
      +--------------------+-------+

- DBA2 sẽ nhận được kết quả sau: 

      +--------------------+-------+
      | Variable_name      | Value |
      +--------------------+-------+
      | wsrep_cluster_size | 2     |
      +--------------------+-------+

- DBA3 sẽ nhận được kết quả sau: 

      +--------------------+-------+
      | Variable_name      | Value |
      +--------------------+-------+
      | wsrep_cluster_size | 3     |
      +--------------------+-------+

#### Kiêm tra đồng bộ cụm cluster:

- Thực hiện trên DBA1:

      mysql -u root -p
      create database test;
      show databases;
      
      +--------------------+
      | Database |
      +--------------------+
      | information_schema |
      | mysql |
      | performance_schema |
      | test |
      +--------------------+
4 rows in set (0.00 sec)

- Tiến hành `show databases` trên DBA2 và DBA3 ta được kết quả:

      +--------------------+
      | Database |
      +--------------------+
      | information_schema |
      | mysql |
      | performance_schema |
      | test |
      +--------------------+
      4 rows in set (0.00 sec)

- Như vậy cụm Galera Cluster đã được đồng bộ với nhau.

<a name="5"></a>

## 5. Cài đặt và Cấu hình Keepalived

<a name="51"></a>

### 5.1 Cài đặt và Cấu hình Keepalived cho Server 1 & Server 2:

      sudo apt-get update
      sudo apt-get install keepalived 

### 5.2 Cấu hình: 

#### Bước 1: Dịch vụ Keepalived sẽ giúp chúng ta tạo 1 Virtual IP để dùng cho máy chủ, nói một cách nôm na là máy chủ sẽ sử dụng IP do chúng ta tự định nghĩa bằng Keepalived chứ không phải dùng IP trên interface của máy chủ (được cấp bởi 1 DHCP nào đó hay do chúng ta tự gán.). Để làm việc này, chúng ta cần vào file /etc/sysctl.conf và thêm dòng sau vào file `sysctl.conf`:

       net.ipv4.ip_nonlocal_bind=1

#### Bước 2: 

- Trên Server 1:

       root@hung:~# vim /etc/keepalived/keepalived.conf

- Nội dung :

       root@daohung:/etc/keepalived# cat /etc/keepalived/keepalived.conf
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
           state MASTER
           interface ens38
           virtual_router_id 51
           priority 100
           advert_int 1
           authentication {
         auth_type PASS
         auth_pass 12345
           }
           virtual_ipaddress {
               172.16.0.50
           }
           track_script {
               chk_apache2
           }
       }
       root@daohung:/etc/keepalived#

#### Bước 3: Tương tự cấu hình trên Server 2:

- Nội dung: 


       root@daohung:/etc/keepalived# cat /etc/keepalived/keepalived.conf
       ! Configuration File for keepalived
       
       global_defs {
         notification_email {
           sysadmin@mydomain.com
         }
         smtp_server localhost
         smtp_connect_timeout 30
         router_id LVS_BACKUP   #khai báo route_id của keepalived
       }
       
       vrrp_script chk_apache2 {
         script "killall -0 apache2"
                interval 2
                weight 2
              }
       
       vrrp_instance VI_1 {
           state BACKUP
           interface ens33
           virtual_router_id 51
           priority 99
           advert_int 1
           authentication {
         auth_type PASS
         auth_pass 12345
           }
           virtual_ipaddress {
               172.16.0.50
           }
           track_script {
               chk_apache2
           }
       }
       root@daohung:/etc/keepalived#
       
- Chú thích:

     - `State` : trạng thái của Instance

     - `Interface` : Interface mà Instance đang chạy

     - `mcast_src_ip` : địa chỉ Multicast

     - `lvs_sync_daemon_inteface` : Interface cho LVS sync_daemon

     - `Virtual_router_id` :  VRRP router id

     - `Priority` : thứ tự ưu tiên trong VRRP router

     - `advert_int` : số  advertisement interval trong 1 giây

     - `smtp_aler` : kích hoạt thông báo SMTP cho MASTER

     - `authentication` :  VRRP authentication

     - `virtual_ipaddress` : VRRP VIP      


- Khởi động lại dịch vụ Keepalived và Apache2 :


       service keepalived restart 
       service apache2 restart 

- Khi nhập Virtual IP hệ thống sẽ truy cập vào Wed Server 2 vì Server 1 có priority là 100 :

     - Ở đây VIP là: `172.16.0.50`

- Nếu Stop dịch vụ `apache2` trên `Server1` lập tức Virtual IP sẽ truy cập vào `Apache` trên `Server 2` 

Kết quả: 

![image](https://user-images.githubusercontent.com/96831921/160271026-ec51535d-5164-4865-999f-51c1ba02d3aa.png)

<a name="52"></a>

### 5.1 Cài đặt và Cấu hình Keepalived trên DBA1 - DBA2 - DBA3:

- Trên DBA1 :

      vim /etc/keepalived/keepalived.conf

- Nội dung:

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
              state MASTER
              interface ens33
              virtual_router_id 10
              priority 101
              advert_int 1
              virtual_ipaddress {
                      172.16.0.55
              }
              track_script {
                      check_haproxy
              }
      }

### 5.2 Tương tự DBA1 cấu hình trên DBA2 & DBA3

- Trên DBA2 & DBA3, cũng sẽ cần xác nhận tên giao diện chính xác, nhưng bạn cũng sẽ cần thay đổi mức độ ưu tiên thành một số thấp hơn 101. Ví dụ: trên DBA2, bạn có thể thay đổi mức độ ưu tiên thành 99 và trên DBA3, bạn có thể đặt nó thành 97.

<a name="6"></a>

## 6. Cài đặt và Cấu hình HAProxy

<a name="61"></a>

### 6.1 Cài đặt và cấu hình HAProxy trên: Server 1 - Server 2

#### Cài dặt:

- HAProxy có sẵn trên kho lưu trữ Ubuntu 20.04 mặc định. Tuy nhiên, gói có sẵn không phải là phiên bản ổn định gần đây nhất. Hãy kiểm tra phiên bản HAProxy nếu chúng ta muốn cài đặt nó từ kho lưu trữ Ubuntu 20.04.

       root@hung4:~# sudo apt show haproxy
       Package: haproxy
       Version: 2.5.5-1ppa1~focal
       Priority: optional
       Section: net
       Maintainer: Debian HAProxy Maintainers <team+haproxy@tracker.debian.org>
       Installed-Size: 3,881 kB
       Pre-Depends: dpkg (>= 1.17.14), init-system-helpers (>= 1.54~)
       Depends: libc6 (>= 2.17), libcrypt1 (>= 1:4.1.0), liblua5.3-0, libpcre2-8-0 (>= 10.22), libssl1.1 (>= 1.1.1), libsystemd0,     adduser, lsb-base (>= 3.0-6)
       Suggests: vim-haproxy, haproxy-doc
       Download-Size: 1,644 kB
       APT-Manual-Installed: yes
       APT-Sources: http://ppa.launchpad.net/vbernat/haproxy-2.5/ubuntu focal/main amd64 Packages
       Description: fast and reliable load balancing reverse proxy
        HAProxy is a TCP/HTTP reverse proxy which is particularly suited for high
        availability environments. It features connection persistence through HTTP
        cookies, load balancing, header addition, modification, deletion both ways. It
        has request blocking capabilities and provides interface to display server
        status.

       N: There are 2 additional records. Please use the '-a' switch to see them.
       root@hung4:~#

- Lệnh này đặt Kho lưu trữ gói cá nhân (PPA) vào danh sách các nguồn apt. Sau khi thêm PPA vào danh sách nguồn APT, chúng ta có thể chạy lệnh bên dưới để hoàn tất cài đặt. Bạn có thể thay thế số phiên bản trong lệnh trên nếu bạn muốn sử dụng phiên bản HAProxy khác.

       $ sudo apt update
       $ sudo apt install haproxy -y


#### Cấu hình:

- Cài đặt xong chúng ta vào file `/etc/haproxy/haproxy.cfg` thêm dòng sau:

       frontend http-in
               bind *:80
               default_backend app
           backend static
               balance roundrobin
               server static 172.16.0.50:80
           backend app
               balance roundrobin
               server test1 172.16.0.20:8080 check
               server test2 172.16.0.30:8080 check

- Option:

      - defaults: chứa những parameters mặc định cho tất cả những sections sử dụng phần khai báo của nó
      
      - frontend: chứa danh sách listening sockets cho phép kết nối từ clients
      
      - backend: sections chứa danh sách các servers mà proxy sẽ kết nối và forward packets.   

      - roundrobin : kiểu chia tải mà Haproxy sẽ chọn lần lượt các máy chủ để chia tải
      
      - leastconn: kiểu chia tải mà Haproxy sẽ chọn máy chủ có ít lưu lượng truy cập đến nhất

      - source : Luôn được chọn vào máy chủ mà Haproxy chọn ban đầu

- Tương tự cấu hình trên Server 2

### `Lưu ý`: Nhớ chuyển `listen port`  của apache2 thành port khác, Vì cài tất cả các dịch vụ haproxy và http đều sử dụng port 80 trên cùng 1 máy nên sẽ conflict đó. Cụ thể ở đây mình sẽ chuyển default listen port của `apache2` thành 8080. Chỉnh sửa lần lượt trên cả 2 server . Edit cả 2 file sau trên mỗi server sudo nano `/etc/apache2/ports.conf` và `sudo nano /etc/apache2/sites-available/000-default.conf`

- Sau đó mở port 8080 : 

       root@hung:~# ufw allow 8080
       Rule added
       Rule added (v6)


- Kiểm tra chia tải trên giao diện web, thêm dòng sau vào option `backend` file config :

        # Bật báo cáo thống kê
        stats enable
        # Thông tin xác thực cho trang web thống kê
        stats auth admin:admin
        # Ẩn phiên bản HAProxy
        stats hide-version
        # Hiển thị tên máy chủ HAProxy
        stats show-node
        # Thời gian làm mới
        stats refresh 60s
        # Báo cáo thống kê URI
        stats uri /haproxy?stats

- Truy cập bằng đường dẫn IP(HAProxy)/haproxy?stats đăng nhập ta được kết quả:

![Screenshot 2022-04-01 10:57:58](https://user-images.githubusercontent.com/96831921/161192352-4b207341-6e62-4768-b86d-bf32c7123685.png)

<a name="62"></a>

### 6.1 Cài đặt và cấu hình HAProxy trên: DBA1 - DBA2 - DBA3

#### Cài đặt: 

      sudo apt install haproxy
      sudo bash -c "echo net.ipv4.ip_nonlocal_bind = 1 >> /etc/sysctl.conf"
      sudo sysctl -p
      
#### cấu hình: 

 Cài đặt xong chúng ta vào file ` vim /etc/haproxy/haproxy.cfg ` thêm dòng sau:

      # Galera Cluster Frontend config
      frontend galera_cluster_frontend
          mode tcp
          bind 172.16.0.55:3306
          option tcplog
          default_backend galera_cluster_backend
      # Galera Cluster Backend config
      backend galera_cluster_backend
          mode tcp
          option tcpka
          balance leastconn
          option mysql-check user clustercheck
          server server01 172.16.0.133:3307 check
          server server02 172.16.0.134:3307 check
          server server03 172.16.0.135:3307 check
      # HAProxy WebGUI
      listen stats # Define a listen section called "stats"
          bind :9000 # Listen on localhost:9000
          mode http
          stats enable  # Enable stats page
          stats hide-version  # Hide HAProxy version
          stats realm Haproxy\ Statistics  # Title text for popup window
          stats uri /stats  # Stats URI
          stats auth admin:admin
          

### `Lưu ý`: Nhớ chuyển `listen port`  của mariaDB thành port khác. Chỉnh sửa trên cả DBA 1-2-3 :

      vim /etc/mysql/mariadb.conf.d/50-server.cnf
      port                    = 3307
      bind-address            = 0.0.0.0
      sudo systemctl restart mysqld

- sau đó mở port trên cả 3 node:

       root@hung:~# ufw allow 3307
       Rule added
       Rule added (v6)
- Chúng ta sẽ tạo ba tài khoản MariaDB mà HAProxy sẽ sử dụng trên mỗi máy chủ để kiểm tra xem MariaDB có đang chạy và phản hồi hay không. Các tài khoản này sẽ không được cấp bất kỳ đặc quyền nào trong cụm, nhưng theo mặc định, chúng có thể thấy cơ sở dữ liệu information_schema . Nếu điều này có quá nhiều rủi ro về bảo mật đối với bạn, bạn có thể xóa tùy chọn cài đặt kiểm tra người dùng mysql-check user clustercheck và bỏ qua bước tiếp theo. Thay vào đó, HAProxy sẽ thực hiện kiểm tra cơ bản để xác minh MariaDB đang chạy:

      sudo mysql -u root -e "CREATE USER clustercheck@'192.168.1.133';CREATE USER clustercheck@'192.168.1.134';CREATE USER clustercheck@'192.168.50.135';flush privileges;"


- Restart the HAProxy service on each server:

      sudo systemctl restart haproxy

- Kết quả : 

![image](https://user-images.githubusercontent.com/96831921/163709309-afeb48ce-c92d-4cfb-aea3-8bf4004b8162.png)

<a name="7"></a>
## 7. Kiểm tra kết quả truy cập galera cluter từ xa: 

- Tạo một tài khoản quản trị MariaDB từ xa mà chúng tôi có thể sử dụng để quản lý và kiểm tra cụm. Đăng nhập vào DBA1 và chạy như sau.

      sudo mysql -u root -e "GRANT ALL ON *.* to 'mdbadmin'@'%' IDENTIFIED BY 'daohung22' WITH GRANT OPTION;flush privileges;"

- Kiểm tra đồng bộ hóa cụm:

- Đăng nhập vào DBA2 và DBA3 và chạy phần sau để kiểm tra xem có thấy tài khoản vừa tạo trên DBA1 hay không.

      sudo mysql -u root -e "SELECT user,host FROM mysql.user WHERE user='mdbadmin';"

- Kết quả DBA2 :

      root@hung2:/home/hung2# sudo mysql -u root -e "SELECT user,host FROM mysql.user WHERE user='mdbadmin';"
      +----------+------+
      | user     | host |
      +----------+------+
      | mdbadmin | %    |
      +----------+------+

- Kết quả DBA3 :

      root@hung3:/home/hung2# sudo mysql -u root -e "SELECT user,host FROM mysql.user WHERE user='mdbadmin';"
      +----------+------+
      | user     | host |
      +----------+------+
      | mdbadmin | %    |
      +----------+------+

- Kiểm tra cân bằng tải

- Để kiểm tra xem lưu lượng MariaDB có đang được cân bằng tải hay không, hãy chạy lệnh sau 3 lần .

      mysql -u mdbadmin -p -h 192.168.1.50 -e "SHOW VARIABLES LIKE 'server_id';"

- Kết quả:

      +---------------+-------+
      | Variable_name | Value |
      +---------------+-------+
      | server_id     | 1     |
      +---------------+-------+
      1 row in set (0.002 sec)

      +---------------+-------+
      | Variable_name | Value |
      +---------------+-------+
      | server_id     | 2     |
      +---------------+-------+
      1 row in set (0.002 sec)

      +---------------+-------+
      | Variable_name | Value |
      +---------------+-------+
      | server_id     | 3     |
      +---------------+-------+
      1 row in set (0.002 sec)

- Kiểm tra nhận dữ liêu từ database: 

Nhấn vào đây để xem lại config database WordPress ở Server 1 & Server 2 : [Tại đây](#34)

- Tạo cơ sở dữ liệu thử nghiệm

      mysql -u mdbadmin -p -h 192.168.1.50 -e "CREATE DATABASE sinhvien;"

Kết quả : 

![image](https://user-images.githubusercontent.com/86958621/163514543-ade53489-8f54-43d2-9f67-c86f4d393229.png)














































































































































































