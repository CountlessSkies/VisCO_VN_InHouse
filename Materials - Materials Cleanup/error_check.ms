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
		
		
		
		
		--Check that objects that are instances of each other has the same material
		fn Same_Mat_On_Instances =
		(
			same_mat = true --variable that indicates wether all instances of each other has the same material
			
			checked_objects = #() --Contains all objects
			
			for obj in allObjects do
			(
				InstanceMgr.GetInstances obj &Instances
				for inst in Instances where obj.material != inst.material do 
				(
					same_mat = false
					
					if (findItem checked_objects obj) == 0 and (findItem checked_objects inst) == 0 do
					(
						print (obj.name + " and " +  inst.name + " does not have the same material ")
					)
					
					append checked_objects obj
					append checked_objects inst
					
				)
			)
			
			--Message the user that not all instances of each other has the same material:
			if same_mat == false do messageBox "Objects that are instances of each other does not have the same material. Open listener (F11) for more info"
			
			--return either true or false as a value in same_mat:
			return same_mat
		),--END Same_Mat_On_Instances
		
		
		
		
		--Check that there are no modifiers that can change material IDs or cause other problems
		fn Forbidden_Modifiers =
		(
			no_forbidden_modifers = true
			
			modifier_list = #(Edit_Mesh, Edit_Patch, Edit_Poly, Materialmodifier)
			
			for obj in allObjects do
			(
				for theMod in obj.modifiers do
				(
					if (findItem modifier_list (classOf theMod)) != 0 do
					(
						no_forbidden_modifers = false
						print (obj.name + " has modifiers that can alter material IDs. Collapse or remove modifiers")
					)
				)--END loop through modifiers
			)--END loop through objects
			
			if no_forbidden_modifers == false do messageBox "Some objects has modifers that can alter material IDs. See listener (F11) for more details"
			
			--Return value false if there are modifiers that can alter material IDs
			return no_forbidden_modifers
		)--END Forbidden_Modifiers
		
		
		
	)--END struct Error_Check
	
	
	
	
	
)--END script