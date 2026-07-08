#!/usr/bin/env python3

"""
Centromeric and Telomeric Repeat Visualization for H. diminuta genome.
 
Outputs:
  1. Chromosome figure (3-panel: left zoom | main | right zoom) for chromosomes 1-6
  2. Contig figure (full-length) for unplaced contigs with repeat signal
 
Usage:
  python centromere_telomere_plot.py
"""
import os
import sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")  # non-interactive backend for script mode
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.lines import Line2D
import matplotlib.ticker as mtick
from matplotlib.gridspec import GridSpec

print(f"Python version: {sys.version}")
## input files
# input files
REPEAT_BED  = "/Users/skc49482/Documents/UGA/PhD/Genome_Assembly/Plots/centromere_Telomere_plot/repeat_regions.bed"
LENGTHS_CSV = "/Users/skc49482/Documents/UGA/PhD/Genome_Assembly/Plots/centromere_Telomere_plot/seq_stats.csv"
TOP10_BED   = "/Users/skc49482/Documents/UGA/PhD/Genome_Assembly/Plots/centromere_Telomere_plot/top10_repeats.bed"
TIDK_TSV    = "/Users/skc49482/Documents/UGA/PhD/Genome_Assembly/Plots/centromere_Telomere_plot/all_contig_TTAGGG_telomeric_repeat_windows.tsv"

# chromosome vs contigs
CHROM_NAMES = {"1", "2", "3", "4", "5", "6"}
MITO_NAMES  = {"7"}

# figure parameters
DPI            = 600
ZOOM_MB        = 1
HIGHLIGHT_N    = 10
TELO_THRESHOLD = 50
BINS_PER_MB    = 80
ROW_HEIGHT     = 0.16
ROW_GAP        = 0.06
 
# colors in RGB format
TELOMERE_COLOR = (1.0, 0.08, 0.58)
OTHER_COLOR    = (0.85, 0.85, 0.85)
 
# output directory
OUT_DIR = "/Users/skc49482/Documents/UGA/PhD/Genome_Assembly/Plots/centromere_Telomere_plot/Figures_paper"

# Data loading functions
def load_chromosome_lengths(filepath):
    df = pd.read_csv(filepath, sep="\t", header=None,
                     names=["seq", "length"],
                     dtype={"seq": str, "length": str})
    df["seq"] = df["seq"].str.split().str[0]
    df["length"] = df["length"].astype(int)
    chrom_order = list(dict.fromkeys(df["seq"].tolist()))
    chrom_len_map = dict(zip(df["seq"], df["length"]))
    return chrom_order, chrom_len_map
 
 
def load_centromere_repeats(filepath, valid_chroms):
    df = pd.read_csv(filepath, sep="\t", header=None,
                     names=["seq", "start", "end", "unit_len"],
                     dtype={"seq": str, "start": int, "end": int, "unit_len": int})
    df = df[(df["end"] > df["start"]) & (df["start"] >= 0)].copy()
    df = df[df["seq"].isin(valid_chroms)].copy()
    return df
 
 
def load_tidk_telomere(filepath, valid_chroms):
    raw = pd.read_csv(filepath, sep="\t", header=0)
    id_col = "id" if "id" in raw.columns else raw.columns[0]
    raw = raw.sort_values([id_col, "window"]).reset_index(drop=True)
 
    records = []
    prev_seq = None
    prev_end = 0
 
    for _, row in raw.iterrows():
        seq = str(row[id_col])
        window_end = int(row["window"])
        if seq != prev_seq:
            window_start = 0
            prev_seq = seq
        else:
            window_start = prev_end
        prev_end = window_end
        total = int(row["forward_repeat_number"]) + int(row["reverse_repeat_number"])
        records.append({"seq": seq, "window_start": window_start,
                        "window_end": window_end, "total_count": total})
 
    df = pd.DataFrame(records)
    df = df[df["seq"].isin(valid_chroms)].copy()
    print(f"Loaded tidk: {len(df)} windows, {df['seq'].nunique()} sequences")
    return df
 
 
def build_color_map(repeats_df, top10_path, n_colors=10):
    if os.path.exists(top10_path):
        top10 = pd.read_csv(top10_path, sep="\t", header=None,
                            names=["seq", "unit_len", "span_len"], dtype=str)
        top10["unit_len"] = top10["unit_len"].str.extract(r"(\d+)", expand=False).astype(float)
        top10["span_len"] = pd.to_numeric(top10["span_len"], errors="coerce")
        ranking = (top10.dropna(subset=["unit_len", "span_len"])
                   .groupby("unit_len")["span_len"].sum()
                   .sort_values(ascending=False))
    else:
        ranking = (repeats_df.groupby("unit_len")["end"].count()
                   .sort_values(ascending=False))
 
    highlight_units = [int(u) for u in ranking.head(n_colors).index]
    cycle = plt.rcParams["axes.prop_cycle"].by_key().get("color", [])
    while len(cycle) < len(highlight_units):
        cycle = cycle * 2
    unit_to_color = {u: cycle[i] for i, u in enumerate(highlight_units)}
    return highlight_units, unit_to_color

## drawing functions
def draw_chromosome_backbones(ax, chrom_order, chrom_len_map,
                              is_zoom=False, zoom_width=None,
                              label_size=9, line_width=0.8):
    y = 0.0
    row_y = {}
    clip_patches = {}
 
    for seq in chrom_order:
        length = chrom_len_map.get(seq, 0)
        if length <= 0:
            continue
        width = min(zoom_width, length) if is_zoom else length
        backbone = Rectangle((0, y), width, ROW_HEIGHT,
                              facecolor="white", edgecolor="black",
                              linewidth=line_width)
        ax.add_patch(backbone)
        row_y[seq] = y
        clip_patches[seq] = backbone
        y += ROW_HEIGHT + ROW_GAP
 
    ax.set_ylim(-ROW_GAP * 0.25, y - ROW_GAP + ROW_HEIGHT + ROW_GAP * 0.25)
    ax.set_yticks([])
    for spine in ("left", "right", "top"):
        ax.spines[spine].set_visible(False)
    ax.spines["bottom"].set_linewidth(0.8)
 
    for seq, y_pos in row_y.items():
        ax.annotate(seq, xy=(0, y_pos + ROW_HEIGHT / 2), xytext=(-6, 0),
                    textcoords="offset points", ha="right", va="center",
                    fontsize=label_size, clip_on=False)
    return row_y, clip_patches
 
 
def _get_zoom_window(chrom_length, side, zoom_width):
    if side == "left":
        return 0, min(zoom_width, chrom_length), 0
    else:
        win_start = max(0, chrom_length - zoom_width)
        return win_start, chrom_length, win_start
 
 
def draw_centromere_repeats(ax, row_y, repeats_df, chrom_len_map,
                            chrom_order, unit_to_color,
                            clip_patches=None,
                            is_zoom=False, side=None,
                            zoom_width=None, n_bins=None, bin_edges=None):
    bar_height = ROW_HEIGHT * 0.50
 
    if not is_zoom:
        for seq in chrom_order:
            if seq not in row_y:
                continue
            sub = repeats_df[repeats_df["seq"] == seq]
            y_base = row_y[seq]
            chrom_len = chrom_len_map[seq]
 
            for _, r in sub.iterrows():
                s, e = int(r["start"]), min(int(r["end"]), chrom_len)
                if e <= s:
                    continue
                color = unit_to_color.get(int(r["unit_len"]), OTHER_COLOR)
                ax.add_patch(
                    Rectangle((s, y_base), e - s, bar_height,
                              facecolor=color, edgecolor=None, alpha=0.95)
                )
        return
 
    bin_width = bin_edges[1] - bin_edges[0]
 
    for seq in chrom_order:
        if seq not in row_y:
            continue
        chrom_len = chrom_len_map.get(seq, 0)
        if chrom_len <= 0:
            continue
 
        win_start, win_end, shift = _get_zoom_window(chrom_len, side, zoom_width)
        draw_limit = min(chrom_len, zoom_width)
        sub = repeats_df[repeats_df["seq"] == seq]
 
        coverage = {u: np.zeros(n_bins) for u in unit_to_color}
        coverage_other = np.zeros(n_bins)
 
        for _, r in sub.iterrows():
            s = max(int(r["start"]), win_start)
            e = min(int(r["end"]), win_end)
            if e <= s:
                continue
            s_shifted = s - shift
            e_shifted = e - shift
            unit = int(r["unit_len"])
 
            i0 = max(0, np.searchsorted(bin_edges, s_shifted, side="right") - 1)
            i1 = min(n_bins, np.searchsorted(bin_edges, e_shifted, side="left"))
            if i1 <= i0:
                continue
 
            for i in range(i0, i1):
                overlap = max(0.0, min(e_shifted, bin_edges[i + 1]) - max(s_shifted, bin_edges[i]))
                if overlap <= 0:
                    continue
                if unit in coverage:
                    coverage[unit][i] += overlap
                else:
                    coverage_other[i] += overlap
 
        y_base = row_y[seq]
        for i in range(n_bins):
            x0 = bin_edges[i]
            if x0 >= draw_limit:
                break
 
            best_unit, best_cov = None, 0.0
            for unit, arr in coverage.items():
                if arr[i] > best_cov:
                    best_cov = arr[i]
                    best_unit = unit
 
            if best_cov >= coverage_other[i] and best_cov > 0:
                color = unit_to_color.get(best_unit, OTHER_COLOR)
                fill = min(1.0, best_cov / bin_width)
            elif coverage_other[i] > 0:
                color = OTHER_COLOR
                fill = min(1.0, coverage_other[i] / bin_width)
            else:
                continue
 
            x1 = min(bin_edges[i + 1], draw_limit)
            ax.add_patch(
                Rectangle((x0, y_base), x1 - x0, bar_height,
                           facecolor=color, edgecolor=None,
                           alpha=0.35 + 0.6 * fill)
            )
 
 
def draw_telomere_repeats(ax, row_y, tidk_df, chrom_len_map, chrom_order,
                          clip_patches=None,
                          is_zoom=False, side=None, zoom_width=None):
    if tidk_df is None or tidk_df.empty:
        return
 
    bar_height = ROW_HEIGHT * 0.50
 
    for seq in chrom_order:
        if seq not in row_y:
            continue
 
        sub = tidk_df[(tidk_df["seq"] == seq) &
                      (tidk_df["total_count"] > TELO_THRESHOLD)].copy()
        if sub.empty:
            continue
 
        chrom_len = chrom_len_map[seq]
        y_top = row_y[seq] + ROW_HEIGHT * 0.5
        draw_limit = min(chrom_len, zoom_width) if is_zoom else chrom_len
 
        if is_zoom and side:
            win_start, win_end, shift = _get_zoom_window(chrom_len, side, zoom_width)
            sub = sub[(sub["window_end"] > win_start) &
                      (sub["window_start"] < win_end)].copy()
            if sub.empty:
                continue
            sub["window_start"] = sub["window_start"] - shift
            sub["window_end"] = sub["window_end"] - shift
            sub = sub[(sub["window_start"] >= 0) &
                      (sub["window_start"] < draw_limit)].copy()
            if sub.empty:
                continue
 
        max_count = sub["total_count"].max()
        if max_count == 0:
            continue
 
        for _, row_data in sub.iterrows():
            start = int(row_data["window_start"])
            end = int(row_data["window_end"])
            count = row_data["total_count"]
 
            if start < 0 or start >= draw_limit:
                continue
            end = min(end, draw_limit)
            if end <= start:
                continue
 
            intensity = min(1.0, count / max_count)
            alpha = 0.5 + 0.5 * intensity
            ax.add_patch(
                Rectangle((start, y_top), end - start, bar_height,
                           facecolor=(*TELOMERE_COLOR, alpha),
                           edgecolor=None, linewidth=0)
            )
 
 
def build_legend(ax, highlight_units, unit_to_color, repeats_df, has_telomere,
                 anchor=(0.9, 1.10), loc="upper left"):
    handles = []
    for u in highlight_units:
        handles.append(Line2D([0], [0], marker="s", linestyle="",
                              markerfacecolor=unit_to_color[u],
                              markeredgecolor="none", markersize=8,
                              label=f"{u} bp"))
    if (~repeats_df["unit_len"].isin(highlight_units)).any():
        handles.append(Line2D([0], [0], marker="s", linestyle="",
                              markerfacecolor=OTHER_COLOR,
                              markeredgecolor="none", markersize=8,
                              label="Other"))
    if has_telomere:
        handles.append(Line2D([0], [0], marker="s", linestyle="",
                              markerfacecolor=TELOMERE_COLOR,
                              markeredgecolor="none", markersize=8,
                              label="Telomeric repeats"))
    ax.legend(handles=handles, title="Repeat Features",
              bbox_to_anchor=anchor, loc=loc,
              frameon=True, fontsize=9, title_fontsize=10,
              framealpha=0.9, edgecolor="black", fancybox=False)
 
# main 
def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("Loading data...")
    all_order, all_len_map = load_chromosome_lengths(LENGTHS_CSV)
    all_repeats = load_centromere_repeats(REPEAT_BED, set(all_order))
    all_tidk = load_tidk_telomere(TIDK_TSV, set(all_order))
 
    print(f"Total sequences loaded: {len(all_order)}")
    print(f"Total repeat regions: {len(all_repeats)}")
    print(f"Total tidk windows: {len(all_tidk)}")
    
     # Split into chromosomes (1-6) and contigs (rest, minus mito)
    chrom_order = [s for s in all_order if s in CHROM_NAMES]
    chrom_len_map = {s: all_len_map[s] for s in chrom_order}
    repeats = all_repeats[all_repeats["seq"].isin(CHROM_NAMES)].copy()
    tidk = all_tidk[all_tidk["seq"].isin(CHROM_NAMES)].copy()
 
    contig_names = set(all_order) - CHROM_NAMES - MITO_NAMES
    contig_order = [s for s in all_order if s in contig_names]
    contig_len_map = {s: all_len_map[s] for s in contig_order}
    contig_repeats = all_repeats[all_repeats["seq"].isin(contig_names)].copy()
    contig_tidk = all_tidk[all_tidk["seq"].isin(contig_names)].copy()
 
    # Build separate color maps
    highlight_units, unit_to_color = build_color_map(repeats, TOP10_BED, n_colors=HIGHLIGHT_N)
    contig_highlight, contig_colors = build_color_map(contig_repeats, TOP10_BED, n_colors=HIGHLIGHT_N)
 
    print(f"\nChromosomes: {chrom_order}")
    print(f"  Repeat regions: {len(repeats)}")
    print(f"  Tidk windows: {len(tidk)}")
    print(f"\nContigs (excl. mito): {len(contig_order)}")
    print(f"  Repeat regions: {len(contig_repeats)}")
    print(f"  Tidk windows: {len(contig_tidk)}")
    
    # FIGURE 1: Chromosome 3-panel layout
    max_len = max(chrom_len_map.values())
    zoom_width = int(ZOOM_MB * 1e6)
    n_bins = max(40, int(BINS_PER_MB * ZOOM_MB))
    bin_edges = np.linspace(0, zoom_width, n_bins + 1)
 
    fig_width = max(10.0, min(20.0, max_len / 5e6 * 10))
    fig_height = max(3.5, len(chrom_order) * (ROW_HEIGHT + ROW_GAP) * 1.15)
 
    fig = plt.figure(figsize=(fig_width, fig_height), dpi=DPI)
    gs = GridSpec(nrows=1, ncols=3, width_ratios=[2.2, 6.0, 2.2], wspace=0.25)
 
    ax_left  = fig.add_subplot(gs[0])
    ax_main  = fig.add_subplot(gs[1])
    ax_right = fig.add_subplot(gs[2])
 
    format_mb     = lambda x, pos: f"{x / 1e6:.1f}"
    format_mb_int = lambda x, pos: f"{x / 1e6:.0f}"
 
    # Left zoom
    ax_left.set_xlim(0, zoom_width)
    ax_left.set_xlabel(f"Left end (first {ZOOM_MB} Mb)", fontsize=9, fontweight="bold")
    ax_left.xaxis.set_major_formatter(mtick.FuncFormatter(format_mb))
    ax_left.tick_params(axis="x", length=3, width=0.8, labelsize=8)
 
    ry_L, clip_L = draw_chromosome_backbones(ax_left, chrom_order, chrom_len_map,
                                              is_zoom=True, zoom_width=zoom_width,
                                              label_size=8, line_width=0.6)
    draw_centromere_repeats(ax_left, ry_L, repeats, chrom_len_map, chrom_order,
                            unit_to_color, clip_patches=clip_L,
                            is_zoom=True, side="left",
                            zoom_width=zoom_width, n_bins=n_bins, bin_edges=bin_edges)
    draw_telomere_repeats(ax_left, ry_L, tidk, chrom_len_map, chrom_order,
                          clip_patches=clip_L, is_zoom=True, side="left",
                          zoom_width=zoom_width)
 
    # Main panel
    ax_main.set_xlim(0, max_len)
    ax_main.set_xlabel("Genomic Position (Mb)", fontsize=10, fontweight="bold")
    ax_main.xaxis.set_major_formatter(mtick.FuncFormatter(format_mb_int))
    ax_main.tick_params(axis="x", length=4, width=0.8, labelsize=9)
 
    ry_M, clip_M = draw_chromosome_backbones(ax_main, chrom_order, chrom_len_map, label_size=10)
    draw_centromere_repeats(ax_main, ry_M, repeats, chrom_len_map, chrom_order,
                            unit_to_color, clip_patches=clip_M)
    draw_telomere_repeats(ax_main, ry_M, tidk, chrom_len_map, chrom_order,
                          clip_patches=clip_M)
 
    # Right zoom
    ax_right.set_xlim(0, zoom_width)
    ax_right.set_xlabel(f"Right end (last {ZOOM_MB} Mb)", fontsize=9, fontweight="bold")
    ax_right.xaxis.set_major_formatter(mtick.FuncFormatter(format_mb))
    ax_right.tick_params(axis="x", length=3, width=0.8, labelsize=8)
 
    ry_R, clip_R = draw_chromosome_backbones(ax_right, chrom_order, chrom_len_map,
                                              is_zoom=True, zoom_width=zoom_width,
                                              label_size=8, line_width=0.6)
    draw_centromere_repeats(ax_right, ry_R, repeats, chrom_len_map, chrom_order,
                            unit_to_color, clip_patches=clip_R,
                            is_zoom=True, side="right",
                            zoom_width=zoom_width, n_bins=n_bins, bin_edges=bin_edges)
    draw_telomere_repeats(ax_right, ry_R, tidk, chrom_len_map, chrom_order,
                          clip_patches=clip_R, is_zoom=True, side="right",
                          zoom_width=zoom_width)
 
    # Legend and title
    has_telo = tidk is not None and not tidk.empty
    build_legend(ax_main, highlight_units, unit_to_color, repeats, has_telo)
    fig.suptitle("Genome-wide Distribution of Centromeric and Telomeric Repeats",
                 fontsize=12, fontweight="bold", y=0.98)
 
    fig.savefig(os.path.join(OUT_DIR, "chrom_repeats_map.png"), bbox_inches="tight", dpi=DPI)
    fig.savefig(os.path.join(OUT_DIR, "chrom_repeats_map.pdf"), bbox_inches="tight")
    plt.close(fig)
    print("Saved: chrom_repeats_map.png/.pdf")
    
    # FIGURE 2: Contig full-length (filtered)
     # Filter: keep only contigs with centromere OR telomere signal
    contigs_with_centromere = set(contig_repeats["seq"].unique())
    if contig_tidk is not None and not contig_tidk.empty:
        contigs_with_telomere = set(
            contig_tidk[contig_tidk["total_count"] > TELO_THRESHOLD]["seq"].unique()
        )
    else:
        contigs_with_telomere = set()
 
    contigs_to_keep = contigs_with_centromere | contigs_with_telomere
    contig_order = [c for c in contig_order if c in contigs_to_keep]
    contig_len_map = {c: contig_len_map[c] for c in contig_order}
    contig_repeats = contig_repeats[contig_repeats["seq"].isin(contig_order)].copy()
    if contig_tidk is not None:
        contig_tidk = contig_tidk[contig_tidk["seq"].isin(contig_order)].copy()
 
    contig_max_len = max(contig_len_map.values())
    contig_fig_h = max(3.5, len(contig_order) * (ROW_HEIGHT + ROW_GAP) * 1.15)
 
    print(f"Contigs kept: {len(contig_order)}")
    print(f"  with centromere: {len(contigs_with_centromere)}")
    print(f"  with telomere:   {len(contigs_with_telomere)}")
 
    # Full-length contigs figure
    contig_fig_w = max(10.0, min(20.0, contig_max_len / 5e6 * 10))
    fig_M, ax_M = plt.subplots(figsize=(contig_fig_w, contig_fig_h), dpi=DPI)
    ax_M.set_xlim(0, contig_max_len)
    ax_M.set_xlabel("Genomic Position (Mb)", fontsize=10, fontweight="bold")
 
    ax_M.xaxis.set_major_locator(mtick.MultipleLocator(2e5))
    ax_M.xaxis.set_major_formatter(mtick.FuncFormatter(lambda x, pos: f"{x/1e6:.1f}"))
    ax_M.tick_params(axis="x", length=4, width=0.8, labelsize=9)
 
    ry_M, clip_M = draw_chromosome_backbones(ax_M, contig_order, contig_len_map, label_size=10)
    draw_centromere_repeats(ax_M, ry_M, contig_repeats, contig_len_map, contig_order,
                            contig_colors, clip_patches=clip_M)
    draw_telomere_repeats(ax_M, ry_M, contig_tidk, contig_len_map, contig_order,
                          clip_patches=clip_M)
 
    build_legend(ax_M, contig_highlight, contig_colors, contig_repeats,
                 contig_tidk is not None and not contig_tidk.empty)
    fig_M.suptitle("Unplaced Contigs — Centromeric and Telomeric Repeat Distribution",
                   fontsize=12, fontweight="bold", y=0.98)
    fig_M.savefig(os.path.join(OUT_DIR, "contigs_full_genome.png"), bbox_inches="tight", dpi=DPI)
    fig_M.savefig(os.path.join(OUT_DIR, "contigs_full_genome.pdf"), bbox_inches="tight")
    plt.close(fig_M)
    print("Saved: contigs_full_genome.png/.pdf")
 
    print("\nDone!")
 
 
if __name__ == "__main__":
    main()