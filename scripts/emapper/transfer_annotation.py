"""
Script name: transfer_name.py
Description:
    Transfer attributes from mRNA to CDS and gene

Usage:
    python transfer_name.py -i input.gff3 -o output.gff3

"""
##load modules
import argparse
import gffutils

## define main function
def transfer_annotation(input_gff, output_gff):
    db = gffutils.create_db(input_gff, dbfn=":memory:", merge_strategy="merge", keep_order=True)
    
    with open(output_gff, "w") as out:
        for feature in db.all_features():

            if feature.featuretype == "gene":
                mRNAs = list(db.children(feature, featuretype="mRNA"))
                if mRNAs:
                    mRNA = mRNAs[0]
                    em_preferred_name_list = mRNA.attributes.get("em_Preferred_name", [])
                    feature.attributes["Name"] = [em_preferred_name_list[0]] if em_preferred_name_list else ["unknown_gene"]
                else:
                    feature.attributes["Name"] = ["unknown_gene"]

            elif feature.featuretype == "CDS":
                parents = list(db.parents(feature, featuretype="mRNA"))
                if parents:
                    mRNA = parents[0]
                    em_preferred_name_list = mRNA.attributes.get("em_Preferred_name", [])
                    feature.attributes["product"] = [em_preferred_name_list[0]] if em_preferred_name_list else ["hypothetical protein"]

            out.write(str(feature) + "\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Transfer em_Preferred_name from mRNA to gene/CDS in GFF3 file.")
    parser.add_argument("-i", "--input", required=True, help="Input GFF3 file")
    parser.add_argument("-o", "--output", required=True, help="Output GFF3 file")
    args = parser.parse_args()
    
    transfer_annotation(args.input, args.output)
