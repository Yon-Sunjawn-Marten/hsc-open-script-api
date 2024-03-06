; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_ai_director

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Spawns waves of enemies for you.
; Option to use Transports.
; Option to use firefight templates.
; Option to use wave/round/set increment.
;
; Editor Notes:
;
;

;; ========================== REQUIRED in Sapien ==================================

; -> means make this parented UNDER.
; gr_waves_trans_red : parent your transports for red team under this. If no transports inside, then it is ignored.
; gr_waves_trans_blue : parent your transports for blue team under this. If no transports inside, then it is ignored.

; gr_waves_red  -> gr_dir_spartans ; this parent squad ships all AI to gr_dir_spartans.
; gr_waves_red_spawns -> gr_waves_red: fill this with spawnable squads.
; gr_waves_veh_red_spawns -> gr_waves_red : for vehicles.

; gr_waves_blue -> gr_dir_elites ; this parent squad ships all AI to gr_dir_elites.
; gr_waves_blue_spawns -> gr_waves_blue: fill this with spawnable squads.
; gr_waves_veh_blue_spawns -> gr_waves_blue : for vehicles.


;; Objectives
; If transports are used, I expect that they use the pool scripts or something to manage them.


; you are requred to implement this script. Part of a compile bug. (not my bug -_-)
; (script static void (plugin_wave_transport_vehicle_red (vehicle phantom))
    ; (print_if dbg_ff "plugin_wave_transport_vehicle_red")
; ) ;; use this script to supply hazard squads to vehicles when spawning.

; (script static void (plugin_wave_transport_vehicle_blue (vehicle phantom))
    ; (print_if dbg_ff "plugin_wave_transport_vehicle_blue")
; ) ;; use this script to supply hazard squads to vehicles when spawning.


;; -------------------------- REQUIRED in Sapien ----------------------------------

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---
(global boolean intf_waves_use_template FALSE)

(global boolean intf_waves_free_spawn_red TRUE) ;; can spawn without transport? Default : YES
(global boolean intf_waves_free_spawn_blue TRUE) ;; can spawn without transport? Default : YES

;; ---  Input Settings        ---
(global short intf_waves_cnt_red  0) ; leave as 0 if you don't want this to spawn them.
(global short intf_waves_cnt_blue 0)
(global short intf_waves_pause_red  900) ; time pause between respawns (ticks)
(global short intf_waves_pause_blue 900) ; time pause between respawns (ticks)

(global short intf_waves_squad_per_t_red  2) ; number of squads per vehicle
(global short intf_waves_squad_per_t_blue 4) ; number of squads per vehicle (phantoms/spirits can hold more.)

; ======== Interfacing Scripts ========
(script static void (intf_load_wave_spawner (boolean dbg_en))
    (set intf_num_transport_spartans (ai_squad_group_get_squad_count gr_waves_trans_red))
    (set intf_num_transport_elites   (ai_squad_group_get_squad_count gr_waves_trans_blue))

    (if (= 0 intf_num_transport_spartans)
        (set intf_waves_free_spawn_red FALSE)
    )
    (if (= 0 intf_num_transport_elites)
        (set intf_waves_free_spawn_blue FALSE)
    )

    (intf_director_add_squad_group gr_dir_spartans) ; set 0
	(intf_director_AUTO_migrate_gr_sq gr_waves_red 0) ; go 0
    (intf_director_add_squad_group gr_dir_elites) ; set 1
	(intf_director_AUTO_migrate_gr_sq gr_waves_blue 1) ; go 1
    (intf_load_ai_director dbg_en)
    (print "load wave spawner. Done.")
    (wake osa_wave_place_red)
    (wake osa_wave_place_blue)
)

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

(script stub boolean plugin_wave_spawn_cond_red
    (and 
        (< (ai_living_count gr_dir_spartans) intf_waves_cnt_red)
        (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
    )
)

(script stub boolean plugin_wave_spawn_cond_blue
    (and 
        (< (ai_living_count gr_dir_elites) intf_waves_cnt_blue)
        (intf_director_can_spawn_ai_x OSA_DIR_SIDE_ELITE 4)
    )
)

(script stub void plugin_wave_spawn_wait_red
    (sleep intf_waves_pause_red)
)

(script stub void plugin_wave_spawn_wait_blue
    (sleep intf_waves_pause_blue)
)

;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)

;; ========================== PUBLIC Scripts ==================================



;; ========================== PUBLIC VARIABLES Read-Only ==================================



;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.

(global short osa_wave_t_pool_idx_red 0)
(global short osa_wave_t_pool_idx_blue 0)

(global short osa_wave_spawned_t_red 0)
(global short osa_wave_spawned_t_blue 0)

(global short osa_wave_loaded_t_red 0)
(global short osa_wave_loaded_t_blue 0)

(global vehicle current_spawn_veh_red NONE)
(global vehicle current_spawn_veh_blue NONE)

(script dormant osa_wave_place_red
    (sleep_until 
        (begin 
            (print "spawner stage 1 red")
            (set osa_wave_loaded_t_red 0)
            (sleep_until (plugin_wave_spawn_cond_red) 1) ;; dont spawn anything until possible.
            (sleep_until 
                (begin 
                    (print "spawner stage 2 red")
                    (if (plugin_wave_spawn_cond_red) ;; can spawn ai
                        (begin 
                            (print "spawner stage 3 red")
                            (set intf_dir_migration_en false) ; dont move ai Yet..
                            (if (< osa_wave_loaded_t_red (* intf_waves_squad_per_t_red osa_use_transport_spartans))
                                (begin 
                                    (set osa_wave_spawned_t_red (random_range 0 osa_use_transport_spartans))
                                    (osa_director_spawn_if_dead gr_waves_trans_red osa_wave_spawned_t_red)
                                    (sleep 5) ; sleep a bit for scripts to run
                                    (set osa_wave_t_pool_idx_red (intf_pool_get_thread_from_sq (ai_squad_group_get_squad gr_waves_trans_red osa_wave_spawned_t_red)))
                                    (cond ;; dont want to return a vehicle type from this.
                                        ((= 0 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_0)
                                        )
                                        ((= 1 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_1)
                                        )
                                        ((= 2 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_2)
                                        )
                                        ((= 3 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_3)
                                        )
                                    )
                                    (print "Red place Squad in Transport!")
                                    (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
                                        (begin 
                                            (osa_director_spawn_random_sq_full gr_waves_red_spawns FALSE)
                                            (set osa_wave_loaded_t_red (+ osa_wave_loaded_t_red 1))
                                            (osa_ds_load_dropship current_spawn_veh_red (intf_pool_get_load_type_for_inf osa_wave_t_pool_idx_red) gr_waves_red_spawns NONE NONE)
                                        )
                                    )
                                )
                                (begin 
                                    (if intf_waves_free_spawn_red
                                        (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
                                            (osa_director_spawn_random_sq_full gr_waves_red_spawns FALSE)
                                        )
                                        (begin 
                                            (print "wave loop, wait for available transport.")
                                            (sleep_until (= 0 (ai_living_count gr_waves_trans_red)) 15) ; wait for transport.
                                            (set osa_wave_spawned_t_red 0)
                                            (set osa_wave_loaded_t_red 0)
                                        )
                                    )
                                )
                                
                            )
                            (set intf_dir_migration_en true) ; move ai into mission.
                            (sleep_until (<= (ai_living_count gr_waves_red_spawns) 0))
                        )
                    )
                    
                    (not (plugin_wave_spawn_cond_red)) ; spawn until we have enough people to meet the condition.
                )
            )
            (print "red wave spawn done... load vehicles if applicable.")
            (if (> osa_use_transport_spartans 0)
                (begin 
                    (set osa_wave_spawned_t_red 0)
                    (sleep_until 
                        (begin 
                            (if (> (ai_living_count (ai_squad_group_get_squad gr_waves_trans_red osa_wave_spawned_t_red)) 0)
                                (begin 
                                    (print "red try load a vehicle into transport.")
                                    (set osa_wave_t_pool_idx_red (intf_pool_get_thread_from_sq (ai_squad_group_get_squad gr_waves_trans_red osa_wave_spawned_t_red)))
                                    (cond ;; dont want to return a vehicle type from this.
                                        ((= 0 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_0)
                                        )
                                        ((= 1 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_1)
                                        )
                                        ((= 2 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_2)
                                        )
                                        ((= 3 osa_wave_t_pool_idx_red)
                                            (set current_spawn_veh_red intf_pool_t_vehicle_3)
                                        )
                                    )
                                    (plugin_wave_transport_vehicle_red current_spawn_veh_red)
                                )
                            )
                            (set osa_wave_spawned_t_red (+ osa_wave_spawned_t_red 1))
                            (sleep_until (<= (ai_living_count gr_waves_veh_red_spawns) 0))
                            (>= osa_wave_spawned_t_red osa_use_transport_spartans)
                        )
                        1
                    )
                )
            )
            (sleep_until (= (ai_living_count gr_waves_trans_red) 0)) ;; wait until transports leave.
            (plugin_wave_spawn_wait_red) ;; wait until spawn is available again.
            FALSE
        )
        1
    )
    
)
; (script dormant osa_wave_place_red_transport
;     (print "none")
; )

(script dormant osa_wave_place_blue
    (sleep_until 
        (begin 
            (print "spawner stage 1 blue")
            (set osa_wave_loaded_t_blue 0)
            (sleep_until (plugin_wave_spawn_cond_blue) 1) ;; dont spawn anything until possible.
            (set s_survival_state_wave 1)
            (sleep_until 
                (begin 
                    (print "spawner stage 2 blue")
                    (if (plugin_wave_spawn_cond_blue) ;; can spawn ai
                        (begin 
                            (print "spawner stage 3 blue")
                            (set intf_dir_migration_en false) ; dont move ai Yet..
                            (if (< osa_wave_loaded_t_blue (* intf_waves_squad_per_t_blue osa_use_transport_elites))
                                (begin 
                                    (set osa_wave_spawned_t_blue (random_range 0 osa_use_transport_elites))
                                    (osa_director_spawn_if_dead gr_waves_trans_blue osa_wave_spawned_t_blue)
                                    (sleep 5) ; sleep a bit for scripts to run
                                    (set osa_wave_t_pool_idx_blue (intf_pool_get_thread_from_sq (ai_squad_group_get_squad gr_waves_trans_blue osa_wave_spawned_t_blue)))
                                    (cond ;; dont want to return a vehicle type from this.
                                        ((= 0 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_0)
                                        )
                                        ((= 1 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_1)
                                        )
                                        ((= 2 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_2)
                                        )
                                        ((= 3 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_3)
                                        )
                                    )
                                    (print "blue place Squad in Transport!")
                                    (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_ELITE 4)
                                        (begin 
                                            (osa_director_spawn_random_sq_full gr_waves_blue_spawns intf_waves_use_template)
                                            (set osa_wave_loaded_t_blue (+ osa_wave_loaded_t_blue 1))
                                            (osa_ds_load_dropship current_spawn_veh_blue (intf_pool_get_load_type_for_inf osa_wave_t_pool_idx_blue) gr_waves_blue_spawns NONE NONE)
                                        )
                                    )
                                )
                                (begin 
                                    (if intf_waves_free_spawn_blue
                                        (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_ELITE 4)
                                            (osa_director_spawn_random_sq_full gr_waves_blue_spawns intf_waves_use_template)
                                        )
                                        (begin 
                                            (print "wave loop, wait for available transport.")
                                            (sleep_until (= 0 (ai_living_count gr_waves_trans_blue)) 15) ; wait for transport.
                                            (set osa_wave_spawned_t_blue 0)
                                            (set osa_wave_loaded_t_blue 0)
                                        )
                                    )
                                )
                                
                            )
                            (set intf_dir_migration_en true) ; move ai into mission.
                            (sleep_until (<= (ai_living_count gr_waves_blue_spawns) 0))
                        )
                    )
                    
                    (not (plugin_wave_spawn_cond_blue)) ; spawn until we have enough people to meet the condition.
                )
            )
            (print "blue wave spawn done... load vehicles if applicable.")
            (if (> osa_use_transport_elites 0)
                (begin 
                    (set osa_wave_spawned_t_blue 0)
                    (sleep_until 
                        (begin 
                            (if (> (ai_living_count (ai_squad_group_get_squad gr_waves_trans_blue osa_wave_spawned_t_blue)) 0)
                                (begin 
                                    (print "blue try load a vehicle into transport.")
                                    (set osa_wave_t_pool_idx_blue (intf_pool_get_thread_from_sq (ai_squad_group_get_squad gr_waves_trans_blue osa_wave_spawned_t_blue)))
                                    (cond ;; dont want to return a vehicle type from this.
                                        ((= 0 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_0)
                                        )
                                        ((= 1 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_1)
                                        )
                                        ((= 2 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_2)
                                        )
                                        ((= 3 osa_wave_t_pool_idx_blue)
                                            (set current_spawn_veh_blue intf_pool_t_vehicle_3)
                                        )
                                    )
                                    (plugin_wave_transport_vehicle_blue current_spawn_veh_blue)
                                )
                            )
                            (set osa_wave_spawned_t_blue (+ osa_wave_spawned_t_blue 1))
                            (sleep_until (<= (ai_living_count gr_waves_veh_blue_spawns) 0))
                            (>= osa_wave_spawned_t_blue osa_use_transport_elites)
                        )
                        1
                    )
                )
            )
            (sleep_until (= (ai_living_count gr_waves_trans_blue) 0)) ;; wait until transports leave.
            (plugin_wave_spawn_wait_blue) ;; wait until spawn is available again.
            (set s_survival_state_wave 2)
            FALSE
        )
        1
    )
    
)

; (script dormant osa_wave_place_blue_transport
;     (print "none")
; )