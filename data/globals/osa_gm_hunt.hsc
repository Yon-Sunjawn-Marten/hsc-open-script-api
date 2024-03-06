; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_incidents
; include osa_ai_director
; include osa_wave_spawner

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; One VIP - a MULE, help them eliminate the enemy team and keep it alive.
; Game over when one team runs out of lives (ai deaths subract lives)
; 
; 
; Editor Notes:
;
;

;; ========================== REQUIRED in Sapien ==================================

;; Objectives
;; All nonvehicle ai should follow players within 20 world units.

;; -------------------------- REQUIRED in Sapien ----------------------------------

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---
(global short intf_attr_max_lives_all 200)

; ======== Interfacing Scripts ========
(script static void intf_load_attrition


    (survival_mode_lives_set player intf_attr_max_lives_all)
    (survival_mode_lives_set player_elite intf_attr_max_lives_all)
)

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

(script static void plugin_bgm_goal_monitor
    (wake osa_attr_endgame)
    (wake osa_attr_display_score_state)
)

(script static void plugin_bgm_default_win_cond
    (if (> (survival_mode_lives_get player) (survival_mode_lives_get player_elite))
        (intf_bgm_set_game_end_state 1) ; spartans win
    )
    (if (< (survival_mode_lives_get player) (survival_mode_lives_get player_elite))
        (intf_bgm_set_game_end_state 2) ; elites win
    )
    (if (= (survival_mode_lives_get player) (survival_mode_lives_get player_elite))
        (intf_bgm_set_game_end_state 3) ; no one wins
    )
    
)

;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)

;; ========================== PUBLIC Scripts ==================================



;; ========================== PUBLIC VARIABLES Read-Only ==================================



;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.
;; osa_player_dead_count_elites
;; osa_player_dead_count_spartans
(global short osa_attr_ai_dead_red  0)
(global short osa_attr_ai_dead_blue 0)
(global short osa_attr_lives_red  intf_attr_max_lives_all)
(global short osa_attr_lives_blue intf_attr_max_lives_all)


(script dormant osa_attr_update_tickets
    (sleep_until 
        (begin 
            (set osa_attr_ai_dead_red (- (ai_spawn_count gr_dir_spartans) (ai_living_count gr_dir_spartans)))
            (set osa_attr_ai_dead_blue (- (ai_spawn_count gr_dir_elites) (ai_living_count gr_dir_elites)))
            (set osa_attr_lives_red (- intf_attr_max_lives_all osa_player_dead_count_spartans osa_attr_ai_dead_red))
            (set osa_attr_lives_blue (- intf_attr_max_lives_all osa_player_dead_count_elites osa_attr_ai_dead_blue))
            
            (survival_mode_lives_set player osa_attr_lives_red) ;; continually sets lives
            (survival_mode_lives_set player_elite osa_attr_lives_blue) ;; continually sets lives
        FALSE)
        15
    )
)

(script dormant osa_attr_endgame
    (sleep_until (or (= (survival_mode_lives_get player) 0) (= (survival_mode_lives_get player_elite) 0)))
    (plugin_bgm_default_win_cond) ;; delcare victory
)

(script dormant osa_attr_display_score_state
    (sleep_until 
        (begin 
            (osa_incid_check_win_status (min (max -1 (- osa_attr_lives_red osa_attr_lives_blue)) 1))
            FALSE
        )
    )
)
