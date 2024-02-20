; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_utils.hsc

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================
; This script is STAND ALONE - praise God. Does not create spaghetti deps except the declared above. No deps in sapien editor either.

; In order to use this script, when you are ready, you need to connect up all the interfaces.
; you can optionally import the script and just use its utilities if you want.

; This script is meant to use with firefight/extraction.
; Can use in any case you want. It just manages spawns/objectives.

;; limitations
; So we cant monitor living groups to know the current power balance. In order for objectives and respawning to work correctly, we need to move squads. This breaks any form of tracking.
; So instead, we need to create an integrator. That sums up the total power used in the match.
; As one side gets access to certain power weapons/vehicles, the other side does as well.
; The way to grant more power to a side is to SUE the other side basically.
; The suing side has to claim that they are losing.
; How do we know if they are losing?
; 1 - casualties. An increasing level of casualties tells me that they are getting wasted.
; 2 - persistently dead players. Speaks for itself right?

; For one side to have permission to spawn a tank, their current power must be less than the current max power.
; This tank spawn gets added to the total power upon this request going through, request denied adds nothing.



; Script Responsibilities:
; 1) This director only supports two teams.
; 2) monitoring AI in a level to avoid overflow
; 3) partitioning AI for teams to balance players.
; 4) cleaning up ai deployments.
; 5) organizing objectives and distributing AI across them.
; 6) monitoring player death counts

; Editor Notes:
; mongoose is so weak usually. Its free if you have AI to spawn it.

; For those interested, I have a software architect background, and I like my scripts scalable, flexible, segregated, ect.
; Apply the rules of SOLID where available and some pattern architecture.
; Scripts should really communicate through interfaces - variable interfaces should be null protected.
; Scripts that provide utility functions and such, should be stand alone. They dont need interfaces either.
; Scripts that provide a service, should use interfaces.
; Scripts that support plug-ins do so through stubs. Stubs should be overwritten by the plugin user.
; stubs should support variable input, so take advantage of that.
; auto plugins should commit at execution time, meaning preqs must all be established before calling the intf_load

; NULL PROTECTION
; scripts/vars supporting this will not execute behavior when the deps are null/unassigned.
;   INSTEAD OF FKING REQUIRING YOU TO CREATE AND INSTANCE THINGS IN SAPIEN EDITOR.

; FINALS/CONSTANTS? Put them in all caps.
; variables? lowercase.

; log_print_if dbg_dir dumps string to log file.
; print_if dbg_dir_if debug "STRING"  optional print_if dbg_dir. -- Did you know even the devs dont use this? Why dude?
; inspect (thing) use to print_if dbg_dir values of data -- FOR FK SAKE WHYYY? WHY DIDN"T DEVS USE THIS?
; breakpoint "message" -- stops scripts here and print_if dbg_dirs.
; branch <cond> <script> -- stops current script and executes another when cond.
;; can use branches for interrupts. Send the return script to the call script. Call script calls the return script whem ready to exit.

; AI objectives are represented as AI objects or Strings??
;; Use <AI>
; ai_task_status_exhausted == short
; <SHORT> ai_task_status <AI>
; if the short says exhausted, then we should refresh the objective.
; We should have a register list of objectives that get refreshed. (FIXED list count obviously -- recommend using gates to wrap all the tasks to be refreshed.)

; ai_nearest_point
; ai_point_set_get_point
; ai_get_point_count

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---
(global ai intf_gr_dir_all NONE)      ;; For asking whether we maxed out the bipeds period.
(global ai intf_gr_dir_spartans NONE) ;; For asking whether we maxed out the bipeds for this side.
(global ai intf_gr_dir_elites NONE)   ;; For asking whether we maxed out the bipeds for this side.

;; ---  Input Settings        ---
; Have a script that wants to override team balance?
; Extraction does!
(global short intf_borrow_bipeds  0) ;; set this to reserve bipeds for external use.

; AI dedicated to transportation services. put both to 0 if you dont plan to use.
; Sometimes, you can leverage this to guarantee a min AI count to a side.
; As the director will sacrifice transports to bolster numbers.
(global short intf_num_transport_spartans    2) ; 2 Pelicans essentially.
(global short intf_num_transport_elites      2) ; 2 Phantoms with gunners,  Forks are cheaper bc one driver. Only looked at when looking to spawn more people.
(global short intf_ai_per_transport_spartans 1)
(global short intf_ai_per_transport_elites   3) ; use spirits if you want to just have 1. or a phantom without gunners.

; This variable is largely map dependent. Boneyard was 43. Do not exceed or meet that.
; by default, this will be 42 -- including players. Don't exceed 50 AI in one spot on sapien.
; There appear to be two limits on this:
; 1) engine limit on entities present on map                - if you see yourself or enemies spawning without weapons, reduce max bipeds
; 2) max entites that can be rendered within the viewport   - if you see flickering enemies, reduce max bipeds (or spread them out so you don't render as many people.)
; 3) assume when things flicker in the viewport, your are exceeding engine limits. Usually crates or scenery will flicker.
; 4) although this is the sapien limitation, I cant say yet for actual game engine. sapien is not as robust.
; On forgeworld - without any thing placed - I could spawn like 100 AI.
; You might need to test this to max is out for your map. So consider this a per-map basis.
(global short intf_part_max_bipeds 42) ; #ai + #players

; ======== Interfacing Scripts ========
(global boolean osa_dir_checksum_pass TRUE) ; why this and not cond? I want ALL missing elements printed out. We're not going to play a game of guess who.
(script static boolean osa_ai_director_checksum
    ;(= 0 0) ; Don't ask, its bullshit like this: (the value of this expression (in a <void> slot) can never be used.: true)
    (if (= intf_gr_dir_all NONE)
        (begin 
			(print "Interface missing required connection: <squad group> intf_gr_dir_all")
			(set osa_dir_checksum_pass FALSE)
		)
    )
    (if (= intf_gr_dir_spartans NONE)
        (begin 
			(print "Interface missing required connection: <squad group> intf_gr_dir_spartans")
			(set osa_dir_checksum_pass FALSE)
		)
    )
    (if (= intf_gr_dir_elites NONE)
        (begin 
			(print "Interface missing required connection: <squad group> intf_gr_dir_elites")
			(set osa_dir_checksum_pass FALSE)
		)
    )
    osa_dir_checksum_pass
) ; intf checksum required on all scripts supporting null protection.

; if using vscode editor, just collapse these intf functions.
(script static void (intf_load_ai_director (boolean dbg_en))
    (print "director loading...")
    (set dbg_dir dbg_en)
    (print_if dbg_dir "Debug-Enabled")
    (osa_ai_director_checksum)
    (if osa_dir_checksum_pass
        (begin 
            (set osa_use_transport_spartans intf_num_transport_spartans)
            (set osa_use_transport_elites intf_num_transport_elites)
            (wake osa_update_player_statistics)
            (wake osa_track_player_death_count)
            (osa_director_refresh_objectives)
            (osa_director_auto_migration)
        )
		(print "director checksum failed, module will not load.")
    )
); REQUIRED SCRIPT CALL THIS IN YOUR MAIN INIT FILE.

(script static boolean (intf_director_can_spawn_ai_x (short side) (short n_ai))
    (cond 
        ((= side OSA_DIR_SIDE_SPARTAN)
            (and (<= (+ (ai_living_count intf_gr_dir_spartans) n_ai) osa_part_max_ai_spartan) (<= (+ (ai_living_count intf_gr_dir_all) n_ai) (+ intf_borrow_bipeds osa_available_bipeds)))
        )
        ((= side OSA_DIR_SIDE_ELITE)
            (and (<= (+ (ai_living_count intf_gr_dir_elites) n_ai) osa_part_max_ai_elite) (<= (+ (ai_living_count intf_gr_dir_all) n_ai) (+ intf_borrow_bipeds osa_available_bipeds)))
        )
        (TRUE ; default
            (<= (+ (ai_living_count intf_gr_dir_all) n_ai) (+ intf_borrow_bipeds osa_available_bipeds)) ; at minimum, need to keep below available bipeds.
        )
    )
) ;; spawning ai is free, use this when spawning ai. director will auto update stats.

(script static boolean (intf_director_try_spawn_vehicle_x (short side) (short v_name) (short count))
    ;; not just ask, put tell the director you are going to spawn it. REQUIRED WHEN SPAWNING AI.
    ;; This assumes that if the director says you cant spawn it, YOU DONT SPAWN IT.
    (if (= count 0)
        (print "ERROR_try_spawn_vehicle: You just sent a count of 0")
    )
    (if (intf_director_can_spawn_vehicle_x side v_name count)
        (begin 
            (incr_side_power side (* (osa_get_vehicle_power v_name) count))
            True
        )
        False
    )
    
) ; use this when spawning vehicles.

(script static boolean (intf_director_can_spawn_vehicle_x (short side) (short v_name) (short count))
    (and (<= (+ (* count (osa_get_vehicle_power v_name)) (get_side_power side)) (get_side_max_power side))     (intf_director_can_spawn_ai_x side (* count (osa_get_vehicle_seats v_name))))
) ; this only checks if it can, doesn't update director stats

(script static short (intf_director_max_squads_of_four (short side))
    (cond
        ((= side OSA_DIR_SIDE_SPARTAN)
            (/ (- osa_part_max_ai_spartan (ai_living_count intf_gr_dir_spartans)) 4)
        ) 
        ((= side OSA_DIR_SIDE_ELITE)
            (/ (- osa_part_max_ai_elite (ai_living_count intf_gr_dir_elites)) 4)
        )
    )
)

(script static ai (intf_director_migrate_squad (ai squad) (short group_index))
    ; The input squad can be a group or squad.
    ; In any case, director is going to stick them in a squad within a registered squad group.
    ; The index lets you filter which channel of groups.
    ; This basically lets you separate teams or types of squads.
    (cond 
        ((= group_index 0)
            (begin 
                (set intf_gr_idx_0 (osa_try_migrate_squad intf_gr_dir_0 squad intf_gr_idx_0) )
                (print_if dbg_dir "director migrate sq 0")
            )
        )
        ((= group_index 1)
            (begin 
                (set intf_gr_idx_1 (osa_try_migrate_squad intf_gr_dir_1 squad intf_gr_idx_1) )
                (print_if dbg_dir "director migrate sq 1")
            )
        )
        ((= group_index 2)
            (begin 
                (set intf_gr_idx_2 (osa_try_migrate_squad intf_gr_dir_2 squad intf_gr_idx_2) )
                (print_if dbg_dir "director migrate sq 2")
            )
        )
        ((= group_index 3)
            (begin 
                (set intf_gr_idx_3 (osa_try_migrate_squad intf_gr_dir_3 squad intf_gr_idx_3) )
                (print_if dbg_dir "director migrate sq 3")
            )
        )
        ((= group_index 4)
            (begin 
                (set intf_gr_idx_4 (osa_try_migrate_squad intf_gr_dir_4 squad intf_gr_idx_4) )
                (print_if dbg_dir "director migrate sq 4")
            )
        )
        ((= group_index 5)
            (begin 
                (set intf_gr_idx_5 (osa_try_migrate_squad intf_gr_dir_5 squad intf_gr_idx_5) )
                (print_if dbg_dir "director migrate sq 5")
            )
        )
        ((= group_index 6)
            (begin 
                (set intf_gr_idx_6 (osa_try_migrate_squad intf_gr_dir_6 squad intf_gr_idx_6) )
                (print_if dbg_dir "director migrate sq 6")
            )
        )
        (TRUE
            (print_if dbg_dir "director failed to find squad group")
        )
    )
    squad
)

(script static void (intf_director_AUTO_migrate_gr_sq (ai squad) (short group_index))
    ; This will try to automatically fill in objective squads when new ai spawn. Give the routing index.
    ; YOUR- WEL- COME.
    ; Min rest time of 5 ticks so the counters can track dispersion.
    (cond 
        ((= intf_migrate_dir_0 NONE)
            (begin (set intf_migrate_dir_0 squad) (set intf_migrate_dest_0 group_index))
        )
        ((= intf_migrate_dir_1 NONE)
            (begin (set intf_migrate_dir_1 squad) (set intf_migrate_dest_1 group_index))
        )
        ((= intf_migrate_dir_2 NONE)
            (begin (set intf_migrate_dir_2 squad) (set intf_migrate_dest_2 group_index))
        )
        ((= intf_migrate_dir_3 NONE)
            (begin (set intf_migrate_dir_3 squad) (set intf_migrate_dest_3 group_index))
        )
        ((= intf_migrate_dir_4 NONE)
            (begin (set intf_migrate_dir_4 squad) (set intf_migrate_dest_4 group_index))
        )
        ((= intf_migrate_dir_5 NONE)
            (begin (set intf_migrate_dir_5 squad) (set intf_migrate_dest_5 group_index))
        )
        ((= intf_migrate_dir_6 NONE)
            (begin (set intf_migrate_dir_6 squad) (set intf_migrate_dest_6 group_index))
        )
        (TRUE
            (print "ERROR: Director failed to add auto migration")
        )
    )
)

(script static void (intf_director_add_squad_group (ai squad_group))
    (cond 
        ((= intf_gr_dir_0 NONE)
           (set intf_gr_dir_0 squad_group)
        )
        ((= intf_gr_dir_1 NONE)
           (set intf_gr_dir_1 squad_group)
        )
        ((= intf_gr_dir_2 NONE)
           (set intf_gr_dir_2 squad_group)
        )
        ((= intf_gr_dir_3 NONE)
           (set intf_gr_dir_3 squad_group)
        )
        ((= intf_gr_dir_4 NONE)
           (set intf_gr_dir_4 squad_group)
        )
        ((= intf_gr_dir_5 NONE)
           (set intf_gr_dir_5 squad_group)
        )
        ((= intf_gr_dir_6 NONE)
           (set intf_gr_dir_6 squad_group)
        )
        (TRUE
            (print "ERROR: Out of squad memory")
        )
    )
)

(script static void (intf_director_add_objective (ai obj))
    (cond 
        ((= intf_obj_dir_0 NONE)
            (set intf_obj_dir_0 obj)
        )
        ((= intf_obj_dir_1 NONE)
            (set intf_obj_dir_1 obj)
        )
        ((= intf_obj_dir_2 NONE)
            (set intf_obj_dir_2 obj)
        )
        ((= intf_obj_dir_3 NONE)
            (set intf_obj_dir_3 obj)
        )
        ((= intf_obj_dir_4 NONE)
            (set intf_obj_dir_4 obj)
        )
        (TRUE
            (print "ERROR: Out of objectives memory")
        )
    )
)

(script static boolean (osa_director_type_can_transport (short type))
    (cond 
        (
            (or (= type OSA_DIR_TYPE_WARTHOG_CHAINGUN)
                (= type OSA_DIR_TYPE_WARTHOG_ROCKET)
                (= type OSA_DIR_TYPE_WARTHOG_GAUSS)
                (= type OSA_DIR_TYPE_WARTHOG_TROOP)
                (= type OSA_DIR_TYPE_MONGOOSE)
                (= type OSA_DIR_TYPE_SCORPION)
                (= type OSA_DIR_TYPE_WRAITH)
                (= type OSA_DIR_TYPE_REVENANT)
                (= type OSA_DIR_TYPE_GHOST)
                (= type OSA_DIR_TYPE_SQUAD) ; ai squads, yes assuming it is 4 people.
                (= type OSA_DIR_TYPE_PAIR)
                (= type OSA_DIR_TYPE_SINGLE)
            )
            TRUE
        )
        (TRUE
            FALSE ; probably is not a vehicle
        )
    )
)
(script static boolean (osa_director_type_is_vehicle (short type))
    (cond 
        ((or (= type OSA_DIR_TYPE_SQUAD) (= type OSA_DIR_TYPE_PAIR) (= type OSA_DIR_TYPE_SINGLE)) ; if it aint a squad, its a vehicle.
            FALSE
        )
        (TRUE
            TRUE
        )
    )
)
(script static boolean (osa_director_type_is_small (short type))
    (cond 
        (
            (or (= type OSA_DIR_TYPE_REVENANT)
                (= type OSA_DIR_TYPE_GHOST) ; I don't think warthogs fit 2 on a phantom.
            )
            TRUE
        )
        (TRUE
            FALSE
        )
    )
); if you want mongooses on phantoms, pls contact me.

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;; ========================== PUBLIC VARIABLES Read-Only ==================================

(global short OSA_DIR_SIDE_SPARTAN 0)
(global short OSA_DIR_SIDE_ELITE 1)
(global short OSA_DIR_SIDE_NONE 2)

(global short OSA_DIR_TYPE_WARTHOG_CHAINGUN    0)
(global short OSA_DIR_TYPE_WARTHOG_ROCKET      1)
(global short OSA_DIR_TYPE_WARTHOG_GAUSS       2)
(global short OSA_DIR_TYPE_WARTHOG_TROOP       3)
(global short OSA_DIR_TYPE_MONGOOSE            4)
(global short OSA_DIR_TYPE_SCORPION            5)
(global short OSA_DIR_TYPE_FALCON              6)
(global short OSA_DIR_TYPE_WRAITH              7)
(global short OSA_DIR_TYPE_REVENANT            8)
(global short OSA_DIR_TYPE_GHOST               9)
(global short OSA_DIR_TYPE_PHANTOM             10)
(global short OSA_DIR_TYPE_PELICAN             11)
(global short OSA_DIR_TYPE_BANSHEE             12)
(global short OSA_DIR_TYPE_PHANTOM_SPACE       13)
(global short OSA_DIR_TYPE_SQUAD               14)
(global short OSA_DIR_TYPE_PAIR                15)
(global short OSA_DIR_TYPE_SINGLE              16)

;; ========================== REQUIRED in Sapien ==================================
; REQUIRED AI/Squad Groups
; gr_survival_all ;; make all groups a child of this somehow. All squads should be counted under this.
; gr_survival_spartans      -> gr_survival_all
; gr_survival_elites        -> gr_survival_all

; If you intend to use FF plugin:
; waves go to gr_survival_remaining at end of wave. Used to trigger some objective tasks that make the AI come near you.
; generally waves spawn in separate squads and thus can attempt tasks that are limited to 4 ai for ex.
; gr_survival_remaining might fill up to more than 4, so they would be ineligible to do them.
; not setting a task limit can result in a rush with dozens of combatants, user beware.
; gr_survival_remaining     -> gr_survival_elites

; gr_survival_waves         -> gr_survival_elites
; gr_survival_bonus         -> gr_survival_elites

;; -------------------------- REQUIRED in Sapien ----------------------------------


;; --- INPUT VARS --- (plugins)
; empty fireteams for the director to distribute spawned squads to.
; assign these fireteams to an objective and they will spread out over the task board. (if you applied a max to the task)
; this is generally for squads not created or managed by the FF wave spawner.
; Having a multitude of squads to to provide dispersion, if you got a bunch of AI then increase the dir_max.
; You don't have to set these manually, just call: intf_director_add_squad_group <ai>
; apparently this exists: ai_squad_group_get_squad_count
; apparently this exists: ai_squad_group_get_squad
; These allowed me to make the squad count essentially unlimited for dispering teams.
;-----------------------------
(global ai intf_gr_dir_0 NONE)
(global ai intf_gr_dir_1 NONE)
(global ai intf_gr_dir_2 NONE)
(global ai intf_gr_dir_3 NONE)
(global ai intf_gr_dir_4 NONE)
(global ai intf_gr_dir_5 NONE)
(global ai intf_gr_dir_6 NONE)

(global short intf_gr_idx_0 0)
(global short intf_gr_idx_1 0)
(global short intf_gr_idx_2 0)
(global short intf_gr_idx_3 0)
(global short intf_gr_idx_4 0)
(global short intf_gr_idx_5 0)
(global short intf_gr_idx_6 0)

(global ai intf_migrate_dir_0 NONE)
(global ai intf_migrate_dir_1 NONE)
(global ai intf_migrate_dir_2 NONE)
(global ai intf_migrate_dir_3 NONE)
(global ai intf_migrate_dir_4 NONE)
(global ai intf_migrate_dir_5 NONE)
(global ai intf_migrate_dir_6 NONE)

(global short intf_migrate_dest_0 0)
(global short intf_migrate_dest_1 0)
(global short intf_migrate_dest_2 0)
(global short intf_migrate_dest_3 0)
(global short intf_migrate_dest_4 0)
(global short intf_migrate_dest_5 0)
(global short intf_migrate_dest_6 0)

; objective wrapper for the director to observe and refresh
; Wrap your tasks with a GATE and give it to this..
; The checker looks for empty gate to reset it. Exhaust only works on tasks unfortunately.
; Up to how much of it you want refreshed.
; You don't have to set these manually, just call: intf_director_add_objective <ai>
(global ai intf_obj_dir_0 NONE)
(global ai intf_obj_dir_1 NONE)
(global ai intf_obj_dir_2 NONE)
(global ai intf_obj_dir_3 NONE)
(global ai intf_obj_dir_4 NONE)

;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.

(global boolean dbg_dir false)

(global short OSA_MIN_TRANSPORT              1) ;; minimum transports to reserve, firefight/extraction needs this at 1 right now.
(global short osa_use_transport_spartans     2)
(global short osa_use_transport_elites       2)

(global short osa_available_bipeds      0)
(global short osa_part_total_players_p2 0) ; players present + bias (less than 8 gives extra bipeds back to pool)

(global short osa_avail_obj_fireteams   0)

(global short osa_part_max_ai_spartan   0)
(global short osa_part_max_ai_elite     0)
(global short osa_part_transport_ai     0)
(global real  osa_current_player_balance 0.0)
(global real  osa_current_bias_spartans  0.0)
(global real  osa_current_bias_elites    0.0)

(global short osa_current_power_spartans 0)
(global short osa_current_power_elites   0)
(global short osa_max_power_spartans     0) ;
(global short osa_max_power_elites       0) ; default power is 20


; Dead player tracking over periods of time.
(global short osa_player_dead_count_spartans 0)
(global short osa_player_dead_count_elites   0)
(global short osa_player_dead_latch_spartans 0)
(global short osa_player_dead_latch_elites   0)

(script static short (osa_get_vehicle_seats (short name))
    (cond 
        ((= name OSA_DIR_TYPE_WARTHOG_CHAINGUN)
            2
        )
        ((= name OSA_DIR_TYPE_WARTHOG_ROCKET)
            2
        )
        ((= name OSA_DIR_TYPE_WARTHOG_GAUSS)
            2
        )
        ((= name OSA_DIR_TYPE_WARTHOG_TROOP)
            5
        )
        ((= name OSA_DIR_TYPE_MONGOOSE)
            2
        )
        ((= name OSA_DIR_TYPE_FALCON) ;; lets say falcons always use 3 seats.
            3
        )
        ((= name OSA_DIR_TYPE_WRAITH)
            2
        )
        ((= name OSA_DIR_TYPE_PHANTOM)
            3
        )
        ((= name OSA_DIR_TYPE_SQUAD)
            4
        )
        ((= name OSA_DIR_TYPE_PAIR)
            2
        )
        ((= name OSA_DIR_TYPE_SINGLE)
            1
        )
        ( TRUE ; default return 1 seat
            1
        )
    )
)

(script static short (osa_get_vehicle_power (short name))
    (cond 
        ((= name OSA_DIR_TYPE_WARTHOG_CHAINGUN)
            5
        )
        ((= name OSA_DIR_TYPE_WARTHOG_ROCKET)
            7
        )
        ((= name OSA_DIR_TYPE_WARTHOG_TROOP)
            7
        )
        ((= name OSA_DIR_TYPE_WARTHOG_GAUSS)
            15
        )
        ((= name OSA_DIR_TYPE_SCORPION)
            20
        )
        ((= name OSA_DIR_TYPE_FALCON)
            40
        )
        ((= name OSA_DIR_TYPE_PELICAN)
            20
        )
        ((= name OSA_DIR_TYPE_REVENANT)
            5
        )
        ((= name OSA_DIR_TYPE_WRAITH)
            7
        )
        ((= name OSA_DIR_TYPE_BANSHEE) ;; they dont' really use banshee bombs that ofter - AND are easily shot down.
            4
        )
        ((= name OSA_DIR_TYPE_PHANTOM)
            5
        )
        ((= name OSA_DIR_TYPE_PHANTOM_SPACE)
            15
        )
        ( TRUE ; default return 1 a power of 1 -- essentially zero cost.
            1
        )
    )
)

(script static short (osa_player_dead_count (short side))
    (cond 
        ((= side OSA_DIR_SIDE_SPARTAN)
            (- osa_con_players_human (players_human_living_count))
        )
        ((= side OSA_DIR_SIDE_ELITE)
            (- osa_con_players_elite (players_elite_living_count))
        )
    )
)

; changing teams counts as a death lol.
(script dormant osa_track_player_death_count
    (sleep_until 
        (begin 
            (if (> osa_player_dead_latch_spartans (osa_player_dead_count OSA_DIR_SIDE_SPARTAN))
                (begin
                    (set osa_player_dead_count_spartans (+ osa_player_dead_count_spartans (- osa_player_dead_latch_spartans (osa_player_dead_count OSA_DIR_SIDE_SPARTAN))))
                    (set osa_player_dead_latch_spartans (osa_player_dead_count OSA_DIR_SIDE_SPARTAN))
                )     
                (if (< osa_player_dead_latch_spartans (osa_player_dead_count OSA_DIR_SIDE_SPARTAN))
                    (begin
                        (set osa_player_dead_latch_spartans (osa_player_dead_count OSA_DIR_SIDE_SPARTAN))
                    )
                )
            )
            (if (> osa_player_dead_latch_elites (osa_player_dead_count OSA_DIR_SIDE_ELITE))
                (begin
                    (set osa_player_dead_count_elites (+ osa_player_dead_count_elites (- osa_player_dead_latch_elites (osa_player_dead_count OSA_DIR_SIDE_ELITE))))
                    (set osa_player_dead_latch_elites (osa_player_dead_count OSA_DIR_SIDE_ELITE))
                )     
                (if (< osa_player_dead_latch_elites (osa_player_dead_count OSA_DIR_SIDE_ELITE))
                    (begin
                        (set osa_player_dead_latch_elites (osa_player_dead_count OSA_DIR_SIDE_ELITE))
                    )
                )
            )
            (sleep 15) ; check every half second.
        FALSE)
    )
)

(script static short (osa_ai_dead_count (short side))
    ; Why hsc doesnt natively support this? IDK.
    ; hsc supported it on a task level.
    (cond 
        ((= side OSA_DIR_SIDE_SPARTAN)
            (- (ai_spawn_count intf_gr_dir_spartans) (ai_living_count intf_gr_dir_spartans))
        )
        ((= side OSA_DIR_SIDE_ELITE)
            (- (ai_spawn_count intf_gr_dir_elites) (ai_living_count intf_gr_dir_elites))
        )
    )
)


(script dormant osa_update_player_statistics
    (sleep_until 
        (begin 
            (print_if dbg_dir "update player statistics")
            (osa_update_player_balance)
            (update_max_power)
            (sleep 15) ; 10 seconds it will refresh counts.
        FALSE)
    )
)


(script static void osa_update_player_balance
    (print_if dbg_dir "Continualy Updating Player Balance")
    (set osa_part_total_players_p2 (max (+ osa_con_players_human osa_con_players_elite) 1)) ; (+  2) ## I think hard bias is better. ; max 1 prevents crash.
    (set osa_part_transport_ai (+ (* intf_num_transport_spartans intf_ai_per_transport_spartans) (* intf_num_transport_elites intf_ai_per_transport_elites)))
    (set osa_available_bipeds (- (- (- intf_part_max_bipeds osa_part_total_players_p2) osa_part_transport_ai) intf_borrow_bipeds) )
    (set osa_current_player_balance (/ (- osa_con_players_human osa_con_players_elite) (+ 4 osa_part_total_players_p2)))

    (set osa_current_player_balance (max osa_current_player_balance -0.38))
    (set osa_current_player_balance (min osa_current_player_balance 0.38)) ; clamp between these as it provides best results.

        
    (set osa_current_bias_spartans (- 0.5 osa_current_player_balance))
    (set osa_current_bias_elites (+ 0.5 osa_current_player_balance))
    
    (set osa_part_max_ai_spartan (* osa_current_bias_spartans osa_available_bipeds))
    (set osa_part_max_ai_spartan (+ osa_part_max_ai_spartan (* intf_ai_per_transport_spartans (- intf_num_transport_spartans osa_use_transport_spartans))))
    (set osa_part_max_ai_elite (* osa_current_bias_elites osa_available_bipeds))
    ; add floored bipeds back to elites.
    (set osa_part_max_ai_elite (+ osa_part_max_ai_elite (- osa_available_bipeds (+ osa_part_max_ai_elite osa_part_max_ai_spartan))))
    (set osa_part_max_ai_elite (+ osa_part_max_ai_elite (* intf_ai_per_transport_elites (- intf_num_transport_elites osa_use_transport_elites))))
    (if (<= osa_part_max_ai_spartan 7) ; sacrifice a transport full of crew to get some bois, the 0.38 prevents 0 transports from happening.
        (begin
            (print_if dbg_dir "remove an spartan transport to balance teams")
            (set osa_use_transport_spartans (max (- osa_use_transport_spartans 1) OSA_MIN_TRANSPORT)) ; don't let below 1
        )
    )
    (if (<= osa_part_max_ai_elite 7)
        (begin 
            (print_if dbg_dir "remove an elite transport to balance teams")
            (set osa_use_transport_elites (max (- osa_use_transport_elites 1) OSA_MIN_TRANSPORT)) ; don't let below 1 for corner cases.
        )
    )
    (if (> (/ osa_part_max_ai_elite 16) intf_num_transport_elites) 
        (begin 
            (print "CRITCAL WARNING: number of transports is not enough for firefight. Min transports for biped count:")
            (inspect (/ osa_part_max_ai_elite 16))
        )
    )
)

(script static short (get_side_max_power (short side))
    (if (= side OSA_DIR_SIDE_SPARTAN)
        osa_max_power_spartans
        osa_max_power_elites
    )
)
(script static short (get_side_power (short side))
    (if (= side OSA_DIR_SIDE_SPARTAN)
        osa_current_power_spartans
        osa_current_power_elites
    )
)

(script static void update_max_power
    ; max power increases through death, to balance the game.
    (set osa_max_power_spartans (+ 20 (+ (osa_ai_dead_count OSA_DIR_SIDE_SPARTAN) (* osa_player_dead_count_spartans 5)) ))
    (set osa_max_power_elites   (+ 20 (+ (osa_ai_dead_count OSA_DIR_SIDE_ELITE)   (* osa_player_dead_count_elites   5)) ))
)

(script static void (incr_side_power (short side) (short power))
    (cond 
        ((= side OSA_DIR_SIDE_SPARTAN)
            (set osa_current_power_spartans (+ osa_current_power_spartans power))
        )
        ((= side OSA_DIR_SIDE_ELITE)
            (set osa_current_power_elites (+ osa_current_power_elites power))
        )
    )
)

(script static short (osa_try_migrate_squad (ai squad_group) (ai squad) (short index))
    (if (and (!= squad_group NONE) (> (ai_squad_group_get_squad_count squad_group) 0))
        (if (> (ai_living_count squad) 0) ; index starts from 0 right?
            (if (< index (ai_squad_group_get_squad_count squad_group))
                (begin
                    (ai_migrate_persistent squad (ai_squad_group_get_squad squad_group index))
                    (inspect index)
                    (+ index 1)
                )
                (osa_try_migrate_squad squad_group squad 0) ; loop back around and try to migrate.
            )
        )
    )
)

(script static void osa_director_refresh_objectives
    (wake osa_dir_ref_obj_0)
    (wake osa_dir_ref_obj_1)
    (wake osa_dir_ref_obj_2)
    (wake osa_dir_ref_obj_3)
    (wake osa_dir_ref_obj_4)
)
(script dormant osa_dir_ref_obj_0
    (sleep_until 
        (begin 
            (if (!= intf_obj_dir_0 NONE)
                (begin 
                    (sleep_until (= 0 (ai_task_count intf_obj_dir_0))) ; ai_task_status_exhausted only works on tasks, and Im lazy in sapien editor so..
                    (sleep 90) ; a cooldown period is required.
                    (print_if dbg_dir "refresh gate_0")
                    (ai_reset_objective intf_obj_dir_0)
                    FALSE ; stay
                )
                TRUE; break
            )
            
        )
    )
    (print_if dbg_dir "Exit Obj Refresh _0")
)
(script dormant osa_dir_ref_obj_1
    (sleep_until 
        (begin 
            (if (!= intf_obj_dir_1 NONE)
                (begin 
                    (sleep_until (= 0 (ai_task_count intf_obj_dir_1)))
                    (sleep 90) ; a cooldown period is required.
                    (print_if dbg_dir "refresh gate_1")
                    (ai_reset_objective intf_obj_dir_1)
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Obj Refresh _1")
)
(script dormant osa_dir_ref_obj_2
    (sleep_until 
        (begin 
            (if (!= intf_obj_dir_2 NONE)
                (begin 
                    (sleep_until (= 0 (ai_task_count intf_obj_dir_2)))
                    (sleep 90) ; a cooldown period is required.
                    (print_if dbg_dir "refresh gate_2")
                    (ai_reset_objective intf_obj_dir_2)
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Obj Refresh _2")
)
(script dormant osa_dir_ref_obj_3
    (sleep_until 
        (begin 
            (if (!= intf_obj_dir_3 NONE)
                (begin 
                    (sleep_until (= 0 (ai_task_count intf_obj_dir_3)))
                    (sleep 90) ; a cooldown period is required.
                    (print_if dbg_dir "refresh gate_3")
                    (ai_reset_objective intf_obj_dir_3)
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Obj Refresh _3")
)
(script dormant osa_dir_ref_obj_4
    (sleep_until 
        (begin 
            (if (!= intf_obj_dir_4 NONE)
                (begin 
                    (sleep_until (= 0 (ai_task_count intf_obj_dir_4)))
                    (sleep 90) ; a cooldown period is required.
                    (print_if dbg_dir "refresh gate_4")
                    (ai_reset_objective intf_obj_dir_4)
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Obj Refresh _4")
)

(script static void osa_director_auto_migration
    (wake osa_dir_migrate_sq_0)
    (wake osa_dir_migrate_sq_1)
    (wake osa_dir_migrate_sq_2)
    (wake osa_dir_migrate_sq_3)
    (wake osa_dir_migrate_sq_4)
    (wake osa_dir_migrate_sq_5)
    (wake osa_dir_migrate_sq_6)
)

(script dormant osa_dir_migrate_sq_0
    (sleep_until 
        (begin 
            (if (!= intf_migrate_dir_0 NONE)
                (begin 
                    (sleep_until (> (ai_living_count intf_migrate_dir_0) 0))
                    (sleep 1) ; just in case they won't migrate immediately.
                    (intf_director_migrate_squad intf_migrate_dir_0 intf_migrate_dest_0) ; find a squad to migrate to.
                    (sleep 1) ; a cooldown period for kicks.
                    (print "director auto migrate squad_0")
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Migrate _0")
)
(script dormant osa_dir_migrate_sq_1
    (sleep_until 
        (begin 
            (if (!= intf_migrate_dir_1 NONE)
                (begin 
                    (sleep_until (> (ai_living_count intf_migrate_dir_1) 0))
                    (sleep 1) ; just in case they won't migrate immediately.
                    (intf_director_migrate_squad intf_migrate_dir_1 intf_migrate_dest_1) ; find a squad to migrate to.
                    (sleep 1) ; a cooldown period for kicks.
                    (print "director auto migrate squad_1")
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Migrate _1")
)
(script dormant osa_dir_migrate_sq_2
    (sleep_until 
        (begin 
            (if (!= intf_migrate_dir_2 NONE)
                (begin 
                    (sleep_until (> (ai_living_count intf_migrate_dir_2) 0))
                    (sleep 1) ; just in case they won't migrate immediately.
                    (intf_director_migrate_squad intf_migrate_dir_2 intf_migrate_dest_2) ; find a squad to migrate to.
                    (sleep 1) ; a cooldown period for kicks.
                    (print "director auto migrate squad_2")
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Migrate _2")
)
(script dormant osa_dir_migrate_sq_3
    (sleep_until 
        (begin 
            (if (!= intf_migrate_dir_3 NONE)
                (begin 
                    (sleep_until (> (ai_living_count intf_migrate_dir_3) 0))
                    (sleep 1) ; just in case they won't migrate immediately.
                    (intf_director_migrate_squad intf_migrate_dir_3 intf_migrate_dest_3) ; find a squad to migrate to.
                    (sleep 1) ; a cooldown period for kicks.
                    (print "director auto migrate squad_3")
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Migrate _3")
)
(script dormant osa_dir_migrate_sq_4
    (sleep_until 
        (begin 
            (if (!= intf_migrate_dir_4 NONE)
                (begin 
                    (sleep_until (> (ai_living_count intf_migrate_dir_4) 0))
                    (sleep 1) ; just in case they won't migrate immediately.
                    (intf_director_migrate_squad intf_migrate_dir_4 intf_migrate_dest_4) ; find a squad to migrate to.
                    (sleep 1) ; a cooldown period for kicks.
                    (print "director auto migrate squad_4")
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Migrate _4")
)
(script dormant osa_dir_migrate_sq_5
    (sleep_until 
        (begin 
            (if (!= intf_migrate_dir_5 NONE)
                (begin 
                    (sleep_until (> (ai_living_count intf_migrate_dir_5) 0))
                    (sleep 1) ; just in case they won't migrate immediately.
                    (intf_director_migrate_squad intf_migrate_dir_5 intf_migrate_dest_5) ; find a squad to migrate to.
                    (sleep 1) ; a cooldown period for kicks.
                    (print "director auto migrate squad_5")
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Migrate _5")
)
(script dormant osa_dir_migrate_sq_6
    (sleep_until 
        (begin 
            (if (!= intf_migrate_dir_6 NONE)
                (begin 
                    (sleep_until (> (ai_living_count intf_migrate_dir_6) 0))
                    (sleep 1) ; just in case they won't migrate immediately.
                    (intf_director_migrate_squad intf_migrate_dir_6 intf_migrate_dest_6) ; find a squad to migrate to.
                    (sleep 1) ; a cooldown period for kicks.
                    (print "director auto migrate squad_6")
                    FALSE ; stay
                )
                TRUE; break
            )
        )
    )
    (print_if dbg_dir "Exit Migrate _6")
)
