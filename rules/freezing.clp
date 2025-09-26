(defrule freezing
    ?f <- (RAISE-User (item_id ?user) (parkinson ?parkinson) (older_adults ?older_adults) (psychiatric_patients ?psychiatric_patients)
          (multiple_sclerosis ?multiple_sclerosis) (young_pci_autism ?young_pci_autism)
          (ANXIETY ?ANXIETY) (crowding ?crowding) (architectural_barriers ?architectural_barriers)
          (heart_rate_differential ?heart_rate_differential) (lighting ?lighting))
=>
    (bind ?freezing 0)
    (bind ?freezing_relevant (create$))
    (bind ?freezing_message "")

    (if (and (or (eq ?parkinson TRUE) (eq ?older_adults TRUE) (eq ?psychiatric_patients TRUE) (eq ?multiple_sclerosis TRUE) (eq ?young_pci_autism TRUE)) (neq ?crowding nil) (>= ?crowding 2)) then
        (bind ?freezing (+ ?freezing 1))
        (bind ?freezing_message (str-cat ?freezing_message "Crowding increases freezing of gait. "))
    )
    (if (and (eq ?parkinson TRUE) (neq ?ANXIETY low)) then
        (bind ?freezing (+ ?freezing 1))
        (bind ?freezing_message (str-cat ?freezing_message "Anxiety increases freezing of gait. "))
    )
    (if (and (eq ?parkinson TRUE) (neq ?architectural_barriers nil) ?architectural_barriers) then
        (bind ?freezing (+ ?freezing 1))
        (bind ?freezing_message (str-cat ?freezing_message "Architectural barriers increase freezing of gait. "))
    )
    (if (and (or (eq ?parkinson TRUE) (eq ?young_pci_autism TRUE)) (neq ?lighting nil) ?lighting) then
        (bind ?freezing (+ ?freezing 1))
        (bind ?freezing_message (str-cat ?freezing_message "Poor lighting increases freezing of gait. "))
    )

    (if (and (or (eq ?psychiatric_patients TRUE) (eq ?young_pci_autism TRUE) (eq ?parkinson TRUE) (eq ?multiple_sclerosis TRUE)) (neq ?heart_rate_differential nil) (>= ?heart_rate_differential 50)) then (bind ?freezing_relevant (insert$ ?freezing_relevant 1 heart_rate_differential)))

    (printout t "User: " ?user crlf)
    (printout t "Freezing: " ?freezing crlf)
    (printout t "Freezing Relevant Factors: " ?freezing_relevant crlf)
    (printout t "Freezing Message: " ?freezing_message crlf)

    (if (and (>= ?freezing 0) (<= ?freezing 1)) then (add_data ?user (create$ FREEZING freezing_relevant) (create$ low (to_json ?freezing_relevant))))
    (if (and (>= ?freezing 2) (<= ?freezing 3)) then (add_data ?user (create$ FREEZING freezing_relevant) (create$ medium (to_json ?freezing_relevant))))
    (if (>= ?freezing 4) then
        (add_data ?user (create$ FREEZING freezing_relevant freezing_message) (create$ high (to_json ?freezing_relevant) ?freezing_message))
        (send_notification ?user "High freezing" "Multiple factors are contributing to high freezing")
    )
)