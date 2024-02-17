; Copyright 2024 Yon-Sunjawn-Marten

; Firefight events/incidents go here as utils.

(global boolean dbg_incidents FALSE)

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
)

(script static void (submit_incident_for_elites (string_id incident))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 0))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 1))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 2))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 3))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 4))
	(submit_incident_with_cause_player incident (elite_player_in_game_get 5))
)

(script static void event_welcome
	(print_if dbg_incidents "event_welcome")
	(submit_incident "survival_welcome")
)

(script static void event_intro
	(print_if dbg_incidents "event_intro")

	; Announce the appropriate Firefight gametype
	(if (> (survival_mode_generator_count) 0)
		(begin
			(submit_incident_with_cause_campaign_team "sur_gen_unsc_start" player)
			(submit_incident_with_cause_campaign_team "sur_gen_cov_start" covenant_player)
		)
		(begin
			(submit_incident_with_cause_campaign_team "sur_cla_unsc_start" player)
			(submit_incident_with_cause_campaign_team "sur_cla_cov_start" covenant_player)
		)
	)
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

; music definitions 
(global looping_sound m_survival_start	"firefight\firefight_music\firefight_music01")
(global looping_sound m_new_set			"firefight\firefight_music\firefight_music01")
(global looping_sound m_initial_wave	"firefight\firefight_music\firefight_music02")
(global looping_sound m_final_wave		"firefight\firefight_music\firefight_music20")

(script static void surival_set_music

	; set initial music 
	(begin_random_count 1
		(set m_initial_wave "firefight\firefight_music\firefight_music02")
		(set m_initial_wave "firefight\firefight_music\firefight_music03")
		(set m_initial_wave "firefight\firefight_music\firefight_music04")
		(set m_initial_wave "firefight\firefight_music\firefight_music05")
		(set m_initial_wave "firefight\firefight_music\firefight_music06")
	)

	; set final music 
	(begin_random_count 1
		(set m_final_wave "firefight\firefight_music\firefight_music20")
		(set m_final_wave "firefight\firefight_music\firefight_music21")
		(set m_final_wave "firefight\firefight_music\firefight_music22")
		(set m_final_wave "firefight\firefight_music\firefight_music23")
		(set m_final_wave "firefight\firefight_music\firefight_music24")
	)
)


(script static void survival_mode_wave_music_start
	(cond
		((survival_mode_current_wave_is_initial) 	(sound_looping_start m_initial_wave NONE 1))
		((survival_mode_current_wave_is_boss) 		(sound_looping_start m_final_wave NONE 1))		
	)
)


(script static void survival_mode_wave_music_stop
	(cond
		((survival_mode_current_wave_is_initial) 	(sound_looping_stop m_initial_wave))
		((survival_mode_current_wave_is_boss) 		(sound_looping_stop m_final_wave))		
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