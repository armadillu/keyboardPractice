
#include "testApp.h"
#import <Cocoa/Cocoa.h>

string kb[3] = {"qwertyuiop", "asdfghjkl","zxcvbnm,."};

void testApp::setup(){

	ofSetVerticalSync(true);
	ofEnableAlphaBlending();
	ofBackground(22);
	font.loadFont("CPMono_v07 Bold.otf", 55, true, true, true);
	fontSmall.loadFont("CPMono_v07 Light.otf", 19, true, true, true);

	NSStringEncoding encoding = NSISOLatin1StringEncoding;
	NSString * path = [NSString stringWithUTF8String: ofToDataPath("text.txt", true).c_str()];
	NSString * string = [NSString stringWithContentsOfFile:path encoding:encoding error:nil];

	string = [string stringByReplacingOccurrencesOfString:@", " withString:@",\n"];
	string = [string stringByReplacingOccurrencesOfString:@"; " withString:@";\n"];
	string = [string stringByReplacingOccurrencesOfString:@". " withString:@".\n"];
	NSArray * split = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
	for (NSString * t in split){
		NSString * clean = [t stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
		//NSLog(@"%@", clean);
		NSString *unaccentedString = [clean stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
		std::string s = std::string( [unaccentedString cStringUsingEncoding:encoding] );
		NSLog(@"<%@>", unaccentedString);
		if (s.size() > 1){
			sentences.push_back( s );
		}
	}

	mostTyped = mostMissed = 1;
	paragraphIndex = 0;
	nextSentence();

	ok.loadSound("keydown.wav");
	ko.loadSound("error.wav");
	ok.setVolume(0.5);
	ko.setVolume(0.5);

	timeLastOk = 0;
	ofSetFullscreen(true);
	ofHideCursor();
	ofEnableSmoothing();

	plot = new ofxHistoryPlot( NULL, "WPM", PLOT_SAMPLES, false); //NULL cos we don't want it to auto-update. confirmed by "true"
	plot->setLowerRange(0);
	plot->setColor( ofColor(64,128,64) );
	plot->setShowNumericalInfo(true);
	plot->setRespectBorders(true);
	plot->setLineWidth(2);
	plot->setBackgroundColor(ofColor(0,64));

	plot2 = new ofxHistoryPlot( NULL, "Accuracy", PLOT_SAMPLES, false); //NULL cos we don't want it to auto-update. confirmed by "true"
	plot2->setRange(0, 120);
	plot2->setColor( ofColor(128,64,64) );
	plot2->setShowNumericalInfo(true);
	plot2->setRespectBorders(true);
	plot2->setLineWidth(2);
	plot2->setBackgroundColor(ofColor(0,64));

	plotUpdateTime = 0;

	//fill in keyb
	for (int i = 0; i<3; i++) {
		for (int j = 0; j< kb[i].size(); j++) {
			char c = kb[i][j];
			missesSoFar[c] = 0;
			typedSoFar[c] = 0;
		}
	}
}

void testApp::nextSentence(){
	sentenceIndex = 0;
	whatToType = sentences[paragraphIndex];
	paragraphIndex++;
	if (paragraphIndex >= sentences.size()){
		paragraphIndex = 0;
	}
}


void testApp::update(){

	if (sentenceIndex >= whatToType.size()){
		nextSentence();
	}

	if (sentenceIndex > 1){
		plotUpdateTime += ofGetLastFrameTime();
		if (plotUpdateTime > PLOT_UPDATE_INTERVAL){
			plotUpdateTime = 0;
			plot->update(wpm);
			plot2->update(accuracy*100);
		}
	}

	float totalTime = 0;
	for(int i = 0; i < lastTimes.size(); i++){
		totalTime += lastTimes[i];
	}
	totalTime += ofGetElapsedTimef() - timeLastOk;
	wpm = (60. / (totalTime / (lastTimes.size() + 1))) / 5.0;

	float total = 0;
	for(int i = 0; i < lastTyped.size(); i++){
		float loopPct = (float)i / (lastTyped.size() - 1);
		if(lastTyped[i]) total++;
	}

	if (lastTyped.size() > 0){
		accuracy =  total / lastTyped.size() ;
	}

}


void testApp::draw(){

	BLUISH_COLOR;
	ofRect(0,0,ofGetWidth(), ofGetHeight() * 0.025);
	
	string sentence = whatToType;
	ofRectangle box = font.getStringBoundingBox(sentence, 0, 0);
	float targetW = ofGetWidth() * 0.7;
	if (box.width > targetW){
		float charW = box.width / (float)sentence.size();
		float times = box.width / targetW;

		for(int i = 0 ; i < times; i++){
			int offset = 0;
			int index = offset + i * targetW / charW;
			bool fixed = false;
			int c = 0;
			while (!fixed ) {
				if(index == 0) break;
				if (sentence[index] == ' '){
					fixed = true;
					sentence[index] = '\n';
					//sentence[index-1] = '*';
					offset += c;
				}
				index--;
				c++;
			}
		}
	}
	box = font.getStringBoundingBox(sentence, 0, 0);

	string typed = sentence ;
	string remaining = sentence;

	for(int i = 0; i < sentenceIndex; i++){
		if(remaining[i]!='\n') remaining[i] = ' ';
	}
	for(int i = sentenceIndex; i < whatToType.size(); i++){
		if(typed[i]!='\n') typed[i] = ' ';
	}

	string cursor = remaining;

	cursor[sentenceIndex] = '_';
	for(int i = sentenceIndex+1; i < sentence.size(); i++){
		if(cursor[i]!='\n') cursor[i] = ' ';
	}

	ofSetColor(233);
	font.drawStringAsShapes( remaining , ofGetWidth()/2 - box.width/2, ofGetHeight()/2 - box.height/2);
	ofSetColor(64);
	font.drawStringAsShapes( typed , ofGetWidth()/2 - box.width/2, ofGetHeight()/2 - box.height/2);
	BLUISH_COLOR;
	font.drawString(cursor, ofGetWidth()/2 - box.width/2, ofGetHeight()/2 - box.height/2 + 20);

//	string score = "accuracy: " + ofToString( accuracy * 100, 2 ) + "  wpm: " + ofToString(wpm);
//	ofRectangle rr = fontSmall.getStringBoundingBox(score, 0, 0);
//	fontSmall.drawString(score, 20,30);


	ofSetColor(128);

	fontSmall.setLetterSpacing(1.55);
	float h = 30;
	float off = 10;
	ofRectangle r = fontSmall.getStringBoundingBox("m",0,0);
	float charW = r.width + r.x + 2.9;
	float kbW = charW * kb[0].size();
	ofVec2f pos = ofVec2f(ofGetWidth()/2 - kbW * 0.5 ,ofGetHeight() - 3 * h);

//	for (int i = 0; i<3; i++) {
//		fontSmall.drawString(kb[i], pos.x + i * off, pos.y + i * h);
//	}

	ofSetColor(255,0,0);
	for (int i = 0; i<3; i++) {
		for (int j = 0; j< kb[i].size(); j++) {
			char c = kb[i][j];
			if (missesSoFar[c] > typedSoFar[c]){
				float a = 10 + 245 * ofClamp((float) missesSoFar[c] / mostMissed, 0,1);
				ofSetColor( ofColor( 255,32,32, a ) );
			}else{
				float a = 10 + 245 * ofClamp((float) typedSoFar[c] / mostTyped, 0,1);
				ofSetColor( ofColor( 32,255,32, a ) );
			}
			fontSmall.drawString( ofToString(c), pos.x + i * off + j * charW, pos.y + i * h);
		}
	}

	float gap = 40;
	plot->draw(0, ofGetHeight() - PLOT_H, ofGetWidth()/2 - gap - kbW / 2, PLOT_H);
	plot2->draw(ofGetWidth()/2 + kbW / 2 + gap, ofGetHeight() - PLOT_H , ofGetWidth()/2 - kbW / 2 - gap, PLOT_H);

}

void testApp::keyPressed(int key){

	if (key == 127){ //delete
		sentenceIndex--;
		if(sentenceIndex < 0) sentenceIndex = 0;
		return;
	}
	if (key=='*'){
		nextSentence();
		return;
	}
	
	char k = key;
	char expectedChar = tolower(whatToType[sentenceIndex]);

	if (k == whatToType[sentenceIndex]){
		if (sentenceIndex > 0){
			//averageTypeTime = 0.1 * (ofGetElapsedTimef() - timeLastOk) + 0.9 * (averageTypeTime);
			lastTimes.push_back(ofGetElapsedTimef() - timeLastOk);
			if (lastTimes.size() > WPM_HISTORY){
				lastTimes.erase(lastTimes.begin());
			}
		}
		sentenceIndex ++;
		ok.play();
		lastTyped.push_back(true);
		timeLastOk = ofGetElapsedTimef();
		typedSoFar[expectedChar] = typedSoFar[expectedChar] + 1;

		if (typedSoFar[expectedChar] > mostTyped){
			mostTyped = typedSoFar[expectedChar];
		}

	}else{
		if (sentenceIndex == 0 && k ==' '){ // hotfix for hansi's end of sentence punctuation mark space behavior
			ok.play();
			return;
		}

		ko.play();
		lastTyped.push_back(false);

		missesSoFar[expectedChar] = missesSoFar[expectedChar] + 1;
		if (missesSoFar[expectedChar] > mostMissed){
			mostMissed = missesSoFar[expectedChar];
		}
	}

	if (lastTyped.size() > ACCURACY_HOSTORY){
		lastTyped.erase(lastTyped.begin());
	}

}


void testApp::keyReleased(int key){

}


void testApp::mouseMoved(int x, int y){

}


void testApp::mouseDragged(int x, int y, int button){

}


void testApp::mousePressed(int x, int y, int button){

}


void testApp::mouseReleased(int x, int y, int button){

}


void testApp::windowResized(int w, int h){

}


void testApp::gotMessage(ofMessage msg){

}


void testApp::dragEvent(ofDragInfo dragInfo){ 

}