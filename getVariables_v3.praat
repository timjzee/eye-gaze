Read Strings from raw text file: "speaker_list.txt"
num_ids = Get number of strings
Read Table from comma-separated file: "average_phone_durations.csv"
source_path$ = "./annotations/combined_textgrids/"
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


procedure processTransfer: .t1_end, .t2_start, .t1_speaker, .t2_speaker
    .fto = .t2_start - .t1_end
    @getSeqOrg
    @getSpeechRate
    appendFile: dest_path$ + "FTO_data.csv", id$, ",", .fto, ",", .t1_end, ",", .t2_start, ",", .t1_speaker, ",", .t2_speaker, ",", getSeqOrg.t1_init$, ",", getSeqOrg.t1_resp$, ",", getSeqOrg.t1_back$, ",", getSeqOrg.t2_init$, ",", getSeqOrg.t2_resp$, ",", getSeqOrg.t2_back$, ",", getSpeechRate.speech_rate
    appendFileLine: dest_path$ + "FTO_data.csv", ",", findTransfers.first_index_start
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

header$ = "conversation_ID,floor_transfer_offset,t1_end,t2_start,t1_speaker,t2_speaker,t1_seq_initiating,t1_seq_responding,t1_seq_backchannel,t2_seq_initiating,t2_seq_responding,t2_seq_backchannel,t1_proc_speechrate"
writeFileLine: dest_path$ + "FTO_data.csv", header$
for i to num_ids
	selectObject: "Strings speaker_list"
    id$ = Get string: i
    Read from file: source_path$ + id$ + "_combined.TextGrid"
    @findTransfers
endfor