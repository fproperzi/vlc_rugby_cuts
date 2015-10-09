VLC Rugby Cutter
================
Using VLC and HandBrake to cut rugby video

- Install VLC
- Copy clips.rugbycut.1.6.lua in VLC extensions directory

![RRcut.01.png]({{site.baseurl}}/RRcut.01.png)

- [Download Handbrake (command line version)](https://handbrake.fr/downloads2.php "HandBrake") and copy it to c:\

![RRcut.02.png]({{site.baseurl}}/RRcut.02.png)

- Open .lua with you text editor and read how about

![RRcut.03.png]({{site.baseurl}}/RRcut.03.png)

- Open VLC

![RRcut.04.png]({{site.baseurl}}/RRcut.04.png)

- Open the video match to cut. Please have a look to the name format of the video file: this is a match done 19 september 2015, Sandona versus Calvisano. I use the compact name "20150919 snd cal". Tre letters to identify the team like the score frame on television when you watch rugby matches  

![RRcut.05.png]({{site.baseurl}}/RRcut.05.png)

- Open the .lua extension from VLC

![RRcut.06.png]({{site.baseurl}}/RRcut.06.png)

- Here the input frame and the video toghether,sorry  i cant capture any image due the VLC-video-overlay. But in the black window there is the video

![RRcut.07.png]({{site.baseurl}}/RRcut.07.png)

- This is the input frame

![RRcut.09a.png]({{site.baseurl}}/RRcut.09a.png)

- in Italian, for my friends with English worse than mine

![RRcut.09.png]({{site.baseurl}}/RRcut.09.png)

- Somethings to check: the 3 letters TEAMS

![RRcut.10.png]({{site.baseurl}}/RRcut.10.png)

- 2 letters WHAT and the 12 field areas

![RRcut.11.png]({{site.baseurl}}/RRcut.11.png)

- HOW / RESULT

![RRcut.12.png]({{site.baseurl}}/RRcut.12.png)

- Here at the end of the video with all the cuts (tags) made in the VLC extension frame
 
![RRcut.13.png]({{site.baseurl}}/RRcut.13.png)

- Here, after the HandBrake transcode, the directory with all the clips

![RRcut.14.png]({{site.baseurl}}/RRcut.14.png)


Really this is a brutal piece of programming without any bell and twinkle but is useful. 

With VLC fast motion (+/-) the mouse will (change mouse option to control position) I cut a match in about 25 minutes. 
After I group several matches cutted in a directory and analize from the the same set piece and field area to find recursive patterns. 

If you want all the lineout drive from Munster, just filter in the directory  

"mun l?+d" 
- mun = munster
- l = lineout
- ? = any men 
- \+ = win
- d = drive

or "mun*d" ... quicker




