#!/usr/bin/env 
import csv
import sys

def parse_coords(row, start_idx, end_idx):
    s = int(row[start_idx])
    e = int(row[end_idx])
    return min(s, e), max(s, e)

def build_gaps(blocks):
    gaps = []

    if not blocks:
        return gaps

    # Gap before first block
    first_start, first_end, first_id = blocks[0]
    if first_start > 1:
        gaps.append((1, first_start - 1, None, first_id))

    # Gaps between consecutive blocks
    for (prev_s, prev_e, prev_id), \
        (cur_s, cur_e, cur_id) in zip(blocks, blocks[1:]):

        if cur_s > prev_e + 1:
            gaps.append((prev_e + 1, cur_s - 1,
                         prev_id, cur_id))

    return gaps

def main(in_path, out_path, ref_gen, query_gen, 
         chrom_idx=2, start_idx=5, end_idx=6,
         block_idx=4):

    chrom_blocks = {}

    with open(in_path, newline='') as fh:
        reader = csv.reader(fh, delimiter=',')
        next(reader)  # skip header

        for row in reader:
            if not row:
                continue

            if row[0] != ref_gen or row[1] != query_gen:
                continue

            chrom = row[chrom_idx]
            block_id = row[block_idx]

            s, e = parse_coords(row, start_idx, end_idx)

            chrom_blocks.setdefault(chrom, []).append(
                (s, e, block_id)
            )

    # Sort blocks per chromosome
    for chrom in chrom_blocks:
        chrom_blocks[chrom].sort(key=lambda x: x[0])

    # Write modified BED output (0-based start)
    with open(out_path, 'w', newline='') as out_fh:
        writer = csv.writer(out_fh, delimiter='\t')

        # Header
        writer.writerow([
            "chrom",
            "start",
            "end",
            "upstream_block",
            "downstream_block"
        ])

        for chrom in sorted(chrom_blocks):
            blocks = chrom_blocks[chrom]
            gaps = build_gaps(blocks)

            for gap_start, gap_end, upstream_id, downstream_id in gaps:
                bed_start = gap_start - 1  # convert to 0-based
                bed_end = gap_end

                # Remove rows where start becomes 0
                if bed_start == 0:
                    continue

                writer.writerow([
                    f"chr{chrom}",
                    bed_start,
                    bed_end,
                    upstream_id if upstream_id else ".",
                    downstream_id if downstream_id else "."
                ])

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
