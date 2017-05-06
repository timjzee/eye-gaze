Read Strings from raw text file: "speaker_list.txt"
num_ids = Get number of strings
source_path$ = "./annotations/combined_textgrids/"
dest_path$ = ""


procedure getShortLabel: .raw_label$
    cut_index = index (.raw_label$, "__")
    .short_label$ = left$ (.raw_label$, cut_index - 1)
endproc


Create Table with column names: "avg_durations", 0, "phone avg_duration"
Create Table with column names: "phone_durations", 0, "phone duration"
for i to num_ids
    selectObject: "Strings speaker_list"
    id$ = Get string: i
    Read from file: source_path$ + id$ + "_combined.TextGrid"
    for tier from 5 to 6
        selectObject: "TextGrid " + id$ + "_combined"
        num_intervals = Get number of intervals: tier
        for interval to num_intervals
            selectObject: "TextGrid " + id$ + "_combined"
            raw_label$ = Get label of interval: tier, interval
            @getShortLabel: raw_label$
            label$ = getShortLabel.short_label$
            if label$ <> "sil"
                start_time = Get start time of interval: tier, interval
                end_time = Get end time of interval: tier, interval
                duration = end_time - start_time
                selectObject: "Table phone_durations"
                num_rows = Get number of rows
                Append row
                Set string value: num_rows + 1, "phone", label$
                Set numeric value: num_rows + 1, "duration", duration
                selectObject: "Table avg_durations"
                phone_in_table = Search column: "phone", label$
                if phone_in_table = 0
                    num_avg_rows = Get number of rows
                    Append row
                    Set string value: num_avg_rows + 1, "phone", label$
                endif
            endif
        endfor
    endfor
endfor

selectObject: "Table avg_durations"
num_unique_phones = Get number of rows
for phone to num_unique_phones
    selectObject: "Table avg_durations"
    phone_label$ = Get value: phone, "phone"
    selectObject: "Table phone_durations"
    mean_duration = Get group mean: "duration", "phone", phone_label$
    selectObject: "Table avg_durations"
    Set numeric value: phone, "avg_duration", mean_duration
endfor

selectObject: "Table avg_durations"
Save as comma-separated file: dest_path$ + "average_phone_durations.csv"
