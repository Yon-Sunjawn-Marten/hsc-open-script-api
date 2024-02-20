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
; (script stub void (intf_plugin_ff_hazard_spawn_0 (vehicle phantom))
    ; (print_if dbg_ff "intf_plugin_ff_hazard_spawn_0")
; ) ;; use this script to supply hazard squads or vehicles to phantoms when spawning.
(script stub void intf_plugin_ff_hazard_custom_0
    ;; wake monitoring script
    (print_if dbg_ff "intf_plugin_ff_hazard_custom_0")
);; use this to wake your hazard scripts as part of automatic interface with firefight.
(script stub void intf_plugin_ff_hazard_custom_1
    ;; wake monitoring script
    (print_if dbg_ff "intf_plugin_ff_hazard_custom_1")
);; use this to wake your hazard scripts as part of automatic interface with firefight.
(script stub void intf_plugin_ff_hazard_custom_2
    ;; use this to wake your hazard scripts as part of automatic interface with firefight.
    ;; wake monitoring script
    (print_if dbg_ff "intf_plugin_ff_hazard_custom_2")
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
(script stub void intf_plugin_ff_goal_custom_0
    ;; wake monitoring script
    ;; (set b_survival_game_end_condition 1)
    (print_if dbg_ff "intf_plugin_ff_goal_custom_0")
);; claimed by generators_goal.hsc -- use custom 1 to have both yours and that.
(script stub void intf_plugin_ff_goal_custom_1
    ;; (set b_survival_game_end_condition 1)
    ;; wake monitoring script
    (print_if dbg_ff "intf_plugin_ff_goal_custom_1")
)
(script stub void intf_plugin_ff_default_win_condition
    (intf_ff_set_survival_end_state 1)
); spartans win by default
(script stub void intf_plugin_ff_end_game_custom_0
    ;; wake monitoring script
    ;; (set b_survival_game_end_condition 1)
    (print_if dbg_ff "intf_plugin_ff_end_game_custom_0")
) ; reserved by generators_goal.hsc -- use custom 1 to have both yours and that.
(script stub void intf_plugin_ff_end_game_custom_1
    ;; (set b_survival_game_end_condition 1)
    ;; wake monitoring script
    (print_if dbg_ff "intf_plugin_ff_end_game_custom_1")
) ; open
(script static void (intf_ff_set_survival_end_state (short value))
	(if (not (test_survival_end_condition)) ;; game not declared yet.
		(set b_survival_game_end_condition value)
	)
)
(script stub void intf_plugin_ff_game_over_event
    (print_if dbg_ff "intf_plugin_ff_game_over_event")
    (if (= b_survival_game_end_condition 1)
        (event_survival_spartans_win_normal)
        (event_survival_elites_win_normal)
    )
) ; reserved by generator def
(script stub boolean intf_plugin_ff_sudden_death_condition
    (print_if dbg_ff "No sudden death for normal mode")
    FALSE
) ; reserved by generator def
(script stub void intf_plugin_ff_sudden_death_extension
    (print_if dbg_ff "Enter Sudden Death Extension")
) ; reserved by generator def
(script stub void intf_plugin_ff_resupply_0
	(print_if dbg_ff "Warzone round start plugin 0")
); reserved by resupply plugin
(script stub void intf_plugin_ff_resupply_1
	(print_if dbg_ff "Warzone round start plugin 1")
); open
(script stub void intf_plugin_ff_resupply_2
	(print_if dbg_ff "Warzone round start plugin 2")
); open

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------


;; ========================== PUBLIC VARIABLES Read-Only ==================================


;; ========================== REQUIRED in Sapien ==================================
; REQUIRED AI/Squad Groups
; If you intend to use FF plugin:
; waves go to gr_survival_remaining at end of wave. Used to trigger some objective tasks that make the AI come near you.
; generally waves spawn in separate squads and thus can attempt tasks that are limited to 4 ai for ex.
; gr_survival_remaining might fill up to more than 4, so they would be ineligible to do them.
; not setting a task limit can result in a rush with dozens of combatants, user beware.
; gr_survival_remaining     -> gr_survival_elites

; gr_survival_waves         -> gr_survival_elites
; gr_survival_bonus         -> gr_survival_elites

; intf_ff_objective -- the objective with a hold_task

; intf_plugin_ff_hazard_spawn_0 - You have to implement a stub when its sent a var IM SORRY. Sapien is glitching out during compile

;; -------------------------- REQUIRED in Sapien ----------------------------------


;; ========================== Internal Use CONSTANTS/VARS ==================================

(global boolean dbg_ff False)

; Kill all scripts
(global boolean b_survival_kill_threads FALSE) ;; use this to end monitoring loops.

; Has a human player ever spawned?
(global boolean b_survival_human_spawned false)
(global short   osa_track_lives_reward 0)

; sets how many ai can be alive before the next wave will spawn 
(global short k_sur_ai_rand_limit 4)
(global short k_sur_ai_final_limit 0)


; controls the number of rounds per set 
(global short k_sur_wave_per_round_limit 5)
(global short k_sur_round_per_set_limit 3)

; These timers are generally cumulative
(global short k_sur_wave_timer 180)		; Delay following every wave
(global short k_sur_round_timer 150)	; Delay following every round
(global short k_sur_set_timer 300)		; Delay following every set
(global short k_sur_bonus_timer 150)	; Delay following every bonus round
(global short k_sur_wave_timeout 0)		; Not used

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

; The number of waves completed NOT COUNTING BONUS WAVE
; Used to determine when the game should end due to completion
(global short s_survival_wave_complete_count 0)


;==================================== Script Settings ====================================

;=============================================================================================================================
;============================================ SURVIVAL CONSTANTS =============================================================
;=============================================================================================================================

(global short S_SUR_AI_WEAK 10) ; triggers that look for weak AI presence will trigger.





;================================== Firefight init ==================================

; In it's own thread
(script continuous survival_garbage_collector
	(sleep_forever)
	(add_recycling_volume_by_type garbage_collection 4 20 16371)
	(sleep (* 30 20))
	(add_recycling_volume_by_type garbage_collection 30 10 12)
)

(script dormant osa_detect_player_spawn
	(sleep_until (> (players_human_living_count) 0))
	(set b_survival_human_spawned true)
) ; blocks game over from human deaths when humans aren't present.

(script startup survival_init_lives
	(if (< (survival_mode_get_shared_team_life_count) 0)
		(survival_mode_lives_set player -1)
		(survival_mode_lives_set player (survival_mode_get_shared_team_life_count))		
	)
	(if (< (survival_mode_get_elite_life_count) 0)
		(survival_mode_lives_set covenant_player -1)
		(survival_mode_lives_set covenant_player (survival_mode_get_elite_life_count))
	)
)

;============================================ MAIN LOOP ===============================================================
; MAIN SURVIVAL MODE SCRIPT 
(script dormant osa_ff_main_loop
	;; When testing this, pls load up the original firefight maps and run them.
	;; Some of the resources are not loading for FF mode, sapien will load them if you do an original ff map first.
	;; A sign of this: The HUD for FF doesn't show up.
	(print "WARZONE START")
	(wake osa_detect_player_spawn) ;; don't block game loop for this bc we want elites to be able to play alone.
	(wake survival_round_timer_counter)
	(wake survival_elite_life_monitor)

	; Set allegiances
	(ai_allegiance human player)
	(ai_allegiance player human)
	(ai_allegiance covenant covenant_player)
	(ai_allegiance covenant_player covenant)

	; ai_enable_stuck_flying_kill group TRUE

	; Set loadouts
	(player_set_spartan_loadout (human_player_in_game_get 0))
	(player_set_spartan_loadout (human_player_in_game_get 1))
	(player_set_spartan_loadout (human_player_in_game_get 2))
	(player_set_spartan_loadout (human_player_in_game_get 3))
	(player_set_spartan_loadout (human_player_in_game_get 4))
	(player_set_spartan_loadout (human_player_in_game_get 5))
	(player_set_spartan_loadout (human_player_in_game_get 6))
	(player_set_spartan_loadout (human_player_in_game_get 7))
	(player_set_elite_loadout (elite_player_in_game_get 0))
	(player_set_elite_loadout (elite_player_in_game_get 1))
	(player_set_elite_loadout (elite_player_in_game_get 2))
	(player_set_elite_loadout (elite_player_in_game_get 3))
	(player_set_elite_loadout (elite_player_in_game_get 4))
	(player_set_elite_loadout (elite_player_in_game_get 5))
	(player_set_elite_loadout (elite_player_in_game_get 6))
	(player_set_elite_loadout (elite_player_in_game_get 7))
	
	; start survival music 
	(sound_looping_start m_survival_start NONE 1)
	
	; Activate custom goals/endgame
	(intf_plugin_ff_goal_custom_0)
	(intf_plugin_ff_goal_custom_1)
	
	; Blink
	(sleep 1)
	; Garbage collect, in case anything is left over from previous rounds (sob)
	(garbage_collect_now)

	; announce survival mode 
	(sleep (* 30 1))
	(event_welcome)
	(sleep (* 30 2))
	(event_intro)

	; wake secondary scripts
	; (wake survival_bonus_round_end) ;; watches for end and closes bonus round.
	(wake survival_end_game) ;; watches for endgame.
	; (wake survival_bonus_round_dropship) ;; continuously watches for available dropship to spawn bonus.
	(wake survival_score_attack) ; -> osa_utils.hsc
	(wake osa_automatic_announcer) ; -> osa_firefight_incident
	
	; begin delay timer 
	(sleep (* 30 3))

	; stop opening music 
	(sound_looping_stop m_survival_start)

	;Enable custom hazard scripts.
	(if (survival_mode_scenario_extras_enable)
		(begin 
			(intf_plugin_ff_hazard_custom_0)
			(intf_plugin_ff_hazard_custom_1)
			(intf_plugin_ff_hazard_custom_2)
		)
	)
	
	; main wave loop SET Encapsulation.	
	(sleep_until
		(begin		
			(print_if dbg_ff "beginning new set")
			(survival_mode_begin_new_set)
			(sleep 1)
				
			(intf_plugin_ff_resupply_0)
			(intf_plugin_ff_resupply_1)
			(intf_plugin_ff_resupply_2)
			
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
					(< s_survival_wave_complete_count (- (survival_mode_get_set_count) 1))
				)
				(sleep k_sur_wave_timer)
			)

			; At this point the wave has spawned and been defeated.
			
			; Increment the wave complete count for game over condition
			(set s_survival_wave_complete_count (+ s_survival_wave_complete_count 1))
			
			; Kill this loop if we're past the end condition count
			; Prevents more loop business from happening
			(if 
				(and
					(> (survival_mode_get_set_count) 0)
					(>= s_survival_wave_complete_count (survival_mode_get_set_count))	
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
							(intf_plugin_ff_resupply_0)
							(intf_plugin_ff_resupply_1)
							(intf_plugin_ff_resupply_2)
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
			(>= s_survival_wave_complete_count (survival_mode_get_set_count))	
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
				(>= s_survival_wave_complete_count (- (survival_mode_get_set_count) 1))	
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


;=============================================================================================================================
;============================================ BONUS ROUND SCRIPTS ============================================================
;=============================================================================================================================


(global boolean b_sur_bonus_round_running FALSE)
(global boolean b_sur_bonus_end FALSE)
(global boolean b_sur_bonus_spawn TRUE)

(global long l_sur_pre_bonus_points 0)
(global long l_sur_post_bonus_points 0)

(global short s_sur_bonus_count 0)
(global short k_sur_bonus_squad_limit 6)

(global short k_sur_bonus_limit 20)

(global boolean b_survival_bonus_timer_begin FALSE)
(global short k_survival_bonus_timer (* 30 60 1))


; (script static void survival_bonus_round
; 	(print_if dbg_ff "** start bonus round **")
	
; 	; mark survival mode as "running" 
; 	(set b_sur_bonus_round_running TRUE)
; 	(set b_sur_bonus_end FALSE)

; 	; sum up the total points before the BONUS ROUND begins 
; 	(set l_sur_pre_bonus_points (survival_total_score))
	
; 	; mark as the start of bonus round
; 	(survival_mode_begin_new_wave)
	
; 	; Get the bonus round duration
; 	(set k_survival_bonus_timer (* (survival_mode_get_current_wave_time_limit) 30))
	
; 	; Display bonus round timer
; 	(chud_bonus_round_set_timer (survival_mode_get_current_wave_time_limit))
; 	(chud_bonus_round_show_timer true)
	
; 	;tysongr - 54505: Respawn players before the bonus round
; 	(survival_mode_respawn_dead_players)
			
; 	; announce BONUS ROUND
; 	(event_survival_bonus_round)
; 	(sleep 90)
	
; 	; spawn in phantom if needed 
; 	(if (wave_dropship_enabled) 
; 		(begin
; 			(if intf_t_bonus_random
; 				(begin 
; 					(print_if dbg_ff "Pick a random phantom to be the bonus :>")
; 					(sleep_until 
; 						(begin 
; 							(begin_random_count 1 
; 								(set intf_sq_phantom_bonus intf_sq_phantom_01)
; 								(set intf_sq_phantom_bonus intf_sq_phantom_02)
; 								(set intf_sq_phantom_bonus intf_sq_phantom_03)
; 							)
; 							(!= NONE intf_sq_phantom_bonus)
; 						)
; 						1
; 					)
; 				)
; 			) ; else use the preset phantom.
; 			; Before it spawns, let's enable the hold mechanic.
; 			(intf_pool_set_hold_en intf_sq_phantom_bonus true)
; 			(ai_place intf_sq_phantom_bonus)
; 			(ai_squad_enumerate_immigrants intf_sq_phantom_bonus true)
; 			(sleep 1)
			
; 			; My sauce was weak. This makes it strong.
; 			(f_survival_bonus_spawner true)
; 			(f_survival_bonus_spawner true)
; 			(f_survival_bonus_spawner true)
; 			(f_survival_bonus_spawner true)
; 		)
; 	)
	
; 	; Start the bonus round end condition timer
; 	(set b_survival_bonus_timer_begin TRUE)
	
; 	; re-populate the space with a single squad 
; 	(sleep_until 
; 		(begin
; 			; Sleep until the number of AI drops below the bonus limit 
; 			(sleep_until	
; 				(or
; 					b_sur_bonus_end
; 					(<= (survival_mode_bonus_living_count) k_sur_bonus_limit)
; 					(osa_utils_players_dead)
; 				)
; 				1
; 			)

; 			; If the round isn't over...
; 			(if	
; 				(and
; 					(not (osa_utils_players_dead))
; 					(not b_sur_bonus_end)
; 				)
; 				(begin
; 					(f_survival_bonus_spawner false)
; 				)
; 			)

; 			; continue in this loop until the timer expires 
; 			; OR all players are dead 
; 			(or
; 				b_sur_bonus_end
; 				(osa_utils_players_dead)
; 			)
; 		)
; 		1
; 	)
				
; 	; kill all ai 
; 	(ai_kill_no_statistics intf_gr_ff_waves)
; 	(ai_kill_no_statistics intf_sq_ff_bonus)
; 	(sleep 90)

; 	; announce bonus round over 
; 	(event_survival_bonus_round_over)

; 	; respawn players 
; 	(skull_enable skull_iron false)
; 	(survival_mode_respawn_dead_players)
; 	(sleep 30)
	
; 	; End the wave and set
; 	(survival_mode_end_wave)
; 	(survival_mode_end_set)

; 	; Increment the wave complete count for game over condition
; 	(set s_survival_wave_complete_count (+ s_survival_wave_complete_count 1))

; 	; delay timer 
; 	(sleep 120)

; 	; calculate the number of points scored during the bonus round 
; 	(set l_sur_post_bonus_points (survival_total_score))
	
; 	; clear timer 
; 	(chud_bonus_round_set_timer 0)
; 	(chud_bonus_round_show_timer FALSE)
; 	(chud_bonus_round_start_timer FALSE)

; 	; reset parameters 
; 	(set k_sur_bonus_squad_limit 6)
; 	(intf_pool_unblock_transport intf_sq_phantom_bonus)
	
; 	; after bonus round. disable hold of current bonus phantom so it can be used during normal waves.
; 	(intf_pool_set_hold_en intf_sq_phantom_bonus false)
	
; 	; mark survival mode as "not-running" 
; 	(set b_sur_bonus_round_running FALSE)
; )


; (script dormant survival_bonus_round_end
; 	(sleep_until
; 		(begin
; 			(sleep_until b_survival_bonus_timer_begin 1)
; 			(chud_bonus_round_start_timer TRUE)
; 			(sleep_until 
; 				(osa_utils_players_dead) 
; 				1 
; 				k_survival_bonus_timer
; 			)
			
; 			; turn off bonus round 
; 			(set b_sur_bonus_end TRUE)
		
; 			; if all players are dead reset the timer 
; 			(if (osa_utils_players_dead)
; 				(begin
; 					(chud_bonus_round_start_timer FALSE)
; 					(chud_bonus_round_set_timer 0)
; 				)
; 			)
				
; 			(set b_survival_bonus_timer_begin FALSE)
			
; 			; Loop forever
; 			b_survival_kill_threads
; 		)
; 		1
; 	)
; )


;(global ai survival_bonus_last_squad none)
; (script static void (f_survival_bonus_spawner (boolean force_load))
; 	(print_if dbg_ff "spawn bonus squad...")
	
; 	; Load them into the dropship if appropriate
; 	(if
; 		(or 
; 			force_load
; 			(and
; 				(intf_pool_is_tranport_holding intf_sq_phantom_bonus)
; 				(wave_dropship_enabled)
; 				(= (random_range 0 2) 0)		
; 			)
; 		)
		
; 		; Spawn them in limbo and load them
; 		(begin
; 			; Place the squad
; 			(ai_place_wave (survival_mode_get_wave_squad) intf_gr_ff_waves 1)
; 			(sleep 1)
; 			(intf_pool_get_transport_running_script intf_sq_phantom_bonus)
; 			; Get the squad, and load it
; 			(survival_attempt_load intf_pool_t_running_export intf_drop_side_bonus intf_gr_ff_waves FALSE)
; 		)
		
; 		; Otherwise, spawn and migrate them
; 		(begin
; 			(ai_place_wave (survival_mode_get_wave_squad) intf_gr_ff_waves 1)
; 			(sleep 1)
; 			(ai_migrate_persistent intf_gr_ff_waves intf_sq_ff_bonus)
; 		)
; 	)
	
; 	; Bedlam?

; )

; (script dormant survival_bonus_round_dropship
; 	(sleep_until
; 		(begin
; 			(sleep_until 
; 				(or
; 					(intf_pool_is_tranport_holding intf_sq_phantom_bonus) 
; 					b_sur_bonus_end
; 				)
; 				5
; 			)
; 			(if (not b_sur_bonus_end)
; 				(begin
; 					(intf_pool_get_thread_from_sq intf_sq_phantom_bonus)
; 					(unit_open intf_pool_t_running_export)
; 					(sleep_until 
; 						(begin
; 							; Empy the dropship. Is it a Phantom or a Spirit?
; 							(osa_ds_unload_dropship intf_pool_t_running_export "any")

; 							; Migrate them (after a short pause)
; 							(sleep 1)
; 							(ai_migrate_persistent intf_gr_ff_waves intf_sq_ff_bonus)
							
; 							; Loop until bonus round ends
; 							b_sur_bonus_end
; 						)
; 						30
; 					)
; 					(unit_close intf_pool_t_running_export)
; 				)
; 			)
		
; 			; Loop forever
; 			false
; 		)
; 	)
; )


(script static short survival_mode_bonus_living_count
	(+
		(ai_living_count intf_gr_ff_waves)
		(ai_living_count intf_sq_ff_bonus)
		(ai_living_count intf_sq_phantom_bonus)
	)
)

;============================================ BONUS ROUND SCRIPTS


;=============================================================================================================================
;============================================ END GAME SCRIPTS ===============================================================
;=============================================================================================================================

(global short b_survival_game_end_condition 0) ; 0 Not met, 1 Spartans win, 2 Elites win
(global short b_survival_entered_sudden_death 0) ; 0 no, 1 started, 2 end.
(global long l_sur_round_timer 0)

(script dormant survival_round_timer_counter
	(sleep_until
		(begin 
			(set l_sur_round_timer (+ l_sur_round_timer 1))
			b_survival_kill_threads
		)
		30
	)
)

(script static boolean test_survival_end_condition
	(> b_survival_game_end_condition 0)
)
(script static void survival_end_finalize
	(set b_survival_kill_threads true) ;; end all monitors.
	(if (= b_survival_game_end_condition 1)
		(begin 
			(survival_spartans_increment_score) ; -> osa_utils.hsc
		)
		(begin 
			; Elites win, Spartans lose.
			(survival_elites_increment_score) ; -> osa_utils.hsc
		)
	)
	(intf_plugin_ff_game_over_event) ; normal win gets overridden in generator mode. All by including the file as a script.
)

(script dormant survival_end_game
	; Wake the end condition scripts
	(wake survival_mode_end_condition)
	(intf_plugin_ff_end_game_custom_0)
	(intf_plugin_ff_end_game_custom_1)
	
	; Sleep until one of them has succeeded
	(sleep_until (test_survival_end_condition) 30) ; check every second, ticks don't matter dude.
	
	(survival_end_finalize)

	; Kill remaining survival threads 
	(sleep_forever osa_ff_main_loop)
	; (sleep_forever survival_bonus_round_end)
	
	(sleep 120)

	; end game 
	(mp_round_end_with_winning_team none)
)

(script dormant survival_mode_end_condition
	(sleep_until 
		(begin 
			(if (and
					b_survival_human_spawned				; Can't end before a human has even spawned
					(= b_sur_bonus_round_running FALSE)		; Never succeed during a bonus round
					(osa_utils_players_dead)					; Players are all dead
					(osa_utils_players_not_respawning)		; Players are not going to respawn (out of lives, respawn on wave, etc.)
				)
				(intf_ff_set_survival_end_state 2)
			)
			(if (or
					(and
						(= b_sur_bonus_round_running FALSE)
						(> (survival_mode_get_time_limit) 0)
						(>= l_sur_round_timer (* (survival_mode_get_time_limit) 60))
					)
					(and
						(> (survival_mode_get_set_count) 0)
						(>= s_survival_wave_complete_count (survival_mode_get_set_count))
					)
				)
				(if (intf_plugin_ff_sudden_death_condition)
					; Enter sudden death.
					(wake survival_sudden_death)
					(set b_survival_entered_sudden_death 2) ;; skip it
				)
			)
			(if (= b_survival_entered_sudden_death 2); is over
				(intf_plugin_ff_default_win_condition)
			)
			b_survival_kill_threads
		)
		
	30) ;; check every second.
)

(script dormant survival_sudden_death
	; Enter sudden death
	(event_survival_sudden_death)
	(survival_mode_sudden_death true)
	(set b_survival_entered_sudden_death 1)

	; Sleep until sudden death no longer in effect or 1 minute
	(sleep_until (not (intf_plugin_ff_sudden_death_condition)) 2 1800)
	(set b_survival_entered_sudden_death 2)
	
	; Sudden death over
	(event_survival_sudden_death_over)
	(survival_mode_sudden_death false)
	(sleep 30)
)


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

;=============================================================================================================================
;============================================ Audio FX SCRIPTS ===============================================================
;=============================================================================================================================
;=============================================================================================================================
;=============================================================================================================================

;=============================================================================================================================
;============================================ ANNOUNCEMENT SCRIPTS ===========================================================
;=============================================================================================================================

;===================================== BEGIN ANNOUNCER =======================================================================

; this script assumes that at the start of a SET the rounds and waves are set to -- 0 -- 
; also, at the start of a ROUND waves are set to -- 0 -- 


; 0 default, 1 new, 2 end. ;; For fuk sake, conserve variable pointers and just use more memory. ITS A PC!!!!!
(global short s_survival_state_set 0)
(global short s_survival_state_round 0)
(global short s_survival_state_wave 0)
(global short s_survival_state_lives 0)

;; use a state machine to manage inbound-outbound waves.
(script dormant osa_automatic_announcer
	(sleep_until 
		(begin 
			(if (= s_survival_state_wave 2) ;; main loop has marked the end of a wave.
				(begin 
					(if (< (survival_mode_wave_get) k_sur_wave_per_round_limit)
						(set s_survival_state_wave 2) ;; leave as is
						(begin 
							(if (< (survival_mode_round_get) k_sur_round_per_set_limit)
								(set s_survival_state_round 2)
								(set s_survival_state_set 2)
							)
						)
					)
					(survival_mode_wave_music_stop) ; Stop music
				)
			)
			(if (= s_survival_state_wave 1)
				(begin 
					(survival_mode_wave_music_start) ; Begin music loop
					(print_if dbg_ff "announce new wave...")
					(if (not (survival_mode_current_wave_is_initial)) ; TODO make sure this is correct (updated for 0 index)
						(begin
							; attempt to award the hero medal 
							(survival_mode_award_hero_medal)
								(sleep 1)
								
							; respawn dead players (WE DO NOT ADD LIVES HERE) 
							(event_survival_reinforcements)
							(survival_mode_respawn_dead_players)
								(sleep (* (random_range 3 5) 30))
						)
						(set s_survival_state_round 1)
					)
					(set s_survival_state_wave 0)
				)
			)
			(if (and (= s_survival_state_round 1) (= (survival_mode_round_get) 0))
				(begin 
					(set s_survival_state_set 1)
					(set s_survival_state_round 0)
				)
			)
			(if (= s_survival_state_set 1)
				(begin 
					(print_if dbg_ff "announce new set...")
					(surival_set_music)
					(event_countdown_timer)
					(event_survival_new_set)
					(set s_survival_state_set 0)

				)
			)
			(if (= s_survival_state_round 1)
				(begin 
					(print_if dbg_ff "announce new round...")
					(event_countdown_timer)
					(event_survival_new_round)
					(set s_survival_state_round 0)
				)
			)
			(if (= s_survival_state_set 2)
				(begin 
					(print_if dbg_ff "announce end set...")
					(event_survival_end_set)
					(set s_survival_state_set 0)

				)
			)
			(if (= s_survival_state_round 2)
				(begin 
					(print_if dbg_ff "announce end round...")
					(event_survival_end_round)
					(set s_survival_state_round 0)

				)
			)
			(if (= s_survival_state_wave 2)
				(begin 
					(print_if dbg_ff "announce end wave...")
					(set s_survival_state_wave 0)

				)
			)

			;; announce lives state
			(if (or (= s_survival_state_lives 0) (> (survival_mode_lives_get player) 5))
				(set s_survival_state_lives 1)
			)
			(if (= s_survival_state_lives 1)
				(if (and (<= (survival_mode_lives_get player) 5) (>= (survival_mode_lives_get player) 0) )
					(begin 
						(print_if dbg_ff "5 lives left...")
						(event_survival_5_lives_left)
						(set s_survival_state_lives 2)
					)
				)
			)
			(if (= s_survival_state_lives 2)
				(if (and (<= (survival_mode_lives_get player) 1) (>= (survival_mode_lives_get player) 0) )
					(begin 
						(print_if dbg_ff "1 life left...")
						(event_survival_1_life_left)
						(set s_survival_state_lives 3)
					)
				)
			)
			(if (= s_survival_state_lives 3)
				(if (= (survival_mode_lives_get player) 0) 
					(begin 
						(print_if dbg_ff "0 lives left...")
						(event_survival_0_lives_left)
						(set s_survival_state_lives 4)
					)
				)
			)
			(if (= s_survival_state_lives 4)
				(if (= (players_human_living_count) 1)
					(begin 
						(print_if dbg_ff "last man standing...")
						(event_survival_last_man_standing)
						(set s_survival_state_lives 5) ;; exit fsm lol. this was bug.
					)
				)
			)
			(if (and (> s_survival_state_lives 1) (> (survival_mode_lives_get player) 1))
				(set s_survival_state_lives 2)
			)
			b_survival_kill_threads
		)
	30) ; sleep one second intervals.

	;; If thread is over, game is over.
	(survival_mode_wave_music_stop)
	(submit_incident "survival_mm_game_complete") ;; game over
)


;------------------------------------- END ANNOUNCER -------------------------------------------------------------------------


;=============================================================================================================================
;============================================ LIVES AND LIVING COUNTS ========================================================
;=============================================================================================================================

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
