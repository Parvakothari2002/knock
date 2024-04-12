#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -f, --file <file>         CSV file to process (required)"
    echo "  -s, --start-date <date>   Start date for filtering (optional)"
    echo "  -e, --end-date <date>     End date for filtering (optional)"
    echo "  -c, --category <category> Product category for filtering (optional)"
    echo "  -o, --output <file>       Output file for the report (required)"
    echo "  -h, --help                Display this help message"
    exit 1
}

# Default values
start_date=""
end_date=""
category=""
output_file=""

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--file)
            file="$2"
            shift
            ;;
        -s|--start-date)
            start_date="$2"
            shift
            ;;
        -e|--end-date)
            end_date="$2"
            shift
            ;;
        -c|--category)
            category="$2"
            shift
            ;;
        -o|--output)
            output_file="$2"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
    shift
done

# Check if file option is provided
if [ -z "$file" ]; then
    echo "Error: Input CSV file is required."
    usage
fi

# Check if output file option is provided
if [ -z "$output_file" ]; then
    echo "Error: Output file is required."
    usage
fi

# Check if file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Filter data based on provided criteria
filtered_data=$(awk -F',' -v start="$start_date" -v end="$end_date" -v cat="$category" '{
    if ((start == "" || $1 >= start) && (end == "" || $1 <= end) && (cat == "" || $3 == cat)) {
        print $0
    }
}' "$file")

# Extract relevant information
total_sales=$(echo "$filtered_data" | awk -F',' '{ total += $2 } END { print total }')
average_sales=$(echo "$filtered_data" | awk -F',' '{ total += $2; count++ } END { if (count > 0) print total/count }')
best_selling_product=$(echo "$filtered_data" | awk -F',' '{ products[$3] += $2 } END { max_sales = 0; best_product = ""; for (product in products) { if (products[product] > max_sales) { max_sales = products[product]; best_product = product } } print best_product }')

# Generate summary report
echo "Summary Report:" > "$output_file"
echo "---------------------" >> "$output_file"
echo "Total Sales: $total_sales" >> "$output_file"
echo "Average Sales Per Month: $average_sales" >> "$output_file"
echo "Best Selling Product: $best_selling_product" >> "$output_file"

echo "Report generated successfully: $output_file"

