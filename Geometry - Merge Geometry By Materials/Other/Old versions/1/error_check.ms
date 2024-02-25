/*
Error check functions will return either true or false.
A false return will be used in the interface to halt the script.
*/

(--START script

	struct Error_Check
	(
		allObjects,
		saveState,
		savePath,
		
		
		------------------------------------------------------------------------------------------------
		--Check if the save path is valid:
		fn SavePath_Valid =
		(
			valid_savePath = true --variable that indicates wether the save path is valid or not (true is valid)
			
			if (saveState == 2 or saveState == 3) and ((dotnetclass "System.IO.Directory").exists (getFilenamePath(savePath))) == False do valid_savePath = false
			
			--Message the user if the save path is not valid:
			if valid_savePath == false do MessageBox "Not a valid save path"
			
			--Return either true or false as a value in valid_savePath:
			return valid_savePath
		)--END SavePath_Valid
		
		
		
		
		
		
		
		
		
		
	)--END struct Error_Check
	
	
	
	
	
)--END script