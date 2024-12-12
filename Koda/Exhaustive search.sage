from sage.all import *
import matplotlib.pyplot as plt

G = graphs.CompleteGraph(5)

# DEFINIRAMO FUNKCIJO, KI IZRAČUNA ftdim(G)

def na_napake_odporna_metricna_dimenzija(G):

    n = G.num_verts() # izračunam število vozlišč grafa G
    razdalje = G.distance_all_pairs() # matrika razdalj med vsakim parom vozlišč iz G


    # inicializacija CLP:

    p = MixedIntegerLinearProgram(maximization = False) # minimizacija
    x = p.new_variable(binary = True) # ustvarjanje binarne spremenljivke za uporabo znotraj CLP p


    # definicija koeficientne matrike A:

    A = {} # oblika slovarja omogoča boljšo shrambo in dostop do našega tipa vrednosti
    for u in range(n):
        for v in range(u + 1, n):
            for i in range(n):
                A[(u, v), i] = 1 if razdalje[u][i] != razdalje[v][i] else 0


    # ciljna funkcija:

    p.set_objective(sum(x[i] for i in range(n)))


    # pogoj: vsak par (u, v) ima vsaj dve razločujoči vozlišči v S:

    for u in range(n):
        for v in range(u + 1, n):
            p.add_constraint(sum(A[(u, v), i] * x[i] for i in range(n)) >= 2)


    # reševanje CLP:

    p.solve()
    na_napake_odporna_razlocujoca_mnozica = [i for i in range(n) if round(p.get_values(x[i])) == 1]


    # vrnemo kardinalnost = moč razločujoče množice:

    return len(na_napake_odporna_razlocujoca_mnozica)


# DEFINIRAMO ŠE FUNKCIJO, KI IZRAČUNA METRIČNO DIMENZIJO GRAFA dim(G):
# (baje lahko v praksi uporabljaš aproksimacijo dim(G) = ftdim(G) - 1 ?)

def metricna_dimenzija(G):

    n = G.num_verts()
    razdalje = G.distance_all_pairs()

    p = MixedIntegerLinearProgram(maximization = False)
    x = p.new_variable(binary = True)

    A = {}
    for u in range(n):
        for v in range(u + 1, n):
            for i in range(n):
                A[(u, v), i] = 1 if razdalje[u][i] != razdalje[v][i] else 0

    p.set_objective(sum(x[i] for i in range(n)))

    for u in range(n):
        for v in range(u + 1, n):
            p.add_constraint(sum(A[(u, v), i] * x[i] for i in range(n)) >= 1)

    p.solve()
    razlocujoca_mnozica = [i for i in range(n) if round(p.get_values(x[i])) == 1]

    return len(razlocujoca_mnozica)


# DEFINIRAMO FUNKCIJO, KI POIŠČE USTREZNE GRAFE:

def poisci_grafe(ciljna_dim, ciljna_ftdim, st_vozlisc): # najmanjše možno število vozlišč za ftdim = 5 je 7, pod tem sploh ne preverjamo

    grafi = [] # dodajali bomo ustrezne grafe

    for G in graphs.nauty_geng(f'{st_vozlisc} -c'): # samo povezani grafi
        dim = metricna_dimenzija(G)
        ftdim = na_napake_odporna_metricna_dimenzija(G)
        
        if dim == ciljna_dim and ftdim == ciljna_ftdim:
            sosedi = {v: list(G[v]) for v in G} # sosede potrebujemo za risanje grafov
            grafi.append((G, st_vozlisc, dim, ftdim, sosedi))
            plt.figure(figsize = (6, 6))
            plot(G).show()  # izrišem grafe
            plt.close()
    
    return len(grafi) # vrnemo število ustreznih grafov


# Preverjamo ustrezne grafe na 7 vozliščih             
# poisci_grafe(2, 5, 7) # 7.24s, dobimo 2 grafa

# Preverjamo ustrezne grafe na 8 vozliščih
# poisci_grafe(2, 5, 8) # 2min44s, 65 grafov

# Preverjamo ustrezne grafe na 9 vozliščih
# poisci_grafe(2, 5, 9) # po 30 minutah se koda preneha izvajati

# ugotovimo torej, da se že za ftdim = 5 in 9 vozlišč koda ne izvede v nekem sprejemljivem času --> uberemo drug pristop

# Prej preverimo še za ftdim = 6:
# poisci_grafe(2, 6, 12) # tudi tukaj se koda izvaja več kot pol ure

# Tako bo torej za vse višje ftdim, ker rabimo tudi vedno večje število vozlišč grafa
