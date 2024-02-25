/*
This part of the script will make the savePath fixed and ready for rendering 
*/

(--START script
	
	struct FixSavePath
	(
		--struct variables:
		fixedSavePath, --Contains the save path after it is fixed
		
		--Fix save path:
		fn fn_FixSavePath savePath =
		(
			fixedSavePath = (trimLeft (trimRight (savePath)))
			
		)--END fn_FixSavePath
		
	)--END struct FixSavePath
	
)--END script