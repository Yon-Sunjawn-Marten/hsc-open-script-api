; Copyright 2024 Yon-Sunjawn-Marten

;; Example mission script making use of the libraries to set up firefight.

; This script triggers squad/individual drop pods to spawn at random locations.
; It triggers a marine reinforcement with random vehicle.
; Both sides navigate around the island.
; The AI director was told that the number of AI supported on the map is 60.. 60 is too much for just the island.

(script startup boneyard_ff	
		; switch to the proper zone set 
		; (switch_zone_set set_firefight)
		
		; sets kill trigger
;		(tv_kbtg_kill)

	; setup director activities
	(intf_director_add_objective intf_ff_objective/obj_task_wrapper)
	(intf_director_add_objective obj_marines/obj_task_wrapper)
	(intf_director_add_objective obj_vehicles/obj_task_wrapper)
	(intf_director_add_objective obj_air_vehicles/obj_task_wrapper)
	
    (intf_director_add_squad_group gr_survival_haz_e) ; set 0
    (intf_director_add_squad_group gr_survival_def_m) ; set 1
    (intf_director_add_squad_group gr_vehicle_elites) ; set 2
    (intf_director_add_squad_group gr_vehicle_marines) ; set 3
	
	(intf_director_AUTO_migrate_gr_sq gr_hazard_spawn 0) ; go 0
	(intf_director_AUTO_migrate_gr_sq gr_defense_spawn 1) ; go 1
	(intf_director_AUTO_migrate_gr_sq gr_vehicle_spawn_e 2) ; go 2
	(intf_director_AUTO_migrate_gr_sq gr_vehicle_spawn_m 3) ; go 3
	

	; Init pooling scripts
	(intf_pool_add_drop_point dm_resupply_02 OSA_POOL_DROP_WEAPON)
	(intf_pool_add_drop_point dm_resupply_03 OSA_POOL_DROP_WEAPON)
	(intf_pool_add_drop_point dm_resupply_04 OSA_POOL_DROP_WEAPON)
	(intf_pool_add_drop_point dm_resupply_08 OSA_POOL_DROP_WEAPON)
	(intf_pool_set_drop_cleanup dm_resupply_02 5400) ; a 3 minute timeout to delete
    (intf_pool_set_drop_cleanup dm_resupply_03 5400)
    (intf_pool_set_drop_cleanup dm_resupply_04 5400)
    (intf_pool_set_drop_cleanup dm_resupply_08 5400)

    (intf_pool_add_drop_point dm_drop_01 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_drop_02 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_drop_03 OSA_POOL_DROP_SQUAD)
    (intf_pool_add_drop_point dm_drop_04 OSA_POOL_DROP_SQUAD)
    (intf_pool_set_drop_cleanup dm_drop_01 10800)
    (intf_pool_set_drop_cleanup dm_drop_02 10800)
    (intf_pool_set_drop_cleanup dm_drop_03 10800)
    (intf_pool_set_drop_cleanup dm_drop_04 10800)

    (intf_pool_add_drop_point dm_drop_s13 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_drop_s19 OSA_POOL_DROP_TROOP)
    ; (intf_pool_add_drop_point dm_drop_s22 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_drop_s23 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_drop_s29 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_drop_s34 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_drop_s38 OSA_POOL_DROP_TROOP)
    (intf_pool_add_drop_point dm_drop_s40 OSA_POOL_DROP_TROOP)
    (intf_pool_set_drop_cleanup dm_drop_s13 10800)
    (intf_pool_set_drop_cleanup dm_drop_s19 10800)
    (intf_pool_set_drop_cleanup dm_drop_s23 10800)
    (intf_pool_set_drop_cleanup dm_drop_s29 10800)
    (intf_pool_set_drop_cleanup dm_drop_s34 10800)
    (intf_pool_set_drop_cleanup dm_drop_s38 10800)
    (intf_pool_set_drop_cleanup dm_drop_s40 10800)
	
	; init HUD scripts
    (intf_utils_add_health_kit health_pack0)
    (intf_utils_add_health_kit health_pack1)
    (intf_utils_add_health_kit health_pack2)
    (intf_utils_add_health_kit health_pack3)
    (intf_utils_add_health_kit health_pack4)
    (intf_utils_add_health_kit health_pack5)
	(set intf_utils_hp_see_dist 20)

    (intf_utils_add_proximity_callout ammo_crate0 (osa_utils_get_marker_type "ammo"))
    (intf_utils_add_proximity_callout ammo_crate1 (osa_utils_get_marker_type "ammo"))
    (intf_utils_add_proximity_callout ammo_crate2 (osa_utils_get_marker_type "ammo"))
    (intf_utils_add_proximity_callout warthog_01 (osa_utils_get_marker_type "ordnance"))
    (intf_utils_add_proximity_callout shot_rock01 (osa_utils_get_marker_type "ammo"))
    (intf_utils_add_proximity_callout br_10 (osa_utils_get_marker_type "ammo"))
    (intf_utils_add_proximity_callout example_01 (osa_utils_get_marker_type "ammo"))
    (intf_utils_add_proximity_callout concussion_rifles1 (osa_utils_get_marker_type "ammo"))
	(Set intf_utils_proximity_see_dist 10)

	;set up transports
    (intf_pool_add_transport sq_sur_pelican_01 OSA_POOL_SIDE_SPARTAN "vany" "any")
    (intf_pool_set_transport_tracks sq_sur_pelican_01 0 13 23)
    (intf_pool_set_transport_drop_a sq_sur_pelican_01 5 18 26)
    (intf_pool_set_transport_drop_b sq_sur_pelican_01 9 20 29)
    (intf_pool_set_transport_movement sq_sur_pelican_01 TRUE 0 0 0) ; no hold points for this map.
    (intf_pool_set_transport_drop_a_face_point sq_sur_pelican_01 4 17 0)
    (intf_pool_set_transport_drop_b_face_point sq_sur_pelican_01 8 17 28)
    (intf_pool_set_transport_marker sq_sur_pelican_01 (osa_utils_get_marker_type "poi blue"))
    (intf_pool_set_transport_slow_at sq_sur_pelican_01  2 16 25)
    (intf_pool_set_transport_fast_at sq_sur_pelican_01 11 21 30)
    
    (intf_pool_add_transport sq_sur_phantom_01 OSA_POOL_SIDE_ELITE "vany" "any")
    (intf_pool_set_transport_tracks sq_sur_phantom_01 0 12 22)
    (intf_pool_set_transport_drop_a sq_sur_phantom_01 5 17 25)
    (intf_pool_set_transport_drop_b sq_sur_phantom_01 8 19 28)
    (intf_pool_set_transport_movement sq_sur_phantom_01 TRUE 8 19 28)
    (intf_pool_set_transport_drop_a_face_point sq_sur_phantom_01 6 0 0)
    (intf_pool_set_transport_drop_b_face_point sq_sur_phantom_01 0 0 0)
    (intf_pool_set_transport_marker sq_sur_phantom_01 (osa_utils_get_marker_type "poi red"))
    (intf_pool_set_transport_slow_at sq_sur_phantom_01 1 13 25)
    (intf_pool_set_transport_fast_at sq_sur_phantom_01 9 19 30)
    
    (intf_pool_add_transport sq_sur_phantom_02 OSA_POOL_SIDE_ELITE "any" "vany") ; for kicks, lets swap the drop.
    (intf_pool_set_transport_tracks sq_sur_phantom_02 0 9 16)
    (intf_pool_set_transport_drop_a sq_sur_phantom_02 3 12 19)
    (intf_pool_set_transport_drop_b sq_sur_phantom_02 5 13 21)
    (intf_pool_set_transport_movement sq_sur_phantom_02 TRUE 5 13 21)
    (intf_pool_set_transport_drop_a_face_point sq_sur_phantom_02 0 0 0)
    (intf_pool_set_transport_drop_b_face_point sq_sur_phantom_02 0 0 0)
    (intf_pool_set_transport_marker sq_sur_phantom_02 (osa_utils_get_marker_type "poi red"))
    (intf_pool_set_transport_slow_at sq_sur_phantom_02 1 10 18)
    (intf_pool_set_transport_fast_at sq_sur_phantom_02 6 14 22)



    ; Set up Hazard Spawns
    ; haz 0
    ; (intf_hazpl_set_event_period 0 900 1800) ;; constant supply of marines.
    (intf_hazpl_set_event_period 0 100 300) ;; constant supply of marines.
    (intf_hazpl_add_hazard sq_sur_pelican_01 OSA_DIR_TYPE_SINGLE OSA_DIR_SIDE_SPARTAN 0)

    (intf_hazpl_set_event_period 1 9000 18000)
    (intf_hazpl_set_event_period 2 9000 16000)
    (intf_hazpl_set_event_period 3 3000 6000)
    (intf_hazpl_set_event_period 7 4000 16000)
    (intf_hazpl_set_event_period 8 8000 16000)
    (intf_hazpl_add_hazard sq_sur_drop_01 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 1)
    (intf_hazpl_add_hazard sq_sur_drop_02 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 2)
    (intf_hazpl_add_hazard sq_sur_drop_03 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 1)
    (intf_hazpl_add_hazard sq_sur_drop_04 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 1)
    (intf_hazpl_add_hazard sq_sur_drop_05 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 1)
    (intf_hazpl_add_hazard sq_sur_banshee_01 OSA_DIR_TYPE_BANSHEE OSA_DIR_SIDE_ELITE 3)
    (intf_hazpl_add_hazard sq_sur_idv_drop_01 OSA_DIR_TYPE_SQUAD OSA_DIR_SIDE_ELITE 7)
    (intf_hazpl_repeat_hazard_spawn sq_sur_idv_drop_01 3 5)
    
    (intf_hazpl_add_hazard sq_sur_falcon_01 OSA_DIR_TYPE_FALCON OSA_DIR_SIDE_SPARTAN 8)
    ; (intf_hazpl_add_hazard sq_hostile_phantom OSA_DIR_TYPE_PHANTOM OSA_DIR_SIDE_ELITE 8)
    ; (intf_hazpl_use_permanent_callout sq_hostile_phantom (osa_utils_get_marker_type "neutralize"))
    
    (set osa_main_temp_var (intf_pool_get_thread_from_sq sq_sur_pelican_01))

	(set intf_gr_dir_all        gr_survival_all)
    (set intf_gr_dir_spartans   gr_survival_spartans)
    (set intf_gr_dir_elites     gr_survival_elites)
    ; (set intf_part_max_bipeds 60) ; max ai in field, boneyard supports 42
    (intf_load_ai_director false)
    
	; assign phantom squads to global ai variables 
	(set intf_sq_phantom_01 sq_sur_phantom_01) ; only use phantoms 2/3
	(set intf_sq_phantom_02 sq_sur_phantom_02) ; bonus will randomly be one of these.
	
	;setting wave spawn group 
	(set intf_gr_ff_waves gr_survival_waves)
	(set intf_sq_ff_remain sq_sur_remaining)
	(set intf_sq_ff_bonus sq_ff_bonus)
    (intf_ff_force_use_transports) ; for debug only.
    (intf_load_ff false)

	(ai_place squads_3) ; place free squads
	(ai_place squads_33) ; place free squads
)

(script static void (intf_plugin_ff_hazard_spawn_0 (vehicle phantom))
    (print "phantom use my hazards")
    (begin_random_count 1
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_ELITE OSA_DIR_TYPE_WRAITH 1)
            (osa_ds_load_dropship_place phantom "vany" sq_sur_wraith_01 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_ELITE OSA_DIR_TYPE_GHOST 2)
            (osa_ds_load_dropship_place phantom "vany" sq_sur_ghost_01 sq_sur_ghost_02 NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_ELITE OSA_DIR_TYPE_REVENANT 2)
            (osa_ds_load_dropship_place phantom "vany" sq_sur_revanant_01 sq_sur_revanant_02 NONE)
        )
    )
    
)

(script static void intf_resupply_weapon_drop_0
    (wake resupply_thread)
)

(script dormant resupply_thread
	(print "bringing in longsword...")
	(sleep 1)
	(device_set_position_track dm_longsword_01 "ff10" 0)
	(device_animate_position dm_longsword_01 1 10.0 3 3 FALSE)
	(sleep_until (>= (device_get_position dm_longsword_01) 0.4) 1)
    (begin_random_count intf_resupply_max_drop_pods
        (intf_pool_drop_a_pod sc_resupply_01 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_02 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_03 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_04 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_05 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_06 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_07 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_08 OSA_POOL_DROP_WEAPON)
        (intf_pool_drop_a_pod sc_resupply_09 OSA_POOL_DROP_WEAPON)
    )
	(sleep_until (>= (device_get_position dm_longsword_01) 0.8) 1)
	(osa_utils_reset_device dm_longsword_01)
)

; HAZPOOL EVENT 4
(script static boolean intf_hazpl_event_0
    (sleep_until (= (ai_living_count sq_sur_pelican_01) 0))
    (sleep_until (> (- osa_part_max_ai_spartan (ai_living_count intf_gr_dir_spartans)) 1))
    (sleep (random_range intf_hazpl_event_p_min_0 intf_hazpl_event_p_max_0))
	(print "Run event 4")
    TRUE
)
(global short osa_main_temp_var 0)
(global vehicle osa_main_temp_veh NONE)
(script static void intf_plugin_hazpl_thread_0
    (print "pelican load reinforcements!")
    (sleep 30)
    (cond 
        ((= 0 osa_main_temp_var)
            (set osa_main_temp_veh intf_pool_t_vehicle_0)
        )
        ((= 1 osa_main_temp_var)
            (set osa_main_temp_veh intf_pool_t_vehicle_1)
        )
        ((= 2 osa_main_temp_var)
            (set osa_main_temp_veh intf_pool_t_vehicle_2)
        )
        ((= 3 osa_main_temp_var)
            (set osa_main_temp_veh intf_pool_t_vehicle_3)
        )
    )
    (inspect (!= NONE osa_main_temp_veh))
    (begin_random_count 2
        (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
            (begin 
                (osa_ds_load_dropship_place osa_main_temp_veh "any" squads_3 NONE NONE)
                (sleep 1)
            )
        )
        (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
            (begin 
                (osa_ds_load_dropship_place osa_main_temp_veh "any" squads_33 NONE NONE)
                (sleep 1)
            )
        )
        (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
            (begin 
                (osa_ds_load_dropship_place osa_main_temp_veh "any" sq_sur_def_b NONE NONE)
                (sleep 1)
            )
        )
        (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
            (begin 
                (osa_ds_load_dropship_place osa_main_temp_veh "any" sq_sur_def_b NONE NONE)
                (sleep 1)
            )
        )
        (if (intf_director_can_spawn_ai_x OSA_DIR_SIDE_SPARTAN 4)
            (begin 
                (osa_ds_load_dropship_place osa_main_temp_veh "any" squads_spartans NONE NONE)
                (sleep 1)
            )
        )
    )
    (begin_random_count 1
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_WARTHOG_ROCKET 1)
            (osa_ds_load_dropship_place osa_main_temp_veh "vany" sq_sur_warthog_01 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_WARTHOG_TROOP 1)
            (osa_ds_load_dropship_place osa_main_temp_veh "vany" sq_sur_warthog_02 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_WARTHOG_GAUSS 1)
            (osa_ds_load_dropship_place osa_main_temp_veh "vany" sq_sur_warthog_03 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_WARTHOG_CHAINGUN 1)
            (osa_ds_load_dropship_place osa_main_temp_veh "vany" sq_sur_warthog_04 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_MONGOOSE 1)
            (osa_ds_load_dropship_place osa_main_temp_veh "vany" sq_sur_mongoose_01 NONE NONE)
        )
        (if (intf_director_try_spawn_vehicle_x OSA_DIR_SIDE_SPARTAN OSA_DIR_TYPE_SCORPION 1)
            (osa_ds_load_dropship_place osa_main_temp_veh "vany" sq_sur_scorpion_01 NONE NONE)
        )
    )
)


; (script dormant survival_phantom_supply_spawn
; 	(print "phantoms ready to support elites!")
; 	(sleep_until 
; 		(begin 
; 			(sleep_until (<= ( unit_get_health v_sur_phantom_01) 0))
; 			(print "phantom supply sent.")
; 			(if (<= ( unit_get_health banshee_01) 0)
; 				(ai_place sq_sur_phantom_supply_01)
; 			)
; 		FALSE)
; 	3600)
; )








