(defrule raise
    (RAISE-User (item_id ?user)
        (baseline_fall ?baseline_fall) (baseline_freezing ?baseline_freezing) (baseline_heart_rate ?baseline_heart_rate)
        (state_anxiety_presence ?state_anxiety_presence) (baseline_blood_pressure ?baseline_blood_pressure)
        (sensory_profile ?sensory_profile) (stress ?stress) (psychiatric_disorders ?psychiatric_disorders)
        (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
        (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)

        (ANXIETY ?ANXIETY) (EXCESSIVE_HEAT ?EXCESSIVE_HEAT) (MENTAL_FATIGUE ?MENTAL_FATIGUE) (PHYSICAL_FATIGUE ?PHYSICAL_FATIGUE) (SENSORY_DYSREGULATION ?SENSORY_DYSREGULATION) (FREEZING ?FREEZING) (FLUCTUATION ?FLUCTUATION) (DYSKINESIA ?DYSKINESIA)

        (crowding ?crowding) (altered_nutrition ?altered_nutrition) (altered_thirst_perception ?altered_thirst_perception)
        (bar_restaurant ?bar_restaurant) (architectural_barriers ?architectural_barriers)
        (water_balance ?water_balance) (sleep_duration_quality ?sleep_duration_quality) (water_fountains ?water_fountains)
        (recent_freezing_episodes ?recent_freezing_episodes) (heart_rate ?heart_rate) (heart_rate_differential ?heart_rate_differential)
        (public_events_frequency ?public_events_frequency) (respiratory_rate ?respiratory_rate) (galvanic_skin_response ?galvanic_skin_response)
        (lighting ?lighting) (noise_pollution ?noise_pollution) (user_reported_noise_pollution ?user_reported_noise_pollution)
        (air_pollution ?air_pollution) (traffic_levels ?traffic_levels) (lack_of_ventilation ?lack_of_ventilation)
        (path_slope ?path_slope) (safety_perception ?safety_perception) (rough_path ?rough_path) (public_events_presence ?public_events_presence)
        (high_blood_pressure ?high_blood_pressure) (low_blood_pressure ?low_blood_pressure)
        (social_pressure ?social_pressure) (sittings ?sittings) (self_perception ?self_perception) (restroom_availability ?restroom_availability)
        (sweating ?sweating) (ambient_temperature ?ambient_temperature) (body_temperature ?body_temperature) (ambient_humidity ?ambient_humidity)
        (excessive_urbanization ?excessive_urbanization) (green_spaces ?green_spaces)
    )
=>
    (bind ?anxiety 0)
    (bind ?anxiety_relevant (create$))
    (bind ?anxiety_message "")

    (bind ?dyskinesia 0)
    (bind ?dyskinesia_message "")

    (bind ?excessive_heat 0)
    (bind ?excessive_heat_relevant (create$))
    (bind ?excessive_heat_message "")

    (bind ?fluctuation 0)
    (bind ?fluctuation_message "")

    (bind ?freezing 0)
    (bind ?freezing_relevant (create$))
    (bind ?freezing_message "")

    (bind ?mental_fatigue 0)
    (bind ?mental_fatigue_message "")

    (bind ?physical_fatigue 0)
    (bind ?physical_fatigue_relevant (create$))
    (bind ?physical_fatigue_message "")

    (bind ?sensory_dysregulation 0)
    (bind ?sensory_dysregulation_relevant (create$))
    (bind ?sensory_dysregulation_message "")

    ; ANXIETY
    (if (and (eq ?parkinson TRUE) (neq ?ANXIETY low)) then
        (bind ?dyskinesia (+ ?dyskinesia 1))
        (bind ?dyskinesia_message (str-cat ?dyskinesia_message "Anxiety contributes to dyskinesia. "))
        (bind ?fluctuation (+ ?fluctuation 1))
        (bind ?fluctuation_message (str-cat ?fluctuation_message "Anxiety contributes to fluctuation. "))
        (bind ?freezing (+ ?freezing 1))
        (bind ?freezing_message (str-cat ?freezing_message "Anxiety increases freezing of gait. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Anxiety increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Anxiety increases physical fatigue. "))
    )
    ; FREEZING
    (if (and (eq ?parkinson TRUE) (neq ?FREEZING low)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Freezing of gait increases anxiety. "))
    )
    ; Crowding
    (if (and (or (eq ?parkinson TRUE) (eq ?older_adults TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?crowding nil) (>= ?crowding 2)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Crowding increases anxiety. "))
        (bind ?excessive_heat (+ ?excessive_heat 1))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Crowding increases heat stress. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Crowding increases mental fatigue. "))
        (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1))
        (bind ?sensory_dysregulation_message (str-cat ?sensory_dysregulation_message "Crowding increases sensory dysregulation. "))
    )
    ; Altered nutrition
    (if (and (or (eq ?parkinson TRUE) (eq ?young_pci_autism TRUE)) (neq ?altered_nutrition nil) ?altered_nutrition) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Altered nutrition increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Altered nutrition increases physical fatigue. "))
    )
    ; Altered thirst perception
    (if (and (eq ?psychiatric_patients TRUE) (neq ?altered_thirst_perception nil) (>= ?altered_thirst_perception 3)) then
        (bind ?excessive_heat (+ ?excessive_heat 1))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Altered thirst perception increases heat stress. "))
    )
    ; Architectural barriers
    (if (and (eq ?parkinson TRUE) (neq ?architectural_barriers nil) ?architectural_barriers) then
        (bind ?freezing (+ ?freezing 1))
        (bind ?freezing_message (str-cat ?freezing_message "Architectural barriers increase freezing of gait. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Architectural barriers increase physical fatigue. "))
    )
    ; Water balance
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE)) (neq ?water_balance nil) (< ?water_balance 1)) then
        (bind ?excessive_heat (+ ?excessive_heat 1))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Low water balance increases heat stress. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Low water balance increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Low water balance increases physical fatigue. "))
    )
    ; Sleep duration/quality
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?sleep_duration_quality nil) (< ?sleep_duration_quality 6)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Poor sleep quality increases anxiety. "))
        (bind ?excessive_heat (+ ?excessive_heat 1))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Poor sleep quality increases heat stress. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Poor sleep quality increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Poor sleep quality increases physical fatigue. "))
    )
    ; Heart rate
    (if (and (or (eq ?parkinson TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?heart_rate nil) (>= ?heart_rate 100)) then
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "High heart rate increases physical fatigue. "))
        (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1))
        (bind ?sensory_dysregulation_message (str-cat ?sensory_dysregulation_message "High heart rate increases sensory dysregulation. "))
    )
    ; Heart rate differential
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?young_pci_autism TRUE) (eq ?parkinson TRUE) (eq ?multiple_sclerosis TRUE)) (neq ?heart_rate_differential nil) (>= ?heart_rate_differential 50)) then
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "High heart rate differential increases physical fatigue. "))
    )
    ; Public events frequency
    (if (and (eq ?psychiatric_patients TRUE) (neq ?public_events_frequency nil) ?public_events_frequency) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Frequent public events increase anxiety. "))
    )
    ; Lighting
    (if (and (or (eq ?parkinson TRUE) (eq ?young_pci_autism TRUE)) (neq ?lighting nil) ?lighting) then
        (bind ?freezing (+ ?freezing 1))
        (bind ?freezing_message (str-cat ?freezing_message "Poor lighting increases freezing of gait. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Poor lighting increases mental fatigue. "))
        (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1))
        (bind ?sensory_dysregulation_message (str-cat ?sensory_dysregulation_message "Poor lighting increases sensory dysregulation. "))
    )
    ; Noise pollution
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?noise_pollution nil) (> ?noise_pollution 45)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "High noise pollution increases anxiety. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "High noise pollution increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "High noise pollution increases physical fatigue. "))
        (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1))
        (bind ?sensory_dysregulation_message (str-cat ?sensory_dysregulation_message "High noise pollution increases sensory dysregulation. "))
    )
    ; User-reported noise pollution
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?user_reported_noise_pollution nil) (> ?user_reported_noise_pollution 45)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "User-reported high noise pollution increases anxiety. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "User-reported high noise pollution increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "User-reported high noise pollution increases physical fatigue. "))
        (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1))
        (bind ?sensory_dysregulation_message (str-cat ?sensory_dysregulation_message "User-reported high noise pollution increases sensory dysregulation. "))
    )
    ; Air pollution
    (if (and (eq ?older_adults TRUE) (neq ?air_pollution nil) (> ?air_pollution 5)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "High air pollution increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "High air pollution increases physical fatigue. "))
    )
    ; Traffic levels
    (if (and (eq ?psychiatric_patients TRUE) (neq ?traffic_levels nil) (> ?traffic_levels 50)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "High traffic levels increase anxiety. "))
    )
    ; Lack of ventilation
    (if (and (eq ?psychiatric_patients TRUE) (neq ?lack_of_ventilation nil) (> ?lack_of_ventilation 1000)) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Poor ventilation increases anxiety. "))
    )
    ; Path slope
    (if (and (eq ?multiple_sclerosis TRUE) (neq ?path_slope nil) ?path_slope) then
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Path slope increases physical fatigue. "))
    )
    ; Safety perception
    (if (and (eq ?older_adults TRUE) (neq ?safety_perception nil) ?safety_perception) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Low safety perception increases anxiety. "))
    )
    ; Rough path
    (if (and (eq ?older_adults TRUE) (neq ?rough_path nil) ?rough_path) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Rough paths increase anxiety. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Rough paths increase mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Rough paths increase physical fatigue. "))
    )
    ; Public events presence
    (if (and (eq ?older_adults TRUE) (neq ?public_events_presence nil) ?public_events_presence) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Presence of public events increases anxiety. "))
    )
    ; Low blood pressure
    (if (and (eq ?parkinson TRUE) (neq ?low_blood_pressure nil) (< ?low_blood_pressure 90)) then
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Low blood pressure increases physical fatigue. "))
    )
    ; Social pressure
    (if (and (eq ?multiple_sclerosis TRUE) (neq ?social_pressure nil) ?social_pressure) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Social pressure increases anxiety. "))
    )
    ; Ambient temperature
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?ambient_temperature nil) (> ?ambient_temperature 27)) then
        (bind ?excessive_heat (+ ?excessive_heat 1))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "High ambient temperature increases heat stress. "))
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "High ambient temperature increases mental fatigue. "))
        (bind ?physical_fatigue (+ ?physical_fatigue 1))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "High ambient temperature increases physical fatigue. "))
    )
    ; Ambient humidity
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?older_adults TRUE)) (neq ?ambient_humidity nil) (> ?ambient_humidity 60)) then
        (bind ?excessive_heat (+ ?excessive_heat 1))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "High ambient humidity increases heat stress. "))
    )
    ; Excessive urbanization
    (if (and (eq ?older_adults TRUE) (neq ?excessive_urbanization nil) ?excessive_urbanization) then
        (bind ?anxiety (+ ?anxiety 1))
        (bind ?anxiety_message (str-cat ?anxiety_message "Excessive urbanization increases anxiety. "))
        (bind ?excessive_heat (+ ?excessive_heat 1))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Excessive urbanization increases heat stress. "))
    )

    ; Bar/restaurant
    (if (and (eq ?psychiatric_patients TRUE) ?bar_restaurant) then
        (bind ?physical_fatigue_relevant (insert$ ?physical_fatigue_relevant 1 bar_restaurant))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Might go to a bar/restaurant to relax and have a drink, which can help reduce physical fatigue. "))
    )
    ; Water balance
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE)) (neq ?water_balance nil) (< ?water_balance 1)) then
        (bind ?excessive_heat_relevant (insert$ ?excessive_heat_relevant 1 water_balance))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Increase water intake to improve water balance and reduce heat stress. "))
    )
    ; Water fountains
    (if (and (eq ?psychiatric_patients TRUE) (neq ?water_fountains nil) ?water_fountains) then
        (bind ?physical_fatigue_relevant (insert$ ?physical_fatigue_relevant 1 water_fountains))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Water fountains are available in the area, which can help reduce physical fatigue. "))
    )
    ; Recent freezing episodes
    (if (and (eq ?parkinson TRUE) (neq ?recent_freezing_episodes nil) (>= ?recent_freezing_episodes 3)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 recent_freezing_episodes))
        (bind ?anxiety_message (str-cat ?anxiety_message "Recent freezing episodes can increase anxiety. "))
    )
    ; Heart rate
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?heart_rate nil) (>= ?heart_rate 100)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 heart_rate))
        (bind ?anxiety_message (str-cat ?anxiety_message "Reduce activities that increase heart rate to help reduce anxiety. "))
        (bind ?physical_fatigue_relevant (insert$ ?physical_fatigue_relevant 1 heart_rate))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Reduce activities that increase heart rate to help reduce physical fatigue. "))
    )
    ; Heart rate differential
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?young_pci_autism TRUE) (eq ?parkinson TRUE) (eq ?multiple_sclerosis TRUE)) (neq ?heart_rate_differential nil) (>= ?heart_rate_differential 50)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 heart_rate_differential))
        (bind ?anxiety_message (str-cat ?anxiety_message "Engage in relaxing activities to help reduce heart rate differential and anxiety. "))
        (bind ?excessive_heat_relevant (insert$ ?excessive_heat_relevant 1 heart_rate_differential))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Engage in relaxing activities to help reduce heart rate differential and heat stress. "))
        (bind ?freezing_relevant (insert$ ?freezing_relevant 1 heart_rate_differential))
        (bind ?freezing_message (str-cat ?freezing_message "Engage in relaxing activities to help reduce heart rate differential and freezing of gait. "))
    )
    ; Respiratory rate
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?older_adults TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?respiratory_rate nil) (>= ?respiratory_rate 30)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 respiratory_rate))
        (bind ?anxiety_message (str-cat ?anxiety_message "Practice deep breathing exercises to help reduce respiratory rate and anxiety. "))
        (bind ?physical_fatigue_relevant (insert$ ?physical_fatigue_relevant 1 respiratory_rate))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Practice deep breathing exercises to help reduce respiratory rate and physical fatigue. "))
        (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 respiratory_rate))
        (bind ?sensory_dysregulation_message (str-cat ?sensory_dysregulation_message "Practice deep breathing exercises to help reduce respiratory rate and sensory dysregulation. "))
    )
    ; Galvanic skin response
    (if (and (eq ?psychiatric_patients TRUE) (neq ?galvanic_skin_response nil) (>= ?galvanic_skin_response 50)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 galvanic_skin_response))
        (bind ?anxiety_message (str-cat ?anxiety_message "Engage in relaxing activities to help reduce galvanic skin response and anxiety. "))
        (bind ?excessive_heat_relevant (insert$ ?excessive_heat_relevant 1 galvanic_skin_response))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Engage in relaxing activities to help reduce galvanic skin response and heat stress. "))
    )
    ; High blood pressure
    (if (and (eq ?older_adults TRUE) (neq ?high_blood_pressure nil) (>= ?high_blood_pressure 100)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 high_blood_pressure))
        (bind ?anxiety_message (str-cat ?anxiety_message "High blood pressure can increase anxiety. "))
    )
    ; Low blood pressure
    (if (and (eq ?parkinson TRUE) (neq ?low_blood_pressure nil) (< ?low_blood_pressure 90)) then
        (bind ?excessive_heat_relevant (insert$ ?excessive_heat_relevant 1 low_blood_pressure))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Improve blood pressure to help reduce heat stress. "))
    )
    ; Sittings
    (if (and (eq ?psychiatric_patients TRUE) (neq ?sittings nil) ?sittings) then
        (bind ?physical_fatigue_relevant (insert$ ?physical_fatigue_relevant 1 sittings))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Sittings are available in the area, which can help reduce physical fatigue. "))
    )
    ; Self-perception
    (if (and (eq ?multiple_sclerosis TRUE) (neq ?self_perception nil) ?self_perception) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 self_perception))
        (bind ?anxiety_message (str-cat ?anxiety_message "Positive self-perception can help reduce anxiety. "))
    )
    ; Restroom availability
    (if (and (eq ?psychiatric_patients TRUE) (neq ?restroom_availability nil) ?restroom_availability) then
        (bind ?physical_fatigue_relevant (insert$ ?physical_fatigue_relevant 1 restroom_availability))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Restrooms are available in the area, which can help reduce physical fatigue. "))
    )
    ; Sweating
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE)) (neq ?sweating nil) (>= ?sweating 10)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 sweating))
        (bind ?anxiety_message (str-cat ?anxiety_message "Excessive sweating can increase anxiety. "))
        (bind ?excessive_heat_relevant (insert$ ?excessive_heat_relevant 1 sweating))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "Excessive sweating can increase heat stress. "))
    )
    ; Body temperature
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?older_adults TRUE) (eq ?parkinson TRUE)) (neq ?body_temperature nil) (> ?body_temperature 37.3)) then
        (bind ?anxiety_relevant (insert$ ?anxiety_relevant 1 body_temperature))
        (bind ?anxiety_message (str-cat ?anxiety_message "High body temperature can increase anxiety. "))
        (bind ?excessive_heat_relevant (insert$ ?excessive_heat_relevant 1 body_temperature))
        (bind ?excessive_heat_message (str-cat ?excessive_heat_message "High body temperature can increase heat stress. "))
    )
    ; Green spaces
    (if (and (eq ?psychiatric_patients TRUE) (neq ?green_spaces nil) ?green_spaces) then
        (bind ?physical_fatigue_relevant (insert$ ?physical_fatigue_relevant 1 green_spaces))
        (bind ?physical_fatigue_message (str-cat ?physical_fatigue_message "Green spaces are available in the area, which can help reduce physical fatigue. "))
    )

    (bind ?final_anxiety low)
    (if (and (>= ?anxiety 2) (<= ?anxiety 3)) then (bind ?final_anxiety medium))
    (if (>= ?anxiety 4) then (bind ?final_anxiety high))

    (bind ?final_dyskinesia low)
    (if (and (>= ?dyskinesia 2) (<= ?dyskinesia 3)) then (bind ?final_dyskinesia medium))
    (if (>= ?dyskinesia 4) then (bind ?final_dyskinesia high))

    (bind ?final_excessive_heat low)
    (if (and (>= ?excessive_heat 2) (<= ?excessive_heat 3)) then (bind ?final_excessive_heat medium))
    (if (>= ?excessive_heat 4) then (bind ?final_excessive_heat high))

    (bind ?final_fluctuation low)
    (if (and (>= ?fluctuation 2) (<= ?fluctuation 3)) then (bind ?final_fluctuation medium))
    (if (>= ?fluctuation 4) then (bind ?final_fluctuation high))

    (bind ?final_freezing low)
    (if (and (>= ?freezing 2) (<= ?freezing 3)) then (bind ?final_freezing medium))
    (if (>= ?freezing 4) then (bind ?final_freezing high))

    (bind ?final_mental_fatigue low)
    (if (and (>= ?mental_fatigue 2) (<= ?mental_fatigue 3)) then (bind ?final_mental_fatigue medium))
    (if (>= ?mental_fatigue 4) then (bind ?final_mental_fatigue high))

    (bind ?final_physical_fatigue low)
    (if (and (>= ?physical_fatigue 2) (<= ?physical_fatigue 3)) then (bind ?final_physical_fatigue medium))
    (if (>= ?physical_fatigue 4) then (bind ?final_physical_fatigue high))

    (bind ?final_sensory_dysregulation low)
    (if (and (>= ?sensory_dysregulation 2) (<= ?sensory_dysregulation 3)) then (bind ?final_sensory_dysregulation medium))
    (if (>= ?sensory_dysregulation 4) then (bind ?final_sensory_dysregulation high))

    (add_data ?user
        (create$ ANXIETY anxiety_relevant anxiety_message DYSKINESIA dyskinesia_message EXCESSIVE_HEAT excessive_heat_relevant excessive_heat_message FLUCTUATION fluctuation_message FREEZING freezing_relevant freezing_message MENTAL_FATIGUE mental_fatigue_message PHYSICAL_FATIGUE physical_fatigue_relevant physical_fatigue_message SENSORY_DYSREGULATION sensory_dysregulation_relevant sensory_dysregulation_message)
        (create$ ?final_anxiety (to_json ?anxiety_relevant) ?anxiety_message ?final_dyskinesia ?dyskinesia_message ?final_excessive_heat (to_json ?excessive_heat_relevant) ?excessive_heat_message ?final_fluctuation ?fluctuation_message ?final_freezing (to_json ?freezing_relevant) ?freezing_message ?final_mental_fatigue ?mental_fatigue_message ?final_physical_fatigue (to_json ?physical_fatigue_relevant) ?physical_fatigue_message ?final_sensory_dysregulation (to_json ?sensory_dysregulation_relevant) ?sensory_dysregulation_message)
    )

    (if (and (or (eq ?ANXIETY high) (eq ?DYSKINESIA high) (eq ?EXCESSIVE_HEAT high) (eq ?FLUCTUATION high) (eq ?FREEZING high) (eq ?MENTAL_FATIGUE high) (eq ?PHYSICAL_FATIGUE high) (eq ?SENSORY_DYSREGULATION high)) (empty_agenda)) then
        (send_notification ?user "Attenzione!" (understand (str-cat "You are a support system for citizens. Based on the following analysis, provide a brief message in italian, a few sentences, to help reduce the identified issues. No comments, just the message. " ?anxiety_message ?dyskinesia_message ?excessive_heat_message ?fluctuation_message ?freezing_message ?mental_fatigue_message ?physical_fatigue_message ?sensory_dysregulation_message)))
    )
)