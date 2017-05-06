Read Strings from raw text file: "speaker_list.txt"
num_ids = Get number of strings
source_path$ = "./annotations/source_textgrids/"
dest_path$ = "./annotations/combined_textgrids_auto/"


procedure addTier: .id$, .donor_tag$, .donor_tier, .where$
	selectObject: "TextGrid " + .id$ + .donor_tag$
	.num_int = Get number of intervals: .donor_tier
	.tier_name$ = Get tier name: .donor_tier
	selectObject: "TextGrid " + .id$ + "_ort_awd"
	.num_tiers = Get number of tiers
	if .where$ = "bottom"
		.insert_tier = .num_tiers + 1
	elsif .where$ = "top"
		.insert_tier = 1
		.donor_tier += 1
	endif
	Insert interval tier: .insert_tier, .tier_name$
	for int to .num_int
		if int <> .num_int
			selectObject: "TextGrid " + .id$ + .donor_tag$
			int_boundary = Get end time of interval: .donor_tier, int
			selectObject: "TextGrid " + .id$ + "_ort_awd"
			Insert boundary: .insert_tier, int_boundary
		endif
		selectObject: "TextGrid " + .id$ + .donor_tag$
		.int_label$ = Get label of interval: .donor_tier, int
		selectObject: "TextGrid " + .id$ + "_ort_awd"
		Set interval text: .insert_tier, int, .int_label$
	endfor
endproc


for i to num_ids
	selectObject: "Strings speaker_list"
	id$ = Get string: i
	Read from file: source_path$ + id$ + ".ort.awd.dbl"
	Read from file: source_path$ + id$ + ".ainton.dbl"
	Read from file: source_path$ + id$ + ".gaze.TextGrid"
	selectObject: "TextGrid " + id$ + "_ort_awd"
	Remove tier: 2
	Remove tier: 1
	@addTier: id$, "_ort_awd", 10, "top"
	@addTier: id$, "_ort_awd", 10, "top"
	Remove tier: 12
	Remove tier: 11
	Remove tier: 6
	Remove tier: 5
	@addTier: id$, "_ainton", 1, "bottom"
	@addTier: id$, "_ainton", 2, "bottom"
	@addTier: id$, "_gaze", 2, "bottom"
	@addTier: id$, "_gaze", 4, "bottom"
	selectObject: "TextGrid " + id$ + "_ort_awd"
	Save as text file: dest_path$ + id$ + "_combined.TextGrid"
endfor
