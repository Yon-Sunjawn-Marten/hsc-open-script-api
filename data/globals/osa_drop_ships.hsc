; Copyright 2024 Yon-Sunjawn-Marten
; Close Derivative of original works from halo devs.

; Editor notes. Did you know? when you do (= str str) it does a partial substring match with "_"
; o.O dude wtf. What do you think "equals" means lisp???
; This is probably why ai_enter_vehicle_immediate or similar form can do sub-string matching. Its bs.


(script static void (osa_ds_load_dropship_place (vehicle dropship) (string load_side) (ai load_squad1) (ai load_squad2) (ai load_squad3))
	(ai_place load_squad1)
	(ai_place load_squad2)
	(ai_place load_squad3)
	(sleep 1)
	(osa_ds_load_dropship dropship load_side load_squad1 load_squad2 load_squad3)	
)

(script static void (osa_ds_load_dropship (vehicle dropship) (string load_side) (ai load_squad1) (ai load_squad2) (ai load_squad3))
	(cond 
		((= OSA_DROP_SHIP_PHANTOM (osa_ds_get_vehicle_type dropship))
			(begin 
				(print_if b_debug_dropships "load type phantom")
				(if (or (= load_side "small") (= load_side "large") (= load_side "vany"))
					(begin 
						(print_if b_debug_dropships "load type: cargo")
						(f_load_phantom_cargo dropship load_side load_squad1 load_squad2)
					)
					(begin 
						(print_if b_debug_dropships "load type: infantry")
						(f_load_phantom dropship load_side load_squad1)
					)
				)
			)
		)
		((= OSA_DROP_SHIP_FORK (osa_ds_get_vehicle_type dropship))
			(begin 
				(print_if b_debug_dropships "load type spirit")
				(if (or (= load_side "small") (= load_side "large") (= load_side "vany"))
					(begin 
						(print_if b_debug_dropships "load type: cargo")
						(f_load_fork_cargo dropship load_side load_squad1 load_squad2 load_squad3)
					)
					(begin 
						(print_if b_debug_dropships "load type: infantry")
						(f_load_fork dropship load_side load_squad1)
					)
				)
			)
		)
		((= OSA_DROP_SHIP_PELICAN (osa_ds_get_vehicle_type dropship))
			(begin 
				(print_if b_debug_dropships "load type pelican")
				(if (or (= load_side "small") (= load_side "large") (= load_side "vany"))
					(begin 
						(print_if b_debug_dropships "load type: cargo")
						(f_load_pelican_cargo dropship load_side load_squad1 load_squad2)
					)
					(begin 
						(print_if b_debug_dropships "load type: infantry")
						(f_load_pelican dropship load_side load_squad1)
					)
				)
			)
		)
		(TRUE
			(begin 
				(print "unable to load dropship type")
				(= 0 0)
			)
		)
	)
) ; Your - Wel - come

(script static void (osa_ds_unload_dropship (vehicle dropship) (string load_side))
	(cond 
		((= OSA_DROP_SHIP_PHANTOM (osa_ds_get_vehicle_type dropship))
			(begin 
				(print_if b_debug_dropships "load type phantom")
				(if (or (= load_side "small") (= load_side "large") (= load_side "vany"))
					(f_unload_phantom_cargo dropship load_side)
					(f_unload_phantom dropship load_side)
				)
			)
		)
		((= OSA_DROP_SHIP_FORK (osa_ds_get_vehicle_type dropship))
			(begin 
				(print_if b_debug_dropships "load type spirit")
				(if (or (= load_side "small") (= load_side "large") (= load_side "vany"))
					(f_unload_fork_cargo dropship load_side)
					(f_unload_fork dropship load_side)
				)
			)
		)
		((= OSA_DROP_SHIP_PELICAN (osa_ds_get_vehicle_type dropship))
			(begin 
				(print_if b_debug_dropships "load type pelican")
				(if (or (= load_side "small") (= load_side "large") (= load_side "vany"))
					(f_unload_pelican_cargo dropship load_side)
					(f_unload_pelican dropship)
				)
			)
		)
		(TRUE
			(begin 
				(print "unable to unload dropship type")
				(= 0 0)
			)
		)
	)
	(sleep 90)
); Your - Wel - come

(script static string (osa_ds_get_vehicle_type (vehicle dropship))
	(cond 
		((ai_vehicle_reserve_seat dropship "phantom_p_ml_f" FALSE)
			OSA_DROP_SHIP_PHANTOM
		)
		((ai_vehicle_reserve_seat dropship "fork_p_r" FALSE)
			OSA_DROP_SHIP_FORK
		)
		((ai_vehicle_reserve_seat dropship "pelican_p_l" FALSE)
			OSA_DROP_SHIP_PELICAN
		)
		(TRUE
			(begin 
				(print "FAILED TO FIND SHIP TYPE. is the dropship none?:")
				(inspect (= NONE dropship))
				"NONE"
			)
		)
	)
); Your - Wel - come


; =================================================================================================
; GLOBAL_PHANTOM.HSC
; HOW TO USE:
; 	1. Open your scenario in Sapien
;	2. In the menu bar, open the "Scenarios" menu, then select "Add Mission Script"
;	3. Point the dialogue to this file: main\data\globals\global_phantom.hsc
; =================================================================================================
(global boolean b_debug_dropships false)

;*
== LOAD PARAMETERS ==
1 - LEFT 
2 - RIGHT 
3 - DUAL 
4 - OUT THE CHUTE 
*;

(global string OSA_DROP_SHIP_PHANTOM "phantom")
(global string OSA_DROP_SHIP_FORK "fork")
(global string OSA_DROP_SHIP_PELICAN "pelican")

; call this script to load up the phantom before flying it into position ================================================================
(script static void	(f_load_phantom
								(vehicle dropship)		; phantom to load 
								(string load_side)		; how to load it 
								(ai load_squad_01)		; squads to load 
				)
	
	(if (= load_side "left")
		(begin
			(if b_debug_dropships (print "load phantom left..."))
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_lb")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_lf")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_ml_f")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_ml_b")
		)
	)
	(if (= load_side "right")
		(begin
			(if b_debug_dropships (print "load phantom right..."))
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_rb")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_rf")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_mr_f")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_mr_b")
		)
	)
	(if (= load_side "dual")
		(begin
			(if b_debug_dropships (print "load phantom dual..."))
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_rb")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_rf")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_lf")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_lb")
		)
	)
	(if (= load_side "chute")
		(begin
			(if b_debug_dropships (print "load phantom chute..."))
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_pc_1")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_pc_2")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_pc_3")
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_pc_4")
		)
	)
	(if (= load_side "any")
		(begin
			(if b_debug_dropships (print "load phantom any..."))
			(ai_vehicle_enter_immediate load_squad_01 dropship "phantom_p_")
		)
	)
)

(script static void (f_load_phantom_cargo
										(vehicle phantom)		; the phantom you are loading the cargo in to 
										(string load_number)	; 1 - single load    ---   2 - double load 
										(ai load_squad_01)		; first squad to load 
										(ai load_squad_02)		; second squad to load 
				)
	; place ai 
	
	; load into phantom 
	(cond
		((= load_number "large")	
						(begin
							(vehicle_load_magic phantom "phantom_lc" (ai_vehicle_get_from_squad load_squad_01 0))
						)
		)
		((= load_number "small")	
						(begin
							(vehicle_load_magic phantom "phantom_sc01" (ai_vehicle_get_from_squad load_squad_01 0))
							(vehicle_load_magic phantom "phantom_sc02" (ai_vehicle_get_from_squad load_squad_02 0))
						)
		)
		((= load_number "vany")
			(begin 
				(if (> (ai_living_count load_squad_02) 0)
					(begin 
						(vehicle_load_magic phantom "sc" (ai_vehicle_get_from_squad load_squad_01 0))
						(vehicle_load_magic phantom "sc" (ai_vehicle_get_from_squad load_squad_02 0))
					)
					(vehicle_load_magic phantom "lc" (ai_vehicle_get_from_squad load_squad_01 0))
				)
				
			)
		)
	)
)



; call this script when the phantom is in place to drop off all the ai ====================================================================
(script static void (f_unload_phantom
										(vehicle phantom)
										(string drop_side)
				)
	
	(if b_debug_dropships (print "opening phantom..."))
	(unit_open phantom)
	(sleep 60)
	; determine how to unload the phantom 
	(cond
		((= drop_side "left")	
						(begin
							(f_unload_ph_left phantom)
							(sleep 45)
							(f_unload_ph_mid_left phantom)
							(sleep 75)
						)
		)

		((= drop_side "right")	
						(begin
							(f_unload_ph_right phantom)
							(sleep 45)
							(f_unload_ph_mid_right phantom)
							(sleep 75)
						)
		)

		((= drop_side "dual")
						(begin
							(f_unload_ph_left phantom)
							(f_unload_ph_right phantom)
							(sleep 75)
						)
		)
		((= drop_side "chute")
						(begin
							(f_unload_ph_chute phantom)
							(sleep 75)
						)
		)
		
		((= drop_side "any")
						(begin
							(f_unload_ph_left phantom)
							(f_unload_ph_mid_left phantom)
							(f_unload_ph_right phantom)
							(f_unload_ph_mid_right phantom)
							(f_unload_ph_chute phantom)
							(sleep 75)
						)
		)
	)
	
	(if b_debug_dropships (print "closing phantom..."))
	(unit_close phantom)
	
)

; you never have to call these scripts directly ===========================================================================================
(script static void (f_unload_ph_left
										(vehicle phantom)
				)
	; randomly evacuate the two sides 
	(begin_random
		(begin
			(vehicle_unload phantom "phantom_p_lf")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload phantom "phantom_p_lb")
			(sleep (random_range 0 10))
		)
	)
)
(script static void (f_unload_ph_right
										(vehicle phantom)
				)
	; randomly evacuate the two sides 
	(begin_random
		(begin
			(vehicle_unload phantom "phantom_p_rf")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload phantom "phantom_p_rb")
			(sleep (random_range 0 10))
		)
	)
)
(script static void (f_unload_ph_mid_left
										(vehicle phantom)
				)
	; randomly evacuate the two sides 
	(begin_random
		(begin
			(vehicle_unload phantom "phantom_p_ml_f")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload phantom "phantom_p_ml_b")
			(sleep (random_range 0 10))
		)
	)
)
(script static void (f_unload_ph_mid_right
										(vehicle phantom)
				)
	; randomly evacuate the two sides 
	(begin_random
		(begin
			(vehicle_unload phantom "phantom_p_mr_f")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload phantom "phantom_p_mr_b")
			(sleep (random_range 0 10))
		)
	)
)
(script static void (f_unload_ph_chute
										(vehicle phantom)
				)
	; turn on phantom power 
	(object_set_phantom_power phantom TRUE)
	
	; poop dudes out the chute 

	(if (vehicle_test_seat phantom "phantom_pc_1")	
									(begin
										(vehicle_unload phantom "phantom_pc_1")
										(sleep 120)
									)
	)
	(if (vehicle_test_seat phantom "phantom_pc_2")	
									(begin
										(vehicle_unload phantom "phantom_pc_2")
										(sleep 120)
									)
	)
	(if (vehicle_test_seat phantom "phantom_pc_3")	
									(begin
										(vehicle_unload phantom "phantom_pc_3")
										(sleep 120)
									)
	)
	(if (vehicle_test_seat phantom "phantom_pc_4")	
									(begin
										(vehicle_unload phantom "phantom_pc_4")
										(sleep 120)
									)
	)

	
	; turn off phantom power 
	(object_set_phantom_power phantom FALSE)
									
)

(script static void (f_unload_phantom_cargo
										(vehicle phantom)
										(string load_number)
				)
	; unload cargo seats 
	(cond
		((= load_number "large")	(vehicle_unload phantom "phantom_lc"))
		((= load_number "small")
								(begin_random
									(begin
										(vehicle_unload phantom "phantom_sc01")
										(sleep (random_range 15 30))
									)
									(begin
										(vehicle_unload phantom "phantom_sc02")
										(sleep (random_range 15 30))
									)
								)
		)
		((= load_number "vany")	
			(begin 
				(begin_random
					(vehicle_unload phantom "phantom_lc")
					(vehicle_unload phantom "phantom_sc01")
					(vehicle_unload phantom "phantom_sc02")
					(sleep (random_range 15 30))
					(sleep (random_range 15 30))
					(sleep (random_range 15 30))
				)
			)
		)
	)
)


; =================================================================================================
; GLOBAL_FORK.HSC
; HOW TO USE:
; 	1. Open your scenario in Sapien
;	2. In the menu bar, open the "Scenarios" menu, then select "Add Mission Script"
;	3. Point the dialogue to this file: main\data\globals\global_fork.hsc
; =================================================================================================

;*
== LOAD PARAMETERS ==
LEFT, RIGHT, DEFAULT, LEFT_FULL, RIGHT_FULL, FULL
*;

(script static void (f_load_fork
								(vehicle dropship)
								(string load_side)
								(ai load_squad_01)
				)
	
	(cond
		; left 
		((= load_side "left")
						(begin
							(if b_debug_dropships (print "load fork left..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "fork_p_l")
						)
		)
		; right 
		((= load_side "right")
						(begin
							(if b_debug_dropships (print "load fork right..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "fork_p_r")
							
						)
		)
		; right 
		((= load_side "dual")
						(begin
							(if b_debug_dropships (print "load fork right..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "fork_p_l")
							(ai_vehicle_enter_immediate load_squad_01 dropship "fork_p_r")
						)
		)
		((= load_side "any") ; any
						(begin
							(if b_debug_dropships (print "load fork any..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "fork_p")
						)
		)
	)
)

(script static void (f_load_fork_cargo
										(vehicle fork)		; the phantom you are loading the cargo in to 
										(string load_type)	; 1 - single load    ---   2 - double load 
										(ai load_squad_01)		; first squad to load
										(ai load_squad_02)		; second squad to load 
										(ai load_squad_03)		; third squad to load 
				)
	; place ai 
	
	; load into fork 
	(cond
		((= load_type "large")	
						(begin
							(vehicle_load_magic fork "fork_lc" (ai_vehicle_get_from_squad load_squad_01 0))
						)
		)
		((= load_type "small")	
						(begin
							(vehicle_load_magic fork "fork_sc01" (ai_vehicle_get_from_squad load_squad_01 0))
							(vehicle_load_magic fork "fork_sc02" (ai_vehicle_get_from_squad load_squad_02 0))
							(vehicle_load_magic fork "fork_sc03" (ai_vehicle_get_from_squad load_squad_03 0))
						)
		)
		((= load_type "vany")
			(begin 
				(if (> (ai_living_count load_squad_02) 0)
					(begin 
						(vehicle_load_magic fork "sc" (ai_vehicle_get_from_squad load_squad_01 0))
						(vehicle_load_magic fork "sc" (ai_vehicle_get_from_squad load_squad_02 0))
						(vehicle_load_magic fork "sc" (ai_vehicle_get_from_squad load_squad_03 0))
					)
					(vehicle_load_magic fork "lc" (ai_vehicle_get_from_squad load_squad_01 0))
				)
			)
		)
	)
)

; call this script when the fork is in place to drop off all the ai ====================================================================
(script static void (f_unload_fork
										(vehicle fork)
										(string drop_side)
				)
	
	(if b_debug_dropships (print "opening fork..."))
	(unit_open fork)
	(sleep 30)
	; determine how to unload the phantom 
	(cond
		((= drop_side "left")	
						(begin
							(f_unload_fork_left fork)
							(sleep 75)
						)
		)

		((= drop_side "right")	
						(begin
							(f_unload_fork_right fork)
							(sleep 75)
						)
		)

		((= drop_side "dual")
						(begin
							(f_unload_fork_all fork)
							(sleep 75)
						)
		)
	)
	
	(if b_debug_dropships (print "closing fork..."))
	(unit_close fork)	
)


(script static void (f_unload_fork_left	(vehicle fork))
	(begin_random
		(begin
			(vehicle_unload fork "fork_p_l1")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l2")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l3")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l4")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l5")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l6")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l7")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l8")
			(sleep (random_range 0 10))
		)
	)
)

(script static void (f_unload_fork_right (vehicle fork))
	(begin_random
		(begin
			(vehicle_unload fork "fork_p_r1")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r2")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r3")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r4")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r5")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r6")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r7")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r8")
			(sleep (random_range 0 10))
		)
	)
)

(script static void (f_unload_fork_all	(vehicle fork))
	(begin_random
		(begin
			(vehicle_unload fork "fork_p_l1")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l2")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l3")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l4")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l5")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l6")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l7")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_l8")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r1")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r2")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r3")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r4")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r5")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r6")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r7")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload fork "fork_p_r8")
			(sleep (random_range 0 10))
		)
	)
)

(script static void (f_unload_fork_cargo
										(vehicle fork)
										(string load_type)
				)
	; unload cargo seats 
	(cond
		((= load_type "large")	(vehicle_unload fork "fork_lc"))
		((= load_type "small")
								(begin_random
									(begin
										(vehicle_unload fork "fork_sc01")
										(sleep (random_range 15 30))
									)
									(begin
										(vehicle_unload fork "fork_sc02")
										(sleep (random_range 15 30))
									)
									(begin
										(vehicle_unload fork "fork_sc03")
										(sleep (random_range 15 30))
									)
								)
		)
		((= load_type "small01")
								(vehicle_unload fork "fork_sc01")
		)
		((= load_type "small02")
								(vehicle_unload fork "fork_sc02")
		)
		((= load_type "small03")
								(vehicle_unload fork "fork_sc03")
		)
		((= load_type "vany")
								(begin 
									(vehicle_unload fork "fork_lc")
									(vehicle_unload fork "fork_sc")
									(sleep (random_range 15 30))
									(sleep (random_range 15 30))
								)
		)
	)
)

; =================================================================================================
; GLOBAL_PELICAN.HSC
; HOW TO USE:
; 	1. Open your scenario in Sapien
;	2. In the menu bar, open the "Scenarios" menu, then select "Add Mission Script"
;	3. Point the dialogue to this file: main\data\globals\global_pelican.hsc
; =================================================================================================

(script static void	(f_load_pelican
								(vehicle dropship)		; phantom to load 
								(string load_side)		; how to load it 
								(ai load_squad_01)		; squads to load
				)
	
	(cond
		; left 
		((= load_side "left")
						(begin
							(if b_debug_dropships (print "load pelican left..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "pelican_p_l")
						)
		)
		; right 
		((= load_side "right")
						(begin
							(if b_debug_dropships (print "load pelican right..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "pelican_p_r")
						)
		)
		; right 
		((= load_side "dual")
						(begin
							(if b_debug_dropships (print "load pelican right..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "pelican_p_r")
							(ai_vehicle_enter_immediate load_squad_01 dropship "pelican_p_l")
						)
		)
		((= load_side "any") ; any
						(begin
							(if b_debug_dropships (print "load pelican passengers..."))
							(ai_vehicle_enter_immediate load_squad_01 dropship "pelican_p")
						)
		)
		(TRUE
			(begin 
				(print "error loading pelican")
			)
		)
	)
				
)


(script static void (f_unload_pelican	(vehicle pelican))
	(unit_open pelican)
	(sleep 60)
	(begin_random
		(begin
			(vehicle_unload pelican "pelican_p_l01")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_l02")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_l03")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_l04")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_l05")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_r01")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_r02")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_r03")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_r04")
			(sleep (random_range 0 10))
		)
		(begin
			(vehicle_unload pelican "pelican_p_r05")
			(sleep (random_range 0 10))
		)
	)
)

; new pelican global scripts =======================================================================================================================================

(script static void (f_load_pelican_cargo
										(vehicle pelican)		; the phantom you are loading the cargo in to 
										(string load_type)	; 1 - single load    ---   2 - double load 
										(ai load_squad_01)		; first squad to load
										(ai load_squad_02)		; second squad to load 
				)
	; load into fork 
	(cond
		((or (= load_type "large") (= load_type "vany"))	
						(begin
							(vehicle_load_magic pelican "pelican_lc" (ai_vehicle_get_from_squad load_squad_01 0))
						)
		)
		((= load_type "small")	
						(begin
							(print "pelican: no support for small cargo.")
							; (vehicle_load_magic pelican "pelican_lc_01" (ai_vehicle_get_from_squad load_squad_01 0))
							; (vehicle_load_magic pelican "pelican_lc_02" (ai_vehicle_get_from_squad load_squad_02 0))
						)
		)
	)
)

(script static void (f_unload_pelican_cargo
										(vehicle pelican)
										(string load_type)
				)
	; unload cargo seats 
	(cond
		((or (= load_type "large") (= load_type "vany"))	(vehicle_unload pelican "pelican_lc"))
		((= load_type "small")
								; (begin_random
								; 	(begin
								; 		(vehicle_unload pelican "pelican_lc_01")
								; 		(sleep (random_range 15 30))
								; 	)
								; 	(begin
								; 		(vehicle_unload pelican "pelican_lc_02")
								; 		(sleep (random_range 15 30))
								; 	)
								; )
								(print "pelican: no support for small cargo.")
		)
		;*
		((= load_type "small01")
								(vehicle_unload fork "pelican_lc_01")
		)
		((= load_type "small02")
								(vehicle_unload fork "pelican_lc_02")
		)
		*;
	)
)
