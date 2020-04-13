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

We have added the current Korean instructional material into Documents. These have been auto-translated into English. Improved translations welcome.

### Notices directory

This contains copies of the Korean 1 page research plan and Data Use Agreement converted from HWP format to PDF as well
as English translations of them. It also contains the notices in Korean translated into English and presented as
Markdown for easy viewing in a browser (or text editor).

### Korean_Codes directory

This directory contains some of the mappings from codes to english strings.

The PDF with the Korean name is the source of many of the codes. It is in Korean and can't be autotranslated but you can find the code you are interested in
and then translate the code numbers from the accompanying table cell. 

Please remember to make code number text in Excel otherwise it will strip the leading 0's and will not match properly.

Please note that the MAIN_SICK and SUB_SICK fields map to KCD7 - the Korean Classification of Diseases v7. The mapping
is UNIQUE_CODE -> (1..n) STRINGS so 1 code could convert to 1..n STRINGS. Please consult to source code but if you do
not do something like this:

```
# MAIN_SICK to KCD-7 string diagnosis
main_sick_map = read_excel("./Korean_Codes/MAIN_SICK_KCD-7.xlsx", sheet=1)

# Remove the duplicate values from KCD-7
main_sick_map = main_sick_map[!duplicated(main_sick_map$MAIN_SICK),]
```

to strip the duplicates then any merge you do will not work as you might expect.


## Running this code

```
$ rm -rf Results/*
$ Rscript extract.R
$ ls Results/
care_info_covid.csv      demographics.csv         med_info_phx.csv         summary_demographics.csv
care_info_phx.csv        med_info_covid.csv       summary_age_range.csv    summary_sex.csv
$ 
```

## HWP file format (how to read them by converting to PDF)

Some notices have been only been published as *.HWP in Korean.

You can convert to PDF at https://allinpdf.com/convert/fileconvert/fileconvert-start

You will find these conversions (with Google translations) in the Notices directory.

## Data Schema

It is documented in the source code but we have converted some of the more obscurely named FIELD_ID tokens to something
more self explanatory and converted the numeric codes to easily undertandable strings.

Please note there does not appear to be a direct coding for the western concepts of "HME", "HDU", or "ICU".

Death is coded in DGRSLT_TP_CD with code number 4.

