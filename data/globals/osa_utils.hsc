; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Manages some player stats
; Mostly in charge of HUD events.
;
; Editor Notes:
;

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---
(global short intf_utils_hp_see_dist 15) ; in world units?
(global short intf_utils_proximity_see_dist 15) ; in world units?
(global short intf_utils_proximity_min_dist 4) ; in world units?

; ======== Interfacing Scripts ========

(script static void (intf_utils_callout_object_p (object thing) (short type))
	(sound_impulse_start sfx_blip NONE 1) ; sfx_blip is a global somewhere..
	
	(chud_track_object_for_player_with_priority (human_player_in_game_get 0) thing type)
	(chud_track_object_for_player_with_priority (human_player_in_game_get 1) thing type)
	(chud_track_object_for_player_with_priority (human_player_in_game_get 2) thing type)
	(chud_track_object_for_player_with_priority (human_player_in_game_get 3) thing type)
	(chud_track_object_for_player_with_priority (human_player_in_game_get 4) thing type)
	(chud_track_object_for_player_with_priority (human_player_in_game_get 5) thing type)
	(chud_track_object_for_player_with_priority (human_player_in_game_get 6) thing type)
	(chud_track_object_for_player_with_priority (human_player_in_game_get 7) thing type)
	; Elites get the opposite marker :)
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 0) thing (osa_utils_get_opposite_type type))
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 1) thing (osa_utils_get_opposite_type type))
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 2) thing (osa_utils_get_opposite_type type))
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 3) thing (osa_utils_get_opposite_type type))
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 4) thing (osa_utils_get_opposite_type type))
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 5) thing (osa_utils_get_opposite_type type))
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 6) thing (osa_utils_get_opposite_type type))
	(chud_track_object_for_player_with_priority (elite_player_in_game_get 7) thing (osa_utils_get_opposite_type type))
	; (sleep time) -- this is a blocking statement. and this script gets indirectly called from command_scripts
	; why not just leave it on and simplify the damn scripts?
	; turning it OFF is why this script got complicated.
	; (chud_track_object dropship false)
) ;; permanent callout until the object is removed from play.

(script static void (intf_utils_callout_object (object thing) (short type) (short timer))
	; This will mark your object in hud, then it will store that in a var buffer
	; this var buffer will then remove your thing from hud call out when it expires.
	(intf_utils_callout_object_p thing type)
	(osa_utils_schedule_chud_death thing timer)
) ; I promise to track at least 14 objects at once.

(script static void (intf_utils_add_health_kit (device pack))
	(cond 
		((= prv_utils_health_pack_0 NONE)
			(set prv_utils_health_pack_0 pack)
		)
		((= prv_utils_health_pack_1 NONE)
			(set prv_utils_health_pack_1 pack)
		)
		((= prv_utils_health_pack_2 NONE)
			(set prv_utils_health_pack_2 pack)
		)
		((= prv_utils_health_pack_3 NONE)
			(set prv_utils_health_pack_3 pack)
		)
		((= prv_utils_health_pack_4 NONE)
			(set prv_utils_health_pack_4 pack)
		)
		((= prv_utils_health_pack_5 NONE)
			(set prv_utils_health_pack_5 pack)
		)
		(TRUE
			(print "ERROR: Utils failed to add health pack. out of mem.")
		)
	)
) ; I promise to track at least 14 objects at once.

(script static void (intf_utils_add_proximity_callout (object thing) (short type))
	(cond 
		((= prv_chud_prox_0 NONE)
			(begin (set prv_chud_prox_0 thing) (set prv_type_prox_0 type))
		)
		((= prv_chud_prox_1 NONE)
			(begin (set prv_chud_prox_1 thing) (set prv_type_prox_1 type))
		)
		((= prv_chud_prox_2 NONE)
			(begin (set prv_chud_prox_2 thing) (set prv_type_prox_2 type))
		)
		((= prv_chud_prox_3 NONE)
			(begin (set prv_chud_prox_3 thing) (set prv_type_prox_3 type))
		)
		((= prv_chud_prox_4 NONE)
			(begin (set prv_chud_prox_4 thing) (set prv_type_prox_4 type))
		)
		((= prv_chud_prox_5 NONE)
			(begin (set prv_chud_prox_5 thing) (set prv_type_prox_5 type))
		)
		((= prv_chud_prox_6 NONE)
			(begin (set prv_chud_prox_6 thing) (set prv_type_prox_6 type))
		)
		((= prv_chud_prox_7 NONE)
			(begin (set prv_chud_prox_7 thing) (set prv_type_prox_7 type))
		)
		(TRUE
			(print "ERROR: Utils failed to add proximity marker. out of mem.")
		)
	)
); I promise to track at least 8 objects at once.

(script static void (intf_utils_remove_proximity_callout (object thing))
	(cond 
		((= prv_chud_prox_0 thing)
			(set prv_type_prox_0 -1)
		)
		((= prv_chud_prox_1 thing)
			(set prv_type_prox_1 -1)
		)
		((= prv_chud_prox_2 thing)
			(set prv_type_prox_2 -1)
		)
		((= prv_chud_prox_3 thing)
			(set prv_type_prox_3 -1)
		)
		((= prv_chud_prox_4 thing)
			(set prv_type_prox_4 -1)
		)
		((= prv_chud_prox_5 thing)
			(set prv_type_prox_5 -1)
		)
		((= prv_chud_prox_6 thing)
			(set prv_type_prox_6 -1)
		)
		((= prv_chud_prox_7 thing)
			(set prv_type_prox_7 -1)
		)
		(TRUE
			(print "ERROR: Utils failed to add proximity marker. out of mem.")
		)
	)
); cleanup might not be so great for this.

(script static long (osa_utils_get_marker_type (string name))
	(cond
		((= name "neutralize")
			0
		)
		((= name "defend")
			1
		)
		((= name "ordnance")
			2
		)
		((= name "switch")
			3
		)
		((= name "poi blue")
			4
		)
		((= name "friendly")
			5
		)
		((= name "message")
			6
		)
		((= name "attack a")
			7
		)
		((= name "attack b")
			8
		)
		((= name "attack c")
			9
		)
		((= name "defend a")
			10
		)
		((= name "defend b")
			11
		)
		((= name "defend c")
			12
		)
		((= name "ammo")
			13
		)
		((= name "poi red")
			14
		)
		((= name "enemy")
			15
		)
		((= name "poi a")
			17
		)
		((= name "poi b")
			18
		)
		((= name "poi c")
			19
		)
		((= name "poi d")
			20
		)
		((= name "health")
			21
		)
		((= name "squad")
			22
		)
		(TRUE
			6
		)
	)
)

(script static long (osa_utils_get_opposite_type (short index))
	(cond
		((= index 0)
			1
		)
		((= index 1)
			0
		)
		((= index 2)
			0
		)
		((= index 3)
			3
		)
		((= index 4)
			14
		)
		((= index 5)
			15
		)
		((= index 6)
			6
		)
		((= index 7)
			10
		)
		((= index 8)
			11
		)
		((= index 9)
			12
		)
		((= index 10)
			7
		)
		((= index 11)
			8
		)
		((= index 12)
			9
		)
		((= index 13)
			13
		)
		((= index 14)
			4
		)
		((= index 15)
			5
		)
		((= index 17)
			17
		)
		((= index 18)
			18
		)
		((= index 19)
			19
		)
		((= index 20)
			20
		)
		((= index 21)
			21
		)
		((= index 22) ;; squad returns enemy for elites.
			15
		)
		(TRUE
			6
		)
	)
)

(script static boolean osa_utils_players_not_respawning
	; This script returns true if the players are:
	;	Out of Lives
	; 	Set to respawn on wave, and have been dead and waiting for >5 seconds
	(or 
		(= (survival_mode_lives_get player) 0)				; NOTE: This assumes that you can never go into negative lives. -1 corresponds to infinite lives.
		(and
			(survival_mode_team_respawns_on_wave player)
			(>= osa_players_all_dead_seconds 5)
		)
	)
)

(script static short players_living_count 
	(list_count (players))
)

(script static short players_human_living_count 
	(list_count (players_human))
)

(script static boolean osa_utils_players_dead
	(<= (players_human_living_count) 0)
)

(script static short players_elite_living_count 
	(list_count (players_elite))
)

(script static unit (player_human (short index))
	(if (< index (players_human_living_count))
		(unit (list_get (players_human) index))
		none
	)
)

(script static unit (player_elite (short index))
	(if (< index (players_elite_living_count))
		(unit (list_get (players_elite) index))
		none
	)
)

(script dormant osa_utils_replenish_players
	(osa_utils_replenish_players_loop 0)
)

(script static void (osa_utils_replenish_players_loop  (short index))
	(if (< index (players_living_count))
		(begin 
			(unit_set_current_vitality (unit (list_get (players) index)) 80 80)
			(osa_utils_replenish_players_loop (+ index 1))
		)
	)
)

(script static void (osa_utils_reset_device (device local_dm))
	(sleep 30) ; not sleeping cuts out the sound.
	(object_hide local_dm true)
	(device_set_position_immediate local_dm 0)
	(object_hide local_dm false)
)

(script static short (osa_utils_compress_short (short a) (short b) (short c))
	(+ a (osa_utils_left_shift b 1) (osa_utils_left_shift c 2))
)

(script static short (osa_utils_decompress_short (short compression) (short select))
	(osa_utils_right_shift compression select)
)

(script static short (osa_utils_left_shift (short a) (short op))
	(cond 
		((= op 1)
			(* a 32)
		)
		((= op 2)
			(* a 1024)
		)
		(TRUE
			a
		)
	)
)

(script static short (osa_utils_right_shift (short a) (short op))
	;; this is what happens when devs dont put freakin binary operators in the language.
	(cond 
		((= op 1)
			(- (/ (- a (* 1024 (- (/ a 1024) (% (/ a 1024) 1)))) 32) (% (/ (- a (* 1024 (- (/ a 1024) (% (/ a 1024) 1)))) 32) 1))
		)
		((= op 2)
			(- (/ a 1024) (% (/ a 1024) 1))
		)
		(TRUE
			(- a (* 1024 (- (/ a 1024) (% (/ a 1024) 1))) (* 32 (- (/ (- a (* 1024 (- (/ a 1024) (% (/ a 1024) 1)))) 32) (% (/ (- a (* 1024 (- (/ a 1024) (% (/ a 1024) 1)))) 32) 1))))
		)
	)
)

(script static void (osa_utils_play_sound_for_humans (sound snd))
	(if (!= NONE (player_human 0))
		(sound_impulse_start snd (player_human 0) 0.25)
	)
	(if (!= NONE (player_human 1))
		(sound_impulse_start snd (player_human 1) 0.25)
	)
	(if (!= NONE (player_human 2))
		(sound_impulse_start snd (player_human 2) 0.25)
	)
	(if (!= NONE (player_human 3))
		(sound_impulse_start snd (player_human 3) 0.25)
	)
	(if (!= NONE (player_human 4))
		(sound_impulse_start snd (player_human 4) 0.25)
	)
	(if (!= NONE (player_human 5))
		(sound_impulse_start snd (player_human 5) 0.25)
	)
	(if (!= NONE (player_human 6))
		(sound_impulse_start snd (player_human 6) 0.25)
	)
	(if (!= NONE (player_human 7))
		(sound_impulse_start snd (player_human 7) 0.25)
	)
)

(script static void (osa_utils_play_sound_for_elites (sound snd))
	(if (!= NONE (player_elite 0))
		(sound_impulse_start snd (player_elite 0) 0.25)
	)
	(if (!= NONE (player_elite 1))
		(sound_impulse_start snd (player_elite 1) 0.25)
	)
	(if (!= NONE (player_elite 2))
		(sound_impulse_start snd (player_elite 2) 0.25)
	)
	(if (!= NONE (player_elite 3))
		(sound_impulse_start snd (player_elite 3) 0.25)
	)
	(if (!= NONE (player_elite 4))
		(sound_impulse_start snd (player_elite 4) 0.25)
	)
	(if (!= NONE (player_elite 5))
		(sound_impulse_start snd (player_elite 5) 0.25)
	)
	(if (!= NONE (player_elite 6))
		(sound_impulse_start snd (player_elite 6) 0.25)
	)
	(if (!= NONE (player_elite 7))
		(sound_impulse_start snd (player_elite 7) 0.25)
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


;; ========================== REQUIRED in Sapien ==================================


;; -------------------------- REQUIRED in Sapien ----------------------------------


;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.


;; ========================== PUBLIC VARIABLES Read-Only ==================================

(global short osa_con_players_human 0) ; detected connected players.
(global short osa_con_players_elite 0)
(global short osa_con_players_all 0)
(global sound sfx_blip "sound\game_sfx\ui\transition_beeps")
(global short osa_players_all_dead_seconds 0)


;; -------------------------- PUBLIC VARIABLES Read-Only ----------------------------------

(global boolean dbg_utils FALSE)

; Why tf did the devs not list out the marker types?
; 0 Neutralize
; 1 Defend Generic
; 2 ordnance
; 3 Switch
; 4 Blue Diamond
; 5 Friendly Arrow
; 6 Tool Tip? Message Box
; 7 Gen A Attack
; 8 Gen B Attack
; 9 Gen C Attack
;10 Gen A Defend
;11 Gen B Defend
;12 Gen C Defend
;13 Ammunition
;14 Red Diamond
;15 Enemy Arrow
;16 Nothing?
;17 Blue Diamond A
;18 Blue Diamond B
;19 Blue Diamond C
;20 Blue Diamond D
;21 Blue Diamond
;22 Friendly Fireteam Bubble (I think it also display's their name.)

(global object prv_chud_track_0 NONE)
(global object prv_chud_track_1 NONE)
(global object prv_chud_track_2 NONE)
(global object prv_chud_track_3 NONE)
(global object prv_chud_track_4 NONE)
(global object prv_chud_track_5 NONE)
(global object prv_chud_track_6 NONE)
(global object prv_chud_track_7 NONE)

(global device prv_utils_health_pack_0 NONE)
(global device prv_utils_health_pack_1 NONE)
(global device prv_utils_health_pack_2 NONE)
(global device prv_utils_health_pack_3 NONE)
(global device prv_utils_health_pack_4 NONE)
(global device prv_utils_health_pack_5 NONE)

(global object prv_chud_prox_0 NONE)
(global object prv_chud_prox_1 NONE)
(global object prv_chud_prox_2 NONE)
(global object prv_chud_prox_3 NONE)
(global object prv_chud_prox_4 NONE)
(global object prv_chud_prox_5 NONE)
(global object prv_chud_prox_6 NONE)
(global object prv_chud_prox_7 NONE)

(global short prv_type_prox_0 0)
(global short prv_type_prox_1 0)
(global short prv_type_prox_2 0)
(global short prv_type_prox_3 0)
(global short prv_type_prox_4 0)
(global short prv_type_prox_5 0)
(global short prv_type_prox_6 0)
(global short prv_type_prox_7 0)
;=============================================================================================================================
;========================================== FOLLOW LOD SCRIPT ================================================================
;=============================================================================================================================

; Here is the command script that will keep AI in the follow task from being LOD'd out.
; Give this script as an objective command for remaining/bonus_follow/hero_follow/main_follow
(script command_script cs_lod
	(ai_force_full_lod ai_current_actor)
)

(script static void (cam_shake (real attack) (real intensity) (real decay))
	(player_effect_set_max_rotation 2 2 2)
	(player_effect_start intensity attack)
	(player_effect_stop decay))

;==========================================================================================

; (script dormant f_periodic_rain
; 	(set s_rain_force 1)
; 	(wake f_rain)
; 	(sleep_until 
; 		(begin 
; 			(sleep (random_range 7200 14400))
; 			(set s_rain_force (random_range 1 2))
; 			FALSE
; 		)
; 	)
; )

; (global short s_rain_force -1)
; (global short s_rain_force_last -1)
; (script dormant f_rain

; 	(branch
; 		(= s_rain_force 0)
; 		(f_rain_kill)
; 	)

; 	(sleep_until
; 		(begin

; 			(if (not (= s_rain_force s_rain_force_last))
; 				(begin
				
; 					(print_if dbg_utils "changing rain")
; 					(set s_rain_force_last s_rain_force)

; 					(cond
; 						((= s_rain_force 1)
; 							(begin
; 								(print_if dbg_utils "heavy")
; 								(weather_animate_force heavy_rain 1 (random_range 10 15))		
; 							)
; 						)
; 						((= s_rain_force 2)
; 							(begin
; 								(print_if dbg_utils "stop")
; 								(weather_animate_force no_rain 1 0)		
; 							)
; 						)

; 					)
; 				)
; 			)

; 		FALSE)
; 	5)

; )

; (script static void f_rain_kill

; 	(weather_animate_force off 1 0)	

; )



(global short osa_update_counter_max 20)
(global short osa_update_counter      0)
(script continuous osa_update_player_count
    ; (print "Player connected counter.")
    (if (>= osa_update_counter osa_update_counter_max)
		(begin 
			(set osa_update_counter 0)
			(set osa_con_players_human (players_human_living_count)) ; clear every wave
            (set osa_con_players_elite (players_elite_living_count))
		)
	)
	(set osa_con_players_all	(list_count (players)))
    (set osa_con_players_human (max osa_con_players_human (players_human_living_count))) ; hold max players alive.
    (set osa_con_players_elite (max osa_con_players_elite (players_elite_living_count)))
	(set osa_update_counter (+ osa_update_counter 1))
	(sleep 2)
)

(script continuous osa_utils_all_dead_timer
	(if (not (survival_mode_team_respawns_on_wave player))
		(sleep_forever)
	)
	(sleep 30)
	(if (osa_utils_players_dead)
		(set osa_players_all_dead_seconds (+ osa_players_all_dead_seconds 1))
		(set osa_players_all_dead_seconds 0)
	)
)

(script static void (osa_utils_schedule_chud_death (object thing) (short timer))
	(cond 
		((= prv_chud_track_0 NONE)
			(begin 
				(set prv_chud_track_0 thing)
				(sleep timer osa_chud_death_0)
			)
		)
		((= prv_chud_track_1 NONE)
			(begin 
				(set prv_chud_track_1 thing)
				(sleep timer osa_chud_death_1)
			)
		)
		((= prv_chud_track_2 NONE)
			(begin 
				(set prv_chud_track_2 thing)
				(sleep timer osa_chud_death_2)
			)
		)
		((= prv_chud_track_3 NONE)
			(begin 
				(set prv_chud_track_3 thing)
				(sleep timer osa_chud_death_3)
			)
		)
		((= prv_chud_track_4 NONE)
			(begin 
				(set prv_chud_track_4 thing)
				(sleep timer osa_chud_death_4)
			)
		)
		((= prv_chud_track_5 NONE)
			(begin 
				(set prv_chud_track_5 thing)
				(sleep timer osa_chud_death_5)
			)
		)
		((= prv_chud_track_6 NONE)
			(begin 
				(set prv_chud_track_6 thing)
				(sleep timer osa_chud_death_6)
			)
		)
		((= prv_chud_track_7 NONE)
			(begin 
				(set prv_chud_track_7 thing)
				(sleep timer osa_chud_death_7)
			)
		)
	)
)

(script continuous osa_chud_death_0
	(sleep_until (!= prv_chud_track_0 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_0 FALSE)
	(set prv_chud_track_0 NONE)
)
(script continuous osa_chud_death_1
	(sleep_until (!= prv_chud_track_1 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_1 FALSE)
	(set prv_chud_track_1 NONE)
)
(script continuous osa_chud_death_2
	(sleep_until (!= prv_chud_track_2 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_2 FALSE)
	(set prv_chud_track_2 NONE)
)
(script continuous osa_chud_death_3
	(sleep_until (!= prv_chud_track_3 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_3 FALSE)
	(set prv_chud_track_3 NONE)
)
(script continuous osa_chud_death_4
	(sleep_until (!= prv_chud_track_4 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_4 FALSE)
	(set prv_chud_track_4 NONE)
)
(script continuous osa_chud_death_5
	(sleep_until (!= prv_chud_track_5 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_5 FALSE)
	(set prv_chud_track_5 NONE)
)
(script continuous osa_chud_death_6
	(sleep_until (!= prv_chud_track_6 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_6 FALSE)
	(set prv_chud_track_6 NONE)
)
(script continuous osa_chud_death_7
	(sleep_until (!= prv_chud_track_7 NONE)) ; wake if something was scheduled.
	(chud_track_object prv_chud_track_7 FALSE)
	(set prv_chud_track_7 NONE)
)


(script static void (survival_health_pack_highlight (device pack) (unit subject))
	(if 
		(or
			(< (object_get_health pack) 0)
			(< (object_get_health subject) 0)
			(> (object_get_health subject) 0.66600) ; Don't show if the player is in the range where he will regenerate naturally
			(> (objects_distance_to_object pack subject) intf_utils_hp_see_dist)
		)
		
		; Un-track it
		(begin
			(chud_track_object_for_player subject pack false)
		)
		
		; Track it
		(begin
			(chud_track_object_for_player_with_priority subject pack 21)
		)			
	)
)


(script static void (osa_highlight_medical_loop (device pack) (short index))
	(survival_health_pack_highlight pack (player_in_game_get index))
	(if (< index osa_con_players_all)
		(begin 
			(osa_highlight_medical_loop pack (+ index 1))
		)
	)
)

(script continuous osa_utils_highlight_medical
	(if (!= prv_utils_health_pack_0 NONE)
		(osa_highlight_medical_loop prv_utils_health_pack_0 0)
	)
	(if (!= prv_utils_health_pack_1 NONE)
		(osa_highlight_medical_loop prv_utils_health_pack_1 0)
	)
	(if (!= prv_utils_health_pack_2 NONE)
		(osa_highlight_medical_loop prv_utils_health_pack_2 0)
	)
	(if (!= prv_utils_health_pack_3 NONE)
		(osa_highlight_medical_loop prv_utils_health_pack_3 0)
	)
	(if (!= prv_utils_health_pack_4 NONE)
		(osa_highlight_medical_loop prv_utils_health_pack_4 0)
	)
	(if (!= prv_utils_health_pack_5 NONE)
		(osa_highlight_medical_loop prv_utils_health_pack_5 0)
	)
	(sleep 30)
)

(script static void (osa_utils_proximity_highlight (object thing) (unit subject) (short type))
	(if 
		(and
			(> type -1)
			(> (object_get_health thing) -1)
			(> (object_get_health subject) -1)
			(<= (objects_distance_to_object thing subject) intf_utils_proximity_see_dist)
			(>= (objects_distance_to_object thing subject) intf_utils_proximity_min_dist)
		)
		
		(begin
			(chud_track_object_for_player_with_priority subject thing type)
		)
		
		(begin
			(chud_track_object_for_player subject thing false)
		)			
	)
)

(script static void (osa_highlight_proximity_loop (object thing) (short index) (short type))
	(osa_utils_proximity_highlight thing (player_in_game_get index) type)
	(if (< index osa_con_players_all)
		(begin 
			(osa_highlight_proximity_loop thing (+ index 1) type)
		)
	)
) ; I think this is safe for less than 9 players.

(script continuous osa_utils_highlight_proximity
	(if (!= prv_chud_prox_0 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_0 0 prv_type_prox_0)
			(if (= prv_type_prox_0 -1)
				(set prv_chud_prox_0 NONE)
			)
		)
	)
	(if (!= prv_chud_prox_1 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_1 0 prv_type_prox_1)
			(if (= prv_type_prox_1 -1)
				(set prv_chud_prox_1 NONE)
			)
		)
	)
	(if (!= prv_chud_prox_2 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_2 0 prv_type_prox_2)
			(if (= prv_type_prox_2 -1)
				(set prv_chud_prox_2 NONE)
			)
		)
	)
	(if (!= prv_chud_prox_3 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_3 0 prv_type_prox_3)
			(if (= prv_type_prox_3 -1)
				(set prv_chud_prox_3 NONE)
			)
		)
	)
	(if (!= prv_chud_prox_4 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_4 0 prv_type_prox_4)
			(if (= prv_type_prox_4 -1)
				(set prv_chud_prox_4 NONE)
			)
		)
	)
	(if (!= prv_chud_prox_5 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_5 0 prv_type_prox_5)
			(if (= prv_type_prox_5 -1)
				(set prv_chud_prox_5 NONE)
			)
		)
	)
	(if (!= prv_chud_prox_6 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_6 0 prv_type_prox_6)
			(if (= prv_type_prox_6 -1)
				(set prv_chud_prox_6 NONE)
			)
		)
	)
	(if (!= prv_chud_prox_7 NONE)
		(begin 
			(osa_highlight_proximity_loop prv_chud_prox_7 0 prv_type_prox_7)
			(if (= prv_type_prox_7 -1)
				(set prv_chud_prox_7 NONE)
			)
		)
	)
	(sleep 90)
)
