from Bio import Entrez
import sys
import time
import os
import random

def find_reference_genome_accession(species_name):
    Entrez.email = os.environ.get('NCBI_EMAIL', None)
    Entrez.api_key = os.environ.get('NCBI_API_KEY', None)
    
    max_attempts = 5
    for attempt in range(max_attempts):
        try:
            time.sleep(random.uniform(3, 5))  # Random delay between 3 and 5 seconds
            handle = Entrez.esearch(db="assembly", term=f"{species_name}[orgn] AND latest_refseq[filter]", retmax=1)
            record = Entrez.read(handle)
            handle.close()
            
            if record["Count"] == "0":
                return None
            
            assembly_id = record["IdList"][0]
            time.sleep(random.uniform(3, 5))  # Another random delay
            summary_handle = Entrez.esummary(db="assembly", id=assembly_id)
            summary_record = Entrez.read(summary_handle)
            summary_handle.close()
            
            accession = summary_record['DocumentSummarySet']['DocumentSummary'][0]['AssemblyAccession']
            return accession
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {str(e)}", file=sys.stderr)
            if attempt < max_attempts - 1:
                sleep_time = min(60, 2 ** attempt + random.uniform(0, 1))  # Cap at 60 seconds
                print(f"Retrying in {sleep_time:.2f} seconds...", file=sys.stderr)
                time.sleep(sleep_time)
            else:
                raise

if __name__ == "__main__":
    species_name = sys.argv[1]
    print(f"Searching for: {species_name}", file=sys.stderr)
    try:
        accession_number = find_reference_genome_accession(species_name)
        
        if accession_number:
            print(f"Found accession: {accession_number}", file=sys.stderr)
            print(accession_number)
        else:
            print("No reference genome found", file=sys.stderr)
            print("GCF_000000000.1")  # Dummy accession number
    except Exception as e:
        print(f"Error occurred: {str(e)}", file=sys.stderr)
        print("GCF_000000000.1")  # Dummy accession number in case of error