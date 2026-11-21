import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brms_theme.dart';
import '../widgets/brms_common.dart';

/// Screen 1: BRMS CSU Aparri - Offline Authentication Gate (Monochrome).
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final _credentialsFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'johnyrey');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _rememberCredentials = true;

  void _submitCredentials() {
    if (!(_credentialsFormKey.currentState?.validate() ?? false)) {
      showBrmsNotice(context, 'Please fill in the highlighted required fields.');
      return;
    }
    widget.onAuthenticated();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openRecoveryModal() {
    final pinController = TextEditingController();
    final serialController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: BrmsColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDAD6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 20,
                        color: Color(0xFF93000A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Admin Security',
                            style: BrmsTheme.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Reset Master Officer Access',
                            style: TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, size: 18),
                      color: BrmsColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrmsColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PRE-SEEDED TEST CREDENTIALS',
                            style: BrmsTheme.mono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: BrmsColors.secondary,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _usernameController.text = 'johnyrey';
                              _passwordController.text = 'admin123';
                              Navigator.of(ctx).pop();
                              showBrmsNotice(
                                context,
                                'Test credentials applied.',
                              );
                            },
                            child: const Text(
                              'Apply Credentials',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: BrmsColors.onSurface,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Username: johnyrey · Password: admin123 · Role: Campus Budget Officer',
                        style: BrmsTheme.mono(
                          fontSize: 11,
                          color: BrmsColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Station Admin Master PIN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  maxLength: 8,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••••',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: BrmsColors.outlineVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Local Auditor Serial (Printed on Campus Token)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: serialController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxWorkstationLength,
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: 'e.g. APARRI-AUD-2024-X',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: BrmsColors.outlineVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BrmsButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Verify & Restore Password',
                      onPressed: () {
                        _usernameController.text = 'johnyrey';
                        _passwordController.text = 'admin123';
                        Navigator.of(ctx).pop();
                        showBrmsNotice(
                          context,
                          'Master Verification Authenticated. Default password restored.',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrmsColors.background,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildWindowChromeBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: BrmsColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: BrmsColors.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrandHeader(),
                          const SizedBox(height: 16),
                          _buildCredentialsForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowChromeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: BrmsColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BrmsColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: BrmsColors.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(
              Icons.account_balance,
              size: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'CSU Aparri Budget Station',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BrmsColors.onSurface,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrmsColors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: BrmsColors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: BrmsColors.statusActiveDot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'OFFLINE STATION',
                  style: BrmsTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.remove, size: 16, color: BrmsColors.secondary),
          const SizedBox(width: 10),
          const Icon(
            Icons.check_box_outline_blank,
            size: 15,
            color: BrmsColors.secondary,
          ),
          const SizedBox(width: 10),
          const Icon(Icons.close, size: 16, color: BrmsColors.secondary),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: BrmsColors.surfaceContainer,
            shape: BoxShape.circle,
            border: Border.all(color: BrmsColors.outlineVariant),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: BrmsColors.primary,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CSU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'APARRI',
                  style: BrmsTheme.mono(
                    fontSize: 6.5,
                    color: const Color(0xFFCBD5E1),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'CAGAYAN STATE UNIVERSITY',
          textAlign: TextAlign.center,
          style: BrmsTheme.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'APARRI CAMPUS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: BrmsColors.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'BUDGET RESOURCE MONITORING SYSTEM (BRMS)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: BrmsColors.secondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialsForm() {
    return Form(
      key: _credentialsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Fiscal Officer ID / Username',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BrmsColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _usernameController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(BrmsInputLimits.maxAuthLength),
            ],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Username is required'
                : null,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.account_circle_outlined,
                size: 18,
                color: BrmsColors.secondary,
              ),
              hintText: 'Enter authorized username',
              filled: true,
              fillColor: BrmsColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: BrmsColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: BrmsColors.primary,
                  width: 1.4,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: BrmsColors.error,
                  width: 1.4,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: BrmsColors.error,
                  width: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Master Ledger Password',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openRecoveryModal,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BrmsColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            inputFormatters: [
              LengthLimitingTextInputFormatter(BrmsInputLimits.maxAuthLength),
            ],
            onFieldSubmitted: (_) => _submitCredentials(),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Password is required'
                : null,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 18,
                color: BrmsColors.secondary,
              ),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: BrmsColors.secondary,
                ),
              ),
              hintText: 'Enter password',
              filled: true,
              fillColor: BrmsColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: BrmsColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: BrmsColors.primary,
                  width: 1.4,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: BrmsColors.error,
                  width: 1.4,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: BrmsColors.error,
                  width: 1.6,
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberCredentials,
                activeColor: BrmsColors.primary,
                onChanged: (v) =>
                    setState(() => _rememberCredentials = v ?? true),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Remember credentials on this machine',
                style: TextStyle(
                  fontSize: 12,
                  color: BrmsColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 44,
            child: FilledButton.icon(
              onPressed: _submitCredentials,
              style: FilledButton.styleFrom(
                backgroundColor: BrmsColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.login, size: 18),
              label: const Text(
                'Sign In',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 15, color: BrmsColors.secondary),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Authorized for use by Cagayan State University Aparri Campus Budget Office only.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BrmsColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
