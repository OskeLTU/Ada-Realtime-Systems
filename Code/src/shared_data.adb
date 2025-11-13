


package body Shared_Data is
   protected body Sensor_Buffer is
      procedure Set_Distances(Dist_Right : Distance_cm; Dist_Left : Distance_cm) is
      begin
         Distance_Right_Stored := Dist_Right;
         Distance_Left_Stored  := Dist_Left;
      end Set_Distances;

      procedure Get_Distances(Dist_Right : out Distance_cm; Dist_Left : out Distance_cm) is
      begin
         Dist_Right := Distance_Right_Stored;
         Dist_Left  := Distance_Left_Stored;
      end Get_Distances;
   end Sensor_Buffer;
end Shared_Data;


