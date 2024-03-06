; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_utils
; include osa_drop_ships
; include osa_ai_director
; include osa_transport_pool
; include osa_firefight_incidents

; A director for firefight mode, it only triggers events and manages enemy spawning.

;; Do not create objectives for generator mode if you don't include the script for it.

; Editor Notes:
;; you can migrate groups into a squad. Only that way.
;; BUT you can also migrate groups/squads of opposing teams into the SAME DAMN SQUAD.
;; I think because technically the engine considers a squad as an encounter.
;; This means that you can share the same objectives between different teams.
;; Use this knowledge to your advantage.
;; However beware if you use MAX count for a task, as you may get all of one team to show up.

; There is a stack depth limiting the number of chained static void calls. FYI CRITICAL.
; Dormant/Startup/Continous scripts all starting point for this.
; 7 script calls on top of your starting script. This could be bad for my for loops :S

; (script dormant test_loop
;     (test_for_loop 0)
; )

; (script static void (test_for_loop (short index))
;     (inspect index)
;     (if (< index 20)
;         (test_for_loop (+ index 1))
;     )
; )
; I ran these scripts and found that it expired on index 11.
; ... so.. thats why the devs didn't use for-loops. fk.




;; ========================== REQUIRED in Sapien ==================================
; REQUIRED AI/Squad Groups
; If you intend to use FF plugin:
; waves go to gr_warzone_remaining at end of wave. Used to trigger some objective tasks that make the AI come near you.
; generally waves spawn in separate squads and thus can attempt tasks that are limited to 4 ai for ex.
; gr_warzone_remaining might fill up to more than 4, so they would be ineligible to do them.
; not setting a task limit can result in a rush with dozens of combatants, user beware.
; gr_warzone_remaining     -> gr_dir_elites

; gr_warzone_waves         -> gr_dir_elites
; gr_warzone_bonus         -> gr_dir_elites

; intf_ff_objective -- the objective with a hold_task

; intf_plugin_ff_hazard_spawn_0 - You have to implement a stub when its sent a var IM SORRY. Sapien is glitching out during compile


; you are requred to implement this script. Part of a compile bug. (not my bug -_-)
; (script static void (intf_plugin_ff_hazard_spawn_0 (vehicle phantom))
    ; (print_if dbg_ff "intf_plugin_ff_hazard_spawn_0")
; ) ;; use this script to supply hazard squads or vehicles to phantoms when spawning.


;; -------------------------- REQUIRED in Sapien ----------------------------------



;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---
(global ai intf_gr_ff_waves NONE) ; So this is a group parent over fireteams, ai_place_in_limbo will fill them JUST by giving the group, which is cool.
(global ai intf_sq_ff_remain NONE) ; The remainders squad that survivors get piled into after each wave

(global ai intf_sq_ff_bonus NONE) ; bonus squad.

; phantom squad definitions 
(global ai intf_sq_phantom_01 NONE)
(global ai intf_sq_phantom_02 NONE)
(global ai intf_sq_phantom_03 NONE)
(global ai intf_sq_phantom_bonus NONE)
(global boolean intf_t_bonus_random TRUE)


; define how the phantoms are loaded. Use the corresponding unload for the transport pool.
(global string intf_drop_side_01 "dual")
(global string intf_drop_side_02 "dual")
(global string intf_drop_side_03 "dual")
;; ---  OUTPUT VARS        ---

(global vehicle intf_sq_ph_1_current NONE)
(global vehicle intf_sq_ph_2_current NONE)
(global vehicle intf_sq_ph_3_current NONE)

; ======== Interfacing Scripts ========
; reserved means that another script uses it if added. You can still use it.
(global boolean osa_ff_checksum_pass TRUE)
(script static boolean osa_ff_checksum
    (if (= intf_gr_ff_waves NONE)
        (begin 
			(print "Interface missing required connection: <squad group> intf_gr_ff_waves")
			(set osa_ff_checksum_pass FALSE)
		)
    )
    (if (= intf_sq_ff_remain NONE)
        (begin 
			(print "Interface missing required connection: <squad> intf_sq_ff_remain")
			(set osa_ff_checksum_pass FALSE)
		)
    )
    (if (= intf_sq_ff_bonus NONE)
        (begin 
			(print "Interface missing required connection: <squad> intf_sq_ff_bonus")
			(set osa_ff_checksum_pass FALSE)
		)
    )
) ; intf checksum required on all scripts supporting null protection.

; if using vscode editor, just collapse these intf functions.
(script static void (intf_load_ff (boolean dbg_en))
    (print "firefight/warzone loading...")
	(set dbg_ff dbg_en)
	(print_if dbg_en "Debug-Enabled")
	(osa_ff_checksum)
	(if osa_ff_checksum_pass
		(begin 
			(survival_mode_set_elite_license_plate 37 29 sur_game_name sur_cov_gen_desc elite_icon)
			(survival_mode_set_spartan_license_plate 37 28 sur_game_name sur_unsc_gen_desc spartan_icon)
			(set s_sur_loader_loop_max (ai_squad_group_get_squad_count intf_gr_ff_waves))
			(set osa_phm_idx_01 (intf_pool_get_thread_from_sq intf_sq_phantom_01))
			(set osa_phm_idx_02 (intf_pool_get_thread_from_sq intf_sq_phantom_02))
			(set osa_phm_idx_03 (intf_pool_get_thread_from_sq intf_sq_phantom_03))
			(wake osa_ff_main_loop)
		)
		(print "warzone checksum failed, module will not load.")
	)
); REQUIRED SCRIPT CALL THIS IN YOUR MAIN INIT FILE.

(script static void intf_ff_force_use_transports
	(set s_sur_dropship_force_on true)
)

(script stub void intf_plugin_ff_kill_volumes_on
	(print_if dbg_ff "**turn on kill volumes**")
)
(script stub void intf_plugin_ff_kill_volumes_off
	(print_if dbg_ff "**turn off kill volumes**")
)
(script stub void intf_plugin_ff_vehicle_cleanup
	(print_if dbg_ff "**vehicle cleanup**")
)

(script stub void plugin_osa_resupply
	(print_if dbg_ff "Warzone round start plugin 0")
); used by resupply plugin

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------


;; ========================== PUBLIC VARIABLES Read-Only ==================================


;; ========================== Internal Use CONSTANTS/VARS ==================================

(global short osa_track_lives_reward 0)

(global short S_SUR_AI_WEAK 10) ; triggers that look for weak AI presence will trigger.
; sets how many ai can be alive before the next wave will spawn 
(global short k_sur_ai_rand_limit 4)
(global short k_sur_ai_final_limit 0)

; controls the number of rounds per set 
(global short k_sur_wave_per_round_limit 5)

; These timers are generally cumulative
(global short k_sur_wave_timer 180)		; Delay following every wave
(global short k_sur_round_timer 150)	; Delay following every round
(global short k_sur_set_timer 300)		; Delay following every set
(global short k_sur_bonus_timer 150)	; Delay following every bonus round

(global boolean s_sur_dropship_force_on false)
(global short s_sur_loader_loop_idx 0)
(global boolean s_sur_loader_loop_done false)
(global boolean s_sur_loader_spawn_done false)
(global short s_sur_loader_loop_max 20)
(global ai s_sur_ai_load_squad NONE)

; dropship spawn logic controls. Actually applies to spirits too
(global boolean b_phantom_spawn TRUE)
(global short b_phantom_spawn_count 0)
(global short b_wave_spawn_count 0)
(global short osa_phm_idx_01 0)
(global short osa_phm_idx_02 0)
(global short osa_phm_idx_03 0)

;============================================ MAIN LOOP ===============================================================
; MAIN SURVIVAL MODE SCRIPT 
(script dormant osa_ff_main_loop
	;; When testing this, pls load up the original firefight maps and run them.
	;; Some of the resources are not loading for FF mode, sapien will load them if you do an original ff map first.
	;; A sign of this: The HUD for FF doesn't show up.
	(print "WARZONE START")
	(wake osa_detect_player_spawn) ;; don't block game loop for this bc we want elites to be able to play alone.
	(wake survival_elite_life_monitor)

	; Set allegiances
	(ai_allegiance human player)
	(ai_allegiance player human)
	(ai_allegiance covenant covenant_player)
	(ai_allegiance covenant_player covenant)

	; ai_enable_stuck_flying_kill group TRUE
	
	; Activate custom goals/endgame
	(intf_plugin_ff_goal_custom_0)
	(intf_plugin_ff_goal_custom_1)
	
	; Blink
	(sleep 1)

	; announce survival mode 
	(sleep (* 30 1))
	(event_welcome)
	(sleep (* 30 2))
	(event_intro)

	; wake secondary scripts
	; (wake survival_bonus_round_end) ;; watches for end and closes bonus round.
	; (wake survival_bonus_round_dropship) ;; continuously watches for available dropship to spawn bonus.
	(wake survival_score_attack) ; -> osa_utils.hsc
	
	; begin delay timer 
	(sleep (* 30 3))
	
	; main wave loop SET Encapsulation.	
	(sleep_until
		(begin		
			(print_if dbg_ff "beginning new set")
			(survival_mode_begin_new_set)
			(sleep 1)
				
			(plugin_osa_resupply)
			
			; BEGIN WAVE LOOP
			; At this point we are at the BEGINNING OF A SET, WAVE 1
			(survival_wave_loop)
			; END WAVE LOOP
			; At this point we are at the END OF A SET, AFTER BONUS WAVE COMPLETE
			
			(wake osa_utils_replenish_players) ; for loop
			(sleep k_sur_set_timer)
	
			; Set loop, runs forever
			; Game over conditions are handled in survival_end_game
			FALSE
		)	
		1
	)
)


;============================================ ROUND SPAWNER ===============================================================

;*
So, the engine knows this:
- What set it is
- What wave it is within that set
- Whether that wave is an Initial, Primary, Boss, or Bonus wave
- For any given wave, what wave template it should use (ie. it handles the randomness)

It is always the case that:
- The wave order is (INITIAL, PRIMARY, PRIMARY, PRIMARY, BOSS)x3, BONUS
- The old Round rewards are granted after a BOSS wave is cleared
- The Bonus rewards are granted after a BONUS wave is cleared

The jurisdiction of this script ends after the bonus wave is complete.
*;


(script static void survival_wave_loop

	; reset wave number 
	(print_if dbg_ff "resetting wave variables...")

	; Wave repeat loop
	(sleep_until
		(begin
			; Advance the wave
			(survival_mode_begin_new_wave)
			; At this point, the current wave is SET UP AND READY TO SPAWN.
			(print "start new wave spawn")
			; (ai_erase intf_gr_ff_waves)
			
			(set s_survival_state_wave 1)
			(wake survival_garbage_collector)
			(sleep_until 
				(begin 
					(print "Can spawn dropship waves. How many squads?")
					(inspect b_wave_spawn_count)
					(print "wave id:")
					(inspect (survival_mode_get_wave_squad))
					(set b_wave_spawn_count (intf_director_max_squads_of_four OSA_DIR_SIDE_ELITE))
					(> b_wave_spawn_count 0)
				)
			)
			; If this is a dropship wave, handle that side of things
			(if (wave_dropship_enabled) (survival_dropship_spawner))
			(wake survival_wave_spawn) ; this was made parallel because the stack overflowed.
			(wake survival_wave_load_dropships)
			(sleep_until 
				s_sur_loader_loop_done
			) ; sleep to let phantoms spawn.
			(set s_sur_loader_loop_done false)
			(print_if dbg_ff "Load hazards if applicable.")
	
	
			(if (> (ai_living_count intf_sq_phantom_01) 0)
				(intf_plugin_ff_hazard_spawn_0 intf_sq_ph_1_current)
			)
			
			(if (> (ai_living_count intf_sq_phantom_02) 0)
				(intf_plugin_ff_hazard_spawn_0 intf_sq_ph_2_current)
			)
			
			(if (> (ai_living_count intf_sq_phantom_03) 0)
				(intf_plugin_ff_hazard_spawn_0 intf_sq_ph_3_current)
			)
			; Sleep until dropships have dropped off their squads
			(sleep_until 
				(begin 
					(print_if dbg_ff "wait for phantoms to exit scene.")
					(= (+ (ai_living_count intf_sq_phantom_01) (ai_living_count intf_sq_phantom_02) (ai_living_count intf_sq_phantom_03)) 0)
				)
			)
			
			; Sleep until wave end conditions are met
			(survival_wave_end_conditions)
			
			; Migrate remaining AI into a unique squad and squad group 
			(ai_migrate_persistent intf_gr_ff_waves intf_sq_ff_remain)
			
			; End wave
			(survival_mode_end_wave)
			(set s_survival_state_wave 2)
				
			; Sleep set amount of time [unless this is the last wave] 
			(if 
				(and
					(< (survival_mode_wave_get) k_sur_wave_per_round_limit)
					(< (survival_mode_set_get) (- (survival_mode_get_set_count) 1))
				)
				(sleep k_sur_wave_timer)
			)

			; At this point the wave has spawned and been defeated.
			
			; Kill this loop if we're past the end condition count
			; Prevents more loop business from happening
			(if 
				(and
					(> (survival_mode_get_set_count) 0)
					(>= (survival_mode_set_get) (survival_mode_get_set_count))	
				)
				(begin
					(sleep_forever)
				)
			)
		
			; Completed an initial wave?
			(if (survival_mode_current_wave_is_initial)
				(begin
					; TODO put the real stuff here
					(print "completed an initial wave")
				)
			)
		
			; Completed a boss wave?
			(if (survival_mode_current_wave_is_boss)
				(begin
					(intf_plugin_ff_vehicle_cleanup)
					(survival_add_lives)
					(wake osa_utils_replenish_players) ; for loop
					; If this isn't the last boss wave in the round,
					(if (< (survival_mode_round_get) 2)	
						(begin
							(plugin_osa_resupply)
							(sleep k_sur_round_timer)
						)
					)
				)
			)
			
			; Condition: stop looping after 3 rounds
			(and
				(>= (survival_mode_round_get) 2) ; Zero indexed
				(>= (survival_mode_wave_get) 4) ; Zero indexed
			)
		)
		1
	)
	
	; Bonus wave
	(sleep k_sur_bonus_timer)
	; (survival_bonus_round)
	
	; Kill this loop if we're past the end condition count
	; Prevents more loop business from happening
	(if 
		(and
			(> (survival_mode_get_set_count) 0)
			(>= (survival_mode_set_get) (survival_mode_get_set_count))	
		)
		(begin
			(sleep_forever)
		)
	)
	
	;tysongr - 53951: Moving the bonus lives awarded to the end of the set
	; Add additional lives
	(survival_add_lives)
)


; Setup and spawn a wave, then babysit it until it ends
(script continuous survival_wave_spawn
	(sleep_forever)
	(set s_sur_loader_spawn_done false)
	(print_if dbg_ff "spawn wave...")
	(if (wave_dropship_enabled)
		(ai_place_wave_in_limbo (survival_mode_get_wave_squad) intf_gr_ff_waves b_wave_spawn_count)
		(ai_place_wave (survival_mode_get_wave_squad) intf_gr_ff_waves b_wave_spawn_count)
	)
	(sleep 1)
	(print_if dbg_ff "Wave spawn complete!")
	(set s_sur_loader_spawn_done true)
	
)

(script continuous survival_wave_load_dropships
	(sleep_forever)
	(print_if dbg_ff "Load dropships.")
	; Load the dropships as appropriate
	(sleep_until s_sur_loader_spawn_done 1)
	(if (wave_dropship_enabled)
		(survival_dropship_loader_loop)
	 	(set s_sur_loader_loop_done true)
	)
	(sleep 1)
)

; === wave end parameters =====================================================
(script static short survival_wave_living_count
	(+ 
		(ai_living_count intf_gr_ff_waves) 
		(ai_living_count intf_sq_ff_remain)
	)	
)

(script static void survival_wave_end_conditions
	; clean out the spawn rooms when there are less than 10 AI remaining 
	(print "wave end conditions")
	(sleep_until (< (survival_wave_living_count) 7))
	(print_if dbg_ff "wave end. start cleanup")
	(ai_survival_cleanup intf_gr_ff_waves TRUE TRUE) ;; detect ai stuck in limbo
	(ai_survival_cleanup intf_sq_ff_remain TRUE TRUE)
	(intf_plugin_ff_kill_volumes_on)

	(cond

		; WAVE 4: last random wave of the final round (index 3)
		((= (survival_mode_wave_get) (- k_sur_wave_per_round_limit 2))
					(begin
						(sleep_until (<= (survival_wave_living_count) k_sur_ai_final_limit))
					)
		)
		
		; FINAL WAVE: final wave of each round sleep until all AI are dead (index 4)
		((or
			(>= (survival_mode_wave_get) (- k_sur_wave_per_round_limit 1))
			(and
				(> (survival_mode_get_set_count) 0)
				(>= (survival_mode_set_get) (- (survival_mode_get_set_count) 1))	
			)
		)
				
			; countdown to final AI 
			(begin
				(sleep_until (<= (survival_wave_living_count) 5) 1)
					(if	(and (<= (survival_wave_living_count) 5) (> (survival_wave_living_count) 2))
							(begin
								(event_survival_5_ai_remaining)
								(intf_utils_callout_object_p intf_gr_ff_waves (osa_utils_get_marker_type "enemy"))
								(intf_utils_callout_object_p intf_sq_ff_remain (osa_utils_get_marker_type "enemy"))
							)
							;(sleep 30)
					)
					(sound_looping_set_alternate m_final_wave TRUE)
					
				(sleep_until (<= (survival_wave_living_count) 2) 1)
					(if	(= (survival_wave_living_count) 2)
							(begin
								(event_survival_2_ai_remaining)
								(intf_utils_callout_object_p intf_gr_ff_waves (osa_utils_get_marker_type "enemy"))
								(intf_utils_callout_object_p intf_sq_ff_remain (osa_utils_get_marker_type "enemy"))
							)
							;(sleep 30)
					)
					
				(sleep_until (<= (survival_wave_living_count) 1) 1)
					(if	(= (survival_wave_living_count) 1)
							(begin
								(event_survival_1_ai_remaining)
								(intf_utils_callout_object_p intf_gr_ff_waves (osa_utils_get_marker_type "enemy"))
								(intf_utils_callout_object_p intf_sq_ff_remain (osa_utils_get_marker_type "enemy"))
							)
							;(sleep 30)
					)
					
				(sleep_until (<= (survival_wave_living_count) 0))
			)
		)
		
		; END WAVE: all other waves 
		(TRUE
					(begin
						(sleep_until (<= (survival_wave_living_count) k_sur_ai_rand_limit))
					)

		)
	)
	(intf_plugin_ff_kill_volumes_off)
	(ai_survival_cleanup intf_gr_ff_waves FALSE FALSE)
	(ai_survival_cleanup intf_sq_ff_remain FALSE FALSE)

)
; --- wave end parameters ---------------------------------------------------==

;================================== PHANTOM SPAWNING / LOADING ================================================================
; Dropships. These can be Phantoms or Spirits depending on scenario settings, but are named "phantom" for legacy support purposes.


; =============== phantom spawn script =============================================

; randomly pick from the available phantoms 
(script static void survival_dropship_spawner
	; reset phantom spawn variables to initial conditions 
	(set b_phantom_spawn TRUE)
	(set b_phantom_spawn_count 0)
	; spawn all phantoms 
	(sleep_until
		(begin
			(begin_random
				(if b_phantom_spawn		(f_survival_dropship_spawner intf_sq_phantom_01))
				(if b_phantom_spawn		(f_survival_dropship_spawner intf_sq_phantom_02))
				(if b_phantom_spawn		(f_survival_dropship_spawner intf_sq_phantom_03))
			)
			
		(= b_phantom_spawn FALSE))
	1)
	(sleep 30) ;; sleep 1 second so AI can engage with the cs_script.
	(if (> (ai_living_count intf_sq_phantom_01) 0)
		(begin 
			(if (= 0 osa_phm_idx_01)
				(set intf_sq_ph_1_current intf_pool_t_vehicle_0)
			)
			(if (= 1 osa_phm_idx_01)
				(set intf_sq_ph_1_current intf_pool_t_vehicle_1)
			)
			(if (= 2 osa_phm_idx_01)
				(set intf_sq_ph_1_current intf_pool_t_vehicle_2)
			)
			(if (= 3 osa_phm_idx_01)
				(set intf_sq_ph_1_current intf_pool_t_vehicle_3)
			)
		)
	)
	
	(if (> (ai_living_count intf_sq_phantom_02) 0)
		(begin 
			(if (= 0 osa_phm_idx_02)
				(set intf_sq_ph_2_current intf_pool_t_vehicle_0)
			)
			(if (= 1 osa_phm_idx_02)
				(set intf_sq_ph_2_current intf_pool_t_vehicle_1)
			)
			(if (= 2 osa_phm_idx_02)
				(set intf_sq_ph_2_current intf_pool_t_vehicle_2)
			)
			(if (= 3 osa_phm_idx_02)
				(set intf_sq_ph_2_current intf_pool_t_vehicle_3)
			)
		)
	)
	
	(if (> (ai_living_count intf_sq_phantom_03) 0)
		(begin 
			(if (= 0 osa_phm_idx_03)
				(set intf_sq_ph_3_current intf_pool_t_vehicle_0)
			)
			(if (= 1 osa_phm_idx_03)
				(set intf_sq_ph_3_current intf_pool_t_vehicle_1)
			)
			(if (= 2 osa_phm_idx_03)
				(set intf_sq_ph_3_current intf_pool_t_vehicle_2)
			)
			(if (= 3 osa_phm_idx_03)
				(set intf_sq_ph_3_current intf_pool_t_vehicle_3)
			)
		)
	)
)



; =============== phantom spawn script =============================================

; spawn a single phantom 
(script static void (f_survival_dropship_spawner (ai spawned_phantom))
	(if (and (!= NONE spawned_phantom) (= (ai_living_count spawned_phantom) 0))
		(begin 
			(ai_place spawned_phantom)
			(sleep 1)
			(ai_force_active spawned_phantom TRUE)
			(if (> (ai_living_count spawned_phantom) 0)
				(begin
					(print_if dbg_ff "spawn phantom...")
					(set b_phantom_spawn_count (+ b_phantom_spawn_count 1))
					(if (>= b_phantom_spawn_count OSA_USE_TRANSPORT_ELITES) (set b_phantom_spawn FALSE))
				)
			)
		)
	)
)


; =============== phantom load scripts =============================================

(global boolean b_dropship_loaded FALSE)
(global boolean b_dropship_check_seats TRUE)
(global short s_dropship_current 1)

(script static void survival_dropship_loader_loop
	; For each squad, it if exists, load it
	(set s_sur_loader_loop_done false)
	(print_if dbg_ff "Wave Loader:")
	(set s_sur_loader_loop_idx 0)
	(sleep_until 
		(begin 
			(if dbg_ff
				(inspect s_sur_loader_loop_idx)
			)
			(set s_sur_ai_load_squad (ai_squad_group_get_squad intf_gr_ff_waves s_sur_loader_loop_idx))
			(if (> (ai_living_count s_sur_ai_load_squad) 0) 
				(f_survival_dropship_loader s_sur_ai_load_squad)
			)
			(set s_sur_loader_loop_idx (+ s_sur_loader_loop_idx 1))
			(>= s_sur_loader_loop_idx s_sur_loader_loop_max)
		)
		1
	)
	(set s_sur_loader_loop_done true)
	(print_if dbg_ff "Wave Loader finished")
)


(script static void (f_survival_dropship_loader (ai load_squad))
	(set b_dropship_check_seats TRUE)
	(print_if dbg_ff "Attempt to load dropship with squad")
	(sleep_until
		(begin
			; attempt to load dropship 01 
			(if (= s_dropship_current 1)
				(begin 
					(print_if dbg_ff "attempt to load dropship 1")
					(survival_attempt_load intf_sq_ph_1_current intf_drop_side_01 load_squad b_dropship_check_seats)
				)
				
			)
			(if (= s_dropship_current 2)
				(begin 
					(print_if dbg_ff "attempt to load dropship 2")
					(survival_attempt_load intf_sq_ph_2_current intf_drop_side_02 load_squad b_dropship_check_seats)
				)
			)
			(if (= s_dropship_current 3)
				(begin 
					(print_if dbg_ff "attempt to load dropship 3")
					(survival_attempt_load intf_sq_ph_3_current intf_drop_side_03 load_squad b_dropship_check_seats)
				)
			)
			(if (>= s_dropship_current 3)
				(set s_dropship_current 1)
				(set s_dropship_current (+ s_dropship_current 1))
			)
			(set b_dropship_check_seats FALSE) ;; fails first pass through? Force load anywhere
			b_dropship_loaded
		)
		1
	)

	; reset loaded variable 
	(set b_dropship_loaded FALSE)
	(print_if dbg_ff "Dropship load succeed")
	
)

(script static void (survival_attempt_load
								(vehicle dropship)
								(string load_side)
								(ai load_squad)
								(boolean test_seat)
							)
	
	(if (>= (object_get_health dropship) 0)
		(if (> (list_count (ai_actors load_squad)) 0)
			(begin 
				(print_if dbg_ff "Loader Passed Inspection: Load the squad")
				; Assign the squad to the hold task to make sure they can be loaded
				(survival_set_hold_task load_squad)
				; Take the AI out of limbo
				(if test_seat
					(begin 
						(print_if dbg_ff "Load Dropship...")
						(ai_exit_limbo load_squad)
						(sleep 1)
						(osa_ds_load_dropship dropship load_side load_squad NONE NONE)
						(set b_dropship_loaded TRUE)
					)
					(begin 
						(print_if dbg_ff "Load Dropship...")
						(ai_exit_limbo load_squad)
						(sleep 1)
						(osa_ds_load_dropship dropship "any" load_squad NONE NONE)
						(set b_dropship_loaded TRUE)
					)
				)
			)
			(set b_dropship_loaded TRUE)
		)
	)
)


(script static boolean wave_dropship_enabled
	(if s_sur_dropship_force_on
		true
		(survival_mode_current_wave_uses_dropship)
	)
)

; ==============================================================================================================
; ====== SECONDARY SCIRPTS =====================================================================================
; ==============================================================================================================
; Do nothing task -- for loading AI onto ships
(script static void (survival_set_hold_task (ai squad))
	(ai_set_task squad intf_ff_objective hold_task)
)

;=============================================================================================================================
;============================================ LIVES AND LIVING COUNTS ========================================================
;=============================================================================================================================


(script continuous survival_elite_life_monitor
	; Monitor the elite living count. If it drops, award lives to the Humans based on options
	; Is the current elite living count less than the life monitor?
	(if (< osa_track_lives_reward osa_player_dead_count_elites)
		; It is, so award lives based on the delta
		(begin
			(survival_mode_add_human_lives (* (- osa_player_dead_count_elites osa_track_lives_reward) (survival_mode_bonus_lives_elite_death)))
		)
	)
	(set osa_track_lives_reward osa_player_dead_count_elites)
	(sleep 5)
)

; TODO every occurrence of survival_mode_lives_set and survival_mode_lives_get needs to be fixed for passing the team index

; adding additional lives as rounds are completed based on difficulty 
; do not add lives for the last round of a set 
(script static void survival_add_lives
	; attempt to award the hero medal 
	(survival_mode_award_hero_medal)
		(sleep 1)
		
	; Respawn dead players 
	(survival_mode_respawn_dead_players)
	(sleep 1)

	; Add the lives if we're not already in infinite lives mode, and we're below the max, add lives and announce
	(if 
		(and
			(>= (survival_mode_lives_get player) 0)
			(< (survival_mode_lives_get player) (survival_mode_max_lives))
		)
		(begin
			(survival_mode_add_human_lives (survival_mode_player_count_by_team player))
			(event_survival_awarded_lives)
		)
	)
)

(script static void (survival_mode_add_human_lives (short lives))
	; Only add lives if the end condition is not met
	(if (not b_survival_game_end_condition)
		(if (> (survival_mode_max_lives) 0)
			; There is a max lives limit, so cap it at that
			(survival_mode_lives_set player 
				(max
					(min 
						(survival_mode_max_lives) 
						(+ (survival_mode_lives_get player) lives)
					)
					(survival_mode_lives_get player)
				)
			)
			
			; There is no limit, so just add them
			;(survival_mode_lives_set player (+ (survival_mode_lives_get player) lives))
		)
	)
)
