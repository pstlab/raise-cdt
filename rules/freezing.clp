(defrule freezing
    (User (item_id ?user) (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
          (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)
          (ANXIETY ?ANXIETY) (crowding ?crowding) (architectural_barriers ?architectural_barriers)
          (heart_rate_differential ?heart_rate_differential) (lighting ?lighting))
=>
    (bind ?freezing 0)
    (bind ?freezing_relevant (create$))

    (if (and (or ?parkinson ?older_adults ?psychiatric_patients ?multiple_sclerosis ?young_pci_autism) (>= ?crowding 2)) then (bind ?freezing (+ ?freezing 1)))
    (if (and ?parkinson ?ANXIETY) then (bind ?freezing (+ ?freezing 1)))
    (if (and ?parkinson ?architectural_barriers) then (bind ?freezing (+ ?freezing 1)))
    (if (and (or ?parkinson ?young_pci_autism) ?lighting) then (bind ?freezing (+ ?freezing 1)))

    (if (and (or ?psychiatric_patients ?young_pci_autism ?parkinson ?multiple_sclerosis) (>= ?heart_rate_differential 50)) then (bind ?freezing_relevant (insert$ ?freezing_relevant 1 heart_rate_differential)))

    (printout t "User: " ?user crlf)
    (printout t "Freezing: " ?freezing crlf)
    (printout t "Freezing Relevant Factors: " ?freezing_relevant crlf)

    (if (and (>= ?freezing 0) (<= ?freezing 1)) then (add_data ?user (create$ FREEZING freezing_relevant) (create$ low (to_json ?freezing_relevant))))
    (if (and (>= ?freezing 2) (<= ?freezing 3)) then (add_data ?user (create$ FREEZING freezing_relevant) (create$ medium (to_json ?freezing_relevant))))
    (if (>= ?freezing 4) then
        (add_data ?user (create$ FREEZING freezing_relevant) (create$ high (to_json ?freezing_relevant)))
        (send_notification ?user "High freezing" "Multiple factors are contributing to high freezing")
    )
)