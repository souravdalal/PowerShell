#Copyright Sourav Dalal
#Date : 13 July 2021
# Purpose: This is a small script which will copy stdout & stderr logs from tomacat logs folder to user defined folder in zipped format
# After zipping the data from Original folder is cleared off
# In target output folder Folder is created with yyyy/mm/dd format & files are zipped with original file name.<fileCount in folder>.zip format
# The script can run on running Tomcat

#input data : Replace the values with tomcat log folder path
$tomcatVSFolderPath = "<Tomcat_Isstall_DIR>\logs";
#Replace the value of $targetFolderPath with target folder where the files are copied & zipped
$targetFolderPath = "<Target_Folder>";
#end of input data

$tomcatSplitPath = $tomcatVSFolderPath.Split("\");

$vsName = $tomcatSplitPath[$tomcatSplitPath.Length - 2];

#Write-Output $vsName;

Write-Output ( -join ("Starting LogBackup Script for :", ($vsName)));

$stdOutFileList = Get-ChildItem -Path $tomcatVSFolderPath -Recurse -Filter "*stdout*";

$stdErrFileList = Get-ChildItem -Path $tomcatVSFolderPath -Recurse -Filter "*stderr*";

$allFiles = ($stdOutFileList, $stdErrFileList).Name;

if ($allFiles.Count -gt 0) {

    $dateStr = Get-Date;

    $outputFolderFullPath = ( -join ($targetFolderPath, "\", $dateStr.Year, "\", $dateStr.Month, "\", $dateStr.Day, "\" + $vsName));

   

    if (!(Test-Path $outputFolderFullPath)) {
        mkdir $outputFolderFullPath;
    }

    $existingFileCount = (dir $outputFolderFullPath | measure).Count;

    

    foreach ($fileName in $allFiles) {
        #Check file size

        $srcFile = ( -join ($tomcatVSFolderPath, "\", $fileName));
        $fileSize = ((Get-Item $srcFile).Length/1KB);

        if ($fileSize -gt 0) {

            $existingFileCount = $existingFileCount+1;
            $targetFile = ( -join ($outputFolderFullPath, "\", $fileName));
            #Copy file
            Copy-Item   $srcFile $targetFile;
            $zippedFileName = ( -join ($fileName,$existingFileCount, ".zip"));
    
            #Compress the file in target folder
            Compress-Archive -Path $targetFile  -DestinationPath ( -join ($outputFolderFullPath, "\", $zippedFileName));
    
            #Remove copied file
            Remove-Item -Path $targetFile;

            #Clear the content in original VS folder
            Clear-Content $srcFile;

        }
    
    }
    Write-Output "Done archiving log to path $outputFolderFullPath";
}


