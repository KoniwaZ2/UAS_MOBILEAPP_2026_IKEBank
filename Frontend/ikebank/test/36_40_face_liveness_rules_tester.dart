import 'package:flutter_test/flutter_test.dart';
import 'package:ikebank/utils/face_liveness_rules.dart';

void main() {
  test('36 - left yaw advances on threshold', () {
    expect(
      shouldAdvanceLivenessStep(
        LivenessStep.lookLeft,
        headY: -13,
        leftEyeOpen: 1,
        rightEyeOpen: 1,
        smileProbability: 0,
      ),
      isTrue,
    );
    expect(nextLivenessStep(LivenessStep.lookLeft), LivenessStep.lookRight);
  });

  test('37 - right yaw advances on threshold', () {
    expect(
      shouldAdvanceLivenessStep(
        LivenessStep.lookRight,
        headY: 13,
        leftEyeOpen: 1,
        rightEyeOpen: 1,
        smileProbability: 0,
      ),
      isTrue,
    );
    expect(nextLivenessStep(LivenessStep.lookRight), LivenessStep.smile);
  });

  test('38 - smile step requires probability', () {
    expect(
      shouldAdvanceLivenessStep(
        LivenessStep.smile,
        headY: 0,
        leftEyeOpen: 1,
        rightEyeOpen: 1,
        smileProbability: 0.6,
      ),
      isTrue,
    );
    expect(nextLivenessStep(LivenessStep.smile), LivenessStep.blink);
  });

  test('39 - blink step requires both eyes closed', () {
    expect(
      shouldAdvanceLivenessStep(
        LivenessStep.blink,
        headY: 0,
        leftEyeOpen: 0.2,
        rightEyeOpen: 0.2,
        smileProbability: 0,
      ),
      isTrue,
    );
    expect(nextLivenessStep(LivenessStep.blink), LivenessStep.done);
  });

  test('40 - done step does not advance again', () {
    expect(
      shouldAdvanceLivenessStep(
        LivenessStep.done,
        headY: 0,
        leftEyeOpen: 1,
        rightEyeOpen: 1,
        smileProbability: 0,
      ),
      isFalse,
    );
    expect(nextLivenessStep(LivenessStep.done), LivenessStep.done);
    expect(livenessInstructionText(LivenessStep.done), 'Verifikasi Selesai');
  });
}
