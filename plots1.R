library(ggplot2)




x11() 
ggplot(raines_number_of_reads, aes(x = reorder(sample_name, reads_in_raw_data), y = reads_in_raw_data))+
  geom_point(aes(color = "firebrick"), size = 2, alpha = 0.4)+
  
  geom_point(data = raines_number_of_reads, aes(color = "blue", x = reorder(sample_name, reads_after_alignment), y = reads_after_alignment), size = 2, alpha = 0.7)+
  theme_bw()+
  scale_y_continuous(breaks = seq(0, 5500000, 2500000))+
  labs(x = "Sample", y = "Number of reads", title = "Number of reads in raw data and after alignment", fill = "green")+
  theme(axis.text.x=element_blank(),  text = element_text(size=20))+
  scale_color_identity(name = "Status of sample",
                       breaks = c("firebrick", "blue"),
                       labels = c("Raw\ndata", "After\nalignment"),
                       guide = "legend")

  

ggplot(raines_number_of_reads, aes(y = reads_in_raw_data)) +
  geom_boxplot(aes(color = "firebrick"), fill = "white") +

  geom_boxplot(data = raines_number_of_reads, aes(x = 1, y = reads_after_alignment, color = "blue"), fill = "white")+
  theme(text = element_text(size=20)) + 
  labs(x = NULL, y = "Number of reads", title = "Number of reads before and after alignment")+
  theme_bw() +
  scale_y_continuous(breaks = seq(0, 5500000, 2500000))+
  scale_color_identity(name = "Status of sample",
                       breaks = c("firebrick", "blue"),
                       labels = c("Raw\ndata", "After\nalignment"),
                       guide = "legend")+
  theme(axis.text.x=element_blank())



