with Microbit.Types; use Microbit.Types;

package Sensors is

procedure sensor_control_setup;

procedure Trig_left;
procedure Trig_right;

function Left_Distance return Distance_cm;
function Right_Distance return Distance_cm;

end Sensors;
