(--START script
	
	
	var_run
	--var_run is a variable that contains the function "run". This variable is declared in the beginning so the memory space is reserved for it.
	--That enables interface.ms to point to var_run instead of "run" directly, and thereby use it before its declared
	
	
	
	--Import interface:
	include "interface_mxs.ms"
	--Create dialogbox:
	createDialog rollout_main 400 310
	
	
	
	
	--Import the main body of the script:
	include "main.ms"
	
	
	
	
)--END script