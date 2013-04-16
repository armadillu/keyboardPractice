
#import "testApp.h"
#import "ofAppGlutWindow.h"

//--------------------------------------------------------------
int main(){
	ofAppGlutWindow window; // create a window
	window.setGlutDisplayString("rgba double samples>=12 depth");

	// set width, height, mode (OF_WINDOW or OF_FULLSCREEN)
	ofSetupOpenGL(&window, 1024, 768, OF_WINDOW);
	ofRunApp(new testApp()); // start the app
}
