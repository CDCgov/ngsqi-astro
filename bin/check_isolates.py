#!/usr/bin/env python
import argparse
import csv
import logging
import sys
from pathlib import Path

logger = logging.getLogger()

class RowChecker:
    VALID_FORMATS = (
        ".fa",
        ".fasta",
        ".fna",
    )

    def __init__(self, sample_col="sample_id", copy_col="added_copy_number", file_col="file_path", species_col="species_name"):
        self._sample_col = sample_col
        self._copy_col = copy_col
        self._file_col = file_col
        self._species_col = species_col
        self._seen = set()
        self.modified = []
        self.mode = None

    def determine_mode(self, rows):
        file_paths = [row[self._file_col] for row in rows]
        if all(len(fp.strip()) == 0 for fp in file_paths):
            self.mode = "download"
        else:
            self.mode = "local"
        return self.mode

    def validate_and_transform(self, row):
        self._validate_sample(row)
        self._validate_copy_number(row)
        if self.mode == "local":
            self._validate_file(row)
        self._validate_species(row)
        self._seen.add((row[self._sample_col], row.get(self._file_col, None)))
        self.modified.append(row)

    def _validate_sample(self, row):
        if len(row[self._sample_col]) <= 0:
            raise AssertionError("Sample ID is required.")
        row[self._sample_col] = row[self._sample_col].replace(" ", "_")

    def _validate_copy_number(self, row):
        if not row[self._copy_col].isdigit() or int(row[self._copy_col]) < 0:
            raise AssertionError("Added copy number must be a non-negative integer.")

    def _validate_file(self, row):
        if len(row[self._file_col]) <= 0:
            raise AssertionError("File path is required.")
        self._validate_format(row[self._file_col])

    def _validate_species(self, row):
        if len(row[self._species_col]) <= 0:
            raise AssertionError("Species name is required.")

    def _validate_format(self, filename):
        if not any(filename.endswith(extension) for extension in self.VALID_FORMATS):
            raise AssertionError(f"The file has an unrecognized extension: {filename}\nIt should be one of: {', '.join(self.VALID_FORMATS)}")

    def validate_unique_samples(self):
        if len(self._seen) != len(self.modified):
            raise AssertionError("The pair of sample ID and file path must be unique.")

def read_head(handle, num_lines=10):
    lines = []
    for idx, line in enumerate(handle):
        if idx == num_lines:
            break
        lines.append(line)
    return "".join(lines)

def sniff_format(handle):
    peek = read_head(handle)
    handle.seek(0)
    sniffer = csv.Sniffer()
    dialect = sniffer.sniff(peek)
    return dialect

def check_isolate_samplesheet(file_in, file_out):
    required_columns = {"sample_id", "added_copy_number", "file_path", "species_name"}
    with file_in.open(newline="") as in_handle:
        reader = csv.DictReader(in_handle, dialect=sniff_format(in_handle))
        if not required_columns.issubset(reader.fieldnames):
            req_cols = ", ".join(required_columns)
            logger.critical(f"The sample sheet **must** contain these column headers: {req_cols}.")
            sys.exit(1)
        rows = list(reader)
        checker = RowChecker()
        mode = checker.determine_mode(rows) 
        logger.info(f"Detected mode: {mode}")
        for i, row in enumerate(rows):
            try:
                checker.validate_and_transform(row)
            except AssertionError as error:
                logger.critical(f"{str(error)} On line {i + 2}.")
                sys.exit(1)
        checker.validate_unique_samples()
    header = list(reader.fieldnames)
    with file_out.open(mode="w", newline="") as out_handle:
        writer = csv.DictWriter(out_handle, header, delimiter=",")
        writer.writeheader()
        for row in checker.modified:
            writer.writerow(row)

def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Validate and transform a tabular samplesheet.",
        epilog="Example: python check_isolate_samplesheet.py isolatesheet.csv isolatesheet.valid.csv",
    )
    parser.add_argument("file_in", metavar="FILE_IN", type=Path, help="Tabular input samplesheet in CSV or TSV format.")
    parser.add_argument("file_out", metavar="FILE_OUT", type=Path, help="Transformed output samplesheet in CSV format.")
    parser.add_argument(
        "-l",
        "--log-level",
        help="The desired log level (default WARNING).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="WARNING",
    )
    return parser.parse_args(argv)

def main(argv=None):
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")
    if not args.file_in.is_file():
        logger.error(f"The given input file {args.file_in} was not found!")
        sys.exit(2)
    args.file_out.parent.mkdir(parents=True, exist_ok=True)
    check_isolate_samplesheet(args.file_in, args.file_out)

if __name__ == "__main__":
    sys.exit(main())
