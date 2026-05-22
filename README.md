# MeteoMada

MeteoMada est une application mobile de météo pour Madagascar, développée avec **Flutter**.

## À propos du projet

Ce projet est une application mobile multiplateforme conçue pour fournir des informations météorologiques actualisées pour Madagascar. L'application est en cours de développement et sera déployée sur les plateformes Android, iOS, Web, Windows, Linux et macOS.

## Caractéristiques

- 📱 Application mobile multiplateforme avec Flutter
- 🌦️ Informations météorologiques en temps réel
- 🗺️ Couverture complète de Madagascar (23 régions)
- 🌡️ Données sur la température, l'humidité, le vent et bien plus
- ⚠️ Alertes cyclones en temps réel
- 🌾 Module météo agricole (riziculture, vanille, etc.)
- 🎣 Module météo marine pour les pêcheurs
- 🏖️ Recommandations touristiques par région
- 🇲🇬 Support bilingue Malgache / Français

## Technologies utilisées

- **Flutter** - Framework pour le développement multiplateforme
- **Dart** - Langage de programmation
- **Mermaid** - Diagrammes de conception UML
- Plateforme cible : Android, iOS, Web, Windows, Linux, macOS

## Démarrage

Pour contribuer ou développer cette application, consultez la [documentation officielle Flutter](https://docs.flutter.dev/).

## Conception UML

### 1. Diagramme de Cas d'Utilisation

```mermaid
graph TD
    U([Utilisateur standard]) --> UC1(Consulter météo du jour)
    U --> UC2(Rechercher une ville)
    U --> UC3(Voir prévisions 7 jours)
    U --> UC4(Ajouter ville aux favoris)
    U --> UC5(Changer langue malgache/français)
    
    A([Agriculteur]) --> UC6(Consulter météo agricole)
    A --> UC7(Recevoir alertes pluie)
    A --> UC8(Voir calendrier cultural)
    UC6 -->|include| UC2
    
    P([Pêcheur]) --> UC9(Consulter météo marine)
    P --> UC10(Voir état de la mer)
    P --> UC11(Recevoir alertes sortie mer)
    UC9 -->|include| UC2
    
    T([Touriste]) --> UC12(Voir météo des plages)
    T --> UC13(Comparer climats régions)
    T --> UC14(Planifier itinéraire météo)
    
    Admin([Administrateur]) --> UC15(Gérer les sources de données)
    Admin --> UC16(Émettre alerte cyclone)
    Admin --> UC17(Modérer signalements)
    
    UC16 -.->|déclenche| N([Service de notifications Push])
    N --> U
    N --> A
    N --> P
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
        +getClimatActuel() Prevision
        +getPrevisions(int jours) List~Prevision~
    }
    
    class Utilisateur {
        +String id
        +String pseudo
        +String email
        +String languePreferee
        +bool alertesCycloneActivees
        +bool alertesPluieActivees
        +ajouterFavori(Ville v)
        +supprimerFavori(String villeId)
        +consulterMeteo(Ville v)
        +changerLangue(String langue)
    }
    
    Utilisateur <|-- Agriculteur : héritage
    Utilisateur <|-- Pecheur : héritage
    Utilisateur <|-- Touriste : héritage
    
    class Agriculteur {
        +String[] typesCultures
        +String[] regionsSuivies
        +bool alertePluieActivee
        +consulterCalendrierCultural() CalendrierCultural
        +getRecommandationsSemis() List~String~
    }
    
    class Pecheur {
        +String[] zonesPeche
        +String typeBateau
        +bool alerteMerDangereuse
        +consulterEtatMer(Ville v) ConditionMarine
        +estSortieAutorisee() bool
    }
    
    class Touriste {
        +Date dateArrivee
        +Date dateDepart
        +String[] lieuxVisites
        +comparerClimats(Ville[] villes) Map~String,Prevision~
        +suggererMeilleurePeriode(String region) String
    }
    
    class Prevision {
        +String id
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
        +traduireCondition(String langue) String
        +estFavorable(String activite) bool
    }
    
    class ConditionMarine {
        +Float hauteurVagues
        +Float temperatureEau
        +String etatMaree
        +String ventMarin
        +Float houle
        +bool baignadeDangereuse
        +bool pechePossible
        +getConseilMarin() String
    }
    
    class AlerteCyclone {
        +String id
        +String nomCyclone
        +NiveauAlerte niveau
        +DateTime dateEmission
        +DateTime dateFinPrevue
        +String[] regionsConcernees
        +String[] consignes
        +List~PointGPS~ trajectoire
        +estActive() bool
        +getRegionsTouchees() List~String~
    }
    
    class NiveauAlerte {
        <<enumeration>>
        VERT
        JAUNE
        ORANGE
        ROUGE
        POST_CYCLONE
    }
    
    class CalendrierCultural {
        +String id
        +String region
        +String typeCulture
        +Mois[] periodeSemis
        +Mois[] periodeRecolte
        +String[] conseilsMeteo
        +estPeriodeSemis(DateTime date) bool
        +estPeriodeRecolte(DateTime date) bool
    }
    
    class SourceDonnee {
        +String id
        +String nom
        +String type
        +String urlAPI
        +Float fiabilite
        +DateTime derniereMAJ
        +recupererDonnees(Ville v) List~Prevision~
        +estDisponible() bool
    }
    
    class Favori {
        +String id
        +DateTime dateAjout
        +String surnom
        +bool notificationsActives
        +int ordreAffichage
        +getPrevisionResume() String
    }
    
    class Notification {
        +String id
        +String titre
        +String message
        +TypeNotification type
        +DateTime dateEnvoi
        +bool estLue
        +String villeConcernee
    }
    
    class TypeNotification {
        <<enumeration>>
        ALERTE_CYCLONE
        ALERTE_PLUIE
        METEO_JOURNALIERE
        CONSEIL_AGRICOLE
        ALERTE_MER
    }
    
    Ville "1" --> "*" Prevision : possède
    Ville "1" --> "0..1" ConditionMarine : a si côtière
    Utilisateur "1" --> "*" Favori : possède
    Utilisateur "1" --> "*" Notification : reçoit
    Favori "*" --> "1" Ville : référence
    Prevision "*" --> "0..1" ConditionMarine : inclut si applicable
    AlerteCyclone "*" --> "1..*" Ville : concerne
    Ville "1" --> "1..*" SourceDonnee : alimentée par
    CalendrierCultural "*" --> "1" Region : associé à
    Agriculteur "1" --> "*" CalendrierCultural : consulte
```

### 3. Diagramme de Séquence : Alerte Cyclone

```mermaid
sequenceDiagram
    participant Satellite as Détecteur Satellite
    participant API as API Météo
    participant System as Système MadaWeather
    participant Admin as Administrateur
    participant Push as Service Push
    participant App as Application Mobile
    participant User as Utilisateur
    
    Satellite->>API: detectionDepression(zone, intensite)
    API->>System: transmettreDonneesBrutes()
    System->>System: analyserTrajectoire()
    System->>System: evaluerNiveauRisque()
    
    alt Risque élevé (niveau Orange/Rouge)
        System->>Admin: alerteNouveauCyclone(nom, niveau, trajectoire)
        Admin->>System: confirmerAlerte(consignes, regionsConcernees)
        System->>System: creerAlerteCyclone()
        System->>System: genererNotifications()
        System->>Push: diffuserAlerte(alerte, regions)
        Push->>App: notificationPush(alerteCyclone)
        App->>User: afficherNotification()
        User->>App: ouvrirDetailsAlerte()
        App->>System: requeteDetailsAlerte(idAlerte)
        System-->>App: detailsComplets + carteTrajectoire
        App-->>User: afficherCarteInteractive()
        User->>App: activerSuiviCyclone()
        App->>System: enregistrerSuivi(userId, alerteId)
        System-->>App: confirmationActivation
    else Risque faible (niveau Vert/Jaune)
        System->>System: surveillanceContinue()
        System-->>Admin: rapportSurveillance()
    end
    
    loop Toutes les 3 heures
        API->>System: miseAJourPositionCyclone()
        System->>System: recalculerTrajectoire()
        System->>System: mettreAJourAlerte()
        System->>Push: notificationMiseAJour(alerteId)
        Push->>App: notification(nouvellePosition)
        App-->>User: miseAJourCarte()
    end
    
    alt Fin du cyclone
        System->>Admin: propositionFinAlerte()
        Admin->>System: confirmerFinAlerte()
        System->>Push: notificationFinAlerte()
        Push->>App: notificationFin()
        App-->>User: messageFinAlerte + bilan
    end
```

### 4. Diagramme d'États : Cycle de vie d'une Alerte Cyclone

```mermaid
stateDiagram-v2
    [*] --> Surveillance
    
    Surveillance --> DepressionTropicale : Dépression détectée\n(vents < 63 km/h)
    
    DepressionTropicale --> TempeteTropicale : Intensification\n(vents 63-118 km/h)
    DepressionTropicale --> Dissipation : Perte d'intensité
    
    TempeteTropicale --> CycloneTropical : Intensification\n(vents > 118 km/h)
    TempeteTropicale --> Dissipation : Perte d'intensité
    
    CycloneTropical --> CycloneIntense : Vents > 166 km/h
    CycloneTropical --> AlerteJaune : Menace Madagascar
    CycloneTropical --> Dissipation : Changement de trajectoire
    
    CycloneIntense --> AlerteOrange : Approche des côtes
    CycloneIntense --> AlerteRouge : Impact direct imminent
    
    AlerteJaune --> AlerteOrange : Intensification
    AlerteJaune --> FinAlerte : Éloignement confirmé
    
    AlerteOrange --> AlerteRouge : Aggravation\n(impact sous 12h)
    AlerteOrange --> AlerteJaune : Amélioration
    
    AlerteRouge --> PhasePostCyclone : Cyclone passé\n(dégâts à évaluer)
    
    PhasePostCyclone --> Bilan : Évaluation complète
    Bilan --> Surveillance : Retour à la normale
    
    Dissipation --> Surveillance
    FinAlerte --> Surveillance
    
    note right of AlerteJaune : • Information populations\n• Préparation kits urgence
    note right of AlerteOrange : • Écoles fermées\n• Évacuations préventives\n• Activation BNGRC
    note right of AlerteRouge : • Confinement total\n• Alerte SMS obligatoire\n• Secours en alerte max
    note right of PhasePostCyclone : • Activation aide humanitaire\n• Évaluation dégâts\n• Distribution vivres
```
### 5. Diagramme de Séquence : Consultation Météo Quotidienne

```mermaid
sequenceDiagram
    participant User as Utilisateur
    participant App as Application Mobile
    participant Cache as Cache Local
    participant API as API Météo
    participant DB as Base de Données
    
    User->>App: ouvrirApplication()
    App->>App: detecterLocalisation()
    App->>Cache: verifierDonneesEnCache(villeId)
    
    alt Cache valide (< 30 min)
        Cache-->>App: donneesCachees
        App->>App: formaterAffichage()
        App-->>User: afficherMeteoActuelle()
    else Cache expiré ou absent
        App->>API: requeteMeteoActuelle(lat, lon)
        API-->>App: donneesMeteoBrutes
        App->>App: parserDonnees()
        App->>Cache: mettreEnCache(donnees)
        App->>DB: sauvegarderHistorique(villeId, donnees)
        App-->>User: afficherMeteoActuelle()
    end
    
    User->>App: changerVille(recherche)
    App->>API: rechercherVilles(terme, langue)
    API-->>App: listeVillesCorrespondantes
    App-->>User: afficherResultatsRecherche()
    
    User->>App: selectionnerVille(villeId)
    App->>API: requetePrevisions7Jours(villeId, langue)
    API-->>App: previsions7Jours
    App->>App: calculerTendances()
    App-->>User: afficherPrevisionsDetaillees()
    
    alt Condition marine (ville côtière)
        User->>App: consulterOngletMarine()
        App->>API: requeteConditionsMarines(lat, lon)
        API-->>App: donneesMarines
        App->>App: evaluerDangers()
        App-->>User: afficherEtatMer + conseils
    end
    
    User->>App: ajouterFavori(villeId, surnom)
    App->>DB: sauvegarderFavori(userId, villeId, surnom)
    DB-->>App: confirmationEnregistrement
    App-->>User: favoriAjouté()
```