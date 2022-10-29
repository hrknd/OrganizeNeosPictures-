# 保管用フォルダのパス 自分用に変えてください
$targetFolder = 'D:\picture\Neos'
$imageList = Get-ChildItem $targetFolder
$localTZ = Get-TimeZone

try
{
    foreach($image in $imageList)
    {
        if($image.PSIsContainer)
        {
            # フォルダは除外
            continue
        }
        $extension = [System.IO.Path]::GetExtension($image.Name);
        if($image.PSIsContainer -or ($extension -ne ".jpg" -and $extension -ne ".png"))
        {
            # jpg,png以外は除外
            Write-Host "Extension :" $extension
            Write-Host "---Not covered files or directories---"
            Write-Host "Detail File Name :" $image.Name
            continue

        }
        # 拡張子なしファイル名に変換する
        $splitExtFileName =  [System.IO.Path]::GetFileNameWithoutExtension($image);
        $ext_name = [System.IO.Path]::GetExtension($image);

        try{
            # ファイル名を日付型に変換する
            $UTCfileNameDateTime = [DateTime]::ParseExact($splitExtFileName,"yyyy-MM-dd HH.mm.ss", $null);
            # ローカルタイムに変換する
            $fileNameDateTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCfileNameDateTime, $localTZ)
        }
        catch
        {
            Write-Host "---This filename is not valid---"
            Write-Host "Detail File Name :" $splitExtFileName
            continue
        }

        # 年と月を抜き出してディレクトリ名を作る
        $subDirectoryName = $fileNameDateTime.ToString("yyyy-MM");
        $localdate_filename = $fileNameDateTime.ToString("yyyy-MM-dd HH.mm.ss");
        Write-Host "yyyyMMDirName:" $subDirectoryName
        $subDirectoryPath = $targetFolder + "\" + $subDirectoryName;
        Write-Host "yyyyMMDirPath:" $subDirectoryPath
        # ディレクトリの存在チェック
        if(-not(Test-Path($subDirectoryPath)))
        {
            # 存在しない場合は作成する
            New-Item $subDirectoryPath -ItemType Directory | Out-Null
        }

        # 画像の移動先のフルパスを作る
        $imagePathTo = $subDirectoryPath + "\" + $localdate_filename + $ext_name;
        # 画像を作ったパスに移動させる
        Move-Item $image.FullName $imagePathTo -ErrorAction Stop
    }

}
catch [Exception]{
    Write-Host "**** ERROR OCCURRED ****"
    $error[0] | Out-string | write-host
}
