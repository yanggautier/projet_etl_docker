import pandas as pd
import sys
import os


def convert_date_format(date_string: str):
    formats = ['%Y-%m-%d', '%d-%m-%Y', '%d/%m/%Y']
    for fmt in formats:
        try:
            return pd.to_datetime(date_string, format=fmt).strftime('%Y-%m-%d')
        except ValueError:
            continue
    raise ValueError(f"Unable to parse date: {date_string}")


def preprocess(input_csv: str, output_csv: str) -> None:
    # Read input CSV file
    df = pd.read_csv(input_csv)
    df.dropna(inplace=True)
    df = df[df["quantity"] > 0]
    df["postal_code"] = df["postal_code"].astype(int).astype(str)
    df['order_date'] = df['order_date'].apply(convert_date_format)
    df['ship_date'] = df['ship_date'].apply(convert_date_format)

    # Write preprocessed data to a new CSV file
    df.to_csv(output_csv, index=False)
    print("Preprocessing completed successfully.")


if __name__ == "__main__":
    input_file = '/app/data/SuperStoreRawData.csv'
    output_file = '/app/data/preprocessed_output.csv'

    if not os.path.exists(input_file):
        print(f"Input file '{input_file}' does not exist.")
        sys.exit(1)  # Exit with error code

    if not os.path.exists(output_file):
        try:
            preprocess(input_file, output_file)
            # sys.exit(0)  # Exit with success code
        except Exception as e:
            print(f"An error occurred during preprocessing: {e}")
            sys.exit(1)  # Exit with error code
