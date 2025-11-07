

with Microbit.Types;    use Microbit.Types;
with Microbit;          use Microbit;
with nRF.GPIO;          use nRF.GPIO;       -- <-- This fixes "GPIO_Pin" is undefined
with Ada.Real_Time;     use Ada.Real_Time;  -- <-- This is needed for Clock, Time_Span, and To_Microseconds
with HAL;               use HAL;


package body Sensors is

Trigger_left_pin : GPIO_Point := MB_P14;
Trigger_right_pin : GPIO_Point := MB_P16;
Echo_left_pin    : GPIO_Point := MB_P13;
Echo_right_pin   : GPIO_Point := MB_P15;

protected sensor_values is

   procedure Timer_start_left;
   procedure Timer_start_right;
   procedure Timer_stop_left;
   procedure Timer_stop_right;


   function Left_Distance return Distance_cm;
   function Right_Distance return Distance_cm;

private
   Left_value, Right_value : Distance_cm := 0.0;
   Left_timer_start        : Time := Clock;
   Right_timer_start       : Time := Clock;

end sensor_values;

protected body sensor_values is

   procedure Timer_start_left is
   begin
      Left_timer_start := Clock;
   end Timer_start_left;

   procedure Timer_stop_left is
   Duration : Time_Span;
   begin
      Duration := Clock - Left_timer_start;
      Left_value := Distance_cm(Float(Milliseconds(Duration))* 0.343/2.0);
   end Timer_stop_left;

   procedure Timer_start_right is
   begin
      Right_timer_start := Clock;
   end Timer_start_right;

   procedure Timer_stop_right is
   Duration : Time_Span;
   begin
      Duration := Clock - Right_timer_start;
      Right_value := Distance_cm(Float(Milliseconds(Duration))* 0.343/2.0);
   end Timer_stop_right;

   function Left_Distance return Distance_cm is
   begin
      return Left_value;
   end Left_Distance;

   function Right_Distance return Distance_cm is
   begin
      return Right_value;
   end Right_Distance;

end sensor_values;

procedure sensor_control_setup is

   Output_Config : constant GPIO_Configuration :=
      (Mode         => Mode_Out,            -- Pin is used to send the trigger pulse
         Resistors    => No_Pull,             -- No pull-up/pull-down needed for output
         Input_Buffer => Input_Buffer_Disconnect, -- Disconnect buffer to save power
         Drive        => Drive_S0S1,
         Sense        => Sense_Disabled);

   Input_Config : constant GPIO_Configuration :=
      (Mode         => Mode_In,             -- Pin is used to read the echo pulse
         Resistors    => Pull_Down,           -- Use pull-down to ensure stable low state when not driven
         Input_Buffer => Input_Buffer_Connect,   -- Connect buffer to read input
         Drive        => Drive_S0S1,
         Sense        => Sense_Disabled);

begin

Trigger_left_pin.Configure_IO(Output_Config);
Trigger_right_pin.Configure_IO(Output_Config);

Echo_left_pin.Configure_IO(Input_Config);
Echo_right_pin.Configure_IO(Input_Config);

Clear (Trigger_left_pin);
Clear (Trigger_right_pin);

pragma Attach_Handler(Echo_left_pin, Rising_Edge, sensor_values.Timer_start_left'Access);
pragma Attach_Handler(Echo_left_pin, Falling_Edge, sensor_values.Timer_stop_left'Access);
pragma Attach_Handler(Echo_right_pin, Rising_Edge, sensor_values.Timer_start_right'Access);
pragma Attach_Handler(Echo_right_pin, Falling_Edge, sensor_values.Timer_stop_right'Access);

delay 0.1;

end sensor_control_setup;

procedure Trig_left is
begin
   Trigger_left_pin.Set;
   delay 0.00001;
   Trigger_left_pin.Clear;
end Trig_left;

procedure Trig_right is
begin
   Trigger_right_pin.Set;
   delay 0.00001;
   Trigger_right_pin.Clear;
end Trig_right;

function Left_Distance return Distance_cm is
begin
   Trig_left;
   delay 0.05;
   return sensor_values.Left_Distance;
end Left_Distance;

function Right_Distance return Distance_cm is
begin
   Trig_right;
   delay 0.05;
   return sensor_values.Right_Distance;
end Right_Distance;

end Sensors;


