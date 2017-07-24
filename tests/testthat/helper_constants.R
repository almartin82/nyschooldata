# #this gets run before tests
agg_all <- dplyr::bind_rows(agg_2015, agg_2016)
clean_all <- dplyr::bind_rows(clean_2015, clean_2016)
