(defrule anxiety
    (RAISE-User (item_id ?user) (baseline_fall ?baseline_fall) (baseline_freezing ?baseline_freezing) (baseline_heart_rate ?baseline_heart_rate)
          (state_anxiety_presence ?state_anxiety_presence) (stress ?stress) (psychiatric_disorders ?psychiatric_disorders)
          (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
          (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)
          (FREEZING ?FREEZING) (crowding ?crowding) (sleep_duration_quality ?sleep_duration_quality)
          (recent_freezing_episodes ?recent_freezing_episodes) (heart_rate ?heart_rate)
          (heart_rate_differential ?heart_rate_differential) (public_events_frequency ?public_events_frequency)
          (respiratory_rate ?respiratory_rate) (galvanic_skin_response ?galvanic_skin_response)
          (noise_pollution ?noise_pollution) (user_reported_noise_pollution ?user_reported_noise_pollution)
          (traffic_levels ?traffic_levels) (lack_of_ventilation ?lack_of_ventilation)
          (safety_perception ?safety_perception) (rough_path ?rough_path)
          (public_events_presence ?public_events_presence) (high_blood_pressure ?high_blood_pressure)
          (social_pressure ?social_pressure) (self_perception ?self_perception)
          (sweating ?sweating) (body_temperature ?body_temperature)
          (excessive_urbanization ?excessive_urbanization))
=>
    (printout t "Updating anxiety!" crlf)
    (bind ?anxiety 0)
    (bind ?anxiety_relevant (create$))
    (bind ?anxiety_message "")

    (if (and (or (eq ?parkinson TRUE) (eq ?older_adults TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?crowding nil) (>= ?crowding 2)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Crowding increases anxiety. "))
    )
    (if (and (eq ?parkinson TRUE) (neq ?baseline_fall nil) (>= ?baseline_fall 6)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Frequent falls increase anxiety. "))
    )
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?sleep_duration_quality nil) (< ?sleep_duration_quality 6)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Poor sleep quality increases anxiety. "))
    )
    (if (and (eq ?parkinson TRUE) (neq ?FREEZING low)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Freezing of gait increases anxiety. "))
    )
    (if (and (eq ?psychiatric_patients TRUE) (neq ?public_events_frequency nil) ?public_events_frequency) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Frequent public events increase anxiety. "))
    )
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?noise_pollution nil) (> ?noise_pollution 45)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "High noise pollution increases anxiety. "))
    )
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?user_reported_noise_pollution nil) (> ?user_reported_noise_pollution 45)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "User-reported high noise pollution increases anxiety. "))
    )
    (if (and (eq ?psychiatric_patients TRUE) (neq ?traffic_levels nil) (> ?traffic_levels 50)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "High traffic levels increase anxiety. "))
    )
    (if (and (eq ?psychiatric_patients TRUE) (neq ?lack_of_ventilation nil) (> ?lack_of_ventilation 1000)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Poor ventilation increases anxiety. "))
    )
    (if (and (eq ?older_adults TRUE) (neq ?safety_perception nil) ?safety_perception) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Low safety perception increases anxiety. "))
    )
    (if (and (eq ?older_adults TRUE) (neq ?rough_path nil) ?rough_path) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Rough paths increase anxiety. "))
    )
    (if (and (eq ?older_adults TRUE) (neq ?public_events_presence nil) ?public_events_presence) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Presence of public events increases anxiety. "))
    )
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?parkinson TRUE) (eq ?older_adults TRUE)) (neq ?state_anxiety_presence nil) ?state_anxiety_presence) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "State anxiety presence increases anxiety. "))
    )
    (if (and (eq ?multiple_sclerosis TRUE) (neq ?social_pressure nil) ?social_pressure) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Social pressure increases anxiety. "))
    )
    (if (and (eq ?older_adults TRUE) (neq ?stress nil) (> ?stress 27)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "High stress levels increase anxiety. "))
    )
    (if (and (eq ?older_adults TRUE) (neq ?excessive_urbanization nil) ?excessive_urbanization) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Excessive urbanization increases anxiety. "))
    )
    (if (and (eq ?psychiatric_patients TRUE) (neq ?psychiatric_disorders nil) ?psychiatric_disorders) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Existing psychiatric disorders increase anxiety. "))
    )

    (if (and (eq ?parkinson TRUE) (neq ?baseline_freezing nil) ?baseline_freezing) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 baseline_freezing)))
    (if (and (eq ?parkinson TRUE) (neq ?recent_freezing_episodes nil) (>= ?recent_freezing_episodes 3)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 recent_freezing_episodes)))
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?heart_rate nil) (>= ?heart_rate 100)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 heart_rate)))
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?young_pci_autism TRUE)) (neq ?baseline_heart_rate nil) (>= ?baseline_heart_rate 100)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 baseline_heart_rate)))
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?young_pci_autism TRUE) (eq ?parkinson TRUE) (eq ?multiple_sclerosis TRUE)) (neq ?heart_rate_differential nil) (>= ?heart_rate_differential 50)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 heart_rate_differential)))
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?older_adults TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?respiratory_rate nil) (>= ?respiratory_rate 30)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 respiratory_rate)))
    (if (and (eq ?psychiatric_patients TRUE) (neq ?galvanic_skin_response nil) (>= ?galvanic_skin_response 50)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 galvanic_skin_response)))
    (if (and (eq ?older_adults TRUE) (neq ?high_blood_pressure nil) (>= ?high_blood_pressure 100)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 high_blood_pressure)))
    (if (and (eq ?multiple_sclerosis TRUE) (neq ?self_perception nil) ?self_perception) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 self_perception)))
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE)) (neq ?sweating nil) (>= ?sweating 10)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 sweating)))
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?older_adults TRUE) (eq ?parkinson TRUE)) (neq ?body_temperature nil) (> ?body_temperature 37.3)) then (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 body_temperature)))

    (printout t "User: " ?user crlf)
    (printout t "Anxiety: " ?anxiety crlf)
    (printout t "Anxiety Relevant Factors: " ?anxiety_relevant crlf)
    (printout t "Anxiety Message: " ?anxiety_message crlf)

    (if (and (>= ?anxiety 0) (<= ?anxiety 1)) then (add_data ?user (create$ ANXIETY anxiety_relevant) (create$ low (to_json ?anxiety_relevant))))
    (if (and (>= ?anxiety 2) (<= ?anxiety 3)) then (add_data ?user (create$ ANXIETY anxiety_relevant) (create$ medium (to_json ?anxiety_relevant))))
    (if (>= ?anxiety 4) then
        (add_data ?user (create$ ANXIETY anxiety_relevant anxiety_message) (create$ high (to_json ?anxiety_relevant) ?anxiety_message))
        (send_notification ?user "High anxiety" "Multiple factors are contributing to high anxiety")
    )
)