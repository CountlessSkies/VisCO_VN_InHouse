/*
This struct can either make an array from a file, or it can make a file from an array.
The text file will be created in the script file´s current location.
*/


struct Arr_From_File
(
	----------------------------------------------------------------------------------------------------------
	--read_file reads a file and returns a dictionary. del_file indicates wether the file should be deleted afterwards or not:
	fn make_arr fileName delimiter del_file:False =
	(
		
		--Get script path and make text file:
		path_thisFile = getSourceFileName() --Gets the full path for currently running script
		dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
		the_path = pathConfig.appendPath dir_script fileName --Combines directory and filename to create a path
		the_file = openFile the_path  mode_string:"r"
		
		--Extract text from file:
		txt_full = ""
		while NOT eof the_file do 
		(
			txt_full += readline the_file
			txt_full += "\n"
		)
		
		--Close and delete text file:
		close the_file
		if del_file == True do deleteFile the_path
		
		--Make array:
		the_arr = #()
		
		--Organizes the extracted text to an array:
		txt_full = txt_full as stringStream
		while (eof txt_full == false) do
		(
			--Reads a line:
			currentLine = (readLine txt_full) as stringStream
			
			--Split string to multiple array items:
			while (eof currentLine == False) do
			(
				the_item = readDelimitedString currentLine delimiter
				--Eliminate spacing errors:
				the_item = (trimLeft (trimRight (toLower (the_item as string))))
				--Insert items into array:
				append the_arr the_item
			)--END while-loop for currentLine
			
		)--END while-loop for txt_full
		
		return the_arr
	),
	
	----------------------------------------------------------------------------------------------------------
	--Read text and make a file:
	fn make_file the_text fileName =
	(
		--Get script path, make text file, and extract text from it:
		path_thisFile = getSourceFileName() --Gets the full path for currently running script
		dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
		the_path = pathConfig.appendPath dir_script fileName --Combines directory and filename to create a path
		
		--Make file:
		the_file = createFile the_path
		
		--Add text to file:
		format the_text to: the_file
		
		--Close file:
		close the_file
	)
	
	----------------------------------------------------------------------------------------------------------
)--END Struct Arr_From_File