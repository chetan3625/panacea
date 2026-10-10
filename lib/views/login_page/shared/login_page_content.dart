import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:panacea/components/common_components.dart';
import 'package:panacea/controller/auth_controller.dart';
import 'package:panacea/components/gradient_background.dart';

class LoginPageContent extends StatelessWidget {
  const LoginPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final authController = Get.put(AuthController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 1000
              ? _buildDesktopLayout(
                  context,
                  authController,
                  textTheme,
                  constraints.maxHeight,
                )
              : _buildCompactLayout(
                  context,
                  authController,
                  textTheme,
                  constraints.maxHeight,
                ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    AuthController authController,
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
                    'assets/Login.json',
                    width: 320,
                    height: 200,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Welcome Back', style: textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to your clinic dashboard.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                _buildFields(authController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AuthController authController,
    TextTheme textTheme,
    double availableHeight,
  ) {
    final verticalPadding = availableHeight >= 760 ? 40.0 : 20.0;
    final availablePanelHeight = availableHeight - verticalPadding * 2;
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
                                'assets/Login.json',
                                width: 390,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Care, clearly connected.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'A calmer workspace for your clinic and the people you care for.',
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
                          horizontal: 64,
                          vertical: 48,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to continue to your clinic dashboard.',
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 36),
                                _buildFields(authController),
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

  Widget _buildFields(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: authController.mobileController,
          label: 'Mobile Number',
          prefixIcon: Icons.phone_android_rounded,
          isNumber: true,
        ),
        const SizedBox(height: 20),
        Obx(
          () => CustomTextField(
            controller: authController.passwordController,
            label: 'Password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !authController.isPasswordVisible.value,
            suffixIcon: IconButton(
              icon: Icon(
                authController.isPasswordVisible.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: authController.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Obx(
          () => FilledButton(
            onPressed: authController.isLoading.value
                ? null
                : authController.login,
            child: authController.isLoading.value
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign In'),
          ),
        ),
      ],
    );
  }
}
