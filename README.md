# easysorter

easysorter is effectively version 2 of the COPASutils package (Shimko and Andersen, 2014). This package is specialized for use with worms and includes additional functionality on top of that provided by COPASutils, including division of recorded objects by larval stage and the ability to regress out control phenotypes from those recorded in experimental conditions. The package is rather specific to use in the Andersen Lab and, therefore, is not available from CRAN. To install easysorter you will need the [`devtools`](https://github.com/hadley/devtools) package and the [`COPASutils`](https://github.com/AndersenLab/COPASutils) package. You can install `devtools`, `COPASutils`, and `easysorter` using the commands below:

```r
install.packages("devtools")
devtools::install_github("AndersenLab/COPASutils")
devtools::install_github("AndersenLab/easysorter")
```

The functionality of the package can be broken down into three main goals:

+ Reading raw data from the sorter alongside information about strains, conditions, controls, and contamination

+ Pruning anomalous data points

+ Regressing control phenotypes from experimental phenotypes

## Directory structure

Because so much information must be transferred alongside the plate data, the directory structure from which you are reading is critically important. Below is an example of a correct directory structure. The `setup` directory contains `.txt` files from the sort day copied directly from the sorter. The `score` directory contains `.txt` files from the score day copied directly from the sorter. If you don't have sort information (i.e. V3 48 hour assay), you do not need the `setup` directory.

```
20150529_LysateScore/
├── conditions
│   └── LysateConc5-20.csv
├── contamination
│   ├── p01_contamination.csv
│   └── p02_contamination.csv
├── controls
│   └── None.csv
├── setup
│   ├── p01_N2CBLysateTest_LysateConc5-20_None.txt
│   └── p02_N2CBLysateTest_LysateConc5-20_None.txt
├── score
│   ├── p01_N2CBLysateTest_LysateConc5-20_None.txt
│   └── p02_N2CBLysateTest_LysateConc5-20_None.txt
└── strains
    └── N2CBLysateTest.csv
```

This directory exhibits the minimal file content and naming for the easysorter package to work.

### Experiment directory

The experiment directory contains all of the files attached to a specific experiment conducted on a specific date. The naming convention for these folders should include the date in the format 4-digit year::2-digit month::2-digit day and experiment name separated by underscores. Optionally, an experiment round and assay can be added as well. The round should be a number and the assay should be a lowercase letter. Because of the ambiguity of the experiment and round/assay, the experiment name should never contain numbers itself.

```
# Minimal directory name
# Date is January 1st, 2015
# Experiment name is "ExperimentName"

20150101_ExperimentName/

#####################################

# Maximum directory name
# Date is January 1st, 2015
# Experiment name is "ExperimentName"
# Round is 1
# Assay is A

20150101_ExperimentName1a/

#####################################

20150101_ExperimentName1a/ = GOOD
20150101_Experiment25Name1a/ = BAD
```

### Template directories

Each experiment directory should have four template directories: `strains`, `conditions`, `controls`, and `contamination`. Within each of these directories should be the template files in `.csv` format.

The blank template file can be downloaded [here](ADD DIRECTORY FOR DOWNLOAD). Each sheet of the file should be filled in and exported to a `.csv` individually. If you are using Excel, use File -> Save As... and select file format `.csv` to export the currently selected sheet only. This will need to be done multiple times to export each sheet. In Numbers, select File -> Export To... -> .CSV. This will export all of the sheets to different files within a folder. Each file will need to be renamed individually after they are exported.

#### Strains template

Enter the strain name for all wells. If the well contained no strain (a wash well, for instance), enter "NA".

#### Conditions template

Enter the condition name for each well. Multiple dosages can be encoded as `bleomycin-250` or `bleomycin 250`. Avoid using just numeric values like `250`.

#### Controls template

Enter the control for each well. If the well does not have an associated control, it should be encoded as `none`. If the well itself is a control well, encode the control value as `NA`.

#### Contamination

Enter the value for contamination in only wells that were contaminated. These should be encoded as `TRUE`. All non-contaminated wells can either be encoded as `FALSE`. Contamination files should be names as the plate number and the word "contamination", separated by an underscore. For example:

```
20150529_LysateScore/
├── conditions
│   └── LysateConc5-20.csv
├── contamination
│   ├── p01_contamination.csv
│   └── p02_contamination.csv
├── controls
│   └── None.csv
├── setup
│   ├── p01_N2CBLysateTest_LysateConc5-20_None.txt
│   └── p02_N2CBLysateTest_LysateConc5-20_None.txt
├── score
│   ├── p01_N2CBLysateTest_LysateConc5-20_None.txt
│   └── p02_N2CBLysateTest_LysateConc5-20_None.txt
└── strains
    └── N2CBLysateTest.csv
```

The contamination files in this directory are named `p01_contamination.csv` and `p02_contamination.csv`. These names correspond to the two numbers used on the two plates that were scored.

### File naming

File names should be formatted with the plate number, name of the strains template file, name of the conditions template file, and name of the controls template file all separated by underscores. All data files must be saved as `.txt` files. In the plate named `p01_N2CBLysateTest_LysateConc5-20_None.txt` `p01` is the plate number, `N2CBLysateTest` refers to the strain template file `N2CBLysateTest.csv`, `LysateConc5-20` refers to the condition template file `LysateConc5-20.csv`, and `None` refers to the control template file `None.csv`.

![File name convention](./READMEfiles/FileNaming.png)

## Pipeline

The complete easy sorter package consists of only 6 functions: `read_data`, `remove_contamination`, `sumplate`, `bioprune`, `bamf_prune`, and `regress`.

### `read_data()`

`read_data()` can take as an argument a path to a single data file, a directory with sorter data files, or an experiment directory with both setup and score subdirectories. If the function is given either a single file or directory of files, it will output a single data frame of all of the data that were read. If the function is given an experiment directory with both setup and score subdirectories, it will output a two element list with the first element being the score data and the second element being the setup data.

For further information use the command `?read_plate` to access the documentation.

### `remove_contamination()`

`remove_contamination()` takes as an argument the raw data output from read_data. It will automatically remove any data from contaminated wells as per the contamination files stored in the data directory.

For further information use the command `?remove_contamination()` to access the documentation.

### `sumplate()`

`sumplate` summarizes the plates that have been read in to R using the `read_data` function. This function can take either a single data frame or the list of two data frames. If a list is passed, the `n.sorted` column will be calculated automatically using the setup data. Otherwise, n.sorted will be set to 0 and can be changed manually by the user.

*For a V3 assay (no sorting), use the `v3_assay = TRUE` flag to avoid calculating `norm.n`.*

For further information use the command `?sumplate` to access the documentation.

### `bioprune()`

`bioprune` will remove any biologically impossible wells from the data set (n > 1000, n < 5, norm.n > 350). It takes as input the standard output from `sumplate`.

For further information use the command `?bioprune` to access the documentation.

### `bamf_prune()`

`bamf_prune()` takes a summarized plate as input and outputs a plate data frame either with three additional columns indicating outlier calls or a trimmed data frame with all outliers removed. It is generally recommended to use `bamf_prune` when running mappings or other experiments with many strains and few replicates because it keeps outliers that are grouped together.

For further information use the command `?bamf_prune` to access the documentation.

### `prune_outliers()`

`prune_outliers()` is an alternative to `bamf_prune()` that takes a summarized plate as input and outputs a trimmed data frame with all outliers removed. Outliers are claculated either as the median +/- (2 * IQR) if `iqr = TRUE` or mean +/- (2 * standard deviation) if `iqr = FALSE` (default). It is generally recommended to use `prune_outliers` with experiments with many replicates because it calculates outliers for each strain independently.

For further information use the command `?prune_outliers` to access the documentation.

### `regress()`

`regress()` can take either a pruned or unpruned data frame and will return a data frame in long form with the phenotype column replaced with residual values (either `phenotype ~ control` if `assay = FALSE` or `phenotype ~ assay` if `assay = TRUE`).

For further information use the command `?regress` to access the documentation.

### Overview

![Overview](./READMEfiles/Overview.png)

### Example

```r
library(easysorter)
library(dplyr)

# Define a vector of your experiement directories
dirs <- c("~/Dropbox/HTA/Results/20150706_McGrathRILs1a/",
          "~/Dropbox/HTA/Results/20150707_McGrathRILs1b/")

# Read in the data
raw <- read_data(dirs)

# Remove all data from the contaminated wells
raw_nocontam <- remove_contamination(raw)

# Summarize the data
summedraw <- sumplate(raw_nocontam, directories = TRUE, quantiles = TRUE)

#Prune based on biological impossibilities
biopruned <- bioprune(summedraw)

# Regress out the effect of assay first
assayregressed <- regress(biopruned, assay = TRUE)

# Prune based on bins
bamfpruned <- bamf_prune(assayregressed, drop = TRUE)

# If you have replicates in the data, summarize the data down to one observation
# per strain. Here we do that by taking the mean of the two replicates. Make
# sure to include `na.rm = TRUE` to avoid losing data missing in only one assay.
sumpruned <- bamfpruned %>%
    group_by(condition, control, strain, trait) %>%
    summarize(phenotype = mean(phenotype, na.rm = TRUE))

# Regress out the effect of the control strains (effects not due to changed
# environmental condition)
LSJ2data <- regress(sumpruned)

# Save the final data frame
saveRDS(LSJ2data, "~/LSJ2phenotype.rds")
```
