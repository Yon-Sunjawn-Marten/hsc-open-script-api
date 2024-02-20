; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_drop_ships
; include osa_utils

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Manages drop pods for squads/weapons/elites
; Manages transport dropoffs and pickups.
;
; Editor Notes:
; Set is NOT Pass-Through - even though it says so. WTF. Set returns the object sent.
;

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---
(global short transport_mark_time 900)


;; ---  OUTPUT VARS        ---
(global vehicle intf_pool_t_vehicle_0 NONE) ;; to get current vehicle doing the thing.
(global vehicle intf_pool_t_vehicle_1 NONE)
(global vehicle intf_pool_t_vehicle_2 NONE)
(global vehicle intf_pool_t_vehicle_3 NONE)

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

(script command_script cs_pool_drop_on_spawn_sq
	(osa_pool_try_drop_a_pod (ai_vehicle_get ai_current_actor) OSA_POOL_DROP_SQUAD)
)
(script command_script cs_pool_drop_on_spawn_solo
	(osa_pool_try_drop_a_pod (ai_vehicle_get ai_current_actor) OSA_POOL_DROP_TROOP)
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


(script static boolean (intf_pool_is_tranport_holding (ai squad_ref))
	(cond 
		((= squad_ref intf_pl_t_veh_0)
			intf_pool_t_is_holding_0
		)
		((= squad_ref intf_pl_t_veh_1)
			intf_pool_t_is_holding_1
		)
		((= squad_ref intf_pl_t_veh_2)
			intf_pool_t_is_holding_2
		)
		((= squad_ref intf_pl_t_veh_3)
			intf_pool_t_is_holding_3
		)
		(TRUE
			(begin 
				(print "ERROR: Squad is not a registered transport.")
				(= 0 1)
			)
		)
	)
); -- set this back to false to leave hold. :)
(script static void (intf_pool_unblock_transport (ai squad_ref))
	(cond 
		((= squad_ref intf_pl_t_veh_0)
			(set intf_pool_t_is_holding_0 false)
		)
		((= squad_ref intf_pl_t_veh_1)
			(set intf_pool_t_is_holding_1 false)
		)
		((= squad_ref intf_pl_t_veh_2)
			(set intf_pool_t_is_holding_2 false)
		)
		((= squad_ref intf_pl_t_veh_3)
			(set intf_pool_t_is_holding_3 false)
		)
		(TRUE
			(begin 
				(print "ERROR: Squad is not a registered transport.")
			)
		)
	)
)

(script static short (intf_pool_get_transport_track (ai squad_ref))
	(cond 
		((= squad_ref intf_pl_t_veh_0)
			intf_pool_t_cur_sel_0
		)
		((= squad_ref intf_pl_t_veh_1)
			intf_pool_t_cur_sel_1
		)
		((= squad_ref intf_pl_t_veh_2)
			intf_pool_t_cur_sel_2
		)
		((= squad_ref intf_pl_t_veh_3)
			intf_pool_t_cur_sel_3
		)
		(TRUE
			(begin 
				(print "ERROR: Squad is not a registered transport.")
				-1
			)
		)
	)
); -- set this back to false to leave hold. :)

(script static void (intf_pool_add_transport (ai squad) (short side) (string drop_a_side) (string drop_b_side))
    (cond 
        ((= intf_pl_t_veh_0 NONE)
            (begin (set intf_pl_t_veh_0 squad) (set intf_pl_t_side_0 side) (set intf_pl_t_drop_side_a_0 drop_a_side) (set intf_pl_t_drop_side_b_0 drop_b_side))
        )
        ((= intf_pl_t_veh_1 NONE)
            (begin (set intf_pl_t_veh_1 squad) (set intf_pl_t_side_1 side) (set intf_pl_t_drop_side_a_1 drop_a_side) (set intf_pl_t_drop_side_b_1 drop_b_side))
        )
        ((= intf_pl_t_veh_2 NONE)
            (begin (set intf_pl_t_veh_2 squad) (set intf_pl_t_side_2 side) (set intf_pl_t_drop_side_a_2 drop_a_side) (set intf_pl_t_drop_side_b_2 drop_b_side))
        )
        ((= intf_pl_t_veh_3 NONE)
            (begin (set intf_pl_t_veh_3 squad) (set intf_pl_t_side_3 side) (set intf_pl_t_drop_side_a_3 drop_a_side) (set intf_pl_t_drop_side_b_3 drop_b_side))
        )
        (TRUE
            (print "ERROR: Point set is being used")
        )
    )
) ; this makes transport use default settings

(script static void (intf_pool_set_transport_marker (ai squad) (short marker))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pool_t_drop_mrkr_0 marker)
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pool_t_drop_mrkr_1 marker)
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pool_t_drop_mrkr_2 marker)
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pool_t_drop_mrkr_3 marker)
        )
        (TRUE
            (print "ERROR_marker: Squad not assigned to a transport")
        )
    )
)

(script static void (intf_pool_set_transport_drop_a (ai squad) (short d1) (short d2) (short d3))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pl_t_drop_a_0 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pl_t_drop_a_1 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pl_t_drop_a_2 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pl_t_drop_a_3 (osa_utils_compress_short d1 d2 d3))
        )
        (TRUE
            (print "ERROR_drop_a: Squad not assigned to a transport")
        )
    )
) ; can occur at any point on the set. same unload method for all point sets.

(script static void (intf_pool_set_transport_drop_b (ai squad) (short d1) (short d2) (short d3))
   (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pl_t_drop_b_0 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pl_t_drop_b_1 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pl_t_drop_b_2 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pl_t_drop_b_3 (osa_utils_compress_short d1 d2 d3))
        )
        (TRUE
            (print "ERROR_drop_b: Squad not assigned to a transport")
        )
    )
) ; can occur at any point on the set. same unload method for all point sets.

(script static void (intf_pool_set_transport_tracks (ai squad) (short d1) (short d2) (short d3))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pool_t_ps_opt_0 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pool_t_ps_opt_1 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pool_t_ps_opt_2 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pool_t_ps_opt_3 (osa_utils_compress_short d1 d2 d3))
        )
        (TRUE
            (print "ERROR_tracks: Squad not assigned to a transport")
        )
    )
) ; send the starting locations for each track within the point set, supports 3 assignments to a single transport. up to 32 points supported in the point set. Transport teleports to the start point of the track.

(script static void (intf_pool_set_transport_movement (ai squad) (boolean close_wh_mv) (short h1) (short h2) (short h3))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (begin (set intf_pl_t_hold_at_0 (osa_utils_compress_short h1 h2 h3)) (set intf_pl_t_clse_whn_mv_0 close_wh_mv))
        )
        ((= intf_pl_t_veh_1 squad)
            (begin (set intf_pl_t_hold_at_1 (osa_utils_compress_short h1 h2 h3)) (set intf_pl_t_clse_whn_mv_1 close_wh_mv))
        )
        ((= intf_pl_t_veh_2 squad)
            (begin (set intf_pl_t_hold_at_2 (osa_utils_compress_short h1 h2 h3)) (set intf_pl_t_clse_whn_mv_2 close_wh_mv))
        )
        ((= intf_pl_t_veh_3 squad)
            (begin (set intf_pl_t_hold_at_3 (osa_utils_compress_short h1 h2 h3)) (set intf_pl_t_clse_whn_mv_3 close_wh_mv))
        )
        (TRUE
            (print "ERROR_movement: Squad not assigned to a transport")
        )
    )
) ; leave 0 for no hold location

(script static void (intf_pool_set_transport_slow_at (ai squad) (short p1) (short p2) (short p3))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pool_t_slow_0 (osa_utils_compress_short p1 p2 p3))
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pool_t_slow_1 (osa_utils_compress_short p1 p2 p3))
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pool_t_slow_2 (osa_utils_compress_short p1 p2 p3))
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pool_t_slow_3 (osa_utils_compress_short p1 p2 p3))
        )
        (TRUE
            (print "ERROR_slow: Squad not assigned to a transport")
        )
    )
) ; leave 0 for no slowdown

(script static void (intf_pool_set_transport_fast_at (ai squad) (short p1) (short p2) (short p3))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pool_t_fast_0 (osa_utils_compress_short p1 p2 p3))
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pool_t_fast_1 (osa_utils_compress_short p1 p2 p3))
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pool_t_fast_2 (osa_utils_compress_short p1 p2 p3))
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pool_t_fast_3 (osa_utils_compress_short p1 p2 p3))
        )
        (TRUE
            (print "ERROR_fast: Squad not assigned to a transport")
        )
    )
) ; leave 0 for no speed up

(script static void (intf_pool_set_hold_en (ai squad) (boolean hold_en))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pl_t_hold_en_0 hold_en)
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pl_t_hold_en_1 hold_en)
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pl_t_hold_en_2 hold_en)
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pl_t_hold_en_3 hold_en)
        )
        (TRUE
            (print "ERROR_hold_en: Squad not assigned to a transport")
        )
    )
)

(script static void (intf_pool_set_transport_drop_a_face_point (ai squad) (short d1) (short d2) (short d3))
	(cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pl_t_face_drop_a_0 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pl_t_face_drop_a_1 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pl_t_face_drop_a_2 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pl_t_face_drop_a_3 (osa_utils_compress_short d1 d2 d3))
        )
        (TRUE
            (print "ERROR_face_a: Squad not assigned to a transport")
        )
    )
) ; leave 0 for no facing

(script static void (intf_pool_set_transport_drop_b_face_point (ai squad) (short d1) (short d2) (short d3))
	(cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pl_t_face_drop_b_0 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pl_t_face_drop_b_1 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pl_t_face_drop_b_2 (osa_utils_compress_short d1 d2 d3))
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pl_t_face_drop_b_3 (osa_utils_compress_short d1 d2 d3))
        )
        (TRUE
            (print "ERROR_face_b: Squad not assigned to a transport")
        )
    )
) ; leave 0 for no facing

; (script static void (intf_pool_set_transport))

(script static short (intf_pool_get_thread_from_sq (ai squad))
	(cond 
		((= NONE squad)
			(begin 
				(print "INFO_get_running_t: Attempted to get pool squad with a none_type")
				-1
			)
		)
        ((= intf_pl_t_veh_0 squad)
            0
        )
        ((= intf_pl_t_veh_1 squad)
            1
        )
        ((= intf_pl_t_veh_2 squad)
            2
        )
        ((= intf_pl_t_veh_3 squad)
            3
        )
        (TRUE
            (begin 
				(print "ERROR_get_running_t: Squad not assigned to a transport thread")
				-1
			)
        )
    )
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

(global short OSA_POOL_SIDE_SPARTAN 0)
(global short OSA_POOL_SIDE_ELITE 1)
(global short OSA_POOL_NULL_PS 15) ; when you dont want a point set assigned.

;; ========================== REQUIRED in Sapien ==================================

; 1) point_sets labeled as ps_pool_0 -> ps_pool_3
; point_sets cant be variables :\
; you don't need to fill them with points either.
; 2) vehicles loaded into the map: pelican, phantom, fork.  (NOT PLACED IN MAP - LOADED AS ASSETS)
; seat_mapping works at compile time, and it needs actual references from vehicles :\

;; -------------------------- REQUIRED in Sapien ----------------------------------


;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.


;; ========================== PUBLIC VARIABLES Read-Only ==================================

(global short OSA_POOL_DROP_WEAPON 0)
(global short OSA_POOL_DROP_TROOP 1)
(global short OSA_POOL_DROP_SQUAD 2)

;; -------------------------- PUBLIC VARIABLES Read-Only ----------------------------------

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


; Up to 8 automatic transports are supported in scenario
; Need to use a unique squad per transport, unfortunately.
(global ai intf_pl_t_veh_0 NONE)
(global ai intf_pl_t_veh_1 NONE)
(global ai intf_pl_t_veh_2 NONE)
(global ai intf_pl_t_veh_3 NONE)
(global short intf_pl_t_side_0 -1)
(global short intf_pl_t_side_1 -1)
(global short intf_pl_t_side_2 -1)
(global short intf_pl_t_side_3 -1)
(global short intf_pl_t_loop_0 0)
(global short intf_pl_t_loop_1 0)
(global short intf_pl_t_loop_2 0)
(global short intf_pl_t_loop_3 0)
(global short intf_pl_t_drop_a_0 (osa_utils_compress_short 3 3 3)) ;; drop point A (compressed to store 4 ps_pool items)
(global short intf_pl_t_drop_a_1 (osa_utils_compress_short 3 3 3))
(global short intf_pl_t_drop_a_2 (osa_utils_compress_short 3 3 3))
(global short intf_pl_t_drop_a_3 (osa_utils_compress_short 3 3 3))
(global short intf_pl_t_drop_b_0 (osa_utils_compress_short 3 3 3)) ;; drop point B (compressed to store 4 ps_pool items)
(global short intf_pl_t_drop_b_1 (osa_utils_compress_short 3 3 3))
(global short intf_pl_t_drop_b_2 (osa_utils_compress_short 3 3 3))
(global short intf_pl_t_drop_b_3 (osa_utils_compress_short 3 3 3))
(global short intf_pl_t_face_drop_a_0 0) ; face a point during drop
(global short intf_pl_t_face_drop_a_1 0)
(global short intf_pl_t_face_drop_a_2 0)
(global short intf_pl_t_face_drop_a_3 0)
(global short intf_pl_t_face_drop_b_0 0) ; face a point during drop
(global short intf_pl_t_face_drop_b_1 0)
(global short intf_pl_t_face_drop_b_2 0)
(global short intf_pl_t_face_drop_b_3 0)
(global string intf_pl_t_drop_side_a_0 "vany") ; default unload is cargo
(global string intf_pl_t_drop_side_a_1 "vany")
(global string intf_pl_t_drop_side_a_2 "vany")
(global string intf_pl_t_drop_side_a_3 "vany")
(global string intf_pl_t_drop_side_b_0 "any") ; default unload is passangers
(global string intf_pl_t_drop_side_b_1 "any")
(global string intf_pl_t_drop_side_b_2 "any")
(global string intf_pl_t_drop_side_b_3 "any")
(global boolean intf_pl_t_clse_whn_mv_0 true)
(global boolean intf_pl_t_clse_whn_mv_1 true)
(global boolean intf_pl_t_clse_whn_mv_2 true)
(global boolean intf_pl_t_clse_whn_mv_3 true)
(global short  intf_pl_t_hold_at_0 0) ;; hold at point
(global short  intf_pl_t_hold_at_1 0)
(global short  intf_pl_t_hold_at_2 0)
(global short  intf_pl_t_hold_at_3 0)
(global boolean  intf_pl_t_hold_en_0 false) ;; hold enabled
(global boolean  intf_pl_t_hold_en_1 false)
(global boolean  intf_pl_t_hold_en_2 false)
(global boolean  intf_pl_t_hold_en_3 false)
(global boolean intf_pool_t_is_holding_0 false) ;; is holding at point 
(global boolean intf_pool_t_is_holding_1 false)
(global boolean intf_pool_t_is_holding_2 false)
(global boolean intf_pool_t_is_holding_3 false)
(global short intf_pool_t_drop_mrkr_0 -1) ;; marker to use when dropping.
(global short intf_pool_t_drop_mrkr_1 -1)
(global short intf_pool_t_drop_mrkr_2 -1)
(global short intf_pool_t_drop_mrkr_3 -1)

(global short intf_pool_t_ps_opt_0 0) ;; assigned track start points to use.
(global short intf_pool_t_ps_opt_1 0) 
(global short intf_pool_t_ps_opt_2 0)
(global short intf_pool_t_ps_opt_3 0)

(global short intf_pool_t_slow_0 0) ; default is to not slow down
(global short intf_pool_t_slow_1 0)
(global short intf_pool_t_slow_2 0)
(global short intf_pool_t_slow_3 0)

(global short intf_pool_t_fast_0 0) ; default is to not speed back up
(global short intf_pool_t_fast_1 0)
(global short intf_pool_t_fast_2 0)
(global short intf_pool_t_fast_3 0)

(global short intf_pool_t_cur_sel_0 -1) ;; current point set track being used.
(global short intf_pool_t_cur_sel_1 -1)
(global short intf_pool_t_cur_sel_2 -1)
(global short intf_pool_t_cur_sel_3 -1)

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

(script static short (osa_path_get_end (point_reference ps) (short point_var) (short idx)) ; constain 0-2
	(cond 
		((= idx 2)
			(ai_get_point_count ps) ; just get the last point.
		)
		((= (osa_utils_decompress_short point_var (+ idx 1)) (osa_utils_decompress_short point_var idx))
			(osa_path_get_end ps point_var (+ idx 1)) ;; if the end points are the same, get next end point. If all are same, just get length.
		)
		(TRUE
			(osa_utils_decompress_short point_var (+ idx 1)) ; bc for loop +1 at end, just send start point of next track.
		)
	)
)

(script command_script intf_pool_cs_transport_init
	(print_if dbg_pool "Vehicle starting pool")
	(cond 
		((= ai_current_squad intf_pl_t_veh_0) 
			(begin 
				(print_if dbg_pool "unit do pool_0")
				(cs_run_command_script ai_current_actor intf_pool_cs_transport_0)
			)
		)
		((= ai_current_squad intf_pl_t_veh_1) 
			(begin 
				(print_if dbg_pool "unit do pool_1")
				(cs_run_command_script ai_current_actor intf_pool_cs_transport_1)
			)
		)
		((= ai_current_squad intf_pl_t_veh_2) 
			(begin 
				(print_if dbg_pool "unit do pool_2")
				(cs_run_command_script ai_current_actor intf_pool_cs_transport_2)
			)
		)
		((= ai_current_squad intf_pl_t_veh_3) 
			(begin 
				(print_if dbg_pool "unit do pool_3")
				(cs_run_command_script ai_current_actor intf_pool_cs_transport_3)
			)
		)
		(TRUE
			(begin 
				(print "CRITICAL ERROR: CS assigned to an unlisted transport!") ; at least I'll tell you what type of transport it is that isn't registered. :P
				(inspect (osa_ds_get_vehicle_type (ai_vehicle_get ai_current_actor)))
			)
			
		)
	)
) ;use this on all transports you want to register under the placement_script option.
(script command_script intf_pool_cs_transport_0
	(cs_enable_pathfinding_failsafe TRUE)
	;(cs_ignore_obstacles TRUE)
	(set intf_pool_t_vehicle_0 (ai_vehicle_get ai_current_actor))
	
	(set intf_pool_t_cur_sel_0 (random_range 0 3)) ; excludes 3
	(set intf_pl_t_loop_0 (osa_utils_decompress_short intf_pool_t_ps_opt_0 intf_pool_t_cur_sel_0))
	(object_hide intf_pool_t_vehicle_0 true)
	(cs_teleport (ai_point_set_get_point ps_pool_0 intf_pl_t_loop_0) (ai_point_set_get_point ps_pool_0 intf_pl_t_loop_0)) ; move to the first point on the track.
	(object_hide intf_pool_t_vehicle_0 false)

	(set intf_pl_t_loop_0 (+ 1 intf_pl_t_loop_0)) ; move to next spot
    
	(if dbg_pool
		(begin 
			(print "TRANSPORT 0 USE TRACK:")
			(inspect intf_pool_t_cur_sel_0)
			(print "TRANSPORT 0 TRACK POINTS: START-END")
			(inspect (osa_utils_decompress_short intf_pool_t_ps_opt_0 intf_pool_t_cur_sel_0))
			(inspect (osa_path_get_end ps_pool_0 intf_pool_t_ps_opt_0 intf_pool_t_cur_sel_0))
			(print "TRANSPORT 0 SPEED POINTS: SLOW-FAST")
			(inspect (osa_utils_decompress_short intf_pool_t_slow_0 intf_pool_t_cur_sel_0))
			(inspect (osa_utils_decompress_short intf_pool_t_fast_0 intf_pool_t_cur_sel_0))
			(print "TRANSPORT 0 DROP POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_drop_a_0 intf_pool_t_cur_sel_0))
			(inspect (osa_utils_decompress_short intf_pl_t_drop_b_0 intf_pool_t_cur_sel_0))
			(print "TRANSPORT 0 FACE POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_a_0 intf_pool_t_cur_sel_0))
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_b_0 intf_pool_t_cur_sel_0))
			(print "TRANSPORT 0 HOLD POINT:")
			(inspect (osa_utils_decompress_short intf_pl_t_hold_at_0 intf_pool_t_cur_sel_0))
		)
	)
    (unit_close (ai_vehicle_get ai_current_actor))
    (sleep_until 
        (begin 
			(if dbg_pool
				(begin 
					(print_if dbg_pool "TRANSPORT 0 LOOP IDX == point:")
					(inspect intf_pl_t_loop_0)
				)
			)
			(cond
				((and (= intf_pl_t_loop_0 (osa_utils_decompress_short intf_pl_t_drop_a_0 intf_pool_t_cur_sel_0)) (> (osa_utils_decompress_short intf_pl_t_face_drop_a_0 intf_pool_t_cur_sel_0) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_0 intf_pl_t_loop_0) (ai_point_set_get_point ps_pool_0 (osa_utils_decompress_short intf_pl_t_face_drop_a_0 intf_pool_t_cur_sel_0)) 1)
				)
				((and (= intf_pl_t_loop_0 (osa_utils_decompress_short intf_pl_t_drop_b_0 intf_pool_t_cur_sel_0)) (> (osa_utils_decompress_short intf_pl_t_face_drop_b_0 intf_pool_t_cur_sel_0) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_0 intf_pl_t_loop_0) (ai_point_set_get_point ps_pool_0 (osa_utils_decompress_short intf_pl_t_face_drop_b_0 intf_pool_t_cur_sel_0)) 1)
				)
				(TRUE
					(cs_fly_by (ai_point_set_get_point ps_pool_0 intf_pl_t_loop_0))
				)

			)
			(if (= intf_pl_t_loop_0 (osa_utils_decompress_short intf_pool_t_slow_0 intf_pool_t_cur_sel_0))
				(cs_vehicle_speed 0.5)
			)
			(if (= intf_pl_t_loop_0 (osa_utils_decompress_short intf_pool_t_fast_0 intf_pool_t_cur_sel_0))
				(cs_vehicle_speed 1.0)
			)
            (if (= intf_pl_t_loop_0 (osa_utils_decompress_short intf_pl_t_drop_a_0 intf_pool_t_cur_sel_0))
				(begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_0 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_a_0)
				)
            )
            (if (= intf_pl_t_loop_0 (osa_utils_decompress_short intf_pl_t_drop_b_0 intf_pool_t_cur_sel_0))
                (begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_0 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_b_0)
				)
            )
            (if (and (= intf_pl_t_loop_0 (osa_utils_decompress_short intf_pl_t_hold_at_0 intf_pool_t_cur_sel_0)) intf_pl_t_hold_en_0)
                (set intf_pool_t_is_holding_0 TRUE) ; latch and hold the transport.
            )
			(sleep_until (begin (print_if dbg_pool "TRANSPORT 0 hold?") (not intf_pool_t_is_holding_0)) 5)
            (if intf_pl_t_clse_whn_mv_0 ; close when moving.
				(unit_close (ai_vehicle_get ai_current_actor))
			)
            (set intf_pl_t_loop_0 (+ intf_pl_t_loop_0 1))
            (>= intf_pl_t_loop_0 (osa_path_get_end ps_pool_0 intf_pool_t_ps_opt_0 intf_pool_t_cur_sel_0))
        )
        1
    )

    (ai_erase ai_current_squad)
    (sleep 120)
)
(script command_script intf_pool_cs_transport_1
	(cs_enable_pathfinding_failsafe TRUE)
	;(cs_ignore_obstacles TRUE)
	(set intf_pool_t_vehicle_1 (ai_vehicle_get ai_current_actor))
	
	(set intf_pool_t_cur_sel_1 (random_range 0 3)) ; excludes 3
	(set intf_pl_t_loop_1 (osa_utils_decompress_short intf_pool_t_ps_opt_1 intf_pool_t_cur_sel_1))
	(object_hide intf_pool_t_vehicle_1 true)
	(cs_teleport (ai_point_set_get_point ps_pool_1 intf_pl_t_loop_1) (ai_point_set_get_point ps_pool_1 intf_pl_t_loop_1)) ; move to the first point on the track.
	(object_hide intf_pool_t_vehicle_1 false)

	(set intf_pl_t_loop_1 (+ 1 intf_pl_t_loop_1)) ; move to next spot
    
	(if dbg_pool
		(begin 
			(print "TRANSPORT 1 USE TRACK:")
			(inspect intf_pool_t_cur_sel_1)
			(print "TRANSPORT 1 TRACK POINTS: START-END")
			(inspect (osa_utils_decompress_short intf_pool_t_ps_opt_1 intf_pool_t_cur_sel_1))
			(inspect (osa_path_get_end ps_pool_1 intf_pool_t_ps_opt_1 intf_pool_t_cur_sel_1))
			(print "TRANSPORT 1 SPEED POINTS: SLOW-FAST")
			(inspect (osa_utils_decompress_short intf_pool_t_slow_1 intf_pool_t_cur_sel_1))
			(inspect (osa_utils_decompress_short intf_pool_t_fast_1 intf_pool_t_cur_sel_1))
			(print "TRANSPORT 1 DROP POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_drop_a_1 intf_pool_t_cur_sel_1))
			(inspect (osa_utils_decompress_short intf_pl_t_drop_b_1 intf_pool_t_cur_sel_1))
			(print "TRANSPORT 1 FACE POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_a_1 intf_pool_t_cur_sel_1))
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_b_1 intf_pool_t_cur_sel_1))
			(print "TRANSPORT 1 HOLD POINT:")
			(inspect (osa_utils_decompress_short intf_pl_t_hold_at_1 intf_pool_t_cur_sel_1))
		)
	)
    (unit_close (ai_vehicle_get ai_current_actor))
    (sleep_until 
        (begin 
			(if dbg_pool
				(begin 
					(print_if dbg_pool "TRANSPORT 1 LOOP IDX == point:")
					(inspect intf_pl_t_loop_1)
				)
			)
			(cond
				((and (= intf_pl_t_loop_1 (osa_utils_decompress_short intf_pl_t_drop_a_1 intf_pool_t_cur_sel_1)) (> (osa_utils_decompress_short intf_pl_t_face_drop_a_1 intf_pool_t_cur_sel_1) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_1 intf_pl_t_loop_1) (ai_point_set_get_point ps_pool_1 (osa_utils_decompress_short intf_pl_t_face_drop_a_1 intf_pool_t_cur_sel_1)) 1)
				)
				((and (= intf_pl_t_loop_1 (osa_utils_decompress_short intf_pl_t_drop_b_1 intf_pool_t_cur_sel_1)) (> (osa_utils_decompress_short intf_pl_t_face_drop_b_1 intf_pool_t_cur_sel_1) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_1 intf_pl_t_loop_1) (ai_point_set_get_point ps_pool_1 (osa_utils_decompress_short intf_pl_t_face_drop_b_1 intf_pool_t_cur_sel_1)) 1)
				)
				(TRUE
					(cs_fly_by (ai_point_set_get_point ps_pool_1 intf_pl_t_loop_1))
				)

			)
			(if (= intf_pl_t_loop_1 (osa_utils_decompress_short intf_pool_t_slow_1 intf_pool_t_cur_sel_1))
				(cs_vehicle_speed 0.5)
			)
			(if (= intf_pl_t_loop_1 (osa_utils_decompress_short intf_pool_t_fast_1 intf_pool_t_cur_sel_1))
				(cs_vehicle_speed 1.0)
			)
            (if (= intf_pl_t_loop_1 (osa_utils_decompress_short intf_pl_t_drop_a_1 intf_pool_t_cur_sel_1))
				(begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_1 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_a_1)
				)
            )
            (if (= intf_pl_t_loop_1 (osa_utils_decompress_short intf_pl_t_drop_b_1 intf_pool_t_cur_sel_1))
                (begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_1 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_b_1)
				)
            )
            (if (and (= intf_pl_t_loop_1 (osa_utils_decompress_short intf_pl_t_hold_at_1 intf_pool_t_cur_sel_1)) intf_pl_t_hold_en_1)
                (set intf_pool_t_is_holding_1 TRUE) ; latch and hold the transport.
            )
			(sleep_until (begin (print_if dbg_pool "TRANSPORT 1 hold?") (not intf_pool_t_is_holding_1)) 5)
            (if intf_pl_t_clse_whn_mv_1 ; close when moving.
				(unit_close (ai_vehicle_get ai_current_actor))
			)
            (set intf_pl_t_loop_1 (+ intf_pl_t_loop_1 1))
            (>= intf_pl_t_loop_1 (osa_path_get_end ps_pool_1 intf_pool_t_ps_opt_1 intf_pool_t_cur_sel_1))
        )
        1
    )

    (ai_erase ai_current_squad)
    (sleep 120)
)
(script command_script intf_pool_cs_transport_2
	(cs_enable_pathfinding_failsafe TRUE)
	;(cs_ignore_obstacles TRUE)
	(set intf_pool_t_vehicle_2 (ai_vehicle_get ai_current_actor))
	
	(set intf_pool_t_cur_sel_2 (random_range 0 3)) ; excludes 3
	(set intf_pl_t_loop_2 (osa_utils_decompress_short intf_pool_t_ps_opt_2 intf_pool_t_cur_sel_2))
	(object_hide intf_pool_t_vehicle_2 true)
	(cs_teleport (ai_point_set_get_point ps_pool_2 intf_pl_t_loop_2) (ai_point_set_get_point ps_pool_2 intf_pl_t_loop_2)) ; move to the first point on the track.
	(object_hide intf_pool_t_vehicle_2 false)

	(set intf_pl_t_loop_2 (+ 1 intf_pl_t_loop_2)) ; move to next spot
    
	(if dbg_pool
		(begin 
			(print "TRANSPORT 2 USE TRACK:")
			(inspect intf_pool_t_cur_sel_2)
			(print "TRANSPORT 2 TRACK POINTS: START-END")
			(inspect (osa_utils_decompress_short intf_pool_t_ps_opt_2 intf_pool_t_cur_sel_2))
			(inspect (osa_path_get_end ps_pool_2 intf_pool_t_ps_opt_2 intf_pool_t_cur_sel_2))
			(print "TRANSPORT 2 SPEED POINTS: SLOW-FAST")
			(inspect (osa_utils_decompress_short intf_pool_t_slow_2 intf_pool_t_cur_sel_2))
			(inspect (osa_utils_decompress_short intf_pool_t_fast_2 intf_pool_t_cur_sel_2))
			(print "TRANSPORT 2 DROP POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_drop_a_2 intf_pool_t_cur_sel_2))
			(inspect (osa_utils_decompress_short intf_pl_t_drop_b_2 intf_pool_t_cur_sel_2))
			(print "TRANSPORT 2 FACE POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_a_2 intf_pool_t_cur_sel_2))
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_b_2 intf_pool_t_cur_sel_2))
			(print "TRANSPORT 2 HOLD POINT:")
			(inspect (osa_utils_decompress_short intf_pl_t_hold_at_2 intf_pool_t_cur_sel_2))
		)
	)
    (unit_close (ai_vehicle_get ai_current_actor))
    (sleep_until 
        (begin 
			(if dbg_pool
				(begin 
					(print_if dbg_pool "TRANSPORT 2 LOOP IDX == point:")
					(inspect intf_pl_t_loop_2)
				)
			)
			(cond
				((and (= intf_pl_t_loop_2 (osa_utils_decompress_short intf_pl_t_drop_a_2 intf_pool_t_cur_sel_2)) (> (osa_utils_decompress_short intf_pl_t_face_drop_a_2 intf_pool_t_cur_sel_2) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_2 intf_pl_t_loop_2) (ai_point_set_get_point ps_pool_2 (osa_utils_decompress_short intf_pl_t_face_drop_a_2 intf_pool_t_cur_sel_2)) 1)
				)
				((and (= intf_pl_t_loop_2 (osa_utils_decompress_short intf_pl_t_drop_b_2 intf_pool_t_cur_sel_2)) (> (osa_utils_decompress_short intf_pl_t_face_drop_b_2 intf_pool_t_cur_sel_2) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_2 intf_pl_t_loop_2) (ai_point_set_get_point ps_pool_2 (osa_utils_decompress_short intf_pl_t_face_drop_b_2 intf_pool_t_cur_sel_2)) 1)
				)
				(TRUE
					(cs_fly_by (ai_point_set_get_point ps_pool_2 intf_pl_t_loop_2))
				)

			)
			(if (= intf_pl_t_loop_2 (osa_utils_decompress_short intf_pool_t_slow_2 intf_pool_t_cur_sel_2))
				(cs_vehicle_speed 0.5)
			)
			(if (= intf_pl_t_loop_2 (osa_utils_decompress_short intf_pool_t_fast_2 intf_pool_t_cur_sel_2))
				(cs_vehicle_speed 1.0)
			)
            (if (= intf_pl_t_loop_2 (osa_utils_decompress_short intf_pl_t_drop_a_2 intf_pool_t_cur_sel_2))
				(begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_2 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_a_2)
				)
            )
            (if (= intf_pl_t_loop_2 (osa_utils_decompress_short intf_pl_t_drop_b_2 intf_pool_t_cur_sel_2))
                (begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_2 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_b_2)
				)
            )
            (if (and (= intf_pl_t_loop_2 (osa_utils_decompress_short intf_pl_t_hold_at_2 intf_pool_t_cur_sel_2)) intf_pl_t_hold_en_2)
                (set intf_pool_t_is_holding_2 TRUE) ; latch and hold the transport.
            )
			(sleep_until (begin (print_if dbg_pool "TRANSPORT 2 hold?") (not intf_pool_t_is_holding_2)) 5)
            (if intf_pl_t_clse_whn_mv_2 ; close when moving.
				(unit_close (ai_vehicle_get ai_current_actor))
			)
            (set intf_pl_t_loop_2 (+ intf_pl_t_loop_2 1))
            (>= intf_pl_t_loop_2 (osa_path_get_end ps_pool_2 intf_pool_t_ps_opt_2 intf_pool_t_cur_sel_2))
        )
        1
    )

    (ai_erase ai_current_squad)
    (sleep 120)
)
(script command_script intf_pool_cs_transport_3
	(cs_enable_pathfinding_failsafe TRUE)
	;(cs_ignore_obstacles TRUE)
	(set intf_pool_t_vehicle_3 (ai_vehicle_get ai_current_actor))
	
	(set intf_pool_t_cur_sel_3 (random_range 0 3)) ; excludes 3
	(set intf_pl_t_loop_3 (osa_utils_decompress_short intf_pool_t_ps_opt_3 intf_pool_t_cur_sel_3))
	(object_hide intf_pool_t_vehicle_3 true)
	(cs_teleport (ai_point_set_get_point ps_pool_3 intf_pl_t_loop_3) (ai_point_set_get_point ps_pool_3 intf_pl_t_loop_3)) ; move to the first point on the track.
	(object_hide intf_pool_t_vehicle_3 false)

	(set intf_pl_t_loop_3 (+ 1 intf_pl_t_loop_3)) ; move to next spot
    
	(if dbg_pool
		(begin 
			(print "TRANSPORT 3 USE TRACK:")
			(inspect intf_pool_t_cur_sel_3)
			(print "TRANSPORT 3 TRACK POINTS: START-END")
			(inspect (osa_utils_decompress_short intf_pool_t_ps_opt_3 intf_pool_t_cur_sel_3))
			(inspect (osa_path_get_end ps_pool_3 intf_pool_t_ps_opt_3 intf_pool_t_cur_sel_3))
			(print "TRANSPORT 3 SPEED POINTS: SLOW-FAST")
			(inspect (osa_utils_decompress_short intf_pool_t_slow_3 intf_pool_t_cur_sel_3))
			(inspect (osa_utils_decompress_short intf_pool_t_fast_3 intf_pool_t_cur_sel_3))
			(print "TRANSPORT 3 DROP POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_drop_a_3 intf_pool_t_cur_sel_3))
			(inspect (osa_utils_decompress_short intf_pl_t_drop_b_3 intf_pool_t_cur_sel_3))
			(print "TRANSPORT 3 FACE POINTS: A-B")
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_a_3 intf_pool_t_cur_sel_3))
			(inspect (osa_utils_decompress_short intf_pl_t_face_drop_b_3 intf_pool_t_cur_sel_3))
			(print "TRANSPORT 3 HOLD POINT:")
			(inspect (osa_utils_decompress_short intf_pl_t_hold_at_3 intf_pool_t_cur_sel_3))
		)
	)
    (unit_close (ai_vehicle_get ai_current_actor))
    (sleep_until 
        (begin 
			(if dbg_pool
				(begin 
					(print_if dbg_pool "TRANSPORT 3 LOOP IDX == point:")
					(inspect intf_pl_t_loop_3)
				)
			)
			(cond
				((and (= intf_pl_t_loop_3 (osa_utils_decompress_short intf_pl_t_drop_a_3 intf_pool_t_cur_sel_3)) (> (osa_utils_decompress_short intf_pl_t_face_drop_a_3 intf_pool_t_cur_sel_3) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_3 intf_pl_t_loop_3) (ai_point_set_get_point ps_pool_3 (osa_utils_decompress_short intf_pl_t_face_drop_a_3 intf_pool_t_cur_sel_3)) 1)
				)
				((and (= intf_pl_t_loop_3 (osa_utils_decompress_short intf_pl_t_drop_b_3 intf_pool_t_cur_sel_3)) (> (osa_utils_decompress_short intf_pl_t_face_drop_b_3 intf_pool_t_cur_sel_3) 0))
					(cs_fly_to_and_face (ai_point_set_get_point ps_pool_3 intf_pl_t_loop_3) (ai_point_set_get_point ps_pool_3 (osa_utils_decompress_short intf_pl_t_face_drop_b_3 intf_pool_t_cur_sel_3)) 1)
				)
				(TRUE
					(cs_fly_by (ai_point_set_get_point ps_pool_3 intf_pl_t_loop_3))
				)

			)
			(if (= intf_pl_t_loop_3 (osa_utils_decompress_short intf_pool_t_slow_3 intf_pool_t_cur_sel_3))
				(cs_vehicle_speed 0.5)
			)
			(if (= intf_pl_t_loop_3 (osa_utils_decompress_short intf_pool_t_fast_3 intf_pool_t_cur_sel_3))
				(cs_vehicle_speed 1.0)
			)
            (if (= intf_pl_t_loop_3 (osa_utils_decompress_short intf_pl_t_drop_a_3 intf_pool_t_cur_sel_3))
				(begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_3 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_a_3)
				)
            )
            (if (= intf_pl_t_loop_3 (osa_utils_decompress_short intf_pl_t_drop_b_3 intf_pool_t_cur_sel_3))
                (begin 
					(intf_utils_callout_object (ai_vehicle_get ai_current_actor) intf_pool_t_drop_mrkr_3 transport_mark_time)
					(osa_ds_unload_dropship (ai_vehicle_get ai_current_actor) intf_pl_t_drop_side_b_3)
				)
            )
            (if (and (= intf_pl_t_loop_3 (osa_utils_decompress_short intf_pl_t_hold_at_3 intf_pool_t_cur_sel_3)) intf_pl_t_hold_en_3)
                (set intf_pool_t_is_holding_3 TRUE) ; latch and hold the transport.
            )
			(sleep_until (begin (print_if dbg_pool "TRANSPORT 3 hold?") (not intf_pool_t_is_holding_3)) 5)
            (if intf_pl_t_clse_whn_mv_3 ; close when moving.
				(unit_close (ai_vehicle_get ai_current_actor))
			)
            (set intf_pl_t_loop_3 (+ intf_pl_t_loop_3 1))
            (>= intf_pl_t_loop_3 (osa_path_get_end ps_pool_3 intf_pool_t_ps_opt_3 intf_pool_t_cur_sel_3))
        )
        1
    )

    (ai_erase ai_current_squad)
    (sleep 120)
)
