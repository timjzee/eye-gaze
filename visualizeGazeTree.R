library(partykit)
library(gplots)

FTO_data <- read.csv("/Users/tim/Documents/IFADVcorpus/FTO_data_pos_processed.csv")
FTO_data2 = FTO_data[FTO_data$floor_transfer_offset < 2.0 & FTO_data$floor_transfer_offset > -2.0,]
hist(FTO_data2$floor_transfer_offset, breaks = seq(-2.0, 2.0, by = 0.1), xlab = "FTO (s)", main = "FTO distribution")


FTO_data2.tree = ctree(floor_transfer_offset ~ t1_seq_initiating + t1_seq_responding + t1_seq_backchannel + t1_proc_duration + t1_proc_speechrate + t2_seq_initiating + t2_seq_responding + t2_seq_backchannel + t2_proc_duration + t2_proc_speechrate + t1_proc_clauses + t2_proc_clauses + t1_proc_frequency + t2_proc_frequency + t1_proc_concreteness + t2_proc_concreteness + t1_nonv_speaker_gaze + t1_nonv_listener_gaze + t1_nonv_pitch + t1_oth_sex + t2_oth_sex, data = FTO_data2, control = ctree_control(mincriterion = 0.95, multiway = TRUE))
plot(FTO_data2.tree, type = "extended", drop_terminal = FALSE)

plotmeans(floor_transfer_offset ~ t1_nonv_speaker_gaze, data = FTO_data2)
plotmeans(floor_transfer_offset ~ t1_nonv_listener_gaze, data = FTO_data2)


FTO_data2.tree2 = ctree(floor_transfer_offset ~ t1_nonv_speaker_gaze + t1_nonv_listener_gaze, data = FTO_data2, control = ctree_control(mincriterion = 0.95, multiway = TRUE))
plot(FTO_data2.tree2, type = "extended", drop_terminal = FALSE)