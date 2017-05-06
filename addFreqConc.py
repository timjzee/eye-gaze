import glob
import csv
import pickle

convos = ["DVA1A", "DVA2C", "DVA3E", "DVA4C", "DVA7B", "DVA10O", "DVA12S", "DVA14W"]
offsets = {"DVA1A": 0, "DVA2C": 6.045966, "DVA3E": 0, "DVA4C": 0, "DVA7B": 0, "DVA10O": 0, "DVA12S": 6.0317, "DVA14W": 0}


def getLemma(l_list):
    """Check .pos file > check SUBTLEX > use token."""
    if l_list[2] != "_":
        lem = l_list[2]
    else:
        f = open("SUBTLEX-NL.csv", "r", encoding='utf-16', errors='ignore')
        subtlex = csv.DictReader(f)
        lem = ""
        for row in subtlex:
            if row["Word"] == l_list[0]:
                lem = row["dominant.pos.lemma"]
        f.close()
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


def addPointTiers():
    for convo in convos:
        f = open(glob.glob("./annotations/POS_files/" + convo + "*")[0], "r")
        convo_lines = f.readlines()
        f.close()
        g = open(glob.glob("./annotations/combined_textgrids_auto_pos-subset/" + convo + "*")[0], "r")
        lines = g.readlines()
        g.close()
        xmax = lines[4][:-2].split(" ")[-1]
        lines[6] = "size = 16 \n"
        g2 = open(glob.glob("./annotations/combined_textgrids_auto_pos-subset/" + convo + "*")[0], "w")
        for nline in lines:
            g2.write(nline)
        g2.close()
        h = open(glob.glob("./annotations/combined_textgrids_auto_pos-subset/" + convo + "*")[0], "a")
        tier_num = 12
        measures = ["frequency", "concreteness"]
        for measure in measures:
            for speaker in ["spreker1", "spreker2"]:
                tier_num += 1
                num_points = 0
                for l in convo_lines:
                    if speaker in l:
                        num_points += 1
                h.write("    item [{}]:\n".format(tier_num))
                h.write('        class = "TextTier" \n')
                h.write('        name = "{}_{}" \n'.format(measure, speaker))
                h.write('        xmin = 0 \n')
                h.write('        xmax = {} \n'.format(xmax))
                h.write('        points: size = {} \n'.format(num_points))
                point = 0
                relevant = False
                tokens = []
                line_counter = 0
                total_lines = len(convo_lines)
                for l in convo_lines:
                    line_counter += 1
                    if l[0] == "<":
                        if len(tokens) > 0:
                            value_list = [str(freq_conc_dict[lemma_dictionary[token]][measures.index(measure)]) for token in tokens]
                            value_string = " ".join(value_list)
                            h.write('            mark = "{}" \n'.format(value_string))
                            tokens = []
                        if speaker in l:
                            l_list = l[:-1].split(" ")
                            start_time = str(float(l_list[2][2:]) + offsets[convo])
                            relevant = True
                            point += 1
                            h.write("        points [{}]:\n".format(point))
                            h.write("            number = {} \n".format(start_time))
                        else:
                            relevant = False
                    if l[0] not in ["<", ".", "?"] and relevant:
                        l_list = l.split("\t")
                        pos = l_list[1].split("(")[0]
                        tokpos = l_list[0] + "-" + pos
                        tokens.append(tokpos)
                    if line_counter == total_lines and len(tokens) != 0:
                        value_list = [str(freq_conc_dict[lemma_dictionary[token]][measures.index(measure)]) for token in tokens]
                        value_string = " ".join(value_list)
                        h.write('            mark = "{}" \n'.format(value_string))
                        tokens = []
        h.close()


lemma_dictionary, freq_conc_dict = getDictionaries()
addPointTiers()
