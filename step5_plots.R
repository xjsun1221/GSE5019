rm(list = ls())
load("step1_output.Rdata")
load("step2_output.Rdata")
load("step4_output.Rdata")
library(dplyr)
#1.火山图----
dat <- mutate(deg,v=-log10(P.Value))
head(dat)
for_label <- dat%>% filter(abs(logFC)>logFC_t & P.Value < 0.05) %>%head(10)
p <- ggplot(data = dat, 
            aes(x = logFC, 
                y = v)) +
  geom_point(alpha=0.4, size=3.5, 
             aes(color=change)) +
  ylab("-log10(Pvalue)")+
  scale_color_manual(values=c("blue", "grey","red"))+
  geom_vline(xintercept=c(-logFC_t,logFC_t),lty=4,col="black",lwd=0.8) +
  geom_hline(yintercept = -log10(0.05),lty=4,col="black",lwd=0.8) +
  theme_bw()
p
volcano_plot <- p +
  geom_point(size = 3, shape = 1, data = for_label) +
  ggrepel::geom_label_repel(
    aes(label = symbol),
    data = for_label,
    color="black"
  )
volcano_plot
ggsave(plot = volcano_plot,filename = paste0(gse,"volcano.png"))
#2.配对样本的差异基因热图----
x=deg$logFC 
names(x)=deg$probe_id 
#cg=c(names(head(sort(x),30)),names(tail(sort(x),30)))
cg = deg$probe_id[deg$change !="stable"]
#热图实现了配对画图，pre在前，post在后
library(pheatmap)
test = data.frame(gsm = colnames(exp),group_list,pairinfo)
test
col = (arrange(test,pairinfo,group_list))$gsm
od = match(col,colnames(exp))
n=exp[cg,od]
annotation_col=data.frame(group= as.character(group_list)[od],
                          pair = as.character(pairinfo)[od])
rownames(annotation_col)=colnames(n) 
library(ggplotify)
heatmap_plot <- as.ggplot(pheatmap(n,show_colnames =F,
                                   show_rownames = F,
                                   scale = "row",
                                   cluster_cols = F, 
                                   annotation_col=annotation_col,
                                   gaps_col = c(2,4)
))
dev.off()
#保存

png(file = paste0(gse,"heatmap.png"))
pheatmap(n,show_colnames =F,
         show_rownames = F,
         scale = "row",
         cluster_cols = F, 
         annotation_col=annotation_col,
         gaps_col = c(2,4)) 
dev.off()

#9.配对样本的箱线图----
expm = exp[match(deg$probe_id,rownames(exp)),]
rownames(expm) = deg$symbol
#配对样本箱线图批量绘制,画10张玩玩
n = 10
library(ggplot2)
x = deg$symbol[order(head(deg$logFC,n))]
dat <- data.frame(pairinfo=pairinfo,group=group_list,t(expm[x,]))
pl = list()
for(i in 1:n){
  pl[[i]] = ggplot(dat, aes_string("group",colnames(dat)[i+2],fill="group")) +
    geom_boxplot() +
    geom_point(size=2, alpha=0.5) +
    geom_line(aes(group=pairinfo), colour="black", linetype="11") +
    xlab("") +
    ylab(paste("Expression of",colnames(dat)[i+2]))+
    theme_classic()+
    theme(legend.position = "none")+
    scale_fill_manual(values = c("#00AFBB", "#E7B800"))
}
#拼图
library(patchwork)
pb_top10= wrap_plots(pl,nrow = 2)+plot_annotation(tag_levels = 'A')
pb_top10
ggsave(plot = pb_top10,filename = paste0(gse,"box.png"),width = 15,height = 6)
load("pca_plot.Rdata")
(pca_plot + volcano_plot +heatmap_plot)/ pb_top10 + plot_annotation(tag_levels = "A")


