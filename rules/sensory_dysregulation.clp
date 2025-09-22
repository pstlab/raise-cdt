(defrule sensory_dysregulation
    (User_baseline_heart_rate (item_id ?user) (baseline_heart_rate ?baseline_heart_rate))
    (User_sensory_profile (item_id ?user) (sensory_profile ?sensory_profile))

    (User_parkinson (item_id ?user) (parkinson ?parkinson))
    (User_older_adults (item_id ?user) (older_adults ?older_adults))
    (User_psychiatric_patients (item_id ?user) (psychiatric_patients ?psychiatric_patients))
    (User_multiple_sclerosis (item_id ?user) (multiple_sclerosis ?multiple_sclerosis))
    (User_young_pci_autism (item_id ?user) (young_pci_autism ?young_pci_autism))

    (User_has_crowding (item_id ?user) (crowding ?crowding))
    (User_has_heart_rate (item_id ?user) (heart_rate ?heart_rate))
    (User_has_respiratory_rate (item_id ?user) (respiratory_rate ?respiratory_rate))
    (User_has_lighting (item_id ?user) (lighting ?lighting))
    (User_has_noise_pollution (item_id ?user) (noise_pollution ?noise_pollution))
    (User_has_user_reported_noise_pollution (item_id ?user) (user_reported_noise_pollution ?user_reported_noise_pollution))
=>
    (bind ?sensory_dysregulation 0)
    (bind ?sensory_dysregulation_relevant (create$))

    (if (and (or ?parkinson ?older_adults ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (>= ?crowding 2)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or ?parkinson ?multiple_sclerosis ?young_pci_autism) (>= ?heart_rate 100)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or ?parkinson ?young_pci_autism) ?lighting) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or ?older_adults ?parkinson ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (> ?noise_pollution 45)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or ?older_adults ?parkinson ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (> ?user_reported_noise_pollution 45)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))

    (if (and (or ?parkinson ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (>= ?heart_rate 100)) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 heart_rate)))
    (if (and (or ?psychiatric_patients ?young_pci_autism) (>= ?baseline_heart_rate 100)) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 baseline_heart_rate)))
    (if (and (or ?parkinson ?psychiatric_patients ?older_adults ?multiple_sclerosis ?young_pci_autism) (>= ?respiratory_rate 30)) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 respiratory_rate)))
    (if (and ?young_pci_autism ?sensory_profile) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 sensory_profile)))

    (printout t "User: " ?user crlf)
    (printout t "Sensory Dysregulation: " ?sensory_dysregulation crlf)
    (printout t "Sensory Dysregulation Relevant Factors: " ?sensory_dysregulation_relevant crlf)

    (if (and (>= ?sensory_dysregulation 0) (<= ?sensory_dysregulation 1)) then (add_data ?user (create$ SENSORY_DYSREGULATION sensory_dysregulation_relevant) (create$ low (to_json ?sensory_dysregulation_relevant))))
    (if (and (>= ?sensory_dysregulation 2) (<= ?sensory_dysregulation 3)) then (add_data ?user (create$ SENSORY_DYSREGULATION sensory_dysregulation_relevant) (create$ medium (to_json ?sensory_dysregulation_relevant))))
    (if (>= ?sensory_dysregulation 4) then
        (add_data ?user (create$ SENSORY_DYSREGULATION sensory_dysregulation_relevant) (create$ high (to_json ?sensory_dysregulation_relevant)))
        (send_notification (?user "High sensory dysregulation" "Multiple factors are contributing to high sensory dysregulation"))
    )
)