with Config;

package Sensor_Task is

   -- Sensor task har høyere prioritet enn Logic task (Rate Monotonic)
   -- Periode: 120ms (litt over WCRT på 118ms for å ha margin)
   task Sensor_Controller is
      pragma Priority(Config.Priority_Sensor);  -- Høy prioritet
   end Sensor_Controller;

end Sensor_Task;
