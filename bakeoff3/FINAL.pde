import java.util.Arrays;
import java.util.Collections;
import java.util.Random;
import java.util.Map;

HashMap<Character, HashMap<Character, Character>> trigrams = new HashMap<Character, HashMap<Character, Character>>();
HashMap<Character, Character> bigrams = new HashMap<Character, Character>();
String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 127; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

char deleteLetter = 'a';
char prevLetter = '_';
char pprevLetter = '_';
//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';
boolean vowel = true;
char[] chars = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
int i = 0;

int[] pos = new int[2];
float[] sizes = new float[2];

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  String[] triGrams = loadStrings("count_3l.txt");
  String[] biGrams = loadStrings("count_2l.txt");
  
  for(String b: triGrams){
    b = b.replaceAll("\\s", "");
    Character c1 = b.charAt(0);
    Character c2 = b.charAt(1);
    Character c3 = b.charAt(2);
   
    //if the first letter is not in the trigram hashMap
    if(!trigrams.containsKey(c1)){
      HashMap<Character, Character> tri = new HashMap<Character, Character>();
      //create a map for second letters and insert the second and third letters
      tri.put(c2, c3);
      trigrams.put(c1, tri);
    }else{
      HashMap<Character, Character> first = trigrams.get(c1);
      //check if there is a more frequent occuring pair of second and third letters
      if(!first.containsKey(c2)){
        first.put(c2, c3);
      }
    }
  }
  
  for(String b: biGrams){
    b = b.replaceAll("\\s", "");
    Character c1 = b.charAt(0);
    Character c2 = b.charAt(1);
   
    //if the first letter is not in the trigram hashMap
    if(!bigrams.containsKey(c1)){
      bigrams.put(c1, c2);
    }
  }
 
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  noStroke(); //my code doesn't use any strokes
  PFont courier = createFont("Courier", 16);
  textFont(courier);
  pos[0] = width/2;
  pos[1] = height/2 + int(sizeOfInputArea / 6);
  sizes[0] = sizeOfInputArea/4;
  sizes[1] = sizeOfInputArea /3;
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{

  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    fill(200);
    rect(width/2-sizeOfInputArea/2 + 5, height/2 - 2, sizeOfInputArea/2 - 10, 20);
    rect(width/2 + 5, height/2 - 2, sizeOfInputArea/2 - 10, 20);
    fill(0);
    textAlign(CENTER);
    textSize(10);
    text("space", width/2 - sizeOfInputArea/4, height/2 +14);
    text("delete", width/2 + sizeOfInputArea/4, height/2 +14);

    textSize(20);
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

    //my draw code
    fill(255, 0, 0); //red button
    rect(pos[0]-sizeOfInputArea/2, pos[1], sizes[0], sizes[1]); //draw 5 back
    fill(200, 0, 0); 
    rect(pos[0]-sizeOfInputArea/4, pos[1], sizes[0], sizes[1]); //draw 1 back
    fill(0, 200, 0);
    rect(pos[0], pos[1], sizes[0], sizes[1]); //draw 1 forward
    fill(0, 255, 0); //green button
    rect(pos[0]+sizeOfInputArea/4, pos[1], sizes[0], sizes[1]); //draw 5 forward
    
    stroke(200);
    line(width/2-sizeOfInputArea/2, height/2 - 5, width/2+sizeOfInputArea/2, height/2 - 5);
    noStroke();
    
    textAlign(CENTER);
    fill(200);
       
    String s;

    s = String.format("%s %s %s  %s %s %s", getLetter(-3),
                         getLetter(-2), getLetter(-1), getLetter(1),
                         getLetter(2), getLetter(3));

    textSize(15);
    text(s, width/2, height/2-sizeOfInputArea/4 + 13); //draw surrounding
    textSize(20);
    fill(255);
    text(currentLetter, width/2, height/2-sizeOfInputArea/4 - 10); //draw current letter
  }
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

char getLetter(int offset)
{
  if (currentLetter + offset > 'z')
    return (char)(currentLetter - 26 + offset);
   else if (currentLetter + offset < 'a')
     return (char)(currentLetter + 26 + offset);
   else
     return (char)(currentLetter + offset);
}
  

//my terrible implementation you can entirely replace
void mousePressed()
{
  //if (didMouseClick(width/2-60, height/2-2, 20, 20)) {
  //  vowel = !vowel;
  //}

  if (didMouseClick(width/2-sizeOfInputArea/2 + 5, height/2-2, sizeOfInputArea/2 - 10, 20)) {
    currentTyped+=" ";
    deleteLetter = pprevLetter;
    pprevLetter = '_';
    prevLetter = '_';
  }

  if (didMouseClick(width/2 + 5, height/2 - 2, sizeOfInputArea/2 - 10, 20) && currentTyped.length() > 0) {
    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    prevLetter = pprevLetter;
    pprevLetter = deleteLetter;
    if(pprevLetter == '_' || prevLetter == '_'){
      currentLetter = 'e';
    }else{
      currentLetter = trigrams.get(pprevLetter).get(prevLetter);
    }
  }

  if (didMouseClick(pos[0]-sizeOfInputArea/2, pos[1], sizes[0], sizes[1])) //check if click in left 5
  {
    if (currentLetter - 3 < 'a') 
      currentLetter += 26;
    currentLetter -= 3;
  }

  if (didMouseClick(pos[0]-sizeOfInputArea/4, pos[1], sizes[0], sizes[1])) //check if click in left 1
  {
    if (currentLetter - 1 < 'a') 
      currentLetter += 26;
    currentLetter -= 1;
  }

  if (didMouseClick(pos[0], pos[1], sizes[0], sizes[1])) //check if click in right 1
  {
    if (currentLetter + 1 > 'z') 
      currentLetter -= 26;
    currentLetter += 1;
  }
  
  if (didMouseClick(pos[0]+sizeOfInputArea/4, pos[1], sizes[0], sizes[1])) //check if click in right 5
  {
    if (currentLetter + 3 > 'z') 
      currentLetter -= 26;
    currentLetter += 3;
  }

  // set currentLetter
  
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/2 - 3)) //check if click occured in letter area
  {
      currentTyped+=currentLetter;
      deleteLetter = pprevLetter;
    pprevLetter = prevLetter;
    prevLetter = currentLetter;
    
    if(prevLetter == '_'){
      currentLetter = 'e';
    }else if(pprevLetter == '_'){
      currentLetter = bigrams.get(prevLetter);
    }else{
      currentLetter = trigrams.get(pprevLetter).get(prevLetter);
    }
  }

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}





//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
