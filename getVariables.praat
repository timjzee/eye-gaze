Read Strings from raw text file: "speaker_list.txt"
num_ids = Get number of strings
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


procedure processTransfer: .t1_end, .t2_start, .t1_speaker, .t2_speaker
    .fto = .t2_start - .t1_end
    appendFileLine: dest_path$ + "FTO_data.csv", id$, ",", .fto, ",", .t1_end, ",", .t2_start, ",", .t1_speaker, ",", .t2_speaker
endproc


procedure findTransfers
    @findFirstTurn: 0, 0
    .turn = findFirstTurn.turn
    .current_index = findFirstTurn.index
    .turn_max = Get number of intervals: .turn
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
            .other_start = Get start time of interval: .other, .other_index
            @processTransfer: .turn_break, .other_start, .turn, .other
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
                    .other_start = Get start time of interval: .other, findFirstTurn.index
                    @processTransfer: .turn_break, .other_start, .turn, .other
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

header$ = "conversation_ID,floor_transfer_offset,t1_end,t2_start,t1_speaker,t2_speaker"
writeFileLine: dest_path$ + "FTO_data.csv", header$
for i to num_ids
	selectObject: "Strings speaker_list"
    id$ = Get string: i
    Read from file: source_path$ + id$ + "_combined.TextGrid"
    @findTransfers
endfor
