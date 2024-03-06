; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_utils

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Manages drop pods for squads/weapons/elites
;
; Editor Notes:
;
;

;; ========================== REQUIRED in Sapien ==================================
; These dm contain the sounds and animation for the drop.

; objects\levels\shared\device_machines\invis_cov_resupply_capsule
; objects\levels\shared\device_machines\invis_cov_squad_drop_pod
; objects\levels\shared\device_machines\invis_cov_squad_drop_water
; objects\levels\shared\device_machines\invis_cov_drop_pod_elite
; objects\levels\shared\device_machines\invis_resupply_capsule
; objects\levels\shared\device_machines\invis_resupply_water

; Supply pods are found under scenery
; Drop pods are vehicles.

; Placement Scripts:
(script command_script cs_pool_drop_on_spawn_sq
	(osa_pool_try_drop_a_pod (ai_vehicle_get ai_current_actor) OSA_POOL_DROP_SQUAD)
) ; for squad pods.

(script command_script cs_pool_drop_on_spawn_solo
	(osa_pool_try_drop_a_pod (ai_vehicle_get ai_current_actor) OSA_POOL_DROP_TROOP)
) ; for elite pods.

;; -------------------------- REQUIRED in Sapien ----------------------------------

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---


;; ---  OUTPUT VARS        ---

; ======== Interfacing Scripts ========

(script static void (intf_pool_add_drop_point (device dm) (short type))
	(print_if dbg_pool "registering drop point:")
	; (inspect type)
    (cond 
        ((= intf_pool_dm_0 NONE)
            (begin (set intf_pool_dm_0 dm) (set intf_pool_dm_type_0 type))
        )
        ((= intf_pool_dm_1 NONE)
            (begin (set intf_pool_dm_1 dm) (set intf_pool_dm_type_1 type))
        )
        ((= intf_pool_dm_2 NONE)
            (begin (set intf_pool_dm_2 dm) (set intf_pool_dm_type_2 type))
        )
        ((= intf_pool_dm_3 NONE)
            (begin (set intf_pool_dm_3 dm) (set intf_pool_dm_type_3 type))
        )
        ((= intf_pool_dm_4 NONE)
            (begin (set intf_pool_dm_4 dm) (set intf_pool_dm_type_4 type))
        )
        ((= intf_pool_dm_5 NONE)
            (begin (set intf_pool_dm_5 dm) (set intf_pool_dm_type_5 type))
        )
        ((= intf_pool_dm_6 NONE)
            (begin (set intf_pool_dm_6 dm) (set intf_pool_dm_type_6 type))
        )
        ((= intf_pool_dm_7 NONE)
            (begin (set intf_pool_dm_7 dm) (set intf_pool_dm_type_7 type))
        )
        ((= intf_pool_dm_8 NONE)
            (begin (set intf_pool_dm_8 dm) (set intf_pool_dm_type_8 type))
        )
        ((= intf_pool_dm_9 NONE)
            (begin (set intf_pool_dm_9 dm) (set intf_pool_dm_type_9 type))
        )
        ((= intf_pool_dm_10 NONE)
            (begin (set intf_pool_dm_10 dm) (set intf_pool_dm_type_10 type))
        )
        ((= intf_pool_dm_11 NONE)
            (begin (set intf_pool_dm_11 dm) (set intf_pool_dm_type_11 type))
        )
        ((= intf_pool_dm_12 NONE)
            (begin (set intf_pool_dm_12 dm) (set intf_pool_dm_type_12 type))
        )
        ((= intf_pool_dm_13 NONE)
            (begin (set intf_pool_dm_13 dm) (set intf_pool_dm_type_13 type))
        )
        ((= intf_pool_dm_14 NONE)
            (begin (set intf_pool_dm_14 dm) (set intf_pool_dm_type_14 type))
        )
        (TRUE
            (print "ERROR: Out of drop pod memory")
        )
    )
) ;; you can use this for any pod: weapon, squad, individual. Just give the type along with it.

(script static void (intf_pool_set_drop_cleanup (device dm) (short timer))
	(print_if dbg_pool "set drop cleanup")
    (cond 
        ((= intf_pool_dm_0 dm)
            (set intf_pool_drop_clean_timer_0 timer)
        )
        ((= intf_pool_dm_1 dm)
            (set intf_pool_drop_clean_timer_1 timer)
        )
        ((= intf_pool_dm_2 dm)
            (set intf_pool_drop_clean_timer_2 timer)
        )
        ((= intf_pool_dm_3 dm)
            (set intf_pool_drop_clean_timer_3 timer)
        )
        ((= intf_pool_dm_4 dm)
            (set intf_pool_drop_clean_timer_4 timer)
        )
        ((= intf_pool_dm_5 dm)
            (set intf_pool_drop_clean_timer_5 timer)
        )
        ((= intf_pool_dm_6 dm)
            (set intf_pool_drop_clean_timer_6 timer)
        )
        ((= intf_pool_dm_7 dm)
            (set intf_pool_drop_clean_timer_7 timer)
        )
        ((= intf_pool_dm_8 dm)
            (set intf_pool_drop_clean_timer_8 timer)
        )
        ((= intf_pool_dm_9 dm)
            (set intf_pool_drop_clean_timer_9 timer)
        )
        ((= intf_pool_dm_10 dm)
            (set intf_pool_drop_clean_timer_10 timer)
        )
        ((= intf_pool_dm_11 dm)
            (set intf_pool_drop_clean_timer_11 timer)
        )
        ((= intf_pool_dm_12 dm)
            (set intf_pool_drop_clean_timer_12 timer)
        )
        ((= intf_pool_dm_13 dm)
            (set intf_pool_drop_clean_timer_13 timer)
        )
        ((= intf_pool_dm_14 dm)
            (set intf_pool_drop_clean_timer_14 timer)
        )
        (TRUE
            (print "ERROR: pod not registered!")
        )
    )
)

(script static void (intf_pool_drop_a_pod (object_name pod_name) (short type))
	(print_if dbg_pool "dropping a pod!")
	(if (= type OSA_POOL_DROP_WEAPON)
		(object_create_variant pod_name (intf_plugin_pool_pod_options))
		(object_create pod_name)
	)
	(print_if dbg_pool "pod placed")
	(osa_pool_try_drop_a_pod pod_name type)
)


(script stub string_id intf_plugin_pool_pod_options
	(begin_random_count 1
		"laser"
		"rocket"
		"sniper"
		"shotgun"
		"pistols"
		"ar"
		"dmr"
		"target_laser"
	)
) ; For selecting the weapon to drop in drop pods. Can override or use default

(script static void (intf_pool_place_squad_in_pod_and_drop (ai squad) (object_name pod_name) (short type))
	(print_if dbg_pool "dropping a pod!")
	(object_create pod_name)
	(ai_place squad)
	(sleep 1)
	(vehicle_load_magic pod_name "" squad)
	(osa_pool_try_drop_a_pod pod_name type)
	(unit_open (unit pod_name))
	(sleep 60)
	(vehicle_unload pod_name "")
)

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================


;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)

;; ========================== PUBLIC VARIABLES Read-Only ==================================

(global short OSA_POOL_DROP_WEAPON 0)
(global short OSA_POOL_DROP_TROOP 1)
(global short OSA_POOL_DROP_SQUAD 2)

;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.


(global boolean dbg_pool false)
(global boolean osa_pool_insta_clean false)

;; --- INPUT VARS --- (plugins)
(global object intf_pool_pod_0 NONE) ; to mark that this is in use and delete the pod later.
(global object intf_pool_pod_1 NONE)
(global object intf_pool_pod_2 NONE)
(global object intf_pool_pod_3 NONE)
(global object intf_pool_pod_4 NONE)
(global object intf_pool_pod_5 NONE)
(global object intf_pool_pod_6 NONE)
(global object intf_pool_pod_7 NONE)
(global object intf_pool_pod_8 NONE)
(global object intf_pool_pod_9 NONE)
(global object intf_pool_pod_10 NONE)
(global object intf_pool_pod_11 NONE)
(global object intf_pool_pod_12 NONE)
(global object intf_pool_pod_13 NONE)
(global object intf_pool_pod_14 NONE)
(global device intf_pool_dm_0 NONE) ; drop location and the actual drop animation
(global device intf_pool_dm_1 NONE)
(global device intf_pool_dm_2 NONE)
(global device intf_pool_dm_3 NONE)
(global device intf_pool_dm_4 NONE)
(global device intf_pool_dm_5 NONE)
(global device intf_pool_dm_6 NONE)
(global device intf_pool_dm_7 NONE)
(global device intf_pool_dm_8 NONE)
(global device intf_pool_dm_9 NONE)
(global device intf_pool_dm_10 NONE)
(global device intf_pool_dm_11 NONE)
(global device intf_pool_dm_12 NONE)
(global device intf_pool_dm_13 NONE)
(global device intf_pool_dm_14 NONE)
(global short intf_pool_dm_type_0 -1)
(global short intf_pool_dm_type_1 -1)
(global short intf_pool_dm_type_2 -1)
(global short intf_pool_dm_type_3 -1)
(global short intf_pool_dm_type_4 -1)
(global short intf_pool_dm_type_5 -1)
(global short intf_pool_dm_type_6 -1)
(global short intf_pool_dm_type_7 -1)
(global short intf_pool_dm_type_8 -1)
(global short intf_pool_dm_type_9 -1)
(global short intf_pool_dm_type_10 -1)
(global short intf_pool_dm_type_11 -1)
(global short intf_pool_dm_type_12 -1)
(global short intf_pool_dm_type_13 -1)
(global short intf_pool_dm_type_14 -1)
(global short intf_pool_drop_clean_timer_0 1800)
(global short intf_pool_drop_clean_timer_1 1800)
(global short intf_pool_drop_clean_timer_2 1800)
(global short intf_pool_drop_clean_timer_3 1800)
(global short intf_pool_drop_clean_timer_4 1800)
(global short intf_pool_drop_clean_timer_5 1800)
(global short intf_pool_drop_clean_timer_6 1800)
(global short intf_pool_drop_clean_timer_7 1800)
(global short intf_pool_drop_clean_timer_8 1800)
(global short intf_pool_drop_clean_timer_9 1800)
(global short intf_pool_drop_clean_timer_10 1800)
(global short intf_pool_drop_clean_timer_11 1800)
(global short intf_pool_drop_clean_timer_12 1800)
(global short intf_pool_drop_clean_timer_13 1800)
(global short intf_pool_drop_clean_timer_14 1800)

(script static void (osa_pool_drop_a_pod (object pod) (device pod_dm) (short type))
	(objects_attach pod_dm "" pod "")
	(sleep 1)
	(device_set_position pod_dm 1)
	(sleep_until (>= (device_get_position pod_dm) 0.98) 1)
	(effect_new_on_object_marker fx\fx_library\pod_impacts\default\pod_impact_default_small.effect pod "fx_impact")
	(sleep_until (>= (device_get_position pod_dm) 1) 1)
	(sleep 1)
	(objects_detach pod_dm pod)
	(osa_utils_reset_device pod_dm)
	(object_damage_damage_section pod "panel" 100)
	(object_damage_damage_section pod "body" 100)
	(if (= type OSA_POOL_DROP_WEAPON)
		(intf_utils_callout_object pod (osa_utils_get_marker_type "ordnance") 900)
	)
	(if (= type OSA_POOL_DROP_TROOP)
		(intf_utils_callout_object pod (osa_utils_get_marker_type "poi red") 900)
	)
	(if (= type OSA_POOL_DROP_SQUAD)
		(intf_utils_callout_object pod (osa_utils_get_marker_type "poi red") 900)
	)
	(print_if dbg_pool "pod placement - exit")
)

(script static void (osa_pool_try_drop_a_pod (object pod_name) (short type))
	(print_if dbg_pool "attempt pod spawn at:")
	; (inspect type)
	(cond 
		((and (!= intf_pool_dm_0 NONE) (= intf_pool_pod_0 NONE) (= type intf_pool_dm_type_0))
			(begin 
				(print_if dbg_pool "drop0")
				(set intf_pool_pod_0 pod_name) ; failure to place still occupies this, thats ok.
			)
		)
		((and (!= intf_pool_dm_1 NONE) (= intf_pool_pod_1 NONE) (= type intf_pool_dm_type_1))
			(begin 
				(print_if dbg_pool "drop1")
				(set intf_pool_pod_1 pod_name)
			)
		)
		((and (!= intf_pool_dm_2 NONE) (= intf_pool_pod_2 NONE) (= type intf_pool_dm_type_2))
			(begin 
				(print_if dbg_pool "drop2")
				(set intf_pool_pod_2 pod_name)
			)
		)
		((and (!= intf_pool_dm_3 NONE) (= intf_pool_pod_3 NONE) (= type intf_pool_dm_type_3))
			(begin 
				(print_if dbg_pool "drop3")
				(set intf_pool_pod_3 pod_name)
			)
		)
		((and (!= intf_pool_dm_4 NONE) (= intf_pool_pod_4 NONE) (= type intf_pool_dm_type_4))
			(begin 
				(print_if dbg_pool "drop4")
				(set intf_pool_pod_4 pod_name)
			)
		)
		((and (!= intf_pool_dm_5 NONE) (= intf_pool_pod_5 NONE) (= type intf_pool_dm_type_5))
			(begin 
				(print_if dbg_pool "drop5")
				(set intf_pool_pod_5 pod_name)
			)
		)
		((and (!= intf_pool_dm_6 NONE) (= intf_pool_pod_6 NONE) (= type intf_pool_dm_type_6))
			(begin 
				(print_if dbg_pool "drop6")
				(set intf_pool_pod_6 pod_name)
			)
		)
		((and (!= intf_pool_dm_7 NONE) (= intf_pool_pod_7 NONE) (= type intf_pool_dm_type_7))
			(begin 
				(print_if dbg_pool "drop7")
				(set intf_pool_pod_7 pod_name)
			)
		)
		((and (!= intf_pool_dm_8 NONE) (= intf_pool_pod_8 NONE) (= type intf_pool_dm_type_8))
			(begin 
				(print_if dbg_pool "drop8")
				(set intf_pool_pod_8 pod_name)
			)
		)
		((and (!= intf_pool_dm_9 NONE) (= intf_pool_pod_9 NONE) (= type intf_pool_dm_type_9))
			(begin 
				(print_if dbg_pool "drop9")
				(set intf_pool_pod_9 pod_name)
			)
		)
		((and (!= intf_pool_dm_10 NONE) (= intf_pool_pod_10 NONE) (= type intf_pool_dm_type_10))
			(begin 
				(print_if dbg_pool "drop10")
				(set intf_pool_pod_10 pod_name)
			)
		)
		((and (!= intf_pool_dm_11 NONE) (= intf_pool_pod_11 NONE) (= type intf_pool_dm_type_11))
			(begin 
				(print_if dbg_pool "drop11")
				(set intf_pool_pod_11 pod_name)
			)
		)
		((and (!= intf_pool_dm_12 NONE) (= intf_pool_pod_12 NONE) (= type intf_pool_dm_type_12))
			(begin 
				(print_if dbg_pool "drop12")
				(set intf_pool_pod_12 pod_name)
			)
		)
		((and (!= intf_pool_dm_13 NONE) (= intf_pool_pod_13 NONE) (= type intf_pool_dm_type_13))
			(begin 
				(print_if dbg_pool "drop13")
				(set intf_pool_pod_13 pod_name)
			)
		)
		((and (!= intf_pool_dm_14 NONE) (= intf_pool_pod_14 NONE) (= type intf_pool_dm_type_14))
			(begin 
				(print_if dbg_pool "drop14")
				(set intf_pool_pod_14 pod_name)
			)
		)
		((not osa_pool_insta_clean)
			(begin 
				(print "Cant drop at a location! Doing emergency cleanup for ALL.")
				(set osa_pool_insta_clean true)
				(sleep 2)
				(osa_pool_try_drop_a_pod pod_name type)
			)
		)
		(TRUE
			(begin 
				(print "failed to drop at a location!")
			)
		)
	)
)

(script static void (osa_pool_drop_handle_exit (object pod) (device pod_dm) (short type) (short timeout))
	(osa_pool_drop_a_pod pod pod_dm type)
	(if (!= type OSA_POOL_DROP_WEAPON)	
		(begin 
			(print_if dbg_pool "squad pod open!")
			(unit_open (unit pod))
			(sleep 60)
			(vehicle_unload pod "")
		)
		; (inspect type)
	)
	(sleep_until osa_pool_insta_clean 1 timeout)
	(object_destroy pod)
	(set osa_pool_insta_clean false) ; I think then, only one pod gets destroyed? :\
)

(script continuous osa_pool_drop_thread_0
	(sleep_until (!= intf_pool_pod_0 NONE) 5)
	(sleep 1)
	(osa_pool_drop_handle_exit intf_pool_pod_0 intf_pool_dm_0 intf_pool_dm_type_0 intf_pool_drop_clean_timer_0)
	(set intf_pool_pod_0 NONE)
)
(script continuous osa_pool_drop_thread_1
	(sleep_until (!= intf_pool_pod_1 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_1 intf_pool_dm_1 intf_pool_dm_type_1 intf_pool_drop_clean_timer_1)
	(set intf_pool_pod_1 NONE)
)
(script continuous osa_pool_drop_thread_2
	(sleep_until (!= intf_pool_pod_2 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_2 intf_pool_dm_2 intf_pool_dm_type_2 intf_pool_drop_clean_timer_2)
	(set intf_pool_pod_2 NONE)
)
(script continuous osa_pool_drop_thread_3
	(sleep_until (!= intf_pool_pod_3 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_3 intf_pool_dm_3 intf_pool_dm_type_3 intf_pool_drop_clean_timer_3)
	(set intf_pool_pod_3 NONE)
)
(script continuous osa_pool_drop_thread_4
	(sleep_until (!= intf_pool_pod_4 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_4 intf_pool_dm_4 intf_pool_dm_type_4 intf_pool_drop_clean_timer_4)
	(set intf_pool_pod_4 NONE)
)
(script continuous osa_pool_drop_thread_5
	(sleep_until (!= intf_pool_pod_5 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_5 intf_pool_dm_5 intf_pool_dm_type_5 intf_pool_drop_clean_timer_5)
	(set intf_pool_pod_5 NONE)
)
(script continuous osa_pool_drop_thread_6
	(sleep_until (!= intf_pool_pod_6 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_6 intf_pool_dm_6 intf_pool_dm_type_6 intf_pool_drop_clean_timer_6)
	(set intf_pool_pod_6 NONE)
)
(script continuous osa_pool_drop_thread_7
	(sleep_until (!= intf_pool_pod_7 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_7 intf_pool_dm_7 intf_pool_dm_type_7 intf_pool_drop_clean_timer_7)
	(set intf_pool_pod_7 NONE)
)
(script continuous osa_pool_drop_thread_8
	(sleep_until (!= intf_pool_pod_8 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_8 intf_pool_dm_8 intf_pool_dm_type_8 intf_pool_drop_clean_timer_8)
	(set intf_pool_pod_8 NONE)
)
(script continuous osa_pool_drop_thread_9
	(sleep_until (!= intf_pool_pod_9 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_9 intf_pool_dm_9 intf_pool_dm_type_9 intf_pool_drop_clean_timer_9)
	(set intf_pool_pod_9 NONE)
)
(script continuous osa_pool_drop_thread_10
	(sleep_until (!= intf_pool_pod_10 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_10 intf_pool_dm_10 intf_pool_dm_type_10 intf_pool_drop_clean_timer_10)
	(set intf_pool_pod_10 NONE)
)
(script continuous osa_pool_drop_thread_11
	(sleep_until (!= intf_pool_pod_11 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_11 intf_pool_dm_11 intf_pool_dm_type_11 intf_pool_drop_clean_timer_11)
	(set intf_pool_pod_11 NONE)
)
(script continuous osa_pool_drop_thread_12
	(sleep_until (!= intf_pool_pod_12 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_12 intf_pool_dm_12 intf_pool_dm_type_12 intf_pool_drop_clean_timer_12)
	(set intf_pool_pod_12 NONE)
)
(script continuous osa_pool_drop_thread_13
	(sleep_until (!= intf_pool_pod_13 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_13 intf_pool_dm_13 intf_pool_dm_type_13 intf_pool_drop_clean_timer_13)
	(set intf_pool_pod_13 NONE)
)
(script continuous osa_pool_drop_thread_14
	(sleep_until (!= intf_pool_pod_14 NONE) 5)
	(osa_pool_drop_handle_exit intf_pool_pod_14 intf_pool_dm_14 intf_pool_dm_type_14 intf_pool_drop_clean_timer_14)
	(set intf_pool_pod_14 NONE)
)
