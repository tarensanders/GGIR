library(GGIR)
context("g.binread")
test_that("g.binread reads data in file correctly", {
  skip_on_cran()
  # Turned off on 2.7-0
  # binfile  = system.file("testfiles/genea_testfile.bin", package = "GGIR")[1]
  # GENEA = g.binread(binfile = binfile, start = 1, end = 4)
  # expect_equal(nrow(GENEA$header), 18)
  # expect_equal(GENEA$header[16], "Sample_Rate")
  # expect_equal(nrow(GENEA$rawxyz), 993)
  # expect_equal(sum(GENEA$rawxyz), 1058559)
  # expect_equal(nrow(GENEA$batt.voltage), 4)
  # expect_equal(as.numeric(GENEA$batt.voltage[1, 3]), 1269950921)
  # expect_equal(GENEA$timestamps1[100], 1269950922)
  # expect_equal(as.character(format(GENEA$timestamps2[100], format = "%Y")), "2010")
})