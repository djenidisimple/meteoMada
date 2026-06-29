/// Énumérateur d'état partagé par tous les providers de l'écran d'accueil.
///
/// Permet à l'UI de distinguer clairement les 3 phases du cycle de vie
/// d'un chargement de données et d'adapter l'affichage en conséquence :
/// - [initial]  → Aucun chargement n'a encore été tenté.
/// - [loading]  → Un chargement asynchrone est en cours.
/// - [success]  → Les données sont disponibles et prêtes à l'affichage.
/// - [error]    → Le chargement a échoué (réseau, parsing, etc.).
enum HomeDataState {
  /// Aucun chargement n'a encore été lancé.
  initial,

  /// Un chargement asynchrone est en cours (afficher shimmer/skeleton).
  loading,

  /// Les données ont été chargées avec succès (afficher les vraies données).
  success,

  /// Le chargement a échoué (afficher un message d'erreur ou icône warning).
  error,
}
