# Assignment Windows server

## General explanation

A Proof Of Concept with 2 domaincontrollers, mailserver and server for automatic deployment of clients. Automated as much as possible in Powershell.

### Required services

- 2x DC - ADDS - DNS
- DHCP
- SQL
- SCCM
- Exchange
- Sharepoint
- Adobe Reader Deployment

### 1. 2 Domaincontrollers

- OS: Windows 2019
- Primary DC Name: WIN-DC1
- IP settings WIN-DC1:
  - 1 NIC on NAT
  - 1 NIC on internal network
- IP address: 192.168.100.10
- Subnetmask: 255.255.255.0
- Secondary DC Name: WIN-DC2
- IP settings WIN-DC2:
  - 1 NIC on internal network
  - IP address: 192.168.100.20
  - Subnetmask: 255.255.255.0
  - Default Gateway: 192.168.100.10

### 2. SQL server

- OS: Windows 2019
- Name: WIN-SQL-SCCM
- SQL version: 2017
- IP settings SQL server:
  - 1 NIC on internal network
  - IP: 192.168.100.30
  - Subnetmask: 255.255.255.0
  - Default Gateway: 192.168.100.10

### 3. Deployment server

- OS: Windows 2019
- Name: WIN-SQL-SCCM
- SCCM version: 2016
- IP settings Deployment server:
  - 1 NIC on internal network
  - IP address: 192.168.100.30
  - Subnetmask: 255.255.255.0
  - Default Gateway: 192.168.100.30
- Possibility to install a Windows 10 Client using an image
- Possibility to roll out Adobe Reader using a .msi package
- Enable update scheduling and maintainment

### 4. Exchange server

- OS: Windows 2019
- Name: WIN-EXC-SHP
- Exchange version: 2016
- IP settings Exchange:
  - 1 NIC on internal network
  - IP: 192.168.100.40
  - Subnetmask: 255.255.255.0
  - Default Gateway: 192.168.100.40

### 5. SharePoint server

- OS Windows 2019
- Name: WIN-EXC-SHP
- SharePoint version: 2016
- IP settings Exchange:
  - 1 NIC on internal network
  - IP: 192.168.100.40
  - Subnetmask: 255.255.255.0
  - Default Gateway: 192.168.100.40
- Installation and configuration of an intranet site, not accessible from outside the network
- Make sure the Active Directory Security Groups can use this site

### 6. Windows Cliënt

- OS: Windows 10
- Name: WIN-CLT1
- IP: via DHCP (DC1 or DC2)
- Mailing software
- Adobe Reader

### Additional requirements

- Configure Routing on WIN-DC1 to provide internet access to the internal network
- DNS on all servers:
  - Primary: 192.168.100.10
  - Secondary: 192.168.100.20

### Contributors & Credits

- [Matthias Van de Velde](https://github.com/fpkmatthi)
- [Nathan Cammerman](https://github.com/NathanCammerman)
- [Jens Van Liefferinge](https://github.com/JensVL)
