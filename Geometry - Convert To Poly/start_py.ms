(--START script

	--Get main script body path:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "main.ms" --Combines directory and filename to create a path
	file_main = fileIn path_script
	
	--Run main:
	file_main.run()
	
)--END script