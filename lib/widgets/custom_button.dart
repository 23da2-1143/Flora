import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutline;
  final double width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutline = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 55,
      child: isOutline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gold, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.lato(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: Text(
                text,
                style: GoogleFonts.lato(
                  color: AppColors.darkGray,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
