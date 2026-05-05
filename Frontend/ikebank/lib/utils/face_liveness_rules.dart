enum LivenessStep { lookLeft, lookRight, smile, blink, done }

bool shouldAdvanceLivenessStep(
  LivenessStep step, {
  required double headY,
  required double leftEyeOpen,
  required double rightEyeOpen,
  required double smileProbability,
  double yawThreshold = 12.0,
}) {
  switch (step) {
    case LivenessStep.lookLeft:
      return headY < -yawThreshold;
    case LivenessStep.lookRight:
      return headY > yawThreshold;
    case LivenessStep.smile:
      return smileProbability > 0.55;
    case LivenessStep.blink:
      return leftEyeOpen < 0.4 && rightEyeOpen < 0.4;
    case LivenessStep.done:
      return false;
  }
}

LivenessStep nextLivenessStep(LivenessStep step) {
  switch (step) {
    case LivenessStep.lookLeft:
      return LivenessStep.lookRight;
    case LivenessStep.lookRight:
      return LivenessStep.smile;
    case LivenessStep.smile:
      return LivenessStep.blink;
    case LivenessStep.blink:
      return LivenessStep.done;
    case LivenessStep.done:
      return LivenessStep.done;
  }
}

String livenessInstructionText(LivenessStep step) {
  switch (step) {
    case LivenessStep.lookLeft:
      return 'Hadap Kiri';
    case LivenessStep.lookRight:
      return 'Hadap Kanan';
    case LivenessStep.smile:
      return 'Senyum';
    case LivenessStep.blink:
      return 'Kedipkan Mata';
    case LivenessStep.done:
      return 'Verifikasi Selesai';
  }
}
