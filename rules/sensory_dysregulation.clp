(defrule sensory_dysregulation
    (User (item_id ?user) (baseline_heart_rate ?baseline_heart_rate) (sensory_profile ?sensory_profile)
          (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
          (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)
          (crowding ?crowding) (heart_rate ?heart_rate) (respiratory_rate ?respiratory_rate)
          (lighting ?lighting) (noise_pollution ?noise_pollution) (user_reported_noise_pollution ?user_reported_noise_pollution))
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
        (send_notification ?user "High sensory dysregulation" "Multiple factors are contributing to high sensory dysregulation")
    )
)