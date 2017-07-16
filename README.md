# AlfaEditor
Leap motion projective spatial understanding for adding sound and context dimensions to tactile prints for the blind

Oseyeris Pty ltd. provides the source code free of charge and does not make any profit from it's research projects. We would appreciate it however, if we are mentioned if you choose to further add features and produce something really cool from our base code. 

1-Introduction 

Blind students around the world do not have adequate access to material for the STEM (Science Technology Engineering and Mathematics) subjects, which either makes it extremely difficult or too intimidating to take.

This impacts on the skills acquired by those who do have the heroism of challenging themselves to a very steep set of materials, where 60% of the time is spent chasing for accessible content, often shifting the availability of the content by 2 to 3 weeks, and often making it very frustrating for the student, no matter his/her degree of motivation to complete a chosen course.

This open source project aims to provide tactile and sound based feedback for various materials as per below:
-diagrams
-graphs
-maps
-matrices
-flow charts
-etc

2-The method

Using Apple's SceneKit framework, AlfaEditor provides a 3D world connected to the leap motion (see https://www.leapmotion.com) to project an image on the platform to an object within the volumetric boundary captured by the leap motion.

Objects are imported from .svg (Simple Vector graphic) files and placed as a flat plane in the 3D world, associated to tags and descriptors which can be pulled out from the editor (not complete) and identified in a A4 page dimension laid on a flat surface or above the leap motion.

3-Future developement

-Complete the editing modes for imported scenes to attach HTML tags and provide further information by loading an NSWebView when tapping on an object
-Use Convolution Neural Networks and QRCodes printed directly on the physical object to provide freedom of rotation. Currently the A4 is placed in a bounding pedestal which holds the leap motion downwards. However, the Infrared has difficulties picking up certain objects when faced against reflective materials.
-Create more interesting use cases such as 3D point source sounds for when exploring a map

4-Installation/build

You need X-code 8.x to run the project. If you don't have an apple developer account, you can go to developer.apple.com and create a free account but I assume you have one and will not go into further detail on how to get an account.

You also need a working leap motion to interact with the world space. They are affordable and a lot of fun if you like tinkering with electronics.

Make sure to extract regulus.zip into your dropbox folder as it will contain all the demo .svg files which can be viewed in the editor by pressing enter in the system tab. A sound will let you know whether your leap motion is connected or when your hand enters the interactive space or leaves it, or when your application enters the background.

5-The simple sampler demo

The interface loads up the "mpc" file located in regulus/ and its associated sound files in /regulus/sounds/mpc/. You can check the pad on which your finger is located and tap. This will create a one-shot sample sound for each of the 9 pads.

As I or others add more features, we will be able to locate objects in 3D and assign them behaviors, 3D positional sounds and other cool stuff, such as chess boards, interactive and 3D physical maps and even adventure games using 3D printed worlds, such as that of Secret of Monkey island.
 
The source code is available free of charge, but some accreditation to oseyeris or Yuma Antoine Decaux is always very well appreciated.
