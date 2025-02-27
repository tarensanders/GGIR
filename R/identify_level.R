identify_levels = function(ts, TRLi, TRMi, TRVi, ws3, params_phyact = c(), ...) {
  #get input variables
  input = list(...)
  expectedArgs = c("ts", "TRLi", "TRMi", "TRVi", "ws3", "params_phyact")
  if (any(names(input) %in% expectedArgs == FALSE) |
      any(!unlist(lapply(expectedArgs, FUN = exists)))) {
    # Extract and check parameters if user provides more arguments than just the parameter arguments
    # So, inside GGIR this will not be used, but it is used when identify_level is used on its own
    # as if it was still the old identify_level function
    params = extract_params(params_phyact = params_phyact,
                            input = input) # load default parameters
    params_phyact = params$params_phyact
  }
  
  #=======================================================
  # LABEL INSENTITY LEVELS
  LEVELS = rep(0, length(ts$time))
  OLEVELS = rep(0, length(ts$time)) #to capture moderate and vigorous seperately
  LEVELS[ts$sibdetection == 1 & ts$diur == 1] = 0 #Sleep during the Sleep Period Time Window
  LEVELS[ts$sibdetection == 0 & ts$diur == 1] = 1 #Wakefullness during Sleep Period Time Window
  # activity during the night
  LEVELS[ts$sibdetection == 0 & ts$diur == 1 & ts$ACC >= TRLi & ts$ACC < TRMi] = 2 #LIGHT
  LEVELS[ts$sibdetection == 0 & ts$diur == 1 & ts$ACC >= TRMi & ts$ACC < TRVi] = 3 #MODERATE
  LEVELS[ts$sibdetection == 0 & ts$diur == 1 & ts$ACC >= TRVi] = 4 #VIGOROUS
  Lnames = c("spt_sleep","spt_wake_IN", "spt_wake_LIG", "spt_wake_MOD", "spt_wake_VIG")
  # activity during the day
  #======================================
  LEVELS[ts$diur == 0 & ts$ACC < TRLi] = 5 # Inactivit
  LEVELS[ts$diur == 0 & ts$ACC >= TRLi & ts$ACC < TRMi] = 6 #LIGHT
  LEVELS[ts$diur == 0 & ts$ACC >= TRMi & ts$ACC < TRVi] = 7 #MODERATE
  LEVELS[ts$diur == 0 & ts$ACC >= TRVi] = 8 #VIGOROUS
  Lnames = c(Lnames,"day_IN_unbt", "day_LIG_unbt", "day_MOD_unbt","day_VIG_unbt")
  # store separate copy of moderate and vigorous levels
  # note that when OLEVELS equal zero this is sleep period time window
  OLEVELS[LEVELS == 5] = 1 #IN
  OLEVELS[LEVELS == 6] = 2 #LIGHT
  OLEVELS[LEVELS == 7] = 3 #MOD
  OLEVELS[LEVELS == 8] = 4 #VIG
  

  #-------------------------------------
  # MVPA BOUTS
  LN = length(ts$time)
  
  boutduration = params_phyact[["boutdur.mvpa"]] * (60 / ws3) 
  NBL = length(boutduration) #number of bout lengths
  CL = 9 #current level
  refe = rep(0, LN)
  bc.mvpa = c()
  for (BL in 1:NBL) { # needs to be flexible to varibale number of bout lengths
    rr1 = rep(0, LN)
    p = which(ts$ACC >= TRMi & refe == 0 & ts$diur == 0); rr1[p] = 1
    out1 = g.getbout(x = rr1, boutduration = boutduration[BL], boutcriter = params_phyact[["boutcriter.mvpa"]],
                     closedbout = FALSE, bout.metric = params_phyact[["bout.metric"]], ws3 = ws3)
    LEVELS[ts$diur == 0 & out1$x == 1] = CL
    bc.mvpa = rbind(bc.mvpa,out1$boutcount)
    refe = refe + out1$x
    if (BL == 1) {
      Lnames = c(Lnames,paste0("day_MVPA_bts_", params_phyact[["boutdur.mvpa"]][BL]))
    } else {
      Lnames = c(Lnames,paste0("day_MVPA_bts_", params_phyact[["boutdur.mvpa"]][BL], "_",
                               params_phyact[["boutdur.mvpa"]][BL - 1]))
    }
    CL = CL + 1
  }
  #-------------------------------------
  # INACTIVITY BOUTS
  LN = length(ts$time)
  boutduration = params_phyact[["boutdur.in"]] * (60/ws3)
  NBL = length(boutduration) #number of bout lengths
  bc.in = c()
  for (BL in 1:NBL) {
    rr1 = rep(0, LN)
    p = which(ts$ACC < TRLi & refe == 0 & ts$diur == 0); rr1[p] = 1
    out1 = g.getbout(x = rr1, boutduration = boutduration[BL], boutcriter = params_phyact[["boutcriter.in"]],
                     closedbout = FALSE, bout.metric = params_phyact[["bout.metric"]], ws3 = ws3)
    LEVELS[ts$diur == 0 & out1$x == 1] = CL
    bc.in = rbind(bc.in, out1$boutcount)
    refe = refe + out1$x
    if (BL == 1) {
      Lnames = c(Lnames,paste0("day_IN_bts_", params_phyact[["boutdur.in"]][BL]))
    } else {
      Lnames = c(Lnames,paste0("day_IN_bts_", params_phyact[["boutdur.in"]][BL], "_",
                               params_phyact[["boutdur.in"]][BL - 1]))
    }
    CL = CL + 1
  }
  #-------------------------------------
  # LIGHT BOUTS
  LN = length(ts$time)
  boutduration = params_phyact[["boutdur.lig"]] * (60 / ws3)
  NBL = length(boutduration) #number of bout lengths
  bc.lig = c()
  for (BL in 1:NBL) {
    rr1 = rep(0, LN)
    p = which(ts$ACC >= TRLi & refe == 0 & ts$ACC < TRMi & ts$diur == 0); rr1[p] = 1
    out1 = g.getbout(x = rr1, boutduration = boutduration[BL], boutcriter = params_phyact[["boutcriter.lig"]],
                     closedbout = FALSE, bout.metric = params_phyact[["bout.metric"]], ws3 = ws3)                    
    LEVELS[ts$diur == 0 & out1$x == 1] = CL
    bc.lig = rbind(bc.lig,out1$boutcount)
    refe = refe + out1$x
    if (BL == 1) {
      Lnames = c(Lnames,paste0("day_LIG_bts_",params_phyact[["boutdur.lig"]][BL]))
    } else {
      Lnames = c(Lnames,paste0("day_LIG_bts_", params_phyact[["boutdur.lig"]][BL],
                               "_", params_phyact[["boutdur.lig"]][BL - 1]))
    }
    CL = CL + 1
  }
  invisible(list(LEVELS = LEVELS, OLEVELS = OLEVELS, Lnames = Lnames, 
                 bc.mvpa = bc.mvpa, bc.lig = bc.lig, bc.in = bc.in, ts = ts))
}