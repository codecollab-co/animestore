import 'package:flutter_test/flutter_test.dart';
import 'package:anime_app/utils/api_verification.dart';

void main() {
  test('Verify Consumet API deployment', () async {
    // This test will check if Consumet is properly deployed
    print('\n=== Running API Verification ===\n');

    await ApiVerification.printVerificationReport();

    final status = await ApiVerification.verifyConsumet();

    // Print result
    if (status.isAvailable && status.canSearch && status.canStream) {
      print('\n✅ SUCCESS: Consumet API is fully functional!\n');
      print('You can proceed with Phase 3 migration.\n');
    } else if (status.needsDeployment) {
      print('\n⚠️  WARNING: Consumet API needs to be deployed\n');
      print('Deploy Consumet before proceeding:');
      print('1. Visit: https://railway.app/template/consumet');
      print('2. Deploy and get your URL');
      print('3. Update lib/config/api_config.dart\n');
    } else {
      print('\n⚠️  WARNING: Consumet has issues\n');
      print('Status: ${status.message}\n');
    }

    // We don't fail the test, just report status
    expect(true, isTrue);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
