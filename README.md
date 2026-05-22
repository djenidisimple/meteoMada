# MeteoMada

MeteoMada est une application mobile météo pour Madagascar, développée avec **Flutter**.

## À propos du projet

Application mobile multiplateforme qui fournit des informations météorologiques pour Madagascar. L'application fonctionne sans serveur back-end : les données météo sont récupérées directement depuis une API externe et stockées localement dans une base SQLite.

## Fonctionnalités

- 🌦️ Météo actuelle et prévisions 7 jours
- 🗺️ Couverture des 23 régions de Madagascar
- 🌡️ Température, humidité, vent, indice UV
- ⚠️ Alertes cyclones avec notifications locales
- 🌾 Calendrier cultural par région
- 🎣 Conditions marines pour les villes côtières
- 🏖️ Comparaison de climats entre régions
- ⭐ Villes favorites
- 🇲🇬 Bilingue malgache / français
- 📦 Stockage local SQLite

## Technologies

- **Flutter** - Framework multiplateforme
- **Dart** - Langage de programmation
- **SQLite** - Base de données locale
- **Mermaid** - Diagrammes UML

## Conception UML

### 1. Diagramme de Cas d'Utilisation

```mermaid
graph TD
    U([Utilisateur]) --> UC1(Consulter météo du jour)
    U --> UC2(Rechercher une ville)
    U --> UC3(Voir prévisions 7 jours)
    U --> UC4(Ajouter ville aux favoris)
    U --> UC5(Changer langue malgache/français)
    U --> UC6(Activer notifications)
    
    U --> UC7(Consulter météo marine)
    UC7 -->|inclut si ville côtière| UC2
    
    U --> UC8(Consulter calendrier cultural)
    UC8 -->|inclut| UC2
    
    U --> UC9(Voir alertes cyclone)
    U --> UC10(Comparer climats régions)
    
    UC1 -.->|données stockées dans| DB[(SQLite locale)]
    UC3 -.->|cache| DB
    UC4 -.->|sauvegarde| DB
    UC9 -.->|alertes reçues via API| DB
    
    API([API Météo externe]) -.->|fournit données| UC1
    API -.->|fournit prévisions| UC3
    API -.->|fournit alertes| UC9
    API -.->|fournit conditions mer| UC7
```

### 2. Diagramme de Classes

```mermaid
classDiagram
    class Ville {
        +String id
        +String nom
        +String region
        +Float latitude
        +Float longitude
        +Int altitude
        +String fuseauHoraire
        +bool estCotiere
        +fromMap(Map) Ville
        +toMap() Map
    }
    
    class Prevision {
        +String id
        +String villeId
        +DateTime dateHeure
        +Float temperature
        +Float temperatureRessentie
        +String condition
        +Float humidite
        +Float vitesseVent
        +String directionVent
        +Float probabilitePluie
        +Float indiceUV
        +String icone
        +DateTime dateCreation
        +estExpiree() bool
        +fromMap(Map) Prevision
        +toMap() Map
    }
    
    class ConditionMarine {
        +String id
        +String villeId
        +Float hauteurVagues
        +Float temperatureEau
        +String etatMaree
        +String ventMarin
        +Float houle
        +bool baignadeDangereuse
        +bool pechePossible
        +fromMap(Map) ConditionMarine
        +toMap() Map
    }
    
    class Utilisateur {
        +String id
        +String pseudo
        +String languePreferee
        +String typeUtilisateur
        +bool alertesCycloneActivees
        +bool alertesPluieActivees
        +fromMap(Map) Utilisateur
        +toMap() Map
    }
    
    class Favori {
        +String id
        +String utilisateurId
        +String villeId
        +String surnom
        +bool notificationsActives
        +int ordreAffichage
        +DateTime dateAjout
        +fromMap(Map) Favori
        +toMap() Map
    }
    
    class AlerteCyclone {
        +String id
        +String nomCyclone
        +String niveau
        +DateTime dateEmission
        +DateTime dateFinPrevue
        +String consignes
        +bool estActive
        +fromMap(Map) AlerteCyclone
        +toMap() Map
    }
    
    class AlerteRegion {
        +String alerteId
        +String region
        +fromMap(Map) AlerteRegion
        +toMap() Map
    }
    
    class CalendrierCultural {
        +String id
        +String region
        +String typeCulture
        +int moisSemisDebut
        +int moisSemisFin
        +int moisRecolteDebut
        +int moisRecolteFin
        +String conseilsMeteo
        +fromMap(Map) CalendrierCultural
        +toMap() Map
    }
    
    class NotificationLocale {
        +String id
        +String titre
        +String message
        +String type
        +DateTime dateEnvoi
        +bool estLue
        +String villeConcernee
        +fromMap(Map) NotificationLocale
        +toMap() Map
    }
    
    Ville "1" --> "*" Prevision : stocke
    Ville "1" --> "0..1" ConditionMarine : a si côtière
    Utilisateur "1" --> "*" Favori : possède
    Favori "*" --> "1" Ville : référence
    AlerteCyclone "1" --> "*" AlerteRegion : concerne
    Utilisateur "1" --> "*" NotificationLocale : reçoit
```

### 3. Diagramme de Séquence : Alerte Cyclone

```mermaid
sequenceDiagram
    participant API as API Météo externe
    participant App as Application Mobile
    participant DB as SQLite locale
    participant Push as Notifications locales
    participant User as Utilisateur
    
    Note over App: L'app interroge l'API toutes les 30 minutes
    
    App->>API: requeteAlertesActives()
    API-->>App: listeAlertes
    
    loop Pour chaque alerte
        App->>DB: verifierAlerteExistante(alerteId)
        
        alt Nouvelle alerte
            App->>DB: insererAlerte(alerte)
            App->>DB: insererRegionsConcernees(alerteId, regions)
            App->>App: evaluerNiveauRisque()
            
            alt Niveau Orange ou Rouge
                App->>Push: creerNotificationLocale(alerte)
                Push-->>User: notificationPush
                User->>App: ouvrirNotification()
                App->>DB: recupererDetailsAlerte(alerteId)
                DB-->>App: detailsAlerte + regions
                App-->>User: afficherDetails + consignes
            end
        else Alerte existante mais modifiée
            App->>DB: mettreAJourAlerte(alerte)
            App->>DB: mettreAJourRegions(alerteId, regions)
            
            alt Changement de niveau
                App->>Push: creerNotificationMiseAJour()
                Push-->>User: notificationMiseAJour
            end
        end
    end
    
    User->>App: consulterHistoriqueAlertes()
    App->>DB: recupererToutesAlertes()
    DB-->>App: listeAlertesStockees
    App-->>User: afficherHistorique()
    
    User->>App: filtrerParRegion(region)
    App->>DB: recupererAlertesParRegion(region)
    DB-->>App: alertesFiltrees
    App-->>User: afficherAlertesFiltrees()
```

### 4. Diagramme d'États : Cycle de vie d'une Alerte Cyclone

```mermaid
stateDiagram-v2
    [*] --> Surveillance
    
    Surveillance --> DepressionTropicale : Dépression détectée<br/>(vents < 63 km/h)
    
    DepressionTropicale --> TempeteTropicale : Intensification<br/>(vents 63-118 km/h)
    DepressionTropicale --> Dissipation : Perte d'intensité
    
    TempeteTropicale --> CycloneTropical : Intensification<br/>(vents > 118 km/h)
    TempeteTropicale --> Dissipation : Perte d'intensité
    
    CycloneTropical --> CycloneIntense : Vents > 166 km/h
    CycloneTropical --> AlerteJaune : Menace Madagascar
    CycloneTropical --> Dissipation : Changement de trajectoire
    
    CycloneIntense --> AlerteOrange : Approche des côtes
    CycloneIntense --> AlerteRouge : Impact direct imminent
    
    AlerteJaune --> AlerteOrange : Intensification
    AlerteJaune --> FinAlerte : Éloignement confirmé
    
    AlerteOrange --> AlerteRouge : Aggravation<br/>(impact sous 12h)
    AlerteOrange --> AlerteJaune : Amélioration
    
    AlerteRouge --> PhasePostCyclone : Cyclone passé<br/>(dégâts à évaluer)
    
    PhasePostCyclone --> Bilan : Évaluation complète
    Bilan --> Surveillance : Retour à la normale
    
    Dissipation --> Surveillance
    FinAlerte --> Surveillance
    
    note right of AlerteJaune : • Notification push locale<br/>• Préparation kits urgence
    note right of AlerteOrange : • Alerte prioritaire<br/>• Évacuations préventives
    note right of AlerteRouge : • Confinement total<br/>• Notification critique<br/>• Sons et vibration
    note right of PhasePostCyclone : • Bilan humain et matériel<br/>• Activation aide
```
### 5. Diagramme de Séquence : Consultation Météo Quotidienne

```mermaid
sequenceDiagram
    participant User as Utilisateur
    participant App as Application Mobile
    participant DB as SQLite locale
    participant API as API Météo externe
    
    User->>App: ouvrirApplication()
    App->>App: detecterLocalisation()
    App->>DB: getVilleParCoordonnees(lat, lon)
    
    alt Ville trouvée dans SQLite
        DB-->>App: ville
    else Ville non trouvée
        App->>API: geocoderCoordonnees(lat, lon)
        API-->>App: nomVille, region
        App->>DB: insererVille(ville)
    end
    
    App->>DB: getPrevisionActive(villeId)
    
    alt Cache valide (< 30 min)
        DB-->>App: previsionEnCache
        App-->>User: afficherMeteoActuelle()
    else Cache expiré
        App->>API: requeteMeteoActuelle(lat, lon)
        API-->>App: donneesMeteo
        App->>DB: supprimerVieillesPrevisions(villeId)
        App->>DB: insererPrevision(prevision)
        App-->>User: afficherMeteoActuelle()
    end
    
    User->>App: rechercherVille(terme)
    App->>DB: rechercherVillesSQLite(terme)
    DB-->>App: villesCorrespondantes
    App-->>User: afficherResultats()
    
    User->>App: selectionnerVille(villeId)
    App->>DB: getPrevisions7Jours(villeId)
    
    alt Prévisions complètes en cache
        DB-->>App: previsions7Jours
    else Cache incomplet
        App->>API: requetePrevisions7Jours(lat, lon)
        API-->>App: previsions7Jours
        App->>DB: insererPrevisions(previsions)
    end
    
    App-->>User: afficherPrevisions()
    
    alt Ville côtière
        User->>App: consulterOngletMarine()
        App->>DB: getConditionMarine(villeId)
        alt Cache marine valide
            DB-->>App: conditionMarine
        else Cache expiré
            App->>API: requeteConditionsMarines(lat, lon)
            API-->>App: donneesMarines
            App->>DB: insererConditionMarine(condition)
        end
        App-->>User: afficherEtatMer()
    end
    
    User->>App: ajouterFavori(villeId, surnom)
    App->>DB: insererFavori(favori)
    DB-->>App: confirmation
    App-->>User: toast "Ville ajoutée aux favoris"
    
    User->>App: voirFavoris()
    App->>DB: getFavoris(utilisateurId)
    DB-->>App: listeFavoris
    App-->>User: afficherFavoris()
```