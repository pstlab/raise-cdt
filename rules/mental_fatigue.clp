(defrule mental_fatigue
    (RAISE-User (item_id ?user) (baseline_nutrition ?baseline_nutrition)
          (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
          (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)
          (ANXIETY ?ANXIETY) (crowding ?crowding) (altered_nutrition ?altered_nutrition)
          (water_balance ?water_balance) (sleep_duration_quality ?sleep_duration_quality)
          (lighting ?lighting) (noise_pollution ?noise_pollution) (user_reported_noise_pollution ?user_reported_noise_pollution)
          (air_pollution ?air_pollution) (rough_path ?rough_path) (ambient_temperature ?ambient_temperature))
=>
    (bind ?mental_fatigue 0)
    (bind ?mental_fatigue_message "")

    (if (and (or (eq ?parkinson TRUE) (eq ?older_adults TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?crowding nil) (>= ?crowding 2)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Crowding increases mental fatigue. "))
    )
    (if (and (or (eq ?parkinson TRUE) (eq ?young_pci_autism TRUE)) (neq ?altered_nutrition nil) ?altered_nutrition) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Altered nutrition increases mental fatigue. "))
    )
    (if (and (or (eq ?parkinson TRUE) ?baseline_nutrition) (neq ?baseline_nutrition nil) ?baseline_nutrition) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Poor baseline nutrition increases mental fatigue. "))
    )
    (if (and (eq ?parkinson TRUE) (neq ?ANXIETY low)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Anxiety increases mental fatigue. "))
    )
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE)) (neq ?water_balance nil) (< ?water_balance 1)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Low water balance increases mental fatigue. "))
    )
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?sleep_duration_quality nil) (< ?sleep_duration_quality 6)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Poor sleep quality increases mental fatigue. "))
    )
    (if (and (or (eq ?parkinson TRUE) (eq ?young_pci_autism TRUE)) (neq ?lighting nil) ?lighting) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Poor lighting increases mental fatigue. "))
    )
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?noise_pollution nil) (> ?noise_pollution 45)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "High noise pollution increases mental fatigue. "))
    )
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?user_reported_noise_pollution nil) (> ?user_reported_noise_pollution 45)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "User-reported high noise pollution increases mental fatigue. "))
    )
    (if (and (eq ?older_adults TRUE) (neq ?air_pollution nil) (> ?air_pollution 5)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "High air pollution increases mental fatigue. "))
    )
    (if (and (eq ?older_adults TRUE) (neq ?rough_path nil) ?rough_path) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "Rough paths increase mental fatigue. "))
    )
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?ambient_temperature nil) (> ?ambient_temperature 27)) then
        (bind ?mental_fatigue (+ ?mental_fatigue 1))
        (bind ?mental_fatigue_message (str-cat ?mental_fatigue_message "High ambient temperature increases mental fatigue. "))
    )

    (printout t "User: " ?user crlf)
    (printout t "Mental Fatigue: " ?mental_fatigue crlf)

    (if (and (>= ?mental_fatigue 0) (<= ?mental_fatigue 1)) then (add_data ?user (create$ MENTAL_FATIGUE) (create$ low)))
    (if (and (>= ?mental_fatigue 2) (<= ?mental_fatigue 3)) then (add_data ?user (create$ MENTAL_FATIGUE) (create$ medium)))
    (if (>= ?mental_fatigue 4) then
        (add_data ?user (create$ MENTAL_FATIGUE mental_fatigue_message) (create$ high ?mental_fatigue_message))
        (send_notification ?user "High mental fatigue" "Multiple factors are contributing to high mental fatigue")
    )
)