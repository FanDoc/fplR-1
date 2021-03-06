#' Detailed data for a player in the current FPL season
#'
#' Returns a tibble containing gameweek-level data for a given player in the current FPL season (season has to be in-play).
#' @param player_id \code{id} field from \code{\link{players}} tibble for a desired player.
#' @export
#' @examples
#' playerDetailed(player_id = 1)
#' playerDetailed(player_id = 54)

playerDetailed <- function(player_id) {
    
    # make the input numeric
    player_id <- as.numeric(player_id)
    
    # get player list
    players <- jsonlite::read_json("https://fantasy.premierleague.com/drf/bootstrap-static", simplifyVector = TRUE)
    
    # check the input is in range, stop if not
    if (!player_id %in% 1:length(players$elements$id)) 
        stop("player_id out of range.")
    
    # read in json player data, simplify vectors to make easy transfer to dataframe
    data <- jsonlite::read_json(paste0("https://fantasy.premierleague.com/drf/element-summary/", player_id), simplifyVector = TRUE)
    
    # extract current seasons data ONLY, convert to tibble format
    data <- tibble::as.tibble(data$history)
    
    if (length(data) < 1) 
        stop("No player data for the current season, yet.")
    
    # replace codes with matching values
    data$opponent_team <- with(players$teams, name[match(data$opponent_team, id)])
    
    # convert values to fpl-familiar style
    data$price <- data$value/10
    
    # convert var types
    data$influence <- as.numeric(data$influence)
    data$creativity <- as.numeric(data$creativity)
    data$threat <- as.numeric(data$threat)
    data$ict_index <- as.numeric(data$ict_index)
    
    # append player id
    data$player_id <- data$element
    
    data <- subset(data, select = -c(element, value))
    
    return(data)
    
}
