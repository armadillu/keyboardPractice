#pragma once

#define WPM_HISTORY				20.0
#define ACCURACY_HOSTORY		100.0
#define PLOT_UPDATE_INTERVAL	.1
#define PLOT_SAMPLES			800
#import "ofMain.h"
#include "ofxHistoryPlot.h"


class testApp : public ofBaseApp{
	public:
		void setup();
		void update();
		void draw();
		
		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y);
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);


		void nextSentence();

		ofTrueTypeFont font, fontSmall;

		vector<string>sentences;
		string whatToType;
		int paragraphIndex;
		int sentenceIndex;


	ofSoundPlayer ok;
	ofSoundPlayer ko;

	//int numOK, numKO;
	float timeLastOk;
	float averageTypeTime;
	vector<float> lastTimes;
	vector<bool> lastTyped;
	float plotUpdateTime;

	ofxHistoryPlot * plot;
	ofxHistoryPlot * plot2;
	ofxHistoryPlot * plot3;
	int wpm;
	float accuracy;
};
