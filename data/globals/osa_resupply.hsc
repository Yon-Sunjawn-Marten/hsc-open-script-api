; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; osa_firefight_incidents.hsc

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Replenish Physical items in the level when triggered.
; Calls an event for FX if desired.
;
; Editor Notes:
; No checksum for this, as it is not possible to checksum folder existence.
; You will just get compile errors.

; device positions
; ff10 -- used for Firefight.
; m10_insert_dropoff_a
; m10_insert_dropoff_b
; m10_dropoff
; m10_insert_dropoff_a_leomar
; m10_insert_dropoff_b_leomar
; device:position
; 
; m50_starport_escape
;

;; ========================== REQUIRED in Sapien ==================================
; these folders must exist in their respective categories.
(global folder folder_survival_scenery 		sc_survival) 	; objects/scenery/sc_survival
(global folder folder_survival_crates 		cr_survival) 	; objects/crates/cr_survival
(global folder folder_survival_vehicles 	v_survival) 	; objects/units/vehicles/v_survival
(global folder folder_survival_equipment 	eq_survival)	; objects/items/equipment/eq_survival
(global folder folder_survival_weapons 		wp_survival)	; objects/items/weapons/wp_survival
(global folder folder_survival_devices 		dc_survival)	; objects/devices/controls/dc_survival

;; -------------------------- REQUIRED in Sapien ----------------------------------


;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  OUTPUT VARS        ---


; ======== Interfacing Scripts ========

(global boolean intf_resupply_refresh_trigger FALSE) ;; just set it to true.
(global short intf_resupply_max_drop_pods 2); max drop pods at once.

(script stub void intf_resupply_weapon_drop_0
	(print "plug this into your script to use your custom/map specific weapon drops.")

	; Example dormant script woken by this.
	; (print "bringing in longsword...")
	; (sleep 1)
	; (device_set_position_track longsword_0 "ff10" 0)
	; (device_animate_position longsword_0 1 10.0 3 3 FALSE)
	; (sleep_until (>= (device_get_position longsword_0) 0.4) 1)
	; (sleep_until (>= (device_get_position longsword_0) 0.8) 1)
	; (osa_utils_reset_device longsword_0)

) ; open

;; ------------------------------------------------------------------------
;; -------------------------- INTERFACES ----------------------------------
;; ------------------------------------------------------------------------

;=========================================================================
;============================== PLUGINS ==================================
;=========================================================================

(script static void intf_plugin_osa_resupply
	(set intf_resupply_refresh_trigger true)
) ; warzone not required, BUT, will run this for you if included.

;------------------------------ PLUGINS ----------------------------------

;; ========================== PUBLIC VARIABLES Read-Only ==================================


;; ========================== Internal Use CONSTANTS/VARS ==================================


(script continuous osa_resup_auto_refresh
	; survival_mode_current_wave_is_initial
	; survival_mode_set_get do I want to use this? to only reload after first set?
	(sleep_until intf_resupply_refresh_trigger)
	(object_create_folder_anew folder_survival_scenery)
	(object_create_folder_anew folder_survival_vehicles)
	(airstrike_set_launches 6)
	(submit_incident_with_cause_campaign_team "sur_airstrike_refill" player)
	(if (survival_mode_ammo_crates_enable)
		(begin 
			(object_create_folder_anew folder_survival_equipment)
			(object_create_folder_anew folder_survival_crates)
		)
	)

	(if (survival_mode_weapon_drops_enable)
		(begin 
			(event_survival_awarded_weapon)
			(object_create_folder_anew folder_survival_weapons)
			(intf_resupply_weapon_drop_0)
		)
	)

	(set intf_resupply_refresh_trigger FALSE)
)
