(defrule dyskinesia
    (User (item_id ?user) (parkinson ?parkinson) (ANXIETY ?ANXIETY))
=>
    (bind ?dyskinesia 0)
    (bind ?dyskinesia_message "")

    (if (and (eq ?parkinson TRUE) (neq ?ANXIETY low)) then
        (bind ?dyskinesia (+ ?dyskinesia 1))
        (bind ?dyskinesia_message (str-cat ?dyskinesia_message "Anxiety contributes to dyskinesia. "))
    )

    (printout t "User: " ?user crlf)
    (printout t "Dyskinesia: " ?dyskinesia crlf)
    (printout t "Dyskinesia Message: " ?dyskinesia_message crlf)

    (if (and (>= ?dyskinesia 0) (<= ?dyskinesia 1)) then (add_data ?user (create$ DYSKINESIA) (create$ low)))
    (if (and (>= ?dyskinesia 2) (<= ?dyskinesia 3)) then (add_data ?user (create$ DYSKINESIA) (create$ medium)))
    (if (>= ?dyskinesia 4) then
        (add_data ?user (create$ DYSKINESIA dyskinesia_message) (create$ high ?dyskinesia_message))
        (send_notification ?user "High dyskinesia" "Anxiety is contributing to high dyskinesia")
    )
)