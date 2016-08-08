# #this gets run before tests

#2015 bits and pieces
ex_2015 <- get_raw_assess_db(2015, verbose = FALSE)
clean_2015 <- clean_assess_db(ex_2015, 2015, verbose = FALSE)
agg_2015 <- aggregate_grades(clean_2015)

final_2015 <- dplyr::bind_rows(clean_2015, agg_2015)

#2016 using the wrapper
final_2016 <- fetch_and_aggregate_assess_db(2016, verbose = TRUE)
