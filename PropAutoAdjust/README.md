# PropAutoAdjust

XLua script that will automatically adjust the prop lever based on power lever position.

More a proof of concept for PID controller implementation and an XLua scripting exercise than anything for daily, practical usage.

This script was developed with the freeware [vFlyteAir Ryan Navion 205](https://forums.x-plane.org/index.php?/files/file/48223-vflyteair-ryan-navion-205-vintage-freeware/) as a test subject.

For installation instructions and general notes, see the repository's [readme](https://github.com/JT8D-17/XLua-scripts-for-X-Plane/blob/main/README.md).

&nbsp;

## Notes

- Supports up to 8 engines
- You will see the prop lever or any other prop controls twitch when the script is active (also serves as an indicator that it's working!)
- Prop RPM will be automatically adjusted when the engine is running
- Lowering aircraft flaps will set the target RPM to the maximum specified (see next item)
- Maximum and minimum RPM range needs to be adjusted on a per-airplane basis   
(_"RPM_max"_ and _"RPM_min"_ variables)
- Prop lever adjustment range can be limited if needed   
(_"Prop_limits"_ table)
- Adjustment is achieved by means of a PID (proportional, integral, derivative) controller. Since X-Plane's RPM variables tend to fluction a bit, trying to tune it to perfection can be very difficult.  
(*"PID_time_step"*,*"P_gain"*,*"I_gain"*,*"D_gain"* variables)
- Debug output to the console/terminal can be enabled by setting *"Debug_Output"* to "true"

&nbsp;