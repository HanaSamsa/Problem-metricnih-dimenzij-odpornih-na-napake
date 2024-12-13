def hill_climbing(ciljna_dim, ciljna_ftdim, st_vozlisc, max_iteracij=1000):
    # generiramo prvotni graf
    trenutni_graf = graphs.CompleteGraph(st_vozlisc)
    trenutna_dim = metricna_dimenzija(trenutni_graf)
    trenutna_ftdim = na_napake_odporna_metricna_dimenzija(trenutni_graf)

    if trenutna_dim == ciljna_dim and trenutna_ftdim == ciljna_ftdim:
        return trenutni_graf.show(), trenutna_dim, trenutna_ftdim

    for iteracija in range(max_iteracij):
        # naredimo kopijo in prilagodimo graf
        nov_graf = trenutni_graf.copy()
        tweak_graph(nov_graf)

        # ocenimo nov graf
        nova_dim = metricna_dimenzija(nov_graf)
        nova_ftdim = na_napake_odporna_metricna_dimenzija(nov_graf)

        # če je boljši, ga sprejmemo
        if nova_dim == ciljna_dim and nova_ftdim == ciljna_ftdim:
            return nov_graf, nova_dim, nova_ftdim
        elif abs(nova_dim - ciljna_dim) + abs(nova_ftdim - ciljna_ftdim) < abs(trenutna_dim - ciljna_dim) + abs(trenutna_ftdim - ciljna_ftdim):
            trenutni_graf = nov_graf
            trenutna_dim = nova_dim
            trenutna_ftdim = nova_ftdim

    return trenutni_graf.show(), trenutna_dim, trenutna_ftdim
