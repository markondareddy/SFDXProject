#!/usr/bin/perl
#
# Removes file extensions like .layout, .email ...
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

use File::Copy;   
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use Cwd;
my $ScriptDir = getcwd();
print "here is the directory name ---$ScriptDir\n";

$deploy = "Deploy";
print `rmdir /s /q $deploy`;
sleep (5);
mkdir $deploy;
$fileName = "GitChanges.rtf";


$Commit1="$ARGV[0]";
$Commit2="$ARGV[1]";
$Commit3="$ARGV[2]";
$Commit4="$ARGV[3]";
$Commit5="$ARGV[4]";
$Commit6="$ARGV[5]";


GetFiles();


sub ParseGitFile {
	open(DeployFile, "$fileName");
		while ($line = <DeployFile>){
		chomp $line;
		print "$line\n";
		ParseGitInputFile($line);		
	}
}

sub GetFiles {
	print "Git Command to get the changed files ..\n";
#	print `git diff --name-only HEAD~$Commit1 HEAD~$Commit2 > GitChanges.rtf`;
#	print `git diff --name-only HEAD~179 HEAD~181 > GitChanges.rtf`;
#    print `git diff --name-only e446d9ac4f24c979496772cf1c3aa2f9eafcfe91 5381592f351f32885a2227116a5ba59acf66661b > GitChanges.rtf`;
	print `git diff --name-only 4d81858cd0e5460b81cb871d903a945f4b96699a HEAD > GitChanges.rtf`;
	git diff --name-only bc92ead1111a08e384dad5f5082aa4732fc3c2e8 HEAD | xargs git checkout-index --force --prefix="uat-deploy/";
	print " Done with GIT files ..\n";
}

sub ParseGitInputFile {
# Src is root and it is 0 argument, next level classes, Dashboard are level 1 arguments 

	if ($line =~ /src/){
            @ReadLine=split (/\//, $line);  
			$FirstArg=$ReadLine[0];
			$SecondArg=$ReadLine[1];
			$thirdArg=$ReadLine[2]; 
			$fourthArg=$ReadLine[3];
			$fifthArg=$ReadLine[4];  	
            #print "SecondArg=$ReadLine[1] thirdArg=$ReadLine[2] fourthArg=$ReadLine[3] fifthArg=$ReadLine[4]\n";
			#src/dashboards/Promotion_Dashboards/Starwood_Hotel.dashboard
			#SecondArg=dashboards, thirdArg=Promotion_Dashboards, fourthArg=Starwood_Hotel.dashboard, fifthArg=

			if ($fifthArg eq "" and $fourthArg  eq ""){			
			#print " both fifthy and fourth arguments are null \n";			
			$FolderName="$deploy\\$SecondArg";
			#print "$FolderName \n";
				if (! -d $FolderName){	
				#print "folder does not exists $FolderName \n";
				print `mkdir $FolderName`;	
				}
				if ($thirdArg eq $Commit3 or $thirdArg eq $Commit4 or $thirdArg eq $Commit5 or $thirdArg eq $Commit6) {					
					goto IGNORE;
					}

			copy ($line, $FolderName)or goto IGNORE;	
			if ($line =~ /meta.xml/){				
				#print "meta.xml file need to be ignored for package.xml\n";
				#print "the line is  -- $line\n";				
				}
				else {
				XMLMataData ($FolderName, $SecondArg);
				}					
			copy ($line."-meta.xml", $FolderName);			
			}
			if ($fifthArg eq "" and $fourthArg  ne ""){
			#print " you are in the second level subfolder \n";
			$FolderName="$deploy\\$SecondArg\\$thirdArg";
			$FolderName2="$deploy\\$SecondArg";
				if (! -d $FolderName){				
				print `mkdir $FolderName`;	
				}	
				if ($fourthArg eq $Commit3 or $fourthArg eq $Commit4 or $fourthArg eq $Commit5 or $fourthArg eq $Commit6) {					
					goto IGNORE;
					}				
				copy ($line, $FolderName)or goto IGNORE;
				if ($line =~ /meta.xml/){				
				print "meta.xml file need to be ignored for package.xml\n";
				#print "the line is  -- $line\n";				
				}
				else {
				XMLMataData22 ($FolderName, $SecondArg);
				}				
			copy ($FirstArg."/".$SecondArg."/".$thirdArg."-meta.xml", $FolderName2);			
			copy ($line."-meta.xml", $FolderName);				
			}				
        }IGNORE:
				# print "========Copy failed $line: $!";					
}

sub Package_File {
	open(package_xml,"> $deploy\\package.xml");
	print package_xml "<package.xml>\n";
	print package_xml "<description>xml package created for deployment </description> \n";
	print package_xml "<!-- ";
	print package_xml "\n";
	print package_xml `date /t`;
	print package_xml `time /t`;
	print package_xml "-->";
	print package_xml "\n";
	print "\n";
	
}
	
sub CloseXML() {
	print package_xml "<version>38.0</version>\n";
	print package_xml "</package.xml>\n";
	close (Package_xml);
}


sub XMLMataData(){	
			@FileExtension=split (/\./, $thirdArg);  
			$FileArg1=$FileExtension[0];			
			$FileArg2=$FileExtension[1];
			#print "File name is $FileArg1 \n";
			#print "File extension is $FileArg2 \n";
			
			if ($SecondArg eq "classes") {						
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>ApexClass</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "approvalProcesses") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1.$FileArg2</members>\n";
					print package_xml "<name>ApprovalProcess</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "dashboards") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Dashboard</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "analyticSnapshots") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>AnalyticSnapshot</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "applications") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>CustomApplication</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "appMenus") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>AppMenu</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "communities") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Community</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "components") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>ApexComponent</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "customApplicationComponents") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>customApplicationComponent</name>\n";
					print package_xml "</types>\n";						
				}elsif ($SecondArg eq "email") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>EmailTemplate</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "flexipages") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>FlexiPage</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "flows") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Flow</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "groups") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Group</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "homePageLayouts") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>HomePageLayout</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "layouts") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Layout</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "networks") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Network</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "objects") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>CustomObject</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "objectTranslations") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>CustomObjectTranslation</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "permissionsets") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>PermissionSet</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "profiles") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Profile</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "quickActions") {
                        if($FileArg2 ne "quickAction"){				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1.$FileArg2</members>\n";
					print package_xml "<name>QuickAction</name>\n";
					print package_xml "</types>\n";}
					else{
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>QuickAction</name>\n";
					print package_xml "</types>\n";
					}
				}elsif ($SecondArg eq "remoteSiteSettings") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>RemoteSiteSetting</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "reports") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Report</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "reportTypes") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>ReportType</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "roles") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Role</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "samlssoconfigs") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>SamlSsoConfig</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "sharingSets") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>SharingSet</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "siteDotComSites") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>SiteDotCom</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "sites") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>CustomSite</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "tabs") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>CustomTab</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "triggers") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>ApexTrigger</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "workflows") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Workflow</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "installedPackages") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>installedPackage</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "labels") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>CustomLabels</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "staticresources") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>StaticResource</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "scontrols") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>scontrol</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "aura") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>AuraDefinitionBundle</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "components") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>ApexComponent</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "pages") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>ApexPage</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "queues") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Queue</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "dataSources") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>ExternalDataSource</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "settings") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Settings</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "assignmentRules") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>AssignmentRules</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "namedCredentials") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>NamedCredential</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "escalationRules") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>EscalationRules</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "customMetadata") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1.$FileArg2</members>\n";
					print package_xml "<name>CustomMetadata</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "letterhead") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Letterhead</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "documents") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Document</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "documents") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>Document</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "liveChatAgentConfigs") {				
					print package_xml "<types>\n";
					print package_xml "<members>*</members>\n";
					print package_xml "<name>LiveChatAgentConfig</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "liveChatButtons") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1</members>\n";
					print package_xml "<name>LiveChatButton</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "liveChatDeployments") {				
					print package_xml "<types>\n";
					print package_xml "<members>*</members>\n";
					print package_xml "<name>LiveChatDeployment</name>\n";
					print package_xml "</types>\n";
				}
				else {
				print package_xml "<types>\n";
				print package_xml "<members>*</members>\n";
				print package_xml "<name>$SecondArg</name>\n";
				print package_xml "</types>\n";
				}
}

sub XMLMataData22(){	
			@FileExtension=split (/\./, $fourthArg);  
			$FileArg1=$FileExtension[0];			
			$FileArg2=$FileExtension[1];
			#print "File name is $FileArg1 \n";
			#print "File extension is $FileArg2 \n";	
			if ($SecondArg eq "classes") {						
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>ApexClass</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "approvalProcesses") {				
					print package_xml "<types>\n";
					print package_xml "<members>$FileArg1.$FileArg2</members>\n";
					print package_xml "<name>ApprovalProcess</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "dashboards") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg</members>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Dashboard</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "analyticSnapshots") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>AnalyticSnapshot</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "applications") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>CustomApplication</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "appMenus") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>AppMenu</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "communities") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Community</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "components") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>ApexComponent</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "customApplicationComponents") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>customApplicationComponent</name>\n";
					print package_xml "</types>\n";						
				}elsif ($SecondArg eq "email") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>EmailTemplate</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "flexipages") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>FlexiPage</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "flows") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Flow</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "groups") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Group</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "homePageLayouts") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>HomePageLayout</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "layouts") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Layout</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "networks") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Network</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "objects") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>CustomObject</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "objectTranslations") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>CustomObjectTranslation</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "permissionsets") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>PermissionSet</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "profiles") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Profile</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "quickActions") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>QuickAction</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "remoteSiteSettings") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>RemoteSiteSetting</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "reports") {		
					if($thirdArg eq 'unfiled$public'){
						print package_xml "<types>\n";											
						print package_xml "<members>$thirdArg/$FileArg1</members>\n";
						print package_xml "<name>Report</name>\n";
						print package_xml "</types>\n";
						} else {
						print package_xml "<types>\n";
						print package_xml "<members>$thirdArg</members>\n";
						print package_xml "<members>$thirdArg/$FileArg1</members>\n";
						print package_xml "<name>Report</name>\n";
						print package_xml "</types>\n";
					}					
				}elsif ($SecondArg eq "reportTypes") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>ReportType</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "roles") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Role</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "samlssoconfigs") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>SamlSsoConfig</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "sharingSets") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>SharingSet</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "siteDotComSites") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>SiteDotCom</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "sites") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>CustomSite</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "tabs") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>CustomTab</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "triggers") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>ApexTrigger</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "workflows") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Workflow</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "installedPackages") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>installedPackage</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "labels") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>CustomLabels</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "staticresources") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>staticresource</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "scontrols") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>scontrol</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "aura") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg</members>\n";
					print package_xml "<name>AuraDefinitionBundle</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "components") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>ApexComponent</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "pages") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>ApexPage</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "queues") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Queue</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "dataSources") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>ExternalDataSource</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "namedCredentials") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>NamedCredential</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "assignmentRules") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>AssignmentRules</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "settings") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Settings</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "escalationRules") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>EscalationRules</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "letterhead") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Letterhead</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "documents") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>Document</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "liveChatAgentConfigs") {				
					print package_xml "<types>\n";
					print package_xml "<members>*</members>\n";
					print package_xml "<name>liveChatAgentConfig</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "liveChatButtons") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1</members>\n";
					print package_xml "<name>LiveChatButton</name>\n";
					print package_xml "</types>\n";
				}elsif ($SecondArg eq "liveChatDeployments") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/*</members>\n";
					print package_xml "<name>LiveChatDeployment</name>\n";
					print package_xml "</types>\n";
				}				
				elsif ($SecondArg eq "customMetadata") {				
					print package_xml "<types>\n";
					print package_xml "<members>$thirdArg/$FileArg1.$FileArg2</members>\n";
					print package_xml "<name>CustomMetadata</name>\n";
					print package_xml "</types>\n";
				}else {
				print package_xml "<types>\n";
				print package_xml "<members>*</members>\n";
				print package_xml "<name>$SecondArg</name>\n";
				print package_xml "</types>\n";
				}
}