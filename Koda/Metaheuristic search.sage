# potrebuje malo preimenovanja
import random
def oceni_graf(G, ciljna_dim, ciljni_ftdim):
    """
    Oceni, kako blizu je graf G želenim dimenzijam.
    - Kazen za odstopanje od ciljnih dimenzij.
    - Manjša ocena pomeni boljši graf.
    """
    dim = metricna_dimenzija(G)
    ftdim = na_napake_odporna_metricna_dimenzija(G)

    # Če graf ustreza ciljni dimenziji in ftdim, vrnemo zelo nizko oceno
    if dim == ciljna_dim and ftdim == ciljni_ftdim:
        return 0

    # Kazen za odstopanje od ciljev
    kazen_dim = abs(dim - ciljna_dim)
    kazen_ftdim = max(0, ciljni_ftdim - ftdim)  # Kazen samo, če je ftdim prenizka
    return kazen_dim * 10 + kazen_ftdim * 100

def tweak_graph(G):
    """
    Naključno prilagodi strukturo grafa G:
    - Doda ali odstrani naključni rob.
    """
    H = G.copy()
    vertices = G.vertices()
    if random.random() < 0.5:  # Dodajanje roba
        u, v = random.sample(vertices, 2)
        if not H.has_edge(u, v):
            H.add_edge(u, v)
    else:  # Odstranjevanje roba
        if len(H.edges()) > 0:
            H.delete_edge(random.choice(H.edges(labels=False)))
    return H

def simulirano_ohlajanje_grafov(ciljna_dim, ciljni_ftdim, st_vozlisc, max_iter=1000, zacetna_temp=100, alpha=0.95):
    """
    Simulirano ohlajanje za iskanje grafov z danimi lastnostmi.
    """
    # Začetni graf: naključni povezani graf
    G = graphs.RandomGNP(st_vozlisc, 0.5)
    najboljsi_graf = G
    najboljsa_ocena = oceni_graf(G, ciljna_dim, ciljni_ftdim)

    trenutni_graf = G
    trenutna_ocena = najboljsa_ocena
    temperatura = zacetna_temp

    for _ in range(max_iter):
        # Naključno prilagodimo trenutni graf
        nov_graf = tweak_graph(trenutni_graf)
        nova_ocena = oceni_graf(nov_graf, ciljna_dim, ciljni_ftdim)

        # Sprejmi novo rešitev z določeno verjetnostjo
        if nova_ocena < trenutna_ocena or random.random() < math.exp((trenutna_ocena - nova_ocena) / temperatura):
            trenutni_graf = nov_graf
            trenutna_ocena = nova_ocena

            # Posodobi najboljšo rešitev
            if nova_ocena < najboljsa_ocena:
                najboljsi_graf = nov_graf
                najboljsa_ocena = nova_ocena

        # Znižanje temperature
        temperatura = temperatura * alpha

        # Če smo našli ustrezen graf, prekinemo
        if najboljsa_ocena == 0:
            break

    return najboljsi_graf, najboljsa_ocena
