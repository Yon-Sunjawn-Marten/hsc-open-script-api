; Copyright 2024 Yon-Sunjawn-Marten

;; Example mission script making use of the libraries to set up firefight on forgeworld.

; This script triggers squad/individual drop pods to spawn at random locations.
; It triggers a marine reinforcement with random vehicle.
; Both sides navigate around the island.
; The AI director was told that the number of AI supported on the map is 60.. 60 is too much for just the island.

(script startup main_script
    (print "Mission start!")
    
    (intf_director_add_squad_group gr_obj_team) ; set 0
    (intf_director_add_squad_group gr_obj_vehicles) ; set 1
    (intf_director_add_squad_group gr_ff_hazards) ; set 2

    (intf_director_AUTO_migrate_gr_sq gr_main_spawn 0) ; go 0
    (intf_director_AUTO_migrate_gr_sq gr_vehicle_spawn 1) ; go 1
    (intf_director_AUTO_migrate_gr_sq gr_ff_hazards_spawn 2) ; go 2

    (intf_director_add_objective ai_objectives_1/obj_task_wrapper)
    (intf_director_add_objective ai_objectives_v/obj_task_wrapper)
    
    (intf_director_add_objective intf_ff_objective/obj_task_wrapper) ;- auto refreshed.

    (intf_utils_add_health_kit hp_0)
    (intf_utils_add_health_kit hp_1)
    (intf_utils_add_health_kit hp_2)
    (intf_utils_add_proximity_callout ab_0 (osa_utils_get_marker_type "ammo"))
    (intf_utils_add_proximity_callout veh_0 (osa_utils_get_marker_type "poi blue"))

    (intf_pool_add_drop_point dm_sq_pod_0 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_sq_pod_1 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_sq_pod_2 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_sq_pod_3 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_sq_pod_4 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_resup_0 OSA_POOL_DROP_WEAPON)
    (intf_pool_add_drop_point dm_resup_1 OSA_POOL_DROP_WEAPON)
    (intf_pool_add_drop_point dm_resup_2 OSA_POOL_DROP_WEAPON)
    (intf_pool_add_drop_point dm_resup_3 OSA_POOL_DROP_WEAPON)
    (intf_pool_add_drop_point dm_resup_4 OSA_POOL_DROP_WEAPON)
    (intf_pool_add_drop_point dm_e_pod_0 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_e_pod_1 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_e_pod_2 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_e_pod_3 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_e_pod_4 OSA_POOL_DROP_TROOP)

    (intf_pool_set_drop_cleanup dm_resup_0 5400) ; a 3 minute timeout to delete
    (intf_pool_set_drop_cleanup dm_resup_1 5400)
    (intf_pool_set_drop_cleanup dm_resup_2 5400)
    (intf_pool_set_drop_cleanup dm_resup_3 5400)
    (intf_pool_set_drop_cleanup dm_resup_4 5400)

    ;ps_pool_0
    (intf_pool_add_transport sq_pel_0 OSA_POOL_SIDE_SPARTAN "vany" "any")
    (intf_pool_set_transport_tracks sq_pel_0 0 10 19)
    (intf_pool_set_transport_drop_a sq_pel_0 3 13 22)
    (intf_pool_set_transport_drop_b sq_pel_0 6 16 22)
    (intf_pool_set_transport_movement sq_pel_0 TRUE 0 0 0) ; no hold points for this map.
    (intf_pool_set_transport_drop_a_face_point sq_pel_0 0 0 0)
    (intf_pool_set_transport_drop_b_face_point sq_pel_0 7 0 0)
    (intf_pool_set_transport_marker sq_pel_0 (osa_utils_get_marker_type "poi blue"))
    (intf_pool_set_transport_slow_at sq_pel_0 0 12 21)
    (intf_pool_set_transport_fast_at sq_pel_0 0 17 23)

    (intf_pool_add_transport sq_phm_0 OSA_POOL_SIDE_ELITE "vany" "any")
    (intf_pool_set_transport_drop_a sq_phm_0 3 3 3)
    (intf_pool_set_transport_drop_b sq_phm_0 6 6 6)
    (intf_pool_set_transport_movement sq_phm_0 TRUE 0 0 0)
    (intf_pool_set_transport_drop_a_face_point sq_phm_0 2 2 2)
    (intf_pool_set_transport_drop_b_face_point sq_phm_0 5 5 5)
    (intf_pool_set_transport_tracks sq_phm_0 0 0 0)
    (intf_pool_set_transport_marker sq_phm_0 (osa_utils_get_marker_type "poi red"))
    
    (intf_pool_add_transport sq_phm_1 OSA_POOL_SIDE_ELITE "vany" "any")
    (intf_pool_set_transport_drop_a sq_phm_1 2 2 2)
    (intf_pool_set_transport_drop_b sq_phm_1 3 3 3)
    (intf_pool_set_transport_movement sq_phm_1 TRUE 0 0 0)
    (intf_pool_set_transport_drop_a_face_point sq_phm_1 2 2 2)
    (intf_pool_set_transport_drop_b_face_point sq_phm_1 5 5 5)
    (intf_pool_set_transport_tracks sq_phm_1 0 0 0)
    (intf_pool_set_transport_marker sq_phm_1 (osa_utils_get_marker_type "poi red"))
    
    (intf_pool_add_transport sq_phm_2 OSA_POOL_SIDE_ELITE "vany" "any")
    (intf_pool_set_transport_drop_a sq_phm_2 2 2 2)
    (intf_pool_set_transport_drop_b sq_phm_2 3 3 3)
    (intf_pool_set_transport_movement sq_phm_2 TRUE 3 0 0)
    (intf_pool_set_transport_drop_a_face_point sq_phm_2 2 2 2)
    (intf_pool_set_transport_drop_b_face_point sq_phm_2 5 5 5)
    (intf_pool_set_transport_tracks sq_phm_2 0 0 0)
    (intf_pool_set_transport_marker sq_phm_2 (osa_utils_get_marker_type "poi red"))

    (intf_hazpl_set_event_period 0 900 2800)
    (intf_hazpl_set_event_period 1 900 4000)
    ; haz 0
    (intf_pool_add_hazard sq_cov_drop_0 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 0)
    (intf_pool_add_hazard sq_cov_drop_1 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 0)
    (intf_pool_add_hazard sq_cov_drop_solo_0 OSA_DIR_TYPE_SINGLE OSA_DIR_SIDE_ELITE 0)
    (intf_hazpl_repeat_hazard_spawn sq_cov_drop_solo_0 3 5)

    ; haz 1
    (intf_pool_add_hazard sq_haz_drop_vip_0 OSA_DIR_TYPE_SINGLE OSA_DIR_SIDE_ELITE 1)
    (intf_hazpl_use_permanent_callout sq_haz_drop_vip_0 (osa_utils_get_marker_type "neutralize"))
    

    ; override 
    ; HAZPOOL 4
    (intf_hazpl_set_event_period 4 100 300) ;900 3600
    (intf_pool_add_hazard sq_pel_0 OSA_DIR_TYPE_SINGLE OSA_DIR_SIDE_SPARTAN 4)


    (set intf_gr_dir_all        gr_dir_all)
    (set intf_gr_dir_spartans   gr_dir_spartans)
    (set intf_gr_dir_elites     gr_dir_elites)
    (set intf_part_max_bipeds 60) ; max ai in field
    (intf_load_ai_director false)
    
    (set intf_gr_ff_waves   gr_ff_waves)
    (set intf_sq_ff_remain  sq_wave_remaining)
    (set intf_sq_ff_bonus   sq_waves_bonus)
    (set ai_sur_phantom_01 sq_phm_0)
    (set ai_sur_phantom_02 sq_phm_1)
    (set ai_sur_phantom_03 sq_phm_2)
    (set ai_sur_bonus_phantom sq_phm_2)
    (set intf_num_transport_elites 3)
    (intf_ff_force_use_transports)
    (intf_load_ff false)
)

(script static void (intf_plugin_ff_hazard_spawn_0 (vehicle phantom))
    ;(print "phantom use my hazards")
    (begin_random_count 1
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_ELITE OSA_DIR_TYPE_WRAITH 1)
            (osa_ds_load_dropship_place phantom "vany" squads_wraith_0 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_ELITE OSA_DIR_TYPE_GHOST 2)
            (osa_ds_load_dropship_place phantom "vany" squads_ghost_0 squads_ghost_1 NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_ELITE OSA_DIR_TYPE_REVENANT 2)
            (osa_ds_load_dropship_place phantom "vany" squads_rev_0 squads_rev_1 NONE)
        )
    )
    
)

(script static void intf_resupply_weapon_drop_0
    (wake fwld_resupply_thread)
)

(script dormant fwld_resupply_thread
	(print "bringing in longsword...")
	(sleep 1)
	(device_set_position_track longsword_0 "ff10" 0)
	(device_animate_position longsword_0 1 10.0 3 3 FALSE)
	(sleep_until (>= (device_get_position longsword_0) 0.4) 1)
    (begin_random_count intf_resupply_max_drop_pods
        (intf_pool_drop_a_pod sc_resup_0 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resup_1 OSA_POOL_DROP_WEAPON)
    )
	(sleep_until (>= (device_get_position longsword_0) 0.8) 1)
	(osa_utils_reset_device longsword_0)
)

; HAZPOOL EVENT 4
(script static boolean intf_hazpl_event_4
    (sleep_until (= (ai_living_count sq_pel_0) 0))
    (sleep (random_range intf_hazpl_event_p_min_4 intf_hazpl_event_p_max_4))
	(print "Run event 4")
    TRUE
)
(script static void intf_plugin_hazpl_thread_4
    (print "pelican load reinforcements!")
    (sleep 1)
    (intf_pool_get_transport_running_script sq_pel_0)
    (inspect (!= NONE intf_pool_t_running_export))
    (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
        (osa_ds_load_dropship_place intf_pool_t_running_export "any" sq_marines_0 NONE NONE)
    )
    (sleep 1)
    (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
        (osa_ds_load_dropship_place intf_pool_t_running_export "any" sq_marines_0 NONE NONE)
    )
    (sleep 1)
    (begin_random_count 1
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_WARTHOG_CHAINGUN 1)
            (osa_ds_load_dropship_place intf_pool_t_running_export "vany" sq_wthog_chain_0 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_WARTHOG_ROCKET 1)
            (osa_ds_load_dropship_place intf_pool_t_running_export "vany" sq_wthog_rocket_0 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_SCORPION 1)
            (osa_ds_load_dropship_place intf_pool_t_running_export "vany" sq_scrp_0 NONE NONE)
        )
        
    )
)
