#' Record to Data Frame
#'
#' Convert a single record, containing one or more data items, to a to
#' a single data frame.
#'
#' @param record A single CIMIS record, in list format.
#' @return A data frame. The column `"Item"` identifies the data item.
#'
#' @importFrom tidyr unnest
#' @importFrom dplyr mutate bind_rows setdiff as_tibble
#' @importFrom purrr map
#' @importFrom rlang .data
#' @keywords internal
record_to_df = function(record) {
  fixed = c("Date", "Hour", "Julian", "Station", "Standard", "ZipCodes", "Scope")
  data.names = setdiff(names(record), fixed)
  other.names = setdiff(names(record), data.names)
  unnest(mutate(as_tibble(record[other.names]),
    Date = as.Date(.data$Date),
    Julian = as.integer(.data$Julian),
    Data = list(bind_rows(map(record[data.names], as_tibble),
      .id = "Item"))
  ))
}


#' Bind Records
#'
#' Bind CIMIS records into a single data frame. This function 
#'   is used internally
#'
#' @param result CIMIS query results.
#' @return A data frame.
#'
#' @importFrom tidyr unnest
#' @importFrom purrr map
#' @importFrom dplyr mutate bind_rows as_tibble
#' @importFrom rlang .data
#' @keywords internal
bind_records = function(result) {
  unnest(mutate(
    bind_rows(map(result[[c("Data", "Providers")]], as_tibble)),
    Records = map(.data$Records, record_to_df)
  ))
}