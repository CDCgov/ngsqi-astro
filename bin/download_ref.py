from Bio import Entrez
import sys
import time
import os
import random

def find_reference_genome_accession(species_name):
    email = os.environ.get('NCBI_EMAIL')
    api_key = os.environ.get('NCBI_API_KEY')
    if api_key and '-' in api_key:
        api_key = api_key.split('-')[0]
        
    Entrez.email = email
    Entrez.api_key = api_key

    def safe_entrez_call(func, **kwargs):
        max_attempts = 3
        base_delay = 3
        
        for attempt in range(max_attempts):
            try:
                time.sleep(base_delay + random.uniform(0, 2))
                handle = func(**kwargs)
                result = Entrez.read(handle)
                handle.close()
                return result
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {str(e)}", file=sys.stderr)
                if attempt < max_attempts - 1:
                    delay = base_delay * (attempt + 2) + random.uniform(0, 2)
                    print(f"Waiting {delay:.1f} seconds before retry...", file=sys.stderr)
                    time.sleep(delay)
                else:
                    raise

    try:
        print(f"Searching for assemblies of {species_name}...", file=sys.stderr)
        record = safe_entrez_call(
            Entrez.esearch,
            db="assembly",
            term=f'{species_name}[Organism] AND (refseq[filter] OR "reference genome"[filter])',
            retmax=100
        )

        if not record["IdList"]:
            print(f"No assemblies found for {species_name}", file=sys.stderr)
            return None

        best_assembly = None
        best_score = -1

        for assembly_id in record["IdList"]:
            summary = safe_entrez_call(
                Entrez.esummary,
                db="assembly",
                id=assembly_id
            )

            doc = summary['DocumentSummarySet']['DocumentSummary'][0]
            accession = doc['AssemblyAccession']
            
            if not accession.startswith('GCF_'):
                continue

            acc_num = int(accession.split('_')[1].split('.')[0])
            
            level = doc['AssemblyStatus']
            n50 = int(doc.get('ContigN50', 0))
            contig_count = int(doc.get('ContigCount', 0))
            total_length = int(doc.get('TotalSequenceLength', 0))
            
            # Calculate N50 ratio safely
            n50_ratio = n50 / total_length if total_length > 0 else 0
            
            score = 0
            
            # Assembly level scoring - dramatically increased weight for Complete Genome
            if level == "Complete Genome":
                score += 300
            elif level == "Chromosome":
                score += 50
            
            # Contig count scoring - much stricter
            if contig_count > 0:
                if contig_count < 10:
                    score += 50
                elif contig_count < 20:
                    score += 30
                elif contig_count < 50:
                    score += 10
            
            # N50 scoring relative to genome size
            if n50_ratio > 0:  # Only score if we have a valid ratio
                if n50_ratio > 0.5:
                    score += 40
                elif n50_ratio > 0.2:
                    score += 30
                elif n50_ratio > 0.1:
                    score += 20
            
            # Age scoring - reduced importance
            if acc_num < 40000000 and acc_num >= 20000000:
                score += 35
            elif acc_num < 20000000:
                score += 25
            else:
                score += 15

            print(f"Found: {accession}", file=sys.stderr)
            print(f"Level: {level}", file=sys.stderr)
            print(f"Contigs: {contig_count}", file=sys.stderr)
            print(f"N50 ratio: {n50_ratio:.3f}", file=sys.stderr)
            print(f"Assembly level score: {300 if level == 'Complete Genome' else (50 if level == 'Chromosome' else 0)}", file=sys.stderr)
            print(f"Contig score: {50 if contig_count < 10 else (30 if contig_count < 20 else (10 if contig_count < 50 else 0))}", file=sys.stderr)
            print(f"N50 score: {40 if n50_ratio > 0.5 else (30 if n50_ratio > 0.2 else (20 if n50_ratio > 0.1 else 0))}", file=sys.stderr)
            print(f"Age score: {35 if (acc_num < 40000000 and acc_num >= 20000000) else (25 if acc_num < 20000000 else 15)}", file=sys.stderr)
            print(f"Total score: {score}", file=sys.stderr)
            print("---", file=sys.stderr)

            if score > best_score:
                best_score = score
                best_assembly = accession

        if best_assembly:
            print(f"Selected best assembly: {best_assembly}", file=sys.stderr)
            return best_assembly
        return None

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py 'Species name'", file=sys.stderr)
        sys.exit(1)

    species_name = sys.argv[1].strip()
    accession = find_reference_genome_accession(species_name)
    
    if accession:
        print(accession)
        sys.exit(0)
    else:
        sys.exit(1)