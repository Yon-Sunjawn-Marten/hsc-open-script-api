; Copyright 2024 Yon-Sunjawn-Marten
;IMPORTS
; include osa_utils
; include osa_ai_director
; include osa_firefight_warzone

(global ai intf_sq_extr_pelican NONE)
(global ai intf_sq_marines_0 NONE)
(global ai intf_sq_marines_1 NONE) ;// a 2 spartan spawn.

(global boolean intf_extra_chatter true) ; disable if not in urban env for extra immersion.

(global short intf_tpool_pel_idx 0)

(global short s_ext_points_spartan 0)   ; 1 civ saved is 1/5 point. 5/5 gives a marine. Starting marines: 2
(global short s_ext_points_elite 0)     ; 1 civ killed is 1/10 point. 10/10 gives an ai. Starting AI: 4

(global short s_ext_civ_saved 0)
(global short s_ext_civ_saved_delta 0)
(global short s_ext_civ_killed 0)
(global short s_ext_civ_spawned 0)
(global short S_EXT_CIV_MIN 8)
(global short S_EXT_CIV_MAX 16)

; global vehicles 
(global vehicle v_esc_pelican NONE)
(global short evac_zone_ready -1) ; zones = 0,1,2,etc.


(global short EVAC_ELITE_VICTORY   100)
(global short EVAC_SPARTAN_VICTORY 100) ;; or if time runs out.

(global short EVAC_PELICAN_WAIT_TIME 200)
(global short EVAC_PELICAN_LOAD_TIME 450)

(global boolean warning_issued_spartans FALSE)
(global boolean warning_issued_elites FALSE)


(script static void extraction_main
	(print "EXTRACTION MODE ENABLED")
    (set intf_borrow_bipeds S_EXT_CIV_MAX) ;; borrow 24 bipeds for this mode. -- reduces down to 12 as round goes on.

    ;(if debug (print "wake reinforcements"))
    (wake extraction_director)
    (wake extraction_rescue_pelican)
	(set intf_tpool_pel_idx (intf_pool_get_thread_from_sq intf_sq_extr_pelican))
	(intf_pool_set_transport_marker intf_sq_extr_pelican (osa_utils_get_marker_type "defend"))
	(intf_pool_set_hold_en intf_sq_extr_pelican TRUE) ; we want transport to hold at drop point.
    ; (wake survival_pelican_spawn)
    ;(ai_place squads_3) ;; startup squards to help players.
    ;(ai_place squads_33) ; done in the reinforce category.

)

(script static void default_win_condition
	(if (<= s_ext_civ_saved s_ext_civ_killed)
		(begin 
			(print "ELITE DEFAULT VICTORY")
			(intf_ff_set_survival_end_state 2)
		)
		(begin 
			(print "SPARTAN DEFAULT VICTORY")
			(intf_ff_set_survival_end_state 1)
		)
	)
)

(script dormant update_extraction_status
	(sleep_until 
        (begin 
			(sleep 60)
			(set intf_borrow_bipeds S_EXT_CIV_MAX)
			(sleep_until (= evac_zone_ready -1))
			(print "Update Evac Win Condition")
			(set s_ext_civ_killed (- s_ext_civ_spawned (+ (ai_living_count gr_evac_civs) s_ext_civ_saved)))
			(if (< s_ext_civ_saved_delta s_ext_civ_saved);; more people saved! YAY
				(begin 
					(set s_ext_civ_saved_delta s_ext_civ_saved)
					(survival_mode_award_hero_medal)
				)
			)
			(if (and (>= s_ext_civ_killed (/ (* EVAC_ELITE_VICTORY 20) 30)) (not warning_issued_spartans))
				(begin 
					(submit_incident_with_cause_campaign_team "sur_cla_unsc_start" player) ;; warn players that ELITES ARE WINNING
					(set warning_issued_spartans TRUE)
				)
			)
			(if (and (>= s_ext_civ_saved (/ (* EVAC_SPARTAN_VICTORY 20) 30)) (not warning_issued_elites))
				(begin 
					(submit_incident_with_cause_campaign_team "sur_cla_cov_start" covenant_player) ;; warn players that SPARTANS ARE WINNING
					(set warning_issued_elites TRUE)
				)
			)

			(if (<= EVAC_ELITE_VICTORY s_ext_civ_killed)
				(begin 
					(print "ELITE VICTORY")
					(intf_ff_set_survival_end_state 2)
				)
			)
			(if (<= EVAC_SPARTAN_VICTORY s_ext_civ_saved)
				(begin 
					(print "SPARTAN VICTORY")
					(intf_ff_set_survival_end_state 1)
				)
			)
        FALSE)
    )
)

(script static boolean ai_place_obj
	(if (and (<= (+ 4 (ai_living_count gr_evac_civs)) S_EXT_CIV_MAX) (intf_director_can_spawn_ai_x OSA_DIR_SIDE_NONE 4))
		(begin 
			(ai_place sq_obj_civ)
			(if (or warning_issued_spartans warning_issued_elites)
				(intf_utils_callout_object_p sq_obj_civ (osa_utils_get_marker_type "defend"))
			)
			(set s_ext_civ_spawned (+ s_ext_civ_spawned 4))
			TRUE
		)
		FALSE
	)
)

(script dormant extraction_director
    ;;script init - place 16 AI -- leaving 8 for marines, 
    (ai_place_obj)
    (ai_place_obj)
    (ai_place_obj)
    (ai_place_obj)
	;; give starting evac a boost to the human side.
	(ai_place intf_sq_marines_0); consume some civ spots with early marines / spartans (when they die, civs replace them)
	(ai_place intf_sq_marines_1); 2 units
	(ai_place intf_sq_marines_1); 2 units
	(wake update_extraction_status)
    (sleep_until 
        (begin 
			(sleep_until (<	(+ 4 (ai_living_count gr_evac_civs)) S_EXT_CIV_MAX))
            (sleep 30) ; check every 1 sec
			(if (ai_place_obj) ; civs were placed.
				(begin_random_count 1
					(begin 
						(print "reduce max civs, increase max cov/marines!")
						(if (> S_EXT_CIV_MAX S_EXT_CIV_MIN)
							(set S_EXT_CIV_MAX (- S_EXT_CIV_MAX 4))
						)
					)
					(print "skip civ change 1")
					(print "skip civ change 2")
					(print "skip civ change 3")
				)
			)
        FALSE)
    )
)

(script dormant extraction_rescue_pelican
	(sleep_until 
		(begin 
			(sleep 2100) ;; help comes every 2 minutes (3600)
			(if intf_extra_chatter
				(begin_random_count 1
					(print "say nothing")
					(print "say nothing")
					(print "say nothing")
					(print "say nothing")
					(begin 
						(sleep (ai_play_line_on_object NONE m50_0930))
						(sleep (ai_play_line_on_object NONE m50_0940))
					)
					(sleep (ai_play_line_on_object NONE m50_0490))
					(sleep (ai_play_line_on_object NONE m50_0460))
					(sleep (ai_play_line_on_object NONE m50_0540))
					(sleep (ai_play_line_on_object NONE m50_0920))
					(sleep (ai_play_line_on_object NONE m50_0830))
					(sleep (ai_play_line_on_object NONE m50_0720))
					(sleep (ai_play_line_on_object NONE m50_0230))
					
				)
			)
			; (sleep_until (<= (ai_living_count intf_sq_extr_pelican) 0 ))
			(print "Evacuate the civs!")
			(ai_place intf_sq_extr_pelican)
			(sleep 30)
			(set evac_zone_ready (intf_pool_get_transport_track intf_sq_extr_pelican))
			(sleep_until (intf_pool_is_tranport_holding intf_sq_extr_pelican))
			(if (= 0 intf_tpool_pel_idx)
				(set v_esc_pelican intf_pool_t_vehicle_0)
			)
			(if (= 1 intf_tpool_pel_idx)
				(set v_esc_pelican intf_pool_t_vehicle_1)
			)
			(if (= 2 intf_tpool_pel_idx)
				(set v_esc_pelican intf_pool_t_vehicle_2)
			)
			(if (= 3 intf_tpool_pel_idx)
				(set v_esc_pelican intf_pool_t_vehicle_3)
			)
			(begin_random_count 2
				(if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
					(osa_ds_load_dropship_place v_esc_pelican "any" intf_sq_marines_0 NONE NONE)
				)
				(if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
					(osa_ds_load_dropship_place v_esc_pelican "any" intf_sq_marines_1 NONE NONE)
				)
			)
			(osa_ds_unload_dropship v_esc_pelican intf_pl_t_drop_side_a_0)
			(sleep EVAC_PELICAN_WAIT_TIME)
			(print "load evacs!")
			(cs_run_command_script gr_evac_civs cs_ext_get_rescued)
			(sleep EVAC_PELICAN_LOAD_TIME)
			(begin_random_count 1
				(sleep (ai_play_line_on_object NONE m50_0990))
				(sleep (ai_play_line_on_object NONE m50_1410))
			)
			(sleep (ai_play_line_on_object NONE m50_1000))
			(set evac_zone_ready -1)
			(intf_pool_unblock_transport intf_sq_extr_pelican)
			(if intf_extra_chatter
				(begin_random_count 1
					(print "say nothing")
					(print "say nothing")
					(sleep (ai_play_line_on_object NONE m50_1040))
					(sleep (ai_play_line_on_object NONE m50_0030))
					
				)
			)

			(set s_ext_civ_saved_delta s_ext_civ_saved)
    		(set s_ext_civ_saved (+ s_ext_civ_saved (- (list_count (vehicle_riders v_esc_pelican)) 1)))
			FALSE
		)
	 1)


)

(script command_script cs_ext_get_rescued
    (cs_enable_pathfinding_failsafe TRUE)
    (cs_go_to_vehicle v_esc_pelican)

)

