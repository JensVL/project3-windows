# Task sequence to deploy Windows 10 clients

## General note

- If the `DeploymentShare` folder isn't available on the network, share it manually by browsing to `C:\`, right-clicking on the `DeploymentShare` folder, going into properties and sharing it with Administrators.

## Creating a boot image

1. In the SCCM console, go to `Software Library > Overview > Operating Systems > Boot images`.
2. Open the context menu by pressing RMB on `boot images`.
3. Select `Create Boot image using MDT`.
4. Enter `\\WIN-SQL-SCCM\DeploymentShare\Boot` as path.
5. Click `Next`.
6. Enter `Windows10x64` as boot name.
7. Click `Next`. Select `X64` as platform. Leave all the other options on default.
8. Click on `Finish`.
9. Open the context menu on the newly created `Windows10x64` boot image by using RMB.
10. Select `Properties`.
11. Go to the `Data source` tab and check `Deploy this boot image from PXE enabled Distribution point`.
12. Apply and exit out of the properties menu.
13. Open the context menu on the newly created `Windows10x64` boot image by using RMB.
14. Select `Distribute content`. Enter `WIN-SQL-SCCM` as distribution point.
15. Click on `Finish`.
16. The boot image is now ready.

## Creating a OS image

1. In the SCCM console, go to `Software Library > Overview > Operating Systems > Operating systems images`.
2. Open the context menu by pressing RMB on `Operating system images`.
3. Select `Add operating system image`.
4. Enter `\\WIN-SQL-SCCM\DeploymentShare\Operating Systems\Win10Consumers1809\sources\install.wim` as path.
5. Press `Next`.
6. Enter `Windows 10` as name and `1809` as version.
7. Press `Finish`.
8. Open the context menu on the newly created `Windows 10` image by using RMB.
9. Select `Distribute content`.
10. Press `Next` in the wizard.
11. Click `Add distribution point`.
12. Enter `WIN-SQL-SCCM.vanliefferinge.periode1` as distribution point.
13. Press `Next`.
14. Press `Finish`.
15. The OS image is now ready.

## Creating a Task Sequence

1. In the SCCM console, go to `Software Library > Overview > Operating Systems > Task sequences`.
2. Open the context menu by pressing RMB on `Task sequences`.
3. Select `Create MDT task sequence`.
4. Leave the template on `Client task sequence`.
5. Enter `Windows 10` as task sequence name.
6. Enter the following on the `details` window:

```console
    Join a domain:
    Domain: vanliefferinge.periode1
    Account: VANLIEFFERINGE\\Administrator

    Windows Settings:
    User name: Admin
    Organization name: VANLIEFFERINGE

    Administrator Account:
    Enable password: Admin2019
```

7. Click `Next`.
8. Leave `capture settings` on default and click `Next`.
9. On the `boot image` window, select the boot image you created earlier: `Windows10x64`.
10. Under `MDT package`, select `Create a new MDT package`.
11. Browse to `\\WIN-SQL-SCCM\DeploymentShare\Packages\MDT`.
12. Enter `MDT` as name.
13. Click `Next`.
14. On the `OS image` window, select `browse for existing..`.
15. Select the `Windows 10 1809 en-US` image.
16. Click `Next`.
17. Select `Windows 10`.
18. Leave deployment method on `No user interaction`.
19. Under `client package`, select `browse for existing...`.
20. Select `Microsoft Corporation Configuration Manager Client Package`.
21. Click `Next`.
22. Under `USMT package`, select `browse for existing...`.
23. Select `Microsoft Corporation User State Migration Tool for Windows 10`.
24. Click `Next`.
25. Under `Settings package`, select `Create a new Settings package`.
26. Browse to `\\WIN-SQ-SCCM\DeploymentShare\Settings`.
27. Enter `Windows 10 Settings` as name.
28. Click `Next`.
29. Under the `SysPrep` menu, leave everyting on default and press `Next`.
30. Confirm your settings.
31. The task sequence is now successfully created.
32. In the SCCM console, go to `Software Library > Overview > Application Management > Packages`.
33. Open the context menu on `MDT` using RMB.
34. Select `Distribute content`.
35. Press `Next` in the wizard.
36. Click `Add distribution point`.
37. Enter `WIN-SQL-SCCM.vanliefferinge.periode1` as distribution point.
38. Press `Next`.
39. Press `Finish`.
40. Repeat steps `33` to `40` for the following packages:
    - `User State Migration Tool (USMT)`
    - `Windows 10 Settings`
41. The task sequence is now complete.

## Creating a Adobe Reader Application

1. In SCCM console, go to `Software Library > Overview > Application Management > Applications`. Select `Create application`.
2. Select `MSI` and browse to `C:\SetupMedia\AcroRdrDC1500720033_en_US`.
3. On the `General Information` page, enter the following line into the `Installation program` field:

```console
msiexec /i "AcroRdrDC1500720033_en_US.msi" /q
```

4. Make sure `Install behavior` is set to `Install for user`.
5. Click `Next`, and `Next` again.
6. Close the wizard.
7. Open the Adobe Reader application properties by clicking RMB on to the newly created Adobe Reader application.
8. Check `Allow this application to be installed from the install application task sequence action without being deployed`.
9. Open the Adobe Reader context menu by clicking RMB on to the newly created Adobe Reader application.
10. Select `Distribute content`.
11. Adobe Reader is now ready for deployment.

## Add applications into task sequence

1. In SCCM console, go to `Software Library > Overview > Operating Systems > Task sequences`.
2. Open the context menu by pressing RMB on `Windows 10`.
3. Select `Edit`.
4. Browse to the `Post install` section.
5. Press `Apply network settings`.
6. Enter the following in the `domain OU` section: `LDAP://CN=Computers,DC=vanliefferinge,DC=periode1`
7. Go to the `State restore` section.
8. Select `Install Application`.
9. Check `Install the following applications` and add Adobe Reader.
10. Add an extra step before the `Install software` step by pressing the `Add` button.
11. Select `general > Restart Computer` and press `Apply`.
12. Open Windows Explorer and browse to `C:\DeploymentShare\Settings`.
13. Open `CustomSettings.ini` using Notepad or a similar program.
14. Copy the following settings into the file:

```console
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=Y
OSDComputerName=Client01
SkipAppsOnUpgrade=YES
SkipComputerName=YES
SkipDomainMembership=YES
SkipUserData=YES
UserDataLocation=Auto
SkipLocaleSelection=YES
SkipTaskSequence=NO
MachineObjectOU=CN=Computers,DC=vanliefferinge,dc=periode1
DeploymentType=NEWCOMPUTER
SkipTimeZone=YES
SkipApplications=NO
SkipBitLocker=YES
SkipSummary=YES
SkipBDDWelcome=YES
SkipCapture=YES
DoCapture=NO
SkipFinalSummary=NO
TimeZone105
TimeZoneName=Romance Standard Time
JoinDomain=VANLIEFFERINGE
DomainAdmin=Administrator
DomainAdminDomain=VANLIEFFERINGE
DomainAdminPassword=Admin2019
SkipAdminPassword=YES
SkipProductKey=YES
```

15. Save and close the file.
16. In the SCCM console, go to `Software Library > Overview > Application Management > Packages`.
17. Open the context menu on the `MDT` package using RMB.
18. Check `Copy the content in this package to a package share on distribution points`.
19. Close the window with `Ok`.
20. Open the context menu on the `MDT` package using RMB.
21. Select `Update distribution points`.
22. Repeat steps `17` to `21` for the following packages:
    - `User State Migration Tool (USMT)`
    - `Windows 10 Settings`
23. In the SCCM console, go to `Software Library > Overview > Operating Systems > Task Sequences`.
24. Open the context menu on `Windows 10`.
25. Select `Deploy`.
26. In the `Collection` section, press `Browse`.
27. Select `All unknown computers`.
28. Press `Next`.
29. Change the `make available to the following` option to `Only media and PXE`.
30. Leave the rest of the wizard on default. Continue by pressing `Next` and `Finish`.
31. The task sequence is now complete.

## Setting up a VirtualBox Client

1. In VirtualBox, create a new VM using `New`.
2. Enter `Client01` as name and `Windows 10 (64 bit)` as version.
3. Click `Next`.
4. Leave RAM settings on default.
5. Click `Next`.
6. Check `Create a virtual hard disk now`.
7. Click `Create`.
8. Check `VHD - Virtual Hard Drive`.
9. Click `Next`.
10. Check `Dynamically allocated`.
11. Click `Next`.
12. Leave size on 50GB.
13. Click `Create`.
14. Open the settings of the newly created VM.
15. Under `Network`, make sure only 1 internal adapter is enabled. Use Intel PRO/1000 T Server (82543GC) as the adapter type.
16. Select a LAN interface. To create new interfaces, refer to the VirtualBox documentation.
17. Under `System`, have the following boot order:
    - Hard Disk: checked
    - Network: checked
    - Optical: unchecked
    - Floppy: unchecked
18. Close the settings.
19. Launch the newly created VM using `Launch`.
20. Press `F12` when prompted.
21. Click `Next`.
22. Select `Windows 10`.
23. The installation will now continue to run automatically.
24. When prompted with a login screen, enter `VANLIEFFERINGE\Administrator` as username and `Admin2019` as password.
25. The client is now complete.
