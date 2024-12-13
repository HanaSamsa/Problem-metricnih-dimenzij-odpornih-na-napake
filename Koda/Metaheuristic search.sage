from sage.all import *
import random
import matplotlib.pyplot as plt

# na novo definiramo funkciji za izračun dim in ftdim, saj po prejšnjih definicijah naletimo na težave

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

# definiramo funkcijo tweak, ki grafu naključno odstrani ali doda povezavo;
# funkcijo bomo uporabili pri simuliranem hlajenju, da bomo namesto generiranja vseh
# možnih grafov preverjali, ali je preurejen graf bližje dovolj dobri rešitvi glede
# na naše določene kriterije.

def tweak_graf(G): 
    povezave = list(G.edges(labels=False))
    if random.random() < 0.5 and povezave:
        # izbrišemo naključno povezavo
        G.delete_edge(random.choice(povezave))
    else:
        # dodamo naključno povezavo
        u, v = random.sample(range(G.num_verts()), 2)
        if not G.has_edge(u, v):
            G.add_edge(u, v)


def simulirano_hlajenje(ciljna_dim, ciljna_ftdim, st_vozlisc, iteracije=1000, temperatura=100, ohlajanje=0.95):
    # definiramo začetni gaf
    trenuten_graf = graphs.CompleteGraph(st_vozlisc)
    
    trenutna_dim = metricna_dimenzija(trenuten_graf)
    trenuten_ftdim = na_napake_odporna_metricna_dimenzija(trenuten_graf)
    naj_graf = trenuten_graf
    naj_dim = trenutna_dim
    naj_ftdim = trenuten_ftdim

    temp = temperatura

    for iteracija in range(iteracije):
        if temp <= 0:
            break

        # naredimo kopijo in spremenimo graf s tweak funkcijo
        nov_graf = trenuten_graf.copy()
        tweak_graf(nov_graf)

        nov_dim = metricna_dimenzija(nov_graf)
        nov_ftdim = na_napake_odporna_metricna_dimenzija(nov_graf)

        # preverimo, če zdaj ta graf ustreza kriterijem
        delta = abs(nov_dim - ciljna_dim) + abs(nov_ftdim - ciljna_ftdim) - abs(trenutna_dim - ciljna_dim) - abs(trenuten_ftdim - ciljna_ftdim)
        if delta < 0 or random.random() < exp(-delta / temp):
            trenuten_graf = nov_graf
            trenutna_dim = nov_dim
            trenuten_ftdim = nov_ftdim

            # če ustreza kriterijem, potem posodobio naš najboljši graf
            if abs(nov_dim - ciljna_dim) + abs(nov_ftdim - ciljna_ftdim) < abs(best_dim - ciljna_dim) + abs(best_ftdim - ciljna_ftdim):
                naj_graf = nov_graf
                naj_dim = nov_dim
                naj_ftdim = nov_ftdim
        temp *= ohlajanje

    naj_graf.show()
    return naj_graf.show(), naj_dim, naj_ftdim