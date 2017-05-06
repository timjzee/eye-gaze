library(partykit)
# library(gplots)

FTO_data <- read.csv("/Users/tim/Documents/IFADVcorpus/FTO_data_auto_pos_processed.csv")
# FTO_data2 = FTO_data[FTO_data$floor_transfer_offset < 2.0 & FTO_data$floor_transfer_offset > -2.0,]
# hist(FTO_data2$floor_transfer_offset, breaks = seq(-2.0, 2.0, by = 0.1), xlab = "FTO (s)", main = "FTO distribution")
hist(FTO_data$floor_transfer_offset, breaks = 20, xlab = "FTO (s)", main = "")

original_colnames = colnames(FTO_data)

colnames(FTO_data)[18] = "speaker_gaze"
colnames(FTO_data)[19] = "listener_gaze"
colnames(FTO_data)[6] = "t1_initiating"
colnames(FTO_data)[7] = "t1_responding"
colnames(FTO_data)[8] = "t1_backchannel"
colnames(FTO_data)[9] = "t2_initiating"
colnames(FTO_data)[10] = "t2_responding"
colnames(FTO_data)[11] = "t2_backchannel"
colnames(FTO_data)[12] = "t1_clauses"
colnames(FTO_data)[13] = "t2_clauses"
colnames(FTO_data)[14] = "t1_frequency"
colnames(FTO_data)[15] = "t2_frequency"
colnames(FTO_data)[16] = "t1_concreteness"
colnames(FTO_data)[17] = "t2_concreteness"
colnames(FTO_data)[23] = "t1_speechrate"
colnames(FTO_data)[24] = "t2_speechrate"
colnames(FTO_data)[25] = "t1_duration"
colnames(FTO_data)[26] = "t2_duration"

FTO_data.tree1 = ctree(floor_transfer_offset ~ speaker_gaze + listener_gaze, data = FTO_data, control = ctree_control(mincriterion = 0.95, multiway = TRUE))

png("/Users/tim/OneDrive/Master/Non-Verbal_Communication/group_assignment/gazetree1.png", width = 5, height = 5, pointsize = 5, units = "cm", res = 600)
par(family="Times New Roman", mar=c(1, 1, 1, 1))
plot(FTO_data.tree1, type = "simple", drop_terminal = FALSE, terminal_panel = node_terminal, tp_args = list(abbreviate = TRUE, FUN = function(node) format(round(node$prediction, 2), nsmall = 2)))
dev.off()

FTO_data.tree2 = ctree(floor_transfer_offset ~ speaker_gaze + listener_gaze + t1_initiating + t1_responding + t1_backchannel + t2_initiating + t2_responding + t2_backchannel, data = FTO_data, control = ctree_control(mincriterion = 0.95, multiway = TRUE))

png("/Users/tim/OneDrive/Master/Non-Verbal_Communication/group_assignment/gazetree2.png", width = 7, height = 5, pointsize = 5, units = "cm", res = 600)
par(family="Times New Roman", mar=c(1, 1, 1, 1))
plot(FTO_data.tree2, type = "simple", drop_terminal = FALSE, terminal_panel = node_terminal, tp_args = list(abbreviate = TRUE, FUN = function(node) format(round(node$prediction, 2), nsmall = 2)))
dev.off()

FTO_data.tree3 = ctree(floor_transfer_offset ~ speaker_gaze + listener_gaze + t1_clauses + t2_clauses + t1_frequency + t2_frequency + t1_concreteness + t2_concreteness + t1_speechrate + t2_speechrate + t1_duration + t2_duration, data = FTO_data, control = ctree_control(mincriterion = 0.95, multiway = TRUE))

png("/Users/tim/OneDrive/Master/Non-Verbal_Communication/group_assignment/gazetree3.png", width = 8, height = 5, pointsize = 5, units = "cm", res = 600)
par(family="Times New Roman", mar=c(1, 1, 1, 1))
plot(FTO_data.tree3, type = "simple", drop_terminal = FALSE, terminal_panel = node_terminal, tp_args = list(abbreviate = TRUE, FUN = function(node) format(round(node$prediction, 2), nsmall = 2)))
dev.off()

FTO_data.tree = ctree(floor_transfer_offset ~ t1_seq_initiating + t1_seq_responding + t1_seq_backchannel + t1_proc_duration + t1_proc_speechrate + t2_seq_initiating + t2_seq_responding + t2_seq_backchannel + t2_proc_duration + t2_proc_speechrate + t1_proc_clauses + t2_proc_clauses + t1_proc_frequency + t2_proc_frequency + t1_proc_concreteness + t2_proc_concreteness + t1_nonv_speaker_gaze + t1_nonv_listener_gaze + t1_nonv_pitch + t1_oth_sex + t2_oth_sex + conversation_time, data = FTO_data, control = ctree_control(mincriterion = 0.95, multiway = TRUE))


colnames(FTO_data) = original_colnames

# Variable importance

detach("package:partykit", unload=TRUE)
library(party)

FTO_data.forest = cforest(floor_transfer_offset ~ t1_seq_initiating + t1_seq_responding + t1_seq_backchannel + t1_proc_duration + t1_proc_speechrate + t2_seq_initiating + t2_seq_responding + t2_seq_backchannel + t2_proc_duration + t2_proc_speechrate + t1_proc_clauses + t2_proc_clauses + t1_proc_frequency + t2_proc_frequency + t1_proc_concreteness + t2_proc_concreteness + t1_nonv_speaker_gaze + t1_nonv_listener_gaze + t1_nonv_pitch + t1_oth_sex + t2_oth_sex + conversation_time, data = FTO_data, controls = cforest_unbiased(ntree = 500, mtry = 3))
variable_importance = varimp(FTO_data.forest)
names(variable_importance) = c("T1 Initiating", "T1 Responding", "T1 Backchannel", "T1 Turn duration", "T1 Speech rate", "T2 Initiating", "T2 Responding", "T2 Backchannel", "T2 Turn duration", "T2 Speech rate", "T1 Clauses", "T2 Clauses", "T1 Frequency", "T2 Frequency", "T1 Concreteness", "T2 Concreteness", "T1 Speaker gaze", "T1 Listener gaze", "T1 Pitch", "T1 Sex", "T2 Sex", "Conversation time")

png("/Users/tim/OneDrive/Master/Non-Verbal_Communication/group_assignment/varimp.png", width = 5, height = 7, pointsize = 5, units = "cm", res = 600)
par(mar=c(4, 8, 2, 2))
bp = barplot(sort(variable_importance), horiz = TRUE, las = 2)
abline(v = abs(min(variable_importance)), lty = 2, col = "red")
dev.off()
par(mar=c(2, 2, 2, 2))

# Correlation between real and predicted FTOs
cor.test(FTO_data$floor_transfer_offset, predict(FTO_data.forest))

# Correlation between variable ranking and Roberts et al.
ranked_names = names(sort(variable_importance))
remove_names = c("T1 Listener gaze", "T1 Speaker gaze", "T1 Pitch")
ranked_names = ranked_names [! ranked_names %in% remove_names]
ranks_tim = length(ranked_names):1
ranks_roberts = c(13,19,11,1,9,16,15,14,4,12,7,17,10,5,8,18,3,2,6)
rank_df = data.frame(ranked_names, ranks_tim, ranks_roberts)

# Associations between predictors
library(lsr)
# pitch - speaker gaze
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t1_nonv_speaker_gaze, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t1_nonv_speaker_gaze, correct=FALSE)
# pitch - listener gaze
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t1_nonv_listener_gaze, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t1_nonv_listener_gaze, correct=FALSE)
# pitch - conversation time
pitch.time = lm(conversation_time ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.time)
sqrt(summary(pitch.time)$r.squared)
# pitch - t1 sex
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t1_oth_sex, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t1_oth_sex, correct=FALSE)
# pitch - t2 sex
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t2_oth_sex, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t2_oth_sex, correct=FALSE)
# pitch - t1 initiating
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t1_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t1_seq_initiating, correct=FALSE)
# pitch - t2 initiating
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t2_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t2_seq_initiating, correct=FALSE)
# pitch - t1 responding
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t1_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t1_seq_responding, correct=FALSE)
# pitch - t2 responding
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t2_seq_responding, correct=FALSE)
# pitch - t1 backchannel
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t1_seq_backchannel, correct=FALSE)
# pitch - t2 backchannel
chisq.test(FTO_data$t1_nonv_pitch, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_nonv_pitch, FTO_data$t2_seq_backchannel, correct=FALSE)
# pitch - t1 duration
pitch.t1_duration = lm(t1_proc_duration ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t1_duration)
sqrt(summary(pitch.t1_duration)$r.squared)
# pitch - t2 duration
pitch.t2_duration = lm(t2_proc_duration ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t2_duration)
sqrt(summary(pitch.t2_duration)$r.squared)
# pitch - t1 frequency
pitch.t1_frequency = lm(t1_proc_frequency ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t1_frequency)
sqrt(summary(pitch.t1_frequency)$r.squared)
# pitch - t2 frequency
pitch.t2_frequency = lm(t2_proc_frequency ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t2_frequency)
sqrt(summary(pitch.t2_frequency)$r.squared)
# pitch - t1 speech rate
pitch.t1_speechrate = lm(t1_proc_speechrate ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t1_speechrate)
sqrt(summary(pitch.t1_speechrate)$r.squared)
# pitch - t2 speech rate
pitch.t2_speechrate = lm(t2_proc_speechrate ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t2_speechrate)
sqrt(summary(pitch.t2_speechrate)$r.squared)
# pitch - t1 clauses
pitch.t1_clauses = lm(t1_proc_clauses ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t1_clauses)
sqrt(summary(pitch.t1_clauses)$r.squared)
# pitch - t2 clauses
pitch.t2_clauses = lm(t2_proc_clauses ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t2_clauses)
sqrt(summary(pitch.t2_clauses)$r.squared)
# pitch - t1 concreteness
pitch.t1_concreteness = lm(t1_proc_concreteness ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t1_concreteness)
sqrt(summary(pitch.t1_concreteness)$r.squared)
# pitch - t2 concreteness
pitch.t2_concreteness = lm(t2_proc_concreteness ~ t1_nonv_pitch, data = FTO_data)
summary(pitch.t2_concreteness)
sqrt(summary(pitch.t2_concreteness)$r.squared)
# speaker gaze - listener gaze
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_nonv_listener_gaze, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_nonv_listener_gaze, correct=FALSE)
# speaker gaze - conversation time
speaker_gaze.time = lm(conversation_time ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.time)
sqrt(summary(speaker_gaze.time)$r.squared)
# speaker gaze - t1 sex
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_oth_sex, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_oth_sex, correct=FALSE)
# speaker gaze - t2 sex
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_oth_sex, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_oth_sex, correct=FALSE)
# speaker gaze - t1 initiating
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_seq_initiating, correct=FALSE)
# speaker gaze - t2 initiating
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_seq_initiating, correct=FALSE)
# speaker gaze - t1 responding
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_seq_responding, correct=FALSE)
# speaker gaze - t2 responding
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_seq_responding, correct=FALSE)
# speaker gaze - t1 backchannel
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t1_seq_backchannel, correct=FALSE)
# speaker gaze - t2 backchannel
chisq.test(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_nonv_speaker_gaze, FTO_data$t2_seq_backchannel, correct=FALSE)
# speaker gaze - t1 duration
speaker_gaze.t1_duration = lm(t1_proc_duration ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t1_duration)
sqrt(summary(speaker_gaze.t1_duration)$r.squared)
# speaker gaze - t2 duration
speaker_gaze.t2_duration = lm(t2_proc_duration ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t2_duration)
sqrt(summary(speaker_gaze.t2_duration)$r.squared)
# speaker gaze - t1 frequency
speaker_gaze.t1_frequency = lm(t1_proc_frequency ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t1_frequency)
sqrt(summary(speaker_gaze.t1_frequency)$r.squared)
# speaker gaze - t2 frequency
speaker_gaze.t2_frequency = lm(t2_proc_frequency ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t2_frequency)
sqrt(summary(speaker_gaze.t2_frequency)$r.squared)
# speaker gaze - t1 speech rate
speaker_gaze.t1_speechrate = lm(t1_proc_speechrate ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t1_speechrate)
sqrt(summary(speaker_gaze.t1_speechrate)$r.squared)
# speaker gaze - t2 speech rate
speaker_gaze.t2_speechrate = lm(t2_proc_speechrate ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t2_speechrate)
sqrt(summary(speaker_gaze.t2_speechrate)$r.squared)
# speaker gaze - t1 clauses
speaker_gaze.t1_clauses = lm(t1_proc_clauses ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t1_clauses)
sqrt(summary(speaker_gaze.t1_clauses)$r.squared)
# speaker gaze - t2 clauses
speaker_gaze.t2_clauses = lm(t2_proc_clauses ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t2_clauses)
sqrt(summary(speaker_gaze.t2_clauses)$r.squared)
# speaker gaze - t1 concreteness
speaker_gaze.t1_concreteness = lm(t1_proc_concreteness ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t1_concreteness)
sqrt(summary(speaker_gaze.t1_concreteness)$r.squared)
# speaker gaze - t2 concreteness
speaker_gaze.t2_concreteness = lm(t2_proc_concreteness ~ t1_nonv_speaker_gaze, data = FTO_data)
summary(speaker_gaze.t2_concreteness)
sqrt(summary(speaker_gaze.t2_concreteness)$r.squared)
# listener gaze - conversation time
listener_gaze.time = lm(conversation_time ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.time)
sqrt(summary(listener_gaze.time)$r.squared)
# listener gaze - t1 sex
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_oth_sex, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_oth_sex, correct=FALSE)
# listener gaze - t2 sex
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_oth_sex, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_oth_sex, correct=FALSE)
# listener gaze - t1 initiating
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_seq_initiating, correct=FALSE)
# listener gaze - t2 initiating
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_seq_initiating, correct=FALSE)
# listener gaze - t1 responding
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_seq_responding, correct=FALSE)
# listener gaze - t2 responding
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_seq_responding, correct=FALSE)
# listener gaze - t1 backchannel
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t1_seq_backchannel, correct=FALSE)
# listener gaze - t2 backchannel
chisq.test(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_nonv_listener_gaze, FTO_data$t2_seq_backchannel, correct=FALSE)
# listener gaze - t1 duration
listener_gaze.t1_duration = lm(t1_proc_duration ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t1_duration)
sqrt(summary(listener_gaze.t1_duration)$r.squared)
# listener gaze - t2 duration
listener_gaze.t2_duration = lm(t2_proc_duration ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t2_duration)
sqrt(summary(listener_gaze.t2_duration)$r.squared)
# listener gaze - t1 frequency
listener_gaze.t1_frequency = lm(t1_proc_frequency ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t1_frequency)
sqrt(summary(listener_gaze.t1_frequency)$r.squared)
# listener gaze - t2 frequency
listener_gaze.t2_frequency = lm(t2_proc_frequency ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t2_frequency)
sqrt(summary(listener_gaze.t2_frequency)$r.squared)
# listener gaze - t1 speech rate
listener_gaze.t1_speechrate = lm(t1_proc_speechrate ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t1_speechrate)
sqrt(summary(listener_gaze.t1_speechrate)$r.squared)
# listener gaze - t2 speech rate
listener_gaze.t2_speechrate = lm(t2_proc_speechrate ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t2_speechrate)
sqrt(summary(listener_gaze.t2_speechrate)$r.squared)
# listener gaze - t1 clauses
listener_gaze.t1_clauses = lm(t1_proc_clauses ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t1_clauses)
sqrt(summary(listener_gaze.t1_clauses)$r.squared)
# listener gaze - t2 clauses
listener_gaze.t2_clauses = lm(t2_proc_clauses ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t2_clauses)
sqrt(summary(listener_gaze.t2_clauses)$r.squared)
# listener gaze - t1 concreteness
listener_gaze.t1_concreteness = lm(t1_proc_concreteness ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t1_concreteness)
sqrt(summary(listener_gaze.t1_concreteness)$r.squared)
# listener gaze - t2 concreteness
listener_gaze.t2_concreteness = lm(t2_proc_concreteness ~ t1_nonv_listener_gaze, data = FTO_data)
summary(listener_gaze.t2_concreteness)
sqrt(summary(listener_gaze.t2_concreteness)$r.squared)
# conversation time - T1 Sex
time.t1_sex = lm(conversation_time ~ t1_oth_sex, data = FTO_data)
summary(time.t1_sex)
sqrt(summary(time.t1_sex)$r.squared)
# conversation time - T2 Sex
time.t2_sex = lm(conversation_time ~ t2_oth_sex, data = FTO_data)
summary(time.t2_sex)
sqrt(summary(time.t2_sex)$r.squared)
# conversation time - T1 initiating
time.t1_initiating = lm(conversation_time ~ t1_seq_initiating, data = FTO_data)
summary(time.t1_initiating)
sqrt(summary(time.t1_initiating)$r.squared)
# conversation time - T2 initiating
time.t2_initiating = lm(conversation_time ~ t2_seq_initiating, data = FTO_data)
summary(time.t2_initiating)
sqrt(summary(time.t2_initiating)$r.squared)
# conversation time - T1 responding
time.t1_responding = lm(conversation_time ~ t1_seq_responding, data = FTO_data)
summary(time.t1_responding)
sqrt(summary(time.t1_responding)$r.squared)
# conversation time - T2 responding
time.t2_responding = lm(conversation_time ~ t2_seq_responding, data = FTO_data)
summary(time.t2_responding)
sqrt(summary(time.t2_responding)$r.squared)
# conversation time - T1 backchannel
time.t1_backchannel = lm(conversation_time ~ t1_seq_backchannel, data = FTO_data)
summary(time.t1_backchannel)
sqrt(summary(time.t1_backchannel)$r.squared)
# conversation time - T2 backchannel
time.t2_backchannel = lm(conversation_time ~ t2_seq_backchannel, data = FTO_data)
summary(time.t2_backchannel)
sqrt(summary(time.t2_backchannel)$r.squared)
# conversation time - t1 duration
cor.test(FTO_data$conversation_time, FTO_data$t1_proc_duration)
# conversation time - t2 duration
cor.test(FTO_data$conversation_time, FTO_data$t2_proc_duration)
# conversation time - t1 frequency
cor.test(FTO_data$conversation_time, FTO_data$t1_proc_frequency)
# conversation time - t2 frequency
cor.test(FTO_data$conversation_time, FTO_data$t2_proc_frequency)
# conversation time - t1 speech rate
cor.test(FTO_data$conversation_time, FTO_data$t1_proc_speechrate)
# conversation time - t2 speech rate
cor.test(FTO_data$conversation_time, FTO_data$t2_proc_speechrate)
# conversation time - t1 clauses
cor.test(FTO_data$conversation_time, FTO_data$t1_proc_clauses)
# conversation time - t2 clauses
cor.test(FTO_data$conversation_time, FTO_data$t2_proc_clauses)
# conversation time - t1 concreteness
cor.test(FTO_data$conversation_time, FTO_data$t1_proc_concreteness)
# conversation time - t2 concreteness
cor.test(FTO_data$conversation_time, FTO_data$t2_proc_concreteness)
# t1 sex - t2 sex
chisq.test(FTO_data$t1_oth_sex, FTO_data$t2_oth_sex, correct=FALSE)
cramersV(FTO_data$t1_oth_sex, FTO_data$t2_oth_sex, correct=FALSE)
# t1 sex - t1 initiating
chisq.test(FTO_data$t1_oth_sex, FTO_data$t1_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_oth_sex, FTO_data$t1_seq_initiating, correct=FALSE)
# t1 sex - t2 initiating
chisq.test(FTO_data$t1_oth_sex, FTO_data$t2_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_oth_sex, FTO_data$t2_seq_initiating, correct=FALSE)
# t1 sex - t1 responding
chisq.test(FTO_data$t1_oth_sex, FTO_data$t1_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_oth_sex, FTO_data$t1_seq_responding, correct=FALSE)
# t1 sex - t2 responding
chisq.test(FTO_data$t1_oth_sex, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_oth_sex, FTO_data$t2_seq_responding, correct=FALSE)
# t1 sex - t1 backchannel
chisq.test(FTO_data$t1_oth_sex, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_oth_sex, FTO_data$t1_seq_backchannel, correct=FALSE)
# t1 sex - t2 backchannel
chisq.test(FTO_data$t1_oth_sex, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_oth_sex, FTO_data$t2_seq_backchannel, correct=FALSE)
# t1 sex - t1 duration
t1_sex.t1_duration = lm(t1_proc_duration ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t1_duration)
sqrt(summary(t1_sex.t1_duration)$r.squared)
# t1 sex - t2 duration
t1_sex.t2_duration = lm(t2_proc_duration ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t2_duration)
sqrt(summary(t1_sex.t2_duration)$r.squared)
# t1 sex - t1 frequency
t1_sex.t1_frequency = lm(t1_proc_frequency ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t1_frequency)
sqrt(summary(t1_sex.t1_frequency)$r.squared)
# t1 sex - t2 frequency
t1_sex.t2_frequency = lm(t2_proc_frequency ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t2_frequency)
sqrt(summary(t1_sex.t2_frequency)$r.squared)
# t1 sex - t1 speech rate
t1_sex.t1_speechrate = lm(t1_proc_speechrate ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t1_speechrate)
sqrt(summary(t1_sex.t1_speechrate)$r.squared)
# t1 sex - t2 speech rate
t1_sex.t2_speechrate = lm(t2_proc_speechrate ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t2_speechrate)
sqrt(summary(t1_sex.t2_speechrate)$r.squared)
# t1 sex - t1 clauses
t1_sex.t1_clauses = lm(t1_proc_clauses ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t1_clauses)
sqrt(summary(t1_sex.t1_clauses)$r.squared)
# t1 sex - t2 clauses
t1_sex.t2_clauses = lm(t2_proc_clauses ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t2_clauses)
sqrt(summary(t1_sex.t2_clauses)$r.squared)
# t1 sex - t1 concreteness
t1_sex.t1_concreteness = lm(t1_proc_concreteness ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t1_concreteness)
sqrt(summary(t1_sex.t1_concreteness)$r.squared)
# t1 sex - t2 concreteness
t1_sex.t2_concreteness = lm(t2_proc_concreteness ~ t1_oth_sex, data = FTO_data)
summary(t1_sex.t2_concreteness)
sqrt(summary(t1_sex.t2_concreteness)$r.squared)
# t2 sex - t1 initiating
chisq.test(FTO_data$t2_oth_sex, FTO_data$t1_seq_initiating, correct=FALSE)
cramersV(FTO_data$t2_oth_sex, FTO_data$t1_seq_initiating, correct=FALSE)
# t2 sex - t2 initiating
chisq.test(FTO_data$t2_oth_sex, FTO_data$t2_seq_initiating, correct=FALSE)
cramersV(FTO_data$t2_oth_sex, FTO_data$t2_seq_initiating, correct=FALSE)
# t2 sex - t1 responding
chisq.test(FTO_data$t2_oth_sex, FTO_data$t1_seq_responding, correct=FALSE)
cramersV(FTO_data$t2_oth_sex, FTO_data$t1_seq_responding, correct=FALSE)
# t2 sex - t2 responding
chisq.test(FTO_data$t2_oth_sex, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t2_oth_sex, FTO_data$t2_seq_responding, correct=FALSE)
# t2 sex - t1 backchannel
chisq.test(FTO_data$t2_oth_sex, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t2_oth_sex, FTO_data$t1_seq_backchannel, correct=FALSE)
# t2 sex - t2 backchannel
chisq.test(FTO_data$t2_oth_sex, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t2_oth_sex, FTO_data$t2_seq_backchannel, correct=FALSE)
# t2 sex - t1 duration
t2_sex.t1_duration = lm(t1_proc_duration ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t1_duration)
sqrt(summary(t2_sex.t1_duration)$r.squared)
# t2 sex - t2 duration
t2_sex.t2_duration = lm(t2_proc_duration ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t2_duration)
sqrt(summary(t2_sex.t2_duration)$r.squared)
# t2 sex - t1 frequency
t2_sex.t1_frequency = lm(t1_proc_frequency ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t1_frequency)
sqrt(summary(t2_sex.t1_frequency)$r.squared)
# t2 sex - t2 frequency
t2_sex.t2_frequency = lm(t2_proc_frequency ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t2_frequency)
sqrt(summary(t2_sex.t2_frequency)$r.squared)
# t2 sex - t1 speech rate
t2_sex.t1_speechrate = lm(t1_proc_speechrate ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t1_speechrate)
sqrt(summary(t2_sex.t1_speechrate)$r.squared)
# t2 sex - t2 speech rate
t2_sex.t2_speechrate = lm(t2_proc_speechrate ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t2_speechrate)
sqrt(summary(t2_sex.t2_speechrate)$r.squared)
# t2 sex - t1 clauses
t2_sex.t1_clauses = lm(t1_proc_clauses ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t1_clauses)
sqrt(summary(t2_sex.t1_clauses)$r.squared)
# t2 sex - t2 clauses
t2_sex.t2_clauses = lm(t2_proc_clauses ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t2_clauses)
sqrt(summary(t2_sex.t2_clauses)$r.squared)
# t2 sex - t1 concreteness
t2_sex.t1_concreteness = lm(t1_proc_concreteness ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t1_concreteness)
sqrt(summary(t2_sex.t1_concreteness)$r.squared)
# t2 sex - t2 concreteness
t2_sex.t2_concreteness = lm(t2_proc_concreteness ~ t2_oth_sex, data = FTO_data)
summary(t2_sex.t2_concreteness)
sqrt(summary(t2_sex.t2_concreteness)$r.squared)
# t1 initiating - t2 initiating
chisq.test(FTO_data$t1_seq_initiating, FTO_data$t2_seq_initiating, correct=FALSE)
cramersV(FTO_data$t1_seq_initiating, FTO_data$t2_seq_initiating, correct=FALSE)
# t1 initiating - t1 responding
chisq.test(FTO_data$t1_seq_initiating, FTO_data$t1_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_seq_initiating, FTO_data$t1_seq_responding, correct=FALSE)
# t1 initiating - t2 responding
chisq.test(FTO_data$t1_seq_initiating, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_seq_initiating, FTO_data$t2_seq_responding, correct=FALSE)
# t1 initiating - t1 backchannel
chisq.test(FTO_data$t1_seq_initiating, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_seq_initiating, FTO_data$t1_seq_backchannel, correct=FALSE)
# t1 initiating - t2 backchannel
chisq.test(FTO_data$t1_seq_initiating, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_seq_initiating, FTO_data$t2_seq_backchannel, correct=FALSE)
# t1 initiating - t1 duration
t1_initiating.t1_duration = lm(t1_proc_duration ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t1_duration)
sqrt(summary(t1_initiating.t1_duration)$r.squared)
# t1 initiating - t2 duration
t1_initiating.t2_duration = lm(t2_proc_duration ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t2_duration)
sqrt(summary(t1_initiating.t2_duration)$r.squared)
# t1 initiating - t1 frequency
t1_initiating.t1_frequency = lm(t1_proc_frequency ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t1_frequency)
sqrt(summary(t1_initiating.t1_frequency)$r.squared)
# t1 initiating - t2 frequency
t1_initiating.t2_frequency = lm(t2_proc_frequency ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t2_frequency)
sqrt(summary(t1_initiating.t2_frequency)$r.squared)
# t1 initiating - t1 speech rate
t1_initiating.t1_speechrate = lm(t1_proc_speechrate ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t1_speechrate)
sqrt(summary(t1_initiating.t1_speechrate)$r.squared)
# t1 initiating - t2 speech rate
t1_initiating.t2_speechrate = lm(t2_proc_speechrate ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t2_speechrate)
sqrt(summary(t1_initiating.t2_speechrate)$r.squared)
# t1 initiating - t1 clauses
t1_initiating.t1_clauses = lm(t1_proc_clauses ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t1_clauses)
sqrt(summary(t1_initiating.t1_clauses)$r.squared)
# t1 initiating - t2 clauses
t1_initiating.t2_clauses = lm(t2_proc_clauses ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t2_clauses)
sqrt(summary(t1_initiating.t2_clauses)$r.squared)
# t1 initiating - t1 concreteness
t1_initiating.t1_concreteness = lm(t1_proc_concreteness ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t1_concreteness)
sqrt(summary(t1_initiating.t1_concreteness)$r.squared)
# t1 initiating - t2 concreteness
t1_initiating.t2_concreteness = lm(t2_proc_concreteness ~ t1_seq_initiating, data = FTO_data)
summary(t1_initiating.t2_concreteness)
sqrt(summary(t1_initiating.t2_concreteness)$r.squared)
# t2 initiating - t1 responding
chisq.test(FTO_data$t2_seq_initiating, FTO_data$t1_seq_responding, correct=FALSE)
cramersV(FTO_data$t2_seq_initiating, FTO_data$t1_seq_responding, correct=FALSE)
# t2 initiating - t2 responding
chisq.test(FTO_data$t2_seq_initiating, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t2_seq_initiating, FTO_data$t2_seq_responding, correct=FALSE)
# t2 initiating - t1 backchannel
chisq.test(FTO_data$t2_seq_initiating, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t2_seq_initiating, FTO_data$t1_seq_backchannel, correct=FALSE)
# t2 initiating - t2 backchannel
chisq.test(FTO_data$t2_seq_initiating, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t2_seq_initiating, FTO_data$t2_seq_backchannel, correct=FALSE)
# t2 initiating - t1 duration
t2_initiating.t1_duration = lm(t1_proc_duration ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t1_duration)
sqrt(summary(t2_initiating.t1_duration)$r.squared)
# t2 initiating - t2 duration
t2_initiating.t2_duration = lm(t2_proc_duration ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t2_duration)
sqrt(summary(t2_initiating.t2_duration)$r.squared)
# t2 initiating - t1 frequency
t2_initiating.t1_frequency = lm(t1_proc_frequency ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t1_frequency)
sqrt(summary(t2_initiating.t1_frequency)$r.squared)
# t2 initiating - t2 frequency
t2_initiating.t2_frequency = lm(t2_proc_frequency ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t2_frequency)
sqrt(summary(t2_initiating.t2_frequency)$r.squared)
# t2 initiating - t1 speech rate
t2_initiating.t1_speechrate = lm(t1_proc_speechrate ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t1_speechrate)
sqrt(summary(t2_initiating.t1_speechrate)$r.squared)
# t2 initiating - t2 speech rate
t2_initiating.t2_speechrate = lm(t2_proc_speechrate ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t2_speechrate)
sqrt(summary(t2_initiating.t2_speechrate)$r.squared)
# t2 initiating - t1 clauses
t2_initiating.t1_clauses = lm(t1_proc_clauses ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t1_clauses)
sqrt(summary(t2_initiating.t1_clauses)$r.squared)
# t2 initiating - t2 clauses
t2_initiating.t2_clauses = lm(t2_proc_clauses ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t2_clauses)
sqrt(summary(t2_initiating.t2_clauses)$r.squared)
# t2 initiating - t1 concreteness
t2_initiating.t1_concreteness = lm(t1_proc_concreteness ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t1_concreteness)
sqrt(summary(t2_initiating.t1_concreteness)$r.squared)
# t2 initiating - t2 concreteness
t2_initiating.t2_concreteness = lm(t2_proc_concreteness ~ t2_seq_initiating, data = FTO_data)
summary(t2_initiating.t2_concreteness)
sqrt(summary(t2_initiating.t2_concreteness)$r.squared)
# t1 responding - t2 responding
chisq.test(FTO_data$t1_seq_responding, FTO_data$t2_seq_responding, correct=FALSE)
cramersV(FTO_data$t1_seq_responding, FTO_data$t2_seq_responding, correct=FALSE)
# t1 responding - t1 backchannel
chisq.test(FTO_data$t1_seq_responding, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_seq_responding, FTO_data$t1_seq_backchannel, correct=FALSE)
# t1 responding - t2 backchannel
chisq.test(FTO_data$t1_seq_responding, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_seq_responding, FTO_data$t2_seq_backchannel, correct=FALSE)
# t1 responding - t1 duration
t1_responding.t1_duration = lm(t1_proc_duration ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t1_duration)
sqrt(summary(t1_responding.t1_duration)$r.squared)
# t1 responding - t2 duration
t1_responding.t2_duration = lm(t2_proc_duration ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t2_duration)
sqrt(summary(t1_responding.t2_duration)$r.squared)
# t1 responding - t1 frequency
t1_responding.t1_frequency = lm(t1_proc_frequency ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t1_frequency)
sqrt(summary(t1_responding.t1_frequency)$r.squared)
# t1 responding - t2 frequency
t1_responding.t2_frequency = lm(t2_proc_frequency ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t2_frequency)
sqrt(summary(t1_responding.t2_frequency)$r.squared)
# t1 responding - t1 speech rate
t1_responding.t1_speechrate = lm(t1_proc_speechrate ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t1_speechrate)
sqrt(summary(t1_responding.t1_speechrate)$r.squared)
# t1 responding - t2 speech rate
t1_responding.t2_speechrate = lm(t2_proc_speechrate ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t2_speechrate)
sqrt(summary(t1_responding.t2_speechrate)$r.squared)
# t1 responding - t1 clauses
t1_responding.t1_clauses = lm(t1_proc_clauses ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t1_clauses)
sqrt(summary(t1_responding.t1_clauses)$r.squared)
# t1 responding - t2 clauses
t1_responding.t2_clauses = lm(t2_proc_clauses ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t2_clauses)
sqrt(summary(t1_responding.t2_clauses)$r.squared)
# t1 responding - t1 concreteness
t1_responding.t1_concreteness = lm(t1_proc_concreteness ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t1_concreteness)
sqrt(summary(t1_responding.t1_concreteness)$r.squared)
# t1 responding - t2 concreteness
t1_responding.t2_concreteness = lm(t2_proc_concreteness ~ t1_seq_responding, data = FTO_data)
summary(t1_responding.t2_concreteness)
sqrt(summary(t1_responding.t2_concreteness)$r.squared)
# t2 responding - t1 backchannel
chisq.test(FTO_data$t2_seq_responding, FTO_data$t1_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t2_seq_responding, FTO_data$t1_seq_backchannel, correct=FALSE)
# t2 responding - t2 backchannel
chisq.test(FTO_data$t2_seq_responding, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t2_seq_responding, FTO_data$t2_seq_backchannel, correct=FALSE)
# t2 responding - t1 duration
t2_responding.t1_duration = lm(t1_proc_duration ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t1_duration)
sqrt(summary(t2_responding.t1_duration)$r.squared)
# t2 responding - t2 duration
t2_responding.t2_duration = lm(t2_proc_duration ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t2_duration)
sqrt(summary(t2_responding.t2_duration)$r.squared)
# t2 responding - t1 frequency
t2_responding.t1_frequency = lm(t1_proc_frequency ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t1_frequency)
sqrt(summary(t2_responding.t1_frequency)$r.squared)
# t2 responding - t2 frequency
t2_responding.t2_frequency = lm(t2_proc_frequency ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t2_frequency)
sqrt(summary(t2_responding.t2_frequency)$r.squared)
# t2 responding - t1 speech rate
t2_responding.t1_speechrate = lm(t1_proc_speechrate ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t1_speechrate)
sqrt(summary(t2_responding.t1_speechrate)$r.squared)
# t2 responding - t2 speech rate
t2_responding.t2_speechrate = lm(t2_proc_speechrate ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t2_speechrate)
sqrt(summary(t2_responding.t2_speechrate)$r.squared)
# t2 responding - t1 clauses
t2_responding.t1_clauses = lm(t1_proc_clauses ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t1_clauses)
sqrt(summary(t2_responding.t1_clauses)$r.squared)
# t2 responding - t2 clauses
t2_responding.t2_clauses = lm(t2_proc_clauses ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t2_clauses)
sqrt(summary(t2_responding.t2_clauses)$r.squared)
# t2 responding - t1 concreteness
t2_responding.t1_concreteness = lm(t1_proc_concreteness ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t1_concreteness)
sqrt(summary(t2_responding.t1_concreteness)$r.squared)
# t2 responding - t2 concreteness
t2_responding.t2_concreteness = lm(t2_proc_concreteness ~ t2_seq_responding, data = FTO_data)
summary(t2_responding.t2_concreteness)
sqrt(summary(t2_responding.t2_concreteness)$r.squared)
# t1 backchannel - t2 backchannel
chisq.test(FTO_data$t1_seq_backchannel, FTO_data$t2_seq_backchannel, correct=FALSE)
cramersV(FTO_data$t1_seq_backchannel, FTO_data$t2_seq_backchannel, correct=FALSE)
# t1 backchannel - t1 duration
t1_backchannel.t1_duration = lm(t1_proc_duration ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t1_duration)
sqrt(summary(t1_backchannel.t1_duration)$r.squared)
# t1 backchannel - t2 duration
t1_backchannel.t2_duration = lm(t2_proc_duration ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t2_duration)
sqrt(summary(t1_backchannel.t2_duration)$r.squared)
# t1 backchannel - t1 frequency
t1_backchannel.t1_frequency = lm(t1_proc_frequency ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t1_frequency)
sqrt(summary(t1_backchannel.t1_frequency)$r.squared)
# t1 backchannel - t2 frequency
t1_backchannel.t2_frequency = lm(t2_proc_frequency ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t2_frequency)
sqrt(summary(t1_backchannel.t2_frequency)$r.squared)
# t1 backchannel - t1 speech rate
t1_backchannel.t1_speechrate = lm(t1_proc_speechrate ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t1_speechrate)
sqrt(summary(t1_backchannel.t1_speechrate)$r.squared)
# t1 backchannel - t2 speech rate
t1_backchannel.t2_speechrate = lm(t2_proc_speechrate ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t2_speechrate)
sqrt(summary(t1_backchannel.t2_speechrate)$r.squared)
# t1 backchannel - t1 clauses
t1_backchannel.t1_clauses = lm(t1_proc_clauses ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t1_clauses)
sqrt(summary(t1_backchannel.t1_clauses)$r.squared)
# t1 backchannel - t2 clauses
t1_backchannel.t2_clauses = lm(t2_proc_clauses ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t2_clauses)
sqrt(summary(t1_backchannel.t2_clauses)$r.squared)
# t1 backchannel - t1 concreteness
t1_backchannel.t1_concreteness = lm(t1_proc_concreteness ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t1_concreteness)
sqrt(summary(t1_backchannel.t1_concreteness)$r.squared)
# t1 backchannel - t2 concreteness
t1_backchannel.t2_concreteness = lm(t2_proc_concreteness ~ t1_seq_backchannel, data = FTO_data)
summary(t1_backchannel.t2_concreteness)
sqrt(summary(t1_backchannel.t2_concreteness)$r.squared)
# t2 backchannel - t1 duration
t2_backchannel.t1_duration = lm(t1_proc_duration ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t1_duration)
sqrt(summary(t2_backchannel.t1_duration)$r.squared)
# t2 backchannel - t2 duration
t2_backchannel.t2_duration = lm(t2_proc_duration ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t2_duration)
sqrt(summary(t2_backchannel.t2_duration)$r.squared)
# t2 backchannel - t1 frequency
t2_backchannel.t1_frequency = lm(t1_proc_frequency ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t1_frequency)
sqrt(summary(t2_backchannel.t1_frequency)$r.squared)
# t2 backchannel - t2 frequency
t2_backchannel.t2_frequency = lm(t2_proc_frequency ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t2_frequency)
sqrt(summary(t2_backchannel.t2_frequency)$r.squared)
# t2 backchannel - t1 speech rate
t2_backchannel.t1_speechrate = lm(t1_proc_speechrate ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t1_speechrate)
sqrt(summary(t2_backchannel.t1_speechrate)$r.squared)
# t2 backchannel - t2 speech rate
t2_backchannel.t2_speechrate = lm(t2_proc_speechrate ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t2_speechrate)
sqrt(summary(t2_backchannel.t2_speechrate)$r.squared)
# t2 backchannel - t1 clauses
t2_backchannel.t1_clauses = lm(t1_proc_clauses ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t1_clauses)
sqrt(summary(t2_backchannel.t1_clauses)$r.squared)
# t2 backchannel - t2 clauses
t2_backchannel.t2_clauses = lm(t2_proc_clauses ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t2_clauses)
sqrt(summary(t2_backchannel.t2_clauses)$r.squared)
# t2 backchannel - t1 concreteness
t2_backchannel.t1_concreteness = lm(t1_proc_concreteness ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t1_concreteness)
sqrt(summary(t2_backchannel.t1_concreteness)$r.squared)
# t2 backchannel - t2 concreteness
t2_backchannel.t2_concreteness = lm(t2_proc_concreteness ~ t2_seq_backchannel, data = FTO_data)
summary(t2_backchannel.t2_concreteness)
sqrt(summary(t2_backchannel.t2_concreteness)$r.squared)
# t1 duration - t2 duration
cor.test(FTO_data$t1_proc_duration, FTO_data$t2_proc_duration)
# t1 duration - t1 frequency
cor.test(FTO_data$t1_proc_duration, FTO_data$t1_proc_frequency)
# t1 duration - t2 frequency
cor.test(FTO_data$t1_proc_duration, FTO_data$t2_proc_frequency)
# t1 duration - t1 speech rate
cor.test(FTO_data$t1_proc_duration, FTO_data$t1_proc_speechrate)
# t1 duration - t2 speech rate
cor.test(FTO_data$t1_proc_duration, FTO_data$t2_proc_speechrate)
# t1 duration - t1 clauses
cor.test(FTO_data$t1_proc_duration, FTO_data$t1_proc_clauses)
# t1 duration - t2 clauses
cor.test(FTO_data$t1_proc_duration, FTO_data$t2_proc_clauses)
# t1 duration - t1 concreteness
cor.test(FTO_data$t1_proc_duration, FTO_data$t1_proc_concreteness)
# t1 duration - t2 concreteness
cor.test(FTO_data$t1_proc_duration, FTO_data$t2_proc_concreteness)
# t2 duration - t1 frequency
cor.test(FTO_data$t2_proc_duration, FTO_data$t1_proc_frequency)
# t2 duration - t2 frequency
cor.test(FTO_data$t2_proc_duration, FTO_data$t2_proc_frequency)
# t2 duration - t1 speech rate
cor.test(FTO_data$t2_proc_duration, FTO_data$t1_proc_speechrate)
# t2 duration - t2 speech rate
cor.test(FTO_data$t2_proc_duration, FTO_data$t2_proc_speechrate)
# t2 duration - t1 clauses
cor.test(FTO_data$t2_proc_duration, FTO_data$t1_proc_clauses)
# t2 duration - t2 clauses
cor.test(FTO_data$t2_proc_duration, FTO_data$t2_proc_clauses)
# t2 duration - t1 concreteness
cor.test(FTO_data$t2_proc_duration, FTO_data$t1_proc_concreteness)
# t2 duration - t2 concreteness
cor.test(FTO_data$t2_proc_duration, FTO_data$t2_proc_concreteness)
# t1 frequency - t2 frequency
cor.test(FTO_data$t1_proc_frequency, FTO_data$t2_proc_frequency)
# t1 frequency - t1 speech rate
cor.test(FTO_data$t1_proc_frequency, FTO_data$t1_proc_speechrate)
# t1 frequency - t2 speech rate
cor.test(FTO_data$t1_proc_frequency, FTO_data$t2_proc_speechrate)
# t1 frequency - t1 clauses
cor.test(FTO_data$t1_proc_frequency, FTO_data$t1_proc_clauses)
# t1 frequency - t2 clauses
cor.test(FTO_data$t1_proc_frequency, FTO_data$t2_proc_clauses)
# t1 frequency - t1 concreteness
cor.test(FTO_data$t1_proc_frequency, FTO_data$t1_proc_concreteness)
# t1 frequency - t2 concreteness
cor.test(FTO_data$t1_proc_frequency, FTO_data$t2_proc_concreteness)
# t2 frequency - t1 speech rate
cor.test(FTO_data$t2_proc_frequency, FTO_data$t1_proc_speechrate)
# t2 frequency - t2 speech rate
cor.test(FTO_data$t2_proc_frequency, FTO_data$t2_proc_speechrate)
# t2 frequency - t1 clauses
cor.test(FTO_data$t2_proc_frequency, FTO_data$t1_proc_clauses)
# t2 frequency - t2 clauses
cor.test(FTO_data$t2_proc_frequency, FTO_data$t2_proc_clauses)
# t2 frequency - t1 concreteness
cor.test(FTO_data$t2_proc_frequency, FTO_data$t1_proc_concreteness)
# t2 frequency - t2 concreteness
cor.test(FTO_data$t2_proc_frequency, FTO_data$t2_proc_concreteness)
# t1 speech rate - t2 speech rate
cor.test(FTO_data$t1_proc_speechrate, FTO_data$t2_proc_speechrate)
# t1 speech rate - t1 clauses
cor.test(FTO_data$t1_proc_speechrate, FTO_data$t1_proc_clauses)
# t1 speech rate - t2 clauses
cor.test(FTO_data$t1_proc_speechrate, FTO_data$t2_proc_clauses)
# t1 speech rate - t1 concreteness
cor.test(FTO_data$t1_proc_speechrate, FTO_data$t1_proc_concreteness)
# t1 speech rate - t2 concreteness
cor.test(FTO_data$t1_proc_speechrate, FTO_data$t2_proc_concreteness)
# t2 speech rate - t1 clauses
cor.test(FTO_data$t2_proc_speechrate, FTO_data$t1_proc_clauses)
# t2 speech rate - t2 clauses
cor.test(FTO_data$t2_proc_speechrate, FTO_data$t2_proc_clauses)
# t2 speech rate - t1 concreteness
cor.test(FTO_data$t2_proc_speechrate, FTO_data$t1_proc_concreteness)
# t2 speech rate - t2 concreteness
cor.test(FTO_data$t2_proc_speechrate, FTO_data$t2_proc_concreteness)
# t1 clauses - t2 clauses
cor.test(FTO_data$t1_proc_clauses, FTO_data$t2_proc_clauses)
# t1 clauses - t1 concreteness
cor.test(FTO_data$t1_proc_clauses, FTO_data$t1_proc_concreteness)
# t1 clauses - t2 concreteness
cor.test(FTO_data$t1_proc_clauses, FTO_data$t2_proc_concreteness)
# t2 clauses - t1 concreteness
cor.test(FTO_data$t2_proc_clauses, FTO_data$t1_proc_concreteness)
# t2 clauses - t2 concreteness
cor.test(FTO_data$t2_proc_clauses, FTO_data$t2_proc_concreteness)
# t1 concreteness - t2 concreteness
cor.test(FTO_data$t1_proc_concreteness, FTO_data$t2_proc_concreteness)

# Explore individual variables

# Gaze
plotmeans(floor_transfer_offset ~ t1_nonv_speaker_gaze, data = FTO_data2)
plotmeans(floor_transfer_offset ~ t1_nonv_listener_gaze, data = FTO_data2)
# Turn duration
FTO_data3 = FTO_data2[FTO_data2$t1_proc_duration < 6 & FTO_data2$t2_proc_duration < 6,]
FTO_data3$t1_proc_duration = cut(FTO_data3$t1_proc_duration, seq(0,6,0.5))
plotmeans(floor_transfer_offset ~ t1_proc_duration, data = FTO_data3)
FTO_data3$t2_proc_duration = cut(FTO_data3$t2_proc_duration, seq(0,6,0.5))
plotmeans(floor_transfer_offset ~ t2_proc_duration, data = FTO_data3)
# Speech rate
qs = unname(quantile(FTO_data2$t1_proc_speechrate))
FTO_data2$t1_proc_speechrate = cut(FTO_data2$t1_proc_speechrate, qs)
plotmeans(floor_transfer_offset ~ t1_proc_speechrate, data = FTO_data2)
qs2 = unname(quantile(FTO_data2$t2_proc_speechrate, na.rm = TRUE))
FTO_data2$t2_proc_speechrate = cut(FTO_data2$t2_proc_speechrate, qs2)
plotmeans(floor_transfer_offset ~ t2_proc_speechrate, data = FTO_data2)
# Initiating / Responding
plotmeans(floor_transfer_offset ~ t2_seq_responding, data = FTO_data2)
