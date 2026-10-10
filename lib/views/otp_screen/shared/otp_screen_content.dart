import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:panacea/controller/otp_controller.dart';
import 'package:panacea/components/gradient_background.dart';

class OtpPageContent extends StatelessWidget {
  const OtpPageContent({
    super.key,
  }); // No longer needs to pass mobileNumber in constructor

  Widget _buildOtpBox(
    BuildContext context,
    int index,
    OtpController controller,
  ) {
    return SizedBox(
      height: 64,
      width: 64,
      child: TextFormField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(
              context,
            ).requestFocus(controller.focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(
              context,
            ).requestFocus(controller.focusNodes[index - 1]);
          }
        },
        decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(), // GetX back navigation
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 1000
              ? _buildDesktopLayout(context, controller, textTheme, constraints)
              : _buildCompactLayout(
                  context,
                  controller,
                  textTheme,
                  constraints.maxHeight,
                ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    OtpController controller,
    TextTheme textTheme,
    double availableHeight,
  ) {
    final verticalPadding = availableHeight >= 760 ? 40.0 : 24.0;
    final minContentHeight = availableHeight - verticalPadding * 2;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: verticalPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minContentHeight > 0 ? minContentHeight : 0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Lottie.asset(
                    'assets/otp.json',
                    width: 260,
                    height: 170,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Verify Account', style: textTheme.headlineLarge),
                const SizedBox(height: 8),
                _buildDestinationText(controller, textTheme),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (index) => _buildOtpBox(context, index, controller),
                  ),
                ),
                const SizedBox(height: 48),
                FilledButton(
                  onPressed: controller.verifyCode,
                  child: const Text('Verify Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    OtpController controller,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    final verticalPadding = constraints.maxHeight >= 760 ? 40.0 : 20.0;
    final availablePanelHeight = constraints.maxHeight - verticalPadding * 2;
    final panelHeight = availablePanelHeight < 680
        ? availablePanelHeight
        : 680.0;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: verticalPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availablePanelHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: SizedBox(
              height: panelHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        color: const Color(0xFF123B4A),
                        padding: const EdgeInsets.all(56),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.health_and_safety,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'PANACEA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Center(
                              child: Lottie.asset(
                                'assets/otp.json',
                                width: 390,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Verification',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'A quick check before opening your clinic workspace.',
                              style: TextStyle(
                                color: Color(0xFFD4E4E8),
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 56,
                          vertical: 48,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Verify account',
                                  style: textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 10),
                                _buildDestinationText(controller, textTheme),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    4,
                                    (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: _buildOtpBox(
                                        context,
                                        index,
                                        controller,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 36),
                                FilledButton(
                                  onPressed: controller.verifyCode,
                                  child: const Text('Verify Code'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationText(OtpController controller, TextTheme textTheme) {
    return RichText(
      text: TextSpan(
        style: textTheme.bodyMedium,
        children: [
          const TextSpan(text: 'Enter the 4-digit code sent to '),
          TextSpan(
            text: controller.mobileNumber,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2024),
            ),
          ),
        ],
      ),
    );
  }
}
