; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include 

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; GENERATOR DEFENSE SCRIPTS
;
; Editor Notes:
; out of memory with the device names, so got rid of them.
; May need to look into culling unused resources from the pools.
; May reduce transport pool to 6 units instead of 8

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---


; ======== Interfacing Scripts ========


;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================


;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)

;; ========================== PUBLIC VARIABLES Read-Only ==================================


;; ========================== REQUIRED in Sapien ==================================

; device machines
; objects/props/human/unsc/generator_x_large -> generator0
; objects/props/human/unsc/generator_x_large -> generator1
; objects/props/human/unsc/generator_x_large -> generator2

; device controls
; objects/levels/firefight/invisible_switch_gen -> generator_switch0
; objects/levels/firefight/invisible_switch_gen -> generator_switch1
; objects/levels/firefight/invisible_switch_gen -> generator_switch2
; objects/levels/firefight/invisible_switch_gen_cool -> generator_switch_cool0
; objects/levels/firefight/invisible_switch_gen_cool -> generator_switch_cool1
; objects/levels/firefight/invisible_switch_gen_cool -> generator_switch_cool2
; objects/levels/firefight/invisible_switch_gen_disabled -> generator_switch_disabled0
; objects/levels/firefight/invisible_switch_gen_disabled -> generator_switch_disabled1
; objects/levels/firefight/invisible_switch_gen_disabled -> generator_switch_disabled2

;; -------------------------- REQUIRED in Sapien ----------------------------------


;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.

(global boolean b_sur_generator_defense_active false)
(global boolean b_sur_generator_defense_fail false)
(global boolean b_sur_generator0_spawned false)
(global boolean b_sur_generator1_spawned false)
(global boolean b_sur_generator2_spawned false)
(global boolean b_sur_generator0_alive false)
(global boolean b_sur_generator1_alive false)
(global boolean b_sur_generator2_alive false)
(global short s_sur_generators_alive 0)
(global real r_sur_generator0_health -1)
(global real r_sur_generator1_health -1)
(global real r_sur_generator2_health -1)

(global short k_surv_generator_cooldown 90)

(global short intf_gen_generator_count (survival_mode_generator_count))

;; Access interfaces in firefight

(script static void intf_plugin_ff_game_over_event
	(if (= b_survival_game_end_condition 1)
		(event_survival_spartans_win_gen)
		(event_survival_elites_win_gen)
	)
)

(script static boolean intf_plugin_ff_sudden_death_condition
	(or
		; Generator alive and closed?
		(and
			(> (object_get_health generator0) 0)
			(> (device_get_position generator0) 0)
		)
		; Generator alive and closed?
		(and
			(> (object_get_health generator1) 0)
			(> (device_get_position generator1) 0)
		)
		; Generator alive and closed?
		(and
			(> (object_get_health generator2) 0)
			(> (device_get_position generator2) 0)
		)
	)
)

(script static void intf_plugin_ff_sudden_death_extension
	; Lock the generators that exist
	(device_set_power generator_switch0 0)
	(device_set_power generator_switch1 0)
	(device_set_power generator_switch2 0)
)

(script static void intf_plugin_ff_goal_custom_0
	(print "Generator Defense Addon Enabled!")
	(if (> intf_gen_generator_count 0)
		(wake osa_generator_defense)
	)
)


(script dormant osa_generator_defense
	(set b_sur_generator_defense_active true)
	(print "Gen defense active")
	
	; Create the generator objects
	(survival_mode_gd_spawn_generators)
	(sleep 1)
	
	; Start the manager
	(wake survival_generator0_management)
	(wake survival_generator1_management)
	(wake survival_generator2_management)
	
	; Make the AI hate the objects
	(if b_sur_generator0_spawned 
		(begin
			(ai_object_set_team generator0 player)
			(ai_object_set_targeting_bias generator0 0.85)
			(ai_object_enable_targeting_from_vehicle generator0 false)
			(object_set_allegiance generator0 player)
			(object_immune_to_friendly_damage generator0 true)
			(set b_sur_generator0_alive true)
		)
	)
	(if b_sur_generator1_spawned 
		(begin
			(ai_object_set_team generator1 player)
			(ai_object_set_targeting_bias generator1 0.85)
			(ai_object_enable_targeting_from_vehicle generator1 false)
			(object_set_allegiance generator1 player)
			(object_immune_to_friendly_damage generator1 true)
			(set b_sur_generator1_alive true)
		)
	)
	(if b_sur_generator2_spawned 
		(begin
			(ai_object_set_team generator2 player)
			(ai_object_set_targeting_bias generator2 0.85)
			(ai_object_enable_targeting_from_vehicle generator2 false)
			(object_set_allegiance generator2 player)
			(object_immune_to_friendly_damage generator2 true)
			(set b_sur_generator2_alive true)
		)
	)
	
	; Connect HUD elements
	; TODO connect HUD elements
	
	; Begin success/failure conditions
	(sleep_until
		(begin
			; Have any generators taken damage?
			(if (< (object_get_health generator0) r_sur_generator0_health)
				(event_survival_generator0_attacked)
			)
			(if (< (object_get_health generator1) r_sur_generator1_health)
				(event_survival_generator1_attacked)
			)
			(if (< (object_get_health generator2) r_sur_generator2_health)
				(event_survival_generator2_attacked)
			)
			
			; Cache generator health
			(set r_sur_generator0_health (object_get_health generator0))
			(set r_sur_generator1_health (object_get_health generator1))
			(set r_sur_generator2_health (object_get_health generator2))
		
			; Have we lost a generator since last update?
			(if 
				(< (survival_mode_gd_generator_count) s_sur_generators_alive)
				(begin
					(event_survival_generator_died)
					
					; Submit an incident for the elites to track stats
					(submit_incident_for_elites "team_generator_kill")
				)
			)
			
			; Cache the living count
			(set s_sur_generators_alive (survival_mode_gd_generator_count))
					
			; Loop until the generators are no longer alive
			(not (survival_mode_gd_generators_alive))
		)
		3
	)
	
	; Failure. Set the failure flag
	(set b_survival_game_end_condition 2)
	
	; And shut down any HUD scripts that might be running
	; TODO disconnect HUD elements
)


(script static void (survival_generator_switch (short switch) (short state))
	; Switch 0
	(if (= switch 0)
		(cond
			; No switch
			((= state 0)
				(begin
					(device_set_power generator_switch0 0)
					(device_set_power generator_switch_cool0 0)
					(device_set_power generator_switch_disabled0 0)
				)
			)
			
			; Active
			((= state 1)
				(begin
					(device_set_power generator_switch0 1)
					(device_set_power generator_switch_cool0 0)
					(device_set_power generator_switch_disabled0 0)
				)
			)
			
			; Cooling
			((= state 2)
				(begin
					(device_set_power generator_switch0 0)
					(device_set_power generator_switch_cool0 1)
					(device_set_power generator_switch_disabled0 0)
				)
			)
			
			; Disabled
			((= state 3)
				(begin
					(device_set_power generator_switch0 0)
					(device_set_power generator_switch_cool0 0)
					(device_set_power generator_switch_disabled0 1)
				)
			)	
		)
	)

	; Switch 1
	(if (= switch 1)
		(cond
			; No switch
			((= state 0)
				(begin
					(device_set_power generator_switch1 0)
					(device_set_power generator_switch_cool1 0)
					(device_set_power generator_switch_disabled1 0)
				)
			)
			
			; Active
			((= state 1)
				(begin
					(device_set_power generator_switch1 1)
					(device_set_power generator_switch_cool1 0)
					(device_set_power generator_switch_disabled1 0)
				)
			)
			
			; Cooling
			((= state 2)
				(begin
					(device_set_power generator_switch1 0)
					(device_set_power generator_switch_cool1 1)
					(device_set_power generator_switch_disabled1 0)
				)
			)
			
			; Disabled
			((= state 3)
				(begin
					(device_set_power generator_switch1 0)
					(device_set_power generator_switch_cool1 0)
					(device_set_power generator_switch_disabled1 1)
				)
			)	
		)
	)

	; Switch 2
	(if (= switch 2)
		(cond
			; No switch
			((= state 0)
				(begin
					(device_set_power generator_switch2 0)
					(device_set_power generator_switch_cool2 0)
					(device_set_power generator_switch_disabled2 0)
				)
			)
			
			; Active
			((= state 1)
				(begin
					(device_set_power generator_switch2 1)
					(device_set_power generator_switch_cool2 0)
					(device_set_power generator_switch_disabled2 0)
				)
			)
			
			; Cooling
			((= state 2)
				(begin
					(device_set_power generator_switch2 0)
					(device_set_power generator_switch_cool2 1)
					(device_set_power generator_switch_disabled2 0)
				)
			)
			
			; Disabled
			((= state 3)
				(begin
					(device_set_power generator_switch2 0)
					(device_set_power generator_switch_cool2 0)
					(device_set_power generator_switch_disabled2 1)
				)
			)	
		)
	)
)


(global short s_surv_generator0_cooldown 0)
(script dormant survival_generator0_management
	(device_set_position_immediate generator0 0)

	; Generator alive
	(sleep_until
		(begin
			; Is it open?
			(if (<= (device_get_position generator0) 0.1)
				; The generator is open and vulnerable
				(begin
					(ai_object_set_targeting_bias generator0 0.85)
					
					; Is it Sudden Death?
					(if (= b_survival_entered_sudden_death 1)
						(survival_generator_switch 0 3) ; Generator disabled (sudden death)
						
						; If not, is it still cooling?
						(if (> s_surv_generator0_cooldown 0)
							(begin
								(survival_generator_switch 0 2) ; Generator cooling prompt
								(sleep s_surv_generator0_cooldown) 
								(set s_surv_generator0_cooldown 0)
							)
							
							; Otherwise, the state is ready
							(survival_generator_switch 0 1) ; Generator ready prompt
						)
					)
				)
				
				; The generator is closed and invulnerable
				(begin
					(event_survival_generator0_locked)
					(survival_generator_switch 0 0) ; No generator prompt
					(ai_object_set_targeting_bias generator0 -1)
					(sleep_until (< (device_get_position generator0) 0.1) 5)
					(set s_surv_generator0_cooldown k_surv_generator_cooldown)
				)
			)
			
			; Loop until the generator is dead
			(<= (object_get_health generator0) 0)
		)
		5 
	)
	
	; Generator dead
	(begin
		(object_cannot_take_damage generator0)
		(survival_generator_switch 0 0) ; No generator prompt
		(ai_object_set_targeting_bias generator0 -1)
		(set b_sur_generator0_alive false)
	)
)


(global short s_surv_generator1_cooldown 0)
(script dormant survival_generator1_management
	(device_set_position_immediate generator1 0)

	; Generator alive
	(sleep_until
		(begin
			; Is it open?
			(if (<= (device_get_position generator1) 0.1)
				; The generator is open and vulnerable
				(begin
					(ai_object_set_targeting_bias generator1 0.85)
					
					; Is it Sudden Death?
					(if (= b_survival_entered_sudden_death 1)
						(survival_generator_switch 1 3) ; Generator disabled (sudden death)
						
						; If not, is it still cooling?
						(if (> s_surv_generator1_cooldown 0)
							(begin
								(survival_generator_switch 1 2) ; Generator cooling prompt
								(sleep s_surv_generator1_cooldown) 
								(set s_surv_generator1_cooldown 0)
							)
							
							; Otherwise, the state is ready
							(survival_generator_switch 1 1) ; Generator ready prompt
						)
					)
				)
				
				; The generator is closed and invulnerable
				(begin
					(event_survival_generator1_locked)
					(survival_generator_switch 1 0) ; No generator prompt
					(ai_object_set_targeting_bias generator1 -1)
					(sleep_until (< (device_get_position generator1) 0.1) 5)
					(set s_surv_generator1_cooldown k_surv_generator_cooldown)
				)
			)
			
			; Loop until the generator is dead
			(<= (object_get_health generator1) 0)
		)
		5 
	)
	
	; Generator dead
	(begin
		(object_cannot_take_damage generator1)
		(survival_generator_switch 1 0) ; No generator prompt
		(ai_object_set_targeting_bias generator1 -1)
		(set b_sur_generator1_alive false)
	)
)


(global short s_surv_generator2_cooldown 0)
(script dormant survival_generator2_management
	(device_set_position_immediate generator2 0)

	; Generator alive
	(sleep_until
		(begin
			; Is it open?
			(if (<= (device_get_position generator2) 0.1)
				; The generator is open and vulnerable
				(begin
					(ai_object_set_targeting_bias generator2 0.85)
					
					; Is it Sudden Death?
					(if (= b_survival_entered_sudden_death 1)
						(survival_generator_switch 2 3) ; Generator disabled (sudden death)
						
						; If not, is it still cooling?
						(if (> s_surv_generator2_cooldown 0)
							(begin
								(survival_generator_switch 2 2) ; Generator cooling prompt
								(sleep s_surv_generator2_cooldown) 
								(set s_surv_generator2_cooldown 0)
							)
							
							; Otherwise, the state is ready
							(survival_generator_switch 2 1) ; Generator ready prompt
						)
					)
				)
				
				; The generator is closed and invulnerable
				(begin
					(event_survival_generator2_locked)
					(survival_generator_switch 2 0) ; No generator prompt
					(ai_object_set_targeting_bias generator2 -1)
					(sleep_until (< (device_get_position generator2) 0.1) 5)
					(set s_surv_generator2_cooldown k_surv_generator_cooldown)
				)
			)
			
			; Loop until the generator is dead
			(<= (object_get_health generator2) 0)
		)
		5 
	)
	
	; Generator dead
	(begin
		(object_cannot_take_damage generator2)
		(survival_generator_switch 2 0) ; No generator prompt
		(ai_object_set_targeting_bias generator2 -1)
		(set b_sur_generator2_alive false)
	)
)


(script static void survival_mode_gd_spawn_generators
	; Random, or sequence?
	(if (survival_mode_generator_random_spawn)
		; Random spawns
		(begin_random_count intf_gen_generator_count
			; Generator 0
			(begin
				(object_create_anew generator0)
				(object_create_anew generator_switch0)
				(object_create_anew generator_switch_cool0)
				(object_create_anew generator_switch_disabled0)
				(set b_sur_generator0_spawned true)
				(object_can_take_damage generator0)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 0) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 1) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 2) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 3) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 4) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 5) generator0 10)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 0) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 1) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 2) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 3) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 4) generator0 7)
			)

			; Generator 1
			(begin
				(object_create_anew generator1)
				(object_create_anew generator_switch1)
				(object_create_anew generator_switch_cool1)
				(object_create_anew generator_switch_disabled1)
				(set b_sur_generator1_spawned true)
				(object_can_take_damage generator1)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 0) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 1) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 2) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 3) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 4) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 5) generator1 11)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 0) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 1) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 2) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 3) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 4) generator1 8)
			)

			; Generator 2
			(begin
				(object_create_anew generator2)
				(object_create_anew generator_switch2)
				(object_create_anew generator_switch_cool2)
				(object_create_anew generator_switch_disabled2)
				(set b_sur_generator2_spawned true)
				(object_can_take_damage generator2)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 0) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 1) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 2) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 3) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 4) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 5) generator2 12)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 0) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 1) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 2) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 3) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 4) generator2 9)
			)
		)
		
		; Sequential
		(begin_count intf_gen_generator_count
			; Generator 0
			(begin
				(object_create_anew generator0)
				(object_create_anew generator_switch0)
				(object_create_anew generator_switch_cool0)
				(object_create_anew generator_switch_disabled0)
				(set b_sur_generator0_spawned true)
				(object_can_take_damage generator0)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 0) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 1) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 2) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 3) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 4) generator0 10)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 5) generator0 10)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 0) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 1) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 2) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 3) generator0 7)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 4) generator0 7)
			)

			; Generator 1
			(begin
				(object_create_anew generator1)
				(object_create_anew generator_switch1)
				(object_create_anew generator_switch_cool1)
				(object_create_anew generator_switch_disabled1)
				(set b_sur_generator1_spawned true)
				(object_can_take_damage generator1)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 0) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 1) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 2) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 3) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 4) generator1 11)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 5) generator1 11)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 0) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 1) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 2) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 3) generator1 8)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 4) generator1 8)
			)

			; Generator 2
			(begin
				(object_create_anew generator2)
				(object_create_anew generator_switch2)
				(object_create_anew generator_switch_cool2)
				(object_create_anew generator_switch_disabled2)
				(set b_sur_generator2_spawned true)
				(object_can_take_damage generator2)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 0) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 1) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 2) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 3) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 4) generator2 12)
				(chud_track_object_for_player_with_priority (human_player_in_game_get 5) generator2 12)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 0) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 1) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 2) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 3) generator2 9)
				(chud_track_object_for_player_with_priority (elite_player_in_game_get 4) generator2 9)
			)
		)
	)
)


(script static boolean survival_mode_gd_generators_alive
	; Is the mode Defend All, or Defend Any?
	(if (survival_mode_generator_defend_all)
		; All of the generators that are supposed to be alive, are
		(>= (survival_mode_gd_generator_count) intf_gen_generator_count)
		
		; At least one generator is alive
		(> (survival_mode_gd_generator_count) 0)
	)
)


(script static short survival_mode_gd_generator_count
	; This is one of the dirtiest things I've ever done in HS
	(+
		(if (and b_sur_generator0_spawned (> (object_get_health generator0) 0))
			1
			0
		)
		(if (and b_sur_generator1_spawned (> (object_get_health generator1) 0))
			1
			0
		)
		(if (and b_sur_generator2_spawned (> (object_get_health generator2) 0))
			1
			0
		)
	)
)
