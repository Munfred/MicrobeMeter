#########################################################################################################
# This script processes the output file of MicrobeMeter v1.0.
# Written by Kalesh Sasidharan
# Date    : 2018/07/02
# Version : 1.0

# This material is provided under the MicrobeMeter non-commercial, academic and personal use licence.
# By using this material, you agree to abide by the MicrobeMeter Terms and Conditions outlined on https://humanetechnologies.co.uk/terms-and-conditions-of-products/.

# © 2018 Humane Technologies Limited. All rights reserved.
#########################################################################################################

turbidityCalculator <- function() {
  ############################################
  # Getting and reading the data file of MicrobeMeter v1.0
  turbidityCTMD <- ""
  while (turbidityCTMD == "") {
    turbidityCTMD <- readline(prompt = "Enter the location and name of the data file: ")
  }
  turbidityCTMD <- read.table(turbidityCTMD, header=F, sep="\t", stringsAsFactors=F, skip=1, fill=T)
  
  # Getting the time unit for x-axis
  timeUnit <- ""
  while (!timeUnit %in% c("seconds", "minutes", "hours", "s", "m", "h")) {
    timeUnit <- readline(prompt = "Enter the time unit for x-axis (seconds: s, minutes: m, hours: h): ")
  }
  timeUnit <- switch (timeUnit, seconds = 1, minutes = 60, hours = 3600, s = 1, m = 60, h = 3600)
  xLabel <- switch (as.character(timeUnit), "1" = "Time (s)", "60" = "Time (m)", "3600" = "Time (h)")
  
  # Getting details about moving average
  windowSize <- ""
  while (windowSize == "") {
    windowSize <- readline(prompt = "Do you want do moving average? If no then enter 0, otherwise enter the window-size: ")
  }
  windowSize <- as.numeric(windowSize)
  
  # Getting rid of unwanted information
  colnames(turbidityCTMD) <- turbidityCTMD[1,]
  turbidityCTMD <- turbidityCTMD[,c(-2,-7)]
  turbidityCTMD <- turbidityCTMD[-1,]
  
  # Converting the time stamp to Unix timestamp (seconds)
  turbidityCTMD[,1] <- as.numeric(as.POSIXct(strptime(turbidityCTMD[,1], "%c")))
  turbidityCTMD[,1] <- turbidityCTMD[,1] - turbidityCTMD[2,1]
  turbidityCTMD <- data.matrix(turbidityCTMD)
  ############################################
  
  ############################################
  # Normalising the measurements of Port 1-3 using Port 4 for removing temperature bias
  turbidityCTMDNorm <- NULL
  for (i in 2:4) {
    turbidityCTMDNorm <- cbind(turbidityCTMDNorm, turbidityCTMD[,i]*(turbidityCTMD[1,i]/turbidityCTMD[,5]))
  }
  
  # Calculating the turbidity: divide each measurement using the corresponding Blank and calculate the -log, then multiply with 1/1.6 for path-length correction
  pathLength <- 1.6
  turbidityCTMDFull <- cbind((turbidityCTMD[,1]/timeUnit), -log10(t(t(turbidityCTMDNorm)/turbidityCTMDNorm[1,]))*(1/pathLength))[-1,]
  colnames(turbidityCTMDFull) <- colnames(turbidityCTMD)[-5]
  
  # Conducting moving average
  if (windowSize > 0) turbidityCTMDFull <- filter(turbidityCTMDFull, rep(1/windowSize, windowSize), sides = 1)[windowSize:nrow(turbidityCTMDFull),]
  
  # Calculating average and SD
  turbidityCTMDMean <- rowMeans(turbidityCTMDFull[,2:4])
  turbidityCTMDSD <- apply((turbidityCTMDFull[,2:4]), 1, sd)
  
  # Saving the turbidity results
  write.table(rbind(c(colnames(turbidityCTMD)[-5], "Mean", "SD"), cbind(turbidityCTMDFull, turbidityCTMDMean, turbidityCTMDSD)), "TurbidityResults.tsv", sep = "\t", row.names = F, col.names = F)
  ############################################
  
  ############################################
  # Generating the plot
  # Turbidity Plot
  pdf("Turbidity.pdf")
  matplot(turbidityCTMDFull[,1], turbidityCTMDFull[,2:4], type = "p", ylab = "Turbidity", xlab = xLabel, pch = 1:3, cex = 0.5, col = 1:3)
  legend('topleft', legend = c("Port 1", "Port 2", "Port 3"), pch = 1:3, col = 1:3)
  dev.off()
  
  # Turbidity Mean-SD Plot
  pdf("Turbidity_Mean-SD.pdf")
  matplot(turbidityCTMDFull[,1], turbidityCTMDMean, type = "n", ylab = "Turbidity", ylim = c(min(turbidityCTMDMean-turbidityCTMDSD), max(turbidityCTMDMean+turbidityCTMDSD)), xlab = xLabel, pch = 20, cex = 0.5, col = 'black')
  arrows(turbidityCTMDFull[,1], turbidityCTMDMean-turbidityCTMDSD, turbidityCTMDFull[,1], turbidityCTMDMean+turbidityCTMDSD, length = 0.02, angle = 90, code = 3, col = 'grey')
  points(turbidityCTMDFull[,1], turbidityCTMDMean, pch = 20, cex = 0.5, col = 'black')
  dev.off()
  ############################################
}