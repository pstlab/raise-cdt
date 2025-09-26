(defrule fluctuation
    (RAISE-User (item_id ?user) (parkinson ?parkinson) (ANXIETY ?ANXIETY))
=>
    (bind ?fluctuation 0)
    (bind ?fluctuation_message "")

    (if (and (eq ?parkinson TRUE) (neq ?ANXIETY low)) then
        (bind ?fluctuation (+ ?fluctuation 1))
        (bind ?fluctuation_message (str-cat ?fluctuation_message "Anxiety contributes to fluctuation. "))
    )

    (printout t "User: " ?user crlf)
    (printout t "Fluctuation: " ?fluctuation crlf)
    (printout t "Fluctuation Message: " ?fluctuation_message crlf)

    (if (and (>= ?fluctuation 0) (<= ?fluctuation 1)) then (add_data ?user (create$ FLUCTUATION) (create$ low)))
    (if (and (>= ?fluctuation 2) (<= ?fluctuation 3)) then (add_data ?user (create$ FLUCTUATION) (create$ medium)))
    (if (>= ?fluctuation 4) then
        (add_data ?user (create$ FLUCTUATION fluctuation_message) (create$ high ?fluctuation_message))
        (send_notification ?user "High fluctuation" "Anxiety is contributing to high fluctuation")
    )
)