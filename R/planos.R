# =============================================================================
# Variâncias teóricas dos planos amostrais para o estimador do total
# Notação de Silva, Bianchini e Dias (2024). Todas as funções recebem o
# cadastro completo e calculam a variância verdadeira (populacional) do
# estimador, usando a proxy y como se fosse a variável de pesquisa.
# =============================================================================

# Variância populacional com divisor N - 1 (S^2 do livro)
s2 <- function(x) if (length(x) > 1) var(x) else 0


# -----------------------------------------------------------------------------
# AAS sem reposição
#   V(Y_hat) = N^2 (1 - n/N) S_y^2 / n
# -----------------------------------------------------------------------------
var_aas <- function(y, n) {
  N <- length(y)
  N^2 * (1 - n / N) * s2(y) / n
}


# -----------------------------------------------------------------------------
# AES: alocação e variância
#   V(Y_hat) = sum_h N_h^2 (1 - n_h/N_h) S_h^2 / n_h
# -----------------------------------------------------------------------------

# Arredonda um vetor real para inteiros que somam `total` (maiores restos)
arredondar_soma <- function(x, total) {
  base <- floor(x)
  falta <- total - sum(base)
  if (falta > 0) {
    ordem <- order(x - base, decreasing = TRUE)
    base[ordem[seq_len(falta)]] <- base[ordem[seq_len(falta)]] + 1
  }
  base
}

# Alocação com piso de min(N_h, 2) unidades por estrato (necessário para que
# todos os estratos sejam cobertos e a variância seja estimável) e censo
# (take-all) iterativo quando a alocação ótima ultrapassa N_h.
#   metodo = "proporcional": n_h ∝ N_h
#   metodo = "neyman":       n_h ∝ N_h S_h
alocar <- function(Nh, Sh, n, metodo = c("neyman", "proporcional")) {
  metodo <- match.arg(metodo)
  piso <- pmin(Nh, 2)
  nh <- piso
  livre <- rep(TRUE, length(Nh))
  repeat {
    peso <- if (metodo == "neyman") Nh * Sh else Nh
    restante <- n - sum(nh[!livre]) - sum(piso[livre])
    w <- ifelse(livre, peso, 0)
    if (sum(w) == 0) break
    alvo <- piso + ifelse(livre, restante * w / sum(w), 0)
    alvo[!livre] <- Nh[!livre]
    estoura <- livre & alvo > Nh
    if (!any(estoura)) { nh <- alvo; break }
    livre[estoura] <- FALSE
    nh[estoura] <- Nh[estoura]
  }
  # arredondamento preservando a soma e os limites [piso, N_h]
  nh_int <- arredondar_soma(nh, n)
  pmin(pmax(nh_int, piso), Nh)
}

aes_plano <- function(y, estrato, n, metodo = "neyman") {
  tab <- data.frame(y = y, h = estrato) |>
    dplyr::group_by(h) |>
    dplyr::summarise(Nh = dplyr::n(), Yh = sum(y), Sh2 = s2(y), .groups = "drop")
  tab$nh <- alocar(tab$Nh, sqrt(tab$Sh2), n, metodo)
  tab$vh <- with(tab, ifelse(nh >= Nh, 0, Nh^2 * (1 - nh / Nh) * Sh2 / nh))
  list(estratos = tab, variancia = sum(tab$vh), n = sum(tab$nh),
       n_censo = sum(tab$nh >= tab$Nh), y_censo = sum(tab$Yh[tab$nh >= tab$Nh]))
}

# Decomposição da variância: proporção da soma de quadrados entre estratos
r2_entre <- function(y, grupo) {
  medias <- ave(y, grupo)
  sum((medias - mean(y))^2) / sum((y - mean(y))^2)
}


# -----------------------------------------------------------------------------
# Conglomerados em um estágio (AC1S): AAS de m UPAs, censo dentro delas
#   Y_hat = (M/m) sum_{i in s} Y_i
#   V(Y_hat) = M^2 (1 - m/M) S_{Y}^2 / m,  S_Y^2 = variância dos totais das UPAs
# -----------------------------------------------------------------------------
ac1s <- function(y, upa, n) {
  totais <- tapply(y, upa, sum)
  tamanhos <- tapply(y, upa, length)
  M <- length(totais)
  N <- length(y)
  Mbar <- N / M
  m <- round(n / Mbar)
  list(M = M, Mbar = Mbar, m = m, n_esperado = m * Mbar,
       min_Mi = min(tamanhos), max_Mi = max(tamanhos),
       S2_totais = s2(totais),
       variancia = M^2 * (1 - m / M) * s2(totais) / m)
}


# -----------------------------------------------------------------------------
# PPT com reposição, estimador de Hansen-Hurwitz
#   p_i = x_i / X,   Y_hat = (1/n) sum_{k=1}^{n} y_k / p_k
#   V(Y_hat) = (1/n) sum_{i=1}^{N} p_i (y_i / p_i - Y)^2
# -----------------------------------------------------------------------------
ppt_hh <- function(y, x, n) {
  p <- x / sum(x)
  Y <- sum(y)
  razao <- y / x
  list(variancia = sum(p * (y / p - Y)^2) / n,
       cor_yx = cor(y, x),
       cv_razao = sd(razao) / mean(razao),
       razao = razao)
}
