# Composants UI réutilisables

## 1. CarteMeteo
→ Utilisé dans : Accueil, Favoris
→ Contient : Icône, température, condition, indicateurs
→ États : chargement, données, erreur

## 2. BanniereAlerte
→ Utilisé dans : Accueil, Alertes
→ Contient : Niveau (couleur), nom cyclone, régions
→ Variantes : rouge, orange, jaune, verte

## 3. LignePrevision
→ Utilisé dans : Accueil (détail)
→ Contient : Jour, icône, temp min/max
→ Hauteur fixe : 48px

## 4. CarteMarine
→ Utilisé dans : Accueil (si côtier)
→ Contient : Vagues, houle, température eau, avis
→ Visibilité conditionnelle

## 5. EtatVide
→ Utilisé dans : Favoris, Alertes, Recherche
→ Contient : Icône, message, action optionnelle
→ Ex: "Aucune alerte", "Aucun favori"

## 6. IndicateurMeteo
→ Utilisé dans : CarteMeteo
→ Contient : Icône + valeur + unité
→ Ex: 💧 65%, 💨 12 km/h, ☀️ UV6