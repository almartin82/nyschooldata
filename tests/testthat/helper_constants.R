#this gets run before tests
ex_2015 <- get_raw_assess_db(2015)
ex_2016 <- get_raw_assess_db(2016)

clean_assess_start <- clean_assess_db(ex_2015, 2015)
clean_assess_end <- clean_assess_db(ex_2016, 2016)
