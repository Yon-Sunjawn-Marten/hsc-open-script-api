; Copyright 2024 Yon-Sunjawn-Marten
; IMPORTS
; include osa_director

;; ========================================================================
;; ========================== Description ==================================
;; ========================================================================

; Script Responsibilities:
; Intended to be a lighter version of warzone. 
; Does not use firefight wave spawner, instead spawns from a squad group.
;
; Editor Notes:
;
;

;; ========================== REQUIRED in Sapien ==================================

; -> means make this parented UNDER.
; gr_warzone_waves_red  -> gr_dir_marines: fill this with spawnable squads.
; gr_warzone_waves_blue -> gr_dir_elites: fill this with spawnable squads.
; gr_warzone_trans_red : parent your transports for red team under this. If no transports inside, then it is ignored.
; gr_warzone_trans_blue : parent your transports for blue team under this. If no transports inside, then it is ignored.

;; -------------------------- REQUIRED in Sapien ----------------------------------

;; ========================================================================
;; ========================== INTERFACES ==================================
;; ========================================================================

;; --- REQUIRED INPUT VARS ---

;; ---  Input Settings        ---


; ======== Interfacing Scripts ========
(script static void (intf_load_warzone_lite (boolean dbg_en) (boolean use_weather))
    (intf_load_bgm dbg_en FALSE TRUE use_weather) ; auto music and no wave / lives announcer

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

;; ========================== Internal Use CONSTANTS/VARS ==================================
; You don't need to read or know any of the internals. The abv functions are the result of all the code below.

