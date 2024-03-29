% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/post_easysorter.R
\name{runPCA}
\alias{runPCA}
\title{Perform principal component analysis on traits}
\usage{
runPCA(df)
}
\arguments{
\item{df}{A regressed dataframe of HTA traits for PCA}
}
\value{
pca_obj, a PCA object output from princomp; 
loadings, a vector of loadings for each HTA trait into each PC;
cumsums, a matrix of cumulative sums of variance explained by each PC;
RIAILPCphenos, a dataframe of PC values for each strain;
corr_PC_trait, correlation of each trait to each PC
}
\description{
Perform principal component analysis on traits
}
