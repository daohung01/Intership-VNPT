# Build System Web Server High Availability
![image](https://user-images.githubusercontent.com/96831921/176250154-1d79870b-24bf-4c1f-a288-9672d33112de.png)

Script Automatically Build System High Availability

- Condition: 5 Server - OS Ububnu

- Set environment variables suitable for the lesson lab:

  - ENV Server1-Server2:
  
          curl -skLO https://raw.githubusercontent.com/Jaweser3/build-system-web-server-high-availability/main/ENV-S1-S2.sh
          
  - ENV DBA1-DBA2-DBA3:
  
          curl -skLO https://raw.githubusercontent.com/Jaweser3/build-system-web-server-high-availability/main/ENV-DBA.sh
  
Install and Configuration:

- Script build Server1-Server2

```console  
 curl -skLO https://raw.githubusercontent.com/Jaweser3/build-system-web-server-high-availability/main/Script-Config%2BInstall-S1-S2.sh
 
```

- Script build DBA1-DBA2-DBA3
 
```console  
  curl -skLO https://raw.githubusercontent.com/Jaweser3/build-system-web-server-high-availability/main/Script-Config%2BInstall-DBA1-2-3.sh
```

- Demo result

![image](https://user-images.githubusercontent.com/96831921/176256023-cc301e3b-9b48-41c3-bc5e-580878a0fc90.png)

![image](https://user-images.githubusercontent.com/96831921/176256051-006ee0d6-e547-4bcc-b153-a856c7f96ca8.png)

![image](https://user-images.githubusercontent.com/96831921/176256069-9752b353-7096-49a4-9c32-7ef8a12b1e54.png)

