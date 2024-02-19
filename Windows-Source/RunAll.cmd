@pushd ..
call .\DownloadUpdates.cmd w100-x64 glb /includedotnet /includewddefs /verify
@popd
@pushd ..
call .\CopyToTarget.cmd w100-x64 glb "D:\Pilot_Endeldijk\WSUS_Offline" /includedotnet /includewddefs
@popd
