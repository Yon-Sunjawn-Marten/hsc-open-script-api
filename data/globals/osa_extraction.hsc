; Copyright 2024 Yon-Sunjawn-Marten
;IMPORTS
; include osa_utils
; include osa_ai_director
; include osa_firefight_warzone


(global short s_ext_points_spartan 0)   ; 1 civ saved is 1/5 point. 5/5 gives a marine. Starting marines: 2
(global short s_ext_points_elite 0)     ; 1 civ killed is 1/10 point. 10/10 gives an ai. Starting AI: 4

(global short s_ext_civ_saved 0)
(global short s_ext_civ_saved_delta 0)
(global short s_ext_civ_killed 0)
(global short s_ext_civ_spawned 0)
(global short S_EXT_CIV_MIN 8)
(global short S_EXT_CIV_MAX 16)

; global vehicles 
(global vehicle v_sur_pelican NONE)
(global short evac_zone_ready -1) ; zones = 0,1,2,etc.


(global short EVAC_ELITE_VICTORY   100)
(global short EVAC_SPARTAN_VICTORY 100) ;; or if time runs out.

(global short EVAC_PELICAN_WAIT_TIME 200)
(global short EVAC_PELICAN_LOAD_TIME 450)

(global boolean warning_issued_spartans FALSE)
(global boolean warning_issued_elites FALSE)


(script static void extraction_main
	(print "EXTRACTION MODE ENABLED")
    (set OSA_INTF_BORROW_BIPEDS S_EXT_CIV_MAX) ;; borrow 24 bipeds for this mode. -- reduces down to 12 as round goes on.

    ;(if debug (print "wake reinforcements"))
    (wake extraction_director)
    (wake extraction_rescue_pelican)
    ; (wake survival_pelican_spawn)
    ;(ai_place squads_3) ;; startup squards to help players.
    ;(ai_place squads_33) ; done in the reinforce category.

)

(script static void default_win_condition
	(if (<= s_ext_civ_saved s_ext_civ_killed)
		(begin 
			(print "ELITE DEFAULT VICTORY")
			(set_survival_end_condition 2)
		)
		(begin 
			(print "SPARTAN DEFAULT VICTORY")
			(set_survival_end_condition 1)
		)
	)
)

(script dormant update_extraction_status
	(sleep_until 
        (begin 
			(sleep 60)
			(set OSA_INTF_BORROW_BIPEDS S_EXT_CIV_MAX)
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
					(set_survival_end_condition 2)
				)
			)
			(if (<= EVAC_SPARTAN_VICTORY s_ext_civ_saved)
				(begin 
					(print "SPARTAN VICTORY")
					(set_survival_end_condition 1)
				)
			)
        FALSE)
    )
)

(script static boolean ai_place_obj
	(if (and (<= (+ 4 (ai_living_count gr_evac_civs)) S_EXT_CIV_MAX) (osa_director_can_spawn_ai_x "no-side" 4))
		(begin 
			(ai_place sq_obj_civ)
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
	(ai_place sq_sur_marines_01); consume some civ spots with early marines / spartans (when they die, civs replace them)
	(ai_place sq_sur_marines_02); 2 units
	(ai_place sq_sur_marines_02); 2 units
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
            (print "Evacuate the civs!")


            (begin_random_count 1
                (ai_place sq_sur_pelican_01)
                (ai_place sq_sur_pelican_02)
                (ai_place sq_sur_pelican_03)
            )
            
            
        FALSE)
    )
)

(script command_script cs_ext_get_rescued
    (cs_enable_pathfinding_failsafe TRUE)
    (cs_go_to_vehicle v_sur_pelican)

)

(script static void survival_def_migrate
    (ai_migrate_persistent sq_sur_marines_01 sq_def_0)
    (ai_migrate_persistent sq_sur_marines_02 sq_def_0)
)

(script static ai (place_and_hold (ai squad))
	(ai_place squad)
	(ai_set_task squad obj_marines hold_task)
	squad
)

; adding hud marker on the pelican
(script continuous blip_pelican
	(sleep_forever)
	(print "blipping evac pelican...")
	(f_blip_object_offset v_sur_pelican blip_default 1)
	(sleep 200)
	(f_unblip_object v_sur_pelican)
	
	; this was using the red hostile dropship blip which is wrong
	; (f_survival_callout_dropship v_sur_pelican)
)

;; is a falcon..
(script command_script cs_sur_pelican_01
	(set v_sur_pelican (ai_vehicle_get_from_starting_location sq_sur_pelican_01/driver))
	(sleep 1)
	(print "spawn pelican...")
	(object_cannot_die v_sur_pelican TRUE)
	(cs_enable_pathfinding_failsafe TRUE)
	(cs_ignore_obstacles TRUE)
		
	; ======= LOAD PELICAN HERE ===================
	(begin_random_count 3
		(if (osa_director_can_spawn_ai_x "spartan" 4)
			(f_load_dropship_x (ai_vehicle_get ai_current_actor) 3 "any" (place_and_hold sq_sur_marines_01))
		)
		(if (osa_director_can_spawn_ai_x "spartan" 2)
			(f_load_dropship_x (ai_vehicle_get ai_current_actor) 3 "any" (place_and_hold sq_sur_marines_02))
		)
		
	)
    
    
	
	(print "pelican pathing...")
    (set evac_zone_ready 0)
	; (cs_vehicle_boost TRUE)	
	
	(cs_fly_by ps_sur_pelican_01/p0)
	(cs_fly_by ps_sur_pelican_01/p1)
	(cs_fly_by ps_sur_pelican_01/p2)
	; (cs_vehicle_boost FALSE)
	(cs_fly_by ps_sur_pelican_01/p3_face)
	(wake blip_pelican)
    (sleep 10)
	(cs_vehicle_speed 0.5)
	(cs_fly_to_and_face ps_sur_pelican_01/drop ps_sur_pelican_01/p3_face 1)
    (f_unload_pelican_all (ai_vehicle_get ai_current_actor))
    (sleep EVAC_PELICAN_WAIT_TIME)
    (print "load evacs!")
    (cs_run_command_script sq_obj_civ cs_ext_get_rescued)
	(sleep EVAC_PELICAN_LOAD_TIME)
    (set evac_zone_ready -1)
	
	; ========= PELICAN LEAVES HERE ================
    
	(cs_vehicle_speed 1)
	(print "pelican leaves...")
	(sleep 15)
	(cs_vehicle_boost TRUE)	
	(cs_fly_by ps_sur_pelican_01/p3_face)
	(cs_fly_by ps_sur_pelican_01/p2)
	(cs_fly_by ps_sur_pelican_01/p1)
	(cs_fly_by ps_sur_pelican_01/p0)
	(cs_fly_by ps_sur_pelican_01/erase 10)
	; erase squad 
	; (object_set_scale (ai_vehicle_get ai_current_actor) 0.01 (* 30 10))
	(set s_ext_civ_saved_delta s_ext_civ_saved)
    (set s_ext_civ_saved (+ s_ext_civ_saved (- (list_count (vehicle_riders (ai_vehicle_get ai_current_actor))) 1)))
	(ai_erase ai_current_squad)
)

(script command_script cs_sur_pelican_02
	(set v_sur_pelican (ai_vehicle_get_from_starting_location sq_sur_pelican_02/driver))
	(sleep 1)
	(print "spawn pelican...")
	(object_cannot_die v_sur_pelican TRUE)
	(cs_enable_pathfinding_failsafe TRUE)
	(cs_ignore_obstacles TRUE)
		
	; ======= LOAD PELICAN HERE ===================
	(begin_random_count 3
		(if (osa_director_can_spawn_ai_x "spartan" 4)
			(f_load_dropship_x (ai_vehicle_get ai_current_actor) 3 "any" (place_and_hold sq_sur_marines_01))
		)
		(if (osa_director_can_spawn_ai_x "spartan" 2)
			(f_load_dropship_x (ai_vehicle_get ai_current_actor) 3 "any" (place_and_hold sq_sur_marines_02))
		)
		
	)
    
    
	
	(print "pelican pathing...")
    (set evac_zone_ready 1)
	(cs_vehicle_boost TRUE)	
	
	(cs_fly_by ps_sur_pelican_02/p0)
	(cs_fly_by ps_sur_pelican_02/p1)
	(cs_fly_by ps_sur_pelican_02/p2)
	(cs_vehicle_boost FALSE)
	(cs_fly_by ps_sur_pelican_02/p3_face)
	(wake blip_pelican)
    (sleep 10)
	(cs_vehicle_speed 0.5)
	(cs_fly_to_and_face ps_sur_pelican_02/drop ps_sur_pelican_02/p3_face 1)
    (f_unload_pelican_all (ai_vehicle_get ai_current_actor))
    (sleep EVAC_PELICAN_WAIT_TIME)
    (print "load evacs!")
    (cs_run_command_script sq_obj_civ cs_ext_get_rescued)
	(sleep EVAC_PELICAN_LOAD_TIME)
    (set evac_zone_ready -1)
	
	; ========= PELICAN LEAVES HERE ================
    
	(cs_vehicle_speed 1)
	(print "pelican leaves...")
	(sleep 15)
	(cs_vehicle_boost TRUE)	
	(cs_fly_by ps_sur_pelican_02/p3_face)
	(cs_fly_by ps_sur_pelican_02/p2)
	(cs_fly_by ps_sur_pelican_02/p1)
	(cs_fly_by ps_sur_pelican_02/p0)
	(cs_fly_by ps_sur_pelican_02/erase 10)
	; erase squad 
	; (object_set_scale (ai_vehicle_get ai_current_actor) 0.01 (* 30 10))
    
	(set s_ext_civ_saved_delta s_ext_civ_saved)
	(set s_ext_civ_saved (+ s_ext_civ_saved (- (list_count (vehicle_riders (ai_vehicle_get ai_current_actor))) 1)))
	(ai_erase ai_current_squad)
)

(script command_script cs_sur_pelican_03
	(set v_sur_pelican (ai_vehicle_get_from_starting_location sq_sur_pelican_03/driver))
	(sleep 1)
	(print "spawn pelican...")
	(object_cannot_die v_sur_pelican TRUE)
	(cs_enable_pathfinding_failsafe TRUE)
	(cs_ignore_obstacles TRUE)
		
	; ======= LOAD PELICAN HERE ===================

    (begin_random_count 3
		(if (osa_director_can_spawn_ai_x "spartan" 4)
			(f_load_dropship_x (ai_vehicle_get ai_current_actor) 3 "any" (place_and_hold sq_sur_marines_01))
		)
		(if (osa_director_can_spawn_ai_x "spartan" 2)
			(f_load_dropship_x (ai_vehicle_get ai_current_actor) 3 "any" (place_and_hold sq_sur_marines_02))
		)
		
	)
    
    
	
	(print "pelican pathing...")
    (set evac_zone_ready 2)
	(cs_vehicle_boost TRUE)	
	
	(cs_fly_by ps_sur_pelican_03/p0)
	(cs_fly_by ps_sur_pelican_03/p1)
	(cs_fly_by ps_sur_pelican_03/p2)
	(cs_vehicle_boost FALSE)
	(cs_fly_by ps_sur_pelican_03/p3_face)
	(wake blip_pelican)
    (sleep 10)
	(cs_vehicle_speed 0.5)
	(cs_fly_to_and_face ps_sur_pelican_03/drop ps_sur_pelican_03/p3_face 1)
    (f_unload_pelican_all (ai_vehicle_get ai_current_actor))
    (sleep EVAC_PELICAN_WAIT_TIME)
    (print "load evacs!")
    (cs_run_command_script sq_obj_civ cs_ext_get_rescued)
	(sleep EVAC_PELICAN_LOAD_TIME)
    (set evac_zone_ready -1)
	
	; ========= PELICAN LEAVES HERE ================
    
	(cs_vehicle_speed 1)
	(print "pelican leaves...")
	(sleep 15)
	(cs_vehicle_boost TRUE)	
	(cs_fly_by ps_sur_pelican_03/p3_face)
	(cs_fly_by ps_sur_pelican_03/p2)
	(cs_fly_by ps_sur_pelican_03/p1)
	(cs_fly_by ps_sur_pelican_03/p0)
	(cs_fly_by ps_sur_pelican_03/erase 10)
	; erase squad 
	; (object_set_scale (ai_vehicle_get ai_current_actor) 0.01 (* 30 10))
    
	(set s_ext_civ_saved_delta s_ext_civ_saved)
	(set s_ext_civ_saved (+ s_ext_civ_saved (- (list_count (vehicle_riders (ai_vehicle_get ai_current_actor))) 1)))
	(ai_erase ai_current_squad)
)
