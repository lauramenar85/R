library("readxl")

#' Carga un excel file desde una URL y lo salva localmente
#'
#'\code{loadXlsFileFromUrl}
#'
#' @export
#' @name loadXlsFileFromUrl
#' @author Patricio Moracho pmorcho@gmail.com
#' @param url enlace al archivo csv.
#' @param path carpeta dónde se salvará el archivo descargado o dónde será leído
#' @param force.download Forzar la descarga del archivo
#' @return un data.frame
#' @examples
#' loadCsvFileFromUrl(url = "http://datos.jus.gob.ar/dataset/27bb9b2c-521b-406c-bdf9-98110ef73f34/resource/9a06c428-8552-42fe-86e1-487bca9b712c/download/registro-de-femicidios.csv")

loadXlsFileFromUrl <- function(url, path, filename='', encoding='latin1', separator=',', force.download=FALSE) {
    
    tmp.path <- tempdir()
    
    if (filename == '') {
        fileext = basename(url)
    } else {
        fileext = filename
    }
    
    file <- tools::file_path_sans_ext(fileext)
    data.file <- file.path(path,fileext)
    
    if (!file.exists(data.file) || force.download) {
        file <- file.path(data.path,fileext)
        download.file(url, data.file)
        
        df <- read.table(file = file, header = TRUE, sep=separator, encoding=encoding)
        write(x = df, file = file.path(paste(data.file, '.Rda')))
    } else {
        df <- load(file = file.path(data.file, 'Rda'))
    }
    return(df)
}

