Read Strings from raw text file: "speaker_list_pos-subset.txt"
num_ids = Get number of strings
Read Table from comma-separated file: "average_phone_durations.csv"
source_path$ = "./annotations/combined_textgrids_pos-subset/"
dest_path$ = ""


procedure getShortLabel: .raw_label$
    cut_index = index (.raw_label$, "__")
    .short_label$ = left$ (.raw_label$, cut_index - 1)
endproc


procedure findFirstTurn: .cur_index1, .cur_index2
    selectObject: "TextGrid " + id$ + "_combined"
    .cur_label1$ = "sil"
    .cur_label2$ = "sil"

    while .cur_label1$ = "sil"
        .cur_index1 += 1
        .raw_label1$ = Get label of interval: 1, .cur_index1
        @getShortLabel: .raw_label1$
        .cur_label1$ = getShortLabel.short_label$
    endwhile
    .first_turn1 = Get start time of interval: 1, .cur_index1

    while .cur_label2$ = "sil"
        .cur_index2 += 1
        .raw_label2$ = Get label of interval: 2, .cur_index2
        @getShortLabel: .raw_label2$
        .cur_label2$ = getShortLabel.short_label$
    endwhile
    .first_turn2 = Get start time of interval: 2, .cur_index2

    if .first_turn1 < .first_turn2
        .turn = 1
        .index = .cur_index1
    elsif .first_turn1 > .first_turn2
        .turn = 2
        .index = .cur_index2
    else
        # i.e. if both first turns start at the same time, which could happen if both speakers are already talking when the recording starts
        .first_turn1_end = Get end time of interval: 1, .cur_index1
        .first_turn2_end = Get end time of interval: 2, .cur_index2
        if .first_turn1_end > .first_turn2_end
            .turn = 1
            .index = .cur_index1
        else
            .turn = 2
            .index = .cur_index2
        endif
    endif
endproc


procedure getOpposite: .current_speaker
    if .current_speaker = 1
        .opposite = 2
    elsif .current_speaker = 2
        .opposite = 1
    endif
endproc


procedure getSeqOrg
    # t1
    .t1_init$ = "no"
    .t1_resp$ = "no"
    .t1_back$ = "no"
    .t1_tier = 6 + processTransfer.t1_speaker
    .t1_label_index = Get low interval at time: .t1_tier, processTransfer.t1_end
    .t1_label_raw$ = Get label of interval: .t1_tier, .t1_label_index
    @getShortLabel: .t1_label_raw$
    .t1_label$ = getShortLabel.short_label$
    if index (.t1_label$, "u") <> 0
        .t1_init$ = "yes"
    endif
    if index (.t1_label$, "r") <> 0
        .t1_resp$ = "yes"
    endif
    if index (.t1_label$, "k") <> 0
        .t1_back$ = "yes"
    endif
    # t2
    .t2_init$ = "no"
    .t2_resp$ = "no"
    .t2_back$ = "no"
    .t2_tier = 6 + processTransfer.t2_speaker
    .t2_label_index = Get high interval at time: .t2_tier, processTransfer.t2_start
    .t2_label_raw$ = Get label of interval: .t2_tier, .t2_label_index
    @getShortLabel: .t2_label_raw$
    .t2_label$ = getShortLabel.short_label$
    if index (.t2_label$, "u") <> 0
        .t2_init$ = "yes"
    endif
    if index (.t2_label$, "r") <> 0
        .t2_resp$ = "yes"
    endif
    if index (.t2_label$, "k") <> 0
        .t2_back$ = "yes"
    endif
endproc


procedure getSpeechRate
    Create Table with column names: "phone_durations", 0, "phone duration proportion"
    selectObject: "TextGrid " + id$ + "_combined"
    .low_index = Get high interval at time: processTransfer.t1_speaker, findTransfers.turn_start
    .high_index = Get low interval at time: processTransfer.t1_speaker, processTransfer.t1_end
    for chunk from .low_index to .high_index
        selectObject: "TextGrid " + id$ + "_combined"
        .chunk_label$ = Get label of interval: processTransfer.t1_speaker, chunk
        .cut_index = index (.chunk_label$, "__")
        .label_length = length (.chunk_label$)
        .chunk_id$ = right$ (.chunk_label$, .label_length - (.cut_index - 1))
        .regex_match$ = ".*" + .chunk_id$ + "[0-9].*"
        Get starting points: processTransfer.t1_speaker + 4, "matches (regex)", .regex_match$
        .num_phons = Get number of points
        for phon_i to .num_phons
            selectObject: "PointProcess " + id$ + "_combined___" + .chunk_id$ + "_0-9_"
            .phon_start = Get time from index: phon_i
            selectObject: "TextGrid " + id$ + "_combined"
            .phon_index = Get high interval at time: processTransfer.t1_speaker + 4, .phon_start
            .phon_raw_lab$ = Get label of interval: processTransfer.t1_speaker + 4, .phon_index
            @getShortLabel: .phon_raw_lab$
            .phon_lab$ = getShortLabel.short_label$
            if .phon_lab$ <> "sil"
                .phon_end = Get end time of interval: processTransfer.t1_speaker + 4, .phon_index
                .phon_dur = .phon_end - .phon_start
                selectObject: "Table average_phone_durations"
                .mean_index = Search column: "phone", .phon_lab$
                .mean_duration = Get value: .mean_index, "avg_duration"
                .phon_prop = .phon_dur / .mean_duration
                selectObject: "Table phone_durations"
                Append row
                .num_rows = Get number of rows
                Set string value: .num_rows, "phone", .phon_lab$
                Set numeric value: .num_rows, "duration", .phon_dur
                Set numeric value: .num_rows, "proportion", .phon_prop
            endif
        endfor
        selectObject: "PointProcess " + id$ + "_combined___" + .chunk_id$ + "_0-9_"
        Remove
    endfor
    selectObject: "Table phone_durations"
    .speech_rate = Get mean: "proportion"
    Remove
    selectObject: "TextGrid " + id$ + "_combined"
endproc


procedure getClauFreqConc
    # get number of clauses
    .start_index = Get high index from time: 12 + processTransfer.t1_speaker, findTransfers.turn_start - 0.05
    .end_index = Get low index from time: 12 + processTransfer.t1_speaker, processTransfer.t1_end
    .num_clauses$ = string$ (.end_index - .start_index + 1)
    if .num_clauses$ = "0"
        .num_clauses$ = "NA"
    endif
    # get mean frequency
    .freq_count = 0
    .conc_count = 0
    .cumul_frequency = 0
    .cumul_concreteness = 0
    for clause_index from .start_index to .end_index
        .freq_label$ = Get label of point: 12 + processTransfer.t1_speaker, clause_index
        .conc_label$ = Get label of point: 14 + processTransfer.t1_speaker, clause_index
        while .freq_label$ <> ""
            # frequency
            .freq_count += 1
            .freq_space_index = index (.freq_label$, " ")
            if .freq_space_index <> 0
                .freq_word = number (left$ (.freq_label$, .freq_space_index - 1))
                .freq_length = length (.freq_label$)
                .freq_label$ = right$ (.freq_label$, .freq_length - .freq_space_index)
            elsif .freq_space_index = 0
                .freq_word = number (.freq_label$)
                .freq_label$ = ""
            endif
            .cumul_frequency += .freq_word
            # concreteness
            .conc_space_index = index (.conc_label$, " ")
            if .conc_space_index <> 0
                .conc_word = number (left$ (.conc_label$, .conc_space_index - 1))
                .conc_length = length (.conc_label$)
                .conc_label$ = right$ (.conc_label$, .conc_length - .conc_space_index)
            elsif .conc_space_index = 0
                .conc_word = number (.conc_label$)
                .conc_label$ = ""
            endif
            if .conc_word <> 0
                .cumul_concreteness += .conc_word
                .conc_count += 1
            endif
        endwhile
    endfor
    if .freq_count <> 0
        .mean_frequency$ = string$ (.cumul_frequency / .freq_count)
    elsif .freq_count = 0
        .mean_frequency$ = "NA"
    endif
    if .conc_count <> 0
        .mean_concreteness$ = string$ (.cumul_concreteness / .conc_count)
    elsif .conc_count = 0
        .mean_concreteness$ = "NA"
    endif
endproc


procedure getGaze
    .fto_start = min (processTransfer.t1_end, processTransfer.t2_start)
    .last_word_index = Get interval at time: processTransfer.t1_speaker + 2, .fto_start
    .last_word_label_raw$ = Get label of interval: processTransfer.t1_speaker + 2, .last_word_index
    @getShortLabel: .last_word_label_raw$
    .last_word_label$ = getShortLabel.short_label$
    if .last_word_label$ = "sil"
        .last_word_index = .last_word_index - 1
    endif
    .last_word_start = Get start time of interval: processTransfer.t1_speaker + 2, .last_word_index
    .last_word_end = Get end time of interval: processTransfer.t1_speaker + 2, .last_word_index
    # speaker gaze
    .start_index = Get interval at time: processTransfer.t1_speaker + 10, .last_word_start
    .end_index = Get interval at time: processTransfer.t1_speaker + 10, .last_word_end
    .number_gaze_changes = .end_index - .start_index
    if .number_gaze_changes = 0
        .speaker_gaze$ = Get label of interval: processTransfer.t1_speaker + 10, .start_index
        if .speaker_gaze$ = "G"
            .speaker_gaze$ = "g"
        endif
        if .speaker_gaze$ = "X"
            .speaker_gaze$ = "x"
        endif
        if .speaker_gaze$ <> "x" and .speaker_gaze$ <> "g"
            .speaker_gaze$ = "NA"
        endif
    elsif .number_gaze_changes > 0
        .gaze_state1$ = Get label of interval: processTransfer.t1_speaker + 10, .end_index - 1
        if .gaze_state1$ = ""
            .gaze_state1$ = Get label of interval: processTransfer.t1_speaker + 10, .end_index - 2
        endif
        if .gaze_state1$ = "G"
            .gaze_state1$ = "g"
        endif
        if .gaze_state1$ = "X"
            .gaze_state1$ = "x"
        endif
        .gaze_state2$ = Get label of interval: processTransfer.t1_speaker + 10, .end_index
        if .gaze_state2$ = ""
            .gaze_state2$ = Get label of interval: processTransfer.t1_speaker + 10, .end_index + 1
        endif
        if .gaze_state2$ = "G"
            .gaze_state2$ = "g"
        endif
        if .gaze_state2$ = "X"
            .gaze_state2$ = "x"
        endif
        if (.gaze_state1$ <> "x" and .gaze_state1$ <> "g") or (.gaze_state2$ <> "x" and .gaze_state2$ <> "g")
            .speaker_gaze$ = "NA"
        else
            if .gaze_state1$ = .gaze_state2$
                .speaker_gaze$ = .gaze_state1$
            else
                .speaker_gaze$ = .gaze_state1$ + "-" + .gaze_state2$
            endif
        endif
    endif
    # listener gaze
    .start_index = Get interval at time: processTransfer.t2_speaker + 10, .last_word_start
    .end_index = Get interval at time: processTransfer.t2_speaker + 10, .last_word_end
    .number_gaze_changes = .end_index - .start_index
    if .number_gaze_changes = 0
        .listener_gaze$ = Get label of interval: processTransfer.t2_speaker + 10, .start_index
        if .listener_gaze$ = "G"
            .listener_gaze$ = "g"
        endif
        if .listener_gaze$ = "X"
            .listener_gaze$ = "x"
        endif
        if .listener_gaze$ <> "x" and .listener_gaze$ <> "g"
            .listener_gaze$ = "NA"
        endif
    elsif .number_gaze_changes > 0
        .gaze_state1$ = Get label of interval: processTransfer.t2_speaker + 10, .end_index - 1
        if .gaze_state1$ = ""
            .gaze_state1$ = Get label of interval: processTransfer.t2_speaker + 10, .end_index - 2
        endif
        if .gaze_state1$ = "G"
            .gaze_state1$ = "g"
        endif
        if .gaze_state1$ = "X"
            .gaze_state1$ = "x"
        endif
        .gaze_state2$ = Get label of interval: processTransfer.t2_speaker + 10, .end_index
        if .gaze_state2$ = ""
            .gaze_state2$ = Get label of interval: processTransfer.t2_speaker + 10, .end_index + 1
        endif
        if .gaze_state2$ = "G"
            .gaze_state2$ = "g"
        endif
        if .gaze_state2$ = "X"
            .gaze_state2$ = "x"
        endif
        if (.gaze_state1$ <> "x" and .gaze_state1$ <> "g") or (.gaze_state2$ <> "x" and .gaze_state2$ <> "g")
            .listener_gaze$ = "NA"
        else
            if .gaze_state1$ = .gaze_state2$
                .listener_gaze$ = .gaze_state1$
            else
                .listener_gaze$ = .gaze_state1$ + "-" + .gaze_state2$
            endif
        endif
    endif
endproc


procedure getIntonation
    .fto_start = min (processTransfer.t1_end, processTransfer.t2_start)
    .last_phrase_index = Get interval at time: processTransfer.t1_speaker + 8, .fto_start
    .last_phrase_label_raw$ = Get label of interval: processTransfer.t1_speaker + 8, .last_phrase_index
    @getShortLabel: .last_phrase_label_raw$
    .last_phrase_label$ = getShortLabel.short_label$
    if .last_phrase_label$ = ""
        .last_phrase_index = .last_phrase_index - 1
        .last_phrase_label_raw$ = Get label of interval: processTransfer.t1_speaker + 8, .last_phrase_index
        @getShortLabel: .last_phrase_label_raw$
        .last_phrase_label$ = getShortLabel.short_label$
    endif
    if .last_phrase_label$ = "1"
        .end_pitch$ = "low"
    elif .last_phrase_label$ = "2"
        .end_pitch$ = "mid"
    elif .last_phrase_label$ = "3"
        .end_pitch$ = "high"
    else
        .end_pitch$ = "NA"
    endif
endproc


procedure getSex
    .id_length = length (id$)
    if .id_length = 7
        .sex_index = 6
    else
        .sex_index = .id_length
    .t1_tier$ = Get tier name: processTransfer.t1_speaker
    .t2_tier$ = Get tier name: processTransfer.t2_speaker
    .t1_oth_sex$ = mid$ (.t1_tier$, .sex_index, 1)
    .t2_oth_sex$ = mid$ (.t2_tier$, .sex_index, 1)
endproc


procedure processTransfer: .t1_end, .t2_start, .t1_speaker, .t2_speaker
    .fto = .t2_start - .t1_end
    @getSeqOrg
    @getSpeechRate
    @getClauFreqConc
    @getGaze
    @getIntonation
    @getSex
    appendFile: dest_path$ + "FTO_data_pos-subset.csv", id$, ",", .fto, ",", .t1_end, ",", .t2_start, ",", getIntonation.fto_start, ",", .t1_speaker, ",", .t2_speaker, ",", getSeqOrg.t1_init$, ",", getSeqOrg.t1_resp$, ",", getSeqOrg.t1_back$, ",", getSeqOrg.t2_init$, ",", getSeqOrg.t2_resp$, ",", getSeqOrg.t2_back$, ",", getClauFreqConc.num_clauses$, ",", getClauFreqConc.mean_frequency$, ",", getClauFreqConc.mean_concreteness$, ",", getGaze.speaker_gaze$, ",", getGaze.listener_gaze$, ",", getIntonation.end_pitch$, ",", getSex.t1_oth_sex$, ",", getSex.t2_oth_sex$, ",", getSpeechRate.speech_rate
    appendFileLine: dest_path$ + "FTO_data_pos-subset.csv", ",", findTransfers.first_index_start
endproc


procedure findTransfers
    @findFirstTurn: 0, 0
    .turn = findFirstTurn.turn
    .current_index = findFirstTurn.index
    .first_index_start = Get start time of interval: .turn, .current_index
    .turn_max = Get number of intervals: .turn
    .iteration = 1
    while .current_index < .turn_max
        .current_raw_label$ = Get label of interval: .turn, .current_index
        @getShortLabel: .current_raw_label$
        .current_label$ = getShortLabel.short_label$
        while (.current_label$ <> "sil" and .current_index < .turn_max)
            .current_index += 1
            .current_raw_label$ = Get label of interval: .turn, .current_index
            @getShortLabel: .current_raw_label$
            .current_label$ = getShortLabel.short_label$
        endwhile
        .turn_break = Get start time of interval: .turn, .current_index
        # at this point there is a silence in the turn; we now check whether the other speaker has started a new turn during the current turn which is not yet finished
        @getOpposite: .turn
        .other = getOpposite.opposite
        .other_index = Get interval at time: .other, .turn_break
        .other_raw_label$ = Get label of interval: .other, .other_index
        @getShortLabel: .other_raw_label$
        .other_label$ = getShortLabel.short_label$
        .other_max = Get number of intervals: .other
        if .other_label$ <> "sil"
            if .iteration = 1
                .turn_start = .first_index_start
            else
                .turn_start = .other_start
            endif
            .other_start = Get start time of interval: .other, .other_index
            @processTransfer: .turn_break, .other_start, .turn, .other
            .iteration += 1
            .turn = .other
            .current_index = .other_index
            .turn_max = Get number of intervals: .turn
        else
            if (.other_index = .other_max or .current_index = .turn_max)
                goto END
            else
                if .turn = 1
                    @findFirstTurn: .current_index, .other_index
                elsif .turn = 2
                    @findFirstTurn: .other_index, .current_index
                endif
                if findFirstTurn.turn = .other
                    if .iteration = 1
                        .turn_start = .first_index_start
                    else
                        .turn_start = .other_start
                    endif
                    .other_start = Get start time of interval: .other, findFirstTurn.index
                    @processTransfer: .turn_break, .other_start, .turn, .other
                    .iteration += 1
                    .turn = .other
                    .current_index = findFirstTurn.index
                    .turn_max = Get number of intervals: .turn
                elsif findFirstTurn.turn = .turn
                    .current_index = findFirstTurn.index
                endif
            endif
        endif
    endwhile
    label END
endproc

header$ = "conversation_ID,floor_transfer_offset,t1_end,t2_start,conversation_time,t1_speaker,t2_speaker,t1_seq_initiating,t1_seq_responding,t1_seq_backchannel,t2_seq_initiating,t2_seq_responding,t2_seq_backchannel,t1_proc_clauses,t1_proc_frequency,t1_proc_concreteness,t1_nonv_speaker_gaze,t1_nonv_listener_gaze,t1_nonv_pitch,t1_oth_sex,t2_oth_sex,t1_proc_speechrate"
writeFileLine: dest_path$ + "FTO_data_pos-subset.csv", header$
for i to num_ids
	selectObject: "Strings speaker_list_pos-subset"
    id$ = Get string: i
    Read from file: source_path$ + id$ + "_combined.TextGrid"
    @findTransfers
endfor
