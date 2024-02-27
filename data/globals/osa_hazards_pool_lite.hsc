; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_utils
; include osa_ai_director

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Manages hazards or event spawning.
; Checks with AI Director to see if spawn is possible.
; --The type provided gives the director an idea of whats spawning.

; Editor Notes:
; Use squad groups to manage hazards instead of individual squads. 
;
;
;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---


; ======== Interfacing Scripts ========

(script static void (intf_hazpl_set_event_period (short event_index) (short event_period_min) (short event_period_max))
	(cond
        ((= event_index 0)
            (begin (set intf_hazpl_event_p_min_0 event_period_min) (set intf_hazpl_event_p_max_0 event_period_max))
        )
        ((= event_index 1)
            (begin (set intf_hazpl_event_p_min_1 event_period_min) (set intf_hazpl_event_p_max_1 event_period_max))
        )
        ((= event_index 2)
            (begin (set intf_hazpl_event_p_min_2 event_period_min) (set intf_hazpl_event_p_max_2 event_period_max))
        )
        ((= event_index 3)
            (begin (set intf_hazpl_event_p_min_3 event_period_min) (set intf_hazpl_event_p_max_3 event_period_max))
        )
        (TRUE
            (print "ERROR: event index out of bounds")
        )
    )
); period in ticks. Default is 1 minute.

(script static void (intf_hazpl_add_hazard (ai sq_group) (short type) (short side) (short event_index))
	(print_if dbg_hazpl "registering a hazard/event")
	(if dbg_hazpl
		(inspect type)
	)
	
    (cond 
        ((= intf_hazpl_sq_0 NONE)
            (begin (set intf_hazpl_sq_0 sq_group) (set intf_hazpl_sq_type_0 type) (set intf_hazpl_sq_side_0 side) (set intf_hazpl_sq_event_idx_0 event_index) (wake osa_hazpl_spawn_event_0))
        )
        ((= intf_hazpl_sq_1 NONE)
            (begin (set intf_hazpl_sq_1 sq_group) (set intf_hazpl_sq_type_1 type) (set intf_hazpl_sq_side_1 side) (set intf_hazpl_sq_event_idx_1 event_index) (wake osa_hazpl_spawn_event_1))
        )
        ((= intf_hazpl_sq_2 NONE)
            (begin (set intf_hazpl_sq_2 sq_group) (set intf_hazpl_sq_type_2 type) (set intf_hazpl_sq_side_2 side) (set intf_hazpl_sq_event_idx_2 event_index) (wake osa_hazpl_spawn_event_2))
        )
        ((= intf_hazpl_sq_3 NONE)
            (begin (set intf_hazpl_sq_3 sq_group) (set intf_hazpl_sq_type_3 type) (set intf_hazpl_sq_side_3 side) (set intf_hazpl_sq_event_idx_3 event_index) (wake osa_hazpl_spawn_event_3))
        )
        (TRUE
            (print "ERROR: Out of hazard pool memory")
        )
    )
);; you can essentially assign multiple hazards to the same event, if desired.

; Note that repeat spawning is not supported with transported squads.
; *It is supported with the drop pod stuff.
(script static void (intf_hazpl_repeat_hazard_spawn (ai sq_group) (short spawn_count) (short spawn_pause))
	(cond
        ((= intf_hazpl_sq_0 sq_group)
            (begin (set intf_hazpl_spawn_amt_0 spawn_count) (set intf_hazpl_spawn_pause_0 spawn_pause))
        )
        ((= intf_hazpl_sq_1 sq_group)
            (begin (set intf_hazpl_spawn_amt_1 spawn_count) (set intf_hazpl_spawn_pause_1 spawn_pause))
        )
        ((= intf_hazpl_sq_2 sq_group)
            (begin (set intf_hazpl_spawn_amt_2 spawn_count) (set intf_hazpl_spawn_pause_2 spawn_pause))
        )
        ((= intf_hazpl_sq_3 sq_group)
            (begin (set intf_hazpl_spawn_amt_3 spawn_count) (set intf_hazpl_spawn_pause_3 spawn_pause))
        )
        (TRUE
            (print "ERROR: sq_group not a hazard")
        )
    )
); maybe you don't want all spawning at once? OR Maybe too lazy to put another spawn point. Probably both. :) (spawn pause in ticks.)

(script static void (intf_hazpl_use_permanent_callout (ai sq_group) (short marker))
	(cond 
        ((= intf_hazpl_sq_0 sq_group)
            (set intf_hazpl_use_marker_0 marker)
        )
        ((= intf_hazpl_sq_1 sq_group)
            (set intf_hazpl_use_marker_1 marker)
        )
        ((= intf_hazpl_sq_2 sq_group)
            (set intf_hazpl_use_marker_2 marker)
        )
        ((= intf_hazpl_sq_3 sq_group)
            (set intf_hazpl_use_marker_3 marker)
        )
        (TRUE
            (print "ERROR: event index out of bounds")
        )
    )
) ; if you want to have the enemies marked as they spawn. Permanent until they die.


;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

; Can override these to have your own trigger for a hazard.
(script stub boolean intf_hazpl_event_0
	(sleep (random_range intf_hazpl_event_p_min_0 intf_hazpl_event_p_max_0))
	(print "Run event 0")
	TRUE
)
(script stub boolean intf_hazpl_event_1
	(sleep (random_range intf_hazpl_event_p_min_1 intf_hazpl_event_p_max_1))
	(print "Run event 1")
	TRUE
)
(script stub boolean intf_hazpl_event_2
	(sleep (random_range intf_hazpl_event_p_min_2 intf_hazpl_event_p_max_2))
	(print "Run event 2")
	TRUE
)
(script stub boolean intf_hazpl_event_3
	(sleep (random_range intf_hazpl_event_p_min_3 intf_hazpl_event_p_max_3))
	(print "Run event 3")
	TRUE
)

(script stub void intf_plugin_hazpl_thread_0
	(print "thread plugin _0")
); allows you to script something on top of the event.
(script stub void intf_plugin_hazpl_thread_1
	(print "thread plugin _1")
)
(script stub void intf_plugin_hazpl_thread_2
	(print "thread plugin _2")
)
(script stub void intf_plugin_hazpl_thread_3
	(print "thread plugin _3")
)


;------------------------------ PLUGINS ----------------------------------

;; --- INPUT VARS --- (plugins)

;; ========================== PUBLIC VARIABLES Read-Only ==================================


;; ========================== REQUIRED in Sapien ==================================

; 1) vehicles loaded into the map: pelican, phantom, fork.  (NOT PLACED IN MAP - LOADED AS ASSETS)
; seat_mapping works at compile time, and it needs actual references from vehicles :\

;; -------------------------- REQUIRED in Sapien ----------------------------------


;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.


;; ========================== PUBLIC VARIABLES Read-Only ==================================


;; -------------------------- PUBLIC VARIABLES Read-Only ----------------------------------

(global boolean dbg_hazpl false)

;; --- INPUT VARS --- (plugins)
(global ai intf_hazpl_sq_0 NONE)
(global ai intf_hazpl_sq_1 NONE)
(global ai intf_hazpl_sq_2 NONE)
(global ai intf_hazpl_sq_3 NONE)
(global short intf_hazpl_sq_event_idx_0 0)
(global short intf_hazpl_sq_event_idx_1 0)
(global short intf_hazpl_sq_event_idx_2 0)
(global short intf_hazpl_sq_event_idx_3 0)
(global short intf_hazpl_sq_type_0 -1)
(global short intf_hazpl_sq_type_1 -1)
(global short intf_hazpl_sq_type_2 -1)
(global short intf_hazpl_sq_type_3 -1)
(global short intf_hazpl_sq_side_0 -1)
(global short intf_hazpl_sq_side_1 -1)
(global short intf_hazpl_sq_side_2 -1)
(global short intf_hazpl_sq_side_3 -1)

(global short intf_hazpl_event_p_min_0 3600); default 2 minute
(global short intf_hazpl_event_p_min_1 3600); default 2 minute
(global short intf_hazpl_event_p_min_2 3600); default 2 minute
(global short intf_hazpl_event_p_min_3 3600); default 2 minute
(global short intf_hazpl_event_p_max_0 900); default 30 seconds
(global short intf_hazpl_event_p_max_1 900); default 30 seconds
(global short intf_hazpl_event_p_max_2 900); default 30 seconds
(global short intf_hazpl_event_p_max_3 900); default 30 seconds

(global short intf_hazpl_spawn_amt_0 1)
(global short intf_hazpl_spawn_amt_1 1)
(global short intf_hazpl_spawn_amt_2 1)
(global short intf_hazpl_spawn_amt_3 1)

(global short intf_hazpl_spawn_lp_0 1)
(global short intf_hazpl_spawn_lp_1 1)
(global short intf_hazpl_spawn_lp_2 1)
(global short intf_hazpl_spawn_lp_3 1)

(global short intf_hazpl_spawn_pause_0 1)
(global short intf_hazpl_spawn_pause_1 1)
(global short intf_hazpl_spawn_pause_2 1)
(global short intf_hazpl_spawn_pause_3 1)

(global short intf_hazpl_use_marker_0 -1)
(global short intf_hazpl_use_marker_1 -1)
(global short intf_hazpl_use_marker_2 -1)
(global short intf_hazpl_use_marker_3 -1)



(script static boolean (osa_hazpl_get_event_by_idx (short index))
	(cond 
		((= index 0 )
			(intf_hazpl_event_0)
		)
		((= index 1 )
			(intf_hazpl_event_1)
		)
		((= index 2 )
			(intf_hazpl_event_2)
		)
		((= index 3 )
			(intf_hazpl_event_3)
		)
		(TRUE
			(begin 
				(print "Error: event index invalid")
				(= 0 1)
			)
		)
	)
)

(script static void (osa_hazpl_mark_spawned_squad (ai squad) (short marker))
	(if (> marker -1)
		(intf_utils_callout_object_p squad marker)
	)
)

(script static void (osa_hazpl_handle_normal (ai sq_group) (short type) (short side) (short marker) (short random_idx))
	(if (osa_director_type_is_vehicle type)
		(sleep_until (intf_director_try_spawn_vehicle_x side type 1) 5)
		(sleep_until (intf_director_can_spawn_ai_x side (osa_get_vehicle_seats type)) 5)
	)
	(ai_place (ai_squad_group_get_squad sq_group random_idx))
	(osa_hazpl_mark_spawned_squad (ai_squad_group_get_squad sq_group random_idx) marker)
)

(script dormant osa_hazpl_spawn_event_0
	; don't consume a thread idling. Activate on registration.
	(sleep_until 
		(begin 
			(sleep_until (osa_hazpl_get_event_by_idx intf_hazpl_sq_event_idx_0) 5)
			(begin 
				(set intf_hazpl_spawn_lp_0 0)
				(sleep_until
					(begin
						(set intf_hazpl_spawn_lp_0 (+ intf_hazpl_spawn_lp_0 1))
						(osa_hazpl_handle_normal intf_hazpl_sq_0 intf_hazpl_sq_type_0 intf_hazpl_sq_side_0 intf_hazpl_use_marker_0 (random_range 0 (ai_squad_group_get_squad_count intf_hazpl_sq_0)))
						(>= intf_hazpl_spawn_lp_0 intf_hazpl_spawn_amt_0)
					)
				intf_hazpl_spawn_pause_0)
			)
			(intf_plugin_hazpl_thread_0)
			FALSE
		)
	5)
)
(script dormant osa_hazpl_spawn_event_1
	; don't consume a thread idling. Activate on registration.
	(sleep_until 
		(begin 
			(sleep_until (osa_hazpl_get_event_by_idx intf_hazpl_sq_event_idx_1) 5)
			(begin 
				(set intf_hazpl_spawn_lp_1 0)
				(sleep_until
					(begin
						(set intf_hazpl_spawn_lp_1 (+ intf_hazpl_spawn_lp_1 1))
						(osa_hazpl_handle_normal intf_hazpl_sq_1 intf_hazpl_sq_type_1 intf_hazpl_sq_side_1 intf_hazpl_use_marker_1 (random_range 0 (ai_squad_group_get_squad_count intf_hazpl_sq_1)))
						(>= intf_hazpl_spawn_lp_1 intf_hazpl_spawn_amt_1)
					)
				intf_hazpl_spawn_pause_1)
			)
			(intf_plugin_hazpl_thread_1)
			FALSE
		)
	5)
)
(script dormant osa_hazpl_spawn_event_2
	; don't consume a thread idling. Activate on registration.
	(sleep_until 
		(begin 
			(sleep_until (osa_hazpl_get_event_by_idx intf_hazpl_sq_event_idx_2) 5)
			(begin 
				(set intf_hazpl_spawn_lp_2 0)
				(sleep_until
					(begin
						(set intf_hazpl_spawn_lp_2 (+ intf_hazpl_spawn_lp_2 1))
						(osa_hazpl_handle_normal intf_hazpl_sq_2 intf_hazpl_sq_type_2 intf_hazpl_sq_side_2 intf_hazpl_use_marker_2 (random_range 0 (ai_squad_group_get_squad_count intf_hazpl_sq_2)))
						(>= intf_hazpl_spawn_lp_2 intf_hazpl_spawn_amt_2)
					)
				intf_hazpl_spawn_pause_2)
			)
			(intf_plugin_hazpl_thread_2)
			FALSE
		)
	5)
)
(script dormant osa_hazpl_spawn_event_3
	; don't consume a thread idling. Activate on registration.
	(sleep_until 
		(begin 
			(sleep_until (osa_hazpl_get_event_by_idx intf_hazpl_sq_event_idx_3) 5)
			(begin 
				(set intf_hazpl_spawn_lp_3 0)
				(sleep_until
					(begin
						(set intf_hazpl_spawn_lp_3 (+ intf_hazpl_spawn_lp_3 1))
						(osa_hazpl_handle_normal intf_hazpl_sq_3 intf_hazpl_sq_type_3 intf_hazpl_sq_side_3 intf_hazpl_use_marker_3 (random_range 0 (ai_squad_group_get_squad_count intf_hazpl_sq_3)))
						(>= intf_hazpl_spawn_lp_3 intf_hazpl_spawn_amt_3)
					)
				intf_hazpl_spawn_pause_3)
			)
			(intf_plugin_hazpl_thread_3)
			FALSE
		)
	5)
)
