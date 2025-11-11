with Config;

package Logic_Task is

   task Logic_Controller is
      pragma Priority(Config.Priority_Logic);
   end Logic_Controller;

end Logic_Task;
