# fec_data

# Table of Contents
1 Introduction / Background
2 Getting Started / Prerequisites
3 Input
4 Output
5 Run Instructions

# Introduction / Background

This project takes data files of campaign finance contributions from the Federal Election Commission and processes them into 2 separate output files. One output file is sorted via the zip code of the donor, and the second output file is sorted via the date of the contribution. The specific files that this project processes are available online at the [FEC data portal](http://classic.fec.gov/finance/disclosure/ftpdet.shtml). The code runs specifically on contributions by individuals, whose data files are typically named indiv[year]. Any years data should be valid to run within the script.

# Getting Started / Prerequisites / Dependencies

This project is coded in the most recent version of Ruby. In order to run it, you must have Ruby installed on your system, which you can download at the [Ruby downloads page](https://www.ruby-lang.org/en/downloads/). The project is not dependent on any special packages, and should be able to run on nothing more than a Ruby installation. Once Ruby is downloaded, clone or download this repository.

# Inputs

The input for this project should be titled "itcont.txt" and stored within the input folder. The file is assumed to be pipe (|) delimited. The structure of the input should follow the following basic structure. After entry 16, the rest of the inputs are not necessary for the script to run. (irr = irrelevant data input)

CMTE_ID|irr|irr|irr|irr|irr|irr|irr|irr|irr|ZIP_CODE|irr|irr|DATE|AMOUNT|OTHER_ID|irr|irr|irr|irr|irr

CMTE_ID is the campaign ID code, and it is considered as long as it has a non null value.
ZIP_CODE is required to be completely numeric, and consist of at least 5 digits (any addition digits will be truncated).
DATE is the date of the donation, and it is counted as long as it is an 8 digit number.
AMOUNT is the amount of money donated, and can be any number (positive or negative) with up to 2 decimal places.
OTHER_ID is a second ID that flags the donor as an organization, and if this value is non null, it is not counted within the output.

# Outputs

The outputs of the script will be located within the outputs folder once the code is run. These will be 2 files that are by default named "medianvals_by_zip.txt" and "medianvals_by_date.txt"

medianvals_by_zip.txt creates a streamed list of donations of the following format. A set of median donations, number of donations, and total amount of donations are created for each unique set of CMTE_ID and ZIP_CODE combinations, and then printed into the file as they are read in.

CMTE_ID|ZIP_CODE|MEDIAN|NUM|TOTAL_AMOUNT

medianvals_by_date.txt creates a list once the entire data set is read of the following format. Like before, a set of median donations, number of donations, and total amount of donations are created for each unique set of CMTE_ID and DATE combinations, and then printed after the entire input is read.

CMTE_ID|DATE|MEDIAN|NUM|TOTAL_AMOUNT

# Run Instructions

Once Ruby is downloaded and the repository has been cloned or downloaded, running the script should be quite simple. First, open up a command window. Next, change and navigate to the folder that contains the cloned / downloaded repository. Once you are in that directory, simply enter the following command,

run.sh

This will call the shell script that will find and run the Ruby script (find_political_donors.rb) in the src file. This shell script will also find the input text file named "itcont.txt" within the input folder and the outputs within the output folder named "medianvals_by_zip.txt" and "medianvals_by_date.txt" and print to those output files.

