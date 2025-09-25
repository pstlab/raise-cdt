(defrule sensory_dysregulation
    (User (item_id ?user) (baseline_heart_rate ?baseline_heart_rate) (sensory_profile ?sensory_profile)
          (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
          (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)
          (crowding ?crowding) (heart_rate ?heart_rate) (respiratory_rate ?respiratory_rate)
          (lighting ?lighting) (noise_pollution ?noise_pollution) (user_reported_noise_pollution ?user_reported_noise_pollution))
=>
    (bind ?sensory_dysregulation 0)
    (bind ?sensory_dysregulation_relevant (create$))

    (if (and (or (eq ?parkinson TRUE) (eq ?older_adults TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?crowding nil) (>= ?crowding 2)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or (eq ?parkinson TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?heart_rate nil) (>= ?heart_rate 100)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or (eq ?parkinson TRUE) (eq ?young_pci_autism TRUE)) (neq ?lighting nil) ?lighting) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?noise_pollution nil) (> ?noise_pollution 45)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))
    (if (and (or (eq ?older_adults TRUE) (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?user_reported_noise_pollution nil) (> ?user_reported_noise_pollution 45)) then (bind ?sensory_dysregulation (+ ?sensory_dysregulation 1)))

    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?heart_rate nil) (>= ?heart_rate 100)) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 heart_rate)))
    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?young_pci_autism TRUE)) (neq ?baseline_heart_rate nil) (>= ?baseline_heart_rate 100)) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 baseline_heart_rate)))
    (if (and (or (eq ?parkinson TRUE) (eq ?psychiatric_patients TRUE) (eq ?older_adults TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?respiratory_rate nil) (>= ?respiratory_rate 30)) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 respiratory_rate)))
    (if (and (eq ?young_pci_autism TRUE) (neq ?sensory_profile nil) ?sensory_profile) then (bind ?sensory_dysregulation_relevant (insert$ ?sensory_dysregulation_relevant 1 sensory_profile)))

    (printout t "User: " ?user crlf)
    (printout t "Sensory Dysregulation: " ?sensory_dysregulation crlf)
    (printout t "Sensory Dysregulation Relevant Factors: " ?sensory_dysregulation_relevant crlf)

    (if (and (>= ?sensory_dysregulation 0) (<= ?sensory_dysregulation 1)) then (add_data ?user (create$ SENSORY_DYSREGULATION sensory_dysregulation_relevant) (create$ low (to_json ?sensory_dysregulation_relevant))))
    (if (and (>= ?sensory_dysregulation 2) (<= ?sensory_dysregulation 3)) then (add_data ?user (create$ SENSORY_DYSREGULATION sensory_dysregulation_relevant) (create$ medium (to_json ?sensory_dysregulation_relevant))))
    (if (>= ?sensory_dysregulation 4) then
        (add_data ?user (create$ SENSORY_DYSREGULATION sensory_dysregulation_relevant) (create$ high (to_json ?sensory_dysregulation_relevant)))
        (send_notification ?user "High sensory dysregulation" "Multiple factors are contributing to high sensory dysregulation")
    )
)