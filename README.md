arduano
=======

A free and open source chronometer for motorcycles.


Inspired by Alfano (tm) chronos, Arduano display the current chrono, best lap, difference with last lap and total lap traveled.

At startup, Arduano is stuck in the standByMode (currentChrono = 0).
When driver push the main button, standByMode is set to false and the currentChrono is calculated by millis().

A second button (called standByModeButton) is used to set back to standByMode tu true when the session finished.


Here's a little video demonstrate how the Arduano work : http://www.youtube.com/watch?v=WIH_s1cBXII 
(with some graphic bugs that should corrected soon)