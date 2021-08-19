enum SERVO {
  THROTTLE,
  LEFT_WING,
  RIGHT_WING,
  RUDDER,
  ELEVATOR,
}
const int MIN_SERVO_STEP = 1;
const int WING_POS_MIN = 20;
const int WING_POS_MAX = 160;
const int ROLL_TRIM = 10;
const int ROLL_RUDDER_TRIM = 10;
const int FLAP_TRIM = 70;
const int RUDDER_POS_MIN = 10;
const int RUDDER_POS_MAX = 170;
const int ELEVATOR_POS_MIN = 10;
const int ELEVATOR_POS_MAX = 170;
const int PITCH_TRIM = 10;
const int THROTTLE_TRIM = 20;
const int THROTTLE_MIN = 0;
const int THROTTLE_MAX = 180;
const int CRUISE_THROTTLE = 160;
