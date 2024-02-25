/*

*/

(--START script

	struct Action
	(
		--Struct arguments from outside:
		main_objects,
		copies_lists,
		
		
		
		
		------------------------------------------------------------------------------------------------------------------------
		fn Fn_Select chkBox_incl_originals =
		(
			chosen_objects = #() --Contains objects that is to be taken action upon
			
			for i in 1 to copies_lists.count where copies_lists[i].count > 0 do
			(
				if chkBox_incl_originals do append chosen_objects main_objects[i]
				for obj in copies_lists[i] do append chosen_objects obj
			)
			
			
			select chosen_objects
		),
		
		------------------------------------------------------------------------------------------------------------------------
		fn Fn_Make_Instances chkBox_incl_originals =
		(
			for i in 1 to main_objects.count do
			(
				main_obj = main_objects[i]
				first_copy = copies_lists[i][1]
				other_copies = (for obj in copies_lists[i] where obj != first_copy collect obj)
				
				if chkBox_incl_originals and first_copy!= undefined do first_copy.baseObject = main_obj.baseObject
				if other_copies.count > 0 do for obj in other_copies do obj.baseObject = first_copy.baseObject
				
				
			)
		),
		
		------------------------------------------------------------------------------------------------------------------------
		fn Fn_Separate_Layers chkBox_incl_originals =
		(
			LayerManager.CloseDialog()
			layerList = for i in 0 to layermanager.count-1 collect (layerManager.getLayer i).name
			
			for i in 1 to main_objects.count do
			(
				main_obj = main_objects[i]
				copies = (for obj in copies_lists[i] collect obj)
				
				main_layer_name = main_obj.layer.name
				main_layer_index = (findItem layerList main_layer_name)
				copies_layer_name = (main_layer_name + "_copies")
				
				if copies.count >0 do 
				(
					LayerManager.newLayerFromName copies_layer_name
					copies_layer = (LayerManager.getLayerFromName copies_layer_name)
					for obj in copies do copies_layer.addNode obj
					if chkBox_incl_originals do copies_layer.addNode main_obj
				)
			)
		),
		
		------------------------------------------------------------------------------------------------------------------------
		fn Fn_Delete chkBox_incl_originals =
		(
			chosen_objects = #() --Contains objects that is to be taken action upon
			
			for i in 1 to copies_lists.count where copies_lists[i].count > 0 do
			(
				if chkBox_incl_originals do append chosen_objects main_objects[i]
				for obj in copies_lists[i] do append chosen_objects obj
			)
			
			
			for i in chosen_objects.count to 1 by -1 do delete chosen_objects[i]
		)
		
		------------------------------------------------------------------------------------------------------------------------
		
	)--END struct Action
	
	
	
	
	
)--END script