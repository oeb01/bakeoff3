# bakeoff3
A simple application that simulates text entry on a smartwatch. Since smartwatches are small, the application displays a 1 inch x 1 inch window for the text entry interface. Outside of the smartwatch window are displayed the target phrase to type (a short sentence like 'the world is a stage' or 'do not squander your time'), the current typed text, and a next button for when the user is done. Your mission is to implement text entry on a smartwatch as quickly and accurately as possible!

The user will only need to type the lowercase letters from 'a' to 'z' and ' ' (space). No capitalization or punctuation is required. Having a way to delete characters is not required, but is strongly recommended! Additionally, you are guaranteed that the target phrase will be a reasonable English sentence; the user is not trying to type gibberish.

The golden rule for this bakeoff is that all phrases must be equally accessible. In other words, you may not bias towards the target letter/word/phrase in any way. For example, highlighting the exact next letter to type is not allowed (as it should not be known by the interface).

Here are a few additional constraints:

- Your application will be tested on a laptop using a trackpad. Other means of input (keyboard, voice, etc) are not allowed.
- The text accuracy must be above 95%; occasional typos are fine, but should be rare.
- Your entire interface must be contained within the 1 inch x 1 inch window. Do not change or add anything outside of the window - leave the next button and displayed target phrase / typed text alone.
- Make sure your smartwatch window is actually 1 inch x 1 inch! This should be accomplished already by the Processing code, but double-check to make sure it's correct.
- Do not change the code that compares the target phrase to the typed text when the next button is clicked
