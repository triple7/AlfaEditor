#pragma once

#include "Leap.h"
using namespace Leap;

class SampleListener : public Listener {
public:
	virtual void onFrame(const Controller&);
private:
	int paperToLensHeight = 222;
	float paperLong  = 148.5;
	uint16_t paperShort = 105;
};

class leapVision
{
public:
	leapVision();
	virtual ~leapVision();
	uint16_t* leapVision::getPositions();
	bool leapVision::checkState();
private:
	Leap::Controller controller;
	SampleListener	Listener;

};

