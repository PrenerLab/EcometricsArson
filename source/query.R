
query <- function(i, target, source, category){
  
  # subset source data
  source <- dplyr::filter(source, id == i)
  
  # store dates
  date <- source$date_occur
  date_val <- lubridate::date(lubridate::mdy_hm(date))
  tail_date <- date_val - lubridate::years(1)
  head_date <- date_val + lubridate::years(1)
  
  # buffer source data
  source <- dplyr::select(source, id)
  buffer <- sf::st_buffer(source, dis = 300)
  
  # intersect source and buffer, and count
  target <- suppressWarnings(sf::st_intersection(target, buffer))
  
  if (category %in% c("violent", "property", "other crime")){
    target <- compstatr::cs_parse_date(target, var = date_occur, dateVar = date, timeVar = time)
  } else if (category == "disorder"){
    target <- dplyr::mutate(target, date = date(datetimeinit))
  }
  
  tail_count <- dplyr::filter(target, date <= date_val & date >= tail_date)
  head_count <- dplyr::filter(target, date >= date_val & date <= head_date)
  
  # construct output
  if (category == "violent"){
    
    out <- dplyr::tibble(
      id = i,
      violent_pre = nrow(tail_count),
      violent_post = nrow(head_count)
    )
    
  } else if (category == "property"){
    
    out <- dplyr::tibble(
      id = i,
      property_pre = nrow(tail_count),
      property_post = nrow(head_count)
    )
    
  } else if (category == "disorder"){
    
    out <- dplyr::tibble(
      id = i,
      disorder_pre = nrow(tail_count),
      disorder_post = nrow(head_count)
    )
    
  } else if (category == "other crime"){
    
    out <- dplyr::tibble(
      id = i,
      other_crime_pre = nrow(tail_count),
      other_crime_post = nrow(head_count)
    )
    
  }
  
  # return output
  return(out)
  
}
