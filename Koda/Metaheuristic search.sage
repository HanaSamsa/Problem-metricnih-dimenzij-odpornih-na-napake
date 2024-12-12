from sage.all import *
import random
import matplotlib.pyplot as plt

# funkcija Tweak za prilagajanje grafa: naključno prilagodimo graf z dodajanjem/odstranjevanjem vozlišča

def tweak_graph(G): 
    
    robovi = list(G.edges(labels = False))
    if random.random() < 0.5 and robovi:
        # odstranimo naključno vozlišče
        G.delete_edge(random.choice(robovi))
    else:
        # dodamo naključno vozlišče
        u, v = random.sample(range(G.num_verts()), 2)
        if not G.has_edge(u, v):
            G.add_edge(u, v)


# Hill-Climbing metahevristika

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


# Simulated Annealing metahevristika

def simulated_annealing(ciljna_dim, ciljna_ftdim, st_vozlisc, max_iteracij = 1000, zacetna_temp = 100, alpha =0.95):

    # generiramo začetni graf
    trenutni_graf = graphs.CompleteGraph(st_vozlisc)
    trenutna_dim = metricna_dimenzija(trenutni_graf)
    trenutna_ftdim = na_napake_odporna_metricna_dimenzija(trenutni_graf)
    naj_graf = trenutni_graf
    naj_dim = trenutna_dim
    naj_ftdim = trenutna_ftdim

    temp = zacetna_temp

    for iteracija in range(max_iteracij):
        if temp <= 0:
            break

        # naredimo kopijo in prilagodimo graf
        nov_graf = trenutni_graf.copy()
        tweak_graph(nov_graf)

        # ocenimo nov graf
        nova_dim = metricna_dimenzija(nov_graf)
        nova_ftdim = na_napake_odporna_metricna_dimenzija(nov_graf)

        # kriterij, po katerem graf sprejmemo
        spr = abs(nova_dim - ciljna_dim) + abs(nova_ftdim - ciljna_ftdim) - abs(trenutna_dim - ciljna_dim) - abs(trenutna_ftdim - ciljna_ftdim)
        if spr < 0 or random.random() < exp(-spr / temp):
            trenutni_graf = nov_graf
            trenutna_dim = nova_dim
            trenutna_ftdim = nova_ftdim

            # posodobimo najboljšo rešitev
            if abs(nova_dim - ciljna_dim) + abs(nova_ftdim - ciljna_ftdim) < abs(naj_dim - ciljna_dim) + abs(naj_ftdim - ciljna_ftdim):
                naj_graf = nov_graf
                naj_dim = nova_dim
                naj_ftdim = nova_ftdim

        # hlajenje
        temp *= alpha

    return naj_graf.show(), naj_dim, naj_ftdim


dim = 2
ftdim = 9
st_vozlisc = 15

# poženemo hill climbing
hc_graf, hc_dim, hc_ftdim = hill_climbing(dim, ftdim, st_vozlisc)
print("Rezultati Hill-Climbing-a:", hc_graf, hc_dim, hc_ftdim)

