; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_drop_ships
; include osa_utils

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Manages transport dropoffs and pickups.
;
; Editor Notes:
; Set is NOT Pass-Through - even though it says so. WTF. Set returns the object sent.
;

;; ========================== REQUIRED in Sapien ==================================

; 1) point_sets labeled as ps_pool_0 -> ps_pool_3
; point_sets cant be variables :\
; you don't need to fill them with points either.
; 2) vehicles loaded into the map: pelican, phantom, fork.  (NOT PLACED IN MAP - LOADED AS ASSETS)
; seat_mapping works at compile time, and it needs actual references from vehicles :\

; Placement_Script:
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
) ;use this on all transports you want to register (under the placement_script option.)

;; -------------------------- REQUIRED in Sapien ----------------------------------


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

(script static string (intf_pool_get_load_type_for_inf (short index)) ;; for infantry
	(cond 
        ((= 0 index)
			(cond 
				((!= "vany" intf_pl_t_drop_side_a_0)
					intf_pl_t_drop_side_a_0
				)
				((!= "vany" intf_pl_t_drop_side_b_0)
					intf_pl_t_drop_side_b_0
				)
				(TRUE
					""
				)
			)
        )
        ((= 1 index)
			(cond 
				((!= "vany" intf_pl_t_drop_side_a_1)
					intf_pl_t_drop_side_a_1
				)
				((!= "vany" intf_pl_t_drop_side_b_1)
					intf_pl_t_drop_side_b_1
				)
				(TRUE
					""
				)
			)
        )
        ((= 2 index)
			(cond 
				((!= "vany" intf_pl_t_drop_side_a_2)
					intf_pl_t_drop_side_a_2
				)
				((!= "vany" intf_pl_t_drop_side_b_2)
					intf_pl_t_drop_side_b_2
				)
				(TRUE
					""
				)
			)
        )
        ((= 3 index)
			(cond 
				((!= "vany" intf_pl_t_drop_side_a_3)
					intf_pl_t_drop_side_a_3
				)
				((!= "vany" intf_pl_t_drop_side_b_3)
					intf_pl_t_drop_side_b_3
				)
				(TRUE
					""
				)
			)
        )
        (TRUE
            (print "ERROR: Squad not in pool")
			""
        )
    )
)

(script static void (intf_pool_remove_transport (ai squad))
    (cond 
        ((= intf_pl_t_veh_0 squad)
            (set intf_pl_t_veh_0 NONE)
        )
        ((= intf_pl_t_veh_1 squad)
            (set intf_pl_t_veh_1 NONE)
        )
        ((= intf_pl_t_veh_2 squad)
            (set intf_pl_t_veh_2 NONE)
        )
        ((= intf_pl_t_veh_3 squad)
            (set intf_pl_t_veh_3 NONE)
        )
        (TRUE
            (print "ERROR: Point set is being used")
        )
    )
) ; clean so you can swap out transports

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

;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.


(global boolean dbg_pool false)
(global boolean osa_pool_insta_clean false)

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
