% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dados-abertos.R
\name{dados-abertos}
\alias{dados-abertos}
\alias{datajud_fato}
\alias{datajud_assuntos}
\alias{datajud_classes}
\title{Baixa as tabelas de dados abertos do Datajud}
\usage{
datajud_fato(path, unzip = TRUE)

datajud_assuntos(path, unzip = TRUE)

datajud_classes(path, unzip = TRUE)
}
\arguments{
\item{path}{caminho para salvar arquivo zip ou csv}

\item{unzip}{dezipar arquivo? Por padrão, sim}
}
\value{
caminho do arquivo csv ou zip baixado
}
\description{
Baixa tabela fato, tabela de assuntos ou tabela de classes.
}
\details{
Infelizmente, essas bases ainda não são de dados abertos. O nível de análise
ainda é o de órgão julgador. Mas já é uma base bastante útil para fazer
estatísticas.
}
