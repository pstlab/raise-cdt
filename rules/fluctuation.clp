(defrule fluctuation
    (User (item_id ?user) (parkinson ?parkinson) (ANXIETY ?ANXIETY))
=>
    (bind ?fluctuation 0)

    (if (and ?parkinson (neq ?ANXIETY low)) then (bind ?fluctuation (+ ?fluctuation 1)))

    (printout t "User: " ?user crlf)
    (printout t "Fluctuation: " ?fluctuation crlf)

    (if (and (>= ?fluctuation 0) (<= ?fluctuation 1)) then (add_data ?user (create$ FLUCTUATION) (create$ low)))
    (if (and (>= ?fluctuation 2) (<= ?fluctuation 3)) then (add_data ?user (create$ FLUCTUATION) (create$ medium)))
    (if (>= ?fluctuation 4) then
        (add_data ?user (create$ FLUCTUATION) (create$ high))
        (send_notification ?user "High fluctuation" "Anxiety is contributing to high fluctuation")
    )
)