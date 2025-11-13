with Config;

package Sensor_Task is

   task Sensor_Controller is
      pragma Priority(Config.Priority_Sensor);
   end Sensor_Controller;

end Sensor_Task;
