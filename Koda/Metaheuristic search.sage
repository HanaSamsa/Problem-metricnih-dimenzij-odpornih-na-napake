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


def simulated_annealing(ciljna_dim, ciljna_ftdim, st_vozlisc, iteracije=1000, temperatura=100, ohlajanje=0.95):
    # Definiramo začetni graf
    trenuten_graf = graphs.CompleteGraph(st_vozlisc)
    
    trenutna_dim = metricna_dimenzija(trenuten_graf)
    trenuten_ftdim = na_napake_odporna_metricna_dimenzija(trenuten_graf)
    best_graf = trenuten_graf
    best_dim = trenutna_dim
    best_ftdim = trenuten_ftdim

    temp = temperatura

    for iteration in range(iteracije):
        if temp <= 0:
            break

        # Naredimo kopijo in spremenimo graf s tweak funkcijo
        nov_graf = trenuten_graf.copy()
        tweak_graf(nov_graf)

        nov_dim = metricna_dimenzija(nov_graf)
        nov_ftdim = na_napake_odporna_metricna_dimenzija(nov_graf)

        # Preverimo če dosega kriterije
        delta = abs(nov_dim - ciljna_dim) + abs(nov_ftdim - ciljna_ftdim) - abs(trenutna_dim - ciljna_dim) - abs(trenuten_ftdim - ciljna_ftdim)
        if delta < 0 or random.random() < exp(-delta / temp):
            trenuten_graf = nov_graf
            trenutna_dim = nov_dim
            trenuten_ftdim = nov_ftdim

            # Če dosega kriterije posodobimo graf
            if abs(nov_dim - ciljna_dim) + abs(nov_ftdim - ciljna_ftdim) < abs(best_dim - ciljna_dim) + abs(best_ftdim - ciljna_ftdim):
                best_graf = nov_graf
                best_dim = nov_dim
                best_ftdim = nov_ftdim
        temp *= ohlajanje

    best_graf.show()
    return best_graf, best_dim, best_ftdim
