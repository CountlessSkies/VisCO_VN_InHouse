/*
Starts the script.
*/


(--START script

	--Get interface path:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "interface_mxs.ms" --Combines directory and filename to create a path
	file_interface_mxs = fileIn path_script
	
	--Create dialogbox:
	createDialog file_interface_mxs 500 310
	
)--END script