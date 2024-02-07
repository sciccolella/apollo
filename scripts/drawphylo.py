from matplotlib import pyplot as plt
from Bio import Phylo
from functools import partial

def getlabel(node, details:dict):
    if node.name:
        return f"{node.name} " + details.get(node.name, "")
    

def main(args):
    _, ax = plt.subplots(1, 1, figsize=(15, 20))

    treefile = args.t
    msafile = args.m
    fastafile = args.f
    dmsa = {}
    for line in open(fastafile):
        print(line)
        if line.startswith(">"):
            k, *name = line[1:].split()
            dmsa[k] = " ".join(name[:2])

    _getlabel = partial(getlabel, details=dmsa)
    Phylo.draw(
            Phylo.read(treefile, "newick"),
            axes=ax,
            show_confidence=False,
            do_show=False,
            label_func=_getlabel,
        )


    plt.tight_layout()
    plt.savefig(args.o)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="show phylo")
    parser.add_argument("-t", type=str, help="tree file")
    parser.add_argument("-m", type=str, help="MSA file")
    parser.add_argument("-f", type=str, help="FASTA file")
    parser.add_argument("-o", type=str, help="output file")
    parser.add_argument("--title", type=str, required=False)

    args = parser.parse_args()
    main(args)
