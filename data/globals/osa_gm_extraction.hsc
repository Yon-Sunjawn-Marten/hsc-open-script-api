; Copyright 2024 Yon-Sunjawn-Marten
;IMPORTS
; include osa_utils
; include osa_ai_director
; include osa_transport_pool
; include osa_wave_spawner


;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
;
;
; Editor Notes:
;
;

;; ========================== REQUIRED in Sapien ==================================

; These squad groups are not meant for vehicles, use a separate group for that.
; sq_ext_rescue 		: usually a pelican. Troop warthog is a possiblity if you used a land vehicle pool.
; gr_ext_civs 			: for the units you need to protect.
; gr_ext_civ_spawns

; I expect that you will use the wave spawner with this gamemode.

;; Objectives 
(global short evac_zone_ready -1) ; evac zones = 0,1,2

;; -------------------------- REQUIRED in Sapien ----------------------------------

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---
(global boolean intf_extra_chatter true) ; disable if not in urban env for extra immersion.

(global short S_EXT_CIV_MIN 8)
(global short S_EXT_CIV_MAX 16) ;; you can leave as is, unless you tested that the map supports more AI.

; ======== Interfacing Scripts ========
(script static void (intf_load_extraction (boolean dbg_en) (boolean urban_env) (boolean use_weather))
	(print "extraction mode loading...")
	(print_if dbg_en "Debug-Enabled")
	(intf_load_bgm dbg_en TRUE TRUE use_weather)
	(set intf_bgm_score_win  100)
	(intf_director_add_objective intf_obj_red/obj_task_wrapper_inf)
	(intf_director_add_objective intf_obj_blue/obj_task_wrapper_inf)
	(intf_director_add_objective intf_obj_red/obj_task_wrapper_veh)
	(intf_director_add_objective intf_obj_blue/obj_task_wrapper_veh)

	(intf_director_add_objective obj_evac/obj_task_wrapper)
	

	(set intf_waves_use_template TRUE)
	(set intf_waves_free_spawn_blue FALSE) ;; cov must drop from ships
	(set intf_waves_free_spawn_red TRUE)
	(set intf_waves_pause_red 1800) ;; longer period between waves for red. (civs spawn independently.)

	(plugin_ext_add_rescue_transport)

	(set intf_extra_chatter urban_env)
	(set intf_borrow_bipeds S_EXT_CIV_MAX) ;; borrow S_EXT_CIV_MAX bipeds for this mode. -- reduces down to S_EXT_CIV_MIN as round goes on.
    (intf_load_wave_spawner dbg_en)
	(wake extraction_director)
    (wake extraction_rescue_pelican)
); REQUIRED SCRIPT CALL THIS IN YOUR MAIN INIT FILE.


;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

(script stub void plugin_ext_add_rescue_transport
	(set intf_tpool_pel_idx (intf_pool_get_thread_from_sq sq_ext_rescue))
	(intf_pool_set_transport_marker sq_ext_rescue (osa_utils_get_marker_type "defend"))
	(intf_pool_set_hold_en sq_ext_rescue TRUE) ; we want transport to hold at drop point.
)

(script static void plugin_bgm_default_win_cond
	(if (< intf_bgm_red_score intf_bgm_blue_score)
		(begin 
			(print "ELITE DEFAULT VICTORY")
			(intf_bgm_set_game_end_state 2)
		)
		(begin 
			(print "SPARTAN DEFAULT VICTORY")
			(intf_bgm_set_game_end_state 1)
		)
	)
)

(script static boolean plugin_incd_game_abt_end
    (cond 
        ((>= intf_bgm_red_score (/ (* intf_bgm_score_win 20) 30))
            (begin 
				(submit_incident_with_cause_campaign_team "sur_cla_cov_start" covenant_player) ;; warn players that SPARTANS ARE WINNING
				(begin_random_count 1
					(set intf_incd_endgame_m "levels\solo\m52\music\m52_music_06")
					(set intf_incd_endgame_m "levels\solo\m52\music\m52_music_08")
					(set intf_incd_endgame_m "levels\solo\m52\music\m52_music_09")
				)
                (= 0 0)
            )
        )
        ((>= intf_bgm_blue_score (/ (* intf_bgm_score_win 20) 30))
            (begin 
				(submit_incident_with_cause_campaign_team "sur_cla_unsc_start" player) ;; warn players that ELITES ARE WINNING
                (begin_random_count 1
                    (set intf_incd_endgame_m "levels\solo\m52\music\m52_music_05") ;; sad losing music.
                    (set intf_incd_endgame_m "levels\solo\m52\music\m52_music_07")
                    (set intf_incd_endgame_m "levels\solo\m70_bonus\music\m70b_music_01")
					
                )
                (= 0 0)
            )
        )
        ((< (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) (* 5 60))
            (begin 
                (set intf_incd_endgame_m "firefight\firefight_music\firefight_music20")
                (= 0 0)
            )
        )
        (TRUE
            (= 0 1)
        )
    )
)

(script static void plugin_bgm_goal_monitor
	(wake update_extraction_status)
	(wake osa_ext_end_game)
)

(script static boolean plugin_wave_spawn_cond_red
    (or 
		(= (ai_living_count sq_ext_rescue) 0) ;; not evac? bring it. Also spawn allies if possible.
		(and 
			(= (ai_living_count sq_ext_rescue) 1) ;; evac started? And we have less than optimal guys, keep spawning them.
			(< (ai_living_count gr_dir_spartans) intf_waves_cnt_red)
			(intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
		)
	)
)
;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)

;; ========================== PUBLIC VARIABLES Read-Only ==================================



;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.



(global short intf_tpool_pel_idx 0)

(global short s_ext_civ_saved_delta 0)
(global short s_ext_civ_spawned 0)

; global vehicles 
(global vehicle v_esc_pelican NONE)

(global short EVAC_PELICAN_WAIT_TIME 200)
(global short EVAC_PELICAN_LOAD_TIME 450)

(script dormant update_extraction_status
	(sleep_until 
        (begin 
			(set intf_borrow_bipeds S_EXT_CIV_MAX)
			(sleep_until (= evac_zone_ready -1))
			(print "Update Evac Win Condition")
			(set intf_bgm_blue_score (- s_ext_civ_spawned (+ (ai_living_count gr_ext_civs) intf_bgm_red_score)))
			(osa_incid_check_win_status (min (max (- intf_bgm_red_score intf_bgm_blue_score) -1) 1))
			(if (< s_ext_civ_saved_delta intf_bgm_red_score);; more people saved! YAY
				(begin 
					(set s_ext_civ_saved_delta intf_bgm_red_score)
					(osa_utils_play_sound_for_humans "sound\dialog\multiplayer\firefight\survival_hero")
				)
			)

			(if (<= intf_bgm_score_win intf_bgm_blue_score)
				(begin 
					(print "ELITE VICTORY")
					(intf_bgm_set_game_end_state 2)
				)
			)
			(if (<= intf_bgm_score_win intf_bgm_red_score)
				(begin 
					(print "SPARTAN VICTORY")
					(intf_bgm_set_game_end_state 1)
				)
			)
        FALSE)
		60
    )
)

(script static boolean ai_place_obj
	(if (and (<= (+ 4 (ai_living_count gr_ext_civs)) S_EXT_CIV_MAX) (intf_director_can_spawn_ai_x OSA_DIR_SIDE_NONE 4))
		(begin 
			(osa_director_spawn_random_sq gr_ext_civs_spawns 4)
			(set s_ext_civ_spawned (+ s_ext_civ_spawned 4))
			(sleep intf_dir_migration_wait)
			TRUE
		)
		FALSE
	)
)



(script dormant extraction_director
	(sleep_until ;; place starting civilians.
		(begin 
			(sleep_until (=	(ai_living_count gr_ext_civs_spawns) 0))
			(ai_place_obj)
			(<	(ai_living_count gr_ext_civs) S_EXT_CIV_MAX)
		)
	)

	; ;; give starting evac a boost to the human side.
	; ; consume some civ spots with early marines / spartans (when they die, civs replace them)
	; (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
	; 	(osa_director_spawn_random_sq gr_waves_red_spawns 4)
	; )
	; (sleep_until (= 0 (ai_living_count gr_waves_red_spawns)))
	; (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 2)
	; 	(osa_director_spawn_random_sq gr_waves_red_spawns 2)
	; )
	; (sleep_until (= 0 (ai_living_count gr_waves_red_spawns)))
	; (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 2)
	; 	(osa_director_spawn_random_sq gr_waves_red_spawns 2)
	; )
    (sleep_until 
        (begin 
			(sleep_until (<	(+ 4 (ai_living_count gr_ext_civs)) S_EXT_CIV_MAX))
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
	; thot about using plugin_wave_transport_vehicle_red but I want to leave that option open.
	(sleep_until 
		(begin 
			(sleep_until (> (ai_living_count sq_ext_rescue) 0) 5)
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
			; (sleep_until (<= (ai_living_count sq_ext_rescue) 0 ))
			(print "Evacuate the civs!")
			(sleep 30)
			(set evac_zone_ready (intf_pool_get_transport_track sq_ext_rescue))
			(sleep_until (intf_pool_is_tranport_holding sq_ext_rescue))
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
			(sleep EVAC_PELICAN_WAIT_TIME)
			(print "load evacs!")
			(cs_run_command_script gr_ext_civs cs_ext_get_rescued) ;; NEEDS v_esc_pelican to be set.
			(sleep EVAC_PELICAN_LOAD_TIME)
			(begin_random_count 1
				(sleep (ai_play_line_on_object NONE m50_0990))
				(sleep (ai_play_line_on_object NONE m50_1410))
			)
			(sleep (ai_play_line_on_object NONE m50_1000))
			(set evac_zone_ready -1)
			(intf_pool_unblock_transport sq_ext_rescue)
			(if intf_extra_chatter
				(begin_random_count 1
					(print "say nothing")
					(print "say nothing")
					(sleep (ai_play_line_on_object NONE m50_1040))
					(sleep (ai_play_line_on_object NONE m50_0030))
					
				)
			)

			(set s_ext_civ_saved_delta intf_bgm_red_score)
    		(set intf_bgm_red_score (+ intf_bgm_red_score (- (list_count (vehicle_riders v_esc_pelican)) 1)))
			(sleep_until (= (ai_living_count sq_ext_rescue) 0) 1) ; wait for deletion.
			FALSE
		)
	 1)


)

(script command_script cs_ext_get_rescued
    (cs_enable_pathfinding_failsafe TRUE)
    (cs_go_to_vehicle v_esc_pelican)

)

(script dormant osa_ext_end_game
    (sleep_until (or (>= intf_bgm_blue_score intf_bgm_score_win) (>= intf_bgm_red_score intf_bgm_score_win)) 30)
    (plugin_bgm_default_win_cond) ; set the default win condition NOW.
)