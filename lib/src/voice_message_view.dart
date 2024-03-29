import 'package:flutter/material.dart';
import 'package:voice_message_package/src/helpers/play_status.dart';
import 'package:voice_message_package/src/helpers/utils.dart';
import 'package:voice_message_package/src/voice_controller.dart';
import 'package:voice_message_package/src/widgets/noises.dart';
import 'package:voice_message_package/src/widgets/play_pause_button.dart';
import 'package:voice_message_package/src/widgets/single_noise.dart';
import 'package:flutter/material.dart';
import 'package:voice_message_package/src/widgets/loading_widget.dart';
import 'package:voice_message_package/voice_message_package.dart';

/// A widget that displays a voice message view with play/pause functionality.
///
/// The [VoiceMessageView] widget is used to display a voice message with customizable appearance and behavior.
/// It provides a play/pause button, a progress slider, and a counter for the remaining time.
/// The appearance of the widget can be customized using various properties such as background color, slider color, and text styles.
///
class VoiceMessageView extends StatelessWidget {
  const VoiceMessageView({
    Key? key,
    required this.controller,
    this.backgroundColor = Colors.white,
    this.activeSliderColor = Colors.red,
    this.notActiveSliderColor,
    this.circlesColor = Colors.red,
    this.innerPadding = 12,
    this.cornerRadius = 20,
    this.size = 38,
    this.circlesTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
    this.counterTextStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  }) : super(key: key);

  /// The controller for the voice message view.
  final VoiceController controller;

  /// The background color of the voice message view.
  final Color backgroundColor;

  ///
  final Color circlesColor;

  /// The color of the active slider.
  final Color activeSliderColor;

  /// The color of the not active slider.
  final Color? notActiveSliderColor;

  /// The text style of the circles.
  final TextStyle circlesTextStyle;

  /// The text style of the counter.
  final TextStyle counterTextStyle;

  /// The padding between the inner content and the outer container.
  final double innerPadding;

  /// The corner radius of the outer container.
  final double cornerRadius;

  /// The size of the play/pause button.
  final double size;

  @override

  /// Build voice message view.
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final color = circlesColor;
    final newTHeme = theme.copyWith(
      sliderTheme: SliderThemeData(
        trackShape: CustomTrackShape(),
        thumbShape: SliderComponentShape.noThumb,
        minThumbSeparation: 0,
      ),
      splashColor: Colors.transparent,
    );

    return Container(
      padding: EdgeInsets.all(innerPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: ValueListenableBuilder(
        /// update ui when change play status
        valueListenable: controller.updater,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// play pause button
                  InkWell(
                    onTap: controller.isDownloadError

                        /// faild loading audio
                        ? controller.play
                        : controller.isPlaying

                            /// playing or pause
                            ? controller.pausePlaying
                            : controller.play,
                    child: Container(
                      height: size,
                      width: size,
                      // decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: controller.isDownloading
                          ? LoadingWidget(
                              progress: controller.downloadProgress,
                              onClose: () {
                                controller.cancelDownload();
                              },
                            )
                          : Icon(
                              /// faild to load audio
                              controller.isDownloadError

                                  /// show refresh icon
                                  ? Icons.refresh

                                  /// playing or pause
                                  : controller.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,

                              /// icon color
                              color: color,
                            ),
                    ),
                  ),

                  ///
                  const SizedBox(width: 10),

                  /// slider & noises
                  _noises(newTHeme),

                  ///
                  const SizedBox(width: 12),

                  /// speed button
                  InkWell(
                    onTap: controller.changeSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        controller.speed.playSpeedStr,
                        style: circlesTextStyle,
                      ),
                    ),
                  ),

                  ///
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: size + 10),
                child: Text(controller.remindingTime, style: counterTextStyle),
              ),
            ],
          );
        },
      ),
    );
  }

  SizedBox _noises(ThemeData newTHeme) => SizedBox(
        height: 30,
        width: controller.noiseWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// noises
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < controller.randoms!.length; i++)
                  Builder(
                    builder: (context) {
                      final asdf =
                          (controller.animController.value / controller.noiseWidth * controller.randoms!.length)
                              .floor();
                      return SingleNoise(
                        activeSliderColor:
                            i >= asdf ? notActiveSliderColor ?? backgroundColor.withOpacity(.4) : activeSliderColor,
                        height: controller.randoms![i],
                      );
                    },
                  ),
              ],
            ),
            Opacity(
              opacity: 0,
              child: Container(
                width: controller.noiseWidth,
                color: Colors.transparent.withOpacity(1),
                child: Theme(
                  data: newTHeme,
                  child: Slider(
                    value: controller.currentMillSeconds,
                    max: controller.maxMillSeconds,
                    onChangeStart: controller.onChangeSliderStart,
                    onChanged: controller.onChanging,
                    onChangeEnd: (value) {
                      controller.onSeek(
                        Duration(milliseconds: value.toInt()),
                      );
                      controller.play();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Transform _changeSpeedButton(Color color) => Transform.translate(
        offset: const Offset(0, -7),
        child: InkWell(
          onTap: controller.changeSpeed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              controller.speed.playSpeedStr,
              style: circlesTextStyle,
            ),
          ),
        ),
      );
}

///
/// A custom track shape for a slider that is rounded rectangular in shape.
/// Extends the [RoundedRectSliderTrackShape] class.
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override

  /// Returns the preferred rectangle for the voice message view.
  ///
  /// The preferred rectangle is calculated based on the current state and layout
  /// of the voice message view. It represents the area where the view should be
  /// displayed on the screen.
  ///
  /// Returns a [Rect] object representing the preferred rectangle.
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 10;
    final double trackLeft = offset.dx, trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
