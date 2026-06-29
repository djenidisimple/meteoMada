import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

/// Widget de chargement animé (shimmer) qui remplace les blocs gris statiques.
///
/// Affiche un conteneur avec un effet de balayage lumineux animé,
/// donnant un retour visuel à l'utilisateur pendant le chargement des données.
class ShimmerBlock extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBlock({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 20,
  });

  @override
  State<ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                AppTheme.backgroundCard,
                Colors.white.withValues(alpha: 0.08),
                AppTheme.backgroundCard,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.04),
              width: 0.5,
            ),
          ),
        );
      },
    );
  }
}

/// Version compacte du shimmer pour les cartes de la grille HomeInfoGrid.
/// Inclut un en-tête shimmer et des lignes de texte simulées.
class ShimmerCardContent extends StatelessWidget {
  const ShimmerCardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBlock(height: 14, width: 60, borderRadius: 4),
        SizedBox(height: 10),
        ShimmerBlock(height: 24, width: 80, borderRadius: 6),
        SizedBox(height: 8),
        ShimmerBlock(height: 10, width: 100, borderRadius: 4),
      ],
    );
  }
}
