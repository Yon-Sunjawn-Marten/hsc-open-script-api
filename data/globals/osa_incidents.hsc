; Copyright 2024 Yon-Sunjawn-Marten

; Firefight events/incidents go here as utils.



;; Intro Options
; "sound\dialog\firefight\cla_cov_start"
; "sound\dialog\firefight\cla_unsc_start"
; "sound\dialog\firefight\gen_unsc_start"
; "sound\dialog\firefight\gen_cov_start"
; "sound\dialog\invasion\bone_cv_ph1_intro"
; "sound\dialog\invasion\bone_sp_ph1_intro"
; "sound\dialog\invasion\bone_sp_ph2_intro"
; "sound\dialog\invasion\bone_sp_ph3_intro"
; "sound\dialog\invasion\isle_cv_ph1_intro"
; "sound\dialog\invasion\isle_cv_ph2_intro"
; "sound\dialog\invasion\isle_cv_ph3_intro"
; "sound\dialog\invasion\isle_sp_ph1_intro"
; "sound\dialog\multiplayer\reach\multiplayer_game_types\invasion"
; "sound\dialog\multiplayer\vip\vip"


(global boolean intf_en_game_starting_m true)
(global boolean intf_music_playing false)
(global short intf_music_sleep 0)
(global sound intf_incd_m_welcome "sound\dialog\multiplayer\firefight\survival_welcome3")
(global sound intf_incd_m_intro_cv "sound\dialog\firefight\cla_cov_start")
(global sound intf_incd_m_intro_sp "sound\dialog\firefight\cla_unsc_start")
(global looping_sound intf_incd_intro_m   "firefight\firefight_music\firefight_music01")
(global looping_sound intf_incd_wave_m    "firefight\firefight_music\firefight_music02")
(global looping_sound intf_incd_round_m   "firefight\firefight_music\firefight_music20")
(global looping_sound intf_incd_endgame_m "firefight\firefight_music\firefight_music20")

(script static void (intf_load_incd (boolean dbg_en) (boolean use_anouncer) (boolean use_auto_music) (boolean use_weather))
    (print "incidents/audio events loading...")
	(set dbg_incidents dbg_en)
	(print_if dbg_en "Debug-Enabled")
	; (osa_ff_checksum)
	(if use_anouncer
		(wake routine_incd_announcer)
	)
	(if use_auto_music
		(wake routine_incd_music_frm_state)
	)
	(if use_weather
		(wake routine_wea_dst_thunder)
	)
); REQUIRED SCRIPT CALL THIS IN YOUR MAIN INIT FILE.

(script static void (intf_incd_set_current_music (looping_sound lpsnd) (short seconds_to_run))
	(if (not intf_music_playing)
		(begin 
			(set osa_incd_current_m lpsnd)
			(set intf_music_sleep (* 30 seconds_to_run))
			(set intf_music_playing true)
		)
		(print "music currently playing.")
	)
	
)

(script static void intf_incd_stop_current_music
	(sound_looping_stop osa_incd_current_m)
)

(global boolean osa_incd_check_endgame TRUE)
(script stub boolean plugin_incd_game_abt_end
	;; use this to set ending game music near victory.
	;; default is to play music near timeout.
	(< (- (* (survival_mode_get_time_limit) 60) osa_bgm_round_timer) (* 5 60))
)

(global boolean dbg_incidents FALSE)
(global looping_sound osa_incd_current_m NONE)

;================================== SCORE AND ACHIEVEMENTS ====================================================================
; Score attack parameters
(global long SURVIVAL_MODE_SCORE_SILVER 50000)
(global long SURVIVAL_MODE_SCORE_GOLD 200000)
(global long SURVIVAL_MODE_SCORE_ONYX 1000000)
(global long SURVIVAL_MODE_SCORE_MM 15000)

(script static long survival_total_score
	(+
		(campaign_metagame_get_player_score (player_human 0))
		(campaign_metagame_get_player_score (player_human 1))
		(campaign_metagame_get_player_score (player_human 2))
		(campaign_metagame_get_player_score (player_human 3))
		(campaign_metagame_get_player_score (player_human 4))
		(campaign_metagame_get_player_score (player_human 5))
		(campaign_metagame_get_player_score (player_human 6))
		(campaign_metagame_get_player_score (player_human 7))
	)
)


(script dormant survival_score_attack
	(print_if dbg_incidents "survival_score_attack")

    (sleep_until (>= (survival_total_score) SURVIVAL_MODE_SCORE_MM))
	(print_if dbg_incidents "survival_score_attack mm_achieve")
	(submit_incident_for_spartans "mm_score_achieve")

	(sleep_until (>= (survival_total_score) SURVIVAL_MODE_SCORE_SILVER))
	(print_if dbg_incidents "survival_score_attack silver")
	(submit_incident_for_spartans "score_silver")

	(sleep_until (>= (survival_total_score) SURVIVAL_MODE_SCORE_GOLD))
	(print_if dbg_incidents "survival_score_attack gold")
	(submit_incident_for_spartans "score_gold")

	(sleep_until (>= (survival_total_score) SURVIVAL_MODE_SCORE_ONYX))
	(print_if dbg_incidents "survival_score_attack onyx")
	(submit_incident_for_spartans "score_onyx")
)



(script static void survival_spartans_increment_score
	(survival_increment_human_score (human_player_in_game_get 0))
	(survival_increment_human_score (human_player_in_game_get 1))
	(survival_increment_human_score (human_player_in_game_get 2))
	(survival_increment_human_score (human_player_in_game_get 3))
	(survival_increment_human_score (human_player_in_game_get 4))
	(survival_increment_human_score (human_player_in_game_get 5))
	(survival_increment_human_score (human_player_in_game_get 6))
	(survival_increment_human_score (human_player_in_game_get 7))
)


(script static void survival_elites_increment_score
	(survival_increment_elite_score (elite_player_in_game_get 0))
	(survival_increment_elite_score (elite_player_in_game_get 1))
	(survival_increment_elite_score (elite_player_in_game_get 2))
	(survival_increment_elite_score (elite_player_in_game_get 3))
	(survival_increment_elite_score (elite_player_in_game_get 4))
	(survival_increment_elite_score (elite_player_in_game_get 5))
	(survival_increment_elite_score (elite_player_in_game_get 6))
	(survival_increment_elite_score (elite_player_in_game_get 7))
)


;=============================================================================================================================
;================================================== INCIDENT SCRIPTS =========================================================
;=============================================================================================================================

(script static void (submit_incident_for_spartans (string_id incident))
	(submit_incident_with_cause_player incident (human_player_in_game_get 0))
	(submit_incident_with_cause_player incident (human_player_in_game_get 1))
	(submit_incident_with_cause_player incident (human_player_in_game_get 2))
	(submit_incident_with_cause_player incident (human_player_in_game_get 3))
	(submit_incident_with_cause_player incident (human_player_in_game_get 4))
	(submit_incident_with_cause_player incident (human_player_in_game_get 5))
	(submit_incident_with_cause_player incident (human_player_in_game_get 6))
	(submit_incident_with_cause_player incident (human_player_in_game_get 7))
)
(script static void (submit_incident_for_elites (string_id incident))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 0))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 1))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 2))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 3))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 4))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 5))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 6))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 7))
)


(global short osa_incid_win_state 0)
(script static void (osa_incid_check_win_status (short direction))
	(if (!= osa_incid_win_state direction)
		(begin 
			(if (> direction 0)
				(begin 
					(osa_utils_play_sound_for_humans "sound\dialog\multiplayer\general\gained_the_lead")
					(osa_utils_play_sound_for_elites "sound\dialog\multiplayer\general\lost_the_lead")
				)
			)
			(if (< direction 0)
				(begin 
					(osa_utils_play_sound_for_elites "sound\dialog\multiplayer\general\gained_the_lead")
					(osa_utils_play_sound_for_humans "sound\dialog\multiplayer\general\lost_the_lead")
				)
			)
			(if (= direction 0)
				(begin 
					(osa_utils_play_sound_for_humans "sound\dialog\multiplayer\general\tied_the_leader")
					(osa_utils_play_sound_for_elites "sound\dialog\multiplayer\general\tied_the_leader")
				)
			)
		)
	)
	(set osa_incid_win_state direction)
)

(script static void event_welcome
	(print_if dbg_incidents "event_welcome")
	; (submit_incident "survival_welcome")
	(sound_impulse_start intf_incd_m_welcome NONE 1.0)
)

(script static void event_intro
	(print_if dbg_incidents "event_intro")

	(osa_utils_play_sound_for_elites intf_incd_m_intro_cv)
	(osa_utils_play_sound_for_humans intf_incd_m_intro_sp)
	; Announce the appropriate Firefight gametype
	; (if (> (survival_mode_generator_count) 0)
	; 	(begin
	; 		(submit_incident_with_cause_campaign_team "sur_gen_unsc_start" player)
	; 		(submit_incident_with_cause_campaign_team "sur_gen_cov_start" covenant_player)
	; 	)
	; 	(begin
	; 		(submit_incident_with_cause_campaign_team "sur_cla_unsc_start" player)
	; 		(submit_incident_with_cause_campaign_team "sur_cla_cov_start" covenant_player)
	; 	)
	; )
)

(script static void event_survival_awarded_lives
	(print_if dbg_incidents "survival_awarded_lives")
	(submit_incident_with_cause_campaign_team "survival_awarded_lives" player)
)

(script static void event_survival_5_ai_remaining
	(print_if dbg_incidents "survival_5_ai_remaining")
	(submit_incident_with_cause_campaign_team "survival_5_ai_remaining" player)
)

(script static void event_survival_2_ai_remaining
	(print_if dbg_incidents "survival_2_ai_remaining")
	(submit_incident_with_cause_campaign_team "survival_2_ai_remaining" player)
)

(script static void event_survival_1_ai_remaining
	(print_if dbg_incidents "survival_1_ai_remaining")
	(submit_incident_with_cause_campaign_team "survival_1_ai_remaining" player)
)

(script static void event_survival_bonus_round
	(print_if dbg_incidents "survival_bonus_round")
	(submit_incident "survival_bonus_round")
)

(script static void event_survival_bonus_round_over
	(print_if dbg_incidents "survival_bonus_round_over")
	(submit_incident "survival_bonus_round_over")
)

(script static void event_survival_bonus_lives_awarded
	(print_if dbg_incidents "survival_bonus_lives_awarded")
	(submit_incident_with_cause_campaign_team "survival_bonus_lives_awarded" player)
)

(script static void event_survival_better_luck_next_time
	(print_if dbg_incidents "survival_better_luck_next_time")
	(submit_incident_with_cause_campaign_team "survival_better_luck_next_time" player)
)

(script static void event_survival_new_set
	(print_if dbg_incidents "survival_new_set")
	(submit_incident "survival_new_set")
)

(script static void event_survival_new_round
	(print_if dbg_incidents "survival_new_round")
	(submit_incident "survival_new_round")
)

(script static void event_survival_reinforcements
	(print_if dbg_incidents "survival_reinforcements")
	(submit_incident "survival_reinforcements")
)

(script static void event_survival_end_round
	(print_if dbg_incidents "survival_end_round")
	(submit_incident "survival_end_round")
)

(script static void event_survival_end_set
	(print_if dbg_incidents "survival_end_set")
	(submit_incident "survival_end_set")
)

(script static void event_survival_sudden_death
	(print_if dbg_incidents "sudden_death")
	(submit_incident "sudden_death")
)

(script static void event_survival_sudden_death_over
	(print_if dbg_incidents "survival_sudden_death_over")
	(submit_incident "survival_sudden_death_over")
)

(script static void event_survival_5_lives_left
	(print_if dbg_incidents "survival_5_lives_left")
	(submit_incident_with_cause_campaign_team "survival_5_lives_left" player)
)

(script static void event_survival_1_life_left
	(print_if dbg_incidents "survival_1_life_left")
	(submit_incident_with_cause_campaign_team "survival_1_life_left" player)
)

(script static void event_survival_0_lives_left
	(print_if dbg_incidents "survival_0_lives_left")
	(submit_incident_with_cause_campaign_team "survival_0_lives_left" player)
)

(script static void event_survival_last_man_standing
	(print_if dbg_incidents "survival_last_man_standing")
	(submit_incident_with_cause_campaign_team "survival_last_man_standing" player)
)

(script static void event_survival_awarded_weapon
	(print_if dbg_incidents "survival_awarded_weapon")
	(submit_incident "survival_awarded_weapon")
)

(script static void event_survival_round_over
	(print_if dbg_incidents "event_survival_round_over")
	(submit_incident "round_over")
)

(script static void event_survival_game_over
	(print_if dbg_incidents "event_survival_game_over")
	(submit_incident "survival_game_over")
)

(script static void event_survival_generator_died
	(print_if dbg_incidents "event_survival_generator_died")
	(submit_incident_with_cause_campaign_team "survival_generator_lost" player)
	(submit_incident_with_cause_campaign_team "survival_generator_destroyed" covenant_player)
)

(global long s_sur_gen0_attack_message_cd 0)
(script static void event_survival_generator0_attacked
	(if (>= (game_tick_get) s_sur_gen0_attack_message_cd)
		(begin
			(print_if dbg_incidents "event_survival_generator0_attacked")
			(submit_incident_with_cause_campaign_team "survival_alpha_under_attack" player)
			(set s_sur_gen0_attack_message_cd (+ (game_tick_get) 450))
		)
	)
)

(global long s_sur_gen1_attack_message_cd 0)
(script static void event_survival_generator1_attacked
	(if (>= (game_tick_get) s_sur_gen1_attack_message_cd)
		(begin
			(print_if dbg_incidents "event_survival_generator1_attacked")
			(submit_incident_with_cause_campaign_team "survival_bravo_under_attack" player)
			(set s_sur_gen1_attack_message_cd (+ (game_tick_get) 450))
		)
	)
)

(global long s_sur_gen2_attack_message_cd 0)
(script static void event_survival_generator2_attacked
	(if (>= (game_tick_get) s_sur_gen2_attack_message_cd)
		(begin
			(print_if dbg_incidents "event_survival_generator2_attacked")
			(submit_incident_with_cause_campaign_team "survival_charlie_under_attack" player)
			(set s_sur_gen2_attack_message_cd (+ (game_tick_get) 450))
		)
	)
)

(script static void event_survival_generator0_locked
	(print_if dbg_incidents "event_survival_generator0_locked")
	(submit_incident "gen_alpha_locked")
)

(script static void event_survival_generator1_locked
	(print_if dbg_incidents "event_survival_generator1_locked")
	(submit_incident "gen_bravo_locked")
)

(script static void event_survival_generator2_locked
	(print_if dbg_incidents "event_survival_generator2_locked")
	(submit_incident "gen_charlie_locked")
)

(script static void event_survival_spartans_win_normal
	(print_if dbg_incidents "event_survival_spartans_win_normal")
	(submit_incident_with_cause_campaign_team "sur_gen_unsc_win" player)
	(submit_incident_with_cause_campaign_team "sur_cla_cov_fail" covenant_player)
)

(script static void event_survival_elites_win_normal
	(print_if dbg_incidents "event_survival_elites_win_normal")
	(submit_incident_with_cause_campaign_team "sur_cla_unsc_fail" player)
	(submit_incident_with_cause_campaign_team "sur_cov_win" covenant_player)
)

(script static void event_survival_spartans_win_gen
	(print_if dbg_incidents "event_survival_spartans_win_gen")
	(submit_incident_with_cause_campaign_team "sur_gen_unsc_win" player)
	(submit_incident_with_cause_campaign_team "sur_gen_cov_fail" covenant_player)
)

(script static void event_survival_elites_win_gen
	(print_if dbg_incidents "event_survival_elites_win_gen")
	(submit_incident_with_cause_campaign_team "sur_gen_unsc_fail" player)
	(submit_incident_with_cause_campaign_team "sur_cov_win" covenant_player)
)

(script static void event_survival_time_up
	(print_if dbg_incidents "event_survival_time_up")
	(submit_incident_with_cause_campaign_team "sur_unsc_timeout" player)
	(submit_incident_with_cause_campaign_team "sur_cov_timeout" covenant_player)
)

;===================================== COUNTDOWN TIMER =======================================================================

(script static void event_countdown_timer
	(sound_impulse_start "sound\game_sfx\ui\atlas_main_menu\player_timer_beep"	NONE 1)
		(sleep 30)
	(sound_impulse_start "sound\game_sfx\ui\atlas_main_menu\player_timer_beep"	NONE 1)
		(sleep 30)
	(sound_impulse_start "sound\game_sfx\ui\atlas_main_menu\player_timer_beep"	NONE 1)
		(sleep 30)
	(sound_impulse_start "sound\game_sfx\ui\atlas_main_menu\player_respawn"	NONE 1)
		(sleep 30)
)


;=============================================================================================================================
;============================================ MUSIC SCRIPTS ==================================================================
;=============================================================================================================================

(script continuous osa_incd_play_current_music
	(sleep_until intf_music_playing)
	(sound_looping_start osa_incd_current_m NONE 1.0)
	(sleep_until (not intf_music_playing) 30 intf_music_sleep) ;; allow interrupts, use the timeout to end it naturally :)
	(sound_looping_stop osa_incd_current_m)
	(set osa_incd_current_m NONE)
	(set intf_music_playing false)
)

; music definitions 
(script stub void plugin_incd_randomize_music
	; set initial music 
	(begin_random_count 1
		(set intf_incd_wave_m "firefight\firefight_music\firefight_music02")
		(set intf_incd_wave_m "firefight\firefight_music\firefight_music03")
		(set intf_incd_wave_m "firefight\firefight_music\firefight_music04")
		(set intf_incd_wave_m "firefight\firefight_music\firefight_music05")
		(set intf_incd_wave_m "firefight\firefight_music\firefight_music06")
	)
	; set final music 
	(begin_random_count 1
		(set intf_incd_round_m "firefight\firefight_music\firefight_music20")
		(set intf_incd_round_m "firefight\firefight_music\firefight_music21")
		(set intf_incd_round_m "firefight\firefight_music\firefight_music22")
		(set intf_incd_round_m "firefight\firefight_music\firefight_music23")
		(set intf_incd_round_m "firefight\firefight_music\firefight_music24")
	)
)

(script static void (osa_incd_force_music_switch (looping_sound lpsnd))
	(if (!= lpsnd osa_incd_current_m)
		(begin 
			(set intf_music_playing false)
			(sleep_until (= NONE osa_incd_current_m)) ;; sleep until music disengages.
		)
	)
)

(script dormant routine_incd_music_frm_state
	(sleep_until 
		(begin 
			(cond 
				(intf_en_game_starting_m
					(begin 
						(set intf_en_game_starting_m false)
						(osa_incd_force_music_switch intf_incd_intro_m)
						(set osa_incd_current_m intf_incd_intro_m)
						(set intf_music_sleep (* 30 60 1)) ;; play 1 minute.
						(set intf_music_playing true)
					)
				)
				((and osa_incd_check_endgame (plugin_incd_game_abt_end))
					(begin 
						(set osa_incd_check_endgame false)
						(osa_incd_force_music_switch intf_incd_endgame_m)
						(set osa_incd_current_m intf_incd_endgame_m)
						(set intf_music_sleep (* 30 60 30)) ;; play 30 minutes.
						(set intf_music_playing true)
					)
				)
				((survival_mode_current_wave_is_initial)
					(begin 
						(osa_incd_force_music_switch intf_incd_wave_m)
						(set osa_incd_current_m intf_incd_wave_m)
						(set intf_music_sleep (* 30 60 2)) ;; play 2 minutes
						(set intf_music_playing true)
					)
				)
				((survival_mode_current_wave_is_boss)
					(begin 
						(osa_incd_force_music_switch intf_incd_round_m)
						(set osa_incd_current_m intf_incd_round_m)
						(set intf_music_sleep (* 30 60 2)) ;; play 2 minutes
						(set intf_music_playing true)
					)
				)
			)
			FALSE
		)
	)
)

;------------------------------------- MUSIC SCRIPTS -------------------------------------------------------------------------

; === ANIMATIONS ===


; (script static void (osa_incident_civ_transport (device obj_dm))
;     (device_set_position_track obj_dm "m50_starport_escape" 0)
;     (device_animate_position obj_dm 1.0 33.33 .1 .1 false);1000 frames
;     (sleep_until (>= (device_get_position obj_dm) 0.307273) 1)
;     (effect_new_on_object_marker levels\solo\m50\fx\civilian_ship_crash\covenant_weapon_fire\covenant_weapon_fire obj_dm "")
; )

;=============================================================================================================================
;============================================ ANNOUNCEMENT SCRIPTS ===========================================================
;=============================================================================================================================

;===================================== BEGIN ANNOUNCER =======================================================================

; this script assumes that at the start of a SET the rounds and waves are set to -- 0 -- 
; also, at the start of a ROUND waves are set to -- 0 -- 


; 0 default, 1 new, 2 end. ;; For fuk sake, conserve variable pointers and just use more memory. ITS A PC!!!!!
(global short s_survival_state_set 0)
(global short s_survival_state_round 0)
(global short s_survival_state_wave 0)
(global short s_survival_state_lives 0)

;; use a state machine to manage inbound-outbound waves.
(script dormant routine_incd_announcer
	(sleep_until 
		(begin 
			(if (= s_survival_state_wave 2) ;; main loop has marked the end of a wave.
				(begin 
					(survival_mode_end_wave)
					(if (< (survival_mode_wave_get) 5)
						(set s_survival_state_wave 2) ;; leave as is
						(begin 
							(if (< (survival_mode_round_get) 3)
								(set s_survival_state_round 2)
								(begin 
									(survival_mode_end_set)
									(set s_survival_state_set 2)
								)
							)
						)
					)
					(intf_incd_stop_current_music) ; Stop music
				)
			)
			(if (= s_survival_state_wave 1)
				(if (and (survival_mode_current_wave_is_initial) (= (survival_mode_round_get) 0))
					(begin (set s_survival_state_set 1)) ; start set instead
					(begin 
						(print_if dbg_incidents "announce new wave...")
						(survival_mode_begin_new_wave)
						(if (not (survival_mode_current_wave_is_initial)) ; TODO make sure this is correct (updated for 0 index)
							(begin
								; attempt to award the hero medal 
								(survival_mode_award_hero_medal)
									(sleep 1)
									
								; respawn dead players (WE DO NOT ADD LIVES HERE) 
								(event_survival_reinforcements)
								(survival_mode_respawn_dead_players)
									(sleep (* (random_range 3 5) 30))
							)
							(set s_survival_state_round 1)
						)
						(set s_survival_state_wave 0)
					)
				)
			)
			(if (and (= s_survival_state_round 1) (= (survival_mode_round_get) 0))
				(begin 
					(set s_survival_state_set 1); start set instead
					(set s_survival_state_round 0)
				)
			)
			(if (= s_survival_state_set 1)
				(begin 
					(print_if dbg_incidents "announce new set...")
					(survival_mode_begin_new_wave)
					(event_countdown_timer)
					(event_survival_new_set)
					(set s_survival_state_set 0)

				)
			)
			(if (= s_survival_state_round 1)
				(begin 
					(print_if dbg_incidents "announce new round...")
					(event_countdown_timer)
					(event_survival_new_round)
					(set s_survival_state_round 0)
				)
			)
			(if (= s_survival_state_set 2)
				(begin 
					(print_if dbg_incidents "announce end set...")
					(event_survival_end_set)
					(set s_survival_state_set 0)

				)
			)
			(if (= s_survival_state_round 2)
				(begin 
					(print_if dbg_incidents "announce end round...")
					(event_survival_end_round)
					(set s_survival_state_round 0)

				)
			)
			(if (= s_survival_state_wave 2)
				(begin 
					(print_if dbg_incidents "announce end wave...")
					(set s_survival_state_wave 0)

				)
			)

			;; announce lives state
			(if (or (= s_survival_state_lives 0) (> (survival_mode_lives_get player) 5))
				(set s_survival_state_lives 1)
			)
			(if (= s_survival_state_lives 1)
				(if (and (<= (survival_mode_lives_get player) 5) (>= (survival_mode_lives_get player) 0) )
					(begin 
						(print_if dbg_incidents "5 lives left...")
						(event_survival_5_lives_left)
						(set s_survival_state_lives 2)
					)
				)
			)
			(if (= s_survival_state_lives 2)
				(if (and (<= (survival_mode_lives_get player) 1) (>= (survival_mode_lives_get player) 0) )
					(begin 
						(print_if dbg_incidents "1 life left...")
						(event_survival_1_life_left)
						(set s_survival_state_lives 3)
					)
				)
			)
			(if (= s_survival_state_lives 3)
				(if (= (survival_mode_lives_get player) 0) 
					(begin 
						(print_if dbg_incidents "0 lives left...")
						(event_survival_0_lives_left)
						(set s_survival_state_lives 4)
					)
				)
			)
			(if (= s_survival_state_lives 4)
				(if (= (players_human_living_count) 1)
					(begin 
						(print_if dbg_incidents "last man standing...")
						(event_survival_last_man_standing)
						(set s_survival_state_lives 5) ;; exit fsm lol. this was bug.
					)
				)
			)
			(if (and (> s_survival_state_lives 1) (> (survival_mode_lives_get player) 1))
				(set s_survival_state_lives 2)
			)
			FALSE
		)
	30) ; sleep one second intervals.
)


;------------------------------------- END ANNOUNCER -------------------------------------------------------------------------


; == Weather events.

(script dormant routine_wea_dst_thunder
	(sleep_until 
		(begin 
			(begin_random_count 1
				(begin 
					(sound_impulse_start sound\levels\solo\weather\thunder_claps.sound NONE 1)
					(sleep (* 30 2.5))
					(sound_impulse_start sound\levels\solo\weather\rain\details\thunder.sound NONE 1)
				)
				(begin 
					(sound_impulse_start sound\levels\solo\weather\rain\details\thunder.sound NONE 1)
				)
				(begin 
					(sound_impulse_start sound\levels\solo\weather\rain\details\thunder.sound NONE 1)
				)
				(begin 
					(sound_impulse_start sound\levels\solo\weather\rain\details\thunder.sound NONE 1)
				)
				(begin 
					(sound_impulse_start sound\levels\solo\weather\rain\details\thunder.sound NONE 1)
				)
				(begin 
					(sound_impulse_start sound\levels\solo\weather\rain\details\thunder.sound NONE 1)
				)
			)
			FALSE
		)
		(random_range (* 30 60) (* 30 60 2))
	)
	
	
)
