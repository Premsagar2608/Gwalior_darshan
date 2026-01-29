import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final String name;
  final String image;
  final String? location;
  final String? price;
  final dynamic rating; // can be int/double/string
  final VoidCallback onTap;

  const HotelCard({
    super.key,
    required this.name,
    required this.image,
    required this.onTap,
    this.location,
    this.price,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final ratingText = (rating == null) ? null : rating.toString();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // IMAGE SECTION
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                image,
                width: 110,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackImage(),
              ),
            ),

            const SizedBox(width: 12),

            // TEXT SECTION
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    if (location != null && location!.trim().isNotEmpty)
                      Text(
                        location!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        if (price != null && price!.trim().isNotEmpty)
                          Text(
                            "💰 $price",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),

                        if (price != null &&
                            price!.trim().isNotEmpty &&
                            ratingText != null)
                          const SizedBox(width: 10),

                        if (ratingText != null)
                          Text(
                            "⭐ $ratingText",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 110,
      height: 90,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported),
    );
  }
}
