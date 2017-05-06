def getPraatData():
    f = open("FTO_data_auto_pos-subset.csv", "r")
    variable_indices = {}
    praat_data = {}
    counter = 0
    for line in f:
        counter += 1
        line_list = line[:-1].split(",")
        if counter == 1:
            for variable in line_list:
                variable_indices[variable] = line_list.index(variable)
        else:
            id_index = variable_indices["conversation_ID"]
            conv_id = line_list[id_index]
            if conv_id in praat_data:
                praat_data[conv_id].append(line_list)
            else:
                praat_data[conv_id] = [line_list]
    f.close()
    return variable_indices, praat_data


def addT2Measures():
    for convo in raw_data.keys():
        line_index = 0
        num_switches = len(raw_data[convo])
        for turn_switch in raw_data[convo]:
            if line_index == num_switches - 1:
                t2_clauses = "NA"
                t2_frequency = "NA"
                t2_concreteness = "NA"
                t2_speechrate = "NA"
            else:
                t2_clauses = raw_data[convo][line_index + 1][var_indices["t1_proc_clauses"]]
                t2_frequency = raw_data[convo][line_index + 1][var_indices["t1_proc_frequency"]]
                t2_concreteness = raw_data[convo][line_index + 1][var_indices["t1_proc_concreteness"]]
                t2_speechrate = raw_data[convo][line_index + 1][var_indices["t1_proc_speechrate"]]
            raw_data[convo][line_index] = raw_data[convo][line_index][:-9] + [t2_clauses] + [raw_data[convo][line_index][-9]] + [t2_frequency] + [raw_data[convo][line_index][-8]] + [t2_concreteness] + raw_data[convo][line_index][-7:-1] + [t2_speechrate] + [raw_data[convo][line_index][-1]]
            line_index += 1


def addTurnDuration():
    for convo in raw_data.keys():
        line_index = 0
        num_switches = len(raw_data[convo])
        for turn_switch in raw_data[convo]:
            # t1
            t1_end = float(turn_switch[var_indices["t1_end"]])
            if line_index == 0:
                t1_start = float(turn_switch[-1])
            else:
                t1_start = float(raw_data[convo][line_index - 1][var_indices["t2_start"]])
            t1_duration = str(t1_end - t1_start)
            raw_data[convo][line_index][-1] = t1_duration
            # t2
            if line_index == num_switches - 1:
                t2_duration = "NA"
            else:
                t2_start = float(turn_switch[var_indices["t2_start"]])
                t2_end = float(raw_data[convo][line_index + 1][var_indices["t1_end"]])
                t2_duration = str(t2_end - t2_start)
            raw_data[convo][line_index].append(t2_duration)
            line_index += 1


def writeProcessedData():
    g = open("FTO_data_auto_pos_processed.csv", "w")
    old_header = list(var_indices.keys())
    header = old_header[:2] + old_header[4:-8] + ["t2_proc_clauses", "t1_proc_frequency", "t2_proc_frequency", "t1_proc_concreteness", "t2_proc_concreteness", "t1_nonv_speaker_gaze", "t1_nonv_listener_gaze", "t1_nonv_pitch", "t1_oth_sex", "t2_oth_sex", "t1_proc_speechrate", "t2_proc_speechrate", "t1_proc_duration", "t2_proc_duration"]
    g.write(",".join(header) + "\n")
    for convo in raw_data.keys():
        for l in raw_data[convo]:
            g.write(",".join(l[:2]) + "," + ",".join(l[4:]) + "\n")
    g.close()


var_indices, raw_data = getPraatData()
addT2Measures()
addTurnDuration()
writeProcessedData()
