arduano
=======

A free and open source chronometer for motorcycles.


Inspired by Alfano (tm) chronos, Arduano display the current chrono, best lap, difference with last lap and total lap traveled.

At startup, Arduano is stuck in the standByMode (currentChrono = 0).
When driver push the main button, standByMode is set to false and the currentChrono is calculated by millis().
