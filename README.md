## Open Data 4 Covid 19 - Korean COVID-19 data extraction using R

With thanks to:
  *The Republic of Korea
  *The Ministry of Health and Welfare and
  *Health Insurance Review & Assessment Service
  *Website: https://hira-covid19.net/

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

I don't use Windows bbut feel free to add instructions here!

## Extra Files

### Documents directory

We have added the current Korean instructional material into Documents. These have been auto-translated into English. Improved translations welcome

### Korean_Codes directory

The mapping between the GNL_CD medication code and the generic name is supplied in 2 formats.

The KCD-7 disease codes are included but these do not seem to map to the codes in use.

## Running this code

```
$ rm -rf Results/*
$ Rscript extract.R
$ ls Results/
care_info_covid.csv              demographic_data.csv             medication_info_past_history.csv
care_info_past_history.csv       medication_info_covid.csv
$ 
```
