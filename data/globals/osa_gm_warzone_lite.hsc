; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_director
; include osa_wave_spawnder

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Intended to be a lighter version of warzone. 
; Does not use firefight wave spawner, instead spawns from a squad group.
; Goals:
; Final score = 300 pts
; 1) Teams kill enemy ai for points. (instead of deaths like attrition)      [1 pt]
; 2) Teams kill enemy team generator for bonus points.                       [100 pt]
; 3) Teams kill enemy team leaders for bonus points. (marked on chud)        [40 pt] 10 pts per.
; 4) Teams capture territory A/B for some bonus points generated per minute. [10 pt] 30x10
; Editor Notes:
; To make things interesting.. if your map is big enough, use mules as a boss spawn option.
; Make them the mule team tho. Meaning that defending it means you get attacked. 
; So if you let the other team fight it, they will get the bonus but you wont be plagued anymore.
; you could try to lure it away from your main encampment, so it doesn't attack your guys, while still making it a need for other team to kill.

;; ========================== REQUIRED in Sapien ==================================

; -> means make this parented UNDER.
; gr_warzone_leaders_red  -> gr_dir_marines: fill this with spawnable hero squads.
; gr_warzone_leaders_blue -> gr_dir_elites: fill this with spawnable hero squads.

; set initial objective of gr_waves_red to intf_obj_red
; set initial objective of gr_waves_blue to intf_obj_blue

;; Objectives (ALL TASKS UNDER THE WRAPPERS ***MUST*** HAVE AN EXHAUST TIME OUT)

; Two separate objectives, I recommend creating a full one first, then copy to the second.
; intf_obj_red
; intf_obj_blue

; Two objective wrappers if you use vehicles.
; obj_task_wrapper_inf ; turn on filter for infantry. (REQUIRED ALWAYS)
; obj_task_wrapper_veh ; turn on filter for vehicles.


; Two trigger volumes for capture points.
; intf_tv_capture_a
; intf_tv_capture_b

;; Objectives
(script static boolean (intf_koth_not_secure_red (short index))
    (osa_warzone_get_hill_state INTF_BGM_SIDE_RED index)
)

(script static boolean (intf_koth_not_secure_blue (short index))
    (osa_warzone_get_hill_state INTF_BGM_SIDE_BLUE index)
)


;; Create a gate with tasks to rally at:
(global short intf_warzone_gen_red_en 0) ;; also used for score.
(global short intf_warzone_gen_blue_en 0) ;; also used for score.

;; -------------------------- REQUIRED in Sapien ----------------------------------

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---


; ======== Interfacing Scripts ========
(script static void (intf_load_warzone_lite (boolean dbg_en) (boolean use_weather))
    (intf_load_bgm dbg_en TRUE TRUE use_weather)
	(set intf_bgm_score_win  1000)
    (set intf_bgm_score_tier (/ intf_bgm_score_win 4)) ;; for progress based rewards/triggers.

    (intf_director_add_objective intf_obj_red/obj_task_wrapper_inf)
	(intf_director_add_objective intf_obj_blue/obj_task_wrapper_inf)
	(intf_director_add_objective intf_obj_red/obj_task_wrapper_veh)
	(intf_director_add_objective intf_obj_blue/obj_task_wrapper_veh)

    (ai_object_set_team intf_warzone_gen_red player)
    (ai_object_set_targeting_bias intf_warzone_gen_red 0.85)
    (ai_object_enable_targeting_from_vehicle intf_warzone_gen_red true)
    (object_set_allegiance intf_warzone_gen_red player)
    (object_immune_to_friendly_damage intf_warzone_gen_red true)

    (ai_object_set_team intf_warzone_gen_blue covenant_player)
    (ai_object_set_targeting_bias intf_warzone_gen_blue 0.85)
    (ai_object_enable_targeting_from_vehicle intf_warzone_gen_blue true)
    (object_set_allegiance intf_warzone_gen_blue covenant_player)
    (object_immune_to_friendly_damage intf_warzone_gen_blue true)

    (wake osa_warzone_monitor_gen_red)
    (wake osa_warzone_monitor_gen_blue)
    (wake osa_warzone_update_score)
    (wake osa_warzone_tally_score)
    (wake osa_warzone_test_a)
    (wake osa_warzone_test_b)
    (wake osa_warzone_end_game)
    (wake osa_warzone_game_stages_red)
    (wake osa_warzone_game_stages_blue)

    (set intf_borrow_bipeds 8)
    (intf_load_wave_spawner dbg_en)
)


;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

(script static void plugin_bgm_default_win_cond
    (if (>= intf_bgm_red_score intf_bgm_score_win)
        (intf_bgm_set_game_end_state 1) ; spartans win
    )
    (if (>= intf_bgm_blue_score intf_bgm_score_win)
        (intf_bgm_set_game_end_state 2) ; elites win
    )
    (intf_bgm_set_game_end_state 3)
)

(script static boolean plugin_incd_game_abt_end
    (cond 
        ((> (/ intf_bgm_red_score intf_bgm_score_win) 0.85)
            (begin 
                (set intf_incd_endgame_m "levels\solo\m52\music\m52_music_09")
                (= 0 0)
            )
        )
        ((> (/ intf_bgm_blue_score intf_bgm_score_win) 0.85)
            (begin 
                (begin_random_count 1
                    (set intf_incd_endgame_m "levels\solo\m52\music\m52_music_06")
                    (set intf_incd_endgame_m "levels\solo\m52\music\m52_music_08")
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

;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)

;; ========================== PUBLIC VARIABLES Read-Only ==================================



;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.

(global short osa_warzone_bal_cnt_a 0)
(global short osa_warzone_bal_cnt_b 0)
(global short osa_warzone_capture_a 0)
(global short osa_warzone_capture_b 0)
(global short osa_warzone_side_a 0)
(global short osa_warzone_side_b 0)
(global short osa_warzone_side_new_a 0)
(global short osa_warzone_side_new_b 0)

(global short osa_warzone_red_tally 0)
(global short osa_warzone_blue_tally 0)
(global short osa_warzone_capture_amt 60)
(global long osa_warzone_warn_per_a 0) ; 900 period
(global long osa_warzone_warn_per_b 0) ; 900 period
(global long osa_warzone_warn_per_c 0) ; 900 period

(script dormant osa_warzone_test_a
    (osa_warzone_update_markers -1 0 0)
    (sleep_until ;; updates every 5 seconds.
        (begin 
            (set osa_warzone_bal_cnt_a (* 10 (osa_warzone_cnt_in_vol intf_tv_capture_a)))
            (set osa_warzone_capture_a (osa_warzone_capture_events osa_warzone_bal_cnt_a osa_warzone_capture_a (osa_warzone_contested_in_vol intf_tv_capture_a) osa_warzone_side_a koth_flag_a 0))
            (set osa_warzone_side_new_a (osa_warzone_capture_event_change osa_warzone_bal_cnt_a osa_warzone_capture_a osa_warzone_side_a koth_flag_a 0))
            (osa_warzone_update_markers osa_warzone_side_a osa_warzone_side_new_a 0)
            (set osa_warzone_side_a osa_warzone_side_new_a)
        FALSE)
        150
    )
)

(script dormant osa_warzone_test_b
    (osa_warzone_update_markers -1 0 1)
    (sleep_until ;; updates every 5 seconds.
        (begin 
            (set osa_warzone_bal_cnt_b (* 10 (osa_warzone_cnt_in_vol intf_tv_capture_b)))
            (set osa_warzone_capture_b (osa_warzone_capture_events osa_warzone_bal_cnt_b osa_warzone_capture_b (osa_warzone_contested_in_vol intf_tv_capture_b) osa_warzone_side_b koth_flag_b 1))
            (set osa_warzone_side_new_b (osa_warzone_capture_event_change osa_warzone_bal_cnt_b osa_warzone_capture_b osa_warzone_side_b koth_flag_b 1))
            (osa_warzone_update_markers osa_warzone_side_b osa_warzone_side_new_b 1)
            (set osa_warzone_side_b osa_warzone_side_new_b)
        FALSE)
        150
    )
)



(script dormant osa_warzone_update_score
    (sleep_until 
        (begin 
            (set intf_bgm_red_score (+
                (- (+ (ai_spawn_count gr_waves_blue_spawns) (ai_spawn_count gr_waves_veh_blue_spawns)) (ai_living_count gr_dir_elites))
                (if (<= intf_warzone_gen_blue_en 0) 350 0)
                (* 35 (- (ai_spawn_count gr_warzone_leaders_blue) (ai_living_count gr_warzone_leaders_blue)))
                osa_warzone_red_tally
            ))
            (set intf_bgm_blue_score (+
                (- (+ (ai_spawn_count gr_waves_red_spawns) (ai_spawn_count gr_waves_veh_red_spawns)) (ai_living_count gr_dir_spartans))
                (if (<= intf_warzone_gen_red_en 0) 350 0)
                (* 35 (- (ai_spawn_count gr_warzone_leaders_red) (ai_living_count gr_warzone_leaders_red)))
                osa_warzone_blue_tally
            ))
            FALSE
        )
        1
    )
)

(script dormant osa_warzone_tally_score
    ; tally every half second.
    (sleep_until 
        (begin 
            (if (> osa_warzone_side_a 0)
                (set osa_warzone_red_tally (+ osa_warzone_red_tally 1))
            )
            (if (> osa_warzone_side_b 0)
                (set osa_warzone_red_tally (+ osa_warzone_red_tally 1))
            )
            (if (< osa_warzone_side_a 0)
                (set osa_warzone_blue_tally (+ osa_warzone_blue_tally 1))
            )
            (if (< osa_warzone_side_b 0)
                (set osa_warzone_blue_tally (+ osa_warzone_blue_tally 1))
            )

            FALSE
        )
        180
    )
)

(script continuous respawn_vip_red
    (sleep_until (<= (ai_living_count gr_warzone_leaders_red) 0))
    (sleep 1800)
    (begin 
        (ai_place (ai_squad_group_get_squad gr_warzone_leaders_red (random_range 0 (ai_squad_group_get_squad_count gr_warzone_leaders_red))))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_red) 0) (osa_utils_get_marker_type "defend"))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_red) 1) (osa_utils_get_marker_type "defend"))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_red) 2) (osa_utils_get_marker_type "defend"))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_red) 3) (osa_utils_get_marker_type "defend"))
    )
)

(script continuous respawn_vip_blue
    (sleep_until (<= (ai_living_count gr_warzone_leaders_blue) 0))
    (sleep 1800)
    (begin 
        (ai_place (ai_squad_group_get_squad gr_warzone_leaders_blue (random_range 0 (ai_squad_group_get_squad_count gr_warzone_leaders_blue))))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_blue) 0) (osa_utils_get_marker_type "neutralize"))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_blue) 1) (osa_utils_get_marker_type "neutralize"))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_blue) 2) (osa_utils_get_marker_type "neutralize"))
        (intf_utils_callout_object_p (list_get (ai_actors gr_warzone_leaders_blue) 3) (osa_utils_get_marker_type "neutralize"))
    )
)

(script static short (osa_warzone_capture_events (short capture_state) (short capture_amt) (boolean contested) (short current_side) (object flag) (short flag_idx))
    (if (and (!= 0 capture_state) (< (max capture_amt (* -1 capture_amt)) osa_warzone_capture_amt))
        (sound_impulse_start sound\device_machines\omaha\invasion_alarm1\track1\loop flag 1.0)
    )
    (if (and (> (max capture_amt (* -1 capture_amt)) 0) (< (max capture_amt (* -1 capture_amt)) (* 0.5 osa_warzone_capture_amt)) (= 0 capture_state) (not contested) (!= 0 current_side))
        (sound_impulse_start sound\device_machines\omaha\invasion_data_core\track1\loop flag 1.0)
    )
    (if (or (< (* capture_state current_side) 0) contested)
        (begin 
            (osa_warzone_warn_side current_side flag_idx)
            (sound_impulse_start sound\device_machines\omaha\invasion_alarm2\track1\loop flag 1.0)
        )
    )
    (if (= 0 capture_state)
        (- capture_amt (min (max capture_amt -1) 1)) ;; slowly degrade capture state.
        (if (or (< (max capture_amt (* -1 capture_amt)) osa_warzone_capture_amt) (< (* capture_state current_side) 0))
            (+ capture_state capture_amt) ;; increase if below limit
            capture_amt ;; no change
        )
    )
)

(script static short (osa_warzone_capture_event_change (short capture_state) (short capture_amt) (short current_side) (object flag) (short flag_idx))
    ;; reach threshold to capture
    ;; and was opposite team.
    (if (or (and (or (< (* capture_amt current_side) 0) (= 0 current_side)) (>= (max capture_amt (* -1 capture_amt)) osa_warzone_capture_amt)) (and (= capture_state 0) (= capture_amt 0) (!= 0 current_side)))
        (begin 
            (osa_warzone_confirm_sides current_side (osa_warzone_side_from_score capture_amt) flag flag_idx)
            (osa_warzone_side_from_score capture_amt)
        )
        current_side
    )
)

(script dormant osa_warzone_monitor_gen_red
    (set intf_warzone_gen_red_en (object_get_health intf_warzone_gen_red))
    (intf_utils_callout_object_p intf_warzone_gen_red (osa_utils_get_marker_type "defend c"))
    (sleep_until 
        (begin 
            (if (!= intf_warzone_gen_red_en (object_get_health intf_warzone_gen_red))
                (osa_warzone_warn_side INTF_BGM_SIDE_RED 2)
            )
            (set intf_warzone_gen_red_en (object_get_health intf_warzone_gen_red))
            (<= intf_warzone_gen_red_en 0)
        )
    )
    (set intf_warzone_gen_red_en -1)
)

(script dormant osa_warzone_monitor_gen_blue
    (set intf_warzone_gen_blue_en (object_get_health intf_warzone_gen_blue))
    (intf_utils_callout_object_p intf_warzone_gen_blue (osa_utils_get_marker_type "attack c"))
    (sleep_until 
        (begin 
            (if (!= intf_warzone_gen_blue_en (object_get_health intf_warzone_gen_blue))
                (osa_warzone_warn_side INTF_BGM_SIDE_BLUE 2)
            )
            (set intf_warzone_gen_blue_en (object_get_health intf_warzone_gen_blue))
            (<= intf_warzone_gen_blue_en 0)
        )
    )
    (set intf_warzone_gen_blue_en -1)
)

(script static void (osa_warzone_update_markers (short old_side) (short new_side) (short index))
    (if (!= old_side new_side)
        (cond 
            ((= 0 index)
                (begin 
                    (object_destroy koth_a_neutral)
                    (object_destroy koth_a_red)
                    (object_destroy koth_a_blue)
                )
                (if (= new_side 1)
                    (begin 
                        (object_create koth_a_red)
                        (intf_utils_callout_object_p koth_a_red (osa_utils_get_marker_type "defend a"))
                    )
                )
                (if (= new_side -1)
                    (begin 
                        (object_create koth_a_blue)
                        (intf_utils_callout_object_p koth_a_blue (osa_utils_get_marker_type "attack a"))
                    )
                    
                )
                (if (= new_side 0)
                    (begin 
                        (object_create koth_a_neutral)
                        (intf_utils_callout_object_p koth_a_neutral (osa_utils_get_marker_type "poi a"))
                    )
                )
            )
            ((= 1 index)
                (begin 
                    (object_destroy koth_b_neutral)
                    (object_destroy koth_b_red)
                    (object_destroy koth_b_blue)
                )
                (if (= new_side 1)
                    (begin 
                        (object_create koth_b_red)
                        (intf_utils_callout_object_p koth_b_red (osa_utils_get_marker_type "defend b"))
                    )
                )
                (if (= new_side -1)
                    (begin 
                        (object_create koth_b_blue)
                        (intf_utils_callout_object_p koth_b_blue (osa_utils_get_marker_type "attack b"))
                    )
                    
                )
                (if (= new_side 0)
                    (begin 
                        (object_create koth_b_neutral)
                        (intf_utils_callout_object_p koth_b_neutral (osa_utils_get_marker_type "poi b"))
                    )
                )
            )
        )
    )
)


(script static short (osa_warzone_side_from_score (short score))
    (cond 
        ((> score 0)
            1
        )
        ((< score 0)
            -1
        )
        ((= score 0)
            0
        )
    )
)

(script static short (osa_warzone_get_opposite_side (short side))
    (if (= side 0)
        -1
        1
    )
)

(script static boolean (osa_warzone_get_hill_state (short side) (short index))
    (cond 
        ((= index 0)
            (or (!= osa_warzone_side_a side) (osa_warzone_contested_in_vol intf_tv_capture_a))
        )
        ((= index 1)
            (or (!= osa_warzone_side_b side) (osa_warzone_contested_in_vol intf_tv_capture_b))
        )
    )
)

(script static void (osa_warzone_warn_side (short side) (short index))
    (cond 
        ((= 0 index)
            (begin 
                (if (>= (game_tick_get) osa_warzone_warn_per_a)
                    (begin 
                        (if (= side 1)
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" covenant_player)
                        )
                        (set osa_warzone_warn_per_a (+ (game_tick_get) 900))
                    )
                )
            )
            
        )
        ((= 1 index)
            (begin 
                (if (>= (game_tick_get) osa_warzone_warn_per_b)
                    (begin 
                        (if (= side 1)
                            (submit_incident_with_cause_campaign_team "survival_bravo_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_bravo_under_attack" covenant_player)
                        )
                        (set osa_warzone_warn_per_b (+ (game_tick_get) 900))
                    )
                )
            )
        )
        ((= 2 index)
            (begin 
                (if (>= (game_tick_get) osa_warzone_warn_per_c)
                    (begin 
                        (if (= side 1)
                            (submit_incident_with_cause_campaign_team "survival_charlie_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_charlie_under_attack" covenant_player)
                        )
                        (set osa_warzone_warn_per_c (+ (game_tick_get) 900))
                    )
                )
            )
        )
    )
)

(script static void (osa_warzone_confirm_sides (short old_side) (short new_side) (object flag) (short index))
    (print "Hill Captured!")
    (cond 
        ((= 0 index)
            (submit_incident "gen_alpha_locked")
        )
        ((= 1 index)
            (submit_incident "gen_bravo_locked")
        )
        ((= 2 index)
            (submit_incident "gen_charlie_locked")
        )
    )
    (sleep 90)
    (if (= new_side 1)
        (begin
            (osa_utils_play_sound_for_humans "sound\dialog\multiplayer\territories\territory_captured")
        )
    )
    (if (= new_side -1)
        (begin 
            (osa_utils_play_sound_for_elites "sound\dialog\multiplayer\territories\territory_captured")
        )
    )
    (if (= old_side 1)
        (begin 
            (osa_utils_play_sound_for_humans "sound\dialog\multiplayer\territories\territory_lost")
            
        )
    )
    (if (= old_side -1)
        (begin 
            (osa_utils_play_sound_for_elites "sound\dialog\multiplayer\territories\territory_lost")
            
        )
    )
)

(script static short (osa_warzone_cnt_in_vol  (trigger_volume vol))
    (+
        (if (volume_test_objects vol (players_human))
            1
            0
        )
        (if (volume_test_objects vol (players_elite))
            -1
            0
        )
        (if (volume_test_objects vol (ai_actors gr_dir_spartans))
            1
            0
        )
        (if (volume_test_objects vol (ai_actors gr_dir_elites))
            -1
            0
        )
    )
)

(script static boolean (osa_warzone_contested_in_vol  (trigger_volume vol))
    (and (or (volume_test_objects vol (players_human)) (volume_test_objects vol (ai_actors gr_dir_spartans))) (or (volume_test_objects vol (players_elite)) (volume_test_objects vol (ai_actors gr_dir_elites))))
)

(script dormant osa_warzone_game_stages_red
    (sleep_until (> (/ intf_bgm_red_score intf_bgm_score_win) 0.25))
    (osa_utils_play_sound_for_humans "sound\music\invasion_temp_cues\unsc_win1")
    ; (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph1_victory")
    ; (osa_utils_play_sound_for_elites "sound\dialog\invasion\bone_cv_ph1_defeat")
    (sleep_until (> (/ intf_bgm_red_score intf_bgm_score_win) 0.50))
    (osa_utils_play_sound_for_humans "sound\music\invasion_temp_cues\unsc_win2")
    ; (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph2_victory")
    ; (osa_utils_play_sound_for_elites "sound\dialog\invasion\bone_cv_ph2_defeat")
    (sleep_until (> (/ intf_bgm_red_score intf_bgm_score_win) 0.75))
    (osa_utils_play_sound_for_humans "sound\music\invasion_temp_cues\unsc_big_win")
    ; (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph3_victory")
    ; (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph3_defeat")
    (sleep_until (> (/ intf_bgm_red_score intf_bgm_score_win) 0.85))
    (submit_incident_with_cause_campaign_team "sur_cla_cov_start" covenant_player) ;; warn players that SPARTANS ARE WINNING
)

(script dormant osa_warzone_game_stages_blue
    (sleep_until (> (/ intf_bgm_blue_score intf_bgm_score_win) 0.25))
    (osa_utils_play_sound_for_elites "sound\music\invasion_temp_cues\covy_win1")
    ; (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph1_victory")
    ; (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph1_defeat")
    (sleep_until (> (/ intf_bgm_blue_score intf_bgm_score_win) 0.50))
    (osa_utils_play_sound_for_elites "sound\music\invasion_temp_cues\covy_win2")
    ; (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph2_victory")
    ; (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph2_defeat")
    (sleep_until (> (/ intf_bgm_blue_score intf_bgm_score_win) 0.75))
    (osa_utils_play_sound_for_elites "sound\music\invasion_temp_cues\covy_big_win")
    ; (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph3_victory")
    ; (osa_utils_play_sound_for_humans "sound\dialog\invasion\bone_sp_ph3_defeat")
    (sleep_until (> (/ intf_bgm_blue_score intf_bgm_score_win) 0.85))
    (submit_incident_with_cause_campaign_team "sur_cla_unsc_start" player) ;; warn players that ELITES ARE WINNING

)

(script dormant osa_warzone_end_game
    (sleep_until (or (>= intf_bgm_blue_score intf_bgm_score_win) (>= intf_bgm_red_score intf_bgm_score_win)) 30)
    (plugin_bgm_default_win_cond) ; set the default win condition NOW.
)