import 'package:flutter/material.dart';

import '../types.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity;
  final VoidCallback onClick;
  final bool? isFavorite;
  final VoidCallback? onToggleFavorite;
  const ActivityCard({Key? key, required this.activity, required this.onClick, this.isFavorite, this.onToggleFavorite}) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 2, end: 12).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    if (isHovering) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onClick,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _elevationAnimation,
            builder: (context, child) {
              return Card(
                margin: EdgeInsets.zero,
                elevation: _elevationAnimation.value,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    // Image with overlay gradient
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          Image.network(
                            widget.activity.image,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.grey[300]!, Colors.grey[200]!],
                                  ),
                                ),
                                child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                              );
                            },
                          ),
                          // Bottom gradient overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Promotion badge (top right)
                    if (widget.activity.hasPromotion ?? false)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Color(0xFFFF6B6B).withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_offer, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                widget.activity.promotionText ?? 'Promo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Favorite button (top left) with animation
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: widget.onToggleFavorite,
                        child: _FavoriteButton(
                          isFavorite: widget.isFavorite ?? false,
                        ),
                      ),
                    ),
                  ],
                ),
                // Content section
                Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Activity name
                      Text(
                        widget.activity.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.activity.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Type badge and rating row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF2563EB).withOpacity(0.1), Color(0xFF3B82F6).withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Color(0xFF3B82F6).withOpacity(0.3)),
                            ),
                            child: Text(
                              widget.activity.type,
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Rating with stars
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 13, color: Colors.amber[700]),
                                SizedBox(width: 3),
                                Text(
                                  widget.activity.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[300]!.withOpacity(0.5), Colors.transparent],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'À partir de ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.activity.price}€',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Animated favorite button
class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;

  const _FavoriteButton({required this.isFavorite});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite && widget.isFavorite) {
      _heartAnimationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.isFavorite ? Colors.red[500] : Colors.grey[700],
          size: 20,
        ),
      ),
    );
  }
}
