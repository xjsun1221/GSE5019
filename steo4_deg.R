rm(list = ls())
load("step1_output.Rdata")
load("step2_output.Rdata")

library(limma)
design=model.matrix(~group_list+pairinfo)
fit=lmFit(exp,design)
fit=eBayes(fit)
deg=topTable(fit,coef=2,number = Inf)
head(deg)

#为deg数据框添加几列
#1.加probe_id列，把行名变成一列
library(dplyr)
deg <- mutate(deg,probe_id=rownames(deg))
#tibble::rownames_to_column()
head(deg)

#merge
deg <- inner_join(deg,ids,by="probe_id")
deg <- deg[!duplicated(deg$symbol),]
head(deg)
#3.加change列：上调或下调，火山图要用
logFC_t=mean(deg$logFC)+2*sd(deg$logFC)
#logFC_t=2
change=ifelse(deg$P.Value>0.05,'stable', 
              ifelse( deg$logFC >logFC_t,'up', 
                      ifelse( deg$logFC < -logFC_t,'down','stable') )
)
deg <- mutate(deg,change)
head(deg)
table(deg$change)

#4.加ENTREZID列，后面富集分析要用
library(ggplot2)
library(clusterProfiler)
library(org.Hs.eg.db)
s2e <- bitr(unique(deg$symbol), fromType = "SYMBOL",
            toType = c( "ENTREZID"),
            OrgDb = org.Hs.eg.db)
head(s2e)
head(deg)
deg <- inner_join(deg,s2e,by=c("symbol"="SYMBOL"))

head(deg)
save(logFC_t,deg,file = "step4_output.Rdata")
