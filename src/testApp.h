#pragma once

#define WPM_HISTORY				20.0
#define ACCURACY_HOSTORY		100.0
#define PLOT_UPDATE_INTERVAL	.1
#define PLOT_SAMPLES			800
#define PLOT_H					( ofGetHeight() * 0.12 )
#define BLUISH_COLOR			(ofSetColor(64, 128, 128) )
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
	map<char,int> missesSoFar;
	map<char,int> typedSoFar;
	int mostMissed, mostTyped;

	ofxHistoryPlot * plot;
	ofxHistoryPlot * plot2;
	int wpm;
	float accuracy;
};
