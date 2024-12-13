from sage.all import *
import random
import matplotlib.pyplot as plt

def metricna_dimenzija(G):
    n = G.num_verts()
    razdalje = G.distance_all_pairs()

    p = MixedIntegerLinearProgram(maximization = False)
    x = p.new_variable(binary = True)
    p.set_objective(sum(x[i] for i in G))
    for u, v in Combinations(G, 2):
        p.add_constraint(sum(x[i] for i in G if razdalje[u].get(i, n) != razdalje[v].get(i, n)) >= 1)

    p.solve()
    razlocujoca_mnozica = [i for i in G if round(p.get_values(x[i])) == 1]

    return len(razlocujoca_mnozica)


def na_napake_odporna_metricna_dimenzija(G):
    n = G.num_verts() # izračunam število vozlišč grafa G
    razdalje = G.distance_all_pairs() # matrika razdalj med vsakim parom vozlišč iz G

    # inicializacija CLP:
    p = MixedIntegerLinearProgram(maximization = False) # minimizacija
    x = p.new_variable(binary = True) # ustvarjanje binarne spremenljivke za uporabo znotraj CLP p
    p.set_objective(sum(x[i] for i in G))
    # pogoj: vsak par (u, v) ima vsaj dve razločujoči vozlišči v S:
    for u, v in Combinations(G, 2):
        p.add_constraint(sum(x[i] for i in G if razdalje[u].get(i, n) != razdalje[v].get(i, n)) >= 2)

    # reševanje CLP:
    p.solve()
    na_napake_odporna_razlocujoca_mnozica = [i for i in G if round(p.get_values(x[i])) == 1]

    # vrnemo kardinalnost = moč razločujoče množice:
    return len(na_napake_odporna_razlocujoca_mnozica)


def tweak_graf(G):
    povezave = list(G.edges(labels=False))
    if random.random() < 0.5 and povezave:
        # Izbrišemo naključno povezavo
        G.delete_edge(random.choice(povezave))
    else:
        # Dodao naključno povezavo
        u, v = random.sample(range(G.num_verts()), 2)
        if not G.has_edge(u, v):
            G.add_edge(u, v)


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
