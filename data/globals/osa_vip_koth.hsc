; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_utils
; include osa_incidents
; include osa_ai_director
; include osa_base_gamemode

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================
; king of the hill / VIP prototype.
; Players can't capture zones, you gotta protect your AI squad to win. OR.. kill the enemy team's squad.

; Script Responsibilities:
;
;
; Editor Notes:
;
;

;; ========================== REQUIRED in Sapien ==================================

;; Objectives
(script static boolean (intf_koth_not_secure_red (short index))
    (osa_koth_get_hill_state INTF_KOTH_SIDE_RED index)
)

(script static boolean (intf_koth_not_secure_blue (short index))
    (osa_koth_get_hill_state INTF_KOTH_SIDE_BLUE index)
)

;; -------------------------- REQUIRED in Sapien ----------------------------------


;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---


; ======== Interfacing Scripts ========
(script static void (intf_load_vip_koth (boolean dbg_en) (boolean use_weather))
    (set intf_incd_m_welcome "sound\dialog\multiplayer\vip\vip")
    (set intf_incd_m_intro_cv "sound\dialog\multiplayer\flavor\hail_to_the_king")
    (set intf_incd_m_intro_sp "sound\dialog\multiplayer\flavor\hail_to_the_king")
    
    (intf_load_bgm dbg_en FALSE TRUE use_weather) ; auto music and no wave / lives announcer

)

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

(script static boolean plugin_incd_game_abt_end
    (cond 
        ((> (/ osa_koth_red_tally intf_koth_score_win) 0.85)
            (begin 
                (set intf_incd_endgame_m "levels\solo\m52\music\m52_music_09")
                (= 0 0)
            )
        )
        ((> (/ osa_koth_blue_tally intf_koth_score_win) 0.85)
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

(script static void plugin_bgm_goal_monitor
    (wake osa_koth_end_game)
)

(script static void plugin_bgm_default_win_cond
    (if (< osa_koth_blue_tally osa_koth_red_tally)
        (intf_bgm_set_game_end_state 1)
    )
    (if (> osa_koth_blue_tally osa_koth_red_tally)
        (intf_bgm_set_game_end_state 2)
    )
)

;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)
(global short intf_koth_score_win  5400) ;; 3600 originally. 5400 brings it close to time out.
(global short intf_koth_score_tier (/ intf_koth_score_win 8))

;; ========================== PUBLIC VARIABLES Read-Only ==================================


;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.


(global short osa_koth_bal_cnt_a 0)
(global short osa_koth_bal_cnt_b 0)
(global short osa_koth_bal_cnt_c 0)
(global short osa_koth_capture_a 0)
(global short osa_koth_capture_b 0)
(global short osa_koth_capture_c 0)
(global short osa_koth_side_a 0)
(global short osa_koth_side_b 0)
(global short osa_koth_side_c 0)



(global short osa_koth_red_tally 0)
(global short osa_koth_blue_tally 0)

(global short osa_koth_capture_amt 60)
(global long osa_koth_warn_per_a 0) ; 900 period
(global long osa_koth_warn_per_b 0) ; 900 period
(global long osa_koth_warn_per_c 0) ; 900 period

(global short INTF_KOTH_SIDE_RED 1)
(global short INTF_KOTH_SIDE_BLUE -1)


(script dormant osa_koth_tally_score
    ; tally every half second.
    (sleep_until 
        (begin 
            (if (> osa_koth_side_a 0)
                (set osa_koth_red_tally (+ osa_koth_red_tally 1))
            )
            (if (> osa_koth_side_b 0)
                (set osa_koth_red_tally (+ osa_koth_red_tally 1))
            )
            (if (> osa_koth_side_c 0)
                (set osa_koth_red_tally (+ osa_koth_red_tally 1))
            )
            (if (< osa_koth_side_a 0)
                (set osa_koth_blue_tally (+ osa_koth_blue_tally 1))
            )
            (if (< osa_koth_side_b 0)
                (set osa_koth_blue_tally (+ osa_koth_blue_tally 1))
            )
            (if (< osa_koth_side_c 0)
                (set osa_koth_blue_tally (+ osa_koth_blue_tally 1))
            )

            FALSE
        )
        15
    )
)

(script static void (osa_koth_spawn_by_tier (short side) (short tier_level))
    (if (= side 1)
        (cond 
            ((>= tier_level 6)
                (begin_random_count 1
                    (ai_place sq_def_red_t1)
                    (ai_place sq_def_red_t2)
                    (ai_place sq_def_red_t3)
                    (ai_place sq_def_red_t4)
                    (ai_place sq_def_red_t5)
                    (ai_place sq_def_red_t6)
                    (ai_place sq_def_red_t7)
                )
            )
            ((>= tier_level 5)
                (begin_random_count 1
                    (ai_place sq_def_red_t1)
                    (ai_place sq_def_red_t2)
                    (ai_place sq_def_red_t3)
                    (ai_place sq_def_red_t4)
                    (ai_place sq_def_red_t5)
                    (ai_place sq_def_red_t6)
                )
            )
            ((>= tier_level 4)
                (begin_random_count 1
                    (ai_place sq_def_red_t1)
                    (ai_place sq_def_red_t2)
                    (ai_place sq_def_red_t3)
                    (ai_place sq_def_red_t4)
                    (ai_place sq_def_red_t5)
                )
            )
            ((>= tier_level 3)
                (begin_random_count 1
                    (ai_place sq_def_red_t1)
                    (ai_place sq_def_red_t2)
                    (ai_place sq_def_red_t3)
                    (ai_place sq_def_red_t4)
                )
            )
            ((>= tier_level 2)
                (begin_random_count 1
                    (ai_place sq_def_red_t1)
                    (ai_place sq_def_red_t2)
                    (ai_place sq_def_red_t3)
                )
            )
            ((>= tier_level 1)
                (begin_random_count 1
                    (ai_place sq_def_red_t1)
                    (ai_place sq_def_red_t2)
                )
            )
            (TRUE
                (ai_place sq_def_red_t1)
            )
        )
        (cond 
            ((>= tier_level 6)
                (begin_random_count 1
                    (ai_place sq_def_blue_t1)
                    (ai_place sq_def_blue_t2)
                    (ai_place sq_def_blue_t3)
                    (ai_place sq_def_blue_t4)
                    (ai_place sq_def_blue_t5)
                    (ai_place sq_def_blue_t6)
                    (ai_place sq_def_blue_t7)
                )
            )
            ((>= tier_level 5)
                (begin_random_count 1
                    (ai_place sq_def_blue_t1)
                    (ai_place sq_def_blue_t2)
                    (ai_place sq_def_blue_t3)
                    (ai_place sq_def_blue_t4)
                    (ai_place sq_def_blue_t5)
                    (ai_place sq_def_blue_t6)
                )
            )
            ((>= tier_level 4)
                (begin_random_count 1
                    (ai_place sq_def_blue_t1)
                    (ai_place sq_def_blue_t2)
                    (ai_place sq_def_blue_t3)
                    (ai_place sq_def_blue_t4)
                    (ai_place sq_def_blue_t5)
                )
            )
            ((>= tier_level 3)
                (begin_random_count 1
                    (ai_place sq_def_blue_t1)
                    (ai_place sq_def_blue_t2)
                    (ai_place sq_def_blue_t3)
                    (ai_place sq_def_blue_t4)
                )
            )
            ((>= tier_level 2)
                (begin_random_count 1
                    (ai_place sq_def_blue_t1)
                    (ai_place sq_def_blue_t2)
                    (ai_place sq_def_blue_t3)
                )
            )
            ((>= tier_level 1)
                (begin_random_count 1
                    (ai_place sq_def_blue_t1)
                    (ai_place sq_def_blue_t2)
                )
            )
            (TRUE
                (ai_place sq_def_blue_t1)
            )
        )
    )
)

(script dormant osa_koth_replinish_blue_ai
    (sleep_until 
        (begin 
            (print "Tier level elites")
            (inspect (/ osa_koth_red_tally intf_koth_score_tier))
            (sleep_until 
                (begin 
                    (if (<= (ai_living_count gr_koth_def_blue) 12)
                        (begin 
                            (osa_koth_spawn_by_tier -1 (/ osa_koth_blue_tally intf_koth_score_tier));; send opposite tally bc we reward losers :)
                            (sleep intf_dir_migration_wait)
                        )
                    )
                    (>= (ai_living_count gr_koth_def_blue) 16)
                )
                10
            )
            (sleep 900)
            FALSE
        )
    )
)
(script dormant osa_koth_replinish_red_ai
    (sleep_until 
        (begin 
            (print "Tier level spartans")
            (inspect (/ osa_koth_blue_tally intf_koth_score_tier))
            (sleep_until 
                (begin 
                    (if (<= (ai_living_count gr_koth_def_red) 12)
                        (begin 
                            (osa_koth_spawn_by_tier 1 (/ osa_koth_blue_tally intf_koth_score_tier));; send opposite tally bc we reward losers :)
                            (sleep intf_dir_migration_wait)
                        )
                    )
                    (>= (ai_living_count gr_koth_def_red) 16)
                )
                10
            )
            (sleep 900)
            FALSE
        )
    )
)

(script dormant osa_koth_summon_capture
    (sleep_until 
        (begin 
            (if (<= (ai_living_count sq_obj_red) 0)
                (begin 
                    (sound_impulse_start "sound\dialog\multiplayer\vip\new_vip" NONE 1.0)
                    (ai_place sq_obj_red)
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_red) 0) (osa_utils_get_marker_type "defend"))
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_red) 1) (osa_utils_get_marker_type "defend"))
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_red) 2) (osa_utils_get_marker_type "defend"))
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_red) 3) (osa_utils_get_marker_type "defend"))
                )
            )
            (if (<= (ai_living_count sq_obj_blue) 0)
                (begin 
                    (sound_impulse_start "sound\dialog\multiplayer\vip\new_vip" NONE 1.0)
                    (ai_place sq_obj_blue)
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_blue) 0) (osa_utils_get_marker_type "neutralize"))
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_blue) 1) (osa_utils_get_marker_type "neutralize"))
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_blue) 2) (osa_utils_get_marker_type "neutralize"))
                    (intf_utils_callout_object_p (list_get (ai_actors sq_obj_blue) 3) (osa_utils_get_marker_type "neutralize"))
                )
            )
            (sleep 3600)
            FALSE
        )
    )
)

(script dormant osa_koth_test_a
    (sleep_until ;; updates every 5 seconds.
        (begin 
            (print "who's winning?:")
            (inspect osa_koth_red_tally)
            (inspect osa_koth_blue_tally)
            (print "==========================")
            (inspect osa_koth_bal_cnt_a)
            (inspect osa_koth_capture_a)
            (inspect osa_koth_side_a)
            (inspect osa_koth_bal_cnt_b)
            (inspect osa_koth_capture_b)
            (inspect osa_koth_side_b)
            (inspect osa_koth_bal_cnt_c)
            (inspect osa_koth_capture_c)
            (inspect osa_koth_side_c)
            (print "--------------------------")

            (set osa_koth_bal_cnt_a (* 10 (osa_koth_cnt_in_vol koth_a_capture)))
            (set osa_koth_capture_a (osa_koth_capture_events osa_koth_bal_cnt_a osa_koth_capture_a (osa_koth_contested_in_vol koth_a_capture) osa_koth_side_a koth_flag_a 0))
            (set osa_koth_side_a (osa_koth_capture_event_change osa_koth_bal_cnt_a osa_koth_capture_a osa_koth_side_a koth_flag_a 0))
            (osa_koth_update_markers osa_koth_side_a 0)
        FALSE)
        150
    )
)

(script dormant osa_koth_test_b
    (sleep_until ;; updates every 5 seconds.
        (begin 
            (set osa_koth_bal_cnt_b (* 10 (osa_koth_cnt_in_vol koth_b_capture)))
            (set osa_koth_capture_b (osa_koth_capture_events osa_koth_bal_cnt_b osa_koth_capture_b (osa_koth_contested_in_vol koth_b_capture) osa_koth_side_b koth_flag_b 1))
            (set osa_koth_side_b (osa_koth_capture_event_change osa_koth_bal_cnt_b osa_koth_capture_b osa_koth_side_b koth_flag_b 1))
            (osa_koth_update_markers osa_koth_side_b 1)
        FALSE)
        150
    )
)

(script dormant osa_koth_test_c
    (sleep_until ;; updates every 5 seconds.
        (begin 
            (set osa_koth_bal_cnt_c (* 10 (osa_koth_cnt_in_vol koth_c_capture)))
            (set osa_koth_capture_c (osa_koth_capture_events osa_koth_bal_cnt_c osa_koth_capture_c (osa_koth_contested_in_vol koth_c_capture) osa_koth_side_c koth_flag_c 2))
            (set osa_koth_side_c (osa_koth_capture_event_change osa_koth_bal_cnt_c osa_koth_capture_c osa_koth_side_c koth_flag_c 2))
            (osa_koth_update_markers osa_koth_side_c 2)
        FALSE)
        150
    )
)


(script static short (osa_koth_capture_events (short capture_state) (short capture_amt) (boolean contested) (short current_side) (object flag) (short flag_idx))
    (if (and (!= 0 capture_state) (< (max capture_amt (* -1 capture_amt)) osa_koth_capture_amt))
        (sound_impulse_start sound\device_machines\omaha\invasion_alarm1\track1\loop flag 1.0)
    )
    (if (and (> (max capture_amt (* -1 capture_amt)) 0) (< (max capture_amt (* -1 capture_amt)) (* 0.5 osa_koth_capture_amt)) (= 0 capture_state) (not contested) (!= 0 current_side))
        (sound_impulse_start sound\device_machines\omaha\invasion_data_core\track1\loop flag 1.0)
    )
    (if (or (< (* capture_state current_side) 0) contested)
        (begin 
            (osa_koth_warn_side current_side flag_idx)
            (sound_impulse_start sound\device_machines\omaha\invasion_alarm2\track1\loop flag 1.0)
        )
    )
    (if (= 0 capture_state)
        (- capture_amt (min (max capture_amt -1) 1)) ;; slowly degrade capture state.
        (if (or (< (max capture_amt (* -1 capture_amt)) osa_koth_capture_amt) (< (* capture_state current_side) 0))
            (+ capture_state capture_amt) ;; increase if below limit
            capture_amt ;; no change
        )
    )
)

(script static short (osa_koth_capture_event_change (short capture_state) (short capture_amt) (short current_side) (object flag) (short flag_idx))
    ;; reach threshold to capture
    ;; and was opposite team.
    (if (or (and (or (< (* capture_amt current_side) 0) (= 0 current_side)) (>= (max capture_amt (* -1 capture_amt)) osa_koth_capture_amt)) (and (= capture_state 0) (= capture_amt 0) (!= 0 current_side)))
        (begin 
            (osa_koth_confirm_sides current_side (osa_koth_side_from_score capture_amt) flag flag_idx)
            (osa_koth_side_from_score capture_amt)
        )
        current_side
    )
)


(script static void (osa_koth_update_markers (short side) (short index))
    (cond 
        ((= 0 index)
            (begin 
                (object_destroy koth_a_neutral)
                (object_destroy koth_a_red)
                (object_destroy koth_a_blue)
            )
            (if (= side 1)
                (object_create koth_a_red)
            )
            (if (= side -1)
                (object_create koth_a_blue)
            )
            (if (= side 0)
                (object_create koth_a_neutral)
            )
        )
        ((= 1 index)
            (begin 
                (object_destroy koth_b_neutral)
                (object_destroy koth_b_red)
                (object_destroy koth_b_blue)
            )
            (if (= side 1)
                (object_create koth_b_red)
            )
            (if (= side -1)
                (object_create koth_b_blue)
            )
            (if (= side 0)
                (object_create koth_b_neutral)
            )
        )
        ((= 2 index)
            (begin 
                (object_destroy koth_c_neutral)
                (object_destroy koth_c_red)
                (object_destroy koth_c_blue)
            )
            (if (= side 1)
                (object_create koth_c_red)
            )
            (if (= side -1)
                (object_create koth_c_blue)
            )
            (if (= side 0)
                (object_create koth_c_neutral)
            )
        )
    )
)


(script static short (osa_koth_side_from_score (short score))
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

(script static short (osa_koth_get_opposite_side (short side))
    (if (= side 0)
        -1
        1
    )
)

(script static boolean (osa_koth_get_hill_state (short side) (short index))
    (cond 
        ((= index 0)
            (or (!= osa_koth_side_a side) (osa_koth_contested_in_vol koth_a_capture))
        )
        ((= index 1)
            (or (!= osa_koth_side_b side) (osa_koth_contested_in_vol koth_b_capture))
        )
        ((= index 2)
            (or (!= osa_koth_side_c side) (osa_koth_contested_in_vol koth_c_capture))
        )
    )
)

(script static void (osa_koth_warn_side (short side) (short index))
    (cond 
        ((= 0 index)
            (begin 
                (if (>= (game_tick_get) osa_koth_warn_per_a)
                    (begin 
                        (if (= side 1)
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" covenant_player)
                        )
                        (set osa_koth_warn_per_a (+ (game_tick_get) 900))
                    )
                )
            )
            
        )
        ((= 1 index)
            (begin 
                (if (>= (game_tick_get) osa_koth_warn_per_b)
                    (begin 
                        (if (= side 1)
                            (submit_incident_with_cause_campaign_team "survival_bravo_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_bravo_under_attack" covenant_player)
                        )
                        (set osa_koth_warn_per_b (+ (game_tick_get) 900))
                    )
                )
            )
        )
        ((= 2 index)
            (begin 
                (if (>= (game_tick_get) osa_koth_warn_per_c)
                    (begin 
                        (if (= side 1)
                            (submit_incident_with_cause_campaign_team "survival_charlie_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_charlie_under_attack" covenant_player)
                        )
                        (set osa_koth_warn_per_c (+ (game_tick_get) 900))
                    )
                )
            )
        )
    )
)

(script static void (osa_koth_confirm_sides (short old_side) (short new_side) (object flag) (short index))
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

(script static short (osa_koth_cnt_in_vol  (trigger_volume vol))
    (+ ;; count only AI, players have to defend the capture AI to get the spot.
        ; (if (volume_test_objects vol (players_human))
        ;     1
        ;     0
        ; )
        ; (if (volume_test_objects vol (players_elite))
        ;     -1
        ;     0
        ; )
        (if (volume_test_objects vol (ai_actors gr_capture_red))
            1
            0
        )
        (if (volume_test_objects vol (ai_actors gr_capture_blue))
            -1
            0
        )
    )
)

(script static boolean (osa_koth_contested_in_vol  (trigger_volume vol))
    (and (or (volume_test_objects vol (players_human)) (volume_test_objects vol (ai_actors gr_capture_red))) (or (volume_test_objects vol (players_elite)) (volume_test_objects vol (ai_actors gr_capture_blue))))
)

(script dormant osa_koth_game_stages_red
    (sleep_until (> (/ osa_koth_red_tally intf_koth_score_win) 0.25))
    ; (osa_utils_play_sound_for_humans "sound\music\invasion_temp_cues\unsc_win1")
    (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph1_victory")
    (osa_utils_play_sound_for_elites "sound\dialog\invasion\bone_cv_ph1_defeat")
    (sleep_until (> (/ osa_koth_red_tally intf_koth_score_win) 0.50))
    ; (osa_utils_play_sound_for_humans "sound\music\invasion_temp_cues\unsc_win2")
    (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph2_victory")
    (osa_utils_play_sound_for_elites "sound\dialog\invasion\bone_cv_ph2_defeat")
    (sleep_until (> (/ osa_koth_red_tally intf_koth_score_win) 0.75))
    ; (osa_utils_play_sound_for_humans "sound\music\invasion_temp_cues\unsc_big_win")
    (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph3_victory")
    (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph3_defeat")
    (sleep_until (> (/ osa_koth_red_tally intf_koth_score_win) 0.85))
    (submit_incident_with_cause_campaign_team "sur_cla_cov_start" covenant_player) ;; warn players that SPARTANS ARE WINNING
)

(script dormant osa_koth_game_stages_blue
    (sleep_until (> (/ osa_koth_blue_tally intf_koth_score_win) 0.25))
    ; (osa_utils_play_sound_for_elites "sound\music\invasion_temp_cues\covy_win1")
    (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph1_victory")
    (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph1_defeat")
    (sleep_until (> (/ osa_koth_blue_tally intf_koth_score_win) 0.50))
    ; (osa_utils_play_sound_for_elites "sound\music\invasion_temp_cues\covy_win2")
    (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph2_victory")
    (osa_utils_play_sound_for_humans "sound\dialog\invasion\isle_sp_ph2_defeat")
    (sleep_until (> (/ osa_koth_blue_tally intf_koth_score_win) 0.75))
    ; (osa_utils_play_sound_for_elites "sound\music\invasion_temp_cues\covy_big_win")
    (osa_utils_play_sound_for_elites "sound\dialog\invasion\isle_cv_ph3_victory")
    (osa_utils_play_sound_for_humans "sound\dialog\invasion\bone_sp_ph3_defeat")
    (sleep_until (> (/ osa_koth_blue_tally intf_koth_score_win) 0.85))
    (submit_incident_with_cause_campaign_team "sur_cla_unsc_start" player) ;; warn players that ELITES ARE WINNING

)

(script dormant osa_koth_display_score_state
    (sleep_until 
        (begin 
            (osa_incid_check_win_status (min (max -1 (- osa_koth_red_tally osa_koth_blue_tally)) 1))
            FALSE
        )
        1
    )
)

(script dormant osa_koth_end_game
    (sleep_until (or (>= osa_koth_blue_tally intf_koth_score_win) (>= osa_koth_red_tally intf_koth_score_win)) 30)
    (plugin_bgm_default_win_cond) ; set the default win condition NOW.
)
