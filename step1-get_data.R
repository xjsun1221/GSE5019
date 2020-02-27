rm(list = ls())
options(stringsAsFactors = F)
library(GEOquery)
library(stringr)
library(AnnoProbe)
gse = "GSE5109"

if(require(AnnoProbe)){
  if(!file.exists(paste0(gse,"_eSet.Rdata"))) geoChina(gse)
  load(paste0(gse,"_eSet.Rdata"))
  eSet <- gset
  rm(gset)
}else{
  eSet <- getGEO(gse, 
                 destdir = '.', 
                 getGPL = F)
}

#(1)提取表达矩阵exp
exp <- exprs(eSet[[1]])
exp[1:4,1:4]
exp = log2(exp+1)
#(2)提取临床信息
pd <- pData(eSet[[1]])
#(3)提取芯片平台编号
gpl <- eSet[[1]]@annotation
save(gse,exp,pd,gpl,file = "step1_output.Rdata")
