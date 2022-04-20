
#### library #####

library(purrr)
library(dplyr)
library(readxl)
library(tidyr)

#### Download arquivos ####


# montar urls

sufixos_1 <-
  c(
    "76facff4-7914-42e0-bad9-b671c9663385", #2010
    "b2afdfa0-7a7a-47fe-b9dc-1391835b8340", #2011
    "88a788ed-49a1-4622-adc7-43006c4873ed", #2012
    "b8b8c906-5d16-46cb-906c-4ce3f9c013de", #2013
    "c64a1b2d-7711-4209-911a-ff5bc9cc8256", #2014
    "143b413a-2ce4-4203-8058-c939d79ab48e", #2015
    "a6c41823-19a5-47c7-9281-f5d7e1aa3894", #2016
    "6d6847c3-fc1d-4eb4-855d-aa9030fcfd47", #2017
    "9664e7ed-6a43-4ccb-8cdd-922e9b8dd62c", #2018
    "65d4cdb9-02e9-4b7c-b59e-5122b2835055", #2019
    "b258f856-b80e-4cad-a4bb-dc570b7f5659"  #2020
    )

ano <- seq(2010, 2020)


url_bases <- paste0(
  "https://www.tesourotransparente.gov.br/ckan/dataset/22d13d17-bf69-4a1a-add2-25cc1e25f2d7/resource/",
  sufixos_1, "/download/Base-COFOG-", ano, "-TT.xlsx"
) %>%
  as.list() %>%
  set_names(ano)


# baixar arquivos em pasta temporaria

purrr::walk2(
  url_bases,
  url_bases %>% names(),
  ~ download.file(.x, 
                  destfile = paste0(tempdir(), 
                                    .y
                  ),
                  mode = "wb"
  )
)

# caminho pastas

path <- paste0(tempdir(), ano)

#### lendo sheets ####

importar_tabelas <- function(path){
  
  readxl::read_excel(path,
                     sheet     = "Despesa Competencia - COFOG",
                     col_names = TRUE)
  }


COFOG <- purrr::map(path, importar_tabelas) %>%
  purrr::set_names(ano)

### correcao base 2012 coluna 3 ###

# compatibilizar double com character

for(i in as.character(ano)){
  COFOG[[i]][["Natureza Despesa Detalhada"]] <- as.character(COFOG[[i]][["Natureza Despesa Detalhada"]])
  
}

COFOG <- COFOG %>% bind_rows()

