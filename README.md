# Amon-Ra
by Ivan Isakov
2020 January

***** AMON RA, a VJ controller in a shape of a pyramid created using Arduino, Processing and 3D-printing. *****

Once at a party I saw a guy turning knobs and creating some cool visuals, so decided to make the same from scratch.
Usually people use MIDI-controllers, but I have created something much simpler.

I had Arduino and 4 old potentiometers, so decided to use those.
In the end, it's a UART-interface based on Arduino, and uses Processing to create and control visuals. 
I hate rectangles, so designed and 3D-printed a pyramid and put those knobs on the sides.

- Potentiometers connected to four ADCs.
- Arduino sends the stream of four 12-bit values (0 - 1024) from four ADC
- Processing picks up those values and creates magic.
- Currently, there are 9 different visual modes. All abstract cubes, triangles and circles, all moving and rotating.
- Knobs control their size, speed, transparency etc.
- Keyboard keys and mouse control some of the parameters too.
- You can record some movements of the knobs and leave it on the loop, while you go to the loo. Very handy
- Recently I have added a possibility to overlay the modes on one screen. Still working on it, but it's already gives some nice visuals

