from Bio import Entrez
import sys
import time
import os
import random
from datetime import datetime

def parse_date(date_str):
    """Try multiple date formats"""
    formats = [
        '%Y/%m/%d %H:%M:%S',
        '%Y/%m/%d %H:%M',
        '%Y-%m-%d %H:%M:%S',
        '%Y-%m-%d %H:%M',
        '%Y/%m/%d',
        '%Y-%m-%d'
    ]
    
    for fmt in formats:
        try:
            return datetime.strptime(date_str, fmt)
        except ValueError:
            continue
    raise ValueError(f"Could not parse date: {date_str}")

def find_reference_genome_accession(species_name):
    email = os.environ.get('NCBI_EMAIL', None)
    api_key = os.environ.get('NCBI_API_KEY', None)
    print(f"Email configured: {'Yes' if email else 'No'}", file=sys.stderr)
    print(f"API key configured: {'Yes' if api_key else 'No'}", file=sys.stderr)
    
    if not email or not api_key:
        print("Missing required environment variables", file=sys.stderr)
        sys.exit(1)
        
    Entrez.email = email
    Entrez.api_key = api_key
    cutoff_date = datetime.strptime('2024/12/31', '%Y/%m/%d')
    
    max_attempts = 5
    for attempt in range(max_attempts):
        try:
            time.sleep(random.uniform(3, 5))
            
            # Basic query with sorting by date
            query = f'"{species_name}"[Organism] AND "latest refseq"[filter]'
            print(f"Trying query: {query}", file=sys.stderr)
            
            handle = Entrez.esearch(db="assembly", term=query, retmax=100, sort="Date Released")
            record = Entrez.read(handle)
            handle.close()
            
            count = int(record["Count"])
            print(f"Found {count} matching assemblies", file=sys.stderr)
            
            if count == 0:
                # Try alternative query
                time.sleep(random.uniform(3, 5))
                alt_query = f'"{species_name}"[Organism] AND refseq[filter]'
                print(f"Trying alternative query: {alt_query}", file=sys.stderr)
                handle = Entrez.esearch(db="assembly", term=alt_query, retmax=100)
                record = Entrez.read(handle)
                handle.close()
                count = int(record["Count"])
                print(f"Found {count} matching assemblies with alternative query", file=sys.stderr)
            
            if count == 0:
                print("No assemblies found", file=sys.stderr)
                return None
            
            # Try each assembly until we find a suitable one
            for assembly_id in record["IdList"]:
                print(f"Checking assembly ID: {assembly_id}", file=sys.stderr)
                
                time.sleep(random.uniform(3, 5))
                summary_handle = Entrez.esummary(db="assembly", id=assembly_id)
                summary_record = Entrez.read(summary_handle)
                summary_handle.close()
                
                assembly_info = summary_record['DocumentSummarySet']['DocumentSummary'][0]
                accession = assembly_info['AssemblyAccession']
                
                if not accession.startswith('GCF_'):
                    print(f"Skipping non-GCF accession: {accession}", file=sys.stderr)
                    continue
                
                submission_date = assembly_info.get('SubmissionDate', '')
                if submission_date:
                    try:
                        parsed_date = parse_date(submission_date)
                        print(f"Assembly date: {parsed_date.date()}", file=sys.stderr)
                        if parsed_date > cutoff_date:
                            print(f"Assembly too recent ({parsed_date.date()}), skipping", file=sys.stderr)
                            continue
                        print(f"Found valid assembly: {accession} from {parsed_date.date()}", file=sys.stderr)
                        return accession
                    except ValueError as e:
                        print(f"Warning: Could not parse date {submission_date}, skipping: {str(e)}", file=sys.stderr)
                        continue
                
            print("No valid assemblies found in results", file=sys.stderr)
            return None
            
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {str(e)}", file=sys.stderr)
            if attempt < max_attempts - 1:
                sleep_time = min(60, 2 ** attempt + random.uniform(0, 1))
                print(f"Retrying in {sleep_time:.2f} seconds...", file=sys.stderr)
                time.sleep(sleep_time)
            else:
                raise

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Error: Species name required", file=sys.stderr)
        sys.exit(1)
        
    species_name = sys.argv[1]
    print(f"Starting search for: {species_name}", file=sys.stderr)
    
    try:
        accession_number = find_reference_genome_accession(species_name)
        
        if accession_number:
            print(f"Found valid accession: {accession_number}", file=sys.stderr)
            print(accession_number)
            sys.exit(0)
        else:
            print("No valid reference genome found", file=sys.stderr)
            sys.exit(1)
        
    except Exception as e:
        print(f"Error occurred: {str(e)}", file=sys.stderr)
        sys.exit(1)