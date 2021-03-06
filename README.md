# Guidance and Path Planning of a Parallel Robot without Visual Feedback
Research project of a spherical robot rolling on a smooth surface and bouncing off walls.
## Abstract
Optimal path planning and design is a fundamental and deep question in many areas of science and engineering. Here, we explore a bumper-car feedback approach to path planning and design. We describe the kinematics of a model parallel robot having contact with the surface and develop a path planning strategy guided by the robot bumping into the walls. Using a Snell's law model for reflection from the wall, a model for the local curvature (derivable from the tangent space) of the wall is developed, and the robot is guided by feedback. Such a model would be important in guiding a rescue robot through a circuitous dust filled mine shaft, where visibility/sensor feedback is not an option. This design is coded in Matlab and simulations are run to show the resulting dynamics. The effect of robot geometries on the path design is investigated.
## Code
The main code is "Robotics.m". An example of parameters to use is located in the file "NiceParameters.txt". The file "Description.pdf" provides further comments on the code while the accompanying paper "Paper.pdf" focuses on the results from our research and the mathematics behind the program.
## Collaborators
| First name | Last name |
| ---- | -------- |
| Thomas | Rochais |
| Courtney | Sheyko |
| Farhad | Jafari |

