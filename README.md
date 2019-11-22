# DataSciMT Telegram Analysis

## Data extraction

The data was extracted from the Telegram group using the "Save Telegram Chat History" chrome extension. A custom format was used ("date|name|message") with "|" as delimiter to ensure that the message texts had the lowest chance of containing the delimiter as possible.

## Pre-procesing

All the preprocessing was performed with the R Language using the Tidyverse package bundle. The script is named "telegram_processing.R" in this repository.
