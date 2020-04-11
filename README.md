## Open Data 4 Covid 19 - Korean COVID-19 data extraction using R

With thanks to:

  * The Republic of Korea

  * The Ministry of Health and Welfare and

  * Health Insurance Review & Assessment Service

  * Website: https://hira-covid19.net/

## Installing R

If you don't have R you are going to need it.

You can download R here:

https://cran.csiro.au/

And you can download RStudio here:

https://rstudio.com/products/rstudio/

Just the free Desktop version is fine.

### Linux/Unix

R uses CRAN for package management so put this in ~./.Rprofile

```
# Default repo
local({r <- getOption("repos")
       r["CRAN"] <- "http://cran.r-project.org" 
       options(repos=r)
})
```

You run an R script from the command line like this

Rscript <script>

Or you can do this

```
$ which Rscript
/usr/local/bin/Rscript
```

Then put 

```#!/usr/local/bin/Rscript``` in the shebang line and make the file executable with 

```
chmod 755 <script>
```

RStudio may look after the details for you will need to consult https://rstudio.com/products/rstudio/ for details

### Windows

If you use Windows, I'm sorry but I can't help. 

I don't use Windows but feel free to add instructions here!

## Extra Files

### Documents directory

We have added the current Korean instructional material into Documents. These have been auto-translated into English. Improved translations welcome

### Korean_Codes directory

This directory contains some of the mappings from codes to english strings.

The PDF with the Korean name is the source of many of the codes. It is in Korean and can't be autotranslated but you can find the code you are interested in
and then translate the code numbers. 

Please remember to make code number text in Excel otherwise it will strip the leading 0's and will not match properly

## Running this code

```
$ rm -rf Results/*
$ Rscript extract.R
$ ls Results/
care_info_covid.csv      demographics.csv         med_info_phx.csv         summary_demographics.csv
care_info_phx.csv        med_info_covid.csv       summary_age_range.csv    summary_sex.csv
$ 
```

## HWP file format

Some notices have been only been published as *.HWP in Korean.

You can convert to PDF at https://allinpdf.com/convert/fileconvert/fileconvert-start

You will find these conversions (with Google translations) in the Notices directory.
