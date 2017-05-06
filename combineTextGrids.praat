Read Strings from raw text file: "speaker_list.txt"
num_ids = Get number of strings
source_path$ = "./annotations/source_textgrids/"
dest_path$ = "./annotations/combined_textgrids/"


procedure addTier: .id$, .donor_tag$, .donor_tier
	selectObject: "TextGrid " + .id$ + .donor_tag$
	.num_int = Get number of intervals: .donor_tier
	.tier_name$ = Get tier name: .donor_tier
	selectObject: "TextGrid " + .id$ + "_ort_awd"
	.num_tiers = Get number of tiers
	Insert interval tier: .num_tiers + 1, .tier_name$
	for int to .num_int
		if int <> .num_int
			selectObject: "TextGrid " + .id$ + .donor_tag$
			int_boundary = Get end time of interval: .donor_tier, int
			selectObject: "TextGrid " + .id$ + "_ort_awd"
			Insert boundary: .num_tiers + 1, int_boundary
		endif
		selectObject: "TextGrid " + .id$ + .donor_tag$
		.int_label$ = Get label of interval: .donor_tier, int
		selectObject: "TextGrid " + .id$ + "_ort_awd"
		Set interval text: .num_tiers + 1, int, .int_label$
	endfor
endproc


for i to num_ids
	selectObject: "Strings speaker_list"
	id$ = Get string: i
	Read from file: source_path$ + id$ + ".ort.awd.dbl"
	Read from file: source_path$ + id$ + ".ainton.dbl"
	Read from file: source_path$ + id$ + ".gaze.TextGrid"
	selectObject: "TextGrid " + id$ + "_ort_awd"
	Remove tier: 12
	Remove tier: 11
	Remove tier: 6
	Remove tier: 5
	@addTier: id$, "_ainton", 1
	@addTier: id$, "_ainton", 2
	@addTier: id$, "_gaze", 2
	@addTier: id$, "_gaze", 4
	selectObject: "TextGrid " + id$ + "_ort_awd"
	Save as text file: dest_path$ + id$ + "_combined.TextGrid"
endfor
