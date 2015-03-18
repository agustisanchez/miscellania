library(scales)
library(ggplot2)

summariesFile<-"Summaries.txt"

#       xlim=c(as.POSIXct("2015/01/13 08:00:00"),as.POSIXct("2015/01/20 08:00:00")), 
#       xlim=c(min(subset$time),max(subset$time)), 

##
## CARREGA RECURSIVAMENT ELS ARXIUS DE DADES DEL DIRECTORI ESPECIFICAT
## -- Converteix les dates
## -- Retorna un dataset.
load.data<-function(dir="."){
    metrics<-data.frame()
    for (file in list.files(dir, recursive=TRUE)){
        print(c("Loading file:", file))
        metrics<-rbind(metrics, read.table(paste(dir,file, sep="/")))
    }
    names(metrics)<- c("time","node","group","metric", "index", "value")
    metrics$time <- strptime(metrics$time, "%Y/%m/%d-%H:%M:%S")
    print("Saving metrics image...")
    save(metrics, file="metrics")
    print("Saved")
    return (metrics)
}

##
## GENERA ELS RESULTATS
## -- Imatges binàries de datasets
## -- Gràfiques
## -- Sumaris d'estadístiques
create.subsets<-function(metrics, ram = 22, swap = 7){
    ram<<-ram   ## To global variable
    swap<<-swap ## To global variable
    java.memory<-c("Usage.used", "Usage.committed", "HeapMemoryUsage.used","HeapMemoryUsage.committed")
    so.metrics<-c("SystemCpuLoad","ProcessCpuLoad")
    titles<-c("PermGen Used by Tomcat Instance","PermGen Committed by Tomcat Instance",
        "Heap Used by Tomcat Instance","Heap Committed by Tomcat Instance",
        "System CPU Load by Server","Process CPU Load by Server")
    names(titles)<-c("Usage.used", "Usage.committed", "HeapMemoryUsage.used",
        "HeapMemoryUsage.committed",
        "SystemCpuLoad","ProcessCpuLoad")

    remove.summary()

    # Per JVM statistics
    for( name in java.memory){
        subset<-extract.subset(metrics, name, to.MB)
        save(subset, file=name)
        print.summary(dataset.toGB(subset), titles[name])
        plot.to.file(paste(name,"png",sep="."), plot.mem, subset, titles[name])
    }

    permgen.committed<-extract.subset(metrics, java.memory[2], to.MB)
    heap.committed<-extract.subset(metrics, java.memory[4], to.MB)
    total.committed<-data.frame(heap.committed)
    total.committed$value <- heap.committed$value + permgen.committed$value
    plot.to.file("Total.Java.png", plot.mem, total.committed, "Total memory Committed by Tomcat Instance")
    print.summary(dataset.toGB(total.committed), "Total memory Committed by Tomcat Instance")
    rm(permgen.committed)
    rm(heap.committed)
    rm(total.committed)

    # Per virtual server statistics
    for( name in so.metrics){
        subset<-extract.subset(metrics, name)
        subset.pro1<-extract.nodeSet(subset, "pro1")
        subset.pro4<-extract.nodeSet(subset, "pro4")
        aggregated<-rbind(subset.pro1, subset.pro4)
        print.summary(aggregated, titles[name])
        rm(subset.pro1)
        rm(subset.pro4)
        plot.to.file(paste(name,"png",sep="."), plot.data.set, aggregated, titles[name])
    }

    free.ram<-extract.somem.subset(metrics,"FreePhysicalMemorySize")
    save(free.ram, file="free.ram")
    title="Free Physical Memory by Server"
    print.summary(dataset.toGB(free.ram), title)
    plot.to.file( "FreePhysicalMemorySize.png", plot.mem, free.ram, title)

    free.swap<-extract.somem.subset(metrics,"FreeSwapSpaceSize")
    save(free.swap, file="free.swap")
    title="Free Swap Space by Server"
    print.summary(dataset.toGB(free.swap), title)
    plot.to.file("FreeSwapSpaceSize.png", plot.mem, free.swap, title)

    total.used=data.frame(free.ram)
    free.ram$value<-(ram*1024)-free.ram$value
    free.swap$value<-(swap*1024)-free.swap$value
    total.used$value<-free.swap$value + free.ram$value
    save(total.used, file = "total.used")
    print.summary(dataset.toGB(total.used), "TOTAL USED")
    plot.to.file("Total.Used.png", plot.total.used, total.used)
    rm(free.ram)
    rm(free.swap)
    rm(total.used)
}

extract.somem.subset<-function(metrics, name){
# Tractament comú memòria sistema operatiu
    #
    # Args:
    #   metrics: Dataset principal
    #   name: Nom de la mètrica a extreure.
    # Returns:
    #   El subset extret.    
    subset<-extract.subset(metrics, name, to.MB)
    subset.pro1<-extract.nodeSet(subset, "pro1")
    subset.pro4<-extract.nodeSet(subset, "pro4")
    aggregated<-rbind(subset.pro1, subset.pro4)
    rm(subset.pro1)
    rm(subset.pro4)
    return (aggregated)
}

extract.subset<-function(metrics, colName, yfactor=NULL){
# Extreu la mètrica especificada (columnes #1, #2, #6), 
# opcionalment aplicant un factor de conversió a la columna del valor.
    #
    # Args:
    #   metrics: Dataset principal
    #   name: Nom de la mètrica a extreure.
    #   yfactor: funció obté el valor originan com a argument 
    #            i retorna el valor convertit.
    # Returns:
    #   El subset extret.    
    sub.metrics<-metrics[metrics$metric == colName,c(1,2,6)]
    if (!is.null(yfactor)){
        sub.metrics$value<-yfactor(sub.metrics$value)
    }
    return (sub.metrics)
}

extract.nodeSet<-function(subset, node){
# Extreu el dataset del node especificat.
    #
    # Args:
    #   subset: Dataset origen
    #   node: Nom del node a extreure
    # Returns:
    #   El subset extret.    
    nodeSet<-subset[subset$node==node,]
    return (nodeSet)
}

to.MB<-function(n){
# Converteix de B a MB.
    #
    # Args:
    #   n: valor en bits
    # Returns:
    #   Valor en MB.    
    return (n/(1024*1024))
}

dataset.toGB<-function(data){
# Converteix de MB a GB.
    #
    # Args:
    #   n: valor en MB
    # Returns:
    #   Valor en GB.    
    data$value<-data$value/1024
    return (data)
}

plot.to.file<-function(file, plot.fun, ...){
# Dibuixa el gràfic directament en arxiu (1000x800).
# L'extensió del nom de l'arxiu determina el format del gràfic (PNG, JPG, ...)
    #
    # Args:
    #   file: Ruta de l'arxiu.
    #   plot.fun: Funció de generació del gràfic
    #   ...: Arguments a passar a la funció anterior.
    png(file, height=800, width=1000)
    print(plot.fun(...))
    dev.off()
}

plot.data.set<-function(dataset, title, ylab="value"){
# Genera un gràfic per dia amb el títol especificat i l'etiqueta per a l'eix de les Y.
    #
    # Args:
    #   dataset: Dataset a representar
    #   title: Títol del gràfic
    #   ylab: Títol de les Y.
    ggplot(dataset, aes(x=time, y=value, group=node, color=node)) + 
    theme_bw() +
    ggtitle(title) + 
    geom_line(size=1) + 
    ylab(ylab) +
    xlab("Day") +
    scale_x_datetime(breaks=date_breaks("days"), labels = date_format("%d/%m"))
}

plot.mem<-function(dataset, title){
# Genera un gràfic per dia per a un dataset de memòria RAM amb el títol especificat.
    #
    # Args:
    #   dataset: Dataset a representar
    #   title: Títol del gràfic
    ggplot(dataset, aes(x=time, y=value, group=node, color=node)) + 
    theme_bw() +
    geom_line(size=1) +
    ylab("Memory (MB)") + 
    xlab("Day") +
    ggtitle(title) +
    # ylim(c(0, max(dataset$value))) + 
    scale_x_datetime(breaks=date_breaks("days"), labels = date_format("%d/%m"))
}

plot.mem.day<-function(dataset, title){
# Genera un gràfic per hora per a un dataset de memòria RAM amb el títol especificat.
    #
    # Args:
    #   dataset: Dataset a representar
    #   title: Títol del gràfic
    ggplot(dataset, aes(x=time, y=value, group=node, color=node)) + 
    theme_bw() +
    geom_line(size=1) +
    ylab("Memory (MB)") + 
    xlab("Hour") +
    ggtitle(title) +
    ylim(c(0, max(dataset$value))) +
    scale_x_datetime(breaks=date_breaks("hours"), labels = date_format("%H"))
}


plot.total.used<-function(dataset){
# Genera un grafic de la memoria total de sistema operatiu consumida.
    #
    # Args:
    #   dataset: Dataset a representar
    ggplot(dataset, aes(x=time, y=value, group=node, color=node)) + 
    theme_bw() +
    geom_line(size=1) +
    ylab("Memory (MB)") + 
    xlab("Day") +
    ggtitle("Total Memory Used (RAM + SWAP)") +
    geom_hline(aes(yintercept=(ram*1024), color="MAX RAM"), linetype="dashed", size=1)  +
    #geom_hline(aes(yintercept=(ram + swap)*1024, color="MAX RAM + SWAP"), linetype="dashed", size=1) +
    scale_color_manual(values=c("orange", "red", "steelblue3", "springgreen3")) +
    scale_x_datetime(breaks=date_breaks("days"), labels = date_format("%d/%m"))
}

remove.summary<-function(){
    if (file.exists(summariesFile)) 
    file.remove(summariesFile)
}

print.summary<-function(subset, title){
# Imprimeix sumari d'estadístiques per al dataset especificat
    #
    # Args:
    #   dataset: Dataset a analitzar
    #   title: Títol del sumari
    sink(summariesFile, append=TRUE)
    cat("\n===========\n")
    cat(title)
    cat("\n===========\n")
    print(summary(subset$value))
    sink()

}

test.benchmark<-function(fun, ...){
    begin.time<-Sys.time()
    fun(...)
    return (Sys.time() - begin.time)
}

test.concat<-function(dir){
    big.file="BigFile.txt"
    for (file in list.files(dir, recursive=TRUE)){
        print(c("Loading file:", file))
        data<-readLines(paste(dir,file, sep="/"))
        cat(data, file=big.file, append=TRUE)
    }
    print("END")

}

manual.extract.day<-function(dataset, day){
    t0<-strptime(paste(day,"00:00:00", sep="-"), "%Y/%m/%d-%H:%M:%S")
    t1<-strptime(paste(day,"00:00:00", sep="-"), "%Y/%m/%d-%H:%M:%S")
    t1$hour <- t1$hour + 24
    return (dataset[(dataset$time >  t0 & dataset$time <  t1 ),])
}

manual.plotHourHeap<-function(dataset){
    ggplot(dataset, aes(x=time, y=value))+ 
    geom_line(size=1, color="blue") + 
    scale_x_datetime( breaks=date_breaks("10 min"), labels = date_format("%M")) + 
    ylab("Memòria (MB)") + 
    xlab("Minut") + 
    ggtitle("Perfil Heap 24/02/2015 10:00 - 11:00") +
    theme_bw() +
    ylim(c(0, max(dataset$value)))
}

manual.plotHourHeap2<-function(dataset, title = ""){
    ggplot(dataset, aes(x=time, y=value))+ 
    geom_line(size=1, color="blue") + 
    scale_x_datetime( breaks=date_breaks("10 min"), labels = date_format("%M")) + 
    ylab("Memòria (MB)") + 
    xlab("Minut") + 
    ggtitle(title) +
    theme_bw()
}

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
