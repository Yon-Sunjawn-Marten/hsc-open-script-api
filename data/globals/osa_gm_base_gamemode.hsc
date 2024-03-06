; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_utils
; include osa_incidents

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; This file contains the base required elements to have a functioning game.
; Life management is not part of this. Assume infinite lives on both sides.
;
; Editor Notes:
;
;

;; ========================== REQUIRED in Sapien ==================================

; First load up a valid firefight mission, then load yours.
; trigger_volume => garbage_collection

;; -------------------------- REQUIRED in Sapien ----------------------------------

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

(script static void (intf_load_bgm (boolean dbg_en) (boolean use_anouncer) (boolean use_auto_music) (boolean use_weather))
    (set dbg_bgm dbg_en)
    (garbage_collect_now) ; Garbage collect, in case anything is left over from previous rounds (sob)

	(ai_allegiance human player)
	(ai_allegiance player human)
	(ai_allegiance covenant covenant_player)
	(ai_allegiance covenant_player covenant)
    
    (if (< (survival_mode_get_shared_team_life_count) 0)
		(survival_mode_lives_set player -1)
		(survival_mode_lives_set player (survival_mode_get_shared_team_life_count))		
	); Crashes sapien without first loading a FF mission
	(if (< (survival_mode_get_elite_life_count) 0)
		(survival_mode_lives_set covenant_player -1)
		(survival_mode_lives_set covenant_player (survival_mode_get_elite_life_count))
	); Crashes sapien without first loading a FF mission
    
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

    (intf_load_incd dbg_en use_anouncer use_auto_music use_weather)
    (wake routine_bgm_end_game)
    (wake routine_bfm_track_time)
    (wake routine_bfm_detect_game_start)
    (wake routine_display_score_state)
    (sleep_until intf_bgm_game_start) ;; sleeps until a player spawns. Holds rest of loading for this.
) ; load this script in your game mode init. It can be used to block game start until a player spawns.

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---
(global short intf_bgm_end_game_condition 0) ;; use to declare victory for a side. 1 or 2
(global boolean intf_bgm_kill_threads false) ; use this to end monitoring loops.
(global boolean intf_bgm_game_start false) ; auto set by player spawn detector
(global short intf_bgm_recycle_period (* 30 60 2)) ;; recycle every 2 minutes.

; ======== Interfacing Scripts ========
(script static void (intf_bgm_set_game_end_state (short value))
	(if (not (osa_bgm_test_game_end_cond)) ;; game not declared yet.
		(set intf_bgm_end_game_condition value)
	)
)

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

(script stub void plugin_bgm_goal_monitor
    (print "implement something to end game based on a goal")
    ; wake your script
)
(script stub void plugin_bgm_default_win_cond
    (intf_bgm_set_game_end_state 1) ; spartans win
)
(script stub void plugin_bgm_game_over_event
    (if (= intf_bgm_end_game_condition 1) ;; default event.
        (event_survival_spartans_win_normal)
    )
    (if (= intf_bgm_end_game_condition 2)
        (event_survival_elites_win_normal)
    )
)
(script stub boolean plugin_bgm_sudden_death_cond
    (print "no sudden death by default")
    FALSE
)
(script stub void plugin_bgm_sudden_death_event
    (print "Enter Sudden Death Extension")
) ;; use this to do extra things during sudden death.
;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)
;; Common variables among game types that can allow you to put multiple missions on the same map file.
; osa_bgm_red_score


(global short intf_bgm_score_win  5400) ;; 3600 originally. 5400 brings it close to time out.
(global short intf_bgm_score_tier (/ intf_bgm_score_win 8)) ;; for progress based rewards/triggers.

(global short intf_bgm_red_score 0)
(global short intf_bgm_blue_score 0)

(global short INTF_BGM_SIDE_RED 1)
(global short INTF_BGM_SIDE_BLUE -1)

;; ========================== PUBLIC VARIABLES Read-Only ==================================

(global long osa_bgm_round_timer 0) ;; in seconds
(global short osa_bgm_sudden_death_en 0) ; 0 no, 1 started, 2 end.
(global long osa_bgm_time_limit_ticks (* (survival_mode_get_time_limit) 60 30))

;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.

(global boolean dbg_bgm False)
; Has a human player ever spawned?


(script static boolean osa_bgm_test_game_end_cond
	(!= intf_bgm_end_game_condition 0)
)

(script static void osa_bgm_game_over
    (set intf_bgm_kill_threads true) ;; kill any running thread that may block exit.
    (if (= intf_bgm_end_game_condition 1)
		(survival_spartans_increment_score) ; -> osa_utils.hsc
	)
    (if (= intf_bgm_end_game_condition 2)
        (survival_elites_increment_score) ; -> osa_utils.hsc
    )
    (plugin_bgm_game_over_event) ; normal win gets overridden all by including the file as a script.
)

(script dormant routine_bfm_detect_game_start
    (sleep_until (> osa_con_players_all 0))
    (set intf_bgm_game_start true)
) ; blocks game over from human deaths when humans aren't present.

(script dormant routine_bgm_end_game
    (wake routine_bgm_default_end_cond)
    (plugin_bgm_goal_monitor)
    (if (<= osa_bgm_time_limit_ticks 0)
        (sleep_until (osa_bgm_test_game_end_cond) 30)
        (sleep_until (osa_bgm_test_game_end_cond) 30 osa_bgm_time_limit_ticks)
    )
    (if (>= osa_bgm_round_timer (* (survival_mode_get_time_limit) 60))
        (event_survival_time_up)
    )
    (plugin_bgm_default_win_cond)
    (osa_bgm_game_over)
    (sleep 120)
    (mp_round_end_with_winning_team none)
)

(script dormant routine_bfm_track_time
    (sleep_until 
        (begin 
            (if (> (survival_mode_get_time_limit) 0)
                (cond
                    ((= (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) 10)
                        (sound_impulse_start "sound\dialog\multiplayer\general\ten_secs_remaining" NONE 1.0)
                    )
                    ((= (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) 30)
                            (if (> osa_incid_win_state 0)
                                (begin 
                                    (osa_utils_play_sound_for_humans "sound\dialog\multiplayer\general\thirty_secs_to_win")
                                    (osa_utils_play_sound_for_elites "sound\dialog\multiplayer\general\thirty_secs_remaining")
                                )
                            )
                            (if (< osa_incid_win_state 0)
                                (begin 
                                    (osa_utils_play_sound_for_humans "sound\dialog\multiplayer\general\thirty_secs_remaining")
                                    (osa_utils_play_sound_for_elites "sound\dialog\multiplayer\general\thirty_secs_to_win")
                                )
                            )
                            (if (= osa_incid_win_state 0)
                                (begin 
                                    (sound_impulse_start "sound\dialog\multiplayer\general\thirty_secs_remaining" NONE 1.0)
                                )
                            )
                    )
                    ((= (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) (* 1 60))
                            (if (> osa_incid_win_state 0)
                                (begin 
                                    (osa_utils_play_sound_for_humans "sound\dialog\multiplayer\general\one_min_to_win")
                                    (osa_utils_play_sound_for_elites "sound\dialog\multiplayer\general\one_min_remaining")
                                )
                            )
                            (if (< osa_incid_win_state 0)
                                (begin 
                                    (osa_utils_play_sound_for_humans "sound\dialog\multiplayer\general\one_min_remaining")
                                    (osa_utils_play_sound_for_elites "sound\dialog\multiplayer\general\one_min_to_win")
                                )
                            )
                            (if (= osa_incid_win_state 0)
                                (begin 
                                    (sound_impulse_start "sound\dialog\multiplayer\general\one_min_remaining" NONE 1.0)
                                )
                            )
                    )
                    ((= (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) (* 5 60))
                        (sound_impulse_start "sound\dialog\multiplayer\general\five_mins_remaining" NONE 1.0)
                    )
                    ((= (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) (* 15 60))
                        (sound_impulse_start "sound\dialog\multiplayer\general\fifteen_mins_remaining" NONE 1.0)
                    )
                    ((= (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) (* 30 60))
                        (sound_impulse_start "sound\dialog\multiplayer\general\thirty_mins_remaining" NONE 1.0)
                    )
                )
            )
            (set osa_bgm_round_timer (+ osa_bgm_round_timer 1))
            intf_bgm_kill_threads
        )
    )
)

(script dormant routine_bgm_default_end_cond
    (sleep_until intf_bgm_game_start)
    (sleep_until 
        (begin 
            (if (and (osa_utils_players_dead) (osa_utils_players_not_respawning) (> osa_con_players_human 0))
                (intf_bgm_set_game_end_state 2) ; a human had to be playing for elites to win by no respawn.
            )
            (if (or 
                (and (> (survival_mode_get_time_limit) 0) (>= osa_bgm_round_timer (* (survival_mode_get_time_limit) 60)))
                (and (> (survival_mode_get_set_count) 0) (>= (survival_mode_set_get) (survival_mode_get_set_count)))
                )
                (if (plugin_bgm_sudden_death_cond)
                    (set osa_bgm_sudden_death_en 2)
                    (wake osa_bgm_sudden_death)
                )
            )
            intf_bgm_kill_threads
        )
    )
)

(script dormant routine_display_score_state
    (sleep_until 
        (begin 
            (osa_incid_check_win_status (min (max -1 (- intf_bgm_red_score intf_bgm_blue_score)) 1))
            FALSE
        )
    )
)

(script dormant osa_bgm_sudden_death
    (event_survival_sudden_death)
    (survival_mode_sudden_death true)
    (set osa_bgm_sudden_death_en 1)
    (sleep_until (not (plugin_bgm_sudden_death_cond)) 2 1800)
    (set osa_bgm_sudden_death_en 2)
    (event_survival_sudden_death_over)
	(survival_mode_sudden_death false)
)


; In it's own thread
(script continuous osa_bgm_garbage_collector
    (sleep intf_bgm_recycle_period)
	(add_recycling_volume_by_type garbage_collection 4 20 16371)
	(sleep (* 30 20))
	(add_recycling_volume_by_type garbage_collection 30 10 12)
)