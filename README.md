This project has been improved and finalized in the following paper:

Brown JW, Caetano-Anollés D, Catanho M, Gribkova E, Ryckman N, Tian K, Voloshin M, Gillette R. (2017). Implementing Goal-Directed Foraging Decisions of a Simpler Nervous System in Simulation. eNeuro eN-NWR-0400-17.2018. [DOI: 10.1523/ENEURO.0400-17.2018.](http://www.eneuro.org/content/5/1/ENEURO.0400-17.2018)

# CONTENTS

* [**I. PLEUROBRANCHAEA BEHAVIOR SIMULATION**](#anchor-1)
* [**II. CHARACTERS IN THE MODEL**](#anchor-2)
  * A. Pleurobranchaea
  * B. Hermisenda
  * C. Flabellina
  * D. Faux-Hermisenda
* [**III. HOW DOES IT WORK?**](#anchor-3)
  * A. Orientation
  * B. Predation and Learning
  * C. Conspecific Behavior and Mating
* [**IV. HOW TO USE IT**](#anchor-4)
  * A. Adjust the Set-Up Controls
  * B. Start the Simulation
  * C. Observe and Interact
  * D. Follow Data Plots
* [**V. THINGS TO NOTICE**](#anchor-5)
* [**VI. THINGS TO TRY**](#anchor-6)
* [**VII. LOADING THIS APPLET ONTO YOUR WEBPAGE**](#anchor-7)
* [**VIII. ANEMONE SCRIPT**](#anchor-8)
* [**IX. CREDITS AND REFERENCES**](#anchor-9)
* [**X. AUTHOR NOTES**](#anchor-10)





- - -





<a id="anchor-1"></a>

# I. PLEUROBRANCHAEA BEHAVIOR SIMULATION

This NetLogo model simulates the predation, orientation, and mating behavior of the *Pleurobranchaea* sea slug.

![Cyblerslug simulation being run.](https://github.com/derekca/cyberslug/blob/master/img_simulation.png)





<a id="anchor-2"></a>

# II. CHARACTERS IN THE MODEL

- **PLEUROBRANCHAEA** - Brown sea slug. *Solitary cannibalistic sea slugs that are trying to learn what to eat.*

- **HERMISENDA** - Green orbs. *Pleurobranchaea loves eating these tastly sea slugs.*

- **FLABELLINA** Red orbs. *These little sea slugs do not taste all that good to Pleurobranchaea, so it learns to avoid the odor (unless it's really hungry).*

- **FAUX-HERMISENDA** Green orbs with red odor. *After being preyed upon by Pleurobranchaea populations for many generations, this particular Hermisenda sub-species has developed a mechanism through Batesian Mimicry to mimic the odor of the toxic flabellina. If pleurobranchaea decides to eat a faux-individual, it may be more inclined to eat others of the same odor in the future.*





<a id="anchor-3"></a>

# III. HOW DOES IT WORK?

Each slug follows a set of simple rules to guide its behavior, described below.

## A. Orientation

1. Slugs initially orient themselves towards betaine (a chemical produced by all marine life). However, as the slugs learn to associate odors of specific animals with pleasure/pain through their "feeding-network", they will orient towards/away based on scent.

2. If the appetence (craving) of a slug is greater than its nociception (pain), then it will orient towards a scent (and vice-versa - it will orient away from a scent in the opposite scenario). In addition, the stronger (closer) a scent is, the greater the angle at which it orients.

3. If a slug encounters another slug that is larger than it (ie. the conspecific slug produces a more concentrated layer of aversive factor on its skin than the subject slug, due to its size) it will orient away from the predator and speed up slightly to escape.


## B. Predation and Learning

1. Hermisenda taste good to slugs, and so they are preferable over other food.

2. Flabellina produce a painful toxin. Therefore, when a slug bites a flabellina, it will spit it out before orienting away. However, pleurobranchaea are known to bite the same flabellina multiple times until they learn not to. This behavior can be seen by viewing the following video.

<a href="https://www.youtube.com/watch?v=rg2UrAnXgdo" target="_blank"><img src="http://img.youtube.com/vi/rg2UrAnXgdo/0.jpg" 
alt="SEA SLUG EATING FLABELLINA" width="480" height="360" border="10" /></a>

3. Appetance and nociception values are filtered into the slug's feeding-network neurons, where it will decide how to proceed towards a scent based on previous encounters. The hungrier a slug is, the more likely it is to bite a toxic animal.

4. Pleurobranchaea cannot tell the difference between small conspecific slugs and food, because small slugs produce a concentration of aversive factor that is less than the concentration that they themselves produce.

5. After eating something, a pleurobranchaea will slow down and digest its food, growing larger in the process.

6. It should be noted that, after a food item (excluding other slugs) is eaten in the simulation, a new individual will appear at a random location to take its place, maintaining the same population levels of prey.


## C. Conspecific Behavior and Mating

1. When slugs reach a certain size (in this simulation, it is 7 size-units large), they will orient towards conspecific slugs of similar size to initiate mating. Both slugs (hermaphrodites) will exchange genetic material and lay eggs (and decrease in size in the process).

2. Eggs will hatch into slug larvae, which will float around the environment eating small food material, eventually growing into small slugs after a short time. However, not all larvae make it to be full slugs. Note that in this simulation, only a handful of offspring are produced, but in reality slugs produce several hundred offspring per season. Naturally, this simulation is too crowded to sustain that many digital offspring.





<a id="anchor-4"></a>

# IV. HOW TO USE IT

Use the buttons, sliders, and toggles to interact with the simulation. Some buttons can be activated by hitting the keyboard with the shortcut-letter indicated on the top-right corner of the button.

## A. Adjust the Set-Up Controls

- **PLEURO-POP, HERMI-POP, FLAB-POP, FAUX-POP**: Change the starting populations of pleurobranchaea slugs, hermisenda, flabellina, and faux-hermisenda. Note that setting population levels very high may slow down the simulation (especially if 'Effects' are enabled).

- **GROWTH**: Enable the ability of pleurobranchaea to grow larger by eating food, to mate with other slugs, and to die of old age. You may consider disabling this feature to prevent the subject slug from dying in the middle of the experiment, halting its data collection. This toggle can be enabled and disabled in the middle of a simulation.

- **EFFECTS**: Enable particulates to float in the water. Particulates do not interact with this version of the simulation in any way, and are only a visual effect designed to be aesthetically pleasing. Disable this feature if using a slower processor, as it will slow down the simulation.

## B. Start the Simulation

- **SETUP**: Resets the simulation, using the current Set-Up Control settings.

- **GO**: Starts and stops the model.

- **STEP**: Starts the model and stops automatically stops it after one 'tick'. A short-term version of 'Go'.

## C. Observe and Interact

- **CLICK-INTERACTION**: Set the action that will occur by the user clicking/dragging on the simulation environment. Actions including dragging food or slugs around, placing slug eggs, increasing a particular slug's size, killing a particular slug, and spraying certain odors into the environment to see how a slug will react.

- **REMOVE FOOD**: Remove all flabellina, hermisenda, and faux-hermisenda individuals from the simulation. Place them back with the 'Reset Food' button. Use this feature along with the odor-placement placement option in the 'Click-Interaction' menu to see how a slug will react to a certain odor after being conditioned.

- **RESET FOOD**: Negate the effects of the 'Remove Food' button and place all food-items back into the simulation.

- **SHOW SIZE**: Allow each slug to display its relative size.

- **SHOW SENSORS**: Allow each slug to color-code the area around itself with the location of its oral-veil sensors and chemosensors. Oral veil sensors are colored yellow, and chemosensors are colored red and blue, circling the slug at NE, SE, SW, and NW positions.

- **FOLLOW, PATHS ON**: Follow a random slug (can be clicked multiple times), and allow slugs to drop a path on the ground of where they have traveled. Reset these options with the 'Reset' button.

- **RESET**: Use this button to reset the perspective of the simulation, remove pen markings, and remove labels.

## D. Follow Data Plots

- **IDENTIFY SUBJECT**: Follow the subject slug, of which the data plots are being collected.

- **RESET**: Use this button to reset the perspective of the simulation, remove pen markings, and remove labels.





<a id="anchor-5"></a>

# V. THINGS TO NOTICE

1. Notice the subject slug's approach when encountering a food item. Does it orient towards or away from it? What is its satiation state? Has it learned anything from previous encounters regarding this species?

2. Notice that slugs bite flabellina and spit them out again, before orienting away from them (flabellina secrete painful toxins). Is the slug naïve, or hungry enough to bite the same flabellina again?

3. Notice a slug's reaction when encountering other slugs. Does it orient towards or away from them, ignore them, or eat them?

4. Notice mating behavior (this feature can be enabled/disabled).

5. Notice the average satiation levels at which slugs eat different food-items (on the right-hand side of the interface). After multiple trails and time-periods, do you notice that certain food-items are consumed only when satiation levels are diminished? Are there any patterns that emerge?





<a id="anchor-6"></a>

# VI. THINGS TO TRY


1. Try changing the hermisenda/ flabellina/ faux-hermisenda population levels. Does including faux-hermisenda make it more or less likely that a red-odored individual gets bitten? If there are more hermisenda than flabellina, will that change the likelihood of a 'mistake'? Try looking at the average satiation levels that each food-item is bitten in the right-hand side of the interface for comparison.

2. Try letting the model run for a while, and then remove all the food with the 'Remove Food' button. Predict whether the subject slug will orient towards or away from you spraying hermisenda/flabellina odor in its path using the 'Click-Interaction' menu.

3. Enable 'Growth' and press the 'Show Sizes' button. Try dragging slugs into each others' paths and predict how each slug will react based on its size. Will it orient towards or away from the slug, or ignore it? If the slugs are large (about 7-8 units large) will they mate? Try using the 'Grow Slug' option from the 'Click-Interactions' menu to alter the slugs' sizes and see how they react.





<a id="anchor-7"></a>

# VII. LOADING THIS APPLET ONTO YOUR WEBPAGE

- In order for this package to work as an applet, all files should be located in the same directory. (You can copy NetLogoLite.jar from the directory where you installed NetLogo.)

- On some systems, you can test the applet locally on your computer before uploading it to a web server. It doesn't work on all systems, though, so if it doesn't work from your hard drive, please try uploading it to a web server.

- You don't need to include everything in this file in your page. If you want, you can just take the HTML code beginning with '< applet >' and ending with "< /applet >", and paste it into any HTML file you want. It's even OK to put multiple '< applet >' tags on a single page.

- If *NetLogoLite.jar* and your model are in different directories, you must modify the archive= and value= lines in the HTML code to point to their actual locations. (For example, if you have multiple applets in different directories on the same web server, you may want to put a single copy of NetLogoLite.jar in one central place and change the archive= lines of all the HTML files to point to that one central copy. This will save disk space for you and download time for your users.)





<a id="anchor-8"></a>

# VIII. ANEMONE MEMORY AND LEARNING SIMULATION

An additional simulation (*anemone.nlogo*) is included with these packages, which simulates the learning-behavior of sea anemone tentacles, which possess memory independently of each other.

To start or stop the simulation, simply press 'Go'. Press 'Setup' to reset the simulation.

Grab the flabellina slug and drag it towards the blue anemonae's tentacles. Each tentacle will draw the flabellina towards the anemone's mouth.

However, each specific tentacle has a memory that recognizes when a particular odor is distasteful to the mouth (like the odor of the flabellina).

Those specific tentacles that have learned that the flabellina is poisonous will ignore it in the future.

![Anemone simulation being run.](https://github.com/derekca/cyberslug/blob/master/img_anemone.png)





<a id="anchor-9"></a>

# IX. CREDITS AND REFERENCES

Derek Caetano-Anolles, Rhanor Gillette, Mark Nelson.
2009, University of Illinois at Urbana-Champaign.






<a id="anchor-10"></a>

# X. AUTHOR NOTES

- **Author:** Derek Caetano-Anolles

- **Website:** [derekca.xyz](http://derekca.xyz)

- **Repository:** [github.com/derekca](https://github.com/derekca)

- **Licenses:** Unless otherwise stated, the materials presented in this package are distributed under the [MIT License.](https://opensource.org/licenses/MIT)

- **Acknowledgements:** These materials are based upon work from the lab of [Dr. Rhanor Gillette](https://mcb.illinois.edu/faculty/profile/rhanor/) at the University of Illinois at Urbana-Champaign. Additional help was provided by [Dr. Mark Nelson](https://mcb.illinois.edu/faculty/profile/m-nelson/).

- **Final Project Cited On:** Brown JW, Caetano-Anollés D, Catanho M, Gribkova E, Ryckman N, Tian K, Voloshin M, Gillette R. (2017). Implementing Goal-Directed Foraging Decisions of a Simpler Nervous System in Simulation. eNeuro eN-NWR-0400-17.2018. [DOI: 10.1523/ENEURO.0400-17.2018.](http://www.eneuro.org/content/5/1/ENEURO.0400-17.2018)

- **Project Notes:** These materials represent an early version of the *CyberSlug* simulation, originally written by Derek Caetano-Anollés in 2009. The project has since been expanded, so additional information and updates can be found at the [Slug City](https://publish.illinois.edu/slug-city/) website.

- **Edited:** 2009.12.09





