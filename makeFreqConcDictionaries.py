import glob
import csv
import pickle

convos = ["DVA1A", "DVA2C", "DVA3E", "DVA4C", "DVA6H", "DVA7B", "DVA8K", "DVA9M", "DVA10O", "DVA11Q", "DVA12S", "DVA13U", "DVA14W", "DVA15Y", "DVA16AA", "DVA17AC", "DVA19AG", "DVA20AI", "DVA22AL", "DVA24AK"]


def getLemma(l_list):
    """Check .pos file > check SUBTLEX > use token."""
    if l_list[2] != "_":
        lem = l_list[2]
    else:
        lem = ""
        for row in subtlex:
            if row["Word"] == l_list[0]:
                lem = row["dominant.pos.lemma"]
    if lem == "":
        lem = l_list[0]
    return lem


def getConcreteness(lem):
    """Get concreteness rating from Brysbaert et al. 2014"""
    f = open("concreteness_ratings.csv", "r", encoding='utf-8', errors='ignore')
    conc_ratings = csv.DictReader(f, dialect='excel')
    conc = 0
    for row in conc_ratings:
        if row["stimulus"] == lem:
            conc = row["Concrete_m"]
    f.close()
    return conc


def makeDictionaries():
    """Makes dictionary with lemma-POS combinations as keys and frequency and concreteness as values."""
    lemma_dict = {}
    freq_conc_dict = {}
    for convo in convos:
        f = open(glob.glob("./annotations/POS_files/" + convo + "*")[0], "r")
        convo_lines = f.readlines()
        num_lines = len(convo_lines)
        f.close()
        counter = 0
        for line in convo_lines:
            counter += 1
            print(convo + ": line " + str(counter) + "/" + str(num_lines))
            if line[0] not in [".", "?", "<"]:
                line_list = line[:-1].split("\t")
                lemma = getLemma(line_list)
                pos = line_list[1].split("(")[0]
                token = line_list[0]
                tokenpos = token + "-" + pos
                lemmapos = lemma + "-" + pos
                if tokenpos not in lemma_dict:
                    lemma_dict[tokenpos] = lemmapos
                if lemmapos in freq_conc_dict:
                    freq_conc_dict[lemmapos][0] += 1
                else:
                    concreteness = getConcreteness(lemma)
                    freq_conc_dict[lemmapos] = [1, concreteness]
    return [lemma_dict, freq_conc_dict]


def getDictionaries():
    try:
        g = open("freq_conc_dicts.pck", "rb")
        fc_dicts = pickle.load(g)
    except:
        fc_dicts = makeDictionaries()
        g = open("freq_conc_dicts.pck", "wb")
        pickle.dump(fc_dicts, g)
    g.close()
    return fc_dicts


f = open("SUBTLEX-NL.csv", "r", encoding='utf-16', errors='ignore')
subtlex = csv.DictReader(f)
lemma_dictionary, frequency_concreteness_dict = getDictionaries()
f.close()
