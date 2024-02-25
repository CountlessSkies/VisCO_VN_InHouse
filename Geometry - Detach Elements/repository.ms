

(--START script
	
	struct Repository
	(
		
		
		
		fn Update_Meshes collection =
		/*
		This function updates all objects
		*/
		(
			for obj in collection do update obj
		),
		
		
		fn Make_Unique allObjects collapseModifiers = 
		/*
		This function makes all selected objects unique.
		Since geometry is being merged, this will also add geometry to other instances in other places, which might be undesirable.
		Also, two objects that are instances of each other cannot be merged

		Modifiers also has to be collapsed, otherwise their effect can double up when merging with other objects
		*/
		(
			for the_object in allObjects do
			(
				--Remove instancing to other objects:
				if (InstanceMgr.CanMakeObjectsUnique the_object) == true do InstanceMgr.MakeObjectsUnique the_object #individual
				
				/*
				--DISABLED ON PURPOSE. YOU CAN ENABLE IT IF YOU NEED TO TROUBLESHOOT
				--Make modifiers unique:
				for the_mod in the_object.modifiers do
				(
					if (InstanceMgr.CanMakeModifiersUnique the_object the_mod) == true do InstanceMgr.MakeModifiersUnique the_object the_mod #individual
				)
				*/
				
				--collapse stack:
				if collapseModifiers == true do
				(
					--Puts baseObject and its class in variables:
					local theObjectBase = the_object.baseObject
					local theClass = classOf theObjectBase
					
					collapseStack the_object
					
					if theClass == Editable_Poly do convertToPoly the_object
					if theClass == Editable_Mesh do convertToMesh the_object
					
				)
				
			)--END loop through allObjects
			
		)--END fn Make_Unique
		
	)--END struct Make_Unique
	
)--END script