#pragma once

#ifndef leapVisionBridge_h
#define leapVisionBridge_h

#ifdef __cplusplus
extern "C" {
#endif
	const void * initClass();
	bool checkGestureFlag(const void *object);
	uint16_t* retrievePosition(const void *object);

#ifdef __cplusplus
}
#endif

#endif // !leapVisionBridge_h


