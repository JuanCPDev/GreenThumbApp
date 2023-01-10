String loademojis(int moistureLevel) {
  if (moistureLevel > 800) {
    return "💧";
  } else if (moistureLevel > 600) {
    return "💧💧";
  } else if (moistureLevel > 500) {
    return "💧💧💧";
  } else if (moistureLevel > 400) {
    return "💧💧💧";
  } else {
    return moistureLevel.toString();
  }
}