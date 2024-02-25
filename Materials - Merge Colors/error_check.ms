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
		materialArray,
		
		
		
		--Check if the save path is valid:
		fn SavePath_Valid =
		(
			valid_savePath = true --variable that indicates wether the save path is valid or not (true is valid)
			
			if (saveState == 2 or saveState == 3) and ((dotnetclass "System.IO.Directory").exists (getFilenamePath(savePath))) == False do valid_savePath = false
			
			--Message the user if the save path is not valid:
			if valid_savePath == false do MessageBox "Not a valid save path"
			
			--Return either true or false as a value in valid_savePath:
			return valid_savePath
		),--END SavePath_Valid
		
		
		
		
		--Function to check if all material classes selected can be handled:
		fn Approved_MatClasses = 
		(
			approved = true
			
			for theMat in materialArray do
			(
				not_recognized = true
				
				if classOf theMat == PhysicalMaterial do not_recognized = false
				if classOf theMat == StandardMaterial do not_recognized = false
				if classOf theMat == PBRMetalRough do not_recognized = false
				
				if not_recognized == true do
				(
					approved = false
					print (theMat.name as string + " is a material class that is not recognized")
				)
			)
			
			if approved == false do messagebox "Unrecognized material class found. Press F11 for details"
			
			return approved
		)
		
		
		
	)--END struct Error_Check
	
	
	
	
	
)--END script