# Adding Custom Data to the Ellis Pipeline

This guide explains how to add your own custom data sources to the Ellis Pipeline Stage 2 without modifying any R scripts.

## 🎯 Quick Start

1. **Edit Configuration**: Open `manipulation/extra-data-config.R`
2. **Add Your Data Source**: Copy a template and modify it
3. **Set Active**: Change `active = FALSE` to `active = TRUE`
4. **Run Pipeline**: Execute `Rscript manipulation/2-ellis-extra.R`

## 🌍 Bilingual Support (Ukrainian ↔ English)

The Ellis Pipeline Stage 2 **automatically handles both Ukrainian and English column names**:

**✅ Ukrainian Input (Natural for Ukrainian Users)**:

```
Показник              | Територія           | 2023
Кількість книгарень   | Івано-Франківська  | 19
```

**✅ English Input (For Standardization)**:

```
Measure               | Territory           | 2023
Number of Bookstores  | Ivano-Frankivska    | 19
```

**🔄 Automatic Standardization**:

- All inputs are converted to English internally ("pokaznik", "teritoria")
- Ensures consistency with core pipeline (Stages 0-1)
- No manual translation required by users
- Both formats work seamlessly

**📝 Supported Ukrainian → English Mappings**:

- `Показник` / `показник` → `pokaznik` (measure/indicator)
- `Територія` / `територія` → `teritoria` (territory/region)
- `Область` / `область` → `oblast` (oblast)
- `Рік` / `рік` → `year` (year)

*You can use either language consistently throughout your data - the system will handle the standardization automatically!*

## 📊 Supported Data Types

### 1. Categorical Time Series (`categorical_time_series`)

**Best for**: Data organized as dimensions × years (similar to core pipeline data)

**Format Requirements**:

- `pokaznik` column (measure type)
- Category column (e.g., region names, themes)
- Year columns (`x2005`, `x2006`, etc.)

**Example Use Cases**:

- Bookstores by region over time ✅ (currently implemented)
- Libraries by oblast over time
- Cultural events by city over time
- Educational institutions by region

**Google Sheets Structure**:

```
pokaznik          | teritoria           | x2020 | x2021 | x2022 | x2023
Кількість книгарень | Івано-Франківська  |   18  |   19  |   19  |   19
Кількість книгарень | Львівська          |   45  |   48  |   50  |   50
```

### 2. Lookup Table (`lookup_table`)

**Best for**: Reference data and mappings

**Format Requirements**:

- Clear key columns for joining
- Consistent data types

**Example Use Cases**:

- Region code mappings
- Publisher classifications
- Author biographical data
- ISBN to metadata mappings

**Google Sheets Structure**:

```
region_name        | region_code | population | area_km2
Івано-Франківська | IF          | 1400000    | 13900
Львівська         | LV          | 2500000    | 21800
```

### 3. Fact Table (`fact_table`)

**Best for**: Event data and simple tabular information

**Format Requirements**:

- Consistent column structure
- Clean data types

**Example Use Cases**:

- Book fair events
- Publisher survey responses
- Literary award winners
- Author interviews

**Google Sheets Structure**:

```
event_name        | date       | location      | attendance | books_sold
Lviv Book Forum   | 2023-09-15 | Lviv          | 25000      | 1200
Kyiv Book Arsenal | 2023-05-20 | Kyiv          | 30000      | 1800
```

## ⚙️ Configuration Examples

### Adding Bookstores Data (Already Implemented)

```r
bookstores = list(
  name = "Ukrainian Bookstores by Region",
  description = "Number of bookstores per region for 2023",
  url = "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID",
  data_type = "categorical_time_series",
  active = TRUE,
  processing_notes = list(
    sheet_mapping = list("Книгарні" = "bookstores"),
    measure_mapping = list("Кількість книгарень" = "bookstore_count"),
    expected_sheets = c("Книгарні")
  )
)
```

### Adding Libraries Data (Template)

```r
libraries = list(
  name = "Public Libraries by Region",
  description = "Number of public libraries per region over time",
  url = "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID",
  data_type = "categorical_time_series",
  active = TRUE,  # Set to TRUE when ready
  processing_notes = list(
    sheet_mapping = list("Бібліотеки" = "libraries"),
    measure_mapping = list(
      "Кількість бібліотек" = "library_count",
      "Кількість відвідувачів" = "visitor_count"
    ),
    expected_sheets = c("Бібліотеки")
  )
)
```

### Adding Region Codes (Template)

```r
region_codes = list(
  name = "Region Code Mappings",
  description = "Official codes and metadata for Ukrainian regions",
  url = "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID",
  data_type = "lookup_table",
  active = TRUE,  # Set to TRUE when ready
  processing_notes = list(
    key_columns = c("region_name", "region_code"),
    expected_sheets = c("RegionCodes")
  )
)
```

## 🔧 Step-by-Step Setup

### Step 1: Prepare Your Google Sheet

1. **Create or access** your Google Sheets document
2. **Set sharing** to the same level as the main data (usually "Anyone with the link can view")
3. **Structure your data** according to one of the supported types above
4. **Name your sheets** clearly (you'll reference these names in configuration)

### Step 2: Get Your Sheet ID

From a URL like:
`https://docs.google.com/spreadsheets/d/1ovYOr_jmdDprYjcGMWAa-w9D1-h7kwwjbRgUgVtlUa0/edit`

The Sheet ID is: `1ovYOr_jmdDprYjcGMWAa-w9D1-h7kwwjbRgUgVtlUa0`

### Step 3: Configure Your Data Source

1. **Open** `manipulation/extra-data-config.R`
2. **Find** the appropriate template for your data type
3. **Uncomment** the template code
4. **Modify** the configuration:
   - Change the `name` and `description`
   - Update the `url` with your Sheet ID
   - Adjust `sheet_mapping` for your sheet names
   - Update `measure_mapping` for your measures
   - Set `active = TRUE`

### Step 4: Test Your Configuration

```r
# Run the extra data script
source("manipulation/2-ellis-extra.R")
```

**Watch for**:

- ✅ "Loaded: X rows × Y columns" (data loaded successfully)
- ✅ "Processed: X records for table: your_table" (processing successful)
- ❌ Error messages (fix issues in your Google Sheet)

### Step 5: Verify Integration

```r
# Run the complete pipeline
source("manipulation/0-ellis.R")
source("manipulation/1-ellis-ua-admin.R")
source("manipulation/2-ellis-extra.R")
source("manipulation/last-ellis.R")
```

**Check outputs**:

- Your tables appear in the final SQLite database
- CSV files are created in `data-private/derived/manipulation/CSV/`
- Tables are named `ds_your_table` and `ds_your_table_wide`

## 🚨 Troubleshooting

### Common Issues

**"Sheet not found"**:

- Check sheet name spelling in `expected_sheets`
- Verify the sheet exists in your Google document

**"No category column detected"**:

- For categorical time series, ensure you have a non-year, non-pokaznik column
- Manually specify using `category_column_detection = "your_column_name"`

**"Missing pokaznik column"**:

- For categorical time series, you must have a column named "pokaznik"
- This column defines what each row measures

**"Error loading sheet"**:

- Check Google Sheets sharing permissions
- Verify the Sheet ID in your URL
- Ensure authentication is working (run core pipeline first)

### Validation Errors

The system validates your data before processing:

- **Required columns** must be present
- **Year columns** must follow x2023 format
- **Data types** must be consistent

Fix issues in your Google Sheet and re-run the script.

## 📈 Advanced Tips

### Custom Measure Mappings

```r
measure_mapping = list(
  "Кількість книгарень" = "bookstore_count",
  "Середня площа" = "average_area_sqm",
  "Кількість працівників" = "employee_count"
)
```

### Multiple Sheets per Data Source

```r
expected_sheets = c("MainData", "AdditionalData", "Metadata")
```

### Sheet-Specific Table Keys

```r
sheet_mapping = list(
  "Головні дані" = "main_data",
  "Додаткові дані" = "additional_data"
)
```

## 🎯 Best Practices

1. **Start Small**: Begin with one simple data source to test the system
2. **Consistent Naming**: Use clear, descriptive names for sheets and columns
3. **Data Quality**: Clean your data before adding to Google Sheets
4. **Documentation**: Update your data source descriptions clearly
5. **Testing**: Always test with `active = FALSE` first, then enable

## 🆘 Getting Help

1. **Check the console output** for specific error messages
2. **Review the templates** in `extra-data-config.R`
3. **Examine working examples** like the bookstores data source
4. **Validate your Google Sheets structure** against the examples above

The modular design makes it easy to add new data sources without touching any core pipeline code! 🚀
