import 'package:material_ui/material_ui.dart';

/// The look from docs/style/ui-style.md: colours (§3), type (§4) and the
/// parts of Flutter's theme that follow from them.

/// A deep (dark theme) or pale (light theme) version of an accent, used as
/// the background of a tonal card, with the text colour that goes on it.
class Tone {
  const Tone(this.container, this.onContainer);

  final Color container;
  final Color onContainer;
}

/// The colours Material's [ColorScheme] has no place for. Read them with
/// `context.kept` (`ui/common.dart`).
class KeptColors extends ThemeExtension<KeptColors> {
  const KeptColors({
    required this.ground,
    required this.surface,
    required this.surfaceHigh,
    required this.greyEdge,
    required this.shadow,
    required this.text,
    required this.muted,
    required this.line,
    required this.sunTone,
    required this.mintTone,
    required this.lilacTone,
    required this.pinkTone,
    required this.skyTone,
    required this.coralTone,
  });

  // The accents are the same in both themes.
  static const coral = Color(0xFFFF8A7A);
  static const coralEdge = Color(0xFFC4564A);
  static const sun = Color(0xFFFFCF5C);
  static const sunEdge = Color(0xFFC4962A);
  static const mint = Color(0xFF7EDDBE);
  static const lilac = Color(0xFFC3B4FF);
  static const sky = Color(0xFF8CCBFF);
  static const pink = Color(0xFFFF9EC6);

  /// Text and icons on any accent, in both themes.
  static const onAccent = Color(0xFF1F1326);

  /// The drop shadow that follows an avatar's shape (black at 40 %, the
  /// same in both themes; ui-style.md §5).
  static const avatarShadow = Color(0x66000000);

  /// Screen background, and input fields inside cards.
  final Color ground;

  /// Cards, list rows, navigation bar.
  final Color surface;

  /// Grey buttons, quote bubbles, the selected navigation pill.
  final Color surfaceHigh;

  /// The hard shadow under grey buttons.
  final Color greyEdge;

  /// The hard shadow under cards, badges, tags and notes.
  final Color shadow;

  final Color text;
  final Color muted;

  /// Timeline line, dashed borders, dividers.
  final Color line;

  final Tone sunTone;
  final Tone mintTone;
  final Tone lilacTone;
  final Tone pinkTone;
  final Tone skyTone;
  final Tone coralTone;

  static const dark = KeptColors(
    ground: Color(0xFF17121C),
    surface: Color(0xFF231C2A),
    surfaceHigh: Color(0xFF30273A),
    greyEdge: Color(0xFF08060B),
    shadow: Color(0x80000000),
    text: Color(0xFFEFE3F2),
    muted: Color(0xFFBBADC2),
    line: Color(0xFF54475E),
    sunTone: Tone(Color(0xFF46380F), Color(0xFFFFE29A)),
    mintTone: Tone(Color(0xFF12433A), Color(0xFFA6F0D8)),
    lilacTone: Tone(Color(0xFF352B63), Color(0xFFDCD3FF)),
    pinkTone: Tone(Color(0xFF54213A), Color(0xFFFFC4DC)),
    skyTone: Tone(Color(0xFF173F5E), Color(0xFFBFE2FF)),
    coralTone: Tone(Color(0xFF5A231C), Color(0xFFFFC2B8)),
  );

  static const _lightText = Color(0xFF2A1B3D);

  static const light = KeptColors(
    ground: Color(0xFFFFF6EA),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF3E6D6),
    greyEdge: Color(0xFFD9C7B2),
    shadow: Color(0x332A1B3D),
    text: _lightText,
    muted: Color(0xFF6B5A7A),
    line: Color(0xFFCDBBA8),
    sunTone: Tone(Color(0xFFFFE08A), _lightText),
    mintTone: Tone(Color(0xFFBDEFDD), _lightText),
    lilacTone: Tone(Color(0xFFDDD4FF), _lightText),
    pinkTone: Tone(Color(0xFFFFD0E2), _lightText),
    skyTone: Tone(Color(0xFFC6E5FF), _lightText),
    coralTone: Tone(Color(0xFFFFC9C0), _lightText),
  );

  // The two themes are fixed sets, so there is nothing to copy or blend.
  @override
  KeptColors copyWith() => this;

  @override
  KeptColors lerp(KeptColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

/// Outfit, for headings, buttons, tags, labels and numbers. The font file is
/// a variable font, so the weight is also given as a variation.
TextStyle outfit(double size, FontWeight weight, {Color? color}) => TextStyle(
  fontFamily: 'Outfit',
  fontSize: size,
  fontWeight: weight,
  fontVariations: [FontVariation.weight(weight.value.toDouble())],
  color: color,
);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final c = dark ? KeptColors.dark : KeptColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: KeptColors.coral,
    onPrimary: KeptColors.onAccent,
    primaryContainer: c.coralTone.container,
    onPrimaryContainer: c.coralTone.onContainer,
    secondary: KeptColors.sun,
    onSecondary: KeptColors.onAccent,
    secondaryContainer: c.sunTone.container,
    onSecondaryContainer: c.sunTone.onContainer,
    tertiary: KeptColors.mint,
    onTertiary: KeptColors.onAccent,
    tertiaryContainer: c.mintTone.container,
    onTertiaryContainer: c.mintTone.onContainer,
    // Coral is the action colour, and nothing is shown as a warning
    // (ui-style.md §2.7), so errors use the coral tone as well.
    error: c.coralTone.onContainer,
    onError: c.coralTone.container,
    surface: c.ground,
    onSurface: c.text,
    onSurfaceVariant: c.muted,
    surfaceContainerLowest: c.ground,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surfaceHigh,
    surfaceContainerHighest: c.surfaceHigh,
    outline: c.line,
    outlineVariant: c.line,
    shadow: c.shadow,
  );
  final base = ThemeData(colorScheme: scheme, extensions: [c]);
  return base.copyWith(
    scaffoldBackgroundColor: c.ground,
    // ui-style.md §4. Roboto is Android's own font and stays the default.
    textTheme: base.textTheme.copyWith(
      displayLarge: outfit(68, FontWeight.w700, color: c.text), // big number
      headlineLarge: outfit(30, FontWeight.w700, color: c.text), // screen title
      titleLarge: outfit(21, FontWeight.w600, color: c.text), // card title
      labelLarge: outfit(17, FontWeight.w600), // button
      labelMedium: outfit(
        13,
        FontWeight.w600,
        color: c.text,
      ).copyWith(letterSpacing: 13 * 0.08), // section label
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: c.muted,
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: c.ground,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: outfit(21, FontWeight.w600, color: c.text),
    ),
    iconButtonTheme: const IconButtonThemeData(
      variant: StyleVariant.material3Expressive,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.surfaceHigh,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.text,
              )
            : TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.muted,
              ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 26,
          color: states.contains(WidgetState.selected) ? c.text : c.muted,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
