; Copyright 2024 Yon-Sunjawn-Marten
;IMPORTS

; king of the hill prototype.

(global short osa_koth_bal_cnt_a 0)
(global short osa_koth_bal_cnt_b 0)
(global short osa_koth_bal_cnt_c 0)
(global short osa_koth_capture_a 0)
(global short osa_koth_capture_b 0)
(global short osa_koth_capture_c 0)
(global short osa_koth_side_a 0)
(global short osa_koth_side_b 0)
(global short osa_koth_side_c 0)
(global short osa_koth_capture_amt 60)
(global long osa_koth_warn_per_a 0) ; 900 period
(global long osa_koth_warn_per_b 0) ; 900 period
(global long osa_koth_warn_per_c 0) ; 900 period
; (global short osa_koth_lock_sec 45)
(global short test_item_types 0)
(script startup tim_main_test_volumes
    
    
	; setup director activities
	(intf_director_add_objective intf_koth_red/obj_task_wrapper)
	(intf_director_add_objective intf_koth_blue/obj_task_wrapper)


    (intf_director_add_squad_group gr_capture_red) ; set 0
	(intf_director_AUTO_migrate_gr_sq gr_koth_red_spawn 0) ; go 0
    (intf_director_add_squad_group gr_capture_blue) ; set 1
	(intf_director_AUTO_migrate_gr_sq gr_koth_blue_spawn 1) ; go 1

    (print "Zone states? A B C")
    (wake osa_koth_test_a)
    (wake osa_koth_test_b)
    (wake osa_koth_test_c)

    (object_hide koth_a_red true)
    (object_hide koth_b_red true)
    (object_hide koth_c_red true)
    (object_hide koth_a_blue true)
    (object_hide koth_b_blue true)
    (object_hide koth_c_blue true)
    (set intf_gr_dir_all gr_dir_all)
    (set intf_gr_dir_spartans gr_dir_spartans)
    (set intf_gr_dir_elites gr_dir_elites)
    (intf_load_ai_director false)

    (ai_place squads_0)
    (ai_place squads_1)
    (sleep 60)
    (ai_place squads_0)
    (ai_place squads_1)
    (sleep 60)
    (ai_place squads_0)
    (ai_place squads_1)
    (sleep 60)
    (ai_place squads_0)
    (ai_place squads_1)
    (sleep 60)
    (ai_place squads_0)
    (ai_place squads_1)
    (sleep 60)
    (ai_place squads_0)
    (ai_place squads_1)
    (sleep 60)
    (ai_place squads_0)
    (ai_place squads_1)

    ; (intf_utils_callout_object_p koth_a_neutral (osa_utils_get_marker_type "poi a"))
    ; (intf_utils_callout_object_p koth_b_neutral (osa_utils_get_marker_type "poi b"))
    ; (intf_utils_callout_object_p koth_c_neutral (osa_utils_get_marker_type "poi c"))
    ; (intf_utils_callout_object_p koth_a_red (osa_utils_get_marker_type "defend a"))
    ; (intf_utils_callout_object_p koth_b_red (osa_utils_get_marker_type "defend b"))
    ; (intf_utils_callout_object_p koth_c_red (osa_utils_get_marker_type "defend c"))
    ; (intf_utils_callout_object_p koth_a_blue (osa_utils_get_marker_type "attack a"))
    ; (intf_utils_callout_object_p koth_b_blue (osa_utils_get_marker_type "attack b"))
    ; (intf_utils_callout_object_p koth_c_blue (osa_utils_get_marker_type "attack c"))
    
    
)

(global short INTF_KOTH_SIDE_RED 1)
(global short INTF_KOTH_SIDE_BLUE -1)

(script static boolean (intf_koth_not_secure_red (short index))
    (osa_koth_get_hill_state INTF_KOTH_SIDE_RED index)
)

(script static boolean (intf_koth_not_secure_blue (short index))
    (osa_koth_get_hill_state INTF_KOTH_SIDE_BLUE index)
)

(script dormant osa_koth_test_a
    (sleep_until ;; updates every 5 seconds.
        (begin 
            (set osa_koth_bal_cnt_a (* 10 (osa_koth_cnt_in_vol koth_a_capture)))
            (set osa_koth_capture_a (osa_koth_capture_events osa_koth_bal_cnt_a osa_koth_capture_a (osa_koth_contested_in_vol koth_a_capture) osa_koth_side_a koth_flag_a 0))
            (inspect osa_koth_bal_cnt_a)
            (inspect osa_koth_capture_a)
            (inspect osa_koth_side_a)
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
            (inspect osa_koth_bal_cnt_b)
            (inspect osa_koth_capture_b)
            (inspect osa_koth_side_b)
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
            (inspect osa_koth_bal_cnt_c)
            (inspect osa_koth_capture_c)
            (inspect osa_koth_side_c)
            (set osa_koth_side_c (osa_koth_capture_event_change osa_koth_bal_cnt_c osa_koth_capture_c osa_koth_side_c koth_flag_c 2))
            (osa_koth_update_markers osa_koth_side_c 2)
        FALSE)
        150
    )
)


(script static short (osa_koth_capture_events (short capture_state) (short capture_amt) (boolean contested) (short current_side) (object flag) (short flag_idx))
    (if (and (!= 0 capture_state) (< (max capture_amt (* -1 capture_amt)) osa_koth_capture_amt))
        (sound_impulse_start sound\device_machines\omaha\invasion_alarm1\track1\loop flag 0.75)
    )
    (if (and (> (max capture_amt (* -1 capture_amt)) 0) (= 0 capture_state) (not contested))
        (sound_impulse_start sound\device_machines\omaha\invasion_data_core\track1\loop flag 0.75)
    )
    (if (or (< (* capture_state current_side) 0) contested)
        (begin 
            (osa_koth_warn_side current_side flag_idx)
            (sound_impulse_start sound\device_machines\omaha\invasion_alarm2\track1\loop flag 0.75)
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
    (if (and (or (< (* capture_amt current_side) 0) (= 0 current_side)) (>= (max capture_amt (* -1 capture_amt)) osa_koth_capture_amt))
        (begin 
            (osa_koth_confirm_sides current_side flag_idx)
            (osa_koth_side_from_score capture_amt)
        )
        current_side
    )
)


(script static void (osa_koth_update_markers (short side) (short index))
    (cond 
        ((= 0 index)
            (begin 
                (object_hide koth_a_neutral false)
                (object_hide koth_a_red false)
                (object_hide koth_a_blue false)
            )
            (if (!= side 1)
                (object_hide koth_a_red true)
            )
            (if (!= side -1)
                (object_hide koth_a_blue true)
            )
            (if (!= side 0)
                (object_hide koth_a_neutral true)
            )
        )
        ((= 1 index)
            (begin 
                (object_hide koth_b_neutral false)
                (object_hide koth_b_red false)
                (object_hide koth_b_blue false)
            )
            (if (!= side 1)
                (object_hide koth_b_red true)
            )
            (if (!= side -1)
                (object_hide koth_b_blue true)
            )
            (if (!= side 0)
                (object_hide koth_b_neutral true)
            )
        )
        ((= 2 index)
            (begin 
                (object_hide koth_c_neutral false)
                (object_hide koth_c_red false)
                (object_hide koth_c_blue false)
            )
            (if (!= side 1)
                (object_hide koth_c_red true)
            )
            (if (!= side -1)
                (object_hide koth_c_blue true)
            )
            (if (!= side 0)
                (object_hide koth_c_neutral true)
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
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" covenant_player)
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
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" player)
                            (submit_incident_with_cause_campaign_team "survival_alpha_under_attack" covenant_player)
                        )
                        (set osa_koth_warn_per_c (+ (game_tick_get) 900))
                    )
                )
            )
        )
    )
)

(script static void (osa_koth_confirm_sides (short side) (short index))
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
    (if (= side 1)
        (submit_incident_with_cause_campaign_team "survival_generator_lost" player)
    )
    (if (= side -1)
        (submit_incident_with_cause_campaign_team "survival_generator_lost" covenant_player)
    )
    (if (= side 0)
        (submit_incident "survival_generator_lost")
    )
)

(script static short (osa_koth_cnt_in_vol  (trigger_volume vol))
    (+
        (if (volume_test_objects vol (players_human))
            1
            0
        )
        (if (volume_test_objects vol (players_elite))
            -1
            0
        )
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
