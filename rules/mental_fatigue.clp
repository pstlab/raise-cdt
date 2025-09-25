(defrule mental_fatigue
    (User (item_id ?user) (baseline_nutrition ?baseline_nutrition)
          (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
          (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)
          (ANXIETY ?ANXIETY) (crowding ?crowding) (altered_nutrition ?altered_nutrition)
          (water_balance ?water_balance) (sleep_duration_quality ?sleep_duration_quality)
          (lighting ?lighting) (noise_pollution ?noise_pollution) (user_reported_noise_pollution ?user_reported_noise_pollution)
          (air_pollution ?air_pollution) (rough_path ?rough_path) (ambient_temperature ?ambient_temperature))
=>
    (bind ?mental_fatigue 0)

    (if (and (or ?parkinson ?older_adults ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (neq ?crowding nil) (>= ?crowding 2)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?parkinson ?young_pci_autism) (neq ?altered_nutrition nil) ?altered_nutrition) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?parkinson ?baseline_nutrition) (neq ?baseline_nutrition nil) ?baseline_nutrition) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and ?parkinson (neq ?ANXIETY low)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?parkinson ?psychiatric_patients) (neq ?water_balance nil) (< ?water_balance 1)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?parkinson ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (neq ?sleep_duration_quality nil) (< ?sleep_duration_quality 6)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?parkinson ?young_pci_autism) (neq ?lighting nil) ?lighting) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?older_adults ?parkinson ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (neq ?noise_pollution nil) (> ?noise_pollution 45)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?older_adults ?parkinson ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (neq ?user_reported_noise_pollution nil) (> ?user_reported_noise_pollution 45)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and ?older_adults (neq ?air_pollution nil) (> ?air_pollution 5)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and ?older_adults (neq ?rough_path nil) ?rough_path) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))
    (if (and (or ?parkinson ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (neq ?ambient_temperature nil) (> ?ambient_temperature 27)) then (bind ?mental_fatigue (+ ?mental_fatigue 1)))

    (printout t "User: " ?user crlf)
    (printout t "Mental Fatigue: " ?mental_fatigue crlf)

    (if (and (>= ?mental_fatigue 0) (<= ?mental_fatigue 1)) then (add_data ?user (create$ MENTAL_FATIGUE) (create$ low)))
    (if (and (>= ?mental_fatigue 2) (<= ?mental_fatigue 3)) then (add_data ?user (create$ MENTAL_FATIGUE) (create$ medium)))
    (if (>= ?mental_fatigue 4) then
        (add_data ?user (create$ MENTAL_FATIGUE) (create$ high))
        (send_notification ?user "High mental fatigue" "Multiple factors are contributing to high mental fatigue")
    )
)