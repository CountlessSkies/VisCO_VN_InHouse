/*
This struct can either make a dictionary from a file, or it can make a file from a dictionary.
The text file will be created in the script file´s current location.
When it reads or creates a text file, it has to\will be in this form: <key> <delimiter> <value> (Without spaces)
*/


struct Dict_From_File
(
	----------------------------------------------------------------------------------------------------------
	--read_file reads a file and returns a dictionary. del_file indicates wether the file should be deleted afterwards or not:
	fn make_dict ini_fileName delimiter del_file:False =
	(
		
		--Get script path and make text file:
		path_thisFile = getSourceFileName() --Gets the full path for currently running script
		dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
		path_ini = pathConfig.appendPath dir_script ini_fileName --Combines directory and filename to create a path
		the_file = openFile path_ini  mode_string:"r"
		
		--Extract text from file:
		txt_full = ""
		while NOT eof the_file do 
		(
			txt_full += readline the_file
			txt_full += "\n"
		)
		
		--Close and delete text file:
		close the_file
		if del_file == True do deleteFile path_ini
		
		--Make dictionary:
		the_dict = Dictionary (#string)
		
		--Organizes the extracted text to a dictionary:
		txt_full = txt_full as stringStream
		while (eof txt_full == false) do
		(
			--Reads a line:
			currentLine = (readLine txt_full) as stringStream
			
			--Split string:
			key = readDelimitedString currentLine delimiter --First part of the line is put into variable key
			val = readDelimitedString currentLine delimiter --Second part of the line is put into variable val
			
			--Eliminate spacing errors:
			key = (trimLeft (trimRight (toLower (key as string))))
			val = (trimLeft (trimRight (toLower (val as string))))
			
			--Converts values stored as text into correct class:
			tempVal = undefined
			try ( tempVal = (execute val) ) catch ()
			if tempVal != undefined do val = tempVal
			
			--Insert keys and values into the dictionary:
			the_dict[key] = val
		)
		
		return the_dict
	),
	
	----------------------------------------------------------------------------------------------------------
	--Read dictionary and make a file:
	fn make_file the_dict ini_fileName delimiter =
	(
		--Make a text string (txt) from dictionary:
		txt = ""
		for key in the_dict.keys do
		(
			txt += key
			txt += delimiter
			txt += the_dict[key] as string --Gets value
			txt += "\n"
		)
		
		--Get script path, make text file, and extract text from it:
		path_thisFile = getSourceFileName() --Gets the full path for currently running script
		dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
		path_ini = pathConfig.appendPath dir_script ini_fileName --Combines directory and filename to create a path
		
		--Make file:
		the_file = createFile path_ini
		
		--Add text to file:
		format txt to: the_file
		
		--Close file:
		close the_file
	)
	
	----------------------------------------------------------------------------------------------------------
)--END Struct Dict_From_File