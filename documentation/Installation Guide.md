# Installation Guide

## General notes

- If you get a WinRM error, execute `vagrant plugin install vagrant-reload` followed by `vagrant reload WIN-XXX`. Replace `WIN-XXX` with the servername.
  - If you continue getting the error, open the VM in VirtualBox.
  - Log in using `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
  - Browse to `C:\vagrant\provisioning\XXX`. Replace `XXX` with your servername.
  - Right-click the first script ande select `Edit`.
  - Press the green arrow at the top to run the script inside the VM.
  - Repeat this process for the other scripts.
- All accounts use `Admin2019` as password.
- Installation of the `WIN-DC1` forest and the `WIN-SQL-SCCM` general SCCM installation can take a while.

## Install WIN-DC1

1. Execute `vagrant up WIN-DC1` in your vagrant directory.
2. When the scripts are done, open the VM in VirtualBox.
3. Select `Other User`. Use `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
4. Open the Start Menu and search for `Server Manager`. Open the application.
5. Select `Manage > Add roles and features`.
6. Click `Next` Until the wizard asks for roles. Select the `Remote Access` role.
7. Continue. When the wizard asks for the wanted role services, select `Direct Access and VPN` and `Routing`.
8. Follow the wizard to install the role.
9. Close the Server Manager.
10. Restart the server.
11. Log in again using `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
12. Open the Server Manager.
13. In the top right menu, select `Tools > Routing And Remote Access`.
14. A new window opens.
15. Right-click on the server and select `Configure and Enable Routing and Remote Access`.
16. Select `Network Adress Translation (NAT)`.
17. Select the `WAN` interface.
18. Finish the wizard.
19. Open the Start Menu and search for `Firewall`. Open `Windows Defender Firewall`.
20. Select `Allow an app or feature through the firewall`.
21. Make sure `Routing and Remote Access` is ticked.
22. This server is now mostly ready. To install DHCP, complete the `WIN-DC2` installation first.

### DHCP

1. Make sure `WIN-DC2` is running and in the domain.
2. Open `WIN-DC1` in VirtualBox.
3. Use `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
4. Open the file explorer.
5. Go to `C:\vagrant\provisioning\WIN-DC1\`.
6. Right-click on `6_dhcp.ps1`. Select `Run with Powershell`.
7. Wait for the script to install and configure DHCP.
8. This server is now ready.

## Install WIN-DC2

1. Execute `vagrant up WIN-DC2` in your vagrant directory.
2. No additional steps are needed for this server. This server is now ready.

- If adding to domain fails, set the domain manually
- Reboot
- After reboot, promote server to DC in existing domain

3. Go back to the `WIN-DC1` installation guide to configure DHCP.

## Install WIN-SQL-SCCM

1. Execute `vagrant up WIN-SQL-SCCM` in your vagrant directory.
2. While the scripts are running, open the VM in VirtualBox.
3. Use `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
4. A popup will appear asking for MDT integration.
5. Follow the wizard.
6. After the wizard is done, the scripts will continue to run automatically.
7. When the scripts are done, open the VM in VirtualBox again.
8. Use `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
9. Open the Start Menu and search for `System Center Configuration Manager`. Open the console.
10. Follow the [Task sequence documentation](Task_Sequence.md) to create a task sequence in order to deploy a client.
11. This server is now ready.

## Install WIN-EXC-SHP

1. Execute `vagrant up WIN-EXC-SHP` in your vagrant directory.
2. When the scripts are done, open the VM in VirtualBox.
3. Use `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
4. This server is now ready.

## Deploy a Windows 10 client

1. Refer to the [Task sequence](Task_Sequence.md) to deploy a client.
