
with MicroBit.Types; use MicroBit.Types;
with Config;

package Shared_Data is
   protected Sensor_Buffer is
      pragma Priority(Config.Priority_Buffer);
      procedure Set_Distances(Dist_Right : Distance_cm; Dist_Left : Distance_cm);
      procedure Get_Distances(Dist_Right : out Distance_cm; Dist_Left : out Distance_cm);
   private
      Distance_Right_Stored : Distance_cm := 0;
      Distance_Left_Stored  : Distance_cm := 0;
   end Sensor_Buffer;
end Shared_Data;
