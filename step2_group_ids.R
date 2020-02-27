rm(list = ls())
load("step1_output.Rdata")
p = identical(rownames(pd),colnames(exp));p
if(!p) exp = exp[,match(rownames(pd),colnames(exp))]

group_list = ifelse(str_detect(pd$title,"Pre"),"pre","post")
group_list=factor(group_list,levels = c("pre","post"),ordered = T)
pairinfo = factor(c(1,2,1,3,2,3))

#2.ids 芯片注释----
gpl

if(F){
  #http://www.bio-info-trainee.com/1399.html
  #hgu133plus2
  if(!require(hgu133plus2.db))BiocManager::install("hgu133plus2.db")
  library(hgu133plus2.db)
  ls("package:hgu133plus2.db")
  ids <- toTable(hgu133plus2SYMBOL)
  head(ids)
}else if(F){
  getGEO(gpl)
  ids = data.table::fread(paste0(gpl,".soft"),header = T,skip = "ID",data.table = F)
  ids = ids[c("ID","Gene Symbol"),]
  colnames(ids) = c("probe_id")
}else if(T){
  ids = idmap(gpl,type = "bioc")
}
save(group_list,pairinfo,ids,file = "step2_output.Rdata")
