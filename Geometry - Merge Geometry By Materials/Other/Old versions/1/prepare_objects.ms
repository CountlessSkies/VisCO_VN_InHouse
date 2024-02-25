/*
This struct makes all selected objects unique.
Since geometry is being merged, this will also add geometry to other instances in other places, which might be undesirable.
Also, two objects that are instances of each other cannot be merged

Modifiers also has to be collapsed, otherwise their effect can double up when merging with other objects
*/

(--START script
	
	struct Prepare_Objects
	(
		allObjects,
		
		fn Make_Unique = 
		(
			for the_object in allObjects do
			(
				--Remove instancing to other objects:
				if (InstanceMgr.CanMakeObjectsUnique the_object) == true do InstanceMgr.MakeObjectsUnique the_object #individual
				
				--Make modifiers unique:
				for the_mod in the_object.modifiers do
				(
					if (InstanceMgr.CanMakeModifiersUnique the_object the_mod) == true do InstanceMgr.MakeModifiersUnique the_object the_mod #individual
				)
				
				--collapse stack:
				collapseStack the_object
				
			)--END loop through allObjects
		)--END fn Make_Unique
		
	)--END struct Make_Unique
	
)--END script