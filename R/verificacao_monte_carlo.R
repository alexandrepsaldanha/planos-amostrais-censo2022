# Verificação por Monte Carlo das variâncias teóricas do relatório.
# Sorteia R amostras de cada plano, calcula o estimador do total e compara a
# variância empírica com a teórica. Razões próximas de 1 confirmam as fórmulas.
# Execute a partir da raiz do repositório: Rscript R/verificacao_monte_carlo.R

source("R/planos.R")
set.seed(42)
d <- read.csv("data/Cadastro_Municipios_2026.csv", encoding = "UTF-8")
n <- 800; y <- d$domicilios * d$pct_urbana; N <- length(y); R <- 20000
# AAS
est <- replicate(R, N * mean(sample(y, n))); cat(sprintf("AAS   teor %.4e  MC %.4e  razao %.3f\n", var_aas(y,n), var(est), var(est)/var_aas(y,n)))
# AES Neyman e proporcional
for (m in c("neyman","proporcional")) { a <- aes_plano(y, d$estrato_uf_porte, n, m); g <- split(y, d$estrato_uf_porte)
  nh <- setNames(a$estratos$nh, a$estratos$h)
  est <- replicate(R/4, sum(sapply(names(g), function(h) { v <- g[[h]]; k <- nh[[h]]; if (k >= length(v)) sum(v) else length(v) * mean(v[sample.int(length(v), k)]) })))
  cat(sprintf("AES %-5s teor %.4e  MC %.4e  razao %.3f  n=%d\n", substr(m,1,5), a$variancia, var(est), var(est)/a$variancia, sum(nh))) }
# AC1S
tot <- tapply(y, d$regiao_imediata, sum); c1 <- ac1s(y, d$regiao_imediata, n)
est <- replicate(R, c1$M / c1$m * sum(sample(tot, c1$m))); cat(sprintf("AC1S  teor %.4e  MC %.4e  razao %.3f\n", c1$variancia, var(est), var(est)/c1$variancia))
# PPT HH
p <- d$domicilios / sum(d$domicilios); pp <- ppt_hh(y, d$domicilios, n)
est <- replicate(R, { k <- sample.int(N, n, replace = TRUE, prob = p); mean(y[k] / p[k]) }); cat(sprintf("PPT   teor %.4e  MC %.4e  razao %.3f  vies rel %.2e\n", pp$variancia, var(est), var(est)/pp$variancia, mean(est)/sum(y)-1))
