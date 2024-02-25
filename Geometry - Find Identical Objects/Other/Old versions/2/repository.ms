/*
Contains general functions
*/

(--START script

	struct Repository
	(
		
		
		fn getFaceSmoothGroupB obj face = --returns a bitArray with all activated smoothing groups for the face
		(
			local sgroup_val=getFaceSmoothGroup obj face
			local sg_bitarray=#{}
			
			if sgroup_val < 0 do
			(
				sg_bitarray[32]=true
				sgroup_val -= 2^31
			)
			
			for i = 1 to 31 do
			(
				sg_bitarray[i]= (mod sgroup_val 2 > .5)
				sgroup_val /= 2
			)
			
			return sg_bitarray
		)
		
		
		
	)
	
	
)--END script