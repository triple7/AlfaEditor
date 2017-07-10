#include "leapVision.h"
#include <iostream>
#include <string.h>
#include "leapVisionBridge.h"
using namespace Leap;


// Two global values to set the position onto the paper
uint16_t PositionX;
uint16_t PositionY;
bool gestureFlag;

void SampleListener::onFrame(const Controller& controller) {
	// Get the current frame data from the controller
	const Frame frame = controller.frame();
	
	// Get a gesture list from the current frame to the previous default amount
	Leap::GestureList gestures = frame.gestures();

	// Check for gestures
	for (int gl = 0; gl < gestures.count(); gl++) {
		// Go through the gesture list and check if any gesture is valid
		Gesture gesture = gestures[gl];
			if (gesture.isValid()) {
				//process the gesture command
				gestureFlag = true;
				//std::cout << "Gesture" << std::endl;
				//std::cout << "x:" << PositionX << ",y:" << PositionY << std::endl;
			}
	}

	// Retrieve the finger object from the current frame
	FingerList fingers = frame.hands()[0].fingers();
	// Go through the list of fingers and find the pointer finger
	for (FingerList::const_iterator fl = fingers.begin(); fl != fingers.end(); fl++) {
		if ((*fl).type() == 1) {
			// Once you have the finger, retrieve the position of it, in x,y,z
			Leap::Bone bone = (*fl).bone(static_cast<Leap::Bone::Type>(3));
			Leap::Vector endPoint = bone.center();

			// Find the 3d positions projection onto the A4 paper
			float xProjection = endPoint[0] * paperToLensHeight / endPoint[1];
			float zProjection = endPoint[2] * paperToLensHeight / endPoint[1];
			
			// find the new coordinates, NOTE: This block and the block above is application specific
			uint16_t X = (uint16_t)zProjection + paperShort;
			uint16_t Y = (uint16_t)(-xProjection + paperLong);
			
			// if the found position is within the bound of the paper, set the global position to these values
			if (X > 0 && X < 210) {
				if (Y > 0 && Y < 297) {
					PositionX = X;
					PositionY = Y;
				}
			}
		}
	}
}

leapVision::leapVision()
{
	// the controller is already set up in the header file for leapVision
	// Set the controller Gesture settings, require tuning
	controller.config().setFloat("Gesture.KeyTap.MinDownVelocity", 20.0);
	controller.config().setFloat("Gesture.KeyTap.HistorySeconds", .2);
	controller.config().setFloat("Gesture.KeyTap.MinDistance", 1.0);
	controller.config().save();
	// Set the gesture to be enabled
	controller.enableGesture(Leap::Gesture::TYPE_KEY_TAP);

	// enable robust mode to attempt to remove ambient light and make tracking a little better,
	// WARNING: lowers the frame rate
	// controller.config().setBool("robust_mode_enabled", true);
	// controller.config().save();
	
	// add a listener to the controller
	controller.addListener(Listener);
	// Set the global values to 0,0 to start with
	PositionX = 0;
	PositionY = 0;
	gestureFlag = false;
}

leapVision::~leapVision()
{
	controller.removeListener(Listener);
}

uint16_t* leapVision::getPositions() {
	uint16_t* arr = new uint16_t[2];

	arr[0] = PositionX;
	arr[1] = PositionY;
	return arr;
}

bool leapVision::checkState() {
	if (gestureFlag) {
		gestureFlag = false;
		return true;
	}
	else {
		return false;
	}
}


// C functions to access the cpp data
const void * initClass(){
	leapVision *leap = new leapVision;
	return (void *)leap;
}

bool checkGestureFlag(const void *object) {
	leapVision *leap;
	leap = (leapVision *)object;
	return (*leap).checkState();
}

uint16_t* retrievePosition(const void *object) {
	leapVision *leap;
	leap = (leapVision *)object;
	return (*leap).getPositions();
}